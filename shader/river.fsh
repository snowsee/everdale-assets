#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec2 v_texCoord0;
in vec3 v_normal;
in vec3 v_tangent0;
in vec3 v_tangent1;
uniform sampler2D normalTex;
uniform sampler2D diffuseTex;
uniform float u_time;
in vec3 v_vCoord;

uniform vec3 u_lightDirView;
uniform vec3 u_diffuseLight;
uniform vec3 u_shadowLight;

// Tweakables
uniform vec3 u_water_col;
uniform vec3 u_water_colRefl;
uniform float u_water_spec;
uniform float u_water_pow;
uniform float u_water_R0;

uniform float u_river_wave_0_scale;        // 0.1
uniform float u_river_wave_0_intensity;    // 1.0
uniform float u_river_wave_0_speed;        // 0.2
uniform float u_river_wave_1_scale;        // 0.5
uniform float u_river_wave_1_intensity;    // 1.0
uniform float u_river_wave_1_speed;        // 0.2

uniform vec4 u_foam_color;	 
uniform float u_foam_base_mul;
uniform float u_foam_wave_scale;     	   // 15.0
uniform float u_foam_wave_intensity;       // 0.7
uniform float u_foam_wave_speed;           // 2.0
uniform float u_foam_wave_offset;

uniform float u_foam_distort_scale;       // 0.1
uniform float u_foam_distort_intensity;   // 1.0
uniform float u_foam_distort_speed;       // 0.1
uniform float u_foam_distort2_intensity;  // 2.0
uniform float u_foam_fade_pow;			  // 1.0
uniform float u_foam_ramp_bias;			  // 0.5
uniform float u_foam_ramp_smoothing;	  // 0.15




#ifdef CLOUD_SHADOW
uniform sampler2D	u_cloudshadow_tex;
uniform float		u_cloudshadow_intensity;
uniform vec2		u_cloudshadow_offset;

in vec2 v_cloudUv;
#endif

out vec4 FragColor;

vec3 rnoise( float scale, float intensity, float speed )
{
	vec3 Ntx0 = (texture( normalTex, (v_texCoord0 + vec2(-0.25, 1) * u_time * speed) * scale ).rgb - 0.5) * 2.;
	vec3 Ntx1 = (texture( normalTex, (v_texCoord0 + vec2( 0.25, 1) * u_time * speed + vec2(0.25, 0.25)) * scale ).rgb - 0.5) * 2.;
	vec3 Ntx = (Ntx0 + Ntx1) * .5;
	Ntx.xyz *= intensity;
	return Ntx;
}

float sstep( float m, float d, float x )
{
	if ( x < m - d ) return 0.;
	if ( x > m + d ) return 1.;
	return smoothstep( m - d, m + d, x );
}


void main (void)
{

	vec3 Ntx = vec3(0.);
	Ntx += rnoise( u_river_wave_0_scale, u_river_wave_0_intensity, u_river_wave_0_speed );
	Ntx += rnoise( u_river_wave_1_scale, u_river_wave_1_intensity, u_river_wave_1_speed );

	Ntx = normalize(Ntx);

	vec3 Nv = v_tangent0 * Ntx.r + v_tangent1 * Ntx.g + v_normal * Ntx.b;

	const float n2 = 1.333;
	float R0 = u_water_R0;
	vec3 V = normalize(-v_vCoord);

	// Reflection/Surface color
	vec3 ref;
	{
		float ctheta_V = max( 0., dot( V, Nv ) );
		float R_V = R0 + (1. - R0) * (1. - ctheta_V);
		ref = mix( u_water_col, u_water_colRefl, R_V );
	}

	// Specular
	vec3 s1;
	{
		vec3 ld = vec3( -u_lightDirView.x, -u_lightDirView.y, -u_lightDirView.z );
		vec3 H = normalize( V + ld );
		float ctheta_H = max( 0.,  dot( H, Nv ) );
		float R_H = R0 + (1. - R0) * (1. - ctheta_H);
		s1 = u_diffuseLight * pow( ctheta_H, u_water_pow ) * u_water_spec;
		s1 *= R_H;
	}

	// Foam
	float fw;
	{
		float x = 1. - (1. - abs( v_texCoord0.x - 0.5 ) * 2. );
		float alpha = x * u_foam_wave_scale + u_time * u_foam_wave_speed + u_foam_wave_offset;
		fw = sin(alpha) * u_foam_wave_intensity;
		fw = x * u_foam_base_mul + fw + Ntx.x * rnoise( u_foam_distort_scale, u_foam_distort_intensity * 100., u_foam_distort_speed ).x;
		fw *= pow( x, u_foam_fade_pow );
		fw = sstep(u_foam_ramp_bias, u_foam_ramp_smoothing, fw);
	}

	vec3 light;
#ifdef CLOUD_SHADOW
	{
		float shad = texture(u_cloudshadow_tex, v_cloudUv + Ntx.xy * 0.05).r;
		shad = pow( shad, 8. );
		shad = 1. - ((1. - shad) * u_cloudshadow_intensity);
		light = mix( u_shadowLight, u_diffuseLight, shad );
		//light = vec3(1.) * shad;
	}
#endif

	vec3 w = (ref + s1) * light;

	FragColor = vec4( mix( w, u_foam_color.rgb, fw * u_foam_color.a ), 1.0 );

}
