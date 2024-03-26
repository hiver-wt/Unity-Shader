Shader "URP/Depth"
{
    Properties
    {
        _DepthOffset("Depth Offset",Float)=0.0
        _BaseColor("BaseColor",Color)=(1,1,1,1)
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
                // float3 posVS : TEXCOORD1;
                // float3 posWS : TEXCOORD2;
                float4 scrPos : TEXCOORD3;
            };
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _DepthOffset;
            CBUFFER_END
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                // o.posWS = TransformObjectToWorld(v.vertex);
                // o.posVS = TransformWorldToView(o.posWS);
                o.scrPos = ComputeScreenPos(o.pos);//获得屏幕坐标
                o.uv = v.texcoord;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 screenPos = i.scrPos.xy/i.scrPos.w;  //透视除法
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,screenPos);
                float linearDepth = Linear01Depth(depth,_ZBufferParams)+_DepthOffset; //转换成[0,1]内的线性变化深度值
                // float EyeDepth = i.scrPos.w;
                float4 col = float4(linearDepth.xxx,1);
                return col;
            }
            ENDHLSL
        }
    }
}
