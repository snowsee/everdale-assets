#ifdef GL_ES
precision highp float;
#else
#define highp 
#define mediump 
#define lowp 
#endif

#ifdef COLORIZE_COLOR
uniform mediump vec4 u_colorize;
#endif
#ifdef COLORTRANSFORM_MUL
uniform mediump vec4 u_colorMul;
#endif

uniform sampler2D diffuseTex;
uniform sampler2D opacityTex;

uniform lowp float u_viewportWidth;
uniform lowp float u_viewportHeight;
//uniform lowp float u_zFar;
uniform lowp float u_zNear;
uniform lowp float u_zNearOverFar;
uniform lowp float u_fogDepth;
//varying float v_color;

varying vec2 v_texCoord0;

float bufferZToEyeZ( float bufferZ )
{
	// optimized version of doing this:
	// float normalizedZ = 2.0*bufferZ - 1;
	// return 2.0*u_zNear*u_zFar / ( u_zFar + u_zNear - normalizedZ * ( u_zFar - u_zNear ) );

	return u_zNear / ( 1.0 - bufferZ + bufferZ*u_zNearOverFar );
}

void main (void)
{
	vec4 fogColor = texture2D( diffuseTex, v_texCoord0 );

	vec2 realTexCoord0 = vec2( gl_FragCoord.x / u_viewportWidth, gl_FragCoord.y / u_viewportHeight );
	float bufferZ = texture2D( opacityTex, realTexCoord0 ).x;
	float eyeZ = bufferZToEyeZ( bufferZ );
	float myEyeZ = bufferZToEyeZ( gl_FragCoord.z );

	//float differenceZ = clamp( ( eyeZ - myEyeZ ) / u_fogDepth, 0.0, 1.0 );
	
	fogColor.a = max(min(fogColor.a, (eyeZ - myEyeZ) / u_fogDepth), 0.0 );

#ifdef COLORIZE_COLOR
	fogColor *= u_colorize;
#endif

#ifdef COLORTRANSFORM_MUL
	fogColor *= u_colorMul;
#endif

	gl_FragColor = fogColor;
	//gl_FragColor = vec4( 0, fmod(v_texCoord0.x,1.0), fmod(v_texCoord0.y, 1.0), 1.0 );
}
