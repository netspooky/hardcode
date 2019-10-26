#ifndef CONTRIB_H
#define CONTRIB_H

#ifdef WIN32
#include <Windows.h>
#endif // WIN32

#if PUBLISH
#ifdef WIN32

#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB 0x0002
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_LAYER_PLANE_ARB 0x2093
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
#define WGL_CONTEXT_COMPATIBILITY_PROFILE_BIT_ARB 0x00000002
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126

typedef HGLRC (APIENTRY * PFNWGLCREATECONTEXTATTRIBSARBPROC)(HDC hDC, HGLRC hShareContext, const int *attribList);

#endif // WIN32
#include <GL/GL.h>

#else
#ifndef APIENTRY
#define APIENTRY  __stdcall
typedef int (APIENTRY *PROC)();
#endif // APIENTRY

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define GLFW_DLL
#include <GLFW/glfw3.h>
#include <GL/GL.h>
#include <GL/GLU.h>
#endif // PUBLISH

#define GL_CLAMP_TO_EDGE 0x812F
#define GL_CLAMP_TO_BORDER 0x812D
#define GL_MIRRORED_REPEAT 0x8370
#define GL_RG 0x8227
#define GL_R32F 0x822E
#define GL_RG16F 0x822F
#define GL_RG32F 0x8230
#define GL_RGB32F 0x8815
#define GL_FRAMEBUFFER 0x8D40
#define GL_DRAW_FRAMEBUFFER 0x8CA9
#define GL_ARRAY_BUFFER 0x8892
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_COLOR_ATTACHMENT1 0x8CE1
#define GL_COLOR_ATTACHMENT2 0x8CE2
#define GL_COLOR_ATTACHMENT3 0x8CE3

#define GL_TEXTURE0 0x84C0
#define GL_TEXTURE1 0x84C1
#define GL_TEXTURE2 0x84C2
#define GL_TEXTURE3 0x84C3

#define GL_TEXTURE_BASE_LEVEL 0x813C
#define GL_TEXTURE_MAX_LEVEL 0x813D
#define GL_TEXTURE_2D_ARRAY 0x8C1A

#define GL_STATIC_DRAW 0x88E4

#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31

#define GL_COMPILE_STATUS 0x8B81
#define GL_LINK_STATUS 0x8B82
#define GL_INFO_LOG_LENGTH 0x8B84

#define GL_PROGRAM_BINARY_RETRIEVABLE_HINT 0x8257
#define GL_PROGRAM_BINARY_LENGTH 0x8741
#define GL_NUM_PROGRAM_BINARY_FORMATS 0x87FE
#define GL_PROGRAM_BINARY_FORMATS 0x87FF

typedef ptrdiff_t GLsizeiptr;
typedef char GLchar;

