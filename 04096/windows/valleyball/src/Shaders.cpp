#include "Shaders.h"
#ifdef _DEBUG

PFNGLCREATESHADERPROC glCreateShader = NULL;
PFNGLSHADERSOURCEPROC glShaderSource = NULL;
PFNGLCOMPILESHADERPROC glCompileShader = NULL;
PFNGLGETSHADERIVPROC glGetShaderiv = NULL;
PFNGLGETPROGRAMIVPROC glGetProgramiv = NULL;
PFNGLCREATEPROGRAMPROC glCreateProgram = NULL;
PFNGLATTACHSHADERPROC glAttachShader = NULL;
PFNGLLINKPROGRAMPROC glLinkProgram = NULL;
PFNGLUSEPROGRAMPROC glUseProgram = NULL;
PFNGLGETSHADERINFOLOGPROC glGetShaderInfoLog = NULL;
PFNGLGETPROGRAMINFOLOGPROC glGetProgramInfoLog = NULL;


void useProgram(GLhandleARB ah_Program)
{
	glUseProgram(ah_Program);
}


void initShaders()
{
	glCreateShader = (PFNGLCREATESHADERPROC)myGetProcAddress("glCreateShader");
	glShaderSource = (PFNGLSHADERSOURCEPROC)myGetProcAddress("glShaderSource");
	glCompileShader = (PFNGLCOMPILESHADERPROC)myGetProcAddress("glCompileShader");
	glGetShaderiv =	(PFNGLGETSHADERIVPROC)myGetProcAddress("glGetShaderiv");
	glGetProgramiv = (PFNGLGETPROGRAMIVPROC)myGetProcAddress("glGetProgramiv");
	glCreateProgram = (PFNGLCREATEPROGRAMPROC)myGetProcAddress("glCreateProgram");
	glAttachShader = (PFNGLATTACHSHADERPROC)myGetProcAddress("glAttachShader");
	glLinkProgram = (PFNGLLINKPROGRAMPROC)myGetProcAddress("glLinkProgram");
	glUseProgram = (PFNGLUSEPROGRAMPROC)myGetProcAddress("glUseProgram");
	glGetShaderInfoLog = (PFNGLGETSHADERINFOLOGPROC)myGetProcAddress("glGetShaderInfoLog");
	glGetProgramInfoLog = (PFNGLGETPROGRAMINFOLOGPROC)myGetProcAddress("glGetProgramInfoLog");
	
	if (!(glCreateShader && glShaderSource && glCompileShader && glGetShaderiv && glGetProgramiv && glCreateProgram && glAttachShader && glLinkProgram && glUseProgram && glGetShaderInfoLog && glGetProgramInfoLog))
	{
		std::cerr <<  "Some shader functions are not available!" << std::endl;
	}
}


void PrintErrors()
{
	GLenum lr_Error = GL_NO_ERROR;
	int li_ErrorCount = 5;
	do
	{
		lr_Error = glGetError();
		if (lr_Error != GL_NO_ERROR)
		{
			li_ErrorCount--;
			char* ls_ErrorString = (char*)gluErrorString(lr_Error);
			if (ls_ErrorString != 0)
				std::cout << "OPENGL :: ERROR " << ls_ErrorString << std::endl;
		}
		if (li_ErrorCount == 0)
		{
			std::cout << "OPENGL :: ERROR Too many errors!" << std::endl;
			break;
		}
	} while (lr_Error != GL_NO_ERROR);
}


GLhandleARB createVertexShader(const char* as_FileName)
{
	GLhandleARB lh_Shader = 0;
	
	char* ls_ShaderSource = textFileRead(as_FileName);

	if (ls_ShaderSource == NULL)
	{
		std::cerr << "Error reading file: " << as_FileName << std::endl;
		return lh_Shader;
	}

	lh_Shader = glCreateShader(GL_VERTEX_SHADER);

	glShaderSource(lh_Shader, 1, (const char**)&ls_ShaderSource, NULL);
	glCompileShader(lh_Shader);

	free(ls_ShaderSource);

	int li_Status = 0;
	glGetShaderiv(lh_Shader, GL_COMPILE_STATUS, &li_Status);

	if (li_Status == GL_FALSE)
	{
		std::cerr << "Error compiling vertex shader: " << as_FileName << std::endl;
		printShaderInfoLog(lh_Shader);
	}

	return lh_Shader;
}


