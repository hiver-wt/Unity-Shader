Shader "Unlit/LatLong"
{
    Properties
    {
        _PanoramaMap("Panorama Map", 2D) = "white"{}  // ȫ����ͼ����
        _Tint("Tint", Color) = (1, 1, 1, 1)         // ������ɫ����
        _Expose("Expose", Float) = 1.0               // ������ع��
        _Rotate("Rotate", Range(0, 360)) = 0         // ������ת���䷽��ĽǶ�
        _NormalMap("Normal Map", 2D) = "bump"{}      // ������ͼ
        _NormalIntensity("Normal Intensity", Float) = 1.0  // ������ͼǿ��
        _AOMap("AO Map", 2D) = "white"{}             // �������ڱ���ͼ
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }  // ��Ⱦ���ͱ��Ϊ��͸��
        LOD 100                         // Level of Detail

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // ���붥��ṹ
            struct appdata
            {
                float4 vertex : POSITION;     // ����λ��
                float2 texcoord : TEXCOORD0;  // ��������
                float3 normal : NORMAL;       // ��������
                float4 tangent : TANGENT;     // ��������
            };

            // �������ṹ
            struct v2f
            {
                float2 uv : TEXCOORD0;          // ���ݸ�ƬԪ��ɫ������������
                float4 pos : SV_POSITION;       // ���ݸ�����λ�õĲü��ռ�����
                float3 normal_world : TEXCOORD1;  // ��������ռ䷨��
                float3 pos_world : TEXCOORD2;     // ��������ռ�λ��
                float3 tangent_world : TEXCOORD3; // ��������ռ�����
                float3 binormal_world : TEXCOORD4;  // ��������ռ丱����
            };

            sampler2D _PanoramaMap;         // ȫ����ͼ
            float4 _PanoramaMap_HDR;       // ȫ����ͼ��HDR����
            float4 _Tint;                  // ������ɫ����
            float _Expose;                 // �����ع��

            sampler2D _NormalMap;          // ������ͼ
            float4 _NormalMap_ST;          // ������ͼ�����ź�ƫ��
            float _NormalIntensity;        // ������ͼǿ��

            sampler2D _AOMap;              // �������ڱ���ͼ
            float _Rotate;                 // ������ת���䷽��ĽǶ�

            // ��ת��ͼ����y����ת
            float3 RotateAround(float degree, float3 target)
            {
                float rad = degree * UNITY_PI / 180;
                float2x2 m_rotate = float2x2(cos(rad), -sin(rad),
                    sin(rad), cos(rad));
                float2 dir_rotate = mul(m_rotate, target.xz);
                target = float3(dir_rotate.x, target.y, dir_rotate.y);
                return target;
            }

            // ������ɫ��
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.tangent_world = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world)) * v.tangent.w;
                o.uv = v.texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
                return o;
            }

            // ƬԪ��ɫ��
            half4 frag(v2f i) : SV_Target
            {
                // ���㷨�߷���
                half3 normal_dir = normalize(i.normal_world);
                // ���뷨����ͼ
                half3 normaldata = UnpackNormal(tex2D(_NormalMap, i.uv));
                // Ӧ�÷���ǿ��
                normaldata.xy = normaldata.xy * _NormalIntensity;
                // �������ߺ͸����߷���
                half3 tangent_dir = normalize(i.tangent_world);
                half3 binormal_dir = normalize(i.binormal_world);
                // ���ݷ�����ͼ�������߷���
                normal_dir = normalize(tangent_dir * normaldata.x + binormal_dir * normaldata.y + normal_dir * normaldata.z);
                // ��ȡ�������ڱ�ֵ
                half ao = tex2D(_AOMap, i.uv).r;
                // �������߷���
                half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world);
                // ���㷴�䷽��
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                reflect_dir = RotateAround(_Rotate, reflect_dir);

                // ������������
                float3 normalizedCoords = normalize(reflect_dir);
                float latitude = acos(normalizedCoords.y);
                float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
                float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
                float2 uv_panorama =  float2(0.5, 1.0) - sphereCoords;

                // ��ȫ����ͼ�в�����ɫ
                half4 color_panorama = tex2D(_PanoramaMap, uv_panorama);
                half3 env_color = DecodeHDR(color_panorama, _PanoramaMap_HDR);

                // ����������ɫ
                half4 final_color = color_panorama * ao * _Tint * _Expose;
                return final_color;
            }
            ENDCG
        }
    }
}
