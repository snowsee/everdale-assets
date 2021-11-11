#ifdef GL_ES
precision highp float;
precision mediump sampler2DShadow;
#else
#define highp 
#define mediump 
#define lowp 
#endif

//#define RIMLIGHT

uniform float u_time;

in vec2 v_texCoord0;
#ifdef USE_TERRAIN_UVS
in vec2 v_texCoord0_far;
#endif

#ifdef LIGHTMAP
in vec2 v_texCoordLightmap;
#endif
#ifdef SHADOWMAP
	in vec4 v_shadowPosition0;
	#ifdef SHADOWMAP_PCF
		in vec4 v_shadowPosition1;
		in vec4 v_shadowPosition2;
		in vec4 v_shadowPosition3;
		#ifdef QUALITY_CHARACTER
			in vec4 v_shadowPosition4;
			in vec4 v_shadowPosition5;
		#endif
	#endif
#endif
#ifdef STENCIL
in vec2 v_texCoordStencil;
#endif
in highp vec3 v_wnormal;
in highp vec3 v_normal;
in highp vec3 v_vpos;

#ifdef VERTEX_COLOR
in vec4 v_color;
#endif

#ifdef COLORIZE_EMISSION_VERTEX
in vec3 v_colorize;
in vec3 v_emission;
#endif

uniform mat4 u_viewInv;
uniform mat4 u_view;

#ifdef SHADOWMAP
	#ifdef SHADOWMAP_PCF
		uniform float u_shadowPcfEdgeSharpness;
	#endif
#endif

#ifdef CLOUD_SHADOW
uniform sampler2D	u_cloudshadow_tex;

uniform float		u_cloudshadow1_intensity;
in vec2 v_cloudUv1;

uniform float		u_cloudshadow2_intensity;
in vec2 v_cloudUv2;
#endif

#ifdef AMBIENT
uniform mediump vec4 u_ambient;
#endif
#ifdef DIFFUSE_COLOR
uniform mediump vec4 u_diffuse;
#endif
#ifdef DIFFUSE_TEX
uniform sampler2D diffuseTex;
#endif
#ifdef STENCIL
uniform sampler2D stencilTex;
#endif
//#ifdef COLORIZE_COLOR
uniform mediump vec4 u_colorize;
//#endif
#ifdef COLORIZE_TEX
uniform sampler2D colorizeTex;
#endif
#ifdef SPECULAR_COLOR
uniform mediump vec4 u_specular;
#endif
#ifdef SPECULAR_TEX
uniform sampler2D specularTex;
#endif
//#ifdef EMISSION_COLOR
uniform mediump vec4 u_emission;
//#endif
#ifdef EMISSION_TEX
uniform sampler2D emissionTex;
#endif
//#ifdef OPACITY_VALUE
uniform mediump float u_opacity;
//#endif
#ifdef OPACITY_TEX
uniform sampler2D opacityTex;
#endif

uniform vec3 u_shadowLight;
uniform vec2 u_lightBias;
uniform float u_shadowIntensity;
uniform vec3 u_diffuseLight;

#ifdef RIMLIGHT
uniform vec3 u_rimlight_color;
uniform float u_rimlight_pow;
uniform float u_rimlight_bias;
uniform float u_rimlight_angle;
uniform vec2 u_rimlight_yaw_r;
#endif

#ifdef ENABLE_LIGHT
uniform vec3 u_lightDirView;
#endif

#ifdef LIGHTMAP_AMBIENT
uniform sampler2D lightmapAmbient;
#endif
#ifdef LIGHTMAP_SPECULAR
uniform sampler2D lightmapSpecular;
#endif
#ifdef SHADOWMAP
uniform sampler2DShadow shadowmap;
#endif

#ifdef SUPPORTED_GL_OES_30
	#ifdef COLORTRANSFORM_MUL
	in mediump vec4 v_colorMul;
	#define uv_colorMul v_colorMul
	#endif
	#ifdef COLORTRANSFORM_ADD
	in mediump vec4 v_colorAdd;
	#define uv_colorAdd v_colorAdd
	#endif
#else
	#ifdef COLORTRANSFORM_MUL
	uniform mediump vec4 u_colorMul;
	#define uv_colorMul u_colorMul
	#endif
	#ifdef COLORTRANSFORM_ADD
	uniform mediump vec4 u_colorAdd;
	#define uv_colorAdd u_colorAdd
	#endif
#endif

#ifdef COLOR_CORRECT
uniform vec3 u_col_mul;
uniform vec3 u_gamma;
#endif

#ifdef USE_TERRAIN_UVS
uniform float u_terrainuv_scale;
#endif

#ifdef CUTOUT
uniform lowp float u_cutout;
#endif

out vec4 FragColor;

