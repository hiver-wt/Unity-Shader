Shader "URP/Depth_Effect_01"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SoftFade("_SoftFade",Float) = 1.0
        _SoftSize("_SoftSize",Range(0,0.005)) = 0.00076
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
        float _SoftFade,_SoftSize;
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
                o.positionWS = PositionInputs.positionWS;                                        //获取世界空间位置信息

                VertexNormalInputs NormalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                o.normalWS.xyz = NormalInputs.normalWS;                                //  获取世界空间下法线信息
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {
                half4 DiffuseTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy);

                float2 screenPos = i.positionCS.xy / _ScreenParams.xy;                                          // 物体在屏幕的位置
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenPos);       //深度值
                float linear01Depth = Linear01Depth(depth,_ZBufferParams);                                      //转换成[0,1]内的线性变化深度值

                float Ddepth = i.positionCS.z;                                //齐次裁剪空间物体像素深度
                float D = Linear01Depth(Ddepth,_ZBufferParams);               //转换线性深度

                float one = saturate((D - linear01Depth + _SoftSize) * 100 * _SoftFade);
                float4 col = DiffuseTex;
                col.a *= 1 - one;                                              //取反向 输出到Alpha
                return col;
            }
            ENDHLSL
        }
    }
} 