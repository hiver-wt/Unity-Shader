// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Teleport"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_BaseTex("BaseTex", 2D) = "white" {}
		_NormalMap("NormalMap", 2D) = "bump" {}
		_CompMask("CompMask", 2D) = "white" {}
		_MetallicAdjust("MetallicAdjust", Range( 0 , 1)) = 0
		_SmoothnessAdjust("SmoothnessAdjust", Range( 0 , 1)) = 0
		_DissolveAmount("DissolveAmount", Float) = 1
		_DissolveOffset("DissolveOffset", Float) = 0
		_DissolveSpread("DissolveSpread", Float) = 1
		_NoiseScale("NoiseScale", Vector) = (200,1,1,0)
		_DistanceEdgeOffset("DistanceEdgeOffset", Float) = 0.5
		[HDR]_EdgeColor("EdgeColor", Color) = (0.240566,0.6528675,1,0)
		_VertexEffectOffset("VertexEffectOffset", Float) = 0
		_VertexOffsetIntensiy("VertexOffsetIntensiy", Float) = 5
		_VertexEffectSpread("VertexEffectSpread", Float) = 1
		_VertexOffsetNoise("VertexOffsetNoise", Vector) = (5,5,5,0)
		[HDR]_RimColor("RimColor", Color) = (0.2311321,0.742731,1,0)
		_RimControl("RimControl", Range( 0 , 1)) = 0
		_EmissTex("EmissTex", 2D) = "white" {}
		_RimIntensity("RimIntensity", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float _DissolveAmount;
		uniform float _VertexEffectOffset;
		uniform float _VertexEffectSpread;
		uniform float _VertexOffsetIntensiy;
		uniform float3 _VertexOffsetNoise;
		uniform float _DissolveOffset;
		uniform float _DissolveSpread;
		uniform float3 _NoiseScale;
		uniform sampler2D _BaseTex;
		uniform float4 _BaseTex_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _MetallicAdjust;
		uniform sampler2D _CompMask;
		uniform float4 _CompMask_ST;
		uniform float _SmoothnessAdjust;
		uniform float _RimControl;
		uniform float _DistanceEdgeOffset;
		uniform float4 _EdgeColor;
		uniform float _RimIntensity;
		uniform sampler2D _EmissTex;
		uniform float4 _EmissTex_ST;
		uniform float4 _RimColor;
		uniform float _Cutoff = 0.5;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 objToWorld21 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_22_0 = ( ase_worldPos.y - objToWorld21.y );
			float simplePerlin3D74 = snoise( ( ase_worldPos * _VertexOffsetNoise ) );
			simplePerlin3D74 = simplePerlin3D74*0.5 + 0.5;
			float3 worldToObj70 = mul( unity_WorldToObject, float4( ( ( max( 0.0 , ( ( ( temp_output_22_0 + _DissolveAmount ) - _VertexEffectOffset ) / _VertexEffectSpread ) ) * float3(0,1,0) * _VertexOffsetIntensiy * simplePerlin3D74 ) + ase_worldPos ), 1 ) ).xyz;
			float3 ase_vertex3Pos = v.vertex.xyz;
			float3 VertexOffset69 = ( worldToObj70 - ase_vertex3Pos );
			v.vertex.xyz += VertexOffset69;
			v.vertex.w = 1;
		}

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld21 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float temp_output_22_0 = ( ase_worldPos.y - objToWorld21.y );
			float temp_output_27_0 = ( ( ( ( 1.0 - temp_output_22_0 ) - _DissolveAmount ) - _DissolveOffset ) / _DissolveSpread );
			float smoothstepResult53 = smoothstep( 0.8 , 1.0 , temp_output_27_0);
			float simplePerlin3D32 = snoise( ( ase_worldPos * _NoiseScale ) );
			simplePerlin3D32 = simplePerlin3D32*0.5 + 0.5;
			float clampResult29 = clamp( ( smoothstepResult53 + ( temp_output_27_0 - simplePerlin3D32 ) ) , 0.0 , 1.0 );
			float Dissolve51 = clampResult29;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float2 uv_BaseTex = i.uv_texcoord * _BaseTex_ST.xy + _BaseTex_ST.zw;
			float3 gammaToLinear14 = GammaToLinearSpace( tex2D( _BaseTex, uv_BaseTex ).rgb );
			s1.Albedo = gammaToLinear14;
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 tex2DNode4 = UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) );
			s1.Normal = normalize( WorldNormalVector( i , tex2DNode4 ) );
			s1.Emission = float3( 0,0,0 );
			float2 uv_CompMask = i.uv_texcoord * _CompMask_ST.xy + _CompMask_ST.zw;
			float4 tex2DNode5 = tex2D( _CompMask, uv_CompMask );
			float clampResult8 = clamp( ( _MetallicAdjust + tex2DNode5.r ) , 0.0 , 1.0 );
			s1.Metallic = clampResult8;
			float clampResult12 = clamp( ( ( 1.0 - tex2DNode5.g ) + _SmoothnessAdjust ) , 0.0 , 1.0 );
			s1.Smoothness = clampResult12;
			s1.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			#ifdef UNITY_PASS_FORWARDADD//1
			surfResult1 -= s1.Emission;
			#endif//1
			float3 linearToGamma15 = LinearToGammaSpace( surfResult1 );
			float RimControl98 = _RimControl;
			float3 PBR_Light16 = ( linearToGamma15 * RimControl98 );
			float saferPower42 = abs( ( 1.0 - distance( temp_output_27_0 , _DistanceEdgeOffset ) ) );
			float smoothstepResult43 = smoothstep( 0.0 , 1.0 , ( pow( saferPower42 , 3.0 ) - simplePerlin3D32 ));
			float4 DissolveEdgeColor46 = ( smoothstepResult43 * _EdgeColor );
			float3 NormalMap96 = tex2DNode4;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult94 = dot( (WorldNormalVector( i , NormalMap96 )) , ase_worldViewDir );
			float clampResult85 = clamp( ( ( 1.0 - (dotResult94*0.5 + 0.5) ) - (_RimControl*2.0 + -1.0) ) , 0.0 , 1.0 );
			float2 uv_EmissTex = i.uv_texcoord * _EmissTex_ST.xy + _EmissTex_ST.zw;
			float4 RimEmiss86 = ( _RimIntensity * ( clampResult85 + ( clampResult85 * tex2D( _EmissTex, uv_EmissTex ).r ) ) * _RimColor );
			c.rgb = ( float4( PBR_Light16 , 0.0 ) + DissolveEdgeColor46 + RimEmiss86 ).rgb;
			c.a = 1;
			clip( Dissolve51 - _Cutoff );
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT( UnityGI, gi );
				o.Alpha = LightingStandardCustomLighting( o, worldViewDir, gi ).a;
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;78;-2734.613,1282.522;Inherit;False;2004.446;838.1416;VertexOffset;19;63;57;59;58;60;62;66;64;71;67;68;70;72;69;75;65;76;77;74;VertexOffset;1,0.7216981,0.7216981,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;55;-2678.578,398.0671;Inherit;False;2823.243;804.0123;Dissolve;24;23;25;26;28;36;38;37;41;39;32;40;27;50;42;29;51;53;35;54;30;45;43;46;44;Dissolve;0.6179246,0.8048189,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1627.5,-543.1815;Inherit;False;1769.378;922.6859;PBR Lighting;17;99;16;100;15;96;14;10;12;3;5;7;6;8;4;11;9;1;PBR Lighting;1,0.7028302,0.7028302,1;0;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;-637.0679,-323.2463;Inherit;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;9;-1214.51,162.1791;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1024.51,201.1791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;4;-1249.42,-301.8725;Inherit;True;Property;_NormalMap;NormalMap;2;0;Create;True;0;0;0;False;0;False;-1;77b91526e481d164aa4fee6e8b5fc94c;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;8;-909.3682,-157.2467;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1145.49,-53.91411;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1494.299,-59.84154;Inherit;False;Property;_MetallicAdjust;MetallicAdjust;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;5;-1577.5,25.91101;Inherit;True;Property;_CompMask;CompMask;3;0;Create;True;0;0;0;False;0;False;-1;a7f745220fb33f946a159d308f6c7308;a7f745220fb33f946a159d308f6c7308;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-1256.596,-493.1816;Inherit;True;Property;_BaseTex;BaseTex;1;0;Create;True;0;0;0;False;0;False;-1;f7549f6cf82871c439168b7599da3968;f7549f6cf82871c439168b7599da3968;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;12;-866.3244,31.05084;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1424.511,257.1791;Inherit;False;Property;_SmoothnessAdjust;SmoothnessAdjust;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;14;-886.9844,-381.3034;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;707.2206,3.92645;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Teleport;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;471.5836,128.9957;Inherit;False;51;Dissolve;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;41;-1012.857,756.5643;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;39;-1203.327,763.0953;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;-665.2517,819.3806;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;29;-937.8455,571.4046;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;51;-751.7788,570.6799;Inherit;False;Dissolve;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;53;-1307.967,448.0671;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.8;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;35;-1267.887,575.6071;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-1083.087,551.7106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;45;-520.8513,990.0794;Inherit;False;Property;_EdgeColor;EdgeColor;11;1;[HDR];Create;True;0;0;0;False;0;False;0.240566,0.6528675,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;43;-493.9114,820.3769;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;-95.33688,875.7219;Inherit;False;DissolveEdgeColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-242.9183,870.3769;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;42;-833.1561,751.5472;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.PosVertexDataNode;71;-1367.126,1642.684;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;70;-1371.544,1473.486;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-1118.126,1501.684;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;69;-963.1655,1505.212;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;36;-2063.625,766.4894;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-1794.579,814.746;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;37;-2053.579,905.746;Inherit;False;Property;_NoiseScale;NoiseScale;9;0;Create;True;0;0;0;False;0;False;200,1,1;100,100,100;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.NoiseGeneratorNode;32;-1636.47,823.5242;Inherit;False;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1547.528,746.6608;Inherit;False;Property;_DistanceEdgeOffset;DistanceEdgeOffset;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;25;-1800.83,565.7358;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;27;-1607.829,577.7358;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1800.83,694.7358;Inherit;False;Property;_DissolveSpread;DissolveSpread;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-2005.831,685.7358;Inherit;False;Property;_DissolveOffset;DissolveOffset;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;63;-2665.125,1332.522;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-2398.62,1376.061;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-2433.644,1540.084;Inherit;False;Property;_VertexEffectSpread;VertexEffectSpread;14;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;58;-2191.664,1378.757;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-2684.613,1502.627;Inherit;False;Property;_VertexEffectOffset;VertexEffectOffset;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;62;-2024.469,1380.119;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;66;-2039.052,1672.029;Inherit;False;Property;_VertexOffsetIntensiy;VertexOffsetIntensiy;13;0;Create;True;0;0;0;False;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1734.189,1437.793;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;67;-1750.386,1607.192;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;68;-1537.486,1477.392;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;75;-2440.632,1751.835;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;65;-2037.476,1524.835;Inherit;False;Constant;_Vector0;Vector 0;14;0;Create;True;0;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;76;-2434.613,1932.664;Inherit;False;Property;_VertexOffsetNoise;VertexOffsetNoise;15;0;Create;True;0;0;0;False;0;False;5,5,5;0,1,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-2208.613,1833.664;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;74;-2059.797,1803.887;Inherit;True;Simplex3D;True;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;20;-3406.021,510.0058;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;23;-2036.743,564.6359;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-2239.693,565.4476;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-3164.277,956.6718;Inherit;False;Property;_DissolveAmount;DissolveAmount;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;21;-3435.661,681.7185;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;22;-3127.34,616.5927;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;73;442.8055,443.3875;Inherit;False;69;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;18;164.6621,133.3141;Inherit;False;16;PBR_Light;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;48;150.094,239.8993;Inherit;False;46;DissolveEdgeColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;443.4271,232.5148;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;145.7693,327.6656;Inherit;False;86;RimEmiss;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;82;-27.62048,1457.672;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;92;38.27594,1715.359;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;181.695,1479.423;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;80;-485.6205,1516.672;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;79;-502.7512,1321.018;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;94;-195.9147,1483.172;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-900.49,-247.0582;Inherit;False;NormalMap;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-682.4537,1341.533;Inherit;False;96;NormalMap;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;91;-448.7241,1706.359;Inherit;False;Property;_RimControl;RimControl;17;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LinearToGammaNode;15;-392.4735,-310.8955;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;100;-370.8306,-156.1628;Inherit;False;98;RimControl;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-162.4854,1798.561;Inherit;False;RimControl;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;99;-190.8306,-292.1628;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-50.0714,-293.8871;Inherit;False;PBR_Light;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;85;574.5801,1481.523;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;376.3796,1483.558;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;1164.601,1491.574;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;86;1312.601,1489.574;Inherit;False;RimEmiss;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;89;912.2014,1700.875;Inherit;False;Property;_RimColor;RimColor;16;1;[HDR];Create;True;0;0;0;False;0;False;0.2311321,0.742731,1,0;0.2311321,0.742731,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;779.9777,1559.803;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;952.0869,1486.712;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;105;374.2347,1709.261;Inherit;True;Property;_EmissTex;EmissTex;18;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;106;943.8103,1392.174;Inherit;False;Property;_RimIntensity;RimIntensity;19;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
WireConnection;1;0;14;0
WireConnection;1;1;4;0
WireConnection;1;3;8;0
WireConnection;1;4;12;0
WireConnection;9;0;5;2
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;8;0;6;0
WireConnection;6;0;7;0
WireConnection;6;1;5;1
WireConnection;12;0;11;0
WireConnection;14;0;3;0
WireConnection;0;10;52;0
WireConnection;0;13;47;0
WireConnection;0;11;73;0
WireConnection;41;0;39;0
WireConnection;39;0;27;0
WireConnection;39;1;40;0
WireConnection;50;0;42;0
WireConnection;50;1;32;0
WireConnection;29;0;54;0
WireConnection;51;0;29;0
WireConnection;53;0;27;0
WireConnection;35;0;27;0
WireConnection;35;1;32;0
WireConnection;54;0;53;0
WireConnection;54;1;35;0
WireConnection;43;0;50;0
WireConnection;46;0;44;0
WireConnection;44;0;43;0
WireConnection;44;1;45;0
WireConnection;42;0;41;0
WireConnection;70;0;68;0
WireConnection;72;0;70;0
WireConnection;72;1;71;0
WireConnection;69;0;72;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;32;0;38;0
WireConnection;25;0;23;0
WireConnection;25;1;26;0
WireConnection;27;0;25;0
WireConnection;27;1;28;0
WireConnection;63;0;22;0
WireConnection;63;1;24;0
WireConnection;57;0;63;0
WireConnection;57;1;60;0
WireConnection;58;0;57;0
WireConnection;58;1;59;0
WireConnection;62;1;58;0
WireConnection;64;0;62;0
WireConnection;64;1;65;0
WireConnection;64;2;66;0
WireConnection;64;3;74;0
WireConnection;68;0;64;0
WireConnection;68;1;67;0
WireConnection;77;0;75;0
WireConnection;77;1;76;0
WireConnection;74;0;77;0
WireConnection;23;0;30;0
WireConnection;23;1;24;0
WireConnection;30;0;22;0
WireConnection;22;0;20;2
WireConnection;22;1;21;2
WireConnection;47;0;18;0
WireConnection;47;1;48;0
WireConnection;47;2;90;0
WireConnection;82;0;94;0
WireConnection;92;0;91;0
WireConnection;83;0;82;0
WireConnection;79;0;97;0
WireConnection;94;0;79;0
WireConnection;94;1;80;0
WireConnection;96;0;4;0
WireConnection;15;0;1;0
WireConnection;98;0;91;0
WireConnection;99;0;15;0
WireConnection;99;1;100;0
WireConnection;16;0;99;0
WireConnection;85;0;93;0
WireConnection;93;0;83;0
WireConnection;93;1;92;0
WireConnection;87;0;106;0
WireConnection;87;1;103;0
WireConnection;87;2;89;0
WireConnection;86;0;87;0
WireConnection;102;0;85;0
WireConnection;102;1;105;1
WireConnection;103;0;85;0
WireConnection;103;1;102;0
ASEEND*/
//CHKSM=DDDD4447344C94A8EB40332A2D17B1DFF44248CB