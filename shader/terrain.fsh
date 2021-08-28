#ifdef GL_ES
precision highp float;
precision mediump sampler2DShadow;
#else
#define highp 
#define mediump 
#define lowp 
#endif

in vec2 v_texCoord0;
in vec2 v_texCoord1;

#ifdef LIGHTMAP
in vec2 v_texCoordLightmap;
#endif
#ifdef SHADOWMAP
	in vec4 v_shadowPosition0;
	#ifdef SHADOWMAP_PCF
		in vec4 v_shadowPosition1;
		in vec4 v_shadowPosition2;
		in vec4 v_shadowPosition3;
		in vec4 v_shadowPosition4;
		in vec4 v_shadowPosition5;
	#endif
#endif
#ifdef STENCIL
in vec2 v_texCoordStencil;
#endif
in highp vec3 v_normal;

#ifdef VERTEX_COLOR
in vec4 v_color;
#endif

#ifdef AMBIENT
uniform mediump vec4 u_ambient;
#endif
#ifdef DIFFUSE_COLOR
uniform mediump vec4 u_diffuse;
#endif
#ifdef DIFFUSE_TEX
uniform sampler2D diffuseTex;
#endif
#ifdef STENCIL
uniform sampler2D stencilTex;
#endif
#ifdef COLORIZE_COLOR
uniform mediump vec4 u_colorize;
#endif
#ifdef COLORIZE_TEX
uniform sampler2D colorizeTex;
#endif
#ifdef SPECULAR_COLOR
uniform mediump vec4 u_specular;
#endif
#ifdef SPECULAR_TEX
uniform sampler2D specularTex;
#endif
#ifdef EMISSION_COLOR
uniform mediump vec4 u_emission;
#endif
#ifdef EMISSION_TEX
uniform sampler2D emissionTex;
#endif
#ifdef OPACITY_VALUE
uniform mediump float u_opacity;
#endif
#ifdef OPACITY_TEX
uniform sampler2D opacityTex;
#endif
#ifdef LIGHTMAP_DIFFUSE
uniform sampler2D lightmapDiffuse;
#endif


uniform vec3 u_shadowLight;
uniform vec3 u_diffuseLight;

#ifdef ENABLE_LIGHT
uniform vec3 u_lightDirView;
#endif

#ifdef LIGHTMAP_AMBIENT
uniform sampler2D lightmapAmbient;
#endif
#ifdef LIGHTMAP_SPECULAR
uniform sampler2D lightmapSpecular;
#endif
#ifdef SHADOWMAP
uniform sampler2DShadow shadowmap;
#endif

#ifdef SUPPORTED_GL_OES_30
	#ifdef COLORTRANSFORM_MUL
	in mediump vec4 v_colorMul;
	#define uv_colorMul v_colorMul
	#endif
	#ifdef COLORTRANSFORM_ADD
	in mediump vec4 v_colorAdd;
	#define uv_colorAdd v_colorAdd
	#endif
#else
	#ifdef COLORTRANSFORM_MUL
	uniform mediump vec4 u_colorMul;
	#define uv_colorMul u_colorMul
	#endif
	#ifdef COLORTRANSFORM_ADD
	uniform mediump vec4 u_colorAdd;
	#define uv_colorAdd u_colorAdd
	#endif
#endif


#ifdef CUTOUT
uniform lowp float u_cutout;
#endif

uniform sampler2D s_shadeMap;
uniform float shadeMapBrightenAmount;
uniform float shadeMapDarkenAmount;

out vec4 FragColor;


