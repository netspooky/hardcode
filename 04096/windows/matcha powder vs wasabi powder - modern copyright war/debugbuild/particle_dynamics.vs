#version 330

#include "common.s"

uniform float sample_count;

layout(location = 0) in vec3 in_positions[NUM_VERTICES_PER_LINE];

out vec3 out_positions[NUM_VERTICES_PER_LINE];

void main()
{
	float t = get_second(sample_count);

	vec3 rand_pos = rand3(float(gl_VertexID)/FLT(NUM_LINES));

	if(t < 2.0)
	{
		for(int i=0; i<NUM_VERTICES_PER_LINE; ++i)
		{
			float x = float(i)/FLT(NUM_VERTICES_PER_LINE);
			out_positions[i] = rand_pos;// + vec3(0.002*sin(22.*x), x*0.002, 0.);
		}
		return;
	}

#if 0
	for(int i=0; i<NUM_VERTICES_PER_LINE; ++i)
	{
		out_positions[i] = in_positions[i];
	}
#endif

	out_positions[0] = in_positions[0];

	out_positions[0] += (in_positions[0] - in_positions[1])*0.94;
	out_positions[1] = in_positions[0];

	//1
#if 1
	vec3 delta = vec3(0.);
//	out_positions[0].z -= 0.0002;
//	out_positions[0].y += pulse(t)*0.0002;
	float gbl1v = gbl_1(t);//max(gbl_1a(t)*4.-3., 0.);
	float angle1 = gbl_1a(t)*12.+pulse_fract(t)*gbl1v*12.;
	delta.x = cos(angle1);
	delta.z = sin(angle1);
	delta.y = (lcl_1(t)-0.5)*2.*(1.-gbl1v);
	out_positions[0] += delta*0.0002*gbl_1(t);
#endif

	//2
#if 1
	out_positions[0]
	+=
	-getNormal(in_positions[0])
	*
	0.004
	*
	DF(in_positions[0])
	*
	gbl_2(t);
#endif

	//3
#if 1
	float gbl3 = gbl_3a(t);
	if(in_positions[0].y < gbl3 && gbl3>0.02)
	{
		out_positions[0].y -= 0.0001;
	}
#endif

	//4
#if 1
	vec3 delta4 = rand_pos - in_positions[0];
	out_positions[0] += delta4 * 0.002 * gbl_4(t);
	if(gbl_4a(t) < 0.5 && gbl_4a(t) > 0.)
	{
		vec3 dist = in_positions[0] - vec3(0.5);
		float d = dot(dist, dist);
		vec3 dir  = normalize(dist);

	//	out_positions[0] += dir/d * (gbl_4a(t)-0.25)*0.0002;
		out_positions[0] += dir/d * (gbl_4a(t)-0.2)*0.0002;
	}
#endif

	for(int i=2; i<NUM_VERTICES_PER_LINE; ++i)
	{
		out_positions[i] = mix(in_positions[i], in_positions[i-1], 0.6);
	}

#if 1
	vec3 torus = vec3(step(1.0, out_positions[0])-step(0.0, -out_positions[0]));
	for(int i=0; i<NUM_VERTICES_PER_LINE; ++i)
	{
		out_positions[i] -= torus;
	}
#endif
}
