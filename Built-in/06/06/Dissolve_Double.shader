// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Double"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 1
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_Spread("Spread", Range( 0 , 1)) = 0
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
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
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeColorEmiss;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _EegeWidth;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime24 = _Time.y * 0.2;
			#ifdef _MNUECONTROL_ON
				float staticSwitch26 = _ChangeAmount;
			#else
				float staticSwitch26 = frac( mulTime24 );
			#endif
			float Gradient20 = ( ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float4 temp_cast_0 = (Gradient20).xxxx;
			float2 temp_cast_1 = (_NoiseSpeed).xx;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner34 = ( 1.0 * _Time.y * temp_cast_1 + uv_Noise);
			float4 Noise37 = tex2D( _Noise, panner34 );
			float4 temp_output_40_0 = ( temp_cast_0 - Noise37 );
			float4 temp_cast_2 = (0.5).xxxx;
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , temp_cast_2 ) / _EegeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( _EdgeColor * _EdgeColorEmiss ) , clampResult15);
			o.Emission = lerpResult16.rgb;
			o.Alpha = 1;
			float4 temp_cast_4 = (Gradient20).xxxx;
			clip( ( tex2DNode1.a * step( float4( 0.5,0,0,0 ) , temp_output_40_0 ) ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;43;-2873.599,654.6566;Inherit;False;1252.527;368;Noise;5;34;36;37;33;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2958.188,-24.81289;Inherit;False;1587.56;644.8994;Graditent;13;20;32;31;30;25;24;4;8;5;26;2;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-1145.554,-165.0988;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;0b7aca28296b0ed4e99f55846348e10e;0b7aca28296b0ed4e99f55846348e10e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-445.6587,566.5526;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;392.058,-14.42591;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Double;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;17;-635.0403,19.29964;Inherit;False;Property;_EdgeColor;EdgeColor;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5649109,0.1650938,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-307.5998,-2.67989;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;25.67978,-108.3252;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-575.6548,203.1507;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;4;0;Create;True;0;0;0;False;0;False;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2598.988,20.34301;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;b28a1c18dc150f14799e3197260c4c2a;b28a1c18dc150f14799e3197260c4c2a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;26;-2593.227,259.8699;Inherit;False;Property;_MnueControl;MnueControl;10;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2284.453,211.8469;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-2032.42,89.105;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-2728.672,229.4861;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2820.785,470.4223;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0;0.481;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2938.259,333.7137;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2491.777,385.5126;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-491.9827,291.5751;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;7;-783.1877,262.0756;Inherit;True;2;0;COLOR;0.5,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1125.285,551.4345;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-878.013,760.8701;Inherit;False;Property;_EegeWidth;EegeWidth;5;0;Create;True;0;0;0;False;0;False;0.1;0.88;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-801.9957,505.6754;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-184.668,642.4112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;69.72806,584.015;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-2912.178,218.8431;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1311.102,272.289;Inherit;False;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1312.967,402.69;Inherit;False;37;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1075.967,307.69;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;34;-2503.599,773.6566;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2793.599,906.6566;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1854.07,705.3244;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;33;-2231.598,704.6566;Inherit;True;Property;_Noise;Noise;8;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;d14593d4466be7e44b9d537374a698ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2823.599,746.6566;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-1857.967,481.4216;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1661.491,385.1795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1538.128,274.2532;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1791.383,273.2623;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;0;2;16;0
WireConnection;0;10;3;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;16;0;1;0
WireConnection;16;1;18;0
WireConnection;16;2;15;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;25;0;24;0
WireConnection;31;0;30;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;7;1;40;0
WireConnection;9;0;40;0
WireConnection;9;1;10;0
WireConnection;13;0;11;0
WireConnection;15;0;13;0
WireConnection;40;0;22;0
WireConnection;40;1;38;0
WireConnection;34;0;35;0
WireConnection;34;2;36;0
WireConnection;37;0;33;0
WireConnection;33;1;34;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;20;0;41;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
ASEEND*/
//CHKSM=F962C185379250679126B76A943C925CE20D3FC8