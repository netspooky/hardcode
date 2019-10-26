// HACKS - Don't use unless you're really in desperate size problems 
//------------------------------------------------------------------
//#define WAVHDR_PREPARE_HACK

// FEATURES - Use whenever you can, at the expense of some size
//-------------------------------------------------------------
#define SHADER_WARMUP
#define START_BLACK

// INCLUDES
//---------
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "synth.h"
#include <GL/gl.h>
#include "glext.h"

// CONFIGURATION
//---------------
//#define WINDOWED

#ifndef SCREENWIDTH
#define SCREENWIDTH 1280
#endif

#ifndef SCREENHEIGHT
#define SCREENHEIGHT 720
#endif

#ifndef ASPECTOFFSET
#define ASPECTOFFSET ((float(SCREENWIDTH) / float(SCREENHEIGHT) - 1.0f) * 0.5f)
#endif

#define shaderCountOffset 14
#define ATOM_EDIT 0xC018
#define ATOM_STATIC 0xC019
#define SCENE_LENGTH (SAMPLES_PER_TICK * 128)

#pragma data_seg(".aspectOffset")
static const float gfAspectOffset = ASPECTOFFSET;

#pragma data_seg(".scebeLength")
static const int giSceneLength = SCENE_LENGTH;

#pragma data_seg(".Shader0")
#include "intro_small.h"

struct FAKEDEVMODE
{
	BYTE _a[36];
	DWORD dmSize;
	DWORD dmFields;
	struct
	{
		BYTE  _b[4];
		DWORD pfdFlags;
	} pfd;
	BYTE _c[56];
	DWORD width;
	DWORD height;
	BYTE  _d[8];
};

#pragma data_seg(".devmode")
static FAKEDEVMODE devmode = {
	"", sizeof(devmode), DM_PELSWIDTH | DM_PELSHEIGHT, "", PFD_DOUBLEBUFFER | PFD_SUPPORT_OPENGL, "", SCREENWIDTH, SCREENHEIGHT, ""
};

#pragma data_seg("fcw")
static WORD fcw = 0x0E7f;

#pragma data_seg(".fltused")
int _fltused = 1;

#pragma data_seg(".glCreateShaderProgramEXT")
static const char* sglCreateShaderProgramEXT = "glCreateShaderProgramEXT";

#pragma data_seg(".glUseProgram")
static const char* sglUseProgram = "glUseProgram";

#pragma data_seg(".glUniform4f")
static const char* sglUniform4f = "glUniform4f";

#pragma code_seg(".main")
void _cdecl main()
{		
	_asm
	{
		fldcw [fcw]

		xor esi, esi

		push esi
		push esi
		push esi
		push esi

#ifndef	WINDOWED
		push esi
		push esi
		push esi
		push esi
		push WS_POPUP | WS_VISIBLE | WS_MAXIMIZE
		push esi
		push ATOM_STATIC
		push esi
		push CDS_FULLSCREEN
		push offset devmode
		push esi
		push esi
		push offset lpSoundBuffer
		push _4klang_render
		push esi
		push esi
		call CreateThread
		call ChangeDisplaySettings
		call CreateWindowExA
#else
		push SCREENHEIGHT
		push SCREENWIDTH
		push esi
		push esi
		push WS_POPUP | WS_VISIBLE
		push esi
		push ATOM_STATIC
		push esi
		push esi
		push esi
		push offset lpSoundBuffer
		push _4klang_render
		push esi
		push esi
		call CreateThread
		call CreateWindowExA
#endif			

		push eax
		call GetDC
		mov edi, eax

		push esi
#ifdef START_BLACK
		push edi
#endif
		push edi
		push esi
		push offset devmode.pfd
		push edi
		call ChoosePixelFormat
		push eax
		push edi
		call SetPixelFormat
		call wglCreateContext
		push eax
		push edi
		call wglMakeCurrent
#ifdef START_BLACK
		call SwapBuffers
#endif
		call ShowCursor

		xor ebx, ebx

	shaderwarmup :
#ifdef SHADER_WARMUP
		push 1
		push 1
		push -1
		push -1
#endif
		push offset intro_fs
		push GL_FRAGMENT_SHADER
		push sglCreateShaderProgramEXT
		call wglGetProcAddress
		call eax
#ifdef SHADER_WARMUP
		push eax
		push sglUseProgram
		call wglGetProcAddress
		call eax
#endif
		inc byte ptr[intro_fs + shaderCountOffset]

		cmp ebx, 9
		jnz skip
		mov byte ptr[intro_fs + shaderCountOffset], 'A'
	skip:
#ifdef SHADER_WARMUP
		push esi
		push gfAspectOffset
		push dword ptr[devmode.height]
		fild dword ptr[esp]
		fstp dword ptr[esp]
		push ebx
		fild dword ptr[esp]
		fstp dword ptr[esp]
		push esi
		push sglUniform4f
		call wglGetProcAddress
		call eax
		call glRecti
#endif
		inc ebx
		cmp ebx, 12
		jnz shaderwarmup

#ifndef WAVHDR_PREPARE_HACK
		push 0x20
		push offset WaveHDR
#endif
		push 0x20
		push offset WaveHDR
		push esi
		push esi
		push esi
		push offset WaveFMT
		push -1
		push offset hWaveOut
		call waveOutOpen
#ifndef WAVHDR_PREPARE_HACK
		push[hWaveOut]
		call waveOutPrepareHeader
#endif
		push [hWaveOut]
		call waveOutWrite

	mainloop:
		push 0xC
		push offset MMTime
		push [hWaveOut]
		call waveOutGetPosition

		push esi
		push esi
		push esi
		push esi
		push esi
		push edi
		push 1
		push 1
		push -1
		push -1
		push esi

		// 4klang envelope buffer, instrument 2, 2x polyphony
		mov eax, dword ptr[MMTime + 4]
		shr eax, 3
		and eax, 1FFFFFE0h
		movss xmm0, dword ptr _4klang_envelope_buffer + 14h[eax * 4]
		addss xmm0, dword ptr _4klang_envelope_buffer + 10h[eax * 4]
		movss dword ptr[esp], xmm0

		push gfAspectOffset
		push dword ptr[devmode.height]
		fild dword ptr[esp]
		fstp dword ptr[esp]
		push dword ptr[MMTime.u.sample]
		fild dword ptr[esp]
		fild giSceneLength				
		fdiv							
		fst dword ptr[esp]				
		push esi						
		push esi						
		fistp dword ptr[esp]			
		pop eax							
		inc eax
		push eax						
		push sglUseProgram				
		call wglGetProcAddress			
		call eax						

		push sglUniform4f
		call wglGetProcAddress			
		call eax
		call glRecti
		call SwapBuffers
		call PeekMessage

		cmp dword ptr [MMTime+4], MAX_SAMPLES
		jae exit
		push VK_ESCAPE
		call GetAsyncKeyState
		test ax,ax
		je mainloop
	exit:
		push esi
		call ExitProcess
	}
}
