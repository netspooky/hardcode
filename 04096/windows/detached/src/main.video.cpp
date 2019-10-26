// INCLUDES
//---------
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "synth.h"
#include <GL/gl.h>
#include "glext.h"
#include "intro_small.h"
#include <vfw.h>

// CONFIG
//-------
#define FPS			60
#define MOTION_BLUR	2
#define SCREENWIDTH 1920
#define SCREENHEIGHT 1080
#define ASPECTOFFSET ((float(SCREENWIDTH) / float(SCREENHEIGHT) - 1.0f) * 0.5f)

typedef struct
{
	PAVISTREAM         m_ps;
	PAVISTREAM	       m_psCompressed;
	PAVISTREAM	       m_psAudio;
	AVISTREAMINFO      m_strhdr;
	AVICOMPRESSOPTIONS m_opts;
	PAVIFILE	       m_pfile;
	BITMAPINFOHEADER   m_alpbi;
} AVIWRITER;

static AVIWRITER avi;
static int frame = 0;
static GLushort tempBuffer[3 * SCREENWIDTH * SCREENHEIGHT];
static GLubyte data[3 * SCREENWIDTH * SCREENHEIGHT];

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

static PFNGLCREATESHADERPROGRAMEXTPROC glCreateShaderProgramEXT;
static PFNGLUSEPROGRAMPROC glUseProgram;
static PFNGLUNIFORM4FPROC glUniform4f;

static FAKEDEVMODE devmode = {
	"", 0, 0, sizeof(devmode), 0, DM_PELSWIDTH | DM_PELSHEIGHT, 0, 0, PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "", 0, 0, SCREENWIDTH, SCREENHEIGHT, 0, 0
};

static const char* sglCreateShaderProgramEXT = "glCreateShaderProgramEXT";
static const char* sglUseProgram = "glUseProgram";
static const char* sglUniform4f = "glUniform4f";

#define shaderCountOffset 14

#define ATOM_EDIT 0xC018
#define ATOM_STATIC 0xC019

#define SCENE_LENGTH (SAMPLES_PER_TICK * 128)

void _cdecl main()
{
	InitSound();
	HWND hWnd = CreateWindowExA(0, (LPCSTR)ATOM_STATIC, 0, WS_VISIBLE | WS_SYSMENU, 0, 0, SCREENWIDTH, SCREENHEIGHT, 0, 0, 0, 0);
	HDC hDC = GetDC(hWnd);

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

	AVIFileInit();
	AVIFileOpen(&avi.m_pfile, "intro.avi", OF_WRITE | OF_CREATE, NULL);

	memset(&avi.m_strhdr, 0, sizeof(avi.m_strhdr));
	avi.m_strhdr.fccType = streamtypeVIDEO;
	avi.m_strhdr.fccHandler = 0;
	avi.m_strhdr.dwScale = 1;
	avi.m_strhdr.dwRate = FPS;
	avi.m_strhdr.dwSuggestedBufferSize = 0;
	SetRect(&avi.m_strhdr.rcFrame, 0, 0, SCREENWIDTH, SCREENHEIGHT);

	AVIFileCreateStream(avi.m_pfile, &avi.m_ps, &avi.m_strhdr);

	memset(&avi.m_strhdr, 0, sizeof(avi.m_strhdr));
	avi.m_strhdr.fccType = streamtypeAUDIO;
	avi.m_strhdr.dwScale = WaveFMT.nBlockAlign;
	avi.m_strhdr.dwRate = WaveFMT.nSamplesPerSec * WaveFMT.nBlockAlign;
	avi.m_strhdr.dwSampleSize = WaveFMT.nBlockAlign;
	avi.m_strhdr.dwQuality = (DWORD)-1;
	SetRect(&avi.m_strhdr.rcFrame, 0, 0, SCREENWIDTH, SCREENHEIGHT);

	AVIFileCreateStream(avi.m_pfile, &avi.m_psAudio, &avi.m_strhdr);
	AVIStreamSetFormat(avi.m_psAudio, 0, &WaveFMT, sizeof(WAVEFORMATEX));

	// Display "choose codec" dialog, allow user to cancel
	auto ops = &avi.m_opts;
	if (AVISaveOptions(hWnd, 0, 1, &avi.m_ps, &ops) == FALSE)
	{
		ExitProcess(0);
	}

	AVIMakeCompressedStream(&avi.m_psCompressed, avi.m_ps, &avi.m_opts, NULL);

	memset(&avi.m_alpbi, 0, sizeof(avi.m_alpbi));
	avi.m_alpbi.biSize = sizeof(avi.m_alpbi);
	avi.m_alpbi.biWidth = SCREENWIDTH;
	avi.m_alpbi.biHeight = SCREENHEIGHT;
	avi.m_alpbi.biPlanes = 1;
	avi.m_alpbi.biBitCount = 24;
	avi.m_alpbi.biCompression = BI_RGB;

	AVIStreamSetFormat(avi.m_psCompressed, 0, &avi.m_alpbi, sizeof(avi.m_alpbi));

	int sample = 0;
	do
	{
		sample = ((float)frame / (float)(FPS * MOTION_BLUR)) * SAMPLE_RATE;
		float fTime = (float)sample / SCENE_LENGTH;

		glUseProgram((int)fTime + 1);

		int i = ((sample >> 8) << 5) + 2 * 2;
		float* a = &_4klang_envelope_buffer;
		float aha = a[i] + a[i + 1];

		glUniform4f(0, fTime, SCREENHEIGHT, ASPECTOFFSET, aha);
		glRecti(-1, -1, 1, 1);
		SwapBuffers(hDC);

		::PeekMessage(0, 0, 0, 0, 0);

		glReadPixels(0, 0, SCREENWIDTH, SCREENHEIGHT, GL_BGR_EXT, GL_UNSIGNED_BYTE, data);

		for (int i = 0; i < SCREENWIDTH * SCREENHEIGHT * 3; ++i)
		{
			tempBuffer[i] += data[i];
		}

		if ((frame++ % MOTION_BLUR) == 0)
		{
			for (int i = 0; i < SCREENWIDTH * SCREENHEIGHT * 3; ++i)
			{
				data[i] = (tempBuffer[i] / MOTION_BLUR);
				tempBuffer[i] = 0;
			}

			AVIStreamWrite(avi.m_psCompressed, (frame - 1) / MOTION_BLUR, 1, data, 3 * SCREENWIDTH * SCREENHEIGHT, AVIIF_KEYFRAME, NULL, NULL);
		}

	} while (sample < MAX_SAMPLES && !GetAsyncKeyState(VK_ESCAPE));

	auto const extraSamples = 0;// SOUND_TICKS_PER_SCENE * SAMPLES_PER_TICK / 4;
	static SAMPLE_TYPE audioBuffer[2 * (MAX_SAMPLES + extraSamples)];
	memcpy(audioBuffer + extraSamples * 2, WaveHDR.lpData, WaveHDR.dwBufferLength);
	AVIStreamWrite(avi.m_psAudio, 0, MAX_SAMPLES + extraSamples, audioBuffer, WaveHDR.dwBufferLength + extraSamples * sizeof(SAMPLE_TYPE) * 2, 0, NULL, NULL);

	AVIStreamClose(avi.m_ps);
	AVIStreamClose(avi.m_psCompressed);
	AVIStreamClose(avi.m_psAudio);
	AVIFileClose(avi.m_pfile);
	AVIFileExit();
}
