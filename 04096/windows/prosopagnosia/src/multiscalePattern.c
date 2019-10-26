#include "contrib.h"

#define WINDOW_WIDTH  1280
#define WINDOW_HEIGHT 720

//(int)( ceil( log( (float)WINDOW_WIDTH ) / log( 16.0f ) ) );
#define HORIZONTAL_PASS_COUNT 3
//(int)( ceil( log( (float)WINDOW_HEIGHT ) / log( 16.0f ) ) );
#define VERTICAL_PASS_COUNT 3

#define MIN_MAX_SIZE  1280

#define PING_PONG_COUNT 2
#define SCALE_COUNT 10

enum
{
	TEXTURE_R_0 = 0,
	TEXTURE_R_1,
	TEXTURE_R_2,
	TEXTURE_MIN_MAX_0,
	TEXTURE_MIN_MAX_1,
	TEXTURE_ARRAY,
	TEXTURE_COUNT
};

enum
{
	R_FIRST=0,
	R_LAST,
	MIN_MAX_FIRST,
	MIN_MAX_LAST,
	UPDATE,
	NORMALIZE,
	SCALE_FIRST,
	SCALE_LAST = SCALE_FIRST+(SCALE_COUNT-1),
	FRAMEBUFFER_COUNT
};

// Shader definitions
#include "header.inl"
#include "vertex.inl"
#include "shader.inl"

#define PROGRAM_COUNT 7

#define MAX_OUTPUT 2

static const GLuint g_drawBuffers[MAX_OUTPUT] =
{ GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1 };

#if defined(PUBLISH) && defined(WIN32)
static const PIXELFORMATDESCRIPTOR g_pixelFormat = 
{
	sizeof(PIXELFORMATDESCRIPTOR),
    1,
    PFD_DRAW_TO_WINDOW|PFD_SUPPORT_OPENGL|PFD_DOUBLEBUFFER,
    PFD_TYPE_RGBA, 32,
    0, 0,
    0, 0,
    0, 0,
    8, 0,
    0, 0, 0, 0, 0,
    32,
    0, 0,
    PFD_MAIN_PLANE, 
    0, 0, 0, 0
};

static DEVMODE g_screenSettings =
{
	"", 
	0, 0,
	sizeof(DEVMODE),
	0,
	DM_PELSWIDTH|DM_PELSHEIGHT,
	{ 0, 0, 0 },
	0, 0, 0, 0, 0,
	"",
    0,
	32, WINDOW_WIDTH, WINDOW_HEIGHT,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

#define g_borderColor (GLint*)(&(g_screenSettings.dmReserved1))

void WINAPI WinMainCRTStartup()
#else
// Texture border color
static const GLint g_borderColor[4] = { 0, 0, 0, 0 };

int main()
#endif // PUBLISH
{
	int i, j, w, h;
	GLuint texId[TEXTURE_COUNT+1];
	GLuint framebuffer[FRAMEBUFFER_COUNT];
	GLuint program[PROGRAM_COUNT], shader;
	GLint uniformId[PROGRAM_COUNT];
	const char *source[2];
	GLenum target;

#if defined(PUBLISH) && defined(WIN32)
	LARGE_INTEGER freq, current, previous;
	HDC hDC;

	ChangeDisplaySettings(&g_screenSettings, CDS_FULLSCREEN);
	ShowCursor( FALSE );
	hDC = GetDC(CreateWindow("edit", NULL, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, 0, 0, 0, 0));
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &g_pixelFormat), &g_pixelFormat);
	// Create and attach OpenGL 2.1 context
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	QueryPerformanceFrequency(&freq);
#else
	double current, previous;
	GLFWwindow* win;

	if(glfwInit() != GL_TRUE)
	{
		return 1;
	}
	
	win = glfwCreateWindow( WINDOW_WIDTH, WINDOW_HEIGHT, "foobar", NULL, NULL );
	if(win == NULL)
	{
		return 1;
	}
	glfwMakeContextCurrent(win);
#ifdef _DEBUG
	// Clear glfw crap
	glGetError();
