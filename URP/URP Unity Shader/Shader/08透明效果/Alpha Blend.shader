Shader "URP/Alpha Blend"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _AlphaScale("AlphaScale",Range(0,1))=1
    }
    SubShader
    {
        Tags {"RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL
        Pass
        {
            Tags{"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent"}
            // 关闭深度写入  
            ZWrite Off  
            // 将源颜色（该片元着色器产生的颜色）混合因子设为SrcAlpha  
            // 目标颜色（已经存在于颜色缓冲中的颜色）混合因子设为OneMinusSrcAlpha  
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
            float _AlphaScale;
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
                return float4(tex.xyz,tex.a*_AlphaScale);
            }
            ENDHLSL
        }
    }
}
