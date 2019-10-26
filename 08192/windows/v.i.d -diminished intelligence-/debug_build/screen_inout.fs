#version 330

#include "common.s"

uniform float sample_count;

out vec4 out_color;

void main()
{
	float t = get_second(sample_count);

	out_color = vec4(gbl_begin(t) + gbl_end(t)/*1.0 + t*/);
}