#endif // _DEBUG

	// Load GL functions
	for(i=0; i<GL_FUNC_COUNT; i++)
	{
		gl.ptr[i] = (PROC)glfwGetProcAddress(g_glFuncNames[i]);
	}

	for(i=0; i<GL_CLEANUP_FUNC_COUNT; i++)
	{
		glCleanup.ptr[i] = (PROC)glfwGetProcAddress(g_glCleanupNames[i]);
	}
#ifdef _DEBUG
	for(i=0; i<GL_DEBUG_FUNC_COUNT; i++)
	{
		glDebug.ptr[i] = (PROC)glfwGetProcAddress(g_glDebugFuncNames[i]);
	}

	glDisable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
#endif
#endif // PUBLISH

	// Create programs
	source[0] = g_shaderHeader;
	for(i=0; i<PROGRAM_COUNT; ++i)
	{
		program[i] = CALL_GLPROC(CreateProgram)();

		target = GL_VERTEX_SHADER;
		source[1] = g_stdVertexShader;
		shader = CALL_GLPROC(CreateShader)(target);
		CALL_GLPROC(ShaderSource)(shader, 2, source, NULL);
		CALL_GLPROC(CompileShader)(shader);
		ShowCompilationErrors(shader);
		CALL_GLPROC(AttachShader)(program[i], shader);

		target = GL_FRAGMENT_SHADER;
		source[1] = g_fragmentShader[i];
		shader = CALL_GLPROC(CreateShader)(target);		
		CALL_GLPROC(ShaderSource)(shader, 2, source, NULL);		
		CALL_GLPROC(CompileShader)(shader);
		ShowCompilationErrors(shader);
		CALL_GLPROC(AttachShader)(program[i], shader);

		CALL_GLPROC(LinkProgram)(program[i]);
		ShowLinkErrors(program[i]);

		CALL_GLPROC(UseProgram)(program[i]);
		CALL_GLPROC(Uniform1i)(CALL_GLPROC(GetUniformLocation)(program[i], "a"), 0);
		CALL_GLPROC(Uniform1i)(CALL_GLPROC(GetUniformLocation)(program[i], "g"), 0);
		CALL_GLPROC(Uniform1i)(CALL_GLPROC(GetUniformLocation)(program[i], "m"), 1);
		uniformId[i] = CALL_GLPROC(GetUniformLocation)(program[i], "r");
	}

	// Create textures

	// TEXTURE_R_2 + SCALE
	// TEXTURE_R_0 + TEXTURE_MIN_MAX_1
	// TEXTURE_R_1 + TEXTURE_MIN_MAX_0
	
	// 1. Standard textures
	glEnable(GL_TEXTURE_2D);
	glGenTextures(TEXTURE_COUNT, texId);

	w = WINDOW_WIDTH, h = WINDOW_HEIGHT;
	for(i=TEXTURE_R_0; i<=TEXTURE_R_2; i++)
	{
		glBindTexture( GL_TEXTURE_2D, texId[i] );

		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER );
		glTexParameteriv( GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, g_borderColor );
		glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB32F, w, h, 0, GL_RGB, GL_FLOAT, NULL );
	}

	// 2. Min max
	w = h = MIN_MAX_SIZE;
	for(;i<=TEXTURE_MIN_MAX_1; i++)
	{
		glBindTexture( GL_TEXTURE_2D, texId[i] );

		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
		glTexParameteriv( GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, g_borderColor );
		glTexImage2D( GL_TEXTURE_2D, 0, GL_RGB32F, w, h, 0, GL_RGB, GL_FLOAT, NULL );
	}
	
	ShowGLErrors();

	// 3. Texture array
	glBindTexture( GL_TEXTURE_2D_ARRAY, texId[TEXTURE_ARRAY] );

	glTexParameteri( GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
	glTexParameteri( GL_TEXTURE_2D_ARRAY, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
	glTexParameteriv( GL_TEXTURE_2D_ARRAY, GL_TEXTURE_BORDER_COLOR, g_borderColor );
	CALL_GLPROC(TexImage3D)( GL_TEXTURE_2D_ARRAY, 0, GL_RGB32F, WINDOW_WIDTH, WINDOW_HEIGHT, SCALE_COUNT, 0, GL_RGB, GL_FLOAT, NULL );

	ShowGLErrors();
		
	// Create fbo
/*
static const unsigned int g_fboTexId[] =
{
	TEXTURE_R_0,       TEXTURE_R_2,
	TEXTURE_R_1,       TEXTURE_COUNT,
	TEXTURE_MIN_MAX_0, TEXTURE_COUNT,
	TEXTURE_MIN_MAX_1, TEXTURE_COUNT,
	TEXTURE_MIN_MAX_0, TEXTURE_R_1,
	TEXTURE_R_0,       TEXTURE_R_2
};
*/

	CALL_GLPROC(GenFramebuffers)(FRAMEBUFFER_COUNT, framebuffer);
	texId[TEXTURE_COUNT]=0;
	//for(i=0, j=0, texId[TEXTURE_COUNT]=0; i<=NORMALIZE;)
	{
		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[0]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_R_0], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_R_2], 0 ); 

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[1]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_R_1], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_COUNT], 0 ); 

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[2]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_MIN_MAX_0], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_COUNT], 0 ); 

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[3]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_MIN_MAX_1], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_COUNT], 0 ); 

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[4]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_MIN_MAX_0], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_R_1], 0 ); 

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[5]);
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_R_0], 0 ); 
		CALL_GLPROC(FramebufferTexture)( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, texId[TEXTURE_R_2], 0 ); 

	}

	for(i=0; i<SCALE_COUNT; i++)
	{
		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[SCALE_FIRST+i]);
		CALL_GLPROC(FramebufferTextureLayer)(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, texId[TEXTURE_ARRAY], 0, i);
	}

	ShowGLErrors();

	// Initialize noise texture	
	glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
	CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[0]);
	CALL_GLPROC(DrawBuffers)(2, g_drawBuffers);
	CALL_GLPROC(UseProgram)(program[0]);
	glRects(-1,-1, 1, 1);
	
