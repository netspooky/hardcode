#ifndef GL_FUNCTIONS_H
#define GL_FUNCTIONS_H

#include <GL/gl.h>
#include "linker.h"

// It get's funny here! This string is written to the elf-header by screw_elf_header.py,
// while the symbol for it is defined in linker.ld
extern const char gl_functions_library;

// the members of this struct have to have the same order as in the hashes-array!
static struct
{
    void GLAPIENTRY (*glBegin)(GLenum);
    void GLAPIENTRY (*glEnd)();
    GLuint GLAPIENTRY (*glCreateShader)(GLenum);
    void GLAPIENTRY (*glShaderSource)(GLuint, GLsizei count, const GLchar**, const GLint*);
    void GLAPIENTRY (*glCompileShader)(GLuint);
    void GLAPIENTRY (*glAttachShader)(GLuint, GLuint);
    GLuint GLAPIENTRY (*glCreateProgram)();
    void GLAPIENTRY (*glLinkProgram)(GLuint);
    void GLAPIENTRY (*glUseProgram)(GLuint);
    void GLAPIENTRY (*glTexImage2D)(GLenum, GLint, GLint, GLsizei, GLsizei, GLint, GLenum, GLenum, const GLvoid*);
    void GLAPIENTRY (*glTexParameteri)(GLenum, GLenum, GLint);
    GLint GLAPIENTRY (*glGetUniformLocation)(GLuint, const GLchar*);
    void GLAPIENTRY (*glUniform3fv)(GLint, GLsizei, const GLfloat*);
    GLint GLAPIENTRY (*glGetAttribLocation)(GLuint, const GLchar*);
    void GLAPIENTRY (*glVertexAttrib2f)(GLuint, GLfloat, GLfloat);
} gl_functions;

static const gnu_hash_t gl_functions_hashes[] = {
    0xfd3eaa9d, // glBegin
    0x0f83490f, // glEnd
    0x835cdd03, // glCreateShader
    0xbba22800, // glShaderSource
    0x712f7898, // glCompileShader
    0x9f5da104, // glAttachShader
    0x205c8f24, // glCreateProgram
    0x2fed8c1e, // glLinkProgram
    0x4f3ddefd, // glUseProgram
    0x4dc8e382, // glTexImage2D
    0xf4dfe433, // glTexParameteri
    0x4c1fa891, // glGetUniformLocation
    0x509144a7, // glUniform3fv
    0x9a887597, // glGetAttribLocation
    0x233f3994  // glVertexAttrib2f
};

static regparm void gl_functions_initialize()
{
    for (int i = 0; i < array_size(gl_functions_hashes); i++)
    {
        ((void**)&gl_functions)[i] =
            linker_lookup_symbol(&gl_functions_library, gl_functions_hashes[i]);
    }
}

#endif

