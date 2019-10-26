#pragma once

#include <windows.h>
#include <iostream>
#include <GL/gl.h>
#include <GL/glu.h>
#include "glext.h"
#define myGetProcAddress(name) wglGetProcAddress((LPCSTR)name)

void initShaders();
GLhandleARB createVertexShader(const char* as_FileName);
GLhandleARB createFragmentShader(const char* as_FileName);
GLhandleARB createProgram(GLhandleARB ah_VertexShader, GLhandleARB ah_FragmentShader);
void PrintErrors();
void useProgram(GLhandleARB ah_Program);
char* textFileRead(const char* as_FileName);
void printShaderInfoLog(GLhandleARB ah_Shader);
void printProgramInfoLog(GLhandleARB ah_Program);
bool printShaderStatistics();
