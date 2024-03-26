Shader "URP/Vertex distortion"
{
    Properties
    {
        _NormalTex("_NormalTex",2D) = "bump" {}
        _NormalScale("_NormalScale",range(0,0.05)) = 0.01
    }
    HLSLINCLUDE
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    CBUFFER_START(UnityPerMaterial)
        float4 _NormalTex_ST;
        float _NormalScale;
    CBUFFER_END

    struct appdata
    {
        float4 positionOS : POSITION;
        float2 texcoord : TEXCOORD0;
        float4 vertexColor : COLOR;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 pos : SV_POSITION;
        float4 vertexColor : COLOR;
    };

    TEXTURE2D(_NormalTex);
    SAMPLER(sampler_NormalTex);

    SAMPLER(_CameraOpaqueTexture); //定义贴图
    ENDHLSL

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent"  "Queue" = "Transparent" "IgnoreProjector" = " True"}
        LOD 100

        Pass
        {
            Tags{ "LightMode"="UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.positionOS.xyz);
                o.uv = TRANSFORM_TEX(v.texcoord, _NormalTex);
                o.vertexColor = v.vertexColor;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 NormalTex = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv),_NormalScale);

                half2 screenUV = (i.pos.xy / _ScreenParams.xy) + half2(NormalTex.rg  * i.vertexColor.a);
                half4 col = tex2D(_CameraOpaqueTexture, screenUV);
                return col;
            }
            ENDHLSL
        } 
    }
}
