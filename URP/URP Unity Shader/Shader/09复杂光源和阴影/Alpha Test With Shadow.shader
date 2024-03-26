Shader "URP/Alpha Test With Shadow"
{
    Properties
    {
        _BaseMap("Main Tex",2D)="white"{}
        _BaseColor("Diffuse Color", Color) = (1,1,1,1)
        _Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
        [Toggle(_AdditionalLights)] _AddLights("AddLights", Float) = 1.0
    }

    SubShader
    {
        Tags
        {
            "Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"
            "RenderPipeline"="UniversalPipeline"
        }

        Pass
        {
            Tags {"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _AdditionalLights

            // 具体解释看 multiLightShadow.shader
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                half _Cutoff;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            struct a2v
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                float4 texcoord : TEXCOORD;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD2;
                half3 worldPos : TEXCOORD0;
                half3 worldNormal : TEXCOORD1;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex).xyz;
                o.worldNormal = TransformObjectToWorldNormal(v.normal);
                o.uv = v.texcoord.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
                return o;
            }

            half3 LightingBased(half3 lightColor, half3 lightDir, half lightAtten, half3 worldNormal, half3 viewDir,
                                half3 albedo)
            {
                lightDir = normalize(lightDir);
                viewDir = normalize(viewDir);

                half3 diffuse = lightColor * albedo * saturate(dot(worldNormal, lightDir) * 0.5 + 0.5);
                return diffuse * lightAtten;
            }

            half3 LightingBased(Light light, half3 worldNormal, half3 viewDir, half3 albedo)
            {
                return LightingBased(light.color, light.direction, light.shadowAttenuation * light.distanceAttenuation,
                                                     worldNormal, viewDir, albedo);
            }

            half4 frag(v2f i) : SV_Target
            {
                half3 worldNormal = normalize(i.worldNormal);
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);

                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                clip(texColor.a - _Cutoff);
                half3 albedo = texColor.rgb * _BaseColor.rgb;

                float4 shadowCoord = TransformWorldToShadowCoord(worldNormal);
                Light mainLight = GetMainLight(shadowCoord);
                half3 color = LightingBased(mainLight, worldNormal, viewDir, albedo);

                #if _AdditionalLights
                uint addLightCount = GetAdditionalLightsCount();
                for (uint iu = 0; iu < addLightCount; iu++)
                {
                    Light addLight = GetAdditionalLight(iu, i.worldPos);
                    color += LightingBased(addLight, worldNormal, viewDir, albedo);
                }
                #endif

                half3 ambient = SampleSH(worldNormal);
                return half4(color + ambient, 1.0);
            }
            ENDHLSL
        }

        // 自己计算阴影的Pass
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

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
                half _Cutoff;
            CBUFFER_END

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            struct a2v
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 texcoord: TEXCOORD0;
            };

            struct v2f
            {
                float2 uv: TEXCOORD0;
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
                o.uv = TRANSFORM_TEX(v.texcoord, _BaseMap);
                o.pos = GetShadowPositionHClips(v);
                return o;
            }


            half4 frag(v2f i): SV_TARGET
            {
                // Alpha(SampleAlbedoAlpha(i.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
                clip(texColor.a - _Cutoff);
                return 0;
            }
            ENDHLSL

        }
    }
    // 不知道为什么不产生阴影
    // FallBack "Universal Render Pipeline/Simple Lit"
}