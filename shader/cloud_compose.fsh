#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

uniform sampler2D diffuseTex;	// cloud intermediate buffer diffuse texure
uniform sampler2D colorizeTex;	// cloud intermediate buffer depth texure
uniform sampler2D normalTex;	// backbuffer depth texure

in vec2 v_texCoord0;

//uniform float offset[5] = float[]( 0.0, 0.01, 0.02, 0.03, 0.03 );
//uniform float weight[5] = float[]( 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 );

// blur kernel
const vec2 offset[9] = vec2[]( 
								vec2(-0.01, -0.01), vec2(0.0, -0.01), vec2(0.01, -0.01), 
								vec2(-0.01, 0.0), vec2(0.0, -0.01), vec2(0.01, 0.0), 
								vec2(-0.01, 0.01), vec2(0, 0.01), vec2(0.01, 0.01)
								);

const float weight[9] = float[]( 
								1.0/9.0, 1.0/9.0, 1.0/9.0, 
								1.0/9.0, 1.0/9.0, 1.0/9.0, 
								1.0/9.0, 1.0/9.0, 1.0/9.0
								);

void main (void)
{
	//vec4 fogColor = texture2D( diffuseTex, v_texCoord0 );


    //vec4 fogColor = texture2D( diffuseTex, v_texCoord0 ) * weight[0];
	vec4 fogColor; //( 0.0, 0.0, 0.0, 0.0 );
    for( int i = 0; i < 9; i++ )
	{
        fogColor += texture2D( diffuseTex, ( vec2(v_texCoord0) + offset[i]*0.125f ) ) * weight[i];
    }


	//float cloudDepth = texture2D( colorizeTex, v_texCoord0 ).x;
	//float cloudDepth; //( 0.0, 0.0, 0.0, 0.0 );
    //for( int i = 0; i < 9; i++ )
	//{
    //    cloudDepth += texture2D( colorizeTex, ( vec2(v_texCoord0) + offset[i]*0.125f ) ).x * weight[i];
    //}
	//
	//float backBufferDepth = texture2D( normalTex, v_texCoord0 ).x;
	//if( cloudDepth < backBufferDepth )
		fogColor.a *= 2.0f;
	//else
	//	fogColor.a = 0.0f;

	gl_FragColor = fogColor;
}
