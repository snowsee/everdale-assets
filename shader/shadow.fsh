#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec2 v_texCoord0;

#ifdef OPACITY_TEX
uniform sampler2D opacityTex;
#endif

out vec4 FragColor;

void main (void)
{
#ifdef OPACITY_TEX
	if ((texture(opacityTex, v_texCoord0).b) < 0.2) {
		discard;
	}
#endif
	FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
