Shader "Unlit/TexShader"
{
    Properties
    {
        _Float("Float", Float) = 0.0
        _Cutout("Cotout",Range(-0.1,1.1)) = 0.0
        _Speed("Speed",Vector)=(1,1,1,1)
        //_Range("Range",Range(0.0,1.0)) = 0.0
        //_Vector("Vector",Vector)=(1,1,1,1)
        _Color("Color",Color)=(0.5,0.5,0.5,1)
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise Tex", 2D) = "white" {}
        [Enum(unityEngine.Rendering.CullMode)]_CullMode("CullMode" , float) = 0
    }
    SubShader
    {
        Pass
        {
            Cull [_CullMode] //�رձ����޳�   //Front ��Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; //��һ��uv���������
                //float3 normal : NORMAL;
                //float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;  //TEXCOORD0 ��0-15��һ�����ۣ����Էźܶ����ݣ���ͨ�ô���������ֵ����
                float4 vertex : SV_POSITION;
                float2 pos_uv : TEXCOORD1;
            };

            float4 _Color;
            float _Cutout;
            float4 _Speed;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                //float4 pos_world = mul(unity_ObjectToWorld,v.vertex);//ģ�Ϳռ�ת������ռ�
                //float4 pos_view = mul(UNITY_MATRIX_V,pos_world);//����ռ�ת������ռ�
                //float4 pos_clip = mul(UNITY_MATRIX_P,pos_view);//ת���ü��ռ�
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv *_MainTex_ST.xy + _MainTex_ST.zw; //uv����
                o.pos_uv = v.vertex *_MainTex_ST.xy + _MainTex_ST.zw;  //����ӳ�����Դ��һ����uv���꣬�����������趨��ֵ
                return o;
            }

            fixed4 frag (v2f i) : SV_Target  //SV_Target��ʾ��fragment shader�����Ŀ�ĵ�
            {
                //float4 col = tex2D(_MainTex, i.uv);
                half gradient = tex2D(_MainTex, i.uv + _Time.y * _Speed.xy).r;
                half noise = tex2D(_NoiseTex, i.uv + _Time.y * _Speed.zw).r;
                clip(gradient - noise - _Cutout);  //�����������Ķ���С��0�ͻᱻ����
                return _Color;  //����float4(gradient,gradient,gradient,gradients)
            }
            ENDCG
        }
    }
}
