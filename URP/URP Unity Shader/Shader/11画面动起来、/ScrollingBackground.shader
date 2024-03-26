Shader "URP/Scrolling Background"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
        _SecondTex("Second Tex",2D) = "white" {}
        _MainSpeed("Main Speed",Float) = 1
        _SecondSpeed("Second Speed",Float) = 1
        _Multiplier("Layer Multiplier", Float) = 1// 纹理整体亮度
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                //用一个四维的TEXCOORD 采样两个二维的纹理，以减少占用的插值寄存器空间。
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _SecondTex_ST;
            half _MainSpeed;
            half _SecondSpeed;
            half _Multiplier;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            TEXTURE2D(_SecondTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecondTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex)+frac(float2(_MainSpeed, 0.0) * _Time.y);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_SecondTex)+frac(float2(_SecondSpeed, 0.0) * _Time.y);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 firstLayer = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy);
                float4 secondLayer = SAMPLE_TEXTURE2D(_SecondTex,sampler_SecondTex,i.uv.zw);
                float4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Multiplier;
				return c;
            }
            ENDHLSL
        }
    }
FallBack "Packages/com.unity.render-pipelines.universal/FallbackError"
}
