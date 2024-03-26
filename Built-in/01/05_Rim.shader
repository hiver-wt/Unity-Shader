Shader "Unlit/05_Rim"
{
    Properties
    {
        _Emiss("Emiss", Float) = 1.0    // 发光强度属性
        //_Range("Range", Range(0.0, 1.0)) = 0.0  // 指定范围属性，但是当前被注释掉了
        //_Vector("Vector", Vector) = (1, 1, 1, 1)  // 向量属性，但是当前被注释掉了
        _RimPower("RimPower", Float) = 1.0  // 边缘强度属性
        _Color("Color", Color) = (1, 1, 1, 1)  // 主颜色属性
        _MainTex ("Texture", 2D) = "white" {}  // 主纹理属性
        [Enum(unityEngine.Rendering.CullMode)]_CullMode("_CullMode", float) = 0  // 剔除模式属性
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }  // 设置渲染队列为透明
        // 看不到内部的半透明效果，预先写深度的效果
        Pass {
            Cull Off  // 关闭背面剔除
            ZWrite On  // 开启深度写入
            ColorMask 0  // 关闭颜色写入
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
            ZWrite off  // 关闭深度写入
            //Blend SrcAlpha OneMinusSrcAlpha  // 半透明混合模式（已注释）
            Blend SrcAlpha One  // 启用混合，透明部分源颜色叠加到目标
            Cull [_CullMode]  // 根据_CullMode属性决定剔除哪一面
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;  // 第一套纹理坐标
                float3 normal : NORMAL;
                //float4 color : COLOR;  
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;  // 传递到片段着色器的纹理坐标
                float4 vertex : SV_POSITION;  // 传递到片段着色器的顶点位置
                float3 normal_world : TEXCOORD1;  // 传递到片段着色器的世界法线
                float3 view_world : TEXCOORD2;  // 传递到片段着色器的世界坐标视线方向
            };

            float _Emiss;  // 发光强度
            float _RimPower;  // 边缘强度
            float4 _Color;  // 主颜色
            sampler2D _MainTex;  // 主纹理
            float4 _MainTex_ST;  // 纹理缩放和平移

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);  // 转化法线到世界空间?
                float3 pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view_world = normalize(_WorldSpaceCameraPos.xyz - pos_world);  // 计算视线方向
                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;  // 计算纹理坐标
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float3 normal_world = normalize(i.normal_world);
                float3 view_world  = normalize(i.view_world);
                float NdotV = saturate(dot(normal_world, view_world));  // 计算法线与视线方向的点积
                float frensel = pow(1.0 - NdotV, _RimPower);  // 计算菲涅耳效应
                float3 col = _Color.xyz * _Emiss;  // 计算主颜色与发光强度的乘积
                float rim = saturate(frensel * _Emiss);  // 计算边缘效应
                return float4(col, rim);
            }
            ENDCG
        }
    }
}
