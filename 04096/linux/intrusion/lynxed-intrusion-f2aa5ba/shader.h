#ifndef SHADER_H
#define SHADER_H

#include <GL/gl.h>
#include "clib.h"
#include "vector.h"
#include "gl_functions.h"

static regparm void shader_add_to_program(GLuint program, GLenum type, const GLchar* source)
{
    GLuint shader = gl_functions.glCreateShader(type);
    gl_functions.glShaderSource(shader, 1, &source, NULL);
    gl_functions.glCompileShader(shader);
    gl_functions.glAttachShader(program, shader);
}

static regparm GLuint shader_compile_program(
        const char* vertex_source, const char* fragment_source)
{
    GLuint program = gl_functions.glCreateProgram();
    shader_add_to_program(program, GL_VERTEX_SHADER, vertex_source);
    shader_add_to_program(program, GL_FRAGMENT_SHADER, fragment_source);
    gl_functions.glLinkProgram(program);
    return program;
}

static regparm void shader_uniform_vector3(
        GLuint program, const char* identifier, const vector3 value, size_t count)
{
    GLint location = gl_functions.glGetUniformLocation(program, identifier);
    gl_functions.glUniform3fv(location, count, value);
}

#endif

