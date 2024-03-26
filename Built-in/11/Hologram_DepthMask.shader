// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Hologram_DepthMask"
{
	Properties
	{
		_GlicthTilling("GlicthTilling", Float) = 3
		_VertexOffset("VertexOffset", Vector) = (1,0,0,0)
		_GlicthTex("GlicthTex", 2D) = "white" {}
		_GlitchTilling("GlitchTilling", Float) = 2
		_GlitchSpeed("Glitch Speed", Float) = 0
		_GlitchWidth("GlitchWidth", Float) = 0
		_GlitchHardness("GlitchHardness", Float) = 1
		_ScanlineVertexOffset("ScanlineVertexOffset", Vector) = (0,0,0,0)
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		ColorMask 0
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
		};

		uniform float3 _VertexOffset;
		uniform float _GlicthTilling;
		uniform float3 _ScanlineVertexOffset;
		uniform sampler2D _GlicthTex;
		uniform float _GlitchTilling;
		uniform float _GlitchSpeed;
		uniform float _GlitchWidth;
		uniform float _GlitchHardness;


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
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;154;-1194.022,911.4606;Inherit;False;1513.568;692.1791;扫描线信号干扰;12;141;143;144;146;147;148;150;151;152;142;145;162;扫描线信号干扰;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;116;-3689.136,330.6308;Inherit;False;2459.738;1241.501;GlicthVertexOffset;32;115;128;127;124;123;126;125;122;121;120;119;135;134;133;132;131;106;130;107;108;104;103;105;102;109;129;118;114;112;110;113;138;随机感信号干扰顶点偏移;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-2430.919,470.6309;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;-2262.918,561.6307;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-2948.919,551.6307;Inherit;False;Constant;_Float0;Float 0;25;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;118;-2747.535,390.3537;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;109;-2639.255,638.8562;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;102;-3685.021,588.9793;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;105;-3649.021,817.9785;Inherit;False;1;0;FLOAT;2.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-3670.021,744.9782;Inherit;False;Property;_GlicthTilling;GlicthTilling;1;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;104;-3465.419,625.5406;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-3452.353,840.3825;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;107;-3277.79,658.4313;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;130;-3133.926,927.7865;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.NoiseGeneratorNode;106;-3099.387,635.6712;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;132;-2804.507,925.9666;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;134;-2457.412,914.1254;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;119;-3279.479,1105.488;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;120;-3128.101,1132.921;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;121;-2885.807,1149.264;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-3422.135,1243.227;Inherit;False;Constant;_Tilling;Tilling;2;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;125;-2728.055,1113.438;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;126;-3524.708,1071.769;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;127;-2468.458,1108.723;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;115;-1512.146,625.5272;Inherit;False;GlicthVertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;135;-2232.8,836.6016;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;128;-2181.458,1115.723;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;129;-1930.775,644.8962;Inherit;True;3;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-1662.725,625.0908;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;124;-3127.772,1265.048;Inherit;False;1;0;FLOAT;-2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;123;-3444.424,1345.3;Inherit;False;1;0;FLOAT;-5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-2981.414,869.0954;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;20;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;133;-2654.989,925.2765;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;143;-1126.539,1008.17;Inherit;True;Property;_GlicthTex;GlicthTex;3;0;Create;True;0;0;0;False;0;False;None;a21b2ad21e1aef24aabb0ca39246f277;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;144;-432.1655,1166.585;Inherit;False;Constant;_Float2;Float 2;26;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-1128.81,1398.439;Inherit;False;Property;_GlitchWidth;GlitchWidth;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;147;-525.774,968.4257;Inherit;False;View;Object;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;148;-1144.022,1307.484;Inherit;False;Property;_GlitchSpeed;Glitch Speed;5;0;Create;True;0;0;0;False;0;False;0;-1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;150;-264.9084,1062.424;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;-97.56631,1230.752;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;142;-1124.91,1488.24;Inherit;False;Property;_GlitchHardness;GlitchHardness;7;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-1143.672,1199.032;Inherit;False;Property;_GlitchTilling;GlitchTilling;4;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;152;85.94564,1246.304;Inherit;False;ScanlineGlitch;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector3Node;141;-760.9589,961.4606;Inherit;False;Property;_ScanlineVertexOffset;ScanlineVertexOffset;8;0;Create;True;0;0;0;False;0;False;0,0,0;-1,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;112;-2937.919,385.6308;Inherit;False;Property;_VertexOffset;VertexOffset;2;0;Create;True;0;0;0;False;0;False;1,0,0;-3,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;162;-697.625,1265.266;Inherit;False;MyScanLine;-1;;23;b91d8257acf9e534ab9d28ee675bfb4c;0;6;23;SAMPLER2D;0;False;19;FLOAT;0;False;21;FLOAT;1;False;22;FLOAT;1;False;24;FLOAT;0;False;25;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;457.4306,293.6601;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Hologram_DepthMask;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;1;False;_ZWriteMode;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Transparent;All;12;all;False;False;False;False;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;156;235.8572,560.808;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;117;-49.9836,554.1395;Inherit;False;115;GlicthVertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;155;-35.25037,674.063;Inherit;False;152;ScanlineGlitch;1;0;OBJECT;;False;1;FLOAT3;0
WireConnection;113;0;118;0
WireConnection;113;1;114;0
WireConnection;110;0;113;0
WireConnection;110;1;109;0
WireConnection;118;0;112;0
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
WireConnection;162;23;143;0
WireConnection;162;21;145;0
WireConnection;162;22;148;0
WireConnection;162;24;146;0
WireConnection;162;25;142;0
WireConnection;0;11;156;0
WireConnection;156;0;117;0
WireConnection;156;1;155;0
ASEEND*/
//CHKSM=A65F74CC2F0DC5743B4547863BC1D68210C233DE