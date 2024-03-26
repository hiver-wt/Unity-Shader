Shader "Unlit/multiLight_PBR"
{
    Properties
    {
        _BaseColor("BaseColor",Color)=(1,1,1,1)  // 基础颜色属性
        [Toggle(_Add_Light_ON)]_Add_Light("AddLight",float)=1  // 额外光源开关
        _SpecularTint("SpecularTint",Range(1,256))=64
        _Smoothness("Smoothness",Range(0,1))=0
        _Metallic("Metallic",Range(0,1))=0
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
            #pragma shader_feature _Add_Light_ON  // 光源开关
            // #pragma shader_feature _SPECULAR_SETUP_ON

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
            float4 _BaseColor;        // 基础颜色变量
            CBUFFER_END
            
            float _SpecularTint;
            float _Smoothness;  
            float _Metallic;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.texcoord;
                o.normal_world = normalize(TransformObjectToWorldNormal(v.normal.xyz));
                o.view_dir = normalize(_WorldSpaceCameraPos - TransformObjectToWorld(v.vertex.xyz));
                o.pos_world = TransformObjectToWorld(v.vertex.xyz);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = _BaseColor;
                // 获取主光源信息
                Light mylight = GetMainLight();
                float3 worldLightDir = normalize(mylight.direction);
                
                float3 worldNormal = normalize(i.normal_world);
                float3 viewDir = normalize(i.view_dir);
                float3 worldPos = normalize(i.pos_world);

                // 环境光
                half4 ambient = half4(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w, 1);

                // 主光源高光
                float worldNdotH = dot(worldNormal,(normalize(viewDir+worldLightDir)));
                float3 worldSpecular = pow(max(0.0,worldNdotH),_SpecularTint);

                // 计算主光源影响的颜色
                float4 maincolor = saturate(dot(worldLightDir, worldNormal)) * col * float4(mylight.color, 1);
                maincolor = float4((maincolor.xyz + worldSpecular + ambient.xyz),1);

                // 计算额外光源影响的颜色
                float4 addcolor = float4(0, 0, 0, 1);
                // PBR light
                #if defined _Add_Light_ON
                int additionalLightsCount = GetAdditionalLightsCount();// 获取场景中额外光源的数量
                for (int index = 0; index < additionalLightsCount; index++)
                {
                    Light additionalLight = GetAdditionalLight(index, worldPos);// 获取当前索引对应的额外光源信息
                    
                    // 高光
                    float3 worldHalf = normalize(viewDir + normalize(_AdditionalLightsSpotDir[index]));
                    float NdotH = dot(worldNormal, worldHalf);
                    float3 specular = pow(max(0,NdotH),_SpecularTint);
                    
                    // 定义 BRDF 数据结构，用于描述光的反射分布
                    BRDFData brdfData;
                    // 初始化 BRDF 数据，传递材质属性如反照率、金属度、镜面反射色调、光滑度等
                    InitializeBRDFData(_BaseColor.rgb, _Metallic, specular, _Smoothness, _BaseColor.a, brdfData);

                    // 计算基于物理的光照，考虑 BRDF 数据、额外光源信息、片元法线和视图方向
                    addcolor += float4(LightingPhysicallyBased(brdfData, additionalLight, worldNormal, viewDir), 1);
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
