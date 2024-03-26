// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "BurnFlag"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Size("Size", Range( 0 , 10)) = 1
		_MainTex("MainTex", 2D) = "white" {}
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		_flag1pos("flag1.pos", 2D) = "white" {}
		_flag1norm("flag1.norm", 2D) = "white" {}
		_FrameCount("FrameCount", Float) = 101
		_Speed("Speed", Range( 0 , 1)) = 0
		_BoundingMax("BoundingMax", Float) = 1
		_BoundingMin("BoundingMin", Float) = 0
		_WindIntensity("WindIntensity", Range( 0 , 1)) = 0
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5
		_Spread("Spread", Range( 0 , 1)) = 0.5718622
		_ObjectScale("ObjectScale", Float) = 2
		_PivotOffset("PivotOffset", Float) = 0
		_FlameIntensity("FlameIntensity", Float) = 1
		_FlameWidth("FlameWidth", Range( 0 , 2)) = 0.1
		_FlameColor("FlameColor", Color) = (0,0,0,0)
		_CharringOffset("CharringOffset", Float) = 0.5
		_CharringWidth("CharringWidth", Range( 0 , 2)) = 0.1
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
		_Noise_Flow("Noise_Flow", 2D) = "white" {}
		_FlowMap("FlowMap", 2D) = "white" {}
		_Flow_Strength("Flow_Strength", Vector) = (0,0,0,0)
		_Flow_Speed("Flow_Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MNUECONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _flag1pos;
		uniform float _Speed;
		uniform float _FrameCount;
		uniform float _BoundingMax;
		uniform float _BoundingMin;
		uniform float _WindIntensity;
		uniform sampler2D _flag1norm;
		uniform float _PivotOffset;
		uniform float _ObjectScale;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise_Flow;
		uniform float4 _Noise_Flow_ST;
		uniform float _Size;
		uniform sampler2D _FlowMap;
		uniform float4 _FlowMap_ST;
		uniform float2 _Flow_Strength;
		uniform float _Flow_Speed;
		uniform float _CharringOffset;
		uniform float _CharringWidth;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float _FlameWidth;
		uniform float4 _FlameColor;
		uniform float _FlameIntensity;
		uniform float _Metallic;
		uniform float _Smoothness;
		uniform float _Cutoff = 0.5;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float CurrentFrame12 = ( ( -ceil( ( frac( ( _Time.y * _Speed ) ) * _FrameCount ) ) / _FrameCount ) + ( -1.0 / _FrameCount ) );
			float2 appendResult13 = (float2(v.texcoord2.xy.x , CurrentFrame12));
			float2 UV_VAT15 = appendResult13;
			float3 break42 = ( ( (tex2Dlod( _flag1pos, float4( UV_VAT15, 0, 0.0) )).rgb * ( _BoundingMax - _BoundingMin ) ) + _BoundingMin );
			float3 appendResult44 = (float3(break42.x , break42.y , break42.z));
			float3 VAT_VertexOffset48 = ( appendResult44 * _WindIntensity );
			v.vertex.xyz += VAT_VertexOffset48;
			v.vertex.w = 1;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 break45 = ((tex2Dlod( _flag1norm, float4( UV_VAT15, 0, 0.0) )).rgb*2.0 + -1.0);
			float3 appendResult46 = (float3(break45.x , break45.y , break45.z));
			float3 lerpResult88 = lerp( ase_vertexNormal , appendResult46 , _WindIntensity);
			float3 VAT_VertexNormal49 = lerpResult88;
			v.normal = VAT_VertexNormal49;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld84 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult77 = clamp( ( ( ( ase_worldPos.y - objToWorld84.y ) - _PivotOffset ) / _ObjectScale ) , 0.0 , 1.0 );
			float mulTime80 = _Time.y * 0.1;
			#ifdef _MNUECONTROL_ON
				float staticSwitch66 = _ChangeAmount;
			#else
				float staticSwitch66 = frac( mulTime80 );
			#endif
			float Gradient70 = ( ( ( clampResult77 - (-_Spread + (staticSwitch66 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float2 uv_Noise_Flow = i.uv_texcoord * _Noise_Flow_ST.xy + _Noise_Flow_ST.zw;
			float2 temp_output_4_0_g1 = (( uv_Noise_Flow / _Size )).xy;
			float2 uv_FlowMap = i.uv_texcoord * _FlowMap_ST.xy + _FlowMap_ST.zw;
			float4 tex2DNode151 = tex2D( _FlowMap, uv_FlowMap );
			float2 appendResult152 = (float2(tex2DNode151.r , tex2DNode151.g));
			float2 temp_output_17_0_g1 = _Flow_Strength;
			float mulTime22_g1 = _Time.y * _Flow_Speed;
			float temp_output_27_0_g1 = frac( mulTime22_g1 );
			float2 temp_output_11_0_g1 = ( temp_output_4_0_g1 + ( -(appendResult152*2.0 + -1.0) * temp_output_17_0_g1 * temp_output_27_0_g1 ) );
			float2 temp_output_12_0_g1 = ( temp_output_4_0_g1 + ( -(appendResult152*2.0 + -1.0) * temp_output_17_0_g1 * frac( ( mulTime22_g1 + 0.5 ) ) ) );
			float4 lerpResult9_g1 = lerp( tex2D( _Noise_Flow, temp_output_11_0_g1 ) , tex2D( _Noise_Flow, temp_output_12_0_g1 ) , ( abs( ( temp_output_27_0_g1 - 0.5 ) ) / 0.5 ));
			float FlowMap160 = (lerpResult9_g1).r;
			float GradientNoise101 = ( Gradient70 - FlowMap160 );
			float clampResult132 = clamp( ( ( distance( GradientNoise101 , _CharringOffset ) / _CharringWidth ) - 0.25 ) , 0.0 , 1.0 );
			float Charring134 = (clampResult132*2.0 + -0.1);
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			o.Albedo = ( Charring134 * tex2D( _MainTex, uv_MainTex ) ).rgb;
			float clampResult111 = clamp( ( 1.0 - ( distance( GradientNoise101 , 0.5 ) / _FlameWidth ) ) , 0.0 , 1.0 );
			float4 temp_output_114_0 = ( clampResult111 * _FlameColor );
			float4 Flame_Color120 = ( ( temp_output_114_0 * temp_output_114_0 ) * _FlameIntensity );
			o.Emission = Flame_Color120.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			clip( step( 0.5 , GradientNoise101 ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;161;-2712.652,1583.048;Inherit;False;1684.907;742.7108;FlowMap;10;158;147;151;159;160;148;154;152;157;150;FlowMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;138;-1309.136,1120.721;Inherit;False;1508.708;413.0997;Charring;10;132;144;140;134;129;125;128;127;126;146;Charring;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;113;-1036.525,581.4575;Inherit;False;1589.309;503.7505;FlameColor;13;123;118;120;117;114;111;116;112;109;110;105;107;108;FlameColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;100;-986.035,243.7969;Inherit;False;723.8547;277.5108;GradientNoise;5;162;101;98;96;97;GradientNoise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;57;-2801.968,-1108.616;Inherit;False;2347.763;1293.146;VAT;39;52;60;54;43;42;44;53;18;55;17;1;49;47;46;45;37;2;36;48;13;10;15;14;12;24;11;5;28;6;34;29;35;27;22;25;61;86;87;88;VAT;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-1494.609,-1328.389;Inherit;False;450.9875;138.2531;取整节点，依次为往小了取，四舍五入，往大了取;3;31;32;30;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;25;-1547.286,-837.9139;Inherit;False;176;143;求出一帧单位的偏移值;1;23;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;22;-1692.616,-1043.637;Inherit;False;163;124;保证从上面开始采样;1;21;;1,1,1,1;0;0
Node;AmplifyShaderEditor.FloorOpNode;30;-1444.609,-1278.389;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RoundOpNode;31;-1311.477,-1274.136;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;32;-1176.622,-1277.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;27;-2575.239,-1052;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-2615.09,-954.9688;Inherit;False;Property;_Speed;Speed;10;0;Create;True;0;0;0;False;0;False;0;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2134.569,-781.9826;Inherit;False;Property;_FrameCount;FrameCount;9;0;Create;True;0;0;0;False;0;False;101;101;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;21;-1670.616,-993.8576;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-1456.09,-965.8297;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-1275.023,-956.1199;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;12;-1114.364,-940.3897;Inherit;False;CurrentFrame;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;65;-2771.052,221.4914;Inherit;False;1712.631;875.9627;Graditent;20;84;83;81;80;79;78;77;76;75;74;73;72;71;70;69;68;67;66;104;103;Graditent;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;66;-2344.265,681.345;Inherit;False;Property;_MnueControl;MnueControl;25;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;67;-2479.71,650.9611;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-2689.297,755.189;Inherit;False;Property;_ChangeAmount;ChangeAmount;14;0;Create;True;0;0;0;False;0;False;0.5;0.547;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-1560.772,886.8206;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-1405.274,758.4258;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;73;-2082.287,634.8818;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;74;-2271.432,806.9879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;75;-1790.744,508.5207;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;76;-2480.335,383.8972;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;79;-2767.242,257.8099;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;81;-1555.458,717.1219;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;84;-2770.254,411.6653;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;36;-1968.411,-34.42214;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;2;-2308.655,-55.66473;Inherit;True;Property;_flag1norm;flag1.norm;8;0;Create;True;0;0;0;False;0;False;-1;908c9706f47c33a4aa4a2f048c2d4f90;908c9706f47c33a4aa4a2f048c2d4f90;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;37;-1793.822,-39.24294;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;45;-1581.221,-34.60863;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;46;-1302.221,-34.60863;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;1;-2463.406,-462.7374;Inherit;True;Property;_flag1pos;flag1.pos;7;0;Create;True;0;0;0;False;0;False;-1;0680b1a9af24f4442b4e252b528cf1db;0680b1a9af24f4442b4e252b528cf1db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;17;-2796.956,-442.6471;Inherit;False;15;UV_VAT;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-1821.173,-438.9465;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SwizzleNode;18;-2134.743,-455.0187;Inherit;False;FLOAT3;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;53;-2157.751,-260.1685;Inherit;False;Property;_BoundingMin;BoundingMin;12;0;Create;True;0;0;0;False;0;False;0;-2.653735;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-1224.912,-425.6594;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;42;-1496.995,-428.3867;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-1957.179,-386.7003;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;60;-1651.84,-415.1319;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-1284.138,-275.6204;Inherit;False;Property;_WindIntensity;WindIntensity;13;0;Create;True;0;0;0;False;0;False;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;86;-1020.78,-391.4389;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-819.1657,-396.8755;Inherit;False;VAT_VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;49;-769.8134,-20.11063;Inherit;False;VAT_VertexNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;87;-1338.127,-187.4514;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;88;-970.2306,-94.62055;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;90;-2706.095,1115.629;Inherit;False;1315.158;443.074;Noise;6;95;149;93;124;94;91;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;50;1.927905,262.4578;Inherit;False;49;VAT_VertexNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;17.00606,188.3268;Inherit;False;48;VAT_VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;77;-2002.74,461.2567;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;83;-2146.15,448.8802;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;78;-2321.507,542.7504;Inherit;False;Property;_ObjectScale;ObjectScale;18;0;Create;True;0;0;0;False;0;False;2;11.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;104;-2509.909,531.2076;Inherit;False;Property;_PivotOffset;PivotOffset;19;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;-2327.06,421.8297;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-958.1846,298.797;Inherit;False;70;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;70;-1245.624,751.0822;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;91;-2391.319,1232.119;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;94;-2121.439,1230.954;Inherit;True;Property;_Noise;Noise;15;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;6e9e3841a0552a34cb7c38b3628da853;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;59;-51.76815,-110.187;Inherit;False;Property;_Smoothness;Smoothness;6;0;Create;True;0;0;0;False;0;False;0;0.125;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-63.49226,-194.1782;Inherit;False;Property;_Metallic;Metallic;5;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-32.55725,-304.0403;Inherit;False;120;Flame_Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-98.73309,-501.218;Inherit;True;Property;_MainTex;MainTex;4;0;Create;True;0;0;0;False;0;False;-1;de5969b59a7d5db48b198da3aa63c061;de5969b59a7d5db48b198da3aa63c061;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;68;-2577.823,894.8977;Inherit;False;Property;_Spread;Spread;17;0;Create;True;0;0;0;False;0;False;0.5718622;0.569;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;80;-2663.216,640.3181;Inherit;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-997.3349,747.1458;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;107;-622.859,761.3846;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-1017.258,646.6335;Inherit;False;101;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;110;-797.2217,701.2205;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;109;-921.7969,862.2189;Inherit;False;Property;_FlameWidth;FlameWidth;21;0;Create;True;0;0;0;False;0;False;0.1;0.26;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;112;-483.965,767.9415;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;116;-390.8478,897.974;Inherit;False;Property;_FlameColor;FlameColor;22;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.9528301,0.6215672,0.1932624,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;111;-341.5151,768.808;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;117;-132.2865,920.0692;Inherit;False;Property;_FlameIntensity;FlameIntensity;20;0;Create;True;0;0;0;False;0;False;1;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;120;342.9355,785.8655;Inherit;False;Flame_Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;219.2589,788.6298;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;28.80806,765.8442;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-152.5521,772.6464;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-864.7353,1285.472;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;127;-1259.136,1170.721;Inherit;False;101;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;128;-1039.099,1225.308;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-1239.213,1271.233;Inherit;False;Property;_CharringOffset;CharringOffset;23;0;Create;True;0;0;0;False;0;False;0.5;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;129;-1162.675,1388.306;Inherit;False;Property;_CharringWidth;CharringWidth;24;0;Create;True;0;0;0;False;0;False;0.1;0.76;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;263.2786,-515.0458;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;140;-860.9368,1409.386;Inherit;False;Constant;_Float2;Float 2;22;0;Create;True;0;0;0;False;0;False;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-65.68011,-690.2513;Inherit;True;134;Charring;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;144;-701.498,1300.178;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-82.87066,1288.073;Inherit;True;Charring;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;132;-524.6577,1305.202;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-2670.838,1218.929;Inherit;False;0;94;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;149;-1828.143,1277.242;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1672.348,1247.341;Inherit;True;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;158;-2662.652,1979.955;Inherit;False;0;151;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;151;-2374.21,1935.177;Inherit;True;Property;_FlowMap;FlowMap;27;0;Create;True;0;0;0;False;0;False;-1;75c11ff777c73f745a290b5eb6b2723f;75c11ff777c73f745a290b5eb6b2723f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;160;-1260.745,1722.902;Inherit;False;FlowMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;148;-2350.763,1633.048;Inherit;True;Property;_Noise_Flow;Noise_Flow;26;0;Create;True;0;0;0;False;0;False;None;6e9e3841a0552a34cb7c38b3628da853;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;150;-2351.511,1819.475;Inherit;False;0;148;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;97;-983.779,395.7173;Inherit;False;95;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;98;-643.1241,323.6375;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;101;-470.4637,326.4626;Inherit;False;GradientNoise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;162;-825.0329,392.1274;Inherit;False;160;FlowMap;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;159;-1461.445,1723.189;Inherit;False;FLOAT;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;124;-2634.406,1355.21;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;16;0;Create;True;0;0;0;False;0;False;0,0;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ScaleAndOffsetNode;146;-305.0362,1316.885;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2328.931,-1015.616;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;28;-2171.603,-1007.788;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-2021.82,-998.668;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CeilOpNode;35;-1851.667,-987.3201;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;23;-1511.286,-793.9139;Inherit;False;2;0;FLOAT;-1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;152;-2033.988,1913.566;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;154;-2021.027,2049.728;Inherit;False;Property;_Flow_Strength;Flow_Strength;28;0;Create;True;0;0;0;False;0;False;0,0;0.5,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;157;-1982.667,2193.357;Inherit;False;Property;_Flow_Speed;Flow_Speed;29;0;Create;True;0;0;0;False;0;False;0;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;147;-1796.934,1715.563;Inherit;False;Flow;1;;1;acad10cc8145e1f4eb8042bebe2d9a42;2,50,0,51,0;6;5;SAMPLER2D;;False;2;FLOAT2;0,0;False;55;FLOAT;1;False;18;FLOAT2;0,0;False;17;FLOAT2;1,1;False;24;FLOAT;0.2;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2162.916,-358.4069;Inherit;False;Property;_BoundingMax;BoundingMax;11;0;Create;True;0;0;0;False;0;False;1;1.072085;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-2517.734,-581.8378;Inherit;False;12;CurrentFrame;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;15;-2111.936,-640.0259;Inherit;False;UV_VAT;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-2536.231,-718.0599;Inherit;False;2;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;13;-2289.295,-663.8865;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;99;313.1918,7.6273;Inherit;False;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;653.9877,-226.3965;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;BurnFlag;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;70.19112,17.80682;Inherit;False;101;GradientNoise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;43;-1355.836,-486.0402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;47;-1435.956,-88.34344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
WireConnection;21;0;35;0
WireConnection;11;0;21;0
WireConnection;11;1;5;0
WireConnection;24;0;11;0
WireConnection;24;1;23;0
WireConnection;12;0;24;0
WireConnection;66;1;67;0
WireConnection;66;0;69;0
WireConnection;67;0;80;0
WireConnection;72;0;81;0
WireConnection;72;1;71;0
WireConnection;73;0;66;0
WireConnection;73;3;74;0
WireConnection;74;0;68;0
WireConnection;75;0;77;0
WireConnection;75;1;73;0
WireConnection;76;0;79;2
WireConnection;76;1;84;2
WireConnection;81;0;75;0
WireConnection;81;1;68;0
WireConnection;36;0;2;0
WireConnection;2;1;17;0
WireConnection;37;0;36;0
WireConnection;45;0;37;0
WireConnection;46;0;45;0
WireConnection;46;1;45;1
WireConnection;46;2;45;2
WireConnection;1;1;17;0
WireConnection;55;0;18;0
WireConnection;55;1;54;0
WireConnection;18;0;1;0
WireConnection;44;0;42;0
WireConnection;44;1;42;1
WireConnection;44;2;42;2
WireConnection;42;0;60;0
WireConnection;54;0;52;0
WireConnection;54;1;53;0
WireConnection;60;0;55;0
WireConnection;60;1;53;0
WireConnection;86;0;44;0
WireConnection;86;1;61;0
WireConnection;48;0;86;0
WireConnection;49;0;88;0
WireConnection;88;0;87;0
WireConnection;88;1;46;0
WireConnection;88;2;61;0
WireConnection;77;0;83;0
WireConnection;83;0;103;0
WireConnection;83;1;78;0
WireConnection;103;0;76;0
WireConnection;103;1;104;0
WireConnection;70;0;72;0
WireConnection;91;0;93;0
WireConnection;91;2;124;0
WireConnection;94;1;91;0
WireConnection;107;0;110;0
WireConnection;107;1;109;0
WireConnection;110;0;105;0
WireConnection;110;1;108;0
WireConnection;112;0;107;0
WireConnection;111;0;112;0
WireConnection;120;0;118;0
WireConnection;118;0;123;0
WireConnection;118;1;117;0
WireConnection;123;0;114;0
WireConnection;123;1;114;0
WireConnection;114;0;111;0
WireConnection;114;1;116;0
WireConnection;126;0;128;0
WireConnection;126;1;129;0
WireConnection;128;0;127;0
WireConnection;128;1;125;0
WireConnection;141;0;142;0
WireConnection;141;1;4;0
WireConnection;144;0;126;0
WireConnection;144;1;140;0
WireConnection;134;0;146;0
WireConnection;132;0;144;0
WireConnection;149;0;94;1
WireConnection;95;0;149;0
WireConnection;151;1;158;0
WireConnection;160;0;159;0
WireConnection;98;0;96;0
WireConnection;98;1;162;0
WireConnection;101;0;98;0
WireConnection;159;0;147;0
WireConnection;146;0;132;0
WireConnection;34;0;27;0
WireConnection;34;1;6;0
WireConnection;28;0;34;0
WireConnection;29;0;28;0
WireConnection;29;1;5;0
WireConnection;35;0;29;0
WireConnection;23;1;5;0
WireConnection;152;0;151;1
WireConnection;152;1;151;2
WireConnection;147;5;148;0
WireConnection;147;2;150;0
WireConnection;147;18;152;0
WireConnection;147;17;154;0
WireConnection;147;24;157;0
WireConnection;15;0;13;0
WireConnection;13;0;10;1
WireConnection;13;1;14;0
WireConnection;99;1;102;0
WireConnection;0;0;141;0
WireConnection;0;2;121;0
WireConnection;0;3;58;0
WireConnection;0;4;59;0
WireConnection;0;10;99;0
WireConnection;0;11;51;0
WireConnection;0;12;50;0
WireConnection;43;0;42;0
WireConnection;47;0;45;0
ASEEND*/
//CHKSM=39BAAADFF11AFA8199BBABA8F3E040F5AACB3A6D