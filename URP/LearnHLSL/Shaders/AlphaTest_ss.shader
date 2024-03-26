Shader "URP/AlphaTest"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Cutoff("Cutoff",Float)=1
        [HDR]_BurnColor("BurnColor",Color)=(2.5,1,1,1)
        _BurnWidth("BurnWidth",Float)=0.1
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="TransparentCutOut"
            "RenderPipeline"="UniversalRenderPipeline"
            "Queue"="AlphaTest"
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
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            float _Cutoff;
            float _BurnWidth;
            float4 _BurnColor;
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
                // clip(step(_Cutoff,tex.r)-0.01);  //clip对0本身也是保留，需要减去0.01
                clip(tex.r-_Cutoff);
                tex = lerp(tex,_BurnColor,step(tex.r,saturate(_Cutoff+_BurnWidth)));   // lerp一下灼烧色和原色 +0.1是控制灼烧区域范围
                return tex;
            }
            ENDHLSL
        }
    }
}
