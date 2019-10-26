varying float T;
varying vec2 Z;
varying vec3 cameraPos;

void main()
{
	T = gl_Color.x;
	Z = (gl_Vertex.xy*vec2(gl_Color.y,1.0))*0.5+0.5;
	cameraPos = gl_Normal.xyz;
	gl_Position = gl_Vertex;
}
