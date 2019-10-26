#version 330 compatibility

#include "common.s"

#define WIDTH	1920.0
#define HEIGHT	1080.0
#define ZNEAR	0.001
#define ZFAR	1.0
#define PROJ_W	0.0005

const mat4x4 projection =
mat4
(
	-ZNEAR/(PROJ_W), 0.0,				0.0,							0.0,
	0.0,	ZNEAR/(HEIGHT/WIDTH*PROJ_W),0.0,							0.0,
	0.0,	0.0,						(ZFAR+ZNEAR)/(ZFAR-ZNEAR),		1.0,
	0.0,	0.0,						-2.0*ZFAR*ZNEAR/(ZFAR-ZNEAR),	0.0
);

layout(location = 0) in vec3 in_positions[NUM_VERTICES_PER_LINE];
//out vec3 vary_pos;

void main()
{
#if 0
	if(gl_VertexID == 0)
	{
		gl_Position = vec4(1.0, 1.0, 0.0, 1.0);
	}else if(gl_VertexID == 1)
	{
		gl_Position = vec4(0.0, 1.0, 0.0, 1.0);
	}else
	{
		gl_Position = vec4(1.0, 0.0, 0.0, 1.0);
	}
#endif

#if 0
	gl_Position = vec4(cos(gl_VertexID/2.0), sin(gl_VertexID/2.0), 0.0, 1.0);
	gl_Position.xy /= gl_InstanceID;
#endif
	gl_Position = projection*vec4(in_positions[gl_VertexID]-vec3(0.5, 0.5, 0.0), 1.0);

//	vary_pos =
	gl_TexCoord[0].xyz =
		in_positions[gl_VertexID];
	
	gl_TexCoord[0].w = gl_InstanceID/FLT(NUM_LINES);
}
