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
in vec2 a_uv1;

#ifdef VERTEX_COLOR
//attribute vec4 a_color;
in float a_color;
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

uniform mat4 u_projectionView;
uniform mat4 u_view;
#ifdef SHADOWMAP
uniform mat4 u_shadowProjectionView;
#endif

out vec2 v_texCoord0;
out vec2 v_texCoord1;
#ifdef LIGHTMAP
out vec2 v_texCoordLightmap;
#endif
#ifdef SHADOWMAP
	out vec4 v_shadowPosition0;
	#ifdef SHADOWMAP_PCF
		out vec4 v_shadowPosition1;
		out vec4 v_shadowPosition2;
		out vec4 v_shadowPosition3;
		out vec4 v_shadowPosition4;
		out vec4 v_shadowPosition5;
	#endif
#endif
#ifdef STENCIL
uniform vec4 u_stencilScaleOffset;
out vec2 v_texCoordStencil;
#endif
out highp vec3 v_normal;

#ifdef VERTEX_COLOR
out vec4 v_color;
#endif

out vec3 v_wpos;
out vec3 v_wnormal;
out float v_textureWeight;

void main(void)
{
	vec4 pos = a_model * a_pos;

	v_texCoord0 = a_uv0;
	v_texCoord1 = a_uv1;

	v_normal = normalize(vec3(u_view * (a_model * vec4(a_normal, 0.0))));
#ifdef LIGHTMAP
	v_texCoordLightmap = v_normal.xy * vec2(0.5, -0.5) + vec2(0.5, 0.5);
#endif
#ifdef SHADOWMAP
	#ifdef SHADOWMAP_PCF
		// static poisson disc sample positions
		const vec4 smScale = vec4( 2.0 / 1024.0, 2.0 / 1024.0, 0, 0 );
		vec4 shadowPosition = u_shadowProjectionView * pos;
		v_shadowPosition0 = shadowPosition + smScale * vec4( -0.030686, -0.004183, 0, 0 );
		v_shadowPosition1 = shadowPosition + smScale * vec4( -0.027215,  0.809542, 0, 0 );
		v_shadowPosition2 = shadowPosition + smScale * vec4(  0.787919,  0.197890, 0, 0 );
		v_shadowPosition3 = shadowPosition + smScale * vec4( -0.631026, -0.571681, 0, 0 );
		v_shadowPosition4 = shadowPosition + smScale * vec4( -0.823725,  0.275209, 0, 0 );
		v_shadowPosition5 = shadowPosition + smScale * vec4(  0.665517, -0.678829, 0, 0 );
	#else
		v_shadowPosition0 = u_shadowProjectionView * pos;
	#endif
#endif
#ifdef STENCIL
	v_texCoordStencil = a_uv0 * u_stencilScaleOffset.xy + u_stencilScaleOffset.zw;
#endif
#ifdef VERTEX_COLOR
	v_color = vec4(1,1,1,1) * a_color;
#endif

#ifdef SUPPORTED_GL_OES_30
	#ifdef COLORTRANSFORM_MUL
		v_colorMul = a_colorMul;
	#endif
	#ifdef COLORTRANSFORM_ADD
		v_colorAdd = a_colorAdd;
	#endif	
#endif

/*
#ifdef VERTEX_COLOR
	v_textureWeight = a_color;
#else
	v_textureWeight = 1.0;
#endif
*/
	v_textureWeight = 1.0;

	v_wpos = pos.xyz;
	v_wnormal = normalize( (a_model * vec4(a_normal, 0.0)).xyz );

	gl_Position = u_projectionView * pos;
}
