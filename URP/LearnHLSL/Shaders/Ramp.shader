Shader "URP/Ramp"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
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
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normalWS : NORMAL;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.texcoord;
                o.normalWS = TransformObjectToWorldNormal(v.normalOS);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                real3 light_dir = normalize(GetMainLight().direction);
                float NdotL = dot(i.normalWS,light_dir)*0.5+0.5;
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,float2(NdotL,0.5))*_BaseColor;
                return tex;
            }
            ENDHLSL
        }
    }
}
