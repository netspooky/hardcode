#version 330

#include "common.s"

uniform float sample_count;

in vec2 vary_uv;

out vec4 out_color;

uniform sampler2D AATex;

void main()
{
	float t = get_second(sample_count);

	vec2 moving_uv = vec2(vary_uv.x + t*0.2, vary_uv.y);
	float v = texture(AATex, moving_uv).r;
	v -= (abs(sin(vary_uv.x*200.0) * sin(vary_uv.y*100.0)) + 1.0) * (1.0 - smoothstep(19.0, 28.0, t));
	if(v < 0.05)
		discard;
	else if(v < 0.4)
	{
		out_color = vec4(1.0);
		return;
	}

	float offset = vary_uv.x + vary_uv.y;
	out_color = vec4(cos(-t*4.0 + offset*40.0)*0.3+0.7, 0.2, 0.2, 1.0);
}
