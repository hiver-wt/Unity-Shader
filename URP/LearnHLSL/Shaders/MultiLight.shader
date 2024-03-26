Shader "URP/MultiLight"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        [Toggle(_Add_Light_ON)]_Add_Light("AddLight",float)=1  // 额外光源开关
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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _Add_Light_ON  // 光源开关
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normalOS : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normalWS : NORMAL;
                float3 posWS : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normalWS=TransformObjectToWorldNormal(v.normalOS);
                o.posWS = TransformObjectToWorld(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;

                float3 posWS = normalize(i.posWS);
                float3 normalWS = normalize(i.normalWS);

                //主光源
                Light mainLight = GetMainLight();
                float3 light_dir = normalize(mainLight.direction);
                float4 maincolor = (dot(light_dir,normalWS)*0.5+0.5) * tex * float4(mainLight.color,1);

                //额外点光源
                float4 addcolor = float4(0, 0, 0, 1);
                #if defined _Add_Light_ON
                int addLightCount = GetAdditionalLightsCount();
                for (int index = 0;index < addLightCount;index++)
                {
                    Light addLight = GetAdditionalLight(index, posWS);
                    float3 addLightDirWS = normalize(addLight.direction);
                    //float LightAten = saturate(dot(LightDir,normalWS));
                    //halfLambert LightAten = LightAten*0.5+0.5;
                    addcolor += (dot(normalWS,addLightDirWS)*0.5+0.5)* float4(addLight.color, 1)
                                * tex * addLight.distanceAttenuation * addLight.shadowAttenuation;
                }
                #else
                addcolor = float4(0, 0, 0, 1);
                #endif
                return addcolor+maincolor;
            }
            ENDHLSL
        }
    }
}
