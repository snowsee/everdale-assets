#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in float v_wheight;
out vec4 FragColor;

void main (void)
{
	if ( v_wheight < -10.0 ) {
		discard;
	}
	FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
