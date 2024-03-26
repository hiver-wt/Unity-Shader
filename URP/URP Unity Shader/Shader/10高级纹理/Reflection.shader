Shader "URP/Reflection"
{
    Properties
    {
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _CubeMap("Cube Map",Cube)="_Skybox"{}
        _ReflectColor("Reflection Color", Color) = (1, 1, 1, 1)
        _ReflectAmount("Reflect Amount", Range(0, 1)) = 1
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
            half4 _ReflectColor;
            half _ReflectAmount;
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
                half3 reflectDir = reflect(-viewDir,normalWS);
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                //获得光源
                Light mylight = GetMainLight();
                half3 LightDir = normalize(mylight.direction);
                //计算漫反射
                half3 diffuse = mylight.color*_BaseColor*saturate(dot(normalWS,LightDir));
                //采样cubeMap
                half3 reflection = SAMPLE_TEXTURECUBE(_CubeMap,sampler_CubeMap,reflectDir)* _ReflectColor.rgb;
                // 使用线性插值根据_ReflectAmount对漫反射和反射颜色进行混合
                half3 color=ambient+lerp(diffuse,reflection,_ReflectAmount);
                return float4(color,1.0);
            }
            ENDHLSL
        }
    }
}
