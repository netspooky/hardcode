#pragma once

#ifdef _WIN32													
#	define	GLEW4KB_GETPROCADDRESS(n)							\
				wglGetProcAddress(n)							
#elif defined(__linux__) 										
#	define 	GLEW4KB_GETPROCADDRESS(n)							\
				glXGetProcAddress((const unsigned char *)n)		
#else 															
#	error Unknow platform 										
#endif 														
																


//#define GLEW4KB_INLINE inline(or __forceinline) before including this file!
GLEW4KB_INLINE void glew4kb_setup_GL_ext()
{
	//This is a dummy setup function so that you dont need to write #if #endif block.
	//This function must be removed by compiler or linker(crinkler).
}


static char* glext_names = {
"glActiveTexture\0"
"glAttachShader\0"
"glBeginTransformFeedback\0"
"glBindBuffer\0"
"glBindBufferBase\0"
"glBindBufferRange\0"
"glBindFramebuffer\0"
"glBufferData\0"
"glCompileShader\0"
"glCreateProgram\0"
"glCreateShader\0"
"glDrawArraysInstanced\0"
"glEnableVertexAttribArray\0"
"glEndTransformFeedback\0"
"glFramebufferTexture\0"
"glGenBuffers\0"
"glGenFramebuffers\0"
"glGenerateMipmap\0"
"glGetBufferSubData\0"
"glGetUniformLocation\0"
"glLinkProgram\0"
"glShaderSource\0"
"glTexBufferRange\0"
"glTransformFeedbackVaryings\0"
"glUniform1f\0"
"glUniform1i\0"
"glUniform2f\0"
"glUseProgram\0"
"glVertexAttribPointer\0"
"\0"
};

#define glActiveTexture	((PFNGLACTIVETEXTUREPROC)GLEW4KB_GETPROCADDRESS(glext_names+0))
#define glAttachShader	((PFNGLATTACHSHADERPROC)GLEW4KB_GETPROCADDRESS(glext_names+16))
#define glBeginTransformFeedback	((PFNGLBEGINTRANSFORMFEEDBACKPROC)GLEW4KB_GETPROCADDRESS(glext_names+31))
#define glBindBuffer	((PFNGLBINDBUFFERPROC)GLEW4KB_GETPROCADDRESS(glext_names+56))
#define glBindBufferBase	((PFNGLBINDBUFFERBASEPROC)GLEW4KB_GETPROCADDRESS(glext_names+69))
#define glBindBufferRange	((PFNGLBINDBUFFERRANGEPROC)GLEW4KB_GETPROCADDRESS(glext_names+86))
#define glBindFramebuffer	((PFNGLBINDFRAMEBUFFERPROC)GLEW4KB_GETPROCADDRESS(glext_names+104))
#define glBufferData	((PFNGLBUFFERDATAPROC)GLEW4KB_GETPROCADDRESS(glext_names+122))
#define glCompileShader	((PFNGLCOMPILESHADERPROC)GLEW4KB_GETPROCADDRESS(glext_names+135))
#define glCreateProgram	((PFNGLCREATEPROGRAMPROC)GLEW4KB_GETPROCADDRESS(glext_names+151))
#define glCreateShader	((PFNGLCREATESHADERPROC)GLEW4KB_GETPROCADDRESS(glext_names+167))
#define glDrawArraysInstanced	((PFNGLDRAWARRAYSINSTANCEDPROC)GLEW4KB_GETPROCADDRESS(glext_names+182))
#define glEnableVertexAttribArray	((PFNGLENABLEVERTEXATTRIBARRAYPROC)GLEW4KB_GETPROCADDRESS(glext_names+204))
#define glEndTransformFeedback	((PFNGLENDTRANSFORMFEEDBACKPROC)GLEW4KB_GETPROCADDRESS(glext_names+230))
#define glFramebufferTexture	((PFNGLFRAMEBUFFERTEXTUREPROC)GLEW4KB_GETPROCADDRESS(glext_names+253))
#define glGenBuffers	((PFNGLGENBUFFERSPROC)GLEW4KB_GETPROCADDRESS(glext_names+274))
#define glGenFramebuffers	((PFNGLGENFRAMEBUFFERSPROC)GLEW4KB_GETPROCADDRESS(glext_names+287))
#define glGenerateMipmap	((PFNGLGENERATEMIPMAPPROC)GLEW4KB_GETPROCADDRESS(glext_names+305))
#define glGetBufferSubData	((PFNGLGETBUFFERSUBDATAPROC)GLEW4KB_GETPROCADDRESS(glext_names+322))
#define glGetUniformLocation	((PFNGLGETUNIFORMLOCATIONPROC)GLEW4KB_GETPROCADDRESS(glext_names+341))
#define glLinkProgram	((PFNGLLINKPROGRAMPROC)GLEW4KB_GETPROCADDRESS(glext_names+362))
#define glShaderSource	((PFNGLSHADERSOURCEPROC)GLEW4KB_GETPROCADDRESS(glext_names+376))
#define glTexBufferRange	((PFNGLTEXBUFFERRANGEPROC)GLEW4KB_GETPROCADDRESS(glext_names+391))
#define glTransformFeedbackVaryings	((PFNGLTRANSFORMFEEDBACKVARYINGSPROC)GLEW4KB_GETPROCADDRESS(glext_names+408))
#define glUniform1f	((PFNGLUNIFORM1FPROC)GLEW4KB_GETPROCADDRESS(glext_names+436))
#define glUniform1i	((PFNGLUNIFORM1IPROC)GLEW4KB_GETPROCADDRESS(glext_names+448))
#define glUniform2f	((PFNGLUNIFORM2FPROC)GLEW4KB_GETPROCADDRESS(glext_names+460))
#define glUseProgram	((PFNGLUSEPROGRAMPROC)GLEW4KB_GETPROCADDRESS(glext_names+472))
#define glVertexAttribPointer	((PFNGLVERTEXATTRIBPOINTERPROC)GLEW4KB_GETPROCADDRESS(glext_names+485))
