/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#ifndef PORT_DEFINES_H
#define PORT_DEFINES_H

	//float sfrand (void);
	#define frand()	(rand()/32768.f)

#ifdef WINDOWS_32
	#include <dsound.h>

	#pragma warning (default: 4710)
	#pragma warning (default: 4820)

	#define mtan(a)		tanf(a)

	#ifndef _DEBUG
		float __fastcall fmod_4k(float a, float b);
		float __fastcall pow_4k (float a, float b);
			
		//#define fmodf(x,y)	fmod_4k(x,y)
		//#define powf(x,y)	pow_4k(x,y)
		//#define	srand(a)	mirand = a
	#else
		#define pow_4k(a,b) powf(a,b)
	#endif
	
	#define	APP_EXIT_4K(a) ExitProcess(a)

#elif defined(LINUX)

	// Platform dependent stuff (Linux)
	#include "SDL.h"
	#include "linux/import_functions.h"
	
	float mtan(float x);

	#define tan(x) tan_4k(x)
	#define pow_4k(x,y) powf(x,y)
	#define sin(x) __builtin_sinf(x)
	#define cos(x) __builtin_cosf(x)
	#define sqrt(x) __builtin_sqrtf(x)
	//#define memset(dest, c, count) __builtin_memset(dest, c, count)
		
	#define SWAPBUFFERS_4K()	SDL_GL_SwapBuffers()
	#define GETTICKS_4K()		SDL_GetTicks()
	//#define SLEEP_4K(a)			SDL_Delay(a)
	#define SLEEP_4K(a)
	#define APP_EXIT_4K(a) \
		if (1) { \
			SDL_Quit();			\
			__asm__("xorl %eax, %eax\n\t"	\
					"incl %eax\n\t"	\
					"int $0x80\n\t"); \
		} else (void) 0


	#ifdef FULLSCREEN
		#define OPENGL_INIT_4K \
				SDL_Event my_sdl_event; \
		        import_functions(); \
		        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO); \
		        SDL_SetVideoMode(xres, yres, 32, SDL_OPENGL | SDL_FULLSCREEN); \
		        SDL_ShowCursor(0); 
	#else	
		#define OPENGL_INIT_4K \
				SDL_Event my_sdl_event; \
		        import_functions(); \
		        SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO); \
		        SDL_SetVideoMode(xres, yres, 32, SDL_OPENGL); \
		        SDL_ShowCursor(0); 
	#endif

	#ifdef OUTFILE
		#define SOUND_INIT_4K \
			fout = fopen(OUTFILE, "wb"); \
			SDL_OpenAudio(&desired, NULL); \
	        SDL_PauseAudio(0); 
	#else
		#define SOUND_INIT_4K \
			SDL_OpenAudio(&desired, NULL); \
	        SDL_PauseAudio(0); 
	#endif

	#ifdef DEBUG
		#define APP_MAIN_4K int main(int argc, char **argv)
	#else
		#define APP_MAIN_4K void  __attribute__((noreturn)) _start(void)
	#endif

	#define BEGIN_MAIN_LOOP_4K \
		while(1) { \
			while (SDL_PollEvent(&my_sdl_event)) { \
				if (my_sdl_event.type == SDL_KEYDOWN) \
					goto end_intro; \
			}

	#define END_MAIN_LOOP_4K \
		} \
		end_intro:
#endif


#endif // defined(PORT_DEFINES_H)
