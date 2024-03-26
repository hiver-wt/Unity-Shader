Shader "URP/Glass"
{
    Properties
    {
        _MainTex("Main Tex",2D)="White"{}
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5 
        [HDR]_EmissionColor("Emission Color",Color)=(1,1,1,1)  
        _DepthOffset("Depth Offset",Float)=1
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalRenderPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/lighting.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
        half _FresnelScale;
        half _DepthOffset;
        half4 _EmissionColor;
        half4 _MainTex_ST;
        CBUFFER_END
        TEXTURE2D(_MainTex);
        SAMPLER(sampler_MainTex);
        float4 _CameraDepthTexture_TexelSize;
        SAMPLER(_CameraDepthTexture);
        
        struct a2v
        {
            float4 vertex:POSITION;
            float2 texcoord:TEXCOORD;
            float3 normal : NORMAL;
        };
        struct v2f
        {
            float4 pos:SV_POSITION;
            float2 uv:TEXCOORD;
            float4 sspos:TEXCOORD1;
            float3 posWS:TEXCOORD2;
            float3 normalWS:NORMAL;
        };
        ENDHLSL
        pass
        {
            Tags
            {
                "LightMode"="UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _NORMAL_STAGE_WS_N
            v2f vert(a2v i)
            {
                v2f o;
                o.pos = TransformObjectToHClip(i.vertex.xyz);
                o.uv = TRANSFORM_TEX(i.texcoord,_MainTex);
            
                o.posWS = TransformObjectToWorld(i.vertex);
                o.normalWS = TransformObjectToWorldNormal(i.normal);
                o.sspos.xy = o.pos.xy * 0.5 + 0.5 * float2(o.pos.w,o.pos.w);
                o.sspos.zw = o.pos.zw;
            
                return o;

            }

            half4 frag(v2f i):SV_TARGET
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.posWS);
                float3 normalWS = normalize(i.normalWS);

                //菲涅尔
                half fresnel = _FresnelScale+(1-_FresnelScale)*pow(1-dot(viewDir,normalWS),5);

                //开始计算屏幕uv
                i.sspos.xy /= i.sspos.w; //透除
                #ifdef UNITY_UV_STARTS_AT_TOP//判断当前的平台是openGL还是dx
                i.sspos.y = 1 - i.sspos.y;
                #endif//得到正常的屏幕uv，也可以通过i.positionCS.xy/_ScreenParams.xy来得到屏幕uv 
                
                //扫光
                float flow = saturate(pow(1-abs(frac(i.posWS.y*0.3-_Time.y*0.2)-0.5),10)*0.3);
                float4 flowColor = flow * _EmissionColor;

                 //计算缓冲区深度，模型深度
                float4 depthColor = tex2D(_CameraDepthTexture,i.sspos);
                float depthBuffer = Linear01Depth(depthColor,_ZBufferParams);//得到线性的深度缓冲
                //计算模型深度
                float depth = i.pos.z;
                depth = Linear01Depth(depth,_ZBufferParams);//得到模型的线性深度
                //计算接触光
                float edge = saturate(depth-depthBuffer+0.005)*100*_DepthOffset;

                //主纹理
                float2 uv =i.uv;
                uv.x += _Time.y * 0.2;//以每秒滚0.2圈的速度旋转
                float4 tex = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv);
                return real4(tex.xyz, fresnel+edge)+flowColor;
            }
            ENDHLSL
        }
    }
}