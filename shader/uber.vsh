#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec4 a_pos;
in vec2 a_uv0;
in vec3 a_normal;

#ifdef VERTEX_COLOR
in vec4 a_color;
#endif

#ifdef SUPPORTED_GL_OES_30
	in mat4 a_model;

	#ifdef COLORTRANSFORM_MUL
		in vec4 a_colorMul;
		out lowp vec4 v_colorMul;
	#endif
	#ifdef COLORTRANSFORM_ADD
		in vec4 a_colorAdd;
		out lowp vec4 v_colorAdd;
	#endif	
#else
	uniform mat4 u_model;
	#define a_model u_model
#endif

#ifdef SHADOWMAP
	#ifdef SHADOWMAP_PCF
		uniform float u_shadowPcfScale;
	#endif
#endif

uniform mat4 u_projectionView;
uniform mat4 u_view;
#ifdef SHADOWMAP
uniform mat4 u_shadowProjectionView;
#endif

out vec2 v_texCoord0;

#ifdef USE_TERRAIN_UVS
out vec2 v_texCoord0_far;
uniform float u_terrainuv_farUvScale;
#endif

#ifdef LIGHTMAP
out vec2 v_texCoordLightmap;
#endif
#ifdef SHADOWMAP
	out vec4 v_shadowPosition0;
	#ifdef SHADOWMAP_PCF
		out vec4 v_shadowPosition1;
		out vec4 v_shadowPosition2;
		out vec4 v_shadowPosition3;
		//out vec4 v_shadowPosition4;
		//out vec4 v_shadowPosition5;
	#endif
#endif
#ifdef STENCIL
uniform vec4 u_stencilScaleOffset;
out vec2 v_texCoordStencil;
#endif
out highp vec3 v_normal;
out highp vec3 v_vpos;

//uniform mat4		u_world;
uniform vec4 u_world_tf; // translate + scale
#ifdef CLOUD_SHADOW
uniform float		u_cloudshadow1_scale;
uniform vec2		u_cloudshadow1_offset;
uniform vec2		u_cloudshadow1_rot_sc;
out		vec2		v_cloudUv1;

uniform float		u_cloudshadow2_scale;
uniform vec2		u_cloudshadow2_offset;
uniform vec2		u_cloudshadow2_rot_sc;
out		vec2		v_cloudUv2;


#endif

#ifdef VERTEX_COLOR
out vec4 v_color;
#endif

#ifdef COLORIZE_EMISSION_VERTEX

in vec4 a_color;
in vec4 a_uv1;

out vec3 v_colorize;
out vec3 v_emission;
#endif



// using #if defined(...) causes some warning spam
#ifdef ANIM_BIRD
uniform float u_time;
#endif
#ifdef ANIM_FOLIAGE
uniform float u_time;
#endif

void main(void)
{
	#ifdef ANIM_BIRD

	float anim_w = abs(a_pos.x);
	float ampl = (sin(u_time * 0.5) + 1.f) * 0.5;
	float sine = sin(u_time * 7.5);
	float ofs_z = sign(sine) * pow( abs(sine), 0.65f ) * anim_w * 0.5 * ampl;
	vec4 pos = a_model * (a_pos + vec4(0,0,1,0) * ofs_z);

	#else

	vec4 pos = a_model * a_pos;

	#ifdef ANIM_FOLIAGE
	// large wobble
	{
		float ampl = (sin( pos.y * 0.025 + u_time * 0.5) + 1.0) * 0.75 + 1.0;
		float freq = (sin( pos.y * 0.05 + u_time * 1.5) + 1.0) * 0.25 + 1.0;
		float phase = mod( a_model[3].x * 10000.0, 7.0 ) + mod( a_model[3].y * 10000.0, 7.0 );
		float anim_w = max( 0.0, min( 0.5, a_pos.z * 0.125 ) ) * 0.2f * ampl;
		float alpha = u_time * 0.75 + phase;
		pos += vec4(0.0,1.0,0.0,0.0) * sin( alpha ) * anim_w;
	}
	// small wobble
	{
		float ampl = (sin( pos.x * 7.0 + pos.y * 9.0 + u_time * 6.5) + 1.0) * 0.5 + 1.0;
		float freq = (sin( pos.y * 0.05 + u_time * 1.5) + 1.0) * 0.5 + 1.0;
		float phase = mod( a_model[3].x * 10000.0, 7.0 ) + mod( a_model[3].y * 10000.0, 7.0 );
		float anim_w = max( 0.0, min( 0.5, a_pos.z * 0.125 ) ) * 0.2f * ampl * a_color.r;
		float alpha = u_time * 0.75 + phase;
		pos += vec4(0.0,0.0,1.0,0.0) * sin( alpha ) * anim_w;
	}
	#endif

	#endif




	vec3 wpos = pos.xyz * u_world_tf.w + u_world_tf.xyz;
	{
		#ifdef USE_TERRAIN_UVS
		// Global world coordinate
		v_texCoord0 = wpos.xy / 8.0f;
		v_texCoord0_far = wpos.xy / 8.0f * u_terrainuv_farUvScale;
		#else
		v_texCoord0 = a_uv0;
		#endif
	}

	//v_wnormal = normalize( vec3( (a_model * vec4( a_normal, 0.0 )) ) );
	#ifdef USE_TERRAIN_UVS
		v_normal = normalize(vec3(u_view * (a_model * vec4(0.0, 0.0, 1.0, 0.0))));
	#else
		v_normal = normalize(vec3(u_view * (a_model * vec4(a_normal, 0.0))));
	#endif
#ifdef LIGHTMAP
	v_texCoordLightmap = v_normal.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5);
