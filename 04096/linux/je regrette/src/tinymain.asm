; The main program

	bits	32

        extern	MDL_Init,MDL_OpenAudio,MDL_PauseAudio
        extern  MDL_SetVideoMode,MDL_PollEvent,MDL_GL_SwapBuffers
        extern  MDL_GetTicks,MDL_ShowCursor,MDL_Quit

        extern  init,osa,dyn_init,syna_init,syna_play
        global	_start,quit
	section	.text
_start:
	call	syna_init
        call    dyn_init

	xor	eax,eax
	mov	al,031h
	push	eax
	call	[MDL_Init]

	xor	eax,eax
        push	eax
	mov	eax,osote
        push	eax
        call	[MDL_OpenAudio]

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
        call    [MDL_SetVideoMode]

	call	init
	xor	eax,eax
        push	eax
        call    [MDL_ShowCursor]
        call	[MDL_PauseAudio]
        call    [MDL_GetTicks]
        mov     [orig],eax

jumi:	call    [MDL_GetTicks]
        sub     eax,[orig]
        push    eax
        call    osa
        pop     ebx
        dec     al
        jnz     jumi

        call    [MDL_GL_SwapBuffers]

        cmp     byte [quit],0
        jne     done

        mov     eax,strukt
        push    eax
        call    [MDL_PollEvent]
        pop     eax
        cmp     byte [strukt],2
        jne     jumi

done:   call    [MDL_Quit]
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
