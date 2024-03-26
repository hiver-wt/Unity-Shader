// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram"
{
	Properties
	{
		[HDR]_MainColor("MainColor", Color) = (0,0,0,0)
		[Toggle]_ZWriteMode("ZWriteMode", Float) = 0
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 0
		_RimPower("RimPower", Float) = 0
		_WireFram("WireFram", 2D) = "white" {}
		_WireFramIntensity("WireFramIntensity", Float) = 1
		_FlickControl("FlickControl", Range( 0 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 1
		[HDR]_ScanLineColor("ScanLineColor", Color) = (0,0,0,0)
		_ScanLine1("ScanLine 1", 2D) = "white" {}
		_Line1Alpha("Line 1 Alpha", Range( 0 , 1)) = 1
		_Line1Tilling("Line 1 Tilling", Float) = 2
		_Line1Speed("Line 1 Speed", Float) = -1
		_Line1Width("Line 1 Width", Range( 0 , 1)) = 0
		_Line1Power("Line 1 Power", Float) = 1
		_ScanLine2("ScanLine 2", 2D) = "white" {}
		_Line2Alpha("Line 2 Alpha", Range( 0 , 1)) = 1
		_Line2Tilling("Line 2 Tilling", Float) = 0
		_Line2Speed("Line 2 Speed", Float) = 0
		_Line2Power("Line 2 Power", Float) = 1
		_Line2Width("Line 2 Width", Range( 0 , 1)) = 0
		_GlicthTilling("GlicthTilling", Float) = 3
		_VertexOffset("VertexOffset", Vector) = (1,0,0,0)
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlitchTilling("GlitchTilling", Float) = 2
		_GlitchSpeed("Glitch Speed", Float) = 0
		_GlitchWidth("GlitchWidth", Float) = 0
		_GlitchHardness("GlitchHardness", Float) = 1
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		ZWrite [_ZWriteMode]
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
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

		uniform float _ZWriteMode;
		uniform float3 _VertexOffset;
		uniform float _GlicthTilling;
		uniform float3 _ScanlineVertexOffset;
		uniform sampler2D _GlicthTex;
		uniform float _GlitchTilling;
		uniform float _GlitchSpeed;
		uniform float _GlitchWidth;
		uniform float _GlitchHardness;
		uniform float _FlickControl;
		uniform float4 _MainColor;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _ScanLine1;
		uniform float _Line1Tilling;
		uniform float _Line1Speed;
		uniform float _Line1Width;
		uniform float _Line1Power;
		uniform float4 _ScanLineColor;
		uniform sampler2D _ScanLine2;
		uniform float _Line2Tilling;
		uniform float _Line2Speed;
		uniform float _Line2Width;
		uniform float _Line2Power;
		uniform float _Line2Alpha;
		uniform float _Line1Alpha;
		uniform sampler2D _WireFram;
		uniform float4 _WireFram_ST;
		uniform float _WireFramIntensity;
		uniform float _Alpha;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 viewToObjDir118 = mul( UNITY_MATRIX_T_MV, float4( _VertexOffset, 0 ) ).xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float mulTime105 = _Time.y * 2.5;
			float mulTime108 = _Time.y * -2.0;
			float2 appendResult107 = (float2((ase_worldPos.y*_GlicthTilling + mulTime105) , mulTime108));
			float simplePerlin2D106 = snoise( appendResult107 );
			simplePerlin2D106 = simplePerlin2D106*0.5 + 0.5;
			float2 break130 = appendResult107;
			float2 appendResult132 = (float2(( break130.x * 20.0 ) , break130.y));
			float simplePerlin2D133 = snoise( appendResult132*0.8 );
			simplePerlin2D133 = simplePerlin2D133*0.5 + 0.5;
			float clampResult135 = clamp( (simplePerlin2D133*2.0 + -1.0) , 0.0 , 1.0 );
			float3 objToWorld126 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime123 = _Time.y * -5.0;
			float mulTime124 = _Time.y * -2.0;
			float2 appendResult121 = (float2((( objToWorld126.x + objToWorld126.y + objToWorld126.z )*200.0 + mulTime123) , mulTime124));
			float simplePerlin2D125 = snoise( appendResult121 );
			simplePerlin2D125 = simplePerlin2D125*0.5 + 0.5;
			float clampResult128 = clamp( (simplePerlin2D125*2.0 + -1.0) , 0.0 , 1.0 );
			float3 temp_output_129_0 = ( ( ( viewToObjDir118 * 0.01 ) * (simplePerlin2D106*2.0 + -1.0) ) * clampResult135 * clampResult128 );
			float3 GlicthVertexOffset115 = ( temp_output_129_0 + temp_output_129_0 );
			float3 viewToObjDir147 = mul( UNITY_MATRIX_T_MV, float4( _ScanlineVertexOffset, 0 ) ).xyz;
			float3 objToWorld4_g23 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g23 = _Time.y * _GlitchSpeed;
			float2 appendResult12_g23 = (float2(0.5 , (( ase_worldPos.y - objToWorld4_g23.y )*_GlitchTilling + mulTime7_g23)));
			float clampResult26_g23 = clamp( ( ( tex2Dlod( _GlicthTex, float4( appendResult12_g23, 0, 0.0) ).r - _GlitchWidth ) * _GlitchHardness ) , 0.0 , 1.0 );
			float3 ScanlineGlitch152 = ( ( viewToObjDir147 * 0.01 ) * clampResult26_g23 );
			v.vertex.xyz += ( GlicthVertexOffset115 + ScanlineGlitch152 );
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 objToWorld13 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime12 = _Time.y * 15.0;
			float2 appendResult16 = (float2((( objToWorld13.x + objToWorld13.y + objToWorld13.z )*200.0 + mulTime12) , _Time.y));
			float simplePerlin2D7 = snoise( appendResult16 );
			simplePerlin2D7 = simplePerlin2D7*0.5 + 0.5;
			float clampResult21 = clamp( (0.5 + (simplePerlin2D7 - 0.0) * (2.0 - 0.5) / (1.0 - 0.0)) , 0.0 , 1.0 );
			float lerpResult50 = lerp( clampResult21 , 1.0 , _FlickControl);
			float Flicking18 = lerpResult50;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV26 = dot( normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) ), ase_worldViewDir );
			float fresnelNode26 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV26 , 0.0001 ), _RimPower ) );
			float FresnelFector36 = max( fresnelNode26 , 0.0 );
			float3 objToWorld4_g21 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g21 = _Time.y * _Line1Speed;
			float2 appendResult12_g21 = (float2(0.5 , (( ase_worldPos.y - objToWorld4_g21.y )*_Line1Tilling + mulTime7_g21)));
			float clampResult26_g21 = clamp( ( ( tex2D( _ScanLine1, appendResult12_g21 ).r - _Line1Width ) * _Line1Power ) , 0.0 , 1.0 );
			float temp_output_160_0 = clampResult26_g21;
			float3 objToWorld4_g22 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float mulTime7_g22 = _Time.y * _Line2Speed;
			float2 appendResult12_g22 = (float2(0.5 , (( ase_worldPos.y - objToWorld4_g22.y )*_Line2Tilling + mulTime7_g22)));
			float clampResult26_g22 = clamp( ( ( tex2D( _ScanLine2, appendResult12_g22 ).r - _Line2Width ) * _Line2Power ) , 0.0 , 1.0 );
			float ScanLine295 = ( clampResult26_g22 * _Line2Alpha );
			float4 FinalScanLineColor64 = ( temp_output_160_0 * _ScanLineColor * ScanLine295 );
			o.Emission = ( Flicking18 * ( _MainColor + ( _MainColor * FresnelFector36 ) + max( FinalScanLineColor64 , float4( 0,0,0,0 ) ) ) ).rgb;
			float FinalScanLineAlpha87 = ( ScanLine295 + ( ScanLine295 * temp_output_160_0 * _Line1Alpha ) );
			float clampResult47 = clamp( ( FresnelFector36 + _MainColor.a + FinalScanLineAlpha87 ) , 0.0 , 1.0 );
			float2 uv_WireFram = i.uv_texcoord * _WireFram_ST.xy + _WireFram_ST.zw;
			float WireFram41 = ( tex2D( _WireFram, uv_WireFram ).r * _WireFramIntensity );
			o.Alpha = ( clampResult47 * WireFram41 * _Alpha );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			sampler3D _DitherMaskLOD;
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
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
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
Node;AmplifyShaderEditor.CommentaryNode;154;-2357.749,1247.013;Inherit;False;1513.568;692.1791;扫描线信号干扰;11;141;143;144;146;147;148;150;151;152;142;145;扫描线信号干扰;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;116;-4867.143,701.8812;Inherit;False;2459.738;1241.501;GlicthVertexOffset;32;115;128;127;124;123;126;125;122;121;120;119;135;134;133;132;131;106;130;107;108;104;103;105;102;109;129;118;114;112;110;113;138;随机感信号干扰顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;-4146.045,-558.7954;Inherit;False;1719.224;1197.056;扫描线;21;83;75;57;70;72;59;84;85;98;99;87;64;86;76;78;80;81;93;94;95;79;扫描线;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2367.266,786.8483;Inherit;False;868.9999;383.1204;线框图;4;38;40;41;39;线框图;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;37;-2383.271,85.51883;Inherit;False;1339.126;649;菲涅尔因子;9;29;27;28;30;32;33;26;35;36;菲涅尔因子;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-419.6719,-480.9326;Inherit;False;246;166;深度写入开关;1;24;深度写入开关;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2375.73,-567.0786;Inherit;False;1865.279;600.1155;闪烁效果;14;12;9;10;16;17;7;14;13;3;18;20;21;50;51;闪烁效果;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2209.481,-517.0787;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;24;-369.6719,-430.9326;Inherit;False;Property;_ZWriteMode;ZWriteMode;2;1;[Toggle];Create;True;0;0;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;29;-2333.271,135.5188;Inherit;True;Property;_NormalMap;NormalMap;3;0;Create;True;0;0;0;False;0;False;-1;None;77b91526e481d164aa4fee6e8b5fc94c;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;27;-1994.271,161.5188;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;28;-2007.271,311.5188;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;30;-1994.271,458.5188;Inherit;False;Property;_RimBias;RimBias;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1987.271,544.5188;Inherit;False;Property;_RimScale;RimScale;5;0;Create;True;0;0;0;False;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-1936.271,618.5188;Inherit;False;Property;_RimPower;RimPower;6;0;Create;True;0;0;0;False;0;False;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;26;-1708.86,279.3766;Inherit;False;Standard;WorldNormal;ViewDir;True;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;35;-1412.145,274.145;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1277.145,272.145;Inherit;False;FresnelFector;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-2317.266,836.8483;Inherit;True;Property;_WireFram;WireFram;7;0;Create;True;0;0;0;False;0;False;-1;None;92f284b27dea88e41885444624ec2963;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1946.267,922.8483;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;41;-1731.267,938.8483;Inherit;False;WireFram;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2314.198,1053.968;Inherit;False;Property;_WireFramIntensity;WireFramIntensity;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-746.8295,-330.0598;Inherit;False;Flicking;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;20;-1291.156,-345.527;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;21;-1106.435,-330.5693;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-1195.534,-146.0187;Inherit;False;Property;_FlickControl;FlickControl;9;0;Create;True;0;0;0;False;0;False;0;0.088;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;-903.1782,196.0322;Inherit;False;Property;_MainColor;MainColor;1;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.2001877,0.4717921,2.020942,0.4117647;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;49;-308.5441,755.0903;Inherit;False;41;WireFram;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;115.1594,592.4882;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-141.388,583.4442;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-369.8287,550.9081;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-591.9182,648.1646;Inherit;False;87;FinalScanLineAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;19;-20.61939,-59.50815;Inherit;False;18;Flicking;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;175.0781,31.0071;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-20.46464,51.28341;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-292.3488,159.4295;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-603.9309,283.2027;Inherit;False;36;FresnelFector;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-373.8726,362.1942;Inherit;False;64;FinalScanLineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;92;-149.0885,260.2652;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;50;-903.1137,-316.8967;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3235.647,-180.777;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;75;-4023.111,-436.446;Inherit;True;Property;_ScanLine1;ScanLine 1;12;0;Create;True;0;0;0;False;0;False;None;afb16754b93daf04187b10b438f7a250;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;57;-4048.13,-240.254;Inherit;False;Property;_Line1Tilling;Line 1 Tilling;14;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-4085.983,-103.5835;Inherit;False;Property;_Line1Width;Line 1 Width;16;0;Create;True;0;0;0;False;0;False;0;0.25;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-4013.61,-20.79137;Inherit;False;Property;_Line1Power;Line 1 Power;17;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-4012.29,-167.6439;Inherit;False;Property;_Line1Speed;Line 1 Speed;15;0;Create;True;0;0;0;False;0;False;-1;-0.7;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;84;-3599.142,-106.5628;Inherit;False;Property;_ScanLineColor;ScanLineColor;11;1;[HDR];Create;True;0;0;0;False;0;False;0,0,0,0;0.9855288,2.408612,13.92881,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;85;-3054.309,-414.9849;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-3307.971,-445.1946;Inherit;False;95;ScanLine2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-2911.487,-508.7953;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-2672.822,-403.6384;Inherit;False;FinalScanLineAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-2999.994,-173.8231;Inherit;False;FinalScanLineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;86;-3325.435,-312.9811;Inherit;False;Property;_Line1Alpha;Line 1 Alpha;13;0;Create;True;0;0;0;False;0;False;1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;76;-4033.174,106.6043;Inherit;True;Property;_ScanLine2;ScanLine 2;18;0;Create;True;0;0;0;False;0;False;None;4bbf045a9f687084ea4bc84d53c39623;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;78;-4058.192,302.7965;Inherit;False;Property;_Line2Tilling;Line 2 Tilling;20;0;Create;True;0;0;0;False;0;False;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-4096.045,439.4664;Inherit;False;Property;_Line2Width;Line 2 Width;23;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-4023.672,522.2606;Inherit;False;Property;_Line2Power;Line 2 Power;22;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;93;-3648.724,474.4133;Inherit;False;Property;_Line2Alpha;Line 2 Alpha;19;0;Create;True;0;0;0;False;0;False;1;0.2;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;-3303.702,333.1654;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-3143.048,336.6368;Inherit;False;ScanLine2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-4082.352,370.4061;Inherit;False;Property;_Line2Speed;Line 2 Speed;21;0;Create;True;0;0;0;False;0;False;0;-1.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;-3352.121,1.074921;Inherit;False;95;ScanLine2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-439.8077,887.9307;Inherit;False;Property;_Alpha;Alpha;10;0;Create;True;0;0;0;False;0;False;1;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-3608.923,841.8812;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-3440.922,932.8812;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-4126.923,922.8812;Inherit;False;Constant;_Float0;Float 0;25;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;118;-3925.539,761.6041;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-2099.782,-349.969;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;10;-1948.406,-322.5367;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;16;-1706.113,-306.1935;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-2242.439,-212.2302;Inherit;False;Constant;_FlickTilling;FlickTilling;2;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;12;-2265.727,-110.1571;Inherit;False;1;0;FLOAT;15;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;17;-1948.077,-190.4079;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;7;-1548.36,-342.0193;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;13;-2345.013,-383.6884;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;109;-3817.259,1010.107;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;102;-4863.028,960.2299;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;105;-4827.028,1189.229;Inherit;False;1;0;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-4848.028,1116.229;Inherit;False;Property;_GlicthTilling;GlicthTilling;24;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-4643.424,996.7914;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-4630.358,1211.633;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-4455.795,1029.682;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;130;-4311.931,1299.037;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;106;-4277.392,1006.922;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;-3982.511,1297.217;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;134;-3635.416,1285.376;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-4457.484,1476.738;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;120;-4306.106,1504.171;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;-4063.811,1520.514;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-4600.14,1614.477;Inherit;False;Constant;_Tilling;Tilling;2;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;125;-3906.059,1484.688;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;126;-4702.713,1443.019;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;127;-3646.462,1479.973;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-2690.15,996.7779;Inherit;False;GlicthVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;135;-3410.804,1207.852;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;128;-3359.462,1486.973;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-3108.779,1016.147;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-2840.729,996.3415;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;124;-4305.777,1636.299;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;123;-4622.428,1716.55;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-4159.418,1240.346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;133;-3832.993,1296.527;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;143;-2290.266,1343.722;Inherit;True;Property;_GlicthTex;GlicthTex;26;0;Create;True;0;0;0;False;0;False;None;a21b2ad21e1aef24aabb0ca39246f277;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;144;-1595.893,1502.137;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-2292.537,1733.991;Inherit;False;Property;_GlitchWidth;GlitchWidth;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;147;-1689.501,1303.978;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-2307.749,1643.036;Inherit;False;Property;_GlitchSpeed;Glitch Speed;28;0;Create;True;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-1428.636,1397.976;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-1261.294,1566.304;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-2288.637,1823.792;Inherit;False;Property;_GlitchHardness;GlitchHardness;30;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-2307.399,1534.584;Inherit;False;Property;_GlitchTilling;GlitchTilling;27;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;-1077.782,1581.856;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;298.8572,773.808;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;13.92224,887.063;Inherit;False;152;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;141;-1924.686,1297.013;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;31;0;Create;True;0;0;0;False;0;False;0,0,0;-1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;457.4306,293.6601;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Hologram;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;True;_ZWriteMode;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.Vector3Node;112;-4115.923,756.8812;Inherit;False;Property;_VertexOffset;VertexOffset;25;0;Create;True;0;0;0;False;0;False;1,0,0;-3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;117;13.0164,767.1395;Inherit;False;115;GlicthVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;160;-3661.432,-354.8039;Inherit;False;MyScanLine;-1;;21;b91d8257acf9e534ab9d28ee675bfb4c;0;6;23;SAMPLER2D;0;False;19;FLOAT;0;False;21;FLOAT;1;False;22;FLOAT;1;False;24;FLOAT;0;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;161;-3657.182,231.5282;Inherit;False;MyScanLine;-1;;22;b91d8257acf9e534ab9d28ee675bfb4c;0;6;23;SAMPLER2D;0;False;19;FLOAT;0;False;21;FLOAT;1;False;22;FLOAT;1;False;24;FLOAT;0;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;162;-1861.352,1600.818;Inherit;False;MyScanLine;-1;;23;b91d8257acf9e534ab9d28ee675bfb4c;0;6;23;SAMPLER2D;0;False;19;FLOAT;0;False;21;FLOAT;1;False;22;FLOAT;1;False;24;FLOAT;0;False;25;FLOAT;1;False;1;FLOAT;0
WireConnection;27;0;29;0
WireConnection;26;0;27;0
WireConnection;26;4;28;0
WireConnection;26;1;30;0
WireConnection;26;2;32;0
WireConnection;26;3;33;0
WireConnection;35;0;26;0
WireConnection;36;0;35;0
WireConnection;40;0;38;1
WireConnection;40;1;39;0
WireConnection;41;0;40;0
WireConnection;18;0;50;0
WireConnection;20;0;7;0
WireConnection;21;0;20;0
WireConnection;48;0;47;0
WireConnection;48;1;49;0
WireConnection;48;2;52;0
WireConnection;47;0;46;0
WireConnection;46;0;43;0
WireConnection;46;1;1;4
WireConnection;46;2;88;0
WireConnection;4;0;19;0
WireConnection;4;1;45;0
WireConnection;45;0;1;0
WireConnection;45;1;44;0
WireConnection;45;2;92;0
WireConnection;44;0;1;0
WireConnection;44;1;43;0
WireConnection;92;0;89;0
WireConnection;50;0;21;0
WireConnection;50;2;51;0
WireConnection;83;0;160;0
WireConnection;83;1;84;0
WireConnection;83;2;101;0
WireConnection;85;0;98;0
WireConnection;85;1;160;0
WireConnection;85;2;86;0
WireConnection;99;0;98;0
WireConnection;99;1;85;0
WireConnection;87;0;99;0
WireConnection;64;0;83;0
WireConnection;94;0;161;0
WireConnection;94;1;93;0
WireConnection;95;0;94;0
WireConnection;113;0;118;0
WireConnection;113;1;114;0
WireConnection;110;0;113;0
WireConnection;110;1;109;0
WireConnection;118;0;112;0
WireConnection;14;0;13;1
WireConnection;14;1;13;2
WireConnection;14;2;13;3
WireConnection;10;0;14;0
WireConnection;10;1;9;0
WireConnection;10;2;12;0
WireConnection;16;0;10;0
WireConnection;16;1;17;0
WireConnection;7;0;16;0
WireConnection;109;0;106;0
WireConnection;104;0;102;2
WireConnection;104;1;103;0
WireConnection;104;2;105;0
WireConnection;107;0;104;0
WireConnection;107;1;108;0
WireConnection;130;0;107;0
WireConnection;106;0;107;0
WireConnection;132;0;131;0
WireConnection;132;1;130;1
WireConnection;134;0;133;0
WireConnection;119;0;126;1
WireConnection;119;1;126;2
WireConnection;119;2;126;3
WireConnection;120;0;119;0
WireConnection;120;1;122;0
WireConnection;120;2;123;0
WireConnection;121;0;120;0
WireConnection;121;1;124;0
WireConnection;125;0;121;0
WireConnection;127;0;125;0
WireConnection;115;0;138;0
WireConnection;135;0;134;0
WireConnection;128;0;127;0
WireConnection;129;0;110;0
WireConnection;129;1;135;0
WireConnection;129;2;128;0
WireConnection;138;0;129;0
WireConnection;138;1;129;0
WireConnection;131;0;130;0
WireConnection;133;0;132;0
WireConnection;147;0;141;0
WireConnection;150;0;147;0
WireConnection;150;1;144;0
WireConnection;151;0;150;0
WireConnection;151;1;162;0
WireConnection;152;0;151;0
WireConnection;156;0;117;0
WireConnection;156;1;155;0
WireConnection;0;2;4;0
WireConnection;0;9;48;0
WireConnection;0;11;156;0
WireConnection;160;23;75;0
WireConnection;160;21;57;0
WireConnection;160;22;59;0
WireConnection;160;24;70;0
WireConnection;160;25;72;0
WireConnection;161;23;76;0
WireConnection;161;21;78;0
WireConnection;161;22;79;0
WireConnection;161;24;80;0
WireConnection;161;25;81;0
WireConnection;162;23;143;0
WireConnection;162;21;145;0
WireConnection;162;22;148;0
WireConnection;162;24;146;0
WireConnection;162;25;142;0
ASEEND*/
//CHKSM=D4D6E1FA232324070A46C6A5038F926965528219