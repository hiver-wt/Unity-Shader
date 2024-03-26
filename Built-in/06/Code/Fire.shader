Shader "Unlit/Fire"
{
    Properties
    {
        _BaseColor("Base Color",color) = (1,1,1,1)
        _BaseColorEmiss("Base Color Emiss",float) = 1

        _GradientTex ("Gradient Texture", 2D) = "white" {}
        _EndColorControl("End Color Control",range(0,1)) = 0
        _GradientEndControl("Graditent End Control",float) = 0

        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseSpeed("Noise Speed",vector) = (0,0,0,0)
        _NoiseIntensity("Noise Intensity",float) = 0

        _FireShape ("Fire Shape", 2D) = "white" {}
        _FireSoftness("Fire Softness",Range(0,0.5)) = 0
        _Test("Tset",Range(0,1))=0
    }
    SubShader
    {
        Tags { "Render Type"="Transparent" "Render Queue" = "Transparent" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

        float4 _BaseColor;
        float _BaseColorEmiss;

        sampler2D _GradientTex;
        float4 _GradientTex_ST;
        float _EndColorControl;
        float _GradientEndControl;

        sampler2D _NoiseTex;
        float4 _NoiseTex_ST;
        float4 _NoiseSpeed;
        float _NoiseIntensity;

        sampler2D _FireShape;
        float4 __FireShape_ST;
        float _FireSoftness;

        float _Test;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                //gradient
                half4 gradient = tex2D(_GradientTex,i.uv);
                half4 gradient_end_control = (1 - gradient) * _GradientEndControl;

                //noise
                half4 noise = tex2D(_NoiseTex,i.uv + _Time.y * _NoiseSpeed.xy);
                
                //fireShape
                half noise_gradient = (noise * 2-1) * _NoiseIntensity * gradient.r;
                half2 uv = half2(noise_gradient + i.uv.x, i.uv.y);
                half4 fireShape = tex2D(_FireShape,uv);
                fireShape *= fireShape;

                //basecolor
                half4 basecolor = _BaseColor * _BaseColorEmiss;
                basecolor.g += _EndColorControl * _GradientEndControl;
                //alpha
                half ng_alpha = smoothstep(saturate(noise.r - _FireSoftness), noise.r, gradient.r);
                half final_alpha = ng_alpha * fireShape.r;
                clip(final_alpha-_Test);
                //return half4(basecolor.rgb,final_alpha);
                return basecolor;
            }
            ENDCG
        }
    }
}
