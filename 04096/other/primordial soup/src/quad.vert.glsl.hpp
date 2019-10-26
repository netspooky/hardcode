static const char *g_shader_vert_quad = ""
#if defined(USE_LD)
"quad.vert.glsl"
#else
"layout(location=0)in vec2 v;"
"out vec2 c;"
"void main()"
"{"
"c=v*.5+.5;"
"gl_Position=vec4(v,0,1);"
"}"
#endif
"";
