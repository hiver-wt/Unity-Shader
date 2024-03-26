Shader "URP/FrameAnimation"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Speed("Speed",Float)=25
        _Sheet("Sheet",Vector)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
            half4 _Sheet;
            float _Speed;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv_small;  //小方块的uv
                uv_small.x = i.uv.x/_Sheet.x+frac(floor(_Time.y*_Speed)/_Sheet.x);
                // uv_small.y = i.uv/8+frac(floor(_Time.y*25/8)/8);//x满8之后，y才+1
                uv_small.y = i.uv.y/_Sheet.y+1-frac(floor(_Time.y*_Speed/_Sheet.x)/_Sheet.y);//x满8之后，y才+1,修正方向
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv_small)*_BaseColor;
                return tex;
            }
            ENDHLSL
        }
    }
}
