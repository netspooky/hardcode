#version 420

#include "common.s"
#include "camera.s"
#include "shadowmap.s"

const mat4 projection =
mat4
(
	ZNEAR/(PROJ_W), 0.0,				0.0,							0.0,
	0.0,	ZNEAR/(HEIGHT/WIDTH*PROJ_W),0.0,							0.0,
	0.0,	0.0,						-(ZFAR+ZNEAR)/(ZFAR-ZNEAR),	   -1.0,
	0.0,	0.0,						-2.0*ZFAR*ZNEAR/(ZFAR-ZNEAR),	0.0
);

#define LINE_WIDTH 0.001

uniform float sample_count;
layout(binding = 0) uniform samplerBuffer positions;

//out vec3 vary_pos;
out vec3 vary_tangent;
out vec3 vary_view_dir;
out vec4 vary_shadow_pos;
out float	vary_t;
out float	vary_nrm_insid;

void main()
{
#if 0
	if(gl_VertexID == 0)
	{
		gl_Position = vec4(1.0, 1.0, 0.0, 1.0);
	}else if(gl_VertexID == 1)
	{
		gl_Position = vec4(0.0, 1.0, 0.0, 1.0);
	}else
	{
		gl_Position = vec4(1.0, 0.0, 0.0, 1.0);
	}
#endif

#if 0
	gl_Position = vec4(cos(gl_VertexID/2.0), sin(gl_VertexID/2.0), 0.0, 1.0);
	gl_Position.xy /= gl_InstanceID;
#endif

	//world coordinate
	vec3 p = texelFetch(positions, gl_VertexID/2 + gl_InstanceID*NUM_VERTICES_PER_LINE + NUM_ADJACENCY_VERTS).xyz;
	vec3 p1 =
		gl_VertexID/2 == NUM_VERTICES_PER_LINE - 1
		?
		texelFetch(positions, gl_VertexID/2 - 1 + gl_InstanceID*NUM_VERTICES_PER_LINE + NUM_ADJACENCY_VERTS).xyz
		:
		texelFetch(positions, gl_VertexID/2 + 1 + gl_InstanceID*NUM_VERTICES_PER_LINE + NUM_ADJACENCY_VERTS).xyz
		;
	vec3 tan =
		normalize
		(
			gl_VertexID/2 == NUM_VERTICES_PER_LINE - 1 ?  p - p1 : p1 - p
		);

	float t = get_second(sample_count);

	//view coordinate
	vec3 cam_pos	= get_cam_pos(t);
	mat3 viewmat	= transpose(get_view_mat(t, cam_pos));
	vec3 view_pos	= viewmat * (p - cam_pos);
	vec3 view_tan	= viewmat * tan;
	view_pos += vec3(view_tan.yx*vec2(1.0, -1.0)*float(gl_VertexID % 2)*LINE_WIDTH, 0.0);

	gl_Position		=
		(is_shadowmap ? shadowmap_projection : projection)*vec4(view_pos, 1.0);
//	gl_Position = vec4(p*1.8 - vec3(0.9, 0.9, 0.0), 1.0);
	vary_tangent	= tan;
	vary_view_dir	= cam_pos - p;

	mat3 shadowmap_view_mat			= get_shadowmap_view_mat();
	mat3 shadowmap_view_mat_trans	= transpose(shadowmap_view_mat);
	vary_shadow_pos					= shadowmap_projection*vec4(shadowmap_view_mat_trans*(p - get_shadowmap_light_pos()), 1.0);
	vary_shadow_pos.xyz	*= 0.5;
	vary_shadow_pos.xyz	+= 0.5;
	vary_shadow_pos.z	-= 0.001;

	vary_t				= (gl_VertexID/2)/FLT(NUM_VERTICES_PER_LINE);
	vary_nrm_insid		= gl_InstanceID/FLT(NUM_LINES);
}
