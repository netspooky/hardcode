#version 140

uniform T {
	mat4 M;
	mat4 P;
//	float Z;
} A;

in vec4 P;

void main()
{
	gl_Position=A.P*A.M*vec4(P.xyz,1);
}
