Shader "URP/Thermal distortion"
{
    Properties
    {
        _NoiseTex("Noise Tex",2D) = "while"{}
        _MaskTex("Mask Tex",2D)="whilt"{}
        _TimeSpeed("Heat Time",Range(0,1))=0.1
        _Force("Force",Range(0,0.1))=0.05
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnorePorjector"="True"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOOORD1;
                float4 scrPos : TEXCOORD2;
                float3 normalWS : NORMAL;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _NoiseTex_ST;
            float4 _MaskTex_ST;
            float _TimeSpeed,_Force;
            CBUFFER_END
            SAMPLER(_CameraOpaqueTexture);      //注意名字
            TEXTURE2D(_NoiseTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_NoiseTex);
            SAMPLER(sampler_MaskTex);
            
            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs PositionInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.pos = PositionInputs.positionCS;
                o.posWS = PositionInputs.positionWS;
                
                o.scrPos = ComputeScreenPos(o.pos);
                
                VertexNormalInputs NormalInputs = GetVertexNormalInputs(v.normal.xyz);
                o.normalWS.xyz = NormalInputs.normalWS;
                
                o.uv.xy = TRANSFORM_TEX(v.texcoord,_NoiseTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord,_MaskTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 uv1 = i.uv.xy + _Time.y * _TimeSpeed;
                half2 uv2 = i.uv.xy - _Time.y * _TimeSpeed;
                half4 noise1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv1);
                half4 noise2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv2);

                half distortX = ((noise1.r + noise2.r) - 1) * _Force;
                half distortY = ((noise1.g + noise2.g) - 1) * _Force;
                half mask = SAMPLE_TEXTURE2D(_MaskTex,sampler_MaskTex,i.uv.zw).r;

                half2 screenUV = (i.pos.xy / _ScreenParams.xy) + float2(distortX, distortY);
                half4 col = tex2D(_CameraOpaqueTexture, screenUV);
                return float4(col.xyz, mask);
            }
            ENDHLSL
        }
    }
}
