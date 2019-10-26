//--------------------------------------------------------------------------//
// iq / rgba  .  tiny codes  .  2008                                        //
//--------------------------------------------------------------------------//

static const char vsh_2d[] = \
"uniform vec4 fpar[4];"

"void main(void)"
"{"
    "gl_Position=gl_Vertex;"
    "gl_TexCoord[0].xy = gl_Vertex.xy * vec2(1.0,fpar[0].x);"  //correct aspect
"}";
