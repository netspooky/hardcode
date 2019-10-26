#version 140

in vec3 O;

out vec4 C;

void main()
{
	C=vec4(O.z);
}
