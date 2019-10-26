BITS 32
%define origin		0x8048000
%define width		1280
%define height		720
%define iters		200000
ORG origin




elfheader:
	
max	db 0x7F, "ELF" 		;e_ident
	db 1
	db 1
	db 1
vol	db 0
	db 0
	dw 0
	db 0
xx	db 0
	db 0
	db 0
	db 0

x	dw 2			;e_type
	dw 3			;e_machine
x2	dd 1			;e_version
yy	dd _start		;e_entry
y	dd pgrheader-origin	;e_phoff
y2	dd 0			;e_shoff
screen	dd 0			;e_flags
	dw elfheadersize	;e_ehsize
	dw pgrsize		;e_phentsize
	dw 3			;e_phnum
	dw 0			;e_shentsize
audio	dw 0			;e_shnum
	dw 0			
elfheadersize equ $ - elfheader


pgrheader:

	;PT_INTERP header	
c2	dd 3			;p_type
	dd interp-origin	;p_offset
	dd interp		;p_vaddr
x2s	dd 0			;p_paddr
	dd interpsize		;p_filesize
 	dd interpsize		;p_memsz
	dd 4 			;p_flags
i	dd 0 			;p_align
pgrsize equ $ - pgrheader

	;PT_LOAD header
a2	dd 1			;p_type
ii	dd 0 			;p_offset
	dd origin		;p_vaddr
	dd 0			;p_paddr
 	dd filesize		;p_filesz
	dd memsize		;p_memsz
	dd 7			;p_flags - 0x1=x, 0x2=w, 0x4=r
	dd 0x2000		;p_align - dangerous, should be 0x1000			

	;PT_DYNAMIC header
b2	dd 2			;p_type
	dd dynamic-origin	;p_offset
	dd dynamic		;p_vaddr
c	dd 0			;p_paddr
	dd dynamicsize		;p_filesize
	dd dynamicsize		;p_memsz
kuus	dd 6			;p_flags
	dd 0x4			;p_align



interp:
	db "/lib/ld-linux.so.2",0
interpsize equ $-interp

dynamic:
	dd 1			; DT_NEEDED
	dd libsdl-strtable
	dd 5			; DT_STRTAB
	dd strtable
	dd 10			; DT_STRSZ
	dd strsize
mqheight dd 6			; DT_SYMTAB
	dd symtable
	dd 11			; DT_SYMENT
	dd 16
dsd	dd 17			; DT_REL
	dd relt
	dd 18			; DT_RELSZ
	dd relsize
	dd 19			; DT_RELENT
thou	dd 8
	dd 0			; DT_NULL
dynamicsize equ $-dynamic

div3	dw 128
divs	dw 0x2000
div2	dw 0x0100

;8192
;256
strtable:
	db 0
libsdl:
 ;;; 	db "libSDL.so", 0
 	db "libSDL-1.2.so.0",0
sdl_init:
	db "SDL_Init",0
sdl_setvideomode:
	db "SDL_SetVideoMode",0
sdl_showcursor:
	db "SDL_ShowCursor",0
sdl_openaudio:
	db "SDL_OpenAudio",0
sdl_pauseaudio:
	db "SDL_PauseAudio",0
sdl_getticks:
	db "SDL_GetTicks",0
sdl_flip:
	db "SDL_Flip",0
sdl_pollevent:
	db "SDL_PollEvent",0
sdl_closeaudio:
	db "SDL_CloseAudio",0
strsize equ $ - strtable



symtable:
sdl_event	resb 16
ssdl_init equ ($ - symtable)/16
	dd sdl_init-strtable		; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_closeaudio equ ($ - symtable)/16
	dd sdl_closeaudio-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_showcursor equ ($ - symtable)/16
	dd sdl_showcursor-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_setvideomode equ ($ - symtable)/16
	dd sdl_setvideomode-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_getticks equ ($ - symtable)/16
	dd sdl_getticks-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_flip equ ($ - symtable)/16
	dd sdl_flip-strtable		; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_pollevent equ ($ - symtable)/16
	dd sdl_pollevent-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_openaudio equ ($ - symtable)/16
	dd sdl_openaudio-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX
ssdl_pauseaudio equ ($ - symtable)/16
	dd sdl_pauseaudio-strtable	; ST_NAME
	dd 0				; ST_VALUE
	dd 0				; ST_SIZE
	db 00010010b			; ST_INFO
	db 0				; ST_OTHER
	dw 0				; ST_SHNDX


relt:
rsdlinit:
	dd SDL_Init				; R_OFFSET
	dd 0x00000001+0x100*ssdl_init		; R_INFO
