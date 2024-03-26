// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Slime"
{
	Properties
	{
		_MatCap("MatCap", 2D) = "white" {}
		_BaseTex("BaseTex", 2D) = "white" {}
		_EmissMap("EmissMap", 2D) = "white" {}
		_Contrast("Contrast", Float) = 5
		_RimBias("RimBias", Float) = 0
		_RimScale("RimScale", Float) = 1
		_RimPower("RimPower", Float) = 1
		_NormalMap("NormalMap", 2D) = "white" {}
		_SlimeNormal("SlimeNormal", 2D) = "white" {}
		_SlimeTilling("SlimeTilling", Vector) = (0,0,0,0)
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_VertexAnimationNoise("VertexAnimationNoise", 2D) = "white" {}
		_VertexNoiseSpeed("VertexNoiseSpeed", Vector) = (0,0,0,0)
		_VertexNoiseTilling("VertexNoiseTilling", Vector) = (0,0,0,0)
		_VertexNoiseIntensity("VertexNoiseIntensity", Float) = 0.001
		_VertexBase("VertexBase", Vector) = (0,0,0,0)
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
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _VertexAnimationNoise;
		uniform float3 _VertexNoiseTilling;
		uniform float3 _VertexNoiseSpeed;
		uniform float3 _VertexBase;
		uniform float _VertexNoiseIntensity;
		uniform sampler2D _BaseTex;
		uniform float4 _BaseTex_ST;
		uniform sampler2D _MatCap;
		uniform float _Contrast;
		uniform sampler2D _SlimeNormal;
		uniform float3 _SlimeTilling;
		uniform float3 _NoiseSpeed;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimBias;
		uniform float _RimScale;
		uniform float _RimPower;
		uniform sampler2D _EmissMap;
		uniform float4 _EmissMap_ST;


		inline float4 TriplanarSampling96( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float2 tiling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= ( projNormal.x + projNormal.y + projNormal.z ) + 0.00001;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.zy * float2(  nsign.x, 1.0 ), 0, 0) );
			yNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xz * float2(  nsign.y, 1.0 ), 0, 0) );
			zNorm = tex2Dlod( topTexMap, float4(tiling * worldPos.xy * float2( -nsign.z, 1.0 ), 0, 0) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 objToWorld98 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float4 triplanar96 = TriplanarSampling96( _VertexAnimationNoise, ( ( ( ase_worldPos - objToWorld98 ) * _VertexNoiseTilling ) + ( _Time.y * _VertexNoiseSpeed ) ), ase_worldNormal, 5.0, float2( 1,1 ), 1.0, 0 );
			float4 VertexNoise106 = triplanar96;
			float dotResult133 = dot( ase_worldNormal , _VertexBase );
			float clampResult134 = clamp( dotResult133 , 0.0 , 1.0 );
			float3 worldToObj136 = mul( unity_WorldToObject, float4( ( ( ( VertexNoise106 * float4( ( ase_worldNormal + _VertexBase ) , 0.0 ) * ( clampResult134 + 1.0 ) * v.color.r ) * _VertexNoiseIntensity * 0.01 ) + float4( ase_worldPos , 0.0 ) ).xyz, 1 ) ).xyz;
			float3 VertexAnimation114 = worldToObj136;
			v.vertex.xyz = VertexAnimation114;
			v.vertex.w = 1;
		}

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_BaseTex = i.uv_texcoord * _BaseTex_ST.xy + _BaseTex_ST.zw;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 temp_cast_0 = (_Contrast).xxx;
			float3 temp_output_71_0 = pow( abs( ase_worldNormal ) , temp_cast_0 );
			float3 break74 = temp_output_71_0;
			float3 break76 = ( temp_output_71_0 / ( break74.x + break74.y + break74.z ) );
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld59 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 temp_output_90_0 = ( ( ( ase_worldPos - objToWorld59 ) * _SlimeTilling ) + ( _Time.y * _NoiseSpeed ) );
			float3 normalizeResult82 = normalize( ( ( break76.z * UnpackNormal( tex2D( _SlimeNormal, (temp_output_90_0).xy ) ) ) + ( break76.x * UnpackNormal( tex2D( _SlimeNormal, (temp_output_90_0).yz ) ) ) + ( break76.y * UnpackNormal( tex2D( _SlimeNormal, (temp_output_90_0).xz ) ) ) ) );
			float3 break83 = normalizeResult82;
			float3 appendResult44 = (float3(( ase_worldNormal.x + break83.x ) , ( ase_worldNormal.y + break83.y ) , ase_worldNormal.z));
			float3 normalizeResult50 = ASESafeNormalize( appendResult44 );
			float3 WorldNomal52 = normalizeResult50;
			float4 MatCapColor23 = tex2D( _MatCap, ((mul( UNITY_MATRIX_V, float4( WorldNomal52 , 0.0 ) ).xyz).xy*0.5 + 0.5) );
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float fresnelNdotV12 = dot( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )), ase_worldViewDir );
			float fresnelNode12 = ( _RimBias + _RimScale * pow( max( 1.0 - fresnelNdotV12 , 0.0001 ), _RimPower ) );
			float4 color19 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float4 RimColor27 = ( ( fresnelNode12 * color19 ) * tex2D( _EmissMap, uv_EmissMap ) );
			o.Emission = ( ( tex2D( _BaseTex, uv_BaseTex ) * MatCapColor23 ) + RimColor27 ).rgb;
			o.Alpha = 1;
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
Node;AmplifyShaderEditor.CommentaryNode;115;-4444.767,897.3779;Inherit;False;2268.938;732.1484;VertexAnimation;16;114;136;137;138;113;112;117;111;110;135;134;133;120;119;109;118;VertexAnimation;1,0.2688679,0.2688679,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;107;-2096.447,858.479;Inherit;False;1701.453;765.8213;VertexNoise;12;106;96;95;100;103;105;104;102;101;99;98;97;VertexNoise;1,0.9129025,0.6462264,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;84;-6019.085,-391.9047;Inherit;False;3904.082;1166.629;TipPlanarNormalMap;34;49;70;71;72;73;74;75;76;77;79;54;57;58;59;60;65;66;68;78;55;61;62;81;80;82;83;52;50;85;89;91;90;88;92;TipPlanarNormalMap;0.5518868,0.5631812,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;49;-3287.803,-116.0997;Inherit;False;655.5049;382.7861;改善UV接缝，但是是错误的;4;47;48;44;45;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-2064.838,61.77519;Inherit;False;1521.322;684.0742;RimColor;12;9;27;20;18;12;19;13;21;15;14;17;16;RimColor;1,0.6839622,0.6839622,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-2061.847,-377.0583;Inherit;False;1472.503;355.3156;MatCapColor;7;1;6;5;4;3;23;53;MatCapColor;0.969676,0.8632076,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1776.244,-258.0584;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;5;-1610.244,-251.0584;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;6;-1440.986,-245.7025;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1225.245,-298.0583;Inherit;True;Property;_MatCap;MatCap;1;0;Create;True;0;0;0;False;0;False;-1;4daf30927b9b77047955233919d7ca50;4daf30927b9b77047955233919d7ca50;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-1644.279,547.0231;Inherit;False;Property;_RimScale;RimScale;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1638.279,622.0231;Inherit;False;Property;_RimPower;RimPower;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-1643.129,314.694;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;15;-1639.744,462.9543;Inherit;False;Property;_RimBias;RimBias;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;-2014.839,111.7752;Inherit;True;Property;_NormalMap;NormalMap;8;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;13;-1676.452,161.9797;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;19;-1365.829,423.759;Inherit;False;Constant;_RimColor;RimColor;6;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;12;-1399.457,258.9495;Inherit;False;Standard;WorldNormal;ViewDir;False;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1101.814,319.1679;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;27;-769.4938,321.8186;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;9;-1170.528,545.6116;Inherit;True;Property;_EmissMap;EmissMap;3;0;Create;True;0;0;0;False;0;False;-1;231b75d5f3f583d4194114bd757154e5;231b75d5f3f583d4194114bd757154e5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;53;-1972.159,-203.251;Inherit;False;52;WorldNomal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-2759.361,25.82791;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-2943.803,141.9016;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;47;-2934.803,-42.09931;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;45;-3237.803,-66.09943;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;70;-5730.889,-184.0043;Inherit;False;Property;_Contrast;Contrast;4;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;71;-5434.059,-264.5729;Inherit;False;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;72;-5696.74,-293.9246;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;73;-5969.085,-341.9047;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-4905.771,-196.1166;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;76;-4434.204,-222.5302;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleDivideOpNode;77;-4627.513,-244.6818;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;52;-2348.003,41.1462;Inherit;False;WorldNomal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;50;-2567.479,41.00957;Inherit;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-4064.938,-20.213;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-4099.87,521.13;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-4061.854,276.5796;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;80;-3798.07,100.6819;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;82;-3653.878,110.0183;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;55;-4534.834,36.73542;Inherit;True;Property;_SlimeNoise1;SlimeNoise;7;0;Create;True;0;0;0;False;0;False;-1;14d5df279c3145048990e3992dd97f70;14d5df279c3145048990e3992dd97f70;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;61;-4533.541,283.7061;Inherit;True;Property;_SlimeNoise2;SlimeNoise;7;0;Create;True;0;0;0;False;0;False;-1;14d5df279c3145048990e3992dd97f70;14d5df279c3145048990e3992dd97f70;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-4520.104,529.7932;Inherit;True;Property;_SlimeNoise3;SlimeNoise;8;0;Create;True;0;0;0;False;0;False;-1;14d5df279c3145048990e3992dd97f70;14d5df279c3145048990e3992dd97f70;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;54;-4995.095,-71.76089;Inherit;True;Property;_SlimeNormal;SlimeNormal;9;0;Create;True;0;0;0;False;0;False;14d5df279c3145048990e3992dd97f70;14d5df279c3145048990e3992dd97f70;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SwizzleNode;57;-4954.273,128.4553;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;65;-4933.167,516.3929;Inherit;False;FLOAT2;0;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;66;-4945.023,404.9534;Inherit;False;FLOAT2;1;2;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;83;-3478.181,106.0561;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;74;-5170.604,-192.49;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TriplanarNode;92;-3092.174,407.7534;Inherit;True;Spherical;World;False;Top Texture 0;_TopTexture0;white;0;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-5714.352,174.5931;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;59;-6012.113,275.6583;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;60;-6009.682,75.21589;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;90;-5231.789,279.2222;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-5472.71,269.8041;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;81;-5724.089,320.7244;Inherit;False;Property;_SlimeTilling;SlimeTilling;10;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;97;-1748.683,1007.857;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;98;-2046.447,1108.922;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;99;-2044.016,908.479;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;105;-1758.42,1153.988;Inherit;False;Property;_VertexNoiseTilling;VertexNoiseTilling;14;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;100;-1266.121,1173.587;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;95;-1345.882,914.4313;Inherit;True;Property;_VertexAnimationNoise;VertexAnimationNoise;12;0;Create;True;0;0;0;False;0;False;c62fcf287b97dcc4f8091f0107df6ab1;c62fcf287b97dcc4f8091f0107df6ab1;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-594.8948,1026.92;Inherit;False;VertexNoise;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;101;-1702.921,1318.644;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;-1481.327,1334.012;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;103;-1713.436,1408.805;Inherit;False;Property;_VertexNoiseSpeed;VertexNoiseSpeed;13;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-1507.042,1103.068;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TriplanarNode;96;-1014.361,1025.271;Inherit;True;Spherical;World;False;Top Texture 1;_TopTexture1;white;-1;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Triplanar Sampler;Tangent;10;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;9;FLOAT3;0,0,0;False;8;FLOAT;1;False;3;FLOAT2;1,1;False;4;FLOAT;5;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-4049.297,1092.932;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;133;-4045.387,1248.229;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-3294.488,1070.706;Inherit;False;4;4;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-3677.646,991.3723;Inherit;False;106;VertexNoise;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-3276.596,1405.788;Inherit;False;Constant;_Float0;Float 0;16;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;112;-3010.882,1094.105;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldPosInputsNode;138;-3038.901,1349.516;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-2828.626,1108.704;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-2430.644,1102.812;Inherit;False;VertexAnimation;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;136;-2665.168,1108.485;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;25;-426.4305,98.771;Inherit;False;23;MatCapColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;409.5082,-4.167107;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Slime;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;202.747,59.37663;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;116;92.41107,257.8743;Inherit;False;114;VertexAnimation;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;29;-40.73251,130.0065;Inherit;False;27;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-33.82098,-2.907148;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;7;-519.5825,-89.47207;Inherit;True;Property;_BaseTex;BaseTex;2;0;Create;True;0;0;0;False;0;False;-1;743dff48827dd9041949af4542c361c1;743dff48827dd9041949af4542c361c1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-798.4552,-302.5222;Inherit;True;MatCapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleTimeNode;85;-5615.397,492.4694;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-5393.802,507.8365;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;88;-5594.661,584.6465;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;11;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-925.3619,319.6235;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewMatrixNode;3;-1959.71,-312.1816;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.Vector3Node;120;-4401.28,1237.774;Inherit;False;Property;_VertexBase;VertexBase;16;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.VertexColorNode;118;-3583.569,1332.893;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;134;-3859.792,1225.998;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;135;-3682.462,1212.186;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;109;-4422.47,1014.797;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;113;-3320.333,1231.972;Inherit;False;Property;_VertexNoiseIntensity;VertexNoiseIntensity;15;0;Create;True;0;0;0;False;0;False;0.001;0;0;0;0;1;FLOAT;0
WireConnection;4;0;3;0
WireConnection;4;1;53;0
WireConnection;5;0;4;0
WireConnection;6;0;5;0
WireConnection;1;1;6;0
WireConnection;13;0;21;0
WireConnection;12;0;13;0
WireConnection;12;4;14;0
WireConnection;12;1;15;0
WireConnection;12;2;16;0
WireConnection;12;3;17;0
WireConnection;18;0;12;0
WireConnection;18;1;19;0
WireConnection;27;0;20;0
WireConnection;44;0;47;0
WireConnection;44;1;48;0
WireConnection;44;2;45;3
WireConnection;48;0;45;2
WireConnection;48;1;83;1
WireConnection;47;0;45;1
WireConnection;47;1;83;0
WireConnection;71;0;72;0
WireConnection;71;1;70;0
WireConnection;72;0;73;0
WireConnection;75;0;74;0
WireConnection;75;1;74;1
WireConnection;75;2;74;2
WireConnection;76;0;77;0
WireConnection;77;0;71;0
WireConnection;77;1;75;0
WireConnection;52;0;50;0
WireConnection;50;0;44;0
WireConnection;79;0;76;2
WireConnection;79;1;55;0
WireConnection;68;0;76;1
WireConnection;68;1;62;0
WireConnection;78;0;76;0
WireConnection;78;1;61;0
WireConnection;80;0;79;0
WireConnection;80;1;78;0
WireConnection;80;2;68;0
WireConnection;82;0;80;0
WireConnection;55;0;54;0
WireConnection;55;1;57;0
WireConnection;61;0;54;0
WireConnection;61;1;66;0
WireConnection;62;0;54;0
WireConnection;62;1;65;0
WireConnection;57;0;90;0
WireConnection;65;0;90;0
WireConnection;66;0;90;0
WireConnection;83;0;82;0
WireConnection;74;0;71;0
WireConnection;58;0;60;0
WireConnection;58;1;59;0
WireConnection;90;0;89;0
WireConnection;90;1;91;0
WireConnection;89;0;58;0
WireConnection;89;1;81;0
WireConnection;97;0;99;0
WireConnection;97;1;98;0
WireConnection;100;0;104;0
WireConnection;100;1;102;0
WireConnection;106;0;96;0
WireConnection;102;0;101;0
WireConnection;102;1;103;0
WireConnection;104;0;97;0
WireConnection;104;1;105;0
WireConnection;96;0;95;0
WireConnection;96;9;100;0
WireConnection;119;0;109;0
WireConnection;119;1;120;0
WireConnection;133;0;109;0
WireConnection;133;1;120;0
WireConnection;110;0;111;0
WireConnection;110;1;119;0
WireConnection;110;2;135;0
WireConnection;110;3;118;1
WireConnection;112;0;110;0
WireConnection;112;1;113;0
WireConnection;112;2;117;0
WireConnection;137;0;112;0
WireConnection;137;1;138;0
WireConnection;114;0;136;0
WireConnection;136;0;137;0
WireConnection;0;2;11;0
WireConnection;0;11;116;0
WireConnection;11;0;8;0
WireConnection;11;1;29;0
WireConnection;8;0;7;0
WireConnection;8;1;25;0
WireConnection;23;0;1;0
WireConnection;91;0;85;0
WireConnection;91;1;88;0
WireConnection;20;0;18;0
WireConnection;20;1;9;0
WireConnection;134;0;133;0
WireConnection;135;0;134;0
ASEEND*/
//CHKSM=5B833DC59F45DCC2424EA39672345A61ABE548C5