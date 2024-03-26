Shader "URP/Attenuation And Shadow"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1,1,1,1)
        _Specular("Specular Color", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(10, 256)) = 10
        [Toggle(_AdditionalLights)] _AddLights("AddLights", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _AdditionalLights

            // // 具体解释看 Chapter9-Shadow.shader
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            // #pragma multi_compile _ _SHADOWS_SOFT


            // GetMainLight(shadowCoord)中需要用到 _MAIN_LIGHT_CALCULATE_SHADOWS ，进而用到_MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            // TransformWorldToShadowCoord 中需要用到 _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            // AdditionalLightRealtimeShadow 中需要用到 _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS

            // 可能和精度有关系
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS

            // GetMainLight(shadowCoord)中需要用到 _SHADOWS_SOFT
            #pragma multi_compile _ _SHADOWS_SOFT

            CBUFFER_START(UnityPerMaterial)
                half4 _Diffuse;
                half4 _Specular;
                half _Gloss;
            CBUFFER_END

            struct a2v
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half3 worldPos : TEXCOORD0;
                half3 worldNormal : TEXCOORD1;
                // SHADOW_COORDS(2)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                // TRANSFER_SHADOW(o);
                return o;
            }

            half3 LightingBased(half3 lightColor, half3 lightDir, half lightAtten, half3 worldNormal, half3 viewDir)
            {
                lightDir = normalize(lightDir);
                viewDir = normalize(viewDir);

                half3 diffuse = lightColor * _Diffuse.rgb * saturate(dot(worldNormal, lightDir));
                half3 halfDir = normalize(lightDir + viewDir);
                half3 specular = lightColor * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);

                return (diffuse + specular) * lightAtten;
            }

            half3 LightingBased(Light light, half3 worldNormal, half3 viewDir)
            {
                return LightingBased(light.color, light.direction, light.shadowAttenuation * light.distanceAttenuation,
                    worldNormal, viewDir);
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                float4 shadowCoord = TransformWorldToShadowCoord(i.worldPos);
                Light mainLight = GetMainLight(shadowCoord);
                half3 color = LightingBased(mainLight, worldNormal, viewDir);
                #if _AdditionalLights
                uint addLightCount = GetAdditionalLightsCount();
                for (uint iu = 0; iu < addLightCount; iu++)
                {
                    Light addLight = GetAdditionalLight(iu, i.worldPos);
                    color += LightingBased(addLight, worldNormal, viewDir);
                }
                #endif

                half3 ambient = SampleSH(worldNormal);
                return half4(color + ambient, 1.0);
            }
            ENDHLSL
        }

        // 方式1：下面计算阴影的Pass可以直接通过使用URP内置的Pass计算
        UsePass "Universal Render Pipeline/Simple Lit/ShadowCaster"
    }
}