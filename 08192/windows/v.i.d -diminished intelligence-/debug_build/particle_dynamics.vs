#version 330

#include "common.s"
#include "distance_field.s"
#include "head.s"

#define EDGE_LENGTH edge_length
#define ODEKO_WIDTH 1.3
#define BEND_WEIGHT 0.5

uniform float sample_count;

layout(location = 0) in vec3 in_crnt_pos[NUM_ADJACENCY_VERTS2+1];
layout(location = NUM_ADJACENCY_VERTS2PLUS1) in vec3 in_prev_pos;

out vec3 out_position;

void main()
{
	float t = get_second(sample_count);

	float nrm_insid = float(gl_VertexID/NUM_VERTICES_PER_LINE)/FLT(NUM_LINES);
	int vert_id	= gl_VertexID % NUM_VERTICES_PER_LINE;

	float phi		= nrm_insid*(2.0*PI - ODEKO_WIDTH) + ODEKO_WIDTH*0.5;
	float theta		= acos(rand3(nrm_insid).x*0.9);
	float radius	= 0.5*sin(theta);

	//毛根の位置.
	vec3 line_pos = 
	vec3
	(
		radius*sin(phi),
		(0.5+0.01)*cos(theta),
		radius*cos(phi)
	)
	+
	get_head_pos(t);

	line_pos =
		mix
		(
			line_pos,
			line_pos+vec3(sin(phi+t*PI*0.3)*1.2, 0.1*sin(t*9.0+nrm_insid*13.0), cos(phi+t*PI*0.3)*1.2),
			scene_smooth(t, 2.0)
		);

	float edge_length = 0.02+0.003*sin(phi*8.);

	if(vert_id == 0)
	{
		out_position = line_pos;
		return;
	}

	//毛の根元の向き.
	vec3 rest_tangent = vec3(sin(theta)*sin(phi), cos(theta), sin(theta)*cos(phi));

	//初期位置.
	if(gbl_begin(t) > 0.0)
	{
		out_position = line_pos + rest_tangent * EDGE_LENGTH * float(vert_id);
		return;
	}

	//時間積分
	out_position = in_crnt_pos[NUM_ADJACENCY_VERTS];

	vec3 dlt = in_crnt_pos[NUM_ADJACENCY_VERTS] - in_prev_pos;
#if 0
	const float max_dlt = 0.005;
	if(dot(dlt, dlt) > max_dlt*max_dlt)
		dlt = normalize(dlt)*max_dlt;
#endif
	out_position += dlt*0.91 + vec3(0.0, -0.0004, 0.0);

	//長さ制約.
	vec3 dir = normalize(out_position - in_crnt_pos[NUM_ADJACENCY_VERTS-1]);
	out_position = in_crnt_pos[NUM_ADJACENCY_VERTS-1] + dir*EDGE_LENGTH;
#if 1
	//曲げ制約.
	if(vert_id == 1)
	{
		out_position = in_crnt_pos[NUM_ADJACENCY_VERTS-1] + rest_tangent * EDGE_LENGTH;
	}else if(vert_id == NUM_VERTICES_PER_LINE-1)
	{
		vec3 edge0	= in_crnt_pos[1] - in_crnt_pos[0];
		vec3 edge1	= out_position - in_crnt_pos[1];
		vec3 delta	= (edge0 - edge1)/3.;
		out_position += delta*0.5*BEND_WEIGHT;
	}else if(vert_id == NUM_VERTICES_PER_LINE-2)
	{
		vec3 edge0	= in_crnt_pos[1] - in_crnt_pos[0];
		vec3 edge1	= out_position - in_crnt_pos[1];
		vec3 edge2	= in_crnt_pos[3] - out_position;

		vec3 delta	= (edge0 - edge1)/3. + (edge2 - edge1)*2/3.;
		out_position += delta*0.5*BEND_WEIGHT;
	}else
	{
		vec3 edge0	= in_crnt_pos[1] - in_crnt_pos[0];
		vec3 edge1	= out_position - in_crnt_pos[1];
		vec3 edge2	= in_crnt_pos[3] - out_position;
		vec3 edge3	= in_crnt_pos[4] - in_crnt_pos[3];

		vec3 delta	= (edge0 - edge1)/3. + (edge2 - edge1)*2/3. + (edge2 - edge3)/3.;
		out_position += delta*0.5*BEND_WEIGHT;
	}

	//長さ制約.
	dir = normalize(out_position - in_crnt_pos[NUM_ADJACENCY_VERTS-1]);
	out_position = in_crnt_pos[NUM_ADJACENCY_VERTS-1] + dir*EDGE_LENGTH;
#endif

	//衝突処理.
	float dst = DF(out_position, t);
	const float thick = 0.01;
	if(dst < thick)
	{
		vec3 dir = get_normal(out_position, t);
		out_position += (thick-dst) * dir;
	}
}
