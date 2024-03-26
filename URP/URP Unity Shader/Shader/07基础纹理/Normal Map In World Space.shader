Shader "URP/Normal Map In World Space"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D)= "bump" {}
        _NormalIntensity("Normal Intensity",Range(0,1))=1.0
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Specular("_Specular",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
        ENDHLSL

        Pass
        {
            Tags{"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                // 一个插值寄存器最多只能存储float4大小的变量  
                // 所以对于矩阵，把它们按行拆成多个变量再进行存储  
                float4 TtoW0 : TEXCOORD1;  
                float4 TtoW1 : TEXCOORD2;  
                float4 TtoW2 : TEXCOORD3;  
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            half4 _BaseColor;
            half4 _Specular;
            half _NormalIntensity;
            float _Gloss;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalMap);
                
                float3 posWS = TransformObjectToWorld(v.vertex);
                half3 normalWS = TransformObjectToWorldNormal(v.normal);
                half3 tangentWS = TransformObjectToWorldDir(v.tangent);
                half3 binormalWS = cross(normalWS,tangentWS)*v.tangent.w;

                //TBN
                o.TtoW0 = float4(tangentWS.x, binormalWS.x, normalWS.x, posWS.x);  
                o.TtoW1 = float4(tangentWS.y, binormalWS.y, normalWS.y, posWS.y);  
                o.TtoW2 = float4(tangentWS.z, binormalWS.z, normalWS.z, posWS.z);  
                
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 posWS = float3(i.TtoW0.w,i.TtoW1.w,i.TtoW2.w);
                //获得光源
                Light mylight = GetMainLight();
                half3 lightDir = normalize(mylight.direction);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz-posWS);

                half3 normal = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv.zw));
                normal.xy *= _NormalIntensity;
                normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy))); // |normal|=1
                //法线信息从切线空间到世界空间
                normal = normalize(half3(dot(i.TtoW0.xyz,normal),dot(i.TtoW1.xyz,normal),dot(i.TtoW2.xyz,normal)));
                
                //反射率
                half3 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy)*_BaseColor;
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w)*albedo;
                //漫反射
                half3 diffuse = albedo*mylight.color*saturate(dot(normal,lightDir)*0.5+0.5);
                //高光：
                half3 halfVec = normalize(viewDir+lightDir);
                half3 specular = mylight.color*_Specular*pow(saturate(dot(normal,halfVec)),_Gloss);
                
                half3 color=ambient+diffuse+specular;
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