rsdlcloseaudio:
	dd SDL_CloseAudio			; R_OFFSET
	dd 0x00000001+0x100*ssdl_closeaudio	; R_INFO
rsdlshowcursor:
	dd SDL_ShowCursor			; R_OFFSET
	dd 0x00000001+0x100*ssdl_showcursor	; R_INFO
rsdlsetvideomode:
	dd SDL_SetVideoMode			; R_OFFSET
	dd 0x00000001+0x100*ssdl_setvideomode	; R_INFO
rsdlgetticks:
	dd SDL_GetTicks				; R_OFFSET
	dd 0x00000001+0x100*ssdl_getticks	; R_INFO
rsdlflip:
	dd SDL_Flip				; R_OFFSET
	dd 0x00000001+0x100*ssdl_flip		; R_INFO
rsdlpollevent:
	dd SDL_PollEvent			; R_OFFSET
	dd 0x00000001+0x100*ssdl_pollevent	; R_INFO
rsdlopenaudio:
	dd SDL_OpenAudio			; R_OFFSET
	dd 0x00000001+0x100*ssdl_openaudio	; R_INFO
rsdlpauseaudio:
	dd SDL_PauseAudio			; R_OFFSET
	dd 0x00000001+0x100*ssdl_pauseaudio	; R_INFO
relsize equ $ - relt

SDL_Init dd 0
SDL_SetVideoMode dd 0
SDL_ShowCursor dd 0
SDL_OpenAudio dd 0
SDL_PauseAudio dd 0
SDL_GetTicks dd 0
SDL_Flip dd 0
SDL_PollEvent dd 0
SDL_CloseAudio dd 0

%macro call_next 0
	lodsd
	call	eax
%endmacro

_start:
	
	lea esi, [SDL_Init]

	push byte 0x20
	call_next

	
	
	push dword ( 80000000h )		; SDL_DOUBLEBUF
	push dword 32				; bpp
	push dword height			; Y
	push dword width			; X
	call_next				;[SDL_SetVideoMode]
	push eax
	
	
	mov ebx,dword[eax+14h]			; set pixel pointer to ebx
	mov dword[screen],eax			; save screen pointer

	push dword 0
	call_next				;[SDL_ShowCursor]
	
	push dword audio_specs
	push dword audio_specs
	call_next				;[SDL_OpenAudio]
	
	push dword 0
	call_next 				;[SDL_PauseAudio]

	sub	esp,6*4		;allocate room for (xx x x2 yy y y2)
	mov	edi,esp
	add	edi,8

	
	main_loop:
		lea	esi,[SDL_GetTicks]
		call_next
		push	eax

		mov	ecx,width*height*4
		clearscreen:
			mov	byte[ebx+ecx-1],0
		loop clearscreen
		
		finit

		
		fild	dword[esp]
		fidiv	dword[thou-2]
		fst	dword[edi-4]
		fst	dword[edi+4*2]
		

		fldz
		fstp	dword[edi+4*3]
		fld	dword[max]
		fidiv	word[thou-1]
		fstp	dword[edi]
		fldln2
		fstp	dword[c]
	

		mov	ecx,iters
		iterate:
			
			fld	dword[edi+4*2]
			fmul	dword[b]
			fsin

			fld	st1
			fsin
			fadd	dword[edi-4]
			fadd	dword[max]
			fsin
			

			fld	dword[edi-4]
			fmul	dword[b]
			fsin
			fldln2
			cmp	word[esp],35780
			jna	noswi
				fld	st3
				fsin
				faddp	st1
				cmp	word[esp],45700
				ja	noswi
				push	word 10000
				pop	word[divi]
			noswi:
			fmulp	st1

			faddp	st2
			faddp	st1
			



			fild	dword[b2]	;sqrt(abs(b2*x2-1-c2))
			fmul	dword[edi]
			fld1
			fsubp	st1
			fild	dword[c2]
			fsubp	st1
			frndint
			fabs
			fsqrt
%if 1
			fld1
			fsubr	dword[edi]
			ficomp	dword[x2s]
			fstsw	ax
			sahf
			ja	pos			

			fldz
			fld1
			fsubp
			fmulp	st1
