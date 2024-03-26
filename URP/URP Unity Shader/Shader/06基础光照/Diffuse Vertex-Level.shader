Shader "URP/Diffuse Vertex-Level"
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 color : TEXCOORD1;
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
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                //获得光源
                Light mylight = GetMainLight();
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                //法线
                half3 normalWS = TransformObjectToWorldNormal(v.normal);
                //计算漫反射
                float3 diffuse = mylight.color*_BaseColor*saturate(dot(normalWS,mylight.direction));
                o.color=ambient+diffuse;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;
                return float4(i.color,1.0);
            }
            ENDHLSL
        }
    }
}