typedef void (APIENTRY * GenFramebuffersproc_t) (GLsizei n, GLuint* framebuffers);
typedef void (APIENTRY * DeleteFramebuffersproc_t) (GLsizei n, const GLuint* framebuffers);
typedef void (APIENTRY * BindFramebufferproc_t) (GLenum target, GLuint framebuffer);
typedef void (APIENTRY * FramebufferTextureproc_t) (GLenum target, GLenum attachment, GLuint texture, GLint level);
typedef void (APIENTRY * GenBuffersproc_t) (GLsizei n, GLuint* buffers);
typedef void (APIENTRY * DeleteBuffersproc_t) (GLsizei n, const GLuint* buffers);
typedef void (APIENTRY * BindBufferproc_t) (GLenum target, GLuint buffer);
typedef void (APIENTRY * BufferDataproc_t) (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
typedef void (APIENTRY * BindVertexArrayproc_t) (GLuint array);
typedef void (APIENTRY * DeleteVertexArraysproc_t) (GLsizei n, const GLuint* arrays);
typedef void (APIENTRY * GenVertexArraysproc_t) (GLsizei n, GLuint* arrays);
typedef void (APIENTRY * EnableVertexAttribArrayproc_t) (GLuint);
typedef void (APIENTRY * VertexAttribPointerproc_t) (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* pointer);
typedef void (APIENTRY * AttachShaderproc_t) (GLuint program, GLuint shader);
typedef void (APIENTRY * CompileShaderproc_t) (GLuint shader);
typedef GLuint (APIENTRY * CreateProgramproc_t) (void);
typedef GLuint (APIENTRY * CreateShaderproc_t) (GLenum type);
typedef void (APIENTRY * DeleteProgramproc_t) (GLuint program);
typedef void (APIENTRY * DeleteShaderproc_t) (GLuint shader);
typedef void (APIENTRY * UseProgramproc_t) (GLuint program);
typedef void (APIENTRY * LinkProgramproc_t) (GLuint program);
typedef void (APIENTRY * ShaderSourceproc_t) (GLuint shader, GLsizei count, const GLchar** strings, const GLint* lengths);
typedef void (APIENTRY * BindAttribLocationproc_t) (GLuint program, GLuint index, const GLchar* name);
typedef void (APIENTRY * BindFragDataLocationproc_t) (GLuint, GLuint, const GLchar*);
typedef GLint (APIENTRY * GetUniformLocationproc_t) (GLuint program, const GLchar* name);
typedef void (APIENTRY * Uniform1iproc_t) (GLint location, GLint v0);
typedef void (APIENTRY * Uniform2iproc_t) (GLint location, GLint v0, GLint v1);
typedef void (APIENTRY * Uniform1fproc_t) (GLint location, GLsizei count, const GLfloat* value);
typedef void (APIENTRY * Uniform1ivproc_t) (GLint location, GLsizei count, const GLint* value);
typedef void (APIENTRY * TexImage3Dproc_t) (GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const GLvoid *pixels);
typedef void (APIENTRY * FramebufferTextureLayerproc_t) (GLenum target,GLenum attachment, GLuint texture,GLint level,GLint layer);
typedef void (APIENTRY * ActiveTextureproc_t) (GLenum texture);
typedef void (APIENTRY * DrawBuffersproc_t) (GLsizei n, const GLenum* bufs);

#define GL_FUNC_COUNT 27
#if !defined(PUBLISH)
union
{
	struct
	{
		GenFramebuffersproc_t         GenFramebuffers;
		BindFramebufferproc_t         BindFramebuffer;
		FramebufferTextureproc_t      FramebufferTexture;
		GenBuffersproc_t              GenBuffers;
		BindBufferproc_t              BindBuffer;
		BufferDataproc_t              BufferData;
		BindVertexArrayproc_t         BindVertexArray;
		GenVertexArraysproc_t         GenVertexArrays;
		EnableVertexAttribArrayproc_t EnableVertexAttribArray;
		VertexAttribPointerproc_t     VertexAttribPointer;
		AttachShaderproc_t            AttachShader;
		CompileShaderproc_t           CompileShader;
		CreateProgramproc_t           CreateProgram;
		CreateShaderproc_t            CreateShader;
		LinkProgramproc_t             LinkProgram;
		UseProgramproc_t              UseProgram;
		ShaderSourceproc_t            ShaderSource;
		BindAttribLocationproc_t      BindAttribLocation;
		BindFragDataLocationproc_t    BindFragDataLocation;
		GetUniformLocationproc_t      GetUniformLocation;
		Uniform1iproc_t               Uniform1i;
		Uniform2iproc_t               Uniform2i;
		Uniform1ivproc_t              Uniform1iv;
		TexImage3Dproc_t              TexImage3D;
		FramebufferTextureLayerproc_t FramebufferTextureLayer;
		ActiveTextureproc_t ActiveTexture;
		DrawBuffersproc_t DrawBuffers;
	};
	PROC ptr[GL_FUNC_COUNT];
} gl;

const char* g_glFuncNames[GL_FUNC_COUNT];

#define GL_CLEANUP_FUNC_COUNT 5
union
{
	struct
	{
		DeleteFramebuffersproc_t DeleteFramebuffers;
		DeleteBuffersproc_t      DeleteBuffers;
		DeleteVertexArraysproc_t DeleteVertexArrays;
		DeleteProgramproc_t      DeleteProgram;
		DeleteShaderproc_t       DeleteShader;
	};
	PROC ptr[GL_CLEANUP_FUNC_COUNT];
} glCleanup;
const char* g_glCleanupNames[GL_CLEANUP_FUNC_COUNT];
#endif // !PUBLISH

#if (defined(_DEBUG) && !defined(PUBLISH))
typedef void (APIENTRY * GetShaderivproc_t) (GLuint shader, GLenum pname, GLint* param);
typedef void (APIENTRY * GetProgramivproc_t) (GLuint program, GLenum pname, GLint* param);
typedef void (APIENTRY * ProgramParameteriproc_t) (GLuint program, GLenum pname, GLint param);
typedef void (APIENTRY * GetShaderInfoLogproc_t) (GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
typedef void (APIENTRY * GetProgramInfoLogproc_t) (GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog);
typedef GLenum (APIENTRY * CheckFramebufferStatusproc_t) (GLenum target);

#define GL_DEBUG_FUNC_COUNT 6
union
{
	struct
	{
		GetShaderivproc_t            GetShaderiv;
		GetProgramivproc_t           GetProgramiv;
		ProgramParameteriproc_t      ProgramParameteri;
		GetShaderInfoLogproc_t       GetShaderInfoLog;
		GetProgramInfoLogproc_t      GetProgramInfoLog;
		CheckFramebufferStatusproc_t CheckFramebufferStatus;
	};
	PROC ptr[GL_DEBUG_FUNC_COUNT];
} glDebug;

const char* g_glDebugFuncNames[GL_DEBUG_FUNC_COUNT];

void ShaderInfoLog(GLuint id);
void ProgramInfoLog(GLuint id);
void ShowGLErrors();
void ShowCompilationErrors(GLuint i);
void ShowLinkErrors(GLuint i);
#else
#define ShaderInfoLog(i)
#define ProgramInfoLog(i)
#define ShowGLErrors()
#define ShowCompilationErrors(i)
#define ShowLinkErrors(i)
#endif // _DEBUG

#if defined(PUBLISH)
#define CALL_GLPROC(p) ((p ## proc_t)wglGetProcAddress("gl" #p))
#else
#define CALL_GLPROC(p) (gl.##p)
#endif

#endif // CONTRIB_H