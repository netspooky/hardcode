#ifndef VERTEX_INL
#define VERTEX_INL

//------------------------------------------------------------------------------------------
// Standard vertex shader.
//------------------------------------------------------------------------------------------
const char* g_stdVertexShader = 
"in vec2 v;"
"void main()"
"{"
    "gl_Position=vec4(v,0.,1.);"
"}";

#endif // VERTEX_INL