Shader "Unlit/04_Blending"
{
    Properties
    {
        _Emiss("Emiss", Float) = 1.0
        //_Range("Range",Range(0.0,1.0)) = 0.0
        //_Vector("Vector",Vector)=(1,1,1,1)
        _Color("Color",Color)=(1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        [Enum(unityEngine.Rendering.CullMode)]_CullMode("_CullMode" , float) = 0
    }
    SubShader
    {
        Tags{"Queue" = "Transparent"} //�ı���Ⱦ����
        Pass
        {
            //ZWrite off //�ر����д��
            //Blend SrcAlpha OneMinusSrcAlpha //��͸��
            Blend SrcAlpha One
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

            float _Emiss;
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                half3 col =  _Color.xyz * _Emiss;
                half alpha  = saturate(tex2D(_MainTex, i.uv).r * _Color.a * _Emiss);  //saturate��������0��1֮��
                return float4(col,alpha);
            }
            ENDCG
        }
    }
}
