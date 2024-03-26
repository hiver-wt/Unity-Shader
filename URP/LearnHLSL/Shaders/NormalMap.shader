Shader "URP/NormalMap"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _NormalMap("NommalMap",2D) = "Bump"{}
        _NormalScale("NormalScale",Range(0,1))=1
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 normal_world : NORMAL;
                float4 tangent_world : TANGENT;
                float4 Btangent_world : TEXCOORD1;
                float3 viewDir_world : TEXCOORD2;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _NormalMap_ST;
            float _NormalScale;
            half4 _BaseColor;
            float _SpecularTint;
            float4 _SpecularColor;
            CBUFFER_END
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalMap);
                
                o.viewDir_world=normalize(_WorldSpaceCameraPos.xyz-TransformObjectToWorld(v.vertex));
                
                o.normal_world.xyz=TransformObjectToWorldNormal(v.normal);
                o.tangent_world.xyz=TransformObjectToWorldDir(v.tangent.xyz);
                //unity_WorldTransformParams.w是为判断是否使用了奇数相反的缩放
                o.Btangent_world.xyz = cross(o.normal_world.xyz,o.tangent_world.xyz)*v.tangent.w*unity_WorldTransformParams.w;

                float3 pos_world = TransformObjectToWorld(v.vertex);
                o.tangent_world.w=pos_world.x;
                o.Btangent_world.w=pos_world.y;
                o.normal_world.w=pos_world.z;
                
                return o;
            }

            real4 frag (v2f i) : SV_Target//新变量类型为real,定义在common.hlsl里面，根据不同平台编译float或者half
            {
                float3 viewDir = normalize(i.viewDir_world);
                
                float4 normalWorld = normalize(i.normal_world);
                float4 tangentWorld = normalize(i.tangent_world);
                float4 BtangentWorld = normalize(i.Btangent_world);
                float3 posWorld = float3(tangentWorld.w,BtangentWorld.w,normalWorld.w);
                float3x3 TBN = {tangentWorld.xyz,BtangentWorld.xyz,normalWorld.xyz};
                
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy)*_BaseColor;
                real4 normalTex = SAMPLE_TEXTURE2D(_NormalMap,sampler_NormalMap,i.uv.zw);
                float3 normal_tangent = UnpackNormalScale(normalTex,_NormalScale);
                normal_tangent.z=pow((1-pow(normal_tangent.x,2)-pow(normal_tangent.y,2)),0.5);//规范化法线
                float3 final_normal_world=mul(normal_tangent,TBN);//向量右乘一个矩阵，等于这个向量左乘这个矩阵的转置
                
                //环境光
                half4 ambient=half4(unity_SHAr.w,unity_SHAg.w,unity_SHAb.w, 1);
                
                //主光源计算
                Light mylight=GetMainLight();
                real4 LightColor = float4(mylight.color,1);
                float3 LightDir = normalize(mylight.direction);
                float LightAten = saturate(dot(LightDir,final_normal_world));

                //高光
                float3 half_vector = normalize(LightDir+viewDir);
                float spec_term = saturate(dot(final_normal_world, half_vector));
                float4 specularColor = pow(spec_term,_SpecularTint)*_SpecularColor;

                //让主颜色受到光照影响（权重）(遮挡相关)
                // real4 texColor = LightAten*0.5+0.5*tex;
                real4 texColor = (dot(final_normal_world,LightDir)*0.5+0.5)*tex;
                texColor *= real4(mylight.color,1)+specularColor+ambient;

                return  texColor;
            }
            ENDHLSL
        }
    }
}
