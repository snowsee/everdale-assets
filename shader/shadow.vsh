#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec4 a_pos;
in vec2 a_uv0;

#ifdef SUPPORTED_GL_OES_30
in mat4 a_model;
#else
uniform mat4 u_model;
#define a_model u_model
#endif

uniform mat4 u_projectionView;

out vec2 v_texCoord0;

void main(void)
{
	gl_Position = u_projectionView * (a_model * a_pos);
	v_texCoord0 = a_uv0;
}
