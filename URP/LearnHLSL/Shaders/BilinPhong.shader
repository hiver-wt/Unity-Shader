Shader "URP/BilinPhong"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _SpecularTint("SpecularTint",Range(10,300))=64
        _SpecularColor("SpecularColor",Color)=(1,1,1,1)
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
            Tags{"LightMode"="UniversalForward"}
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float3 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 viewDir_world : TEXCOORD2;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            float _SpecularTint;
            float4 _SpecularColor;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal_world=TransformObjectToWorldNormal(v.normal);
                o.viewDir_world=normalize(_WorldSpaceCameraPos.xyz-TransformObjectToWorld(v.vertex.xyz));
                return o;
            }

            real4 frag (v2f i) : SV_Target//新变量类型为real,定义在common.hlsl里面，根据不同平台编译float或者half
            {
                float3 normalWorld = normalize(i.normal_world);
                float3 viewDir = normalize(i.viewDir_world);
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;
                
                //环境光
                half4 ambient=half4(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w, 1)*tex;
                
                //主光源计算
                Light mylight=GetMainLight();
                real4 LightColor = float4(mylight.color,1);
                float3 LightDir = normalize(mylight.direction);
                float LightAten = saturate(dot(LightDir,normalWorld));

                //高光
                float3 half_vector = normalize(LightDir+viewDir);
                float spec_term = saturate(dot(normalWorld, half_vector));
                float4 specularColor = pow(spec_term,_SpecularTint)*_SpecularColor;

                //让主颜色受到光照影响（权重）(遮挡相关)
                real4 texColor = (dot(normalWorld,LightDir))*tex;
                texColor *= real4(mylight.color,1);

                return  specularColor+texColor+ambient;
                // float4 lambert = tex * LightAten * LightColor + ambient;
                // float4 halfLamber = tex * LightColor * (LightAten * 0.5 + 0.5); //半兰伯特
                //
                // return lambert;
            }
            ENDHLSL
        }
    }
}
