Shader "Unlit/CubeMap"
{
    Properties
    {
        _CubeMap("Cube Map", Cube) = "white"{}   // 立方体贴图属性
        _Tint("Tint", Color) = (1, 1, 1, 1)     // 物体颜色的调整
        _Expose("Expose", Float) = 1.0           // 物体的曝光度
        _Rotate("Rotate", Range(0, 360)) = 0     // 用于旋转反射方向的角度
        _NormalMap("Normal Map", 2D) = "bump"{}  // 法线贴图
        _NormalIntensity("Normal Intensity", Float) = 1.0  // 法线贴图强度
        _AOMap("AO Map", 2D) = "white"{}         // 环境光遮蔽贴图
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }  // 渲染类型标记为不透明
        LOD 100                        // Level of Detail

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

            samplerCUBE _CubeMap;          // 立方体贴图
            float4 _CubeMap_HDR;          // 立方体贴图的HDR数据
            float4 _Tint;                 // 物体颜色调整
            float _Expose;                // 物体曝光度

            sampler2D _NormalMap;         // 法线贴图
            float4 _NormalMap_ST;         // 法线贴图的缩放和偏移
            float _NormalIntensity;       // 法线贴图强度

            sampler2D _AOMap;             // 环境光遮蔽贴图
            float _Rotate;                // 用于旋转反射方向的角度

            // 旋转贴图，绕y轴旋转
            float3 RotateAround(float degree, float3 target)
            {
                float rad = degree * UNITY_PI / 180;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
                    sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
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
                // 计算视线方向
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                // 计算反射方向
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                // 旋转反射方向
                reflect_dir = RotateAround(_Rotate, reflect_dir);
                // 从反射探针立方体贴图中采样颜色
                half4 color_cubemap = texCUBE(_CubeMap, reflect_dir);
                // 解码HDR颜色
                half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);
                // 计算最终颜色
                half3 final_color = env_color * ao * _Tint.rgb * _Expose;
                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
}
