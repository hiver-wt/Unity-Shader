Shader "URP/Refraction"
{
    Properties
    {
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _CubeMap("Cube Map",Cube)="_Skybox"{}
        _RefractColor("Reflection Color", Color) = (1, 1, 1, 1)
        _RefractAmount("Reflect Amount", Range(0, 1)) = 1
        _RefractRatio("Refraction Ratio", Range(0.1, 1)) = 0.5// 折射率比
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL

        Pass
        {
            Tags{"LightMode" = "UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 posWS : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half4 _RefractColor;
            half _RefractAmount;
            half _RefractRatio;
            CBUFFER_END
            TEXTURECUBE(_CubeMap);
            SAMPLER(sampler_CubeMap);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                o.posWS = TransformObjectToWorld(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                half3 normalWS = normalize(i.normalWS);
                half3 posWS = i.posWS;
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz-posWS);
                half3 refractDir = refract(-viewDir,normalWS,_RefractRatio);
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                //获得光源
                Light mylight = GetMainLight();
                half3 LightDir = normalize(mylight.direction);
                //计算漫反射
                half3 diffuse = mylight.color*_BaseColor*saturate(dot(normalWS,LightDir));
                //采样cubeMap
                half3 refraction = SAMPLE_TEXTURECUBE(_CubeMap,sampler_CubeMap,refractDir)* _RefractColor.rgb;
                // 使用线性插值根据_ReflectAmount对漫反射和反射颜色进行混合
                half3 color=ambient+lerp(diffuse,refraction,_RefractAmount);
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
