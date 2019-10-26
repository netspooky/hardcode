#version 330

#include "common.s"
#include "utils.s"

uniform float sample_count;

in vec3 vary_pos;
out vec4 color;

void main()
{
	float t = get_second(sample_count);

	vec3 pos = vary_pos;
	vec3 p0 = vec3(-0.2, sin(t)*0.5, 0.0);
	vec3 p1 = vec3(0.8, -sin(t)*0.5, 0.0);
	vec3 p2 = vec3(-1.0, -sin(t*2.0)*0.7+0.2, 0.0);
	float d0 = length(pos - p0);
	float d1 = lengthN3D(pos - p1, 8.0) * 1.2;
	float d2 = lengthN3D(pos - p2, 1.0) * 0.8;
	float r = 1.0/d0 + 1.0/d1 + 1.0/d2;
	float pw = 8.0;
	float pwd0 = pow(1.0/d0, pw);
	float pwd1 = pow(1.0/d1, pw);
	float pwd2 = pow(1.0/d2, pw);
	float w0 = pwd0/(pwd0 + pwd1 + pwd2);
	float w1 = pwd1/(pwd0 + pwd1 + pwd2);
	float w2 = pwd2/(pwd0 + pwd1 + pwd2);

	r *= 0.3;
	const float ring_width = 0.03;
	if(r > 1.0 + ring_width || r < 1.0 - ring_width)
		discard;
	float c = min((ring_width - abs(r - 1.0))*30.0, 1.0)*0.2;
	color = vec4(c*w0, c*w1, c*w2, 1.0);
}
