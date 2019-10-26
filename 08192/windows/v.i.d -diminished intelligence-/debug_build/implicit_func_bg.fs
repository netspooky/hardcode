#version 330

in vec3 vary_pos;
out vec4 color;

void main()
{
	float d0 = length(vary_pos.xy);
	float r = d0;

	const float ring_width = 0.03;
	const float rad = 0.5;
	if(r > rad + ring_width || r < rad - ring_width)
		discard;

	float c = min((ring_width - abs(r - rad))*30.0, 1.0)*0.3;
	color = vec4(c);
}
