Shader "URP/Depth_Water"
{
    Properties
    {
        _ShallowWater ("shallowColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _DeepWater ("DeepColor", Color) = (1.0, 1.0, 1.0, 1.0)
        _DepthDdgeSize("_DepthDdgeSize",Range(0,100)) = 0.005
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
        float _DepthDdgeSize;
        float4 _ShallowWater,_DeepWater;
        CBUFFER_END
        TEXTURE2D(_CameraDepthTexture);
        SAMPLER(sampler_CameraDepthTexture);       //获取深度贴图

        // 顶点着色器的输入
        struct a2v
        {
            float3 positionOS : POSITION;
            float4 normalOS : NORMAL;
            float2 texcoord :TEXCOORD0;
        };
        // 顶点着色器的输出
        struct v2f
        {
            float4 positionCS : SV_POSITION;
            float3 normalWS : NORMAL;
            float3 positionWS:TEXCOORD1;
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
            
            float4 ComputeScreenPos(float4 pos, float projectionSign)                          //齐次坐标变换到屏幕坐标
            {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x,o.y * projectionSign) + o.w;
                o.zw = pos.zw;
                return o;
			}

            float CustomSampleSceneDepth(float2 uv)
            {
                return SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,uv).r;
			}

            //输入世界空间   WorldPos
            float GetDepthFade(float3 WorldPos, float Distance)
            {
                float4 posCS = TransformWorldToHClip(WorldPos);                                            //转换成齐次坐标
                float4 ScreenPosition = ComputeScreenPos(posCS, _ProjectionParams.x);                      //齐次坐标系下的屏幕坐标值
                //从齐次坐标变换到屏幕坐标， x,y的分量 范围在[-w,w]的范围   _ProjectionParams 用于在使用翻转投影矩阵时（此时其值为-1.0）翻转y的坐标值。
                //这里
                float screenDepth = CustomSampleSceneDepth(ScreenPosition.xy / ScreenPosition.w);        //计算屏幕深度 是非线性

                float EyeDepth = LinearEyeDepth(screenDepth,_ZBufferParams);                   //深度纹理的采样结果转换到视角空间下的深度值
                return saturate((EyeDepth - ScreenPosition.w)/ Distance);                 //使用视角空间下所有深度 减去模型顶点的深度值
			}
            
            v2f vert(a2v v)
            {
                v2f o;

                VertexPositionInputs  PositionInputs = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = PositionInputs.positionCS;                          //获取裁剪空间位置
                o.positionWS = PositionInputs.positionWS;                          //获取世界空间位置信息

                VertexNormalInputs NormalInputs = GetVertexNormalInputs(v.normalOS.xyz);
                o.normalWS.xyz = NormalInputs.normalWS;                                //  获取世界空间下法线信息
                return o;
            }
            
            half4 frag (v2f i) : SV_Target
            {

                float depthfade = GetDepthFade(i.positionWS, _DepthDdgeSize);
                float3 watercolor = lerp(_DeepWater,_ShallowWater,depthfade);
                float4 col = float4(watercolor,1);

                return col;
            }
            ENDHLSL
        }
    }
}