void main (void)
{

	vec3 light = vec3(0.0);
#ifndef DIFFUSE_COLOR
  #ifndef DIFFUSE_TEX
	vec4 color = vec4(0.0);
  #endif
#endif
#ifdef DIFFUSE_COLOR
	vec4 color = u_diffuse;
#endif





#ifdef OPACITY_TEX
	// multitexturing

	//vec2 opaUv = v_wpos.yx * vec2(-1,-1) * 0.001065 + vec2(0.475, 0.4875);
	//vec2 texelCoord = opaUv * 128 + vec2( 0.5, -0.5);

	//vec2 opaUv = (v_wpos.xy - vec2( -450, -350 )) / (vec2(142, 134) * 6);
	//vec2 texelCoord = opaUv * vec2(142, 134) + vec2( 0.5, 0.5);

	//vec2 texelCoord = (v_wpos.xy - vec2( -450, -350 )) / 6.0 + vec2(-0.5,0.5);
	vec2 texelCoord = (v_wpos.xy - vec2( -450, -350 )) / 3.0 + vec2(-0.5,0.5);
	//vec2 texCoord0 = v_wpos.xy / 8.0;
	vec2 texCoord0 = v_texCoord0;
	
	vec2 texelPoint = fract(texelCoord) - 0.5;

	float qx = texelPoint.x < 0. ? -1.0 : 1.0;
	float qy = texelPoint.y < 0. ? -1.0 : 1.0;

	// Fetch texture weight information of 2x2 block.
	vec4 idata = texelFetch( opacityTex, ivec2(texelCoord ), 0 );
	vec4 idatax = texelFetch( opacityTex, ivec2(texelCoord + vec2(qx, 0) ), 0 );
	vec4 idatay = texelFetch( opacityTex, ivec2(texelCoord + vec2(0, qy) ), 0 );
	vec4 idataxy = texelFetch( opacityTex, ivec2(texelCoord + vec2(qx, qy) ), 0 );

	// Proper bilinear sampling - 8 texture fetches --------------------------------
	float tx0 = floor(idata.r * 255.0 + 0.5);
	float tx1 = floor(idata.g * 255.0 + 0.5);
	vec4 d0 = texture( s_ground, vec3(v_texCoord0, tx0) );
	vec4 d1 = texture( s_ground, vec3(v_texCoord0, tx1) );

	float tx0x = floor(idatax.r * 255.0 + 0.5);
	float tx1x = floor(idatax.g * 255.0 + 0.5);
	vec4 d0x = texture( s_ground, vec3(v_texCoord0, tx0x) );
	vec4 d1x = texture( s_ground, vec3(v_texCoord0, tx1x) );

	float tx0y = floor(idatay.r * 255.0 + 0.5);
	float tx1y = floor(idatay.g * 255.0 + 0.5);
	vec4 d0y = texture( s_ground, vec3(v_texCoord0, tx0y) );
	vec4 d1y = texture( s_ground, vec3(v_texCoord0, tx1y) );

	float tx0xy = floor(idataxy.r * 255.0 + 0.5);
	float tx1xy = floor(idataxy.g * 255.0 + 0.5);
	vec4 d0xy = texture( s_ground, vec3(v_texCoord0, tx0xy) );
	vec4 d1xy = texture( s_ground, vec3(v_texCoord0, tx1xy) );

	color = mix(d1, d0, idata.z);
	vec4 colorx = mix(d1x, d0x, idatax.z);
	vec4 colory = mix(d1y, d0y, idatay.z);
	vec4 colorxy = mix(d1xy, d0xy, idataxy.z);

	color = mix( mix(color, colorx, abs(texelPoint.x)), mix(colory, colorxy, abs(texelPoint.x)), abs(texelPoint.y));

	// Limit sampling to textures in current weightcell - 2 texture fetches ---------------------------
	/*
	float tx0 = floor(idata.r * 255.0 + 0.5);
	float tx1 = floor(idata.g * 255.0 + 0.5);

	float tx0w = idata.z;
	float tx1w = 1.0 - idata.z;

	// evaluate weights of tx0 and tx1 in neighbouring weight cells
	float txa_x = floor(idatax.r * 255.0 + 0.5);
	float txb_x = floor(idatax.g * 255.0 + 0.5);
	float tx0w_x = (tx0 == txa_x ? 1.0 : 0.0) * idatax.z + (tx0 == txb_x ? 1.0 : 0.0) * (1.0 - idatax.z);
	float tx1w_x = (tx1 == txa_x ? 1.0 : 0.0) * idatax.z + (tx1 == txb_x ? 1.0 : 0.0) * (1.0 - idatax.z);
	float txa_y = floor(idatay.r * 255.0 + 0.5);
	float txb_y = floor(idatay.g * 255.0 + 0.5);
	float tx0w_y = (tx0 == txa_y ? 1.0 : 0.0) * idatay.z + (tx0 == txb_y ? 1.0 : 0.0) * (1.0 - idatay.z);
	float tx1w_y = (tx1 == txa_y ? 1.0 : 0.0) * idatay.z + (tx1 == txb_y ? 1.0 : 0.0) * (1.0 - idatay.z);
	float txa_xy = floor(idataxy.r * 255.0 + 0.5);
	float txb_xy = floor(idataxy.g * 255.0 + 0.5);
	float tx0w_xy = (tx0 == txa_xy ? 1.0 : 0.0) * idataxy.z + (tx0 == txb_xy ? 1.0 : 0.0) * (1.0 - idataxy.z);
	float tx1w_xy = (tx1 == txa_xy ? 1.0 : 0.0) * idataxy.z + (tx1 == txb_xy ? 1.0 : 0.0) * (1.0 - idataxy.z);

	tx0w = mix( mix( tx0w, tx0w_x, abs(texelPoint.x) ), mix( tx0w_y, tx0w_xy, abs(texelPoint.x) ), abs(texelPoint.y) );
	tx1w = mix( mix( tx1w, tx1w_x, abs(texelPoint.x) ), mix( tx1w_y, tx1w_xy, abs(texelPoint.x) ), abs(texelPoint.y) );

	tx0w /= tx0w + tx1w > 0 ? tx0w + tx1w : 1.0;

	color = texture( s_ground, vec3(v_texCoord0, tx0) ) * tx0w + texture( s_ground, vec3(v_texCoord0, tx1) ) * (1.0 - tx0w);
	*/

	// DEBUG: highlight areas that could be pretty much be rendered with single texturing
	//color = idata.z > 0.9 && idatax.z > 0.9 && idatay.z > 0.9 && idataxy.z > 0.9 && tx0 == tx0x && tx0 == tx0y && tx0 == tx0xy ? vec4(1,0,0,1) : vec4(0,0,0,0);

	//color += (texelPoint.x < -0.475) || (texelPoint.y < -0.475) || (texelPoint.x > 0.475) || (texelPoint.y > 0.475) ? 0.03 : 0.0;

	// test: some shading
	//vec4 wdata = texture( opacityTex, opaUv, 0 );
	//color *= wdata.a;
#endif

#ifdef DIFFUSE_TEX
  #ifdef COMBINE_DIFFUSE_AND_SPECULAR
	vec4 diffuseColor = texture(diffuseTex, v_texCoord0);
	vec4 color = diffuseColor;
  #endif
  #ifndef COMBINE_DIFFUSE_AND_SPECULAR
	vec4 color = texture(diffuseTex, v_texCoord0);
  #endif
#endif

#ifdef ENABLE_LIGHT
	light = vec3(1.00) * clamp( dot(-u_lightDirView, v_normal), 0.0, 1.0 );
#else
	light = vec3(1.00);
#endif

#ifdef VERTEX_COLOR
	color *= v_color;
#endif

#ifdef COLORIZE_COLOR
	color *= u_colorize;
#endif

#ifdef COLORIZE_TEX
	color *= texture(colorizeTex, v_texCoord0);
#endif

#ifdef STENCIL
	vec4 stencilColor = texture(stencilTex, v_texCoordStencil);
	color = vec4(color.rgb * (1.0 - stencilColor.a) + stencilColor.rgb, color.a);
#endif

#ifdef EMISSION_TEX
	color.rgb += texture(emissionTex, v_texCoord0).rgb;
#endif
#ifdef EMISSION_COLOR
	color += vec4( u_emission.rgb, 0);
#endif

#ifdef LIGHTMAP_SPECULAR
  #ifdef SPECULAR_TEX
    #ifdef COMBINE_DIFFUSE_AND_SPECULAR
	color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * diffuseColor.rgb;
    #else
	color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * texture(specularTex, v_texCoord0).rgb;
    #endif
  #endif
  #ifndef SPECULAR_TEX
    #ifdef SPECULAR_COLOR
	  color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb * u_specular.rgb;
	#else
	  color.rgb += texture(lightmapSpecular, v_texCoordLightmap).rgb;
    #endif
  #endif
#endif // LIGHTMAP_SPECULAR

#ifdef SHADOWMAP
	float margin = 0.0;
	vec4 shadowPos0 = v_shadowPosition0 - vec4(0, 0, margin, 0);
	#ifdef SHADOWMAP_PCF
	vec4 shadowPos1 = v_shadowPosition1 - vec4(0, 0, margin, 0);
	vec4 shadowPos2 = v_shadowPosition2 - vec4(0, 0, margin, 0);
	vec4 shadowPos3 = v_shadowPosition3 - vec4(0, 0, margin, 0);
	vec4 shadowPos4 = v_shadowPosition4 - vec4(0, 0, margin, 0);
	vec4 shadowPos5 = v_shadowPosition5 - vec4(0, 0, margin, 0);
	#endif

	float shadowSample = texture(shadowmap, shadowPos0.xyz);

	#ifdef SHADOWMAP_PCF
	shadowSample +=      texture(shadowmap, shadowPos1.xyz);
	shadowSample +=      texture(shadowmap, shadowPos2.xyz);
	shadowSample +=      texture(shadowmap, shadowPos3.xyz);
	shadowSample +=      texture(shadowmap, shadowPos4.xyz);
	shadowSample +=      texture(shadowmap, shadowPos5.xyz);
	shadowSample *= 1.0/6.0;
	shadowSample = step( 0.6, shadowSample );
	#endif

	shadowSample = mix(1.0, shadowSample, smoothstep( 0.0, 0.05, v_shadowPosition0.x ) * smoothstep( 0.0, 0.05, v_shadowPosition0.y ) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.x )) * (1.0 - smoothstep( 0.95, 1.0, v_shadowPosition0.y )));

	light *= shadowSample;
