Shader "Unlit/multiLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}    // 主纹理属性
        _BaseColor("BaseColor",Color)=(1,1,1,1)  // 基础颜色属性
        //  [KeywordEnum(ON,OFF)]_Add_Light("AddLight",float)=1  // 额外光源开关
        [Toggle(_Add_Light_ON)]_Add_Light("AddLight",float)=1  // 额外光源开关
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalRenderPipeline" "LightMode"="UniversalForward"}
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        ENDHLSL
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // #pragma shader_feature _Add_Light_ON _Add_Light_OFF  // 光源开关
            #pragma shader_feature _Add_Light_ON  // 光源开关

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : NORMAL;
                float3 view_dir : TEXCOORD1;
                float3 pos_world : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;       // 纹理缩放和偏移变量
            float4 _BaseColor;        // 基础颜色变量
            CBUFFER_END

            TEXTURE2D(_MainTex);      // 主纹理变量
            SAMPLER(sampler_MainTex); // 主纹理采样器变量

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_world = normalize(TransformObjectToWorldNormal(v.normal.xyz));
                o.view_dir = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(v.vertex.xyz));
                o.pos_world = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _BaseColor;

                // 主光源信息
                Light mylight = GetMainLight();
                float3 worldLight = normalize(mylight.direction);
                float3 worldNormal = normalize(i.normal_world);
                float3 viewDir = normalize(i.view_dir);
                
                float3 worldHalf = normalize(viewDir + worldLight);
                float3 NdotH = dot(worldHalf,worldNormal);
                float3 worldPos = normalize(i.pos_world);

                // 主光源颜色
                float4 maincolor = (dot(worldLight, worldNormal)) * col * float4(mylight.color, 1);

                // 额外光源颜色
                float4 addcolor = float4(0, 0, 0, 1);
                #if defined _Add_Light_ON
                int addLightsCount = GetAdditionalLightsCount();
                for(int index = 0; index < addLightsCount; index++)
                {
                    Light addLight = GetAdditionalLight(index, worldPos);
                    float3 world_addLightDir = normalize(addLight.direction);
                    addcolor += (dot(worldNormal, world_addLightDir) * 0.5 + 0.5) * float4(addLight.color, 1)
                                * col * addLight.distanceAttenuation * addLight.shadowAttenuation;
                }
                #else 
                addcolor = float4(0,0,0,1);
                #endif
                return maincolor + addcolor;  // 返回最终颜色
            }
            ENDHLSL
        }
    }
}
