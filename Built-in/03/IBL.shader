Shader "IBL"
{
    Properties
    {
        // _MainTex ("Texture", 2D) = "white" {}
        [Header(CubeMap)]
        _CubeMap("Cube Map", Cube) = "white"{}  // 立方体贴图属性
        _Tint("Tint", Color) = (1, 1, 1, 1)     // 物体颜色调整
        _Expose("Expose", Float) = 1.0          // 物体的曝光度
        _Rotate("Rotate", Range(0, 360)) = 0     // 用于旋转反射方向的角度

        [Header(Normal)]
        _NormalMap("Normal Map", 2D) = "bump"{} // 法线贴图
        _NormalIntensity("Normal Intensity", Float) = 1.0  // 法线贴图强度

        [Header(AO)]
        _AOMap("AO Map", 2D) = "white"{}         // 环境光遮蔽贴图
        _AOAdjust("AO Adjust", Range(0, 1)) = 1  // 环境光遮蔽调整

        [Header(Roughness)]
        _RoughnessMap("Roughness Map", 2D) = "black"{}  // 粗糙度贴图
        _RoughnessContrast("Roughness Contrast", Range(0.01, 10)) = 1  // 粗糙度对比度
        _RoughnessBrightness("Roughness Brightness", Float) = 1     // 粗糙度亮度
        _RoughnessMin("Rough Min", Range(0, 1)) = 0               // 粗糙度最小值
        _RoughnessMax("Rough Max", Range(0, 1)) = 1               // 粗糙度最大值
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }  // 渲染类型标记为不透明
        LOD 100                         // Level of Detail

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // 输入顶点结构
            struct appdata
            {
                float4 vertex : POSITION;     // 顶点位置
                float2 texcoord : TEXCOORD0;  // 纹理坐标
                float3 normal : NORMAL;       // 法线向量
                float4 tangent : TANGENT;     // 切线向量
            };

            // 输出顶点结构
            struct v2f
            {
                float2 uv : TEXCOORD0;          // 传递给片元着色器的纹理坐标
                float4 pos : SV_POSITION;       // 传递给像素位置的裁剪空间坐标
                float3 normal_world : TEXCOORD1;  // 传递世界空间法线
                float3 pos_world : TEXCOORD2;     // 传递世界空间位置
                float3 tangent_world : TEXCOORD3; // 传递世界空间切线
                float3 binormal_world : TEXCOORD4;  // 传递世界空间副法线
            };

			samplerCUBE _CubeMap;
			float4 _CubeMap_HDR;
			float4 _Tint;
			float _Expose;
            float _Rotate;

			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			float _NormalIntensity;

			sampler2D _AOMap;
			float _AOAdjust;

			float _Roughness;
			sampler2D _RoughnessMap;
			float _RoughnessContrast;
			float _RoughnessBrightness;
			float _RoughnessMin;
			float _RoughnessMax;

            float3 RotateAround(float degree, float3 target)
			{
				float rad = degree / 180 * UNITY_PI; 
				float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
					sin(rad), cos(rad));
				float2 dir_rotate = mul(m_rotate, target.xz);
				target = float3(dir_rotate.x, target.y, dir_rotate.y);
				return target;
			}

            // 定义ACES tonemapping函数
            inline float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                float3 encode_color = saturate((x * (a * x + b)) / (x * (c * x + d) + e));
                return encode_color;
            };

            // 顶点着色器
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world)) * v.tangent.w;
                return o;
            }

            // 片元着色器
            half4 frag(v2f i) : SV_Target
            {
                // 计算法线方向
                half3 normal_dir = normalize(i.normal_world);
                // 解码法线贴图
                half3 normaldata = UnpackNormal(tex2D(_NormalMap, i.uv));
                // 应用法线强度
                normaldata.xy = normaldata.xy * _NormalIntensity;
                // 计算切线和副法线方向
                half3 tangent_dir = normalize(i.tangent_world);
                half3 binormal_dir = normalize(i.binormal_world);
                // 根据法线贴图调整法线方向
                normal_dir = normalize(tangent_dir * normaldata.x + binormal_dir * normaldata.y + normal_dir * normaldata.z);

                // 读取环境光遮蔽值
                half ao = tex2D(_AOMap, i.uv).r;
                ao = lerp(1.0, ao, _AOAdjust);
                // 计算视线方向
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                // 计算反射方向
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                reflect_dir = RotateAround(_Rotate, reflect_dir);

                // 计算粗糙度
                half roughness = tex2D(_RoughnessMap, i.uv);
                roughness = saturate(pow(roughness, _RoughnessContrast) * _RoughnessBrightness);
                roughness = lerp(_RoughnessMin, _RoughnessMax, roughness);
                roughness = roughness * (1.7 - 0.7 * roughness);  //转化为平滑的变换
                float mip_level = roughness * 6.0;

                // 从立方体贴图中采样颜色
                half4 color_cubemap = texCUBElod(_CubeMap, float4(reflect_dir, mip_level));
                // 解码HDR颜色
                half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);
                half3 final_color = env_color * ao * _Tint.rgb * _Expose;
                half3 final_color_linear = pow(final_color, 2.2);
                final_color = ACES_Tonemapping(final_color_linear);
                half3 final_color_gamma = pow(final_color, 1.0 / 2.2);

                return float4(final_color_gamma, 1.0);
            }
            ENDCG
        }
    }
}
