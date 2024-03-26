// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Double Vertical 1"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 1
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_MainColor("MainColor", Color) = (0,0,0,0)
		_Spread("Spread", Range( 0 , 1)) = 0.629294
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
		_MainColorAdjust("MainColorAdjust", Float) = 0.18
		_Float2("Float 2", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MNUECONTROL_ON
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float4 _MainColor;
		uniform float _MainColorAdjust;
		uniform float4 _EdgeColor;
		uniform float _EdgeColorEmiss;
		uniform float _Float2;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _EegeWidth;
		uniform float _Cutoff = 0.5;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Albedo = ( _MainColor * _MainColorAdjust ).rgb;
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld78 = mul( unity_ObjectToWorld, float4( float3( 0,-0.5,0 ), 1 ) ).xyz;
			float clampResult52 = clamp( ( ( ase_worldPos.y - objToWorld78.y ) / _Float2 ) , 0.0 , 1.0 );
			float mulTime24 = _Time.y * 0.2;
			#ifdef _MNUECONTROL_ON
				float staticSwitch26 = _ChangeAmount;
			#else
				float staticSwitch26 = frac( mulTime24 );
			#endif
			float Gradient20 = ( ( ( ( 1.0 - clampResult52 ) - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float4 temp_cast_1 = (Gradient20).xxxx;
			float2 temp_cast_2 = (_NoiseSpeed).xx;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner34 = ( 1.0 * _Time.y * temp_cast_2 + uv_Noise);
			float4 Noise37 = ( 1.0 - tex2D( _Noise, panner34 ) );
			float4 temp_output_40_0 = ( temp_cast_1 - Noise37 );
			float4 temp_cast_3 = (0.5).xxxx;
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , temp_cast_3 ) / _EegeWidth ) ) , 0.0 , 1.0 );
			o.Emission = ( _EdgeColor * _EdgeColorEmiss * clampResult15 ).rgb;
			o.Alpha = 1;
			float4 temp_cast_5 = (Gradient20).xxxx;
			clip( step( float4( 0.5,0,0,0 ) , temp_output_40_0 ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;21;-3251.509,-534.5603;Inherit;False;1908.058;984.0826;Graditent;19;52;4;49;32;42;41;20;46;31;8;24;5;30;25;26;61;78;80;79;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;61;-2292.883,-274.1962;Inherit;False;191;130;把方向改成从上到下;1;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2605.157,531.5185;Inherit;False;1252.527;368;Noise;6;34;36;33;35;37;58;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-445.6587,566.5526;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;7;-783.1877,262.0756;Inherit;True;2;0;COLOR;0.5,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1125.285,551.4345;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-878.013,760.8701;Inherit;False;Property;_EegeWidth;EegeWidth;3;0;Create;True;0;0;0;False;0;False;0.1;1.432;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-801.9957,505.6754;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-184.668,642.4112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1311.102,272.289;Inherit;False;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1075.967,307.69;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;34;-2235.157,650.5185;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2525.157,783.5185;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2555.157,623.5185;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1312.967,403.8686;Inherit;False;37;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-37.33199,65.86628;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-159.1307,-88.84186;Inherit;False;Property;_MainColorAdjust;MainColorAdjust;10;0;Create;True;0;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;127.6904,-104.8204;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.4571022;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;44;-198.2574,-297.434;Inherit;False;Property;_MainColor;MainColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7216981,0.8586897,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;392.058,-14.42591;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Dissolve_Double Vertical 1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-447.0501,184.7787;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;2;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-461.1795,-11.93325;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.1750177,0.4272177,0.6509434,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;15;27.68624,615.2949;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;33;-2027.277,651.3538;Inherit;True;Property;_Noise;Noise;7;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;0b741386b9612564188990f7c153bfbf;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1572.186,645.7403;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;58;-1676.377,729.6537;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1533.519,-15.73071;Inherit;True;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-2099.709,-158.607;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1856.765,-3.40714;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1862.331,189.586;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1692.31,108.9672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;59;-2265.843,-223.841;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-3162.265,133.1079;Inherit;False;Property;_ChangeAmount;ChangeAmount;1;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3037.446,348.1669;Inherit;False;Property;_Spread;Spread;6;0;Create;True;0;0;0;False;0;False;0.629294;0.668;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-3194.637,4.643308;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-2981.225,18.3278;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2742.254,232.0569;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2524.924,-17.65528;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;46;-3191.421,-441.6576;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;78;-3198.562,-279.2326;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,-0.5,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;26;-2831.594,42.86301;Inherit;False;Property;_MnueControl;MnueControl;9;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-2909.733,-370.9723;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;52;-2570.887,-344.2032;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;79;-2703.625,-259.7298;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2831.414,-113.6747;Inherit;False;Property;_Float2;Float 2;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;7;1;40;0
WireConnection;9;0;40;0
WireConnection;9;1;10;0
WireConnection;13;0;11;0
WireConnection;40;0;22;0
WireConnection;40;1;38;0
WireConnection;34;0;35;0
WireConnection;34;2;36;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;18;2;15;0
WireConnection;45;0;44;0
WireConnection;45;1;57;0
WireConnection;0;0;45;0
WireConnection;0;2;18;0
WireConnection;0;10;7;0
WireConnection;15;0;13;0
WireConnection;33;1;34;0
WireConnection;37;0;58;0
WireConnection;58;0;33;0
WireConnection;20;0;41;0
WireConnection;4;0;59;0
WireConnection;4;1;8;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;59;0;52;0
WireConnection;25;0;24;0
WireConnection;31;0;30;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
WireConnection;49;0;46;2
WireConnection;49;1;78;2
WireConnection;52;0;79;0
WireConnection;79;0;49;0
WireConnection;79;1;80;0
ASEEND*/
//CHKSM=2B8739E02F5CCD1E996481AA5B1AA5C084D00D02