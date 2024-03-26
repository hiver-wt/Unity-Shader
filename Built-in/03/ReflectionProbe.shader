Shader "Unlit/ReflectionProbe"
{
    Properties
    {
        //_CubeMap("Cube Map",Cube) = "white"{}
        _Tint("Tint",Color) = (1,1,1,1)        // 物体颜色的调整
        _Expose("Expose",Float) = 1.0           // 物体的曝光度
        _Rotate("Rotate",Range(0,360)) = 0       // 用于旋转反射方向的角度
        _NormalMap("Normal Map",2D) = "bump"{}   // 法线贴图
        _NormalIntensity("Normal Intensity",Float) = 1.0  // 法线贴图强度
        _AOMap("AO Map",2D) = "white"{}         // 环境光遮蔽贴图
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }           // 指定渲染类型为不透明
        LOD 100                                  // Level of Detail

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"               // 包含Unity的常用着色器函数

            struct appdata
            {
                float4 vertex : POSITION;          // 顶点位置
                float2 texcoord : TEXCOORD0;       // 纹理坐标
                float3 normal : NORMAL;            // 法线向量
                float4 tangent : TANGENT;          // 切线向量
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;              // 传递给片元着色器的纹理坐标
                float4 pos : SV_POSITION;           // 传递给像素位置的裁剪空间坐标
                float3 normal_world : TEXCOORD1;    // 传递世界空间法线
                float3 pos_world : TEXCOORD2;       // 传递世界空间位置
                float3 tangent_world : TEXCOORD3;   // 传递世界空间切线
                float3 binormal_world : TEXCOORD4;  // 传递世界空间副法线
            };

            samplerCUBE _CubeMap;                    // 立方体贴图
            float4 _CubeMap_HDR;                    // 立方体贴图的HDR数据
            float4 _Tint;                           // 物体颜色调整
            float _Expose;                          // 物体曝光度

            sampler2D _NormalMap;                   // 法线贴图
            float4 _NormalMap_ST;                   // 法线贴图的缩放和偏移
            float _NormalIntensity;                 // 法线贴图强度
            sampler2D _AOMap;                       // 环境光遮蔽贴图
            float _Rotate;                         // 用于旋转反射方向的角度

            // 旋转贴图，绕y轴旋转
            float3 RotateAround(float degree, float3 target)
            {
                float rad = degree * UNITY_PI / 180;   // 将角度转换为弧度
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
                    sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);      // 转换顶点坐标到裁剪空间
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject));   // 计算世界空间法线
                o.pos_world  = mul(unity_ObjectToWorld, v.vertex).xyz;  // 计算世界空间位置
                o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0).xyz));  // 计算世界空间切线
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);  // 计算世界空间副法线
                o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;   // 计算法线贴图的纹理坐标
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 normal_dir = normalize(i.normal_world);   // 计算法线方向
                half3 normaldata = UnpackNormal(tex2D(_NormalMap,i.uv));  // 解码法线贴图
                normaldata.xy = normaldata.xy * _NormalIntensity;    // 应用法线强度

                half3 tangent_dir = normalize(i.tangent_world);   // 计算切线方向
                half3 binormal_dir = normalize(i.binormal_world);  // 计算副法线方向
                normal_dir = normalize(tangent_dir * normaldata.x
                    + binormal_dir * normaldata.y + normal_dir * normaldata.z);  // 根据法线贴图调整法线方向
                half ao = tex2D(_AOMap, i.uv).r;   // 读取环境光遮蔽值

                half3 view_dir  = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);   // 计算视线方向
                half3 reflect_dir = reflect(-view_dir, normal_dir);  // 计算反射方向
                reflect_dir = RotateAround(_Rotate, reflect_dir);    // 根据角度旋转反射方向

                // 从反射探针立方体贴图中采样颜色
                half4 env_color = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect_dir);
                half3 env_hdr_color = DecodeHDR(env_color, unity_SpecCube0_HDR);  // 解码HDR颜色

                //half4 color_cubemap = texCUBE(_CubeMap, reflect_dir);
				//half3 env_color = DecodeHDR(color_cubemap, _CubeMap_HDR);//确保在移动端能拿到HDR信息

                half3 final_color = env_hdr_color * ao * _Tint * _Expose;  // 计算最终颜色

                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
}