Shader "URP/Normal Map In Tangent Space"
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
                float3 lightDir : TEXCOORD1;  
                float3 viewDir : TEXCOORD2;
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
                
                //计算副切线  
                float3 binormal = normalize(cross( v.normal, v.tangent.xyz )) * v.tangent.w;  
                //计算从模型空间到切线空间的旋转矩阵  
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // 得到模型空间下的光照和视角方向，再利用旋转矩阵变化到切线空间中  
                o.lightDir = mul(rotation,TransformWorldToObject(_MainLightPosition.xyz)-v.vertex).xyz;  
                o.viewDir = mul(rotation, TransformWorldToObject(GetCameraPositionWS())-v.vertex).xyz;  
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                half3 tangentLightDir = normalize(i.lightDir);
                half3 tangentViewDir = normalize(i.viewDir);

                half4 packedNormal = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv.zw);

                half3 tangentNormal;

                // 如果材质类型不是Normal map：  
                // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale; // 进行映射  
                // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));// |normal|=1
                
                // 如果材质类型是Normal map，可以使用 function：  
                tangentNormal=UnpackNormal(packedNormal);
                tangentNormal.xy *= _NormalIntensity;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy))); // |normal|=1  
                
                //反射率
                half3 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy)*_BaseColor;
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w)*albedo;
                //获得光源
                Light mylight = GetMainLight();
                //漫反射
                half3 diffuse = albedo*mylight.color*saturate(dot(tangentNormal,tangentLightDir)*0.5+0.5);
                //高光：
                half3 halfVec = normalize(tangentViewDir+tangentLightDir);
                half3 specular = mylight.color*_Specular*pow(saturate(dot(tangentNormal,halfVec)),_Gloss);
                
                half3 color=ambient+diffuse+specular;
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
