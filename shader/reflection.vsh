#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec4 a_pos;
in vec3 a_normal;
in vec2 a_uv0;

#ifdef SUPPORTED_GL_OES_30
in mat4 a_model;
#else
uniform mat4 u_model;
#define a_model u_model
#endif

uniform mat4 u_projectionView;
uniform mat4 u_view;

out float v_wheight;

void main(void)
{
	vec4 wpos = a_model * a_pos;
	vec4 wnormal = a_model * vec4( a_normal, 0.0 );
	wpos += wnormal * 1.5 * (wpos.z+10.0);

	v_wheight = wpos.z;
	//gl_Position = u_projectionView * (a_model * (posd));
	gl_Position = u_projectionView * wpos;
}
