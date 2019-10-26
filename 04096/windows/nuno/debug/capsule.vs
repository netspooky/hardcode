#version 140

//uniform T {
	uniform mat4 B;	//ModelView
	uniform mat4 C;	//Projection
//}A;

in vec3 P;
in vec3 N;

out vec3 O;

uniform samplerBuffer V;
uniform isamplerBuffer I;

void main()
{
	ivec2 i=texelFetch(I,gl_InstanceID).xy;
	vec3 p0=texelFetch(V,i.x).xyz;
	vec3 p1=texelFetch(V,i.y).xyz;
	float len=distance(p1,p0)/2;
	vec3 dr=normalize(p1-p0);
	vec3 z;
	if(abs(dr.x)>abs(dr.z))
	{
		z=vec3(0,0,1);
	}else
	{
		z=vec3(1,0,0);
	}
	vec3 x=normalize(cross(dr,z));
	z=cross(x,dr);
	mat3 rot=mat3(x,dr,z);
	float r=.03;
	vec3 pos=P;
	pos.y+=sign(pos.y)*(len-r)/r;
	vec3 p=(p0+p1)*.5+rot*pos*r;
	gl_Position=C*B*vec4(p,1);
	O=vec4(B*vec4(rot*N,0)).xyz;
}
