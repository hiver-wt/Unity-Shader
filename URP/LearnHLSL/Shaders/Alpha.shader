Shader "URP/Alpha"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _AlphaTex ("AlphaTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent"
            "RenderPipeline"="UniversalRenderPipeline"
            "IgnoreProjector"="True"
            "Queue"="Transparent"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
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
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _AlphaTex_ST;
            half4 _BaseColor;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            TEXTURE2D(_AlphaTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_AlphaTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _AlphaTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xw)*_BaseColor;
                float alpha = SAMPLE_TEXTURE2D(_AlphaTex,sampler_AlphaTex,i.uv.zw).x;
                return float4(tex.xyz,alpha);
            }
            ENDHLSL
        }
    }
}
