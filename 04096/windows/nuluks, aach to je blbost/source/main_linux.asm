; this is buggy

bits 32

%define FULLSCREEN_

section .text

extern dlopen, dlsym, intro_init, intro_run, dlerror, synth_init, synth_render

global _start

player_render:
	push	ebp 
	mov	ebp,esp
	
	pop	ebp
	ret

_start:

	mov	esi,names
	mov	edi,funcs
.lib	lodsd
	or	eax,eax
	jz	.nolib
	push	dword 0x0102
	push	eax
	call	dlopen
	mov	ebp,eax
	pop	eax
	pop	eax
.func	lodsd
	or	eax,eax
	jz	.lib
	push	eax
	push	ebp
	call	dlsym
.store 	stosd
	pop	eax
	pop	eax
	jmp	.func
.nolib

	push	dword 0x00000031
	call	[_SDL_Init]

	xor	eax,eax
	push	eax
	push	dword aspec
	call	[_SDL_OpenAudio]

%ifdef FULLSCREEN
	push	dword 0x80000003
%else
	push	dword 0x00000003
%endif
	push	dword 32
	push	dword 480
	push	dword 640
	call	[_SDL_SetVideoMode]

	call	intro_init
	call	synth_init

	xor	eax,eax
	push	eax
	call	[_SDL_ShowCursor]
	call	[_SDL_PauseAudio]

	call	[_SDL_GetTicks]
	mov	[start],eax
	
.loop	call	[_SDL_GetTicks]
	sub	eax,[start]

	cmp	eax,60938
	jg	.done

	push	eax
	call	intro_run
	pop	eax

	call	[_SDL_GL_SwapBuffers]

	push	event
	call	[_SDL_PollEvent]
	pop	eax

	cmp	byte [event],2
	jne	.loop

.done	call	[_SDL_Quit]

	xor	eax,eax
	inc	eax
	xor	ebx,ebx
	int	0x80

section .data

aspec	dd	44100	
	dw	8010h	
	db	1	
	db	0	
	dw	1024
	dw	0
	dd	0
	dd	synth_render
	dd	0

section .bss

event	resb	24
start	resd	1

section .text

global _glBegin, _glEnd, _glVertex3f, _glClearColor, _glClear, _glEnable, _glMatrixMode, _glLoadIdentity, _glFrustum, _glColor3ub, _glTranslatef
global _glGenTextures, _glBindTexture, _glTexImage2D, _glTexParameteri, _glRotatef, _glTexCoord2f, _glBlendFunc, _glScalef, _glFogf

section .data

names			dd	.libGL, .glBegin, .glEnd, .glVertex3f, .glClear, .glClearColor, .glEnable, .glMatrixMode, .glLoadIdentity,
			dd 	.glFrustum, .glColor3ub, .glTranslatef,.glGenTextures, .glBindTexture, .glTexImage2D, .glTexParameteri,
			dd	.glTexCoord2f, .glRotatef, .glBlendFunc, .glScalef, .glFogf, 0
			dd	.libpthread, 0
			dd	.libSDL, .SDL_Init, .SDL_Quit, .SDL_OpenAudio, .SDL_PauseAudio, .SDL_PollEvent, .SDL_ShowCursor, .SDL_GetTicks
			dd     	.SDL_GL_SwapBuffers, .SDL_SetVideoMode, 0
			dd	0

.libGL			db	"libGL.so",0
.glBegin		db	"glBegin",0
.glEnd			db	"glEnd",0
.glVertex3f		db	"glVertex3f",0
.glClear		db	"glClear",0
.glClearColor		db	"glClearColor",0
.glEnable		db	"glEnable",0
.glMatrixMode		db	"glMatrixMode",0
.glLoadIdentity		db	"glLoadIdentity",0
.glFrustum		db	"glFrustum",0
.glColor3ub		db	"glColor3ub",0
.glTranslatef		db	"glTranslatef",0
.glGenTextures		db	"glGenTextures",0
.glBindTexture		db 	"glBindTexture",0
.glTexImage2D		db	"glTexImage2D",0
.glTexParameteri	db	"glTexParameteri",0
.glTexCoord2f		db	"glTexCoord2f",0
.glRotatef		db	"glRotatef",0
.glBlendFunc		db	"glBlendFunc",0
.glScalef		db	"glScalef",0
.glFogf			db	"glFogf",0
.libpthread		db	"libpthread.so",0
.libSDL			db	"libSDL.so",0
.SDL_Init		db	"SDL_Init",0
.SDL_Quit		db	"SDL_Quit",0
.SDL_OpenAudio		db	"SDL_OpenAudio",0
.SDL_PauseAudio		db	"SDL_PauseAudio",0
.SDL_PollEvent		db	"SDL_PollEvent",0
.SDL_ShowCursor		db	"SDL_ShowCursor",0
.SDL_GetTicks		db	"SDL_GetTicks",0
.SDL_GL_SwapBuffers	db	"SDL_GL_SwapBuffers",0
.SDL_SetVideoMode	db	"SDL_SetVideoMode",0

section .bss

funcs
_glBegin		resd	1
_glEnd			resd	1
_glVertex3f		resd	1
_glClear		resd	1
_glClearColor		resd	1
_glEnable		resd	1
_glMatrixMode		resd	1
_glLoadIdentity		resd	1
_glFrustum		resd	1
_glColor3ub		resd	1
_glTranslatef		resd	1
_glGenTextures		resd	1
_glBindTexture		resd	1
_glTexImage2D		resd	1
_glTexParameteri	resd	1
_glTexCoord2f		resd	1
_glRotatef		resd	1
_glBlendFunc		resd	1
_glScalef		resd	1
_glFogf			resd	1
_SDL_Init		resd	1
_SDL_Quit		resd	1
_SDL_OpenAudio		resd	1
_SDL_PauseAudio		resd	1
_SDL_PollEvent		resd	1
_SDL_ShowCursor		resd	1
_SDL_GetTicks		resd	1
_SDL_GL_SwapBuffers	resd	1
_SDL_SetVideoMode	resd	1