#if defined(PUBLISH) && defined(WIN32)
	QueryPerformanceCounter(&previous);
#else
	previous = glfwGetTime();
#endif // PUBLISH

	// Let's go!
	do
	{
		// Summed area table
		// 1. horizontal
		
		w = 1, i = h = 0;
		for(j=0; j<HORIZONTAL_PASS_COUNT; j++)
		{
			CALL_GLPROC(ActiveTexture)(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texId[TEXTURE_R_0+i]);

			CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[i^1]);
			CALL_GLPROC(DrawBuffers)(1, g_drawBuffers);
			CALL_GLPROC(UseProgram)(program[1]);
			CALL_GLPROC(Uniform2i)(uniformId[1], w, h);
			glRects(-1,-1, 1, 1);
			
			i ^= 1;
			w <<= 4;
			h <<= 4;
		};

		// 2. vertical
		w = 0, h = 1;
		for(j=0; j<VERTICAL_PASS_COUNT; j++)
		{
			glBindTexture(GL_TEXTURE_2D, texId[TEXTURE_R_0+i]);

			CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[i^1]);
			CALL_GLPROC(DrawBuffers)(1, g_drawBuffers);
			CALL_GLPROC(UseProgram)(program[1]);
			CALL_GLPROC(Uniform2i)(uniformId[1], w, h);
			glRects(-1,-1, 1, 1);

			i ^= 1;
			w <<= 4;
			h <<= 4;
		};
		
		// compute activator/inhibitor
		for(j=0; j<SCALE_COUNT; j++)
		{
			glBindTexture(GL_TEXTURE_2D, texId[TEXTURE_R_0+i]);
			CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[SCALE_FIRST+j]);
			CALL_GLPROC(DrawBuffers)(1, g_drawBuffers);
			CALL_GLPROC(UseProgram)(program[2]);
			CALL_GLPROC(Uniform2i)(uniformId[2], j, j);
			glRects(-1,-1, 1, 1);
		}

		// multiscale turing pattern
#if defined(PUBLISH) && defined(WIN32)
		QueryPerformanceCounter(&current);
		w = j = (1600 * (int)(current.QuadPart - previous.QuadPart)) / (int)freq.QuadPart;
		previous = current;
