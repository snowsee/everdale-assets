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
in vec3 a_tangent;

#ifdef VERTEX_COLOR
in vec4 a_color;
#endif

#ifdef SUPPORTED_GL_OES_30
in mat4 a_model;
#else
uniform mat4 u_model;
#define a_model u_model
#endif

uniform mat4 u_projectionView;
uniform mat4 u_view;

out vec2 v_texCoord0;
out vec3 v_vCoord;
out highp vec3 v_normal;
out highp vec3 v_tangent0;
out highp vec3 v_tangent1;

#ifdef VERTEX_COLOR
out vec4 v_color;
#endif


#ifdef CLOUD_SHADOW
uniform vec4 		u_world_tf; // translate + scale
uniform float		u_cloudshadow_scale;
uniform vec2		u_cloudshadow_offset;
uniform vec2		u_cloudshadow_rot_sc;
out		vec2		v_cloudUv;
#endif


void main(void)
{
	vec4 pos = a_model * a_pos;
	
	v_texCoord0 = a_uv0;

	v_normal = normalize(vec3(u_view * (a_model * vec4(a_normal, 0.0))));
	v_tangent0 = normalize( vec3(u_view * (a_model * vec4(a_tangent, 0.0))) );
	v_tangent1 = cross( v_normal, v_tangent0 );

	v_vCoord = (u_view * pos).xyz;

	vec4 scrpos = u_projectionView * pos;
	gl_Position = scrpos;

#ifdef CLOUD_SHADOW
	vec3 wpos = pos.xyz * u_world_tf.w + u_world_tf.xyz;
	v_cloudUv = vec2( wpos.x, wpos.y );
	v_cloudUv *= u_cloudshadow_scale;
	v_cloudUv += u_cloudshadow_offset;
	v_cloudUv = vec2( v_cloudUv.x * u_cloudshadow_rot_sc.x - v_cloudUv.y * u_cloudshadow_rot_sc.y, v_cloudUv.x * u_cloudshadow_rot_sc.y + v_cloudUv.y * u_cloudshadow_rot_sc.x );
#endif
}
