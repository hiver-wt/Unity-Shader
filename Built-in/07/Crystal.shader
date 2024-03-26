// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Crystal"
{
	Properties
	{
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 5
		_RimColor("RimColor", Color) = (1,0.9858491,0.9858491,0)
		_NormalMap("NormalMap", 2D) = "bump" {}
		_EmissMask("EmissMask", 2D) = "white" {}
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_ReflectIntensity("ReflectIntensity", Float) = 1
		_InsideTex("InsideTex", 2D) = "white" {}
		_TillingOffset("TillingOffset", Vector) = (1,1,0,0)
		_UVDistort("UVDistort", Float) = 1
		_InsideColor("InsideColor", Color) = (0,0,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
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
			float3 worldRefl;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _EmissMask;
		uniform float4 _EmissMask_ST;
		uniform float4 _RimColor;
		uniform samplerCUBE _ReflectTex;
		uniform float _ReflectIntensity;
		uniform sampler2D _InsideTex;
		uniform float4 _TillingOffset;
		uniform float _UVDistort;
		uniform float4 _InsideColor;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float4 tex2DNode9 = tex2D( _NormalMap, uv_NormalMap );
			float3 WorldNormal24 = normalize( (WorldNormalVector( i , tex2DNode9.rgb )) );
			float fresnelNdotV1 = dot( WorldNormal24, ase_worldViewDir );
			float fresnelNode1 = ( _RimBias + _RimScale * pow( 1.0 - fresnelNdotV1, _RimPower ) );
			float2 uv_EmissMask = i.uv_texcoord * _EmissMask_ST.xy + _EmissMask_ST.zw;
			float4 RimColor14 = ( ( fresnelNode1 + tex2D( _EmissMask, uv_EmissMask ) ) * _RimColor );
			float4 NormalMap26 = tex2DNode9;
			float dotResult32 = dot( WorldNormal24 , ase_worldViewDir );
			float clampResult37 = clamp( ( 1.0 - dotResult32 ) , 0.0 , 1.0 );
			float FresnelData40 = clampResult37;
			float4 ReflectColor21 = ( texCUBE( _ReflectTex, WorldReflectionVector( i , NormalMap26.rgb ) ) * _ReflectIntensity * ( FresnelData40 * FresnelData40 ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView62 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView65 = mul( UNITY_MATRIX_MV, float4( float3(0,0,0), 1 ) ).xyz;
			float3 objToViewDir74 = mul( UNITY_MATRIX_IT_MV, float4( WorldNormal24, 0 ) ).xyz;
			float4 lerpResult76 = lerp( tex2D( _InsideTex, ( ( ( (( objToView62 - objToView65 )).xy * (_TillingOffset).xy ) + (_TillingOffset).zw ) + ( (objToViewDir74).xy * _UVDistort ) ) ) , _InsideColor , FresnelData40);
			float4 InsideColor48 = lerpResult76;
			o.Emission = ( RimColor14 + ReflectColor21 + InsideColor48 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				surfIN.worldRefl = -worldViewDir;
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
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
Node;AmplifyShaderEditor.CommentaryNode;75;-2284.656,660.2666;Inherit;False;2219.467;736.6819;InsideColor;22;74;70;72;73;71;69;48;46;62;67;65;61;56;52;54;51;55;53;68;77;76;78;InsideColor;0.6509434,0.3899519,0.6375595,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;68;-1778.621,796.3817;Inherit;False;143;147;相对坐标值;1;63;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;41;-3465.01,592.8442;Inherit;False;1123.646;348.4982;FresnelData;6;32;33;38;40;30;37;FresnelData;1,0.8588839,0.3820755,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;28;-3189.556,159.2725;Inherit;False;853.0435;385.5979;Normal;4;24;2;9;26;Normal;1,0.2688679,0.2688679,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2285.234,161.2814;Inherit;False;1419.082;404.4617;ReflectColor;8;45;43;21;19;27;18;20;17;ReflectColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;13;-3004.306,-593.3808;Inherit;False;1818.888;696.9493;RimColor;11;8;12;10;7;1;6;5;4;3;14;25;RimColor;0.5235849,0.6608767,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Crystal;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-2642.596,-375.4788;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;4;-2623.302,-229.1836;Inherit;False;Property;_RimBias;RimBias;0;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2630.596,-144.4788;Inherit;False;Property;_RimScale;RimScale;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2499.597,-74.47888;Inherit;False;Property;_RimPower;RimPower;2;0;Create;True;0;0;0;False;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-1627.019,-284.9862;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;-1414.761,-260.9367;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-2569.513,359.2917;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;26;-2734.615,209.2726;Inherit;False;NormalMap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;8;-1856.496,-107.4314;Inherit;False;Property;_RimColor;RimColor;3;0;Create;True;0;0;0;False;0;False;1,0.9858491,0.9858491,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;32;-3198.714,644.1425;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;33;-3415.01,753.3427;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;30;-3408.896,642.8442;Inherit;False;24;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;37;-2864.41,668.3252;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-1773.698,210.7836;Inherit;True;Property;_ReflectTex;ReflectTex;6;0;Create;True;0;0;0;False;0;False;-1;27ea2da27bb70d943b8e70557f6e4fb5;None;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-1678.107,418.5116;Inherit;False;Property;_ReflectIntensity;ReflectIntensity;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldReflectionVector;18;-2036.966,218.8856;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;27;-2240.498,222.2039;Inherit;False;26;NormalMap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-2582.367,665.5592;Inherit;False;FresnelData;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-1313.903,343.3285;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-1137.521,363.174;Inherit;False;ReflectColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-1667.967,491.2115;Inherit;False;40;FresnelData;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;53;-1630.337,978.3274;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1424.267,844.9852;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;51;-1593.383,829.6068;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;54;-1630.337,1084.327;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;52;-1833.337,1014.327;Inherit;False;Property;_TillingOffset;TillingOffset;9;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;56;-1263.76,885.879;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;61;-2234.656,715.5182;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;65;-2050.621,895.3815;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;67;-2214.621,897.3815;Inherit;False;Constant;_Vector0;Vector 0;10;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;63;-1767.621,838.3818;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;62;-2049.975,710.2667;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;46;-927.9496,852.4495;Inherit;True;Property;_InsideTex;InsideTex;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;69;-1093.537,964.97;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;71;-1433.811,1186.408;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-1448.169,1292.339;Inherit;False;Property;_UVDistort;UVDistort;10;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1285.169,1173.339;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;-1944.428,1219.059;Inherit;False;24;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;74;-1706.317,1203.259;Inherit;False;Object;View;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;23;-441.2158,46.31715;Inherit;False;21;ReflectColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-434.7038,131.7272;Inherit;False;48;InsideColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;77;-841.3142,1057.167;Inherit;False;Property;_InsideColor;InsideColor;11;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-398.8234,854.1064;Inherit;False;InsideColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-818.6259,1239.803;Inherit;False;40;FresnelData;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;15;-464.9708,-40.85139;Inherit;False;14;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1458.056,465.1277;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-1901.226,-322.6491;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;12;-2214.069,-127.0722;Inherit;True;Property;_EmissMask;EmissMask;5;0;Create;True;0;0;0;False;0;False;-1;3aa57a15823b319419705785679bb9b4;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;76;-576.6021,993.3899;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;38;-3037.191,679.4175;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-197.9178,51.42503;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;1;-2305.355,-364.6578;Inherit;True;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-3139.556,262.6581;Inherit;True;Property;_NormalMap;NormalMap;4;0;Create;True;0;0;0;False;0;False;-1;033933fdb92f98847b11071483e5b2bc;None;True;0;False;bump;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;25;-2670.437,-501.099;Inherit;False;24;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2819.44,361.8706;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;0;2;44;0
WireConnection;7;0;10;0
WireConnection;7;1;8;0
WireConnection;14;0;7;0
WireConnection;24;0;2;0
WireConnection;26;0;9;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;37;0;38;0
WireConnection;17;1;18;0
WireConnection;18;0;27;0
WireConnection;40;0;37;0
WireConnection;19;0;17;0
WireConnection;19;1;20;0
WireConnection;19;2;45;0
WireConnection;21;0;19;0
WireConnection;53;0;52;0
WireConnection;55;0;51;0
WireConnection;55;1;53;0
WireConnection;51;0;63;0
WireConnection;54;0;52;0
WireConnection;56;0;55;0
WireConnection;56;1;54;0
WireConnection;65;0;67;0
WireConnection;63;0;62;0
WireConnection;63;1;65;0
WireConnection;62;0;61;0
WireConnection;46;1;69;0
WireConnection;69;0;56;0
WireConnection;69;1;72;0
WireConnection;71;0;74;0
WireConnection;72;0;71;0
WireConnection;72;1;73;0
WireConnection;74;0;70;0
WireConnection;48;0;76;0
WireConnection;45;0;43;0
WireConnection;45;1;43;0
WireConnection;10;0;1;0
WireConnection;10;1;12;0
WireConnection;76;0;46;0
WireConnection;76;1;77;0
WireConnection;76;2;78;0
WireConnection;38;0;32;0
WireConnection;44;0;15;0
WireConnection;44;1;23;0
WireConnection;44;2;57;0
WireConnection;1;0;25;0
WireConnection;1;4;3;0
WireConnection;1;1;4;0
WireConnection;1;2;5;0
WireConnection;1;3;6;0
WireConnection;2;0;9;0
ASEEND*/
//CHKSM=481F50F75DBFF6308A75E42D3EBCED0DFF130556