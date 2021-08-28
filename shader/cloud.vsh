#ifdef GL_ES
precision highp float;
#else
#define highp
#define mediump
#define lowp
#endif

attribute vec4 a_pos;
attribute vec2 a_uv0;
//attribute float a_color;

#ifdef SUPPORTED_GL_OES_30
attribute mat4 a_model;
#else
uniform mat4 u_model;
#define a_model u_model
#endif

varying vec2 v_texCoord0;
//varying float v_color;

uniform mat4 u_projectionView;

uniform float u_sineTime;
uniform float u_sinePeriod;
uniform float u_sineMag;

void main(void)
{
	v_texCoord0 = a_uv0;
	//v_color = a_color;

	float sine = u_sineMag * ( sin( u_sineTime / ( u_sinePeriod + mod( a_pos.y, 13.0 ) / 13.0 ) + a_pos.x ) - 0.5 );

	gl_Position = u_projectionView * ( a_model * vec4( a_pos.x + sine, a_pos.y + sine, a_pos.z, a_pos.w ) );
	//gl_Position = u_projectionView * ( a_model * vec4( a_pos.x, a_pos.y, a_pos.z, a_pos.w ) );
}
