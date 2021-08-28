#ifdef GL_ES
precision highp float;
precision mediump sampler2DShadow;
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
uniform float u_time;
in vec3 v_vCoord;
in vec2 v_wpos;
in vec3 v_mpos;

uniform vec3 u_lightDirView;
uniform vec3 u_diffuseLight;
uniform vec3 u_shadowLight;

// Tweakables
uniform vec3 u_water_col;
uniform vec3 u_water_colRefl;
uniform float u_water_spec;
uniform float u_water_pow;
uniform float u_water_R0;

uniform float u_foam_base_mul;
uniform float u_water_wave_0_scale;
uniform float u_water_wave_0_intensity;
uniform float u_water_wave_1_scale;
uniform float u_water_wave_1_intensity;
uniform float u_water_wave_2_scale;
uniform float u_water_wave_2_intensity;
uniform float u_water_wave_speed;


#ifdef CLOUD_SHADOW
uniform sampler2D	u_cloudshadow_tex;
uniform float		u_cloudshadow1_intensity;

in vec2 v_cloudUv;
#endif

out vec4 FragColor;

// Shadow Mapping
uniform sampler2DShadow shadowmap;
uniform mat4 u_shadowProjectionView;


vec3 wnoise( float scale, float intensity, float speed )
{
	//vec3 Ntx0 = (texture( normalTex, (v_texCoord0 + vec2(1, 0) * u_time * 0.025) * scale ).rgb - 0.5) * 2.;
	//vec3 Ntx1 = (texture( normalTex, (v_texCoord0 - vec2(0, 1) * u_time * 0.025) * scale + vec2(0.25, 0.5) ).rgb - 0.5) * 2.;
	vec3 Ntx0 = (texture( normalTex, (-v_wpos.xy * 0.0075 + vec2(1, 0) * u_time * 0.005 * speed) * scale ).rgb - 0.5) * 2.;
	vec3 Ntx1 = (texture( normalTex, (-v_wpos.xy * 0.0075 - vec2(0, 1) * u_time * 0.005 * speed) * scale + vec2(0.25, 0.5) ).rgb - 0.5) * 2.;
	vec3 Ntx = (Ntx0 + Ntx1) * 0.5;
	Ntx.xyz *= intensity;
	return Ntx;
}

vec3 wnoise2( float mgn, float i, float speed )
{
	return wnoise( pow( 2., mgn ), pow( 2., i ), speed );
}

void main (void)
{
	vec3 Ntx = vec3(0.);
	Ntx += wnoise2( u_water_wave_0_scale, u_water_wave_0_intensity, 5.0 * u_water_wave_speed );
	Ntx += wnoise2( u_water_wave_1_scale, u_water_wave_1_intensity, 1.0 * u_water_wave_speed );
	Ntx += wnoise2( u_water_wave_2_scale, u_water_wave_2_intensity, 1.0 * u_water_wave_speed );

	Ntx = normalize(Ntx);

	vec3 Nv = v_tangent0 * Ntx.r + v_tangent1 * Ntx.g + v_normal * Ntx.b;

	const float n2 = 1.333;
	//const float R0 = ((1. - n2) / (1. + n2)) * ((1. - n2) / (1. + n2));
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

	float light = 1.0;
#ifdef CLOUD_SHADOW
	{
		float shad = texture(u_cloudshadow_tex, v_cloudUv + Ntx.xy * 0.05).r;
		shad = 1. - ((1. - shad) * u_cloudshadow1_intensity);
		//light = mix( u_shadowLight, u_diffuseLight, shad );
		light *= shad;
		//light = vec3(1.) * shad;
	}
#endif

#ifdef SHADOWMAP
	{
		float margin = 0.0;
		vec4 v_shadowPosition0 = u_shadowProjectionView * vec4(v_mpos + vec3( Ntx.xy * 30., Ntx.z ), 1.0);
		vec4 shadowPos0 = v_shadowPosition0 - vec4(0, 0, margin, 0);
		float shadowSample = texture(shadowmap, shadowPos0.xyz);
		shadowSample = 1. - ((1. - shadowSample) * .5);
		light *= shadowSample;
	}
#endif

	vec3 lightc = mix( u_shadowLight, u_diffuseLight, light );

	FragColor = vec4( (ref + s1) * lightc, 1.0 );
}