// Source: https://github.com/zzorn/pipedream/blob/master/assets/shaders/ShaderUtils.glsl
float sigmoid2(float x, float sharpness) {
  if (x >= 1.0) return 1.0;
  else if (x <= -1.0) return -1.0;
  else {
    if (sharpness < 0.0) sharpness -= 1.0;

    if (x > 0.0) return sharpness * x / (sharpness - x + 1.0);
    else if (x < 0.0) return sharpness * x / (sharpness - abs(x) + 1.0);
    else return 0.0;
  }
}

void main (void)
{

	vec3 light = vec3(0.0);
#ifndef DIFFUSE_COLOR
  #ifndef DIFFUSE_TEX
	vec4 color = vec4(0.0);
  #endif
#endif
#ifdef DIFFUSE_COLOR
	vec4 color = u_diffuse;
#endif


#ifdef DIFFUSE_TEX
  #ifdef COMBINE_DIFFUSE_AND_SPECULAR
	vec4 diffuseColor = texture(diffuseTex, v_texCoord0);
	vec4 color = diffuseColor;
  #endif
  #ifndef COMBINE_DIFFUSE_AND_SPECULAR
	vec4 color = texture(diffuseTex, v_texCoord0);
  #endif
#endif

#ifdef USE_TERRAIN_UVS
	color = mix( color, texture(diffuseTex, v_texCoord0_far), u_terrainuv_scale );
#endif

#ifdef ENABLE_LIGHT
	float L = clamp( dot(-u_lightDirView, v_normal) + u_lightBias.y, 0.0, 1.0 );
	L = clamp( L / (1.0 - u_lightBias.x), 0.0, 1.0 );

	light = vec3(1.00) * L;
	//light = vec3(1.00);
#else
	light = vec3(1.00);
#endif

	//FragColor = vec4( v_normal.xyz, 1. );
	//return;

#ifdef VERTEX_COLOR
	color *= v_color;
#endif

//#ifdef COLORIZE_COLOR
	color *= u_colorize;
//#endif
#ifdef COLORIZE_EMISSION_VERTEX
	color *= vec4( v_colorize.rgb, 1.0 );
#endif


#ifdef COLORIZE_TEX
	color *= texture(colorizeTex, v_texCoord0);
#endif

#ifdef STENCIL
	vec4 stencilColor = texture(stencilTex, v_texCoordStencil);
	color = vec4(color.rgb * (1.0 - stencilColor.a) + stencilColor.rgb, color.a);
#endif

#ifdef EMISSION_TEX
	color.rgb += texture(emissionTex, v_texCoord0).rgb;
#endif
//#ifdef EMISSION_COLOR
	color += vec4( u_emission.rgb, 0);
//#endif
#ifdef COLORIZE_EMISSION_VERTEX
	color += vec4( v_emission.rgb, 0 );
#endif

	// Prevent emission from burning the color
	color = min( vec4(1.,1.,1.,1.), color );

#ifdef LIGHTMAP_SPECULAR
  #ifdef SPECULAR_TEX
    #ifdef COMBINE_DIFFUSE_AND_SPECULAR
	color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * diffuseColor.rgb;
    #else
	color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * texture(specularTex, v_texCoord0).rgb;
    #endif
  #endif
  #ifndef SPECULAR_TEX
    #ifdef SPECULAR_COLOR
	  color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * u_specular.rgb;
	#else
	  color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb;
    #endif
  #endif
#endif // LIGHTMAP_SPECULAR

	vec3 shadowLight = (u_shadowLight) * dot(light, light) * 0.1;
	float shadow = 1.0;

#ifdef SHADOWMAP
	float shadowSample = texture(shadowmap, v_shadowPosition0.xyz);

	#ifdef SHADOWMAP_PCF
	shadowSample +=      texture(shadowmap, v_shadowPosition1.xyz);
	shadowSample +=      texture(shadowmap, v_shadowPosition2.xyz);
	shadowSample +=      texture(shadowmap, v_shadowPosition3.xyz);
	#ifdef QUALITY_CHARACTER
		shadowSample +=      texture(shadowmap, v_shadowPosition4.xyz);
		shadowSample +=      texture(shadowmap, v_shadowPosition5.xyz);
	#endif
	
	// Quick n' dirty adding samples for nicer photo shadows
	#ifdef QUALITY_PHOTOMODE
		float w = 2.0f / 1024.0f;
		shadowSample +=      texture(shadowmap, v_shadowPosition0.xyz + vec3(1,0,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition1.xyz + vec3(1,0,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition2.xyz + vec3(1,0,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition3.xyz + vec3(1,0,0) * w );
		#ifdef QUALITY_CHARACTER
			shadowSample +=      texture(shadowmap, v_shadowPosition4.xyz + vec3(1,0,0) * w );
			shadowSample +=      texture(shadowmap, v_shadowPosition5.xyz + vec3(1,0,0) * w );
		#endif

		shadowSample +=      texture(shadowmap, v_shadowPosition0.xyz + vec3(0,1,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition1.xyz + vec3(0,1,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition2.xyz + vec3(0,1,0) * w );
		shadowSample +=      texture(shadowmap, v_shadowPosition3.xyz + vec3(0,1,0) * w );
		#ifdef QUALITY_CHARACTER
			shadowSample +=      texture(shadowmap, v_shadowPosition4.xyz + vec3(0,1,0) * w );
			shadowSample +=      texture(shadowmap, v_shadowPosition5.xyz + vec3(0,1,0) * w );
			shadowSample *= 1.0/18.0;
		#else
			shadowSample *= 1.0/12.0;
		#endif
	#else
		#ifdef QUALITY_CHARACTER
			shadowSample *= 1.0/6.0;
		#else
			shadowSample *= 1.0/4.0;
		#endif
	#endif



	shadowSample = (sigmoid2( (shadowSample - 0.5) * 2.0, -u_shadowPcfEdgeSharpness ) + 1.0) * 0.5;
	#endif

	shadowSample = mix(1.0, shadowSample, smoothstep( 0.0, 0.05, v_shadowPosition0.x ) * smoothstep( 0.0, 0.05, v_shadowPosition0.y ) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.x )) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.y )));

	#ifdef FORCE_REALTIME_LIGHTING
	shadowSample = 1.0 - ((1.0 - shadowSample) * 0.9);
	#endif

	//shadowSample = 1.0 - ((1.0 - shadowSample) * 0.5);

	light *= shadowSample;

	//light = mix( vec3(0,0,0), vec3(1,0,0), smoothstep( 0.0, 0.05, v_shadowPosition0.x ) * smoothstep( 0.0, 0.05, v_shadowPosition0.y ) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.x )) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.y )));

#endif

#ifdef AMBIENT
	light += u_ambient.rgb;
#endif

	light = 1. - ((1. - light) * u_shadowIntensity);

#ifdef CLOUD_SHADOW
	{
		float shad = texture(u_cloudshadow_tex, v_cloudUv1).r;
		shad = 1. - ((1. - shad) * u_cloudshadow1_intensity);
		light *= shad;
	}
	{
		float shad = texture(u_cloudshadow_tex, v_cloudUv2).r;
		shad = 1. - ((1. - shad) * u_cloudshadow2_intensity);
		light *= shad;
	}
#endif


#ifdef FORCE_REALTIME_LIGHTING
	color.rgb = mix(u_shadowLight, u_diffuseLight, light);
#else
	#ifdef ENABLE_LIGHT
		color.rgb *= mix(u_shadowLight, u_diffuseLight, light);
	#else
		color.rgb *= mix(u_shadowLight, vec3(1,1,1), light);
	#endif
#endif

#ifdef RIMLIGHT
	vec3 upview = normalize(u_view[2].xyz);
	vec3 ldir0  = normalize( -v_vpos );
	vec3 ldir1  = normalize( ldir0 - upview * dot( upview, ldir0 ) );
	ldir1 = mix( ldir1, ldir0, u_rimlight_angle );
	vec3 ldir2  = vec3( ldir1.x * u_rimlight_yaw_r.x - ldir1.z * u_rimlight_yaw_r.y, ldir1.y, ldir1.x * u_rimlight_yaw_r.y + ldir1.z * u_rimlight_yaw_r.x );	

	float rl = dot( normalize(v_normal), ldir2 );
	rl+= u_rimlight_bias;
	rl = min( 1., max( 0., rl ));
	rl = pow( 1. - rl, u_rimlight_pow );

	color.rgb += u_rimlight_color * rl;

#endif

#ifdef COLORTRANSFORM_MUL
  #ifdef COLORTRANSFORM_ADD
    #define COLORTRANSFORM_MUL_AND_ADD
  #endif
#endif

#ifdef COLORTRANSFORM_MUL_AND_ADD
	color = (color * vec4(uv_colorMul.rgb, 1.0)) + (uv_colorAdd * color.a);
#endif
#ifndef COLORTRANSFORM_MUL_AND_ADD
  #ifdef COLORTRANSFORM_MUL
	color *= uv_colorMul;
  #endif
#endif
#ifndef COLORTRANSFORM_MUL_AND_ADD
  #ifdef COLORTRANSFORM_ADD
	color += uv_colorAdd * color.a;
	//color.rgb += u_colorAdd.rgb * color.a;
  #endif
#endif // mul & add

//#ifdef OPACITY_VALUE
	color.a *= u_opacity;
//#endif

#ifdef OPACITY_TEX
	#ifdef BLEND_MODE_4
		color.a *= texture(opacityTex, v_texCoord0).b;
	#else
		color *= texture(opacityTex, v_texCoord0).b;
	#endif
#endif

#ifdef COLOR_CORRECT
	color = vec4(u_col_mul * pow(color.rgb, u_gamma), color.a);
#endif

#ifdef CUTOUT
	if (color.a < u_cutout) {
		discard;
	}
#endif

	FragColor = color;
}
