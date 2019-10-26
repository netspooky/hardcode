#version 330

layout(location = 0) in vec2 in_position;

uniform vec2 msgPos;

out vec2 vary_uv;

void main()
{
	vary_uv = in_position;
	gl_Position = vec4(in_position * vec2(1.0*(1080.0/1980.0), 0.125)*16.0 + msgPos, 0.0, 1.0);
}