%endif

			pos:
		
			fld1
			faddp	st1
			fsubr	dword[edi+4*3]

			
			
			


			fld	dword[edi-4]
			fmul	dword[a]
			fsin

			fld	st2
			fmul	dword[freqs+4]
			fadd	dword[edi-4]
			fadd	dword[max]
			fsin
			

			fld	dword[edi+4*2]
			fmul	dword[a]
			fsin
			fld	dword[c]
			cmp	word[esp],51000
			jna	skit
				push	ecx
				fild	dword[esp]
				fmul	dword[freqs+4]
				pop	ecx
				fsin
				faddp	st1
				fst	dword[c]
		skit:	fmulp	st1

			faddp	st2
			faddp	st1


			fld1
			fadd	dword[edi]
			fisubr	dword[a2]





			mov	edx,3
			do:
			fst	dword[edi+edx*4]
			fidiv	word[divi]
			fxch	st1
			dec	edx
			
			cmp	dword[esp],23080
			jg	chn
		nochn:	fidiv	dword[b2]
			faddp	st1
			fst	dword[edi+edx*4]
			push	word height/3
			pop	word[mqheight]
			jmp	short chnend
		chn:	cmp	dword[esp],51000
			jg	nochn
			push	word 501
			pop	word[divi]
			push	dword 16048
			pop	dword[thou-2]
			push	word height/4
			pop	word[mqheight]
			fst	dword[edi+edx*4]
			faddp	st1
		chnend: dec	edx
			fimul	word[mqheight]
			fistp	dword[edi+edx*4]
			dec	edx
			jz	do
			


			mov	eax,dword[edi-4*2]	;check if coordinates on screen range
			add	eax,width/2
			mov	dword[edi-4*2],eax
			js	cont
			cmp	eax,width-1
			jnl	cont			

			mov	eax,dword[edi+4]
			add	eax,height/2
			mov	dword[edi+4],eax
			js	cont
			cmp	eax,height-1
			jnl	cont






			imul	eax,dword[edi+4],width
			add	eax,dword[edi-4*2]
			imul	eax,eax,4
			
			mov	edx,ecx
			shr	edx,13
			shl	edx,16
			add	edx,25
			add	dword[ebx+eax],edx
		
		cont:
		dec	ecx
		jnz	iterate



		push dword[screen]
		call_next		;[SDL_Flip]
		
		pop	eax
		pop	eax
		cmp	eax,59200
		jg	exit
		

		check_esc:
			push dword sdl_event
			call [SDL_PollEvent]
			sub esi, byte 4
			add esp, byte 4
			test al,al
			jz main_loop

			mov al,[sdl_event]
			cmp al, byte 0x2
			jne check_esc

			mov al,[sdl_event+8]
			cmp al, byte 0x1b
			jne check_esc


	exit:
	call [SDL_CloseAudio]
	mov eax,1		;EXIT
	mov ebx,4
	int 80h




divi	dw	128

full	dw	0x4fff

a	dd	-0.966918
b	dd	2.879879

freqs	dd	1.0			;+- 0
	dd	0.79370052598		; - 4
	dd	0.89089871714		; - 2
	dd	0.749409557		; - 5
;524288
audio_specs:	
freq	dd	44100		;frequency
	dw	0x8010		;sample format = AUDIO_S16
	db	2		;channels
	db	0		;silence buffer, not used
	dw	1024		;sample count
	dw	0
	dd	0
	dd	audio_callback	;audio callback function
	dd	0		;user data, passed to callback function, not used
;1.059463094359
audio_callback:
	push	ebp
	mov	ebp, esp
	mov	esi,[ebp+12]	;audio_buffer
	fldz
	fstp	dword[max]
	
	fill_loop:
		inc	dword[audio]
		mov	eax,dword[audio]
		shr	eax,19
		test	al,00001000b
		jz	pla
		xor	eax,eax
	pla:	and	al,00000011b
		
		push	dword[audio]
		and	dword[esp],0x0007ffff
		fild	dword[esp]
		pop	edx
		fmul	dword[freqs+eax*4]

		
		fld	st0
		fld	st0
		fldz
		mov	edx,3
	waves:	fxch	st1
		fidiv	word[div3-2+edx*2]
		fsin
		faddp	st1
		dec	edx
		jnz	waves
		fcos
		
		
		fild	dword[audio]
		fidiv	dword[dsd-2]
		fsin
		mov	eax,dword[audio]
		shr	eax,21
		jz	envdon
		fidiv	dword[kuus]
		fld1
		faddp	st1
		envdon:
		fmulp	st1



		fcom	dword[max]
		fstsw	ax
		sahf
		jna	co
		fst	dword[max]
		co:

		fimul	word[full]
		fistp	word[esi]

		
		add	esi,2
		dec	dword[ebp+16]
		dec	dword[ebp+16]
		jnz	fill_loop
		

	pop	ebp
	ret



filesize equ $ - origin

memsize equ $ - origin+3





