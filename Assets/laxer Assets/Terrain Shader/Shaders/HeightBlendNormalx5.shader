Shader "Custom/HeightBlended/Bump x5" {
	Properties {
	_Splat4 ("Layer 4 (A)", 2D) = "Black" {}
	_Normal4 ("Normal 4 (A)", 2D) = "bump" {}
	_Splat3 ("Layer 3 (B)", 2D) = "Black" {}
	_Normal3 ("Normal 3 (B)", 2D) = "bump" {}
	_Splat2 ("Layer 2 (G)", 2D) = "Black" {}
	_Normal2 ("Normal 2 (G)", 2D) = "bump" {}
	_Splat1 ("Layer 1 (R)", 2D) = "Black" {}
	_Normal1 ("Normal 1 (R)", 2D) = "bump" {}
	_Splat0 ("Layer 0 (-)", 2D) = "Black" {}
	_Normal0 ("Normal 0 (-)", 2D) = "bump" {}
	// used in fallback on old cards & base map
	_MainTex ("Fallback texture", 2D) = "Black" {}
	//controlls edge blurryness
	_Fade ("Fade length", Range( 0.001,0.5)) = 0.1
}
	
SubShader {
	Tags {
	}
CGPROGRAM
#pragma surface surf Lambert exclude_path:prepass exclude_path:deferred
#pragma target 3.0
struct Input {
	float2 uv_Splat0 : TEXCOORD0;
	float2 uv_Splat1 : TEXCOORD1;
	float2 uv_Splat2 : TEXCOORD2;
	float2 uv_Splat3 : TEXCOORD3;
	float2 uv_Splat4 : TEXCOORD4;
	float4 color : COLOR;
};

sampler2D _Splat0,_Splat1,_Splat2,_Splat3,_Splat4;
sampler2D _Normal0,_Normal1,_Normal2,_Normal3,_Normal4;
float _Fade;

void surf (Input IN, inout SurfaceOutput o) {
	float4 splat_control = IN.color;
	fixed4 tex0 = tex2D (_Splat0, IN.uv_Splat0);
	fixed4 tex1 = tex2D (_Splat1, IN.uv_Splat1);
	fixed4 tex2 = tex2D (_Splat2, IN.uv_Splat2);
	fixed4 tex3 = tex2D (_Splat3, IN.uv_Splat3);
	fixed4 tex4 = tex2D (_Splat4, IN.uv_Splat4);
	fixed4 norm0 = tex2D (_Normal0, IN.uv_Splat0);
	fixed4 norm1 = tex2D (_Normal1, IN.uv_Splat1);
	fixed4 norm2 = tex2D (_Normal2, IN.uv_Splat2);
	fixed4 norm3 = tex2D (_Normal3, IN.uv_Splat3);
	fixed4 norm4 = tex2D (_Normal4, IN.uv_Splat4);
	//splat_control *= 0.5.xxxx;
	fixed nothing = clamp(1-splat_control.r - splat_control.g - splat_control.b - splat_control.a,0,1);
	//nothing = nothing *2;
	splat_control += fixed4(tex1.a * splat_control.r, tex2.a * splat_control.g, tex3.a * splat_control.b, tex4.a * splat_control.a);
	
	fixed4 sc2;
		sc2.r =	clamp((splat_control.r - nothing)+_Fade,0,1) * clamp((splat_control.r - splat_control.g)+_Fade,0,1) * clamp((splat_control.r - splat_control.b)+_Fade,0,1) * clamp((splat_control.r - splat_control.a)+_Fade,0,1);
		sc2.g = clamp((splat_control.g - nothing)+_Fade,0,1) * clamp((splat_control.g - splat_control.r)+_Fade,0,1) * clamp((splat_control.g - splat_control.b)+_Fade,0,1) * clamp((splat_control.g - splat_control.a)+_Fade,0,1);
		sc2.b = clamp((splat_control.b - nothing)+_Fade,0,1) * clamp((splat_control.b - splat_control.r)+_Fade,0,1) * clamp((splat_control.b - splat_control.g)+_Fade,0,1) * clamp((splat_control.b - splat_control.a)+_Fade,0,1);
		sc2.a = clamp((splat_control.a - nothing)+_Fade,0,1) * clamp((splat_control.a - splat_control.r)+_Fade,0,1) * clamp((splat_control.a - splat_control.g)+_Fade,0,1) * clamp((splat_control.a - splat_control.b)+_Fade,0,1);
		fixed alpha = clamp((nothing - splat_control.r)+_Fade,0,1) * clamp((nothing - splat_control.g)+_Fade,0,1) * clamp((nothing - splat_control.b)+_Fade,0,1) * clamp((nothing - splat_control.a)+_Fade,0,1);
	half sum = sc2.r + sc2.g + sc2.b + sc2.a + alpha;
	sc2 = sc2 / sum;
	alpha = alpha / sum;
	o.Albedo = alpha * tex0 +  tex1 * sc2.r + tex2 * sc2.g + tex3 * sc2.b + tex4 * sc2.a;
	o.Normal = UnpackNormal(norm0) * alpha + UnpackNormal(norm1) * sc2.r + UnpackNormal(norm2) * sc2.g + UnpackNormal(norm3) * sc2.b + UnpackNormal(norm4) * sc2.a;

	o.Alpha = 0.0;
}
ENDCG  
}


Fallback "Mobile/Diffuse"
}
