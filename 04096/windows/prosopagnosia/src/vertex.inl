#ifndef VERTEX_INL
#define VERTEX_INL

//------------------------------------------------------------------------------------------
// Standard vertex shader.
//------------------------------------------------------------------------------------------
const char* g_stdVertexShader = 
"void main()"
"{"
	"gl_Position=vec4(gl_Vertex.xy,0.,1.);"
"}";

#endif // VERTEX_INL