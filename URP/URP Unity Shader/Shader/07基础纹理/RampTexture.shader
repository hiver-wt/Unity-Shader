Shader "URP/RampTexture"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
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
                //o.uv = v.textcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.posWS = TransformObjectToWorld(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                half3 normalWS = normalize(i.normalWS);
                half3 posWS = i.posWS;

                //反射率
                half3 albedo = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w)*albedo;
                //获得光源
                Light mylight = GetMainLight();
                real4 LightColor = float4(mylight.color,1);
                half3 LightDir = normalize(mylight.direction);
                //漫反射
                half halfLambert = dot(normalWS,LightDir)*0.5+0.5;
                half3 diffuseColor = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,half2(halfLambert, 0.5))*_BaseColor;
                half3 diffuse = LightColor*diffuseColor;
                //高光：n·h
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz-posWS);
                half3 halfVec = normalize(viewDir+LightDir);
                half3 specular = LightColor*_Specular*pow(saturate(dot(normalWS,halfVec)),_Gloss);
                
                half3 color=ambient+diffuse+specular;
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
