#ifndef HEADER_INL
#define HEADER_INL

//------------------------------------------------------------------------------------------
// Shader header.
//------------------------------------------------------------------------------------------
const char* g_shaderHeader =
"#version 150 compatibility\n"
"#extension GL_EXT_gpu_shader4 : enable\n"
"#extension GL_EXT_texture_array : enable\n"
"#define pi 3.141592653589793238462643383279\n"
"uniform sampler2D g,m;"
"uniform sampler2DArray a;"
"uniform ivec2 r;\n";

#endif // HEADER_INL