Shader "URP/MainLightShadow"
{
    Properties
    {
        _MainTex("MainTex",2D)="white"{}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Gloss("gloss",Range(10,300))=20
        _SpecularColor("SpecularColor",Color )=(1,1,1,1)
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalRenderPipeline"
            "RenderType"="Opaque"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            half _Gloss;
            real4 _SpecularColor;
        CBUFFER_END
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        struct a2v
        {
            float4 positionOS:POSITION;
            float4 normalOS:NORMAL;
            float2 texcoord:TEXCOORD;
        };
        struct v2f
        {
            float4 positionCS:SV_POSITION;
            float2 texcoord:TEXCOORD;
            float3 positionWS:TEXCOORD1;
            float3 normalWS:NORMAL;
        };
        ENDHLSL
        pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex VERT
            #pragma fragment FRAG
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT//柔化阴影，得到软阴影，造成性能的降低
            v2f VERT(a2v i)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(i.positionOS.xyz);
                o.texcoord = TRANSFORM_TEX(i.texcoord, _MainTex);
                o.positionWS = TransformObjectToWorld(i.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(i.normalOS);
                return o;
            }
            half4 FRAG(v2f i):SV_TARGET
            {
                half4 tex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord) * _BaseColor;
                Light mylight = GetMainLight(TransformWorldToShadowCoord(i.positionWS));
                float3 LightDir = normalize(mylight.direction);
                float3 normalWS = normalize(i.normalWS);
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.positionWS);
                float3 worldHalf = normalize(viewDir + LightDir);
                tex *= (dot(LightDir, normalWS) * 0.5 + 0.5) * mylight.shadowAttenuation * real4(mylight.color, 1);
                float4 Specular = pow(max(dot(normalWS, worldHalf), 0), _Gloss) * _SpecularColor * mylight.shadowAttenuation;
                return tex + Specular;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}