#endif
#ifdef SHADOWMAP
	#ifdef SHADOWMAP_PCF
		// static poisson disc sample positions
		vec4 shadowPosition = u_shadowProjectionView * pos;
		vec4 smScale = vec4( 1.0 / 1024.0, 1.0 / 1024.0, 0, 0 ) * u_shadowPcfScale;
		v_shadowPosition0 = shadowPosition + smScale * vec4( -0.030686, -0.004183, 0, 0 );
		v_shadowPosition1 = shadowPosition + smScale * vec4( -0.027215,  0.809542, 0, 0 );
		v_shadowPosition2 = shadowPosition + smScale * vec4(  0.787919,  0.197890, 0, 0 );
		v_shadowPosition3 = shadowPosition + smScale * vec4( -0.631026, -0.571681, 0, 0 );
		//v_shadowPosition4 = shadowPosition + smScale * vec4( -0.823725,  0.275209, 0, 0 );
		//v_shadowPosition5 = shadowPosition + smScale * vec4(  0.665517, -0.678829, 0, 0 );
	#else
		v_shadowPosition0 = u_shadowProjectionView * pos;
	#endif
#endif
#ifdef STENCIL
	v_texCoordStencil = a_uv0 * u_stencilScaleOffset.xy + u_stencilScaleOffset.zw;
#endif
#ifdef VERTEX_COLOR
	v_color = a_color;
#endif

#ifdef SUPPORTED_GL_OES_30
	#ifdef COLORTRANSFORM_MUL
		v_colorMul = a_colorMul;
	#endif
	#ifdef COLORTRANSFORM_ADD
		v_colorAdd = a_colorAdd;
	#endif	
#endif

#ifdef CLOUD_SHADOW
	v_cloudUv1 = vec2( wpos.x, wpos.y );
	v_cloudUv1 *= u_cloudshadow1_scale;
	v_cloudUv1 += u_cloudshadow1_offset;
	v_cloudUv1 = vec2( v_cloudUv1.x * u_cloudshadow1_rot_sc.x - v_cloudUv1.y * u_cloudshadow1_rot_sc.y, v_cloudUv1.x * u_cloudshadow1_rot_sc.y + v_cloudUv1.y * u_cloudshadow1_rot_sc.x );

	v_cloudUv2 = vec2( wpos.x, wpos.y );
	v_cloudUv2 *= u_cloudshadow2_scale;
	v_cloudUv2 += u_cloudshadow2_offset;
	v_cloudUv2 = vec2( v_cloudUv2.x * u_cloudshadow2_rot_sc.x - v_cloudUv2.y * u_cloudshadow2_rot_sc.y, v_cloudUv2.x * u_cloudshadow2_rot_sc.y + v_cloudUv2.y * u_cloudshadow2_rot_sc.x );
#endif

#ifdef COLORIZE_EMISSION_VERTEX
	v_colorize.rgb = a_color.rgb;
	v_emission.rgb = a_uv1.rgb;
#endif

	v_vpos = (u_view * vec4( pos.xyz, 1. )).xyz;
	gl_Position = u_projectionView * pos;
}
