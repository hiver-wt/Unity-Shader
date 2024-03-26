Shader "Unlit/SkyBox"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Background" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_HDR;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                //��ֹ��պб��ü������ֳ�DX��OpenGL
                #if UNITY_REVERSED_Z
                    o.vertex.z = o.vertex.w*0.00001f;
                #else
                    o.vertex.z = o.vertex.w*0.999999f;
                #endif
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                half3 col_hdr = DecodeHDR(col,_MainTex_HDR);
                return half4(col_hdr,1.0);
            }
            ENDCG
        }
    }
}
