Shader "lit/Phong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {} // 主纹理属性
		_NormalMap("NormalMap", 2D) = "bump"{} // 法线贴图属性
		_NormalIntensity("Normal Intensity", Range(0.0, 5.0)) = 1.0 // 法线强度属性
		_AOMap("AO Map", 2D) = "white"{} // 环境光遮蔽图属性
		_SpecMask("Spec Mask", 2D) = "white"{} // 高光掩模属性
		_Shininess("Shininess", Range(0.01, 100)) = 1.0 // 高光强度属性
		_SpecIntensity("SpecIntensity", Range(0.01, 5)) = 1.0 // 高光强度属性
		_ParallaxMap("ParallaxMap", 2D) = "black"{} // 视差贴图属性
		_Parallax("__Parallax", float) = 2 // 视差深度属性
		//_AmbientColor("环境颜色", Color) = (0,0,0,0) // 环境颜色（已注释）
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			// 引入所需的包含文件
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			// 定义顶点输入结构
			struct appdata
			{
				float4 vertex : POSITION; // 顶点位置
				float2 texcoord : TEXCOORD0; // 纹理坐标
				float3 normal : NORMAL; // 顶点法线
				float4 tangent : TANGENT; // 顶点切线
			};

			// 定义顶点输出结构
			struct v2f
			{
				float4 pos : SV_POSITION; // 输出位置
				float2 uv : TEXCOORD0; // 输出纹理坐标
				float3 normal_dir : TEXCOORD1; // 世界空间中的法线方向
				float3 pos_world : TEXCOORD2; // 世界空间中的位置
				float3 tangent_dir : TEXCOORD3; // 世界空间中的切线方向
				float3 binormal_dir : TEXCOORD4; // 世界空间中的副切线方向
				SHADOW_COORDS(5) // 用于光照映射的阴影坐标
			};

			// 纹理采样器和属性定义
			sampler2D _MainTex; // 主纹理采样器
			float4 _MainTex_ST; // 主纹理缩放和偏移
			float4 _LightColor0; // 光源颜色
			float _Shininess; // 高光光泽度
			float4 _AmbientColor; // 环境颜色（已注释）
			float _SpecIntensity; // 高光强度
			sampler2D _AOMap; // 环境光遮蔽图
			sampler2D _SpecMask; // 高光掩模
			sampler2D _NormalMap; // 法线贴图
			float _NormalIntensity; // 法线强度
			sampler2D _ParallaxMap; // 视差贴图
			float _Parallax; // 视差深度

			// 色调映射函数（Tone-Mapping）
			float3 ACESFilm(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				return saturate((x * (a * x + b)) / (x * (c * x + d) + e));
			};

			// 顶点着色器
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); // 将顶点位置转换为剪辑空间坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // 转换纹理坐标
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); // 将法线转换为世界空间
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 将切线转换为世界空间
				o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w; // 计算副切线方向
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz; // 将顶点位置转换为世界空间坐标
				TRANSFER_SHADOW(o); // 传递阴影坐标
				return o;
			}

			// 片段着色器
			half4 frag(v2f i) : SV_Target
			{
				half shadow = SHADOW_ATTENUATION(i); // 阴影强度

				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world); // 视图方向
				half3 normal_dir = normalize(i.normal_dir); // 法线方向
				half3 tangent_dir = normalize(i.tangent_dir); // 切线方向
				half3 binormal_dir = normalize(i.binormal_dir); // 副切线方向
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir); // 切线空间到世界空间的转换矩阵
				half3 view_tangentspace = normalize(mul(TBN, view_dir)); // 视图方向在切线空间中
				half2 uv_parallax = i.uv;

				for (int i = 0; i < 10; i++)
				{
					half height = tex2D(_ParallaxMap, uv_parallax); // 从视差贴图中获取高度
					uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace.xy * _Parallax * 0.01f; // 使用视差映射调整纹理坐标
				}

				half4 base_color = tex2D(_MainTex, uv_parallax); // 获取主纹理颜色
				base_color = pow(base_color, 2.2); // Gamma矫正
				half4 ao_color = tex2D(_AOMap, uv_parallax); // 获取环境光遮蔽颜色
				half4 spec_mask = tex2D(_SpecMask, uv_parallax); // 获取高光掩模

				half4 normalmap = tex2D(_NormalMap, uv_parallax); // 获取法线贴图
				half3 normal_data = UnpackNormal(normalmap); // 解包法线贴图数据
				normal_data.xy = normal_data.xy * _NormalIntensity; // 缩放法线数据
				normal_dir = normalize(mul(normal_data.xyz, TBN)); // 计算最终法线方向

				half3 light_dir = normalize(_WorldSpaceLightPos0.xyz); // 光源方向
				half diff_term = min(shadow, max(0.0, dot(normal_dir, light_dir))); // 漫反射项
				half3 diffuse_color = diff_term * _LightColor0.xyz * base_color.xyz; // 漫反射颜色

				half3 half_dir = normalize(light_dir + view_dir); // 半向量
				half NdotH = dot(normal_dir, half_dir); // 法线和半向量的点积
				half3 spec_color = pow(max(0.0, NdotH), _Shininess) * diff_term * _LightColor0.xyz * _SpecIntensity * spec_mask.rgb; // 高光颜色

				half3 ambient_color = UNITY_LIGHTMODEL_AMBIENT.rgb * base_color.xyz; // 环境光颜色
				half3 final_color = (diffuse_color + spec_color + ambient_color) * ao_color; // 最终颜色

				// 有弊端，一般在后处理阶段做
				half3 tone_color = ACESFilm(final_color); // 色调映射
				tone_color = pow(tone_color, 1.0 / 2.2); // 反Gamma矫正
				return half4(tone_color, 1.0); // 输出最终颜色
			}
			ENDCG
		}
        Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION; // 顶点位置
				float2 texcoord : TEXCOORD0; // 纹理坐标
				float3 normal  : NORMAL; // 顶点法线
				float4 tangent : TANGENT; // 顶点切线
			};

			struct v2f
			{
				float4 pos : SV_POSITION; // 输出位置
				float2 uv : TEXCOORD0; // 输出纹理坐标
				float3 normal_dir : TEXCOORD1; // 世界空间中的法线方向
				float3 pos_world : TEXCOORD2; // 世界空间中的位置
				float3 tangent_dir : TEXCOORD3; // 世界空间中的切线方向
				float3 binormal_dir : TEXCOORD4; // 世界空间中的副切线方向
				LIGHTING_COORDS(5, 6) // 光照坐标
			};

			sampler2D _MainTex; // 主纹理采样器
			float4 _MainTex_ST; // 主纹理缩放和偏移
			float4 _LightColor0; // 光源颜色
			float _Shininess; // 高光光泽度
			float4 _AmbientColor; // 环境颜色（已注释）
			float _SpecIntensity; // 高光强度
			sampler2D _AOMap; // 环境光遮蔽图
			sampler2D _SpecMask; // 高光掩模
			sampler2D _NormalMap; // 法线贴图
			float _NormalIntensity; // 法线强度
			sampler2D _ParallaxMap; // 视差贴图
			float _Parallax; // 视差深度

			float3 ACESFilm(float3 x)
			{
				float a = 2.51f;
				float b = 0.03f;
				float c = 2.43f;
				float d = 0.59f;
				float e = 0.14f;
				return saturate((x*(a*x + b)) / (x*(c*x + d) + e));
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex); // 将顶点位置转换为剪辑空间坐标
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex); // 转换纹理坐标
				o.normal_dir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); // 将法线转换为世界空间
				o.tangent_dir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz); // 将切线转换为世界空间
				o.binormal_dir = normalize(cross(o.normal_dir, o.tangent_dir)) * v.tangent.w; // 计算副切线方向
				o.pos_world = mul(unity_ObjectToWorld, v.vertex).xyz; // 将顶点位置转换为世界空间坐标
				TRANSFER_VERTEX_TO_FRAGMENT(o); // 传递光照坐标
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half atten = LIGHT_ATTENUATION(i); // 光照衰减,投影

				half3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.pos_world); // 视图方向
				half3 normal_dir = normalize(i.normal_dir); // 法线方向
				half3 tangent_dir = normalize(i.tangent_dir); // 切线方向
				half3 binormal_dir = normalize(i.binormal_dir); // 副切线方向
				float3x3 TBN = float3x3(tangent_dir, binormal_dir, normal_dir); // 切线空间到世界空间的转换矩阵
				half3 view_tangentspace = normalize(mul(TBN, view_dir)); // 视图方向在切线空间中
				half2 uv_parallax = i.uv;

				for (int j = 0; j < 2; j++) //消耗很严重
				{
					half height = tex2D(_ParallaxMap, uv_parallax); // 从视差贴图中获取高度
					uv_parallax = uv_parallax - (0.5 - height) * view_tangentspace.xy * _Parallax * 0.01f; // 使用视差映射调整纹理坐标
				}

				half4 base_color = tex2D(_MainTex, uv_parallax); // 获取主纹理颜色
				half4 ao_color = tex2D(_AOMap, uv_parallax); // 获取环境光遮蔽颜色
				half4 spec_mask = tex2D(_SpecMask, uv_parallax); // 获取高光掩模
				half4 normalmap = tex2D(_NormalMap, uv_parallax); // 获取法线贴图
				half3 normal_data = UnpackNormal(normalmap); // 解包法线贴图数据
				normal_data.xy = normal_data.xy * _NormalIntensity; // 缩放法线数据
				normal_dir = normalize(mul(normal_data.xyz, TBN)); // 计算最终法线方向

				half3 light_dir_point = normalize(_WorldSpaceLightPos0.xyz - i.pos_world); // 点光源光照方向
				half3 light_dir = normalize(_WorldSpaceLightPos0.xyz); // 光源方向
				light_dir = lerp(light_dir, light_dir_point, _WorldSpaceLightPos0.w); // 在点光源和方向光源之间插值，w=0就是平行光，=1就是其他光源
				half diff_term = min(atten, max(0.0, dot(normal_dir, light_dir))); // 漫反射项
				half3 diffuse_color = diff_term * _LightColor0.xyz * base_color.xyz; // 漫反射颜色

				half3 half_dir = normalize(light_dir + view_dir); // 半向量
				half NdotH = dot(normal_dir, half_dir); // 法线和半向量的点积
				half3 spec_color = pow(max(0.0, NdotH), _Shininess) 
					 * diff_term * _LightColor0.xyz * _SpecIntensity * spec_mask.rgb; // 高光颜色

				half3 final_color = (diffuse_color + spec_color) * ao_color; // 最终颜色
				return half4(final_color, 1.0); // 输出最终颜色
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
