Shader "URP/multiLightShadow"
{
    Properties
    {
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Specular("SpecularColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(10,256))=64
        [Toggle(_AdditionalLights)] _AddLights("AddLights", Float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        ENDHLSL

        Pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _AdditionalLights

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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 posWS : TEXCOORD1;
                float3 normalWS : NORMAL;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _Specular;
                half _Gloss;
            CBUFFER_END

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.posWS = TransformObjectToWorld(v.vertex);
                o.normalWS = TransformObjectToWorldNormal(v.normal);
                return o;
            }

            half3 LightingBased(half3 lightColor, half3 lightDir, half lightAtten, half3 worldNormal, half3 viewDir)
            {
                lightDir = normalize(lightDir);
                viewDir = normalize(viewDir);

                half3 diffuse = lightColor * _BaseColor.rgb * saturate(dot(lightDir, worldNormal));
                half3 halfDir = normalize(lightDir + viewDir);
                half3 specular = lightColor * _Specular.rgb * pow(saturate(dot(halfDir, worldNormal)), _Gloss);
                return (diffuse + specular) * lightAtten;
            }

            half3 LightingBased(Light light, half3 worldNormal, half3 viewDir)
            {
                return LightingBased(light.color, light.direction, light.shadowAttenuation * light.distanceAttenuation,
        worldNormal, viewDir);
            }

            float4 frag(v2f i) : SV_Target
            {
                half3 normalWS = normalize(i.normalWS);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.posWS);

                //平行光
                float4 shadowCoord = TransformWorldToShadowCoord(i.posWS);
                Light mainLight = GetMainLight(shadowCoord);
                half3 color = LightingBased(mainLight, normalWS, viewDir);

                //额外光（不支持阴影）
                #if _AdditionalLights
                uint addLightCount = GetAdditionalLightsCount();
                for (uint iu = 0; iu < addLightCount; iu++)
                {
                    Light addLight = GetAdditionalLight(iu, i.posWS);
                    color += LightingBased(addLight, normalWS, viewDir);
                }
                #endif

                half3 ambient = SampleSH(normalWS);
                return float4(ambient + color, 1);
            }
            ENDHLSL
        }
        // 产生阴影有问题，有时有，有时没有
        // FallBack "Universal Render Pipeline/Simple Lit"

        // 方式1：下面计算阴影的Pass可以直接通过使用URP内置的Pass计算
        // UsePass "Universal Render Pipeline/Simple Lit/ShadowCaster"

        // 方式2：自己计算阴影的Pass
        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            Cull Off
            ZWrite On
            ZTest LEqual
            ColorMask 0
            HLSLPROGRAM
            // 设置关键字
            #pragma shader_feature _ALPHATEST_ON
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            float3 _LightDirection;
            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            struct v2f
            {
                float4 pos: SV_POSITION;
            };
            // 获取裁剪空间下的阴影坐标
            float4 GetShadowPositionHClips(a2v v)
            {
                float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
                float3 normalWS = TransformObjectToWorldNormal(v.normal);
                // 获取阴影专用裁剪空间下的坐标
                float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

                // 判断是否是在DirectX平台翻转过坐标
                #if UNITY_REVERSED_Z
                positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #else
                    positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
                #endif

                return positionCS;
            }
            v2f vert(a2v v)
            {
                v2f o;
                o.pos = GetShadowPositionHClips(v);
                return o;
            }
            half4 frag(v2f i): SV_TARGET
            {
                return 0;
            }
            ENDHLSL

        }
    }
}