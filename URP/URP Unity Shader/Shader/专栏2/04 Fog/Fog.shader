Shader "URP/Fog"
{
    Properties
    {
        _MainTex("Texture",2D) = "while"{}
        _Blend("Blend",Range(0,1)) = 1.0
        _Noise_R("Noise_R Tiling",Float) = 1.0
        _Noise_G("Noise_G Tiling",Float) = 1.0
        _UVSpeed("UV Speed",Vector)=(1,1,1,1)
        
        _SoftFade("SoftFade",Float) = 1.0
        //_FogRamp("Fog Ramp",2D)="white"{}
        _FogColor("Fog Color",Color)=(1.0,1,1,1)
        _Soft("Soft",Range(0,3)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        ENDHLSL
        Pass
        {
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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
                float3 posWS : TEXCOOORD1;
                float4 scrPos : TEXCOORD2;
                float3 normalWS : NORMAL;
            };

            CBUFFER_START(UnityPerMaterial)
            float _SoftFade,_Soft,_Blend,_Noise_R,_Noise_G;
            float4 _MainTex_ST;
            float4 _UVSpeed;
            float4 _FogColor;
            half4 _FogRamp_ST;
            CBUFFER_END
            
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_FogRamp);
            SAMPLER(sampler_FogRamp);
            
            //UV移动函数
            inline half2 UVSpeed(half speedU,half speedV)
            {
                half2 uvSpeed = _Time.y * (half2(speedU,speedV));
                return uvSpeed;
			}
            
            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs PositionInputs = GetVertexPositionInputs(v.vertex.xyz);
                o.pos = PositionInputs.positionCS;
                o.posWS = PositionInputs.positionWS;
                
                o.scrPos = ComputeScreenPos(o.pos);
                
                VertexNormalInputs NormalInputs = GetVertexNormalInputs(v.normal.xyz);
                o.normalWS.xyz = NormalInputs.normalWS;
                
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv1 = i.uv*_Noise_R+UVSpeed(_UVSpeed.x,_UVSpeed.y);
                float2 uv2 = i.uv*_Noise_G+UVSpeed(_UVSpeed.z,_UVSpeed.w);
                half Tex1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv1).r;
                half Tex2 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv2).g;
                half mask = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,i.uv).a;
                half texBlend = clamp(0,1,lerp(Tex1,(Tex1*Tex2),_Blend));
                
                float2 PosNDC = i.scrPos.xy/i.scrPos.w;
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture,sampler_CameraDepthTexture,PosNDC).r;
                float linearDepth = LinearEyeDepth(depth,_ZBufferParams);

                float fade = saturate((linearDepth - i.scrPos.w - _Soft) / _SoftFade);
                float4 col=(fade+texBlend)*mask;
                col.rgb *= _FogColor.rgb;
                col.a *= clamp(0,1,fade)*_FogColor.a;
                return col  ;
            }
            ENDHLSL
        }
    }
}
