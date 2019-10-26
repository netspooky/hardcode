
	bits	32
        extern	SDL_Init,SDL_OpenAudio,SDL_PauseAudio,syna_init,syna_play
        extern  SDL_SetVideoMode,SDL_PollEvent,SDL_GL_SwapBuffers
        extern  SDL_GetTicks,SDL_ShowCursor,SDL_Quit
        extern  osa,ml_init
        global	_start,quit
	section	.text
_start:
	call	syna_init
        
	xor	eax,eax
	mov	al,031h
	push	eax
	call	SDL_Init

	xor	eax,eax
        push	eax
	mov	eax,osote
        push	eax
        call	SDL_OpenAudio

%ifdef FULLSCREEN
        mov     eax,80000003h ; Fullscreen
%else
        mov     eax,00000003h
%endif
        push    eax
        xor     eax,eax
        mov     al,32
        push    eax
        mov     ax,480
        push    eax
        mov     ax,640
        push    eax
        call    SDL_SetVideoMode
        
        call    ml_init

	xor	eax,eax
        push	eax
        call    SDL_ShowCursor
        call	SDL_PauseAudio
        call    SDL_GetTicks       
        mov     [orig],eax

jumi:	call    SDL_GetTicks
        sub     eax,[orig]
        push    eax
        call    osa
        pop     eax

        call    SDL_GL_SwapBuffers

        cmp     byte [quit],0
        jne     done

        mov     eax,strukt
        push    eax
        call    SDL_PollEvent
        pop     eax
        cmp     byte [strukt],2
        jne     jumi

done:   call    SDL_Quit
        xor     eax,eax
        inc     al
        xor     ebx,ebx
        int     080h

	section	.data
osote:	dd	44100
	dw	8010h
        db	1
        db	0
        dw	1024
        dw	0
        dd	0
        dd	syna_play
        dd	0

quit:   db      0

        section .bss
orig:   resd    1
strukt: resd    10000
