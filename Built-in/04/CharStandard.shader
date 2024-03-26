Shader "Unlit/CharStandard"
{
    Properties
    {
        [Header(Texture)]
        _MainTex ("Base Color", 2D) = "white" {}
        _CompMask("CompMask(RM)", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump"{}

        _RoughnessAdjust("Roughness Adjust",Range(-1, 1)) = 0.0
        _MetalAdjust("Metal Adjust",Range(-1, 1)) = 0.0
        _Gloss ("Gloss", Range(8, 256)) = 20 //高光控制

         [Header(IBL)]
        _EnvMap("Env Map", Cube) = "white"{}  
        //_Tint("Tint", Color) = (1, 1, 1, 1)     
        _Expose("Expose", Float) = 1.0        
        //_Rotate("Rotate", Range(0, 360)) = 0 

        [Header(SSS)]
        _SkinLUT("Skin LUT",2D) = "white"{}
        _Tiling("Tiling", Range(0,1)) = 0 

        //[Toggle(_SSS_DIFFUSECHAEK_ON)] _SSS_Diffuse_Check("SSS_Diffuse_Check",float) = 0.0
        //SH球谐光照
        [HideInInspector]custom_SHAr("Custom SHAr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAg("Custom SHAg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHAb("Custom SHAb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBr("Custom SHBr", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBg("Custom SHBg", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHBb("Custom SHBb", Vector) = (0, 0, 0, 0)
		[HideInInspector]custom_SHC("Custom SHC", Vector) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            //#pragma shader_feature _SSS_DIFFUSECHAEK_ON  //定义宏

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
				float4 vertex : POSITION; // 顶点位置
				float2 texcoord : TEXCOORD0; // 纹理坐标
				float3 normal : NORMAL; // 顶点法线
				float4 tangent : TANGENT; // 顶点切线
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal_world : TEXCOORD1;
				float3 pos_world : TEXCOORD2; // 世界空间中的位置
				float3 tangent_dir : TEXCOORD3; // 世界空间中的切线方向
				float3 binormal_dir : TEXCOORD4; // 世界空间中的副切线方向
                LIGHTING_COORDS(5, 6)// 阴影
            };

            sampler2D _MainTex;
            sampler2D _CompMask;
            sampler2D _NormalMap;
            float4 _LightColor0;

            //SSS
            sampler2D _SkinLUT;
            float _Tiling;

            float _RoughnessAdjust;
            float _MetalAdjust;
            float _Gloss;

            //SH
            half4 custom_SHAr;
			half4 custom_SHAg;
			half4 custom_SHAb;
			half4 custom_SHBr;
			half4 custom_SHBg;
			half4 custom_SHBb;
			half4 custom_SHC;

            //IBL
            samplerCUBE _EnvMap;
			float4 _EnvMap_HDR;
			//float4 _Tint;
			float _Expose;
            //float _Rotate;

            //球谐光照函数
            float3 custom_sh(float3 normal_dir)
            {
                float4 normalForSH = float4(normal_dir, 1.0);
                //SHEvalLinearL0L1
                half3 x;
                x.r = dot(custom_SHAr, normalForSH);
				x.g = dot(custom_SHAg, normalForSH);
				x.b = dot(custom_SHAb, normalForSH);

                //SHEvalLinearL2
				half3 x1, x2;
				// 4 of the quadratic (L2) polynomials
				half4 vB = normalForSH.xyzz * normalForSH.yzzx;
				x1.r = dot(custom_SHBr, vB);
				x1.g = dot(custom_SHBg, vB);
				x1.b = dot(custom_SHBb, vB);

                // Final (5th) quadratic (L2) polynomial
				half vC = normalForSH.x*normalForSH.x - normalForSH.y*normalForSH.y;
				x2 = custom_SHC.rgb * vC;

				float3 sh = max(float3(0.0, 0.0, 0.0), (x + x1 + x2));
				sh = pow(sh, 1.0 / 2.2);

                return sh;
            }

            // 定义ACES tonemapping函数
            inline float3 ACES_Tonemapping(float3 x)
            {
                float a = 2.51f;
                float b = 0.03f;
                float c = 2.43f;
                float d = 0.59f;
                float e = 0.14f;
                float3 encode_color = saturate((x * (a * x + b)) / (x * (c * x + d) + e));
                return encode_color;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.normal_world = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); 
				o.binormal_dir = normalize(cross(o.normal_world, o.tangent_dir)) * v.tangent.w;
                o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.texcoord;
                TRANSFER_VERTEX_TO_FRAGMENT(o);// 阴影
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {   
                //Texture
                half4 albedo_color_gamma = tex2D(_MainTex, i.uv);
                half4 albedo_color = pow(albedo_color_gamma, 2.2);
                half4 comp_mask = tex2D(_CompMask, i.uv);
                half3 normal_map = UnpackNormal(tex2D(_NormalMap, i.uv)); // 获取法线贴图并解包

                //区分金属和非金属
                half skin_area = 1.0 - comp_mask.b;
                half roughess = saturate(comp_mask.r + _RoughnessAdjust);
                half metal = saturate(comp_mask.g + _MetalAdjust);
                half3 base_color = albedo_color.rgb * (1.0 - metal); //固有色（非金属）
                half3 spec_color = lerp(0, albedo_color.rgb, metal);//高光

                //Dir
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world);
                half3 normal_dir = normalize(i.normal_world);
                half3 tangent_dir = normalize(i.tangent_dir); // 切线方向
				half3 binormal_dir = normalize(i.binormal_dir); // 副切线方向
                float3x3 TBN = float3x3(tangent_dir, binormal_dir,normal_dir);
                normal_dir = normalize(mul(normal_map, TBN));

                //直接光漫反射
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half atten = LIGHT_ATTENUATION(i); //衰减值（阴影）
                half diff_term = max(0.0, dot(normal_dir, light_dir));
                half half_lambert = (diff_term + 1.0) * 0.5;
                half3 common_diffuse = base_color * _LightColor0 * diff_term * half_lambert * atten;

                //SSS（皮肤质感模拟）有问题
                half2 uv_lut = half2(diff_term  * atten + _Tiling, 1);
                half3 lut_color_gamma = tex2D(_SkinLUT,uv_lut);
                half3 lut_color = pow(lut_color_gamma, 2.2);
                half3 sss_diffuse = lut_color * _LightColor0 * diff_term * base_color;
                half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin_area);
                //#ifdef _SSS_DIFFUSECHAEK_ON  //宏开关
                //half3 direct_diffuse = lerp(common_diffuse, sss_diffuse, skin_area);
                //#else
                //half3 direct_diffuse = common_diffuse;
                //#endif

                //直接光高光
                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = saturate(dot(normal_dir, half_dir));
                half smoothness = 1.0 - roughess;
                half shiniess = lerp(1, _Gloss, smoothness); //越光滑值越靠近gloss，越粗糙越靠近1
                half spec_term = pow(NdotH, shiniess * smoothness);
                //half spec_skin_color = lerp(spec_color, 0.01,skin_area);//皮肤高光
                half3 direct_specular = _LightColor0 * spec_color * spec_term * atten;

                //间接光漫反射（SH)
                float3 env_diffuse = custom_sh(normal_dir) * base_color * half_lambert;
                env_diffuse = lerp(env_diffuse * 0.7, env_diffuse * 2, skin_area);//皮肤

                //间接光高光（IBL）
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                roughess = roughess * (1.7 - 0.7 * roughess);
                float mip_level = roughess * 6.0;
                
                half4 color_envmap = texCUBElod(_EnvMap, float4(reflect_dir, mip_level));// 从立方体贴图中采样颜色
                half3 env_color = DecodeHDR(color_envmap, _EnvMap_HDR);// 解码HDR颜色
                half3 env_specular = env_color * _Expose * spec_color * half_lambert;

                half3 final_color = direct_diffuse + direct_specular + env_diffuse * 0.5 + env_specular;

                final_color = ACES_Tonemapping(final_color);
                final_color = pow(final_color, 1.0 / 2.2);//转换到gamma空间

                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
