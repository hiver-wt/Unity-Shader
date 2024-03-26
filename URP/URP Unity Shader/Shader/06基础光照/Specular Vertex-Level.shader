Shader "URP/Specular Vertex-Level"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" {}
        _Specular("BaseColor",Color)=(1,1,1,1)
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Gloss("Gloss",Range(8.0,256)) = 20
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 color : TEXCOORD1;
            };
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _Specular;
            half4 _BaseColor;
            float _Gloss;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = TransformObjectToHClip(v.vertex);
                half3 posWS = TransformObjectToWorld(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                //环境光
                half3 ambient = half3(unity_SHAr.w, unity_SHAg.w, unity_SHAb.w);
                
                //获得光源
                Light mylight = GetMainLight();
                float3 LightDirWS = normalize(mylight.direction);
                //法线
                half3 normalWS = TransformObjectToWorldNormal(v.normal);
                
                //漫反射
                float3 diffuse = mylight.color*_BaseColor*saturate(dot(normalWS,LightDirWS));
                
                //高光
                // reflect函数：输入入射方向（向内）和法线方向（向外），返回镜面反射方向（向外）
				// 对于一个Shading Point，所有方向向量都向外
				// 所以这里要取入射方向的反方向
                half3 reflectDir = normalize(reflect(-LightDirWS,normalWS));
                half3 viewDir = normalize(_WorldSpaceCameraPos.xyz-posWS);
                float3 specular = mylight.color*_Specular.rgb*pow(saturate(dot(reflectDir,viewDir)), _Gloss);
                o.color=ambient+diffuse+specular;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                //float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv)*_BaseColor;
                return float4(i.color,1.0);
            }
            ENDHLSL
        }
    }
}
