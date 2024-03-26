Shader "URP/Depth_Effect_02"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SoftFade("_SoftFade",Float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        CBUFFER_START(UnityPerMaterial)
        float _SoftFade;
        float4 _MainTex_ST;
        CBUFFER_END
        
        TEXTURE2D(_CameraDepthTexture);
        SAMPLER(sampler_CameraDepthTexture);
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        
        struct a2v
        {
            float3 positionOS : POSITION;
            float4 normalOS : NORMAL;
            float2 texcoord :TEXCOORD0;
        };
        struct v2f
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS : NORMAL;
            float3 positionWS:TEXCOORD1;
            float2 uv :TEXCOORD2;
            float4 srcPos : TEXCOORD3;
        };
        ENDHLSL
        Pass
        {
            Name "Pass"
            Tags
            {
                "LightMode" = "UniversalForward"
                "RenderType"="Transparent"
            }

            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert(a2v v)
            {
                v2f o;

                VertexPositionInputs  PositionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = PositionInputs.positionCS;                                        //获取裁剪空间位置
                o.positionWS = PositionInputs.positionWS;//获取世界空间位置信息
                o.srcPos = ComputeScreenPos(o.positionCS);
                VertexNormalInputs NormalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                o.normalWS.xyz = NormalInputs.normalWS;                                //  获取世界空间下法线信息
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                half4 DiffuseTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy);
                float2 NDC_Pos = i.srcPos.xy/i.srcPos.w;//[0-1]透视除法
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,NDC_Pos);//-[w,w]计算深度
                float LinearDepth = LinearEyeDepth(depth,_ZBufferParams);
                float fade = saturate((LinearDepth-i.srcPos.w)/_SoftFade);//使用全部深度 --减去物体的深度
                float4 col = DiffuseTex;
                col.a *= fade;
                return col;
            }
            ENDHLSL
        }
    }
} 