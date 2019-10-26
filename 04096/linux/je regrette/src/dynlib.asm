
        bits    32
        extern  dlopen,dlsym
        global  dyn_init

        global  MDL_Init,MDL_Quit,MDL_SetVideoMode,MDL_OpenAudio
        global  MDL_ShowCursor,MDL_PauseAudio,MDL_GetTicks,MDL_GL_SwapBuffers
        global  MDL_PollEvent

        global  mlBegin,mlEnd,mlVertex3f,mlMatrixMode
        global  mlLoadIdentity,mlClear,mlColor3f
        global  mlRotatef,mlTranslatef,mlEnable,mlDisable
        global  mlLineWidth,mlFrustum

        global	mlBindTexture,mlTexParameteri
	global	mlTexImage2D,mlCopyTexSubImage2D,mlTexCoord2f
        global	mlBlendFunc
        
        section .text
        
dyn_init:
        pushad
        mov     eax,slib
        mov     edi,MDL_Init
        mov     esi,snames
        call    load
        mov     eax,glib
        mov     edi,mlBegin
        mov     esi,gnames
        call    load
        popad
        ret

load:   mov     ebx,2 ; RTLD_NOW
        push    ebx
        push    eax
        call    dlopen
        mov     ebp,eax
        pop     eax
        pop     eax

nexti:  lodsd
        cmp     eax,0
        je      finito
        push    eax
        push    ebp
        call    dlsym
        stosd
        pop     eax
        pop     eax
        jmp     nexti

finito: ret

        section .data
gnames  dd      glBegin,glEnd,glVertex3f,glMatrixMode,
        dd      glLoadIdentity,glClear,glColor3f
        dd      glRotatef,glTranslatef,glEnable,glDisable
        dd      glLineWidth,glFrustum
        dd	glBindTexture,glTexParameteri
	dd	glTexImage2D,glCopyTexSubImage2D,glTexCoord2f
        dd	glBlendFunc
        dd      0

snames  dd      SDL_Init,SDL_Quit,SDL_SetVideoMode,SDL_OpenAudio
        dd      SDL_ShowCursor,SDL_PauseAudio,SDL_GetTicks,SDL_GL_SwapBuffers
        dd      SDL_PollEvent
        dd      0

glib    db      "libGL.so",0
slib    db      "libSDL.so",0

glBegin         db      "glBegin",0
glEnd           db      "glEnd",0
glVertex3f      db      "glVertex3f",0
glMatrixMode    db      "glMatrixMode",0

glLoadIdentity  db      "glLoadIdentity",0
glClear         db      "glClear",0
glColor3f       db      "glColor3f",0

glRotatef	db	"glRotatef",0
glTranslatef	db	"glTranslatef",0
glEnable	db	"glEnable",0
glDisable       db      "glDisable",0

glLineWidth     db      "glLineWidth",0
glFrustum       db      "glFrustum",0

glBindTexture	db	"glBindTexture",0
glTexParameteri	db	"glTexParameteri",0
glTexImage2D	db	"glTexImage2D",0
glCopyTexSubImage2D db	"glCopyTexSubImage2D",0
glTexCoord2f	db	"glTexCoord2f",0
glBlendFunc	db	"glBlendFunc",0

SDL_Init            db  "SDL_Init",0
SDL_Quit            db  "SDL_Quit",0
SDL_SetVideoMode    db  "SDL_SetVideoMode",0
SDL_OpenAudio       db  "SDL_OpenAudio",0

SDL_ShowCursor      db  "SDL_ShowCursor",0
SDL_PauseAudio      db  "SDL_PauseAudio",0
SDL_GetTicks        db  "SDL_GetTicks",0
SDL_GL_SwapBuffers  db  "SDL_GL_SwapBuffers",0

SDL_PollEvent       db  "SDL_PollEvent",0

        section .bss
mlBegin         resd    1
mlEnd           resd    1
mlVertex3f      resd    1
mlMatrixMode    resd    1

mlLoadIdentity  resd    1
mlClear         resd    1
mlColor3f       resd    1

mlRotatef	resd	1
mlTranslatef	resd	1
mlEnable	resd	1
mlDisable       resd    1

mlLineWidth     resd    1
mlFrustum       resd    1

mlBindTexture	resd	1
mlTexParameteri	resd	1
mlTexImage2D	resd	1
mlCopyTexSubImage2D	resd 	1
mlTexCoord2f	resd	1
mlBlendFunc	resd	1

MDL_Init            resd    1
MDL_Quit            resd    1
MDL_SetVideoMode    resd    1
MDL_OpenAudio       resd    1

MDL_ShowCursor      resd    1
MDL_PauseAudio      resd    1
MDL_GetTicks        resd    1
MDL_GL_SwapBuffers  resd    1

MDL_PollEvent       resd    1
