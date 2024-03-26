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
        Tags{"Queue" = "Transparent"} //改变渲染队列
        Pass
        {
            //ZWrite off //关闭深度写入
            //Blend SrcAlpha OneMinusSrcAlpha //半透明
            Blend SrcAlpha One
            Cull [_CullMode] //关闭背面剔除   //Front ，Back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; //第一套uv，最多四套
                //float3 normal : NORMAL;
                //float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;  //TEXCOORD0 （0-15，一个凹槽，可以放很多数据）是通用储存器（插值器）
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
                //float4 pos_world = mul(unity_ObjectToWorld,v.vertex);//模型空间转到世界空间
                //float4 pos_view = mul(UNITY_MATRIX_V,pos_world);//世界空间转到相机空间
                //float4 pos_clip = mul(UNITY_MATRIX_P,pos_view);//转到裁剪空间
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv *_MainTex_ST.xy + _MainTex_ST.zw; //uv计算
                o.pos_uv = v.vertex *_MainTex_ST.xy + _MainTex_ST.zw;  //纹理映射的来源不一定是uv坐标，可以是任意设定的值
                return o;
            }

            fixed4 frag (v2f i) : SV_Target  //SV_Target表示：fragment shader输出的目的地
            {
                half3 col =  _Color.xyz * _Emiss;
                half alpha  = saturate(tex2D(_MainTex, i.uv).r * _Color.a * _Emiss);  //saturate：限制在0到1之间
                return float4(col,alpha);
            }
            ENDCG
        }
    }
}
