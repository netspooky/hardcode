#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "synth.h"
#include <GL/gl.h>
#include "glext.h"

#ifndef SCREENWIDTH
#define SCREENWIDTH 1280
#endif

#ifndef SCREENHEIGHT
#define SCREENHEIGHT 720
#endif

#ifndef ASPECTOFFSET
#define ASPECTOFFSET ((float(SCREENWIDTH) / float(SCREENHEIGHT) - 1.0f) * 0.5f)
#endif

#define WINDOWED

#pragma data_seg(".Shader0")
#include "intro_small.h"

struct FAKEPFD
{
	WORD nSize;
	WORD nVersion;
	DWORD dwFlags;
	// Snip
};

struct FAKEDEVMODE
{
	BYTE dmDeviceName[CCHDEVICENAME];
	WORD dmSpecVersion;
	WORD dmDriverVersion;
	WORD dmSize;
	WORD dmDriverExtra;
	DWORD dmFields;
	union {
		/* printer only fields */
		struct {
			short dmOrientation;
			short dmPaperSize;
			short dmPaperLength;
			short dmPaperWidth;
			short dmScale;
			short dmCopies;
			short dmDefaultSource;
			short dmPrintQuality;
		};
		FAKEPFD pfd;
	};
	short dmColor;
	short dmDuplex;
	short dmYResolution;
	short dmTTOption;
	short dmCollate;
	BYTE dmFormName[CCHFORMNAME];
	WORD dmLogPixels;
	DWORD dmBitsPerPel;
	DWORD dmPelsWidth;
	DWORD dmPelsHeight;
	union {
		DWORD dmDisplayFlags;
		DWORD dmNup;
	};
	DWORD dmDisplayFrequency;
};

#pragma bss_seg(".mainbss")
static PFNGLCREATESHADERPROGRAMEXTPROC glCreateShaderProgramEXT;
static PFNGLUSEPROGRAMPROC glUseProgram;
static PFNGLUNIFORM4FPROC glUniform4f;

#pragma data_seg(".devmode")
static FAKEDEVMODE devmode = {
	"", 0, 0, sizeof(devmode), 0, DM_PELSWIDTH | DM_PELSHEIGHT, 0, 0, PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "", 0, 0, SCREENWIDTH, SCREENHEIGHT, 0, 0
};

#pragma data_seg(".fltused")
int _fltused = 1;

#pragma data_seg(".glCreateShaderProgramEXT")
static const char* sglCreateShaderProgramEXT = "glCreateShaderProgramEXT";

#pragma data_seg(".glUseProgram")
static const char* sglUseProgram = "glUseProgram";

#pragma data_seg(".glUniform4f")
static const char* sglUniform4f = "glUniform4f";

#define shaderCountOffset 14

#define ATOM_EDIT 0xC018
#define ATOM_STATIC 0xC019

#define SCENE_LENGTH (SAMPLES_PER_TICK * 128)

#pragma code_seg(".main")
void _cdecl main()
{
	InitSound();

#ifndef	WINDOWED
	ChangeDisplaySettings((DEVMODEA*)&devmode, CDS_FULLSCREEN);
	HDC hDC = GetDC(CreateWindowExA(0, (LPCSTR)ATOM_STATIC, 0, WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0));
#else
	HDC hDC = GetDC(CreateWindowExA(0, (LPCSTR)ATOM_STATIC, 0, WS_VISIBLE | WS_SYSMENU, 0, 0, SCREENWIDTH, SCREENHEIGHT, 0, 0, 0, 0));
#endif

	SetPixelFormat(hDC, ChoosePixelFormat(hDC, (const PIXELFORMATDESCRIPTOR*)&devmode.pfd), 0);
	wglMakeCurrent(hDC, wglCreateContext(hDC));

	glCreateShaderProgramEXT = (PFNGLCREATESHADERPROGRAMEXTPROC)wglGetProcAddress(sglCreateShaderProgramEXT);
	glUseProgram = (PFNGLUSEPROGRAMPROC)wglGetProcAddress(sglUseProgram);
	glUniform4f = (PFNGLUNIFORM4FPROC)wglGetProcAddress(sglUniform4f);

	for (int i = 0; i < 12; ++i)
	{
		glUseProgram(glCreateShaderProgramEXT(GL_FRAGMENT_SHADER, intro_fs));
		intro_fs[shaderCountOffset]++;
		if (i == 9)
		{
			intro_fs[shaderCountOffset] = 'A';
		}
		glUniform4f(0, i, SCREENHEIGHT, ASPECTOFFSET, 0.0f);
		glRecti(-1, -1, 1, 1);
	}

	ShowCursor(FALSE);
	PlaySound();

	do
	{
		get_Sample();

		float fTime = (float)MMTime.u.sample / SCENE_LENGTH;

		glUseProgram((int)fTime + 1);

		int i = ((MMTime.u.sample >> 8) << 5) + 2 * 2;
		float* a = &_4klang_envelope_buffer;
		float aha = a[i] + a[i + 1];

		glUniform4f(0, fTime, SCREENHEIGHT, ASPECTOFFSET, aha);
		glRecti(-1, -1, 1, 1);
		SwapBuffers(hDC);

		::PeekMessage(0, 0, 0, 0, 0);
	} while (MMTime.u.sample < MAX_SAMPLES && !GetAsyncKeyState(VK_ESCAPE));

	ExitProcess(0);
}
