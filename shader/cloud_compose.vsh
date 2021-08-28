#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec4 a_pos;
in vec2 a_uv0;

out vec2 v_texCoord0;

void main(void)
{
	v_texCoord0 = a_uv0;
	gl_Position = a_pos;
}
