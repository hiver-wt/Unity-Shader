Shader "URP/NormalMapChange"
{
    Properties
    {
        _DiffuseColor("DiffuseColor",Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _gloss("gloss",Float) = 0.2
        [Normal]_NormalTex ("NormalTex", 2D) = "bump"{}
        _NormalScale("NormalScale",Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline"}

        Pass
        {
            Tags{ "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"        //增加光照函数库

            struct appdata
            {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;                                             //float4类型的UV数据，
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD1;                                       //输出世界空间下法线信息
                float3 tangentWS :TANGENT;                                         //注意 是 float4 类型，W分量储存其他信息
                float3 BtangentWS : TEXCOORD2;                                     //注意 是 float4 类型，W分量储存其他信息
                float3 viewDirWS: TEXCOORD3;                                       //输出视角方向
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST,_NormalTex_ST;
                float _gloss,_NormalScale;
                float4 _DiffuseColor;
            CBUFFER_END

            TEXTURE2D (_MainTex);
            TEXTURE2D (_NormalTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_NormalTex);

            v2f vert (appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);      //xy分量，储存颜色贴图uv
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalTex);    //zw分量，储存法线贴图uv
                o.normalWS.xyz = TransformObjectToWorldNormal(v.normalOS.xyz,true);
                o.tangentWS.xyz = TransformObjectToWorldDir(v.tangentOS);
                
                /* unity_WorldTransformParams.w,
                定义于unityShaderVariables.cginc中.模型的Scale值是三维向量，即xyz，
                当这三个值中有奇数个值为负时（1个或者3个值全为负时），unity_WorldTransformParams.w = -1，否则为1 */
                /*v.tangentOS.w
                 值为-1或者1,由DCC软件中的切线自动生成,和顶点的环绕顺序有关。*/
                o.BtangentWS.xyz = cross(o.normalWS.xyz,o.tangentWS.xyz) * v.tangentOS.w * unity_WorldTransformParams.w;
                
                /*计算出世界空间下的顶点坐标。储存到法线，切线，副切线的W通道中 
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);            //模型的顶点位置 储存到 W分量里
                o.tangentWS.w = positionWS.x;
                o.BtangentWS.w = positionWS.y;
                o.normalWS.w =  positionWS.z;*/
                
                o.viewDirWS = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.positionOS.xyz));
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //新法线信息 = 模型顶点法线 + 法线贴图

                half4 DiffuseTex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv.xy);     //贴图采样变成3个变量
                half4 NormalTex = SAMPLE_TEXTURE2D(_NormalTex,sampler_NormalTex,i.uv.zw);   //法线贴图
                
                Light mylight = GetMainLight();                                //获取场景主光源
                real4 LightColor = real4(mylight.color,1);                     //获取主光源的颜色

                //float3 WSpos = float3(i.tangentWS.w,i.BtangentWS.w,i.normalWS.w);      //顶点位置

                float3x3 TBN = {i.tangentWS.xyz,i.BtangentWS.xyz,i.normalWS.xyz};          //世界空间法线方向
                float3 normalTS = UnpackNormalScale(NormalTex,_NormalScale);               //控制法线强度
                normalTS.z = pow((1 - pow(normalTS.x,2) - pow(normalTS.y,2)),0.5);         //规范化法线,使向量的模长恒为1

                float3 norWS = mul(normalTS,TBN);                                          //顶点法线，和法线贴图融合 == 世界空间的法线信息

                //real3 NormalDir = normalize(i.normalWS);
                real3 ViewDir = normalize(i.viewDirWS);                            //在这里计算  视角方向
                real3 LightDir = normalize(mylight.direction);                     //获取光照方向

                real3 halfDir = normalize(ViewDir + LightDir);                      //半角向量

                //漫反射
                float LdotN = dot(LightDir,norWS) * 0.5 + 0.5;                      //LdotN    这里使用新的法线信息。

                half4 specularValue = pow(max(0,dot(norWS,halfDir)),_gloss) * LightColor;   //计算高光
                half4 diffusecolor = DiffuseTex * LdotN * LightColor * _DiffuseColor;
                
                half4 col =  specularValue + diffusecolor;

                return col;
            }
            ENDHLSL
        }
    }
}
