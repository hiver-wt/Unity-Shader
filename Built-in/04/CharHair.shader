Shader "Unlit/CharStandard"
{
    Properties
    {
        [Header(Texture)]
        _MainTex ("Base Color", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump"{}

        _BaseColor("Base Color",COLOR) = (1,1,1,1)
        _RoughnessAdjust("Roughness Adjust",Range(-1, 1)) = 0.0

        [Header(Specular)]
        _AnisoMap("Aniso Map", 2D) = "gray"{}
        _SpecColor1("Speclar Color 1", COLOR) = (1,1,1,1)
        _SpecShininess1("Speclar Shininess 1", Range(0,1)) = 0.1
        _SpecNoise1("Speclar Noise 1",float) = 1
        _SpecOffset1("Speclar Offset 1",float) = 0

        _SpecColor2("Speclar Color 2", COLOR) = (1,1,1,1)
        _SpecShininess2("Speclar Shininess 2", Range(0,1)) = 0.1
        _SpecNoise2("Speclar Noise 2",float) = 1
        _SpecOffset2("Speclar Offset 2",float) = 0

         [Header(IBL)]
        _EnvMap("Env Map", Cube) = "white"{}  
        _Expose("Expose", Float) = 1.0        
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
            sampler2D _NormalMap;
            float4 _LightColor0;

            float4 _BaseColor;
            float _RoughnessAdjust;
            
            //Aniso Spec
            sampler2D  _AnisoMap;
            float4 _AnisoMap_ST;
            float4 _SpecColor1;
            float _SpecShininess1;
            float _SpecNoise1;
            float _SpecOffset1;
            float4 _SpecColor2;
            float _SpecShininess2;
            float _SpecNoise2;
            float _SpecOffset2;

            //IBL
            samplerCUBE _EnvMap;
			float4 _EnvMap_HDR;
			float _Expose;

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
                half4 albedo_color = pow(albedo_color_gamma, 2.2) * _BaseColor; 
                half3 base_color = albedo_color.rgb;
                half3 normal_map = UnpackNormal(tex2D(_NormalMap, i.uv)); // 获取法线贴图并解包

                //区分金属和非金属
                half roughess = saturate(_RoughnessAdjust);

                //Dir
                half3 view_dir = normalize(_WorldSpaceCameraPos - i.pos_world);
                half3 normal_dir = normalize(i.normal_world);
                half3 tangent_dir = normalize(i.tangent_dir); // 切线方向
				half3 binormal_dir = normalize(i.binormal_dir); // 副切线方向
                float3x3 TBN = float3x3(tangent_dir, binormal_dir,normal_dir);
                normal_dir = normalize(mul(normal_map, TBN));

                //------------------------------------
                //直接光漫反射
                half3 light_dir = normalize(_WorldSpaceLightPos0.xyz);
                half atten = LIGHT_ATTENUATION(i); //衰减值（阴影）
                half diff_term = max(0.0, dot(normal_dir, light_dir));
                half half_lambert = (diff_term + 1.0) * 0.5;
                //half3 common_diffuse = base_color * _LightColor0 * diff_term * half_lambert * atten;//明度高的头发可以加上
                half3 common_diffuse = base_color;

                //------------------------------------
                //直接光高光  ---各向异性
                half2 uv_aniso = i.uv * _AnisoMap_ST.xy + _AnisoMap_ST.zw;
                half aniso_noise = tex2D(_AnisoMap, uv_aniso).r * 2.0 - 1.0; 

                half3 half_dir = normalize(light_dir + view_dir);
                half NdotH = saturate(dot(normal_dir, half_dir));

                half TdotH = saturate(dot(tangent_dir, half_dir));
                half NdotV = saturate(dot(normal_dir, view_dir));
                float aniso_atten = saturate(sqrt(max(0.0, half_lambert / NdotV))) * atten;  //衰减值

                //Spec1
                float3 spec_color1 = _SpecColor1.rgb + base_color;
                float aniso_offset1 = normal_dir * (aniso_noise * _SpecNoise1 + _SpecOffset1);
                float3 binormal_dir1 = normalize(binormal_dir + aniso_offset1);
                half BdotH1 = (dot(binormal_dir1, half_dir)) / _SpecShininess1; //KK需要根据引擎uv不同，选择切线或者副切线
                //half sinBH = sqrt(1 - BdotH * BdotH);//KK各项异性
                half3 spec_term1 = exp(-(TdotH * TdotH + BdotH1 * BdotH1)) / (1.0 + NdotH);
                half3 final_color1 = spec_term1 * aniso_atten * spec_color1 * _LightColor0.xyz;

                //Spec2
                float3 spec_color2 = _SpecColor2.rgb + base_color;
                float aniso_offset2 = normal_dir * (aniso_noise * _SpecNoise2 + _SpecOffset2);
                float3 binormal_dir2 = normalize(binormal_dir + aniso_offset2);
                half BdotH2 = (dot(binormal_dir2, half_dir)) / _SpecShininess2;
                half3 spec_term2 = exp(-(TdotH * TdotH + BdotH2 * BdotH2)) / (1.0 + NdotH);
                half3 final_color2 = spec_term2 * aniso_atten * spec_color2 * _LightColor0.xyz;

                half3 direct_specular = final_color2 + final_color1;

                //------------------------------------
                //间接光高光（IBL）
                half3 reflect_dir = reflect(-view_dir, normal_dir);
                roughess = roughess * (1.7 - 0.7 * roughess);
                float mip_level = roughess * 6.0;
                
                half4 color_envmap = texCUBElod(_EnvMap, float4(reflect_dir, mip_level));// 从立方体贴图中采样颜色
                half3 env_color = DecodeHDR(color_envmap, _EnvMap_HDR);// 解码HDR颜色
                half3 env_specular = env_color * _Expose * half_lambert * aniso_noise;

                //------------------------------------
                half3 final_color = common_diffuse + direct_specular + env_specular;

                final_color = ACES_Tonemapping(final_color);
                final_color = pow(final_color, 1.0 / 2.2);//转换到gamma空间
              
                return float4(final_color, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
