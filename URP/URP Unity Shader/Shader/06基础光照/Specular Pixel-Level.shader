Shader "URP/Specular Pixel-Level"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Specular("BaseColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 posWS : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            half4 _Specular;
            float _Gloss;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.posWS = TransformObjectToWorld(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                half3 normalWS = normalize(i.normalWS);
                half3 posWS = i.posWS;
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                //获得光源
                Light mylight = GetMainLight();
                half3 LightDir = normalize(mylight.direction);
                //计算漫反射
                half3 diffuse = mylight.color*_BaseColor*saturate(dot(normalWS,LightDir));
                //计算高光：r·v
                half3 reflectDir = normalize(reflect(-LightDir,normalWS));
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz-posWS);
                half3 specular = mylight.color*_Specular*pow(saturate(dot(reflectDir,viewDir)),_Gloss);
                
                half3 color=ambient+diffuse+specular;
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
