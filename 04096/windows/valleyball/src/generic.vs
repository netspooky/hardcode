varying vec4 Y;
varying vec2 Z;

void main()
{
	Y = gl_Color;
	Z = (gl_Vertex.xy*vec2(Y.w,1.0))*0.5+0.5;
	gl_Position = gl_Vertex;
}
