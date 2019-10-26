
# define glCreateProgram		\
	((PFNGLCREATEPROGRAMPROC)wglGetProcAddress("glCreateProgram"))
# define glCreateShader		\
	((PFNGLCREATESHADERPROC)wglGetProcAddress("glCreateShader"))
# define glShaderSource		\
	((PFNGLSHADERSOURCEPROC)wglGetProcAddress("glShaderSource"))
# define glCompileShader		\
	((PFNGLCOMPILESHADERPROC)wglGetProcAddress("glCompileShader"))
# define glAttachShader		\
	((PFNGLATTACHSHADERPROC)wglGetProcAddress("glAttachShader"))
# define glLinkProgram		\
	((PFNGLLINKPROGRAMPROC)wglGetProcAddress("glLinkProgram"))
# define glUseProgram		\
	((PFNGLUSEPROGRAMPROC)wglGetProcAddress("glUseProgram"))
# define glGetProgramInfoLog		\
	((PFNGLGETPROGRAMINFOLOGPROC)wglGetProcAddress("glGetProgramInfoLog"))
# define glGetUniformLocation		\
	((PFNGLGETUNIFORMLOCATIONPROC)wglGetProcAddress("glGetUniformLocation"))
# define glGetAttribLocation		\
	((PFNGLGETATTRIBLOCATIONPROC)wglGetProcAddress("glGetAttribLocation"))
# define glUniform2f		\
	((PFNGLUNIFORM2FPROC)wglGetProcAddress("glUniform2f"))
# define glUniform1fv		\
	((PFNGLUNIFORM1FVPROC)wglGetProcAddress("glUniform1fv"))
# define glUniformMatrix4fv		\
	((PFNGLUNIFORMMATRIX4FVPROC)wglGetProcAddress("glUniformMatrix4fv"))
# define glUniform4f		\
	((PFNGLUNIFORM4FPROC)wglGetProcAddress("glUniform4f"))
# define glVertexAttribPointer		\
	((PFNGLVERTEXATTRIBPOINTERPROC)wglGetProcAddress("glVertexAttribPointer"))
# define glEnableVertexAttribArray		\
	((PFNGLENABLEVERTEXATTRIBARRAYPROC)wglGetProcAddress("glEnableVertexAttribArray"))
# define glBufferData		\
	((PFNGLBUFFERDATAPROC)wglGetProcAddress("glBufferData"))
# define glBindBuffer		\
	((PFNGLBINDBUFFERPROC)wglGetProcAddress("glBindBuffer"))
# define glGenBuffers		\
	((PFNGLGENBUFFERSPROC)wglGetProcAddress("glGenBuffers"))
# define glBindTransformFeedback		\
	((PFNGLBINDTRANSFORMFEEDBACKPROC)wglGetProcAddress("glBindTransformFeedback"))
# define glBeginTransformFeedback		\
	((PFNGLBEGINTRANSFORMFEEDBACKPROC)wglGetProcAddress("glBeginTransformFeedback"))
# define glEndTransformFeedback		\
	((PFNGLENDTRANSFORMFEEDBACKPROC)wglGetProcAddress("glEndTransformFeedback"))
# define glDrawTransformFeedback		\
	((PFNGLDRAWTRANSFORMFEEDBACKPROC)wglGetProcAddress("glDrawTransformFeedback"))
# define glGenTransformFeedbacks		\
	((PFNGLGENTRANSFORMFEEDBACKSPROC)wglGetProcAddress("glGenTransformFeedbacks"))
# define glBindBufferBase		\
	((PFNGLBINDBUFFERBASEPROC)wglGetProcAddress("glBindBufferBase"))
# define glTransformFeedbackVaryings		\
	((PFNGLTRANSFORMFEEDBACKVARYINGSPROC)wglGetProcAddress("glTransformFeedbackVaryings"))