GLhandleARB createFragmentShader(const char* as_FileName)
{
	GLhandleARB lh_Shader = 0;

	char* ls_ShaderSource = textFileRead(as_FileName);
	if (ls_ShaderSource == NULL)
	{
		std::cerr << "Error reading file: " << as_FileName << std::endl;
		return lh_Shader;
	}

	lh_Shader = glCreateShader(GL_FRAGMENT_SHADER);

	glShaderSource(lh_Shader, 1, (const char**)&ls_ShaderSource, NULL);
	glCompileShader(lh_Shader);

	int li_Status = 0;

	glGetShaderiv(lh_Shader, GL_COMPILE_STATUS, &li_Status);

	if (li_Status == GL_FALSE)
	{
		std::cerr << "Error compiling fragment shader: " << as_FileName << std::endl;
		printShaderInfoLog(lh_Shader);
	}

	free(ls_ShaderSource);

	return lh_Shader;
}


GLhandleARB createProgram(GLhandleARB ah_VertexShader, GLhandleARB ah_FragmentShader)
{
	GLhandleARB lh_Program = 0;
	
	if (ah_VertexShader + ah_FragmentShader <= 1)
	{
		std::cerr << "Cannot create program." << std::endl;
		return lh_Program;
	}

	lh_Program = glCreateProgram();

	glAttachShader(lh_Program, ah_VertexShader);
	glAttachShader(lh_Program, ah_FragmentShader);
	glLinkProgram(lh_Program);

	int li_Status = 0;

	glGetProgramiv(lh_Program, GL_LINK_STATUS, &li_Status);

	if (li_Status == GL_FALSE)
	{
		std::cerr << "Error linking shaders." << std::endl;
		printProgramInfoLog(lh_Program);
	}

	return lh_Program;
}


char* textFileRead(const char* as_FileName) 
{
	FILE* lh_File;
	char* ls_Content = NULL;
	size_t li_Count = 0;

	if (as_FileName != NULL) 
	{
		fopen_s(&lh_File, as_FileName, "rt");

		if (lh_File != NULL) 
		{
			fseek(lh_File, 0, SEEK_END);
			li_Count = ftell(lh_File);
			rewind(lh_File);

			if (li_Count > 0) 
			{
				ls_Content = (char*) malloc(sizeof(char) * (li_Count + 1));
				li_Count = fread(ls_Content, sizeof(char), li_Count, lh_File);
				ls_Content[li_Count] = '\0';
			}

			fclose(lh_File);
		}
	}

	return ls_Content;
}


void printShaderInfoLog(GLhandleARB ah_Shader)
{
	int li_InfologLength = 0;
	int li_CharsWritten = 0;
	char* li_InfoLog;

	glGetShaderiv(ah_Shader, GL_INFO_LOG_LENGTH, &li_InfologLength);

	if (li_InfologLength > 0)
	{
		li_InfoLog = (char*) malloc(li_InfologLength);

		glGetShaderInfoLog(ah_Shader, li_InfologLength, &li_CharsWritten, li_InfoLog);

		std::cerr << li_InfoLog << std::endl;
		free(li_InfoLog);
	}
}


void printProgramInfoLog(GLhandleARB ah_Program)
{
	int li_InfologLength = 0;
	int li_CharsWritten = 0;
	char* ls_InfoLog;

	glGetProgramiv(ah_Program, GL_INFO_LOG_LENGTH, &li_InfologLength);

	if (li_InfologLength > 0)
	{
		ls_InfoLog = (char *)malloc(li_InfologLength);

		glGetProgramInfoLog(ah_Program, li_InfologLength, &li_CharsWritten, ls_InfoLog);

		std::cerr << ls_InfoLog << std::endl;
		free(ls_InfoLog);
	}
}


bool printShaderStatistics()
{
	if (GL_VERSION_2_1) std::cout <<  "Supports OpenGL 2.1. " << std::endl;
	else if (GL_VERSION_2_0) std::cout <<  "Supports OpenGL 2.0. " << std::endl;
	else if (GL_VERSION_1_5) std::cout <<  "Supports OpenGL 1.5. " << std::endl;
	else if (GL_VERSION_1_4) std::cout <<  "Supports OpenGL 1.4. " << std::endl;
	else if (GL_VERSION_1_3) std::cout <<  "Supports OpenGL 1.3. " << std::endl;
	else if (GL_VERSION_1_2) std::cout <<  "Supports OpenGL 1.2. " << std::endl;
	else if (GL_VERSION_1_1) std::cout <<  "Supports OpenGL 1.1. " << std::endl;

	if (GL_ARB_shader_objects && GL_ARB_vertex_shader && GL_ARB_fragment_shader)
	{
		std::cout << "Status: Using GLSL " << glGetString(GL_SHADING_LANGUAGE_VERSION_ARB) << std::endl;
	}
	else
	{
		std::cerr <<  "No GLSL support!" << std::endl;
		return false;
	}

	return true;
}
#endif