#endif

#ifdef AMBIENT
	light += u_ambient.rgb;
#endif

	//FragColor.rgb = light.rgb;
	//return;


	float shade = texture( s_shadeMap, v_texCoord1 ).r;
	float darken = min(shade, 0.5) * 2.0;
	float brighten  = max(shade, 0.5) * 2.0;
	color *= 1.0 - (1.0 - darken) * shadeMapDarkenAmount;
	color *= pow(brighten, shadeMapBrightenAmount );

#ifdef ENABLE_LIGHT
	color.rgb *= mix(u_shadowLight, u_diffuseLight, light);
#endif

#ifdef COLORTRANSFORM_MUL
  #ifdef COLORTRANSFORM_ADD
    #define COLORTRANSFORM_MUL_AND_ADD
  #endif
#endif

#ifdef COLORTRANSFORM_MUL_AND_ADD
	color = (color * vec4(uv_colorMul.rgb, 1.0)) + (uv_colorAdd * color.a);
	//color = (vec4(1,1,1,1) * vec4(uv_colorMul.rgb, 1.0)) + (uv_colorAdd * color.a);
#endif
#ifndef COLORTRANSFORM_MUL_AND_ADD
  #ifdef COLORTRANSFORM_MUL
	//color *= uv_colorMul;
	color = vec4(1,0,0,1);
  #endif
#endif
#ifndef COLORTRANSFORM_MUL_AND_ADD
  #ifdef COLORTRANSFORM_ADD
	//color += uv_colorAdd * color.a;
	color = vec4(0,1,0,1);
  #endif
#endif // mul & add

#ifdef OPACITY_VALUE
	color.a *= u_opacity;
#endif

#ifdef OPACITY_TEX
	#ifdef BLEND_MODE_4
		color.a *= texture(opacityTex, v_texCoord0).b;
	#else
		color *= texture(opacityTex, v_texCoord0).b;
	#endif
#endif

#ifdef GAMMA_CORRECT
	color = vec4(pow(color.rgb, vec3(0.454545)), color.a);
#endif

#ifdef CUTOUT
	if (color.a < u_cutout) {
		discard;
	}
#endif

	FragColor = color;
}





