Shader "URP/Alpha Test"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Cutoff("CutOff",Range(0,1))=0
    }
    SubShader
    {
        Tags {"RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL
        Pass
        {
            Tags{"Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType"="TransparentCutout"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            float _Cutoff;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;
                clip(tex.a - _Cutoff);
                //clip对0本身也是保留
                // Equal to  
                // if((tex.a - _Cutoff < 0.0)
                // {
                        //discard;
                // }  
                return tex;
            }
            ENDHLSL
        }
    }
}
