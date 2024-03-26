Shader "URP/Billboard"
{
    Properties
    {
        _MainTex("MainTex",2D)="white"{}
        _BaseColor("BaseColor",Color)=(1,1,1,1)
        _Sheet("Sheet",Vector)=(1,1,1,1)
        _FrameRate("FrameRate",float)=25
        [KeywordEnum(LOCK_Z,FREE_Z)]_Z_STAGE("Z_Stage",float)=1//定义一个是否锁定Z轴
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent" 
            "RenderPipeline"="UniversalPipaline" 
        }
        Pass
        {
            Tags{"LightMode"="UniversalForward"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _Z_STAGE_LOCK_Z
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
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
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float4 _Sheet;
            float _FrameRate;
            float4 _BaseColor;
            CBUFFER_END
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            v2f vert (appdata v)
            {
                v2f o;
                //先构建一个新的Z轴朝向相机的坐标系，这时我们需要在模型空间下计算新的坐标系的3个坐标基
                //由于三个坐标基两两垂直，故只需要计算2个即可叉乘得到第三个坐标基
                //先计算新坐标系的Z轴
                float3 center = TransformObjectToWorld(float3(0,0,0));
                float3 newZ = TransformWorldToObjectDir(center-_WorldSpaceCameraPos);
                #ifdef _Z_STAGE_LOCK_Z
                newZ.y=0;
                #endif
                newZ=normalize(newZ);
                //根据Z的位置判断X方向
                float3 newX = abs(newZ.y)<0.99?cross(float3(0,1,0),newZ):cross(newZ,float3(0,0,1));
                newX = normalize(newX);
                float3 newY = normalize(cross(newZ,newX));
                
                float3x3 Matrix={newX,newY,newZ};//这里应该取矩阵的逆 但是hlsl没有取逆矩阵的函数
                float3 newPos=mul(v.vertex.xyz,Matrix);//故在mul函数里进行右乘 等同于左乘矩阵的逆（正交阵的转置等于逆）
                
                o.pos = TransformObjectToHClip(newPos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float2 uv; //小方块的uv
                uv.x = i.uv.x / _Sheet.x + frac(floor(_Time.y * _FrameRate) / _Sheet.x);
                uv.y = i.uv.y / _Sheet.y + 1 - frac(floor(_Time.y * _FrameRate / _Sheet.x) / _Sheet.y);

                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                return col;
            }
            ENDHLSL
        }
    }
}
