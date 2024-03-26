Shader "Unlit/05_Rim"
{
    Properties
    {
        _Emiss("Emiss", Float) = 1.0    // ����ǿ������
        //_Range("Range", Range(0.0, 1.0)) = 0.0  // ָ����Χ���ԣ����ǵ�ǰ��ע�͵���
        //_Vector("Vector", Vector) = (1, 1, 1, 1)  // �������ԣ����ǵ�ǰ��ע�͵���
        _RimPower("RimPower", Float) = 1.0  // ��Եǿ������
        _Color("Color", Color) = (1, 1, 1, 1)  // ����ɫ����
        _MainTex ("Texture", 2D) = "white" {}  // ����������
        [Enum(unityEngine.Rendering.CullMode)]_CullMode("_CullMode", float) = 0  // �޳�ģʽ����
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }  // ������Ⱦ����Ϊ͸��
        // �������ڲ��İ�͸��Ч����Ԥ��д��ȵ�Ч��
        Pass {
            Cull Off  // �رձ����޳�
            ZWrite On  // �������д��
            ColorMask 0  // �ر���ɫд��
            CGPROGRAM
            float4 _Color;
            #pragma vertex vert
            #pragma fragment frag

            float4 vert(float4 vertexPos : POSITION) : SV_POSITION
            {
                return UnityObjectToClipPos(vertexPos);
            }

            float4 frag(void) : COLOR
            {
                return _Color;
            }
            ENDCG
        }
        Pass
        {
            ZWrite off  // �ر����д��
            //Blend SrcAlpha OneMinusSrcAlpha  // ��͸�����ģʽ����ע�ͣ�
            Blend SrcAlpha One  // ���û�ϣ�͸������Դ��ɫ���ӵ�Ŀ��
            Cull [_CullMode]  // ����_CullMode���Ծ����޳���һ��
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;  // ��һ����������
                float3 normal : NORMAL;
                //float4 color : COLOR;  
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;  // ���ݵ�Ƭ����ɫ������������
                float4 vertex : SV_POSITION;  // ���ݵ�Ƭ����ɫ���Ķ���λ��
                float3 normal_world : TEXCOORD1;  // ���ݵ�Ƭ����ɫ�������編��
                float3 view_world : TEXCOORD2;  // ���ݵ�Ƭ����ɫ���������������߷���
            };

            float _Emiss;  // ����ǿ��
            float _RimPower;  // ��Եǿ��
            float4 _Color;  // ����ɫ
            sampler2D _MainTex;  // ������
            float4 _MainTex_ST;  // �������ź�ƽ��

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);  // ת�����ߵ�����ռ�?
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);  // �������߷���
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;  // ������������
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world  = normalize(i.view_world);
                float NdotV = saturate(dot(normal_world, view_world));  // ���㷨�������߷���ĵ��
                float frensel = pow(1.0 - NdotV, _RimPower);  // ���������ЧӦ
                float3 col = _Color.xyz * _Emiss;  // ��������ɫ�뷢��ǿ�ȵĳ˻�
                float rim = saturate(frensel * _Emiss);  // �����ԵЧӦ
                return float4(col, rim);
            }
            ENDCG
        }
    }
}