#else
		current = glfwGetTime();
		w = j = (int)(1600.0 * (current - previous));
		previous = current;
#endif // PUBLISH
		
		CALL_GLPROC(ActiveTexture)(GL_TEXTURE0);
		glBindTexture( GL_TEXTURE_2D_ARRAY, texId[TEXTURE_ARRAY] );
		
		CALL_GLPROC(ActiveTexture)(GL_TEXTURE1);
		glBindTexture( GL_TEXTURE_2D, texId[TEXTURE_R_2] );
		
		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[UPDATE]);
		CALL_GLPROC(DrawBuffers)(2, g_drawBuffers);
		CALL_GLPROC(UseProgram)(program[3]);
		CALL_GLPROC(Uniform2i)(uniformId[3], w, h);
		glRects(-1,-1, 1, 1);
		
		// find min/max from data
		for(i=1, w=WINDOW_WIDTH, h=WINDOW_HEIGHT; (w!=1) && (h!=1); i^=1)
		{
			glViewport(0, 0, w, h);
			CALL_GLPROC(ActiveTexture)(GL_TEXTURE0);
			glBindTexture(GL_TEXTURE_2D, texId[TEXTURE_MIN_MAX_0+(i^1)]);		
			
			CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[MIN_MAX_FIRST+i]);
			CALL_GLPROC(DrawBuffers)(1, g_drawBuffers);
			CALL_GLPROC(UseProgram)(program[4]);
			CALL_GLPROC(Uniform2i)(uniformId[4], w, h);
			glRects(-1,-1, 1, 1);

			w = (w>>1) + (w&1);
			h = (h>>1) + (h&1);
		}

		// scale data	
		glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);	

		CALL_GLPROC(ActiveTexture)(GL_TEXTURE0);
		glBindTexture( GL_TEXTURE_2D, texId[TEXTURE_MIN_MAX_0+(i^1)] );
		CALL_GLPROC(ActiveTexture)(GL_TEXTURE1);
		glBindTexture( GL_TEXTURE_2D, texId[TEXTURE_R_1] );
	
		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, framebuffer[NORMALIZE]);
		CALL_GLPROC(DrawBuffers)(2, g_drawBuffers);
		CALL_GLPROC(UseProgram)(program[5]);
		glRects(-1,-1, 1, 1);

		// Display result
		w = j;
		CALL_GLPROC(ActiveTexture)(GL_TEXTURE0);
		glBindTexture( GL_TEXTURE_2D, texId[TEXTURE_R_0] );

		CALL_GLPROC(BindFramebuffer)(GL_FRAMEBUFFER, 0);
		glDrawBuffer(GL_BACK);		
		CALL_GLPROC(UseProgram)(program[6]);
		CALL_GLPROC(Uniform2i)(uniformId[6], w, h);
		glRects(-1,-1, 1, 1);
		
#if defined(PUBLISH) && defined(WIN32)
		SwapBuffers(hDC); //wglSwapLayerBuffers( hDC, WGL_SWAP_MAIN_PLANE );
	} while (!GetAsyncKeyState(VK_ESCAPE));
#else
		glfwSwapBuffers(win);
		glfwPollEvents();
	} while((glfwGetKey(win, GLFW_KEY_ESCAPE) != GLFW_PRESS) && !glfwWindowShouldClose(win));
#endif // PUBLISH
	
#if !defined(PUBLISH)
	for(i=0; i<PROGRAM_COUNT; i++)
	{
		glCleanup.DeleteProgram(program[i]);
	}

	glDeleteTextures(TEXTURE_COUNT, texId);
	glCleanup.DeleteFramebuffers(FRAMEBUFFER_COUNT, framebuffer);
#endif // !PUBLISH

#if defined(PUBLISH) && defined(WIN32)
_end_1:
	ChangeDisplaySettings(0, 0);
    ShowCursor(TRUE);
_end_0:
	ExitProcess(0);
#else
	glfwDestroyWindow(win);
	glfwTerminate();

	return 0;
#endif // PUBLISH
}