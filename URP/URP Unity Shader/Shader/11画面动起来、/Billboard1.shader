Shader "Unlit/Billboard1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //值1则为垂直于摄像机，值0则为仍然面朝摄像机但永远垂直于地面
        [Enum(Billboard, 1, VerticalBillboard, 0)]_BillboardType("BillboardType", int)=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipaline" "LightMode"="UniversalForward"}
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 world_pos : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
            TEXTURE2D(_MainTex); //CG中写成sampler2D _MainTex;
            SAMPLER(sampler_MainTex);
            float4 _MainTex_ST;
            float _BillboardType;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;

                // 构建旋转后的基向量在模型本地空间下的坐标
                // viewDir 相当于是定义的 z 基向量，把相机从世界空间转换到模型空间
                float3 viewDir = normalize(mul(GetWorldToObjectMatrix(), float4(_WorldSpaceCameraPos, 1)).xyz);
                viewDir.y *= _BillboardType;
                
                // 假设向上的向量为世界坐标系下的上向量
                float3 upDir = float3(0, 1, 0);
                float3 rightDir = normalize(cross(viewDir, upDir));
                upDir = cross(rightDir, viewDir);
                
                // 计算新的顶点位置
                float3 newVertex = rightDir * v.vertex.x + upDir * v.vertex.y + viewDir * v.vertex.z;

                o.pos = TransformObjectToHClip(newVertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.world_pos = TransformObjectToWorld(v.vertex.xyz);

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
