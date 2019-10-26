; Linux port of flow2 by leblane
; Original Windows version by auld: http://sizecoding.blogspot.com

; To compile:
;   nasm -f bin flow2.asm -o flow2
;   chmod a+x flow2
;
; To get it under 1k:
;   gzip flow2
;   advdef -z -4 flow2.gz
;   echo "a=/tmp/I;tail -n+2 \$0|zcat>\$a;chmod +x \$a;\$a;rm \$a;exit" >flow2
;   cat flow2.gz >>flow2
;   chmod a+x flow2

BITS 32
%define origin 0x8048000
ORG origin

%define SYS_exit        1
%define GL_VERTEX_SHADER 0x8B31
%define GL_FRAGMENT_SHADER 0x8B30

ehdr:
				; e_ident
	db 0x7F, "ELF"		;   EI_MAG[0-3]
	db 1			;   EI_CLASS
	db 1			;   EI_DATA
	db 1			;   EI_VERSION

	db 0			;   EI_OSABI
	db 0			;   EI_ABIVERSION
	times 7 db 0		;   EI_PAD
	dw 2			; e_type
	dw 3			; e_machine
	dd 1			; e_version
	dd _start		; e_entry
	dd phdr-origin	 	; e_phoff
	dd 0			; e_shoff
	dd 0 			; e_flags
	dw ehdrsize		; e_ehsize
	dw phdrsize		; e_phentsize
	dw 3			; e_phnum
	dw 0			; e_shentsize
	dw 0			; e_shnum
	dw 0			; e_shstrndx

ehdrsize equ $ - ehdr

phdr:
	;; PT_INTERP header
	dd 3			; p_type
	dd interp-origin	; p_offset
	dd interp		; p_vaddr
	dd 0			; p_addr
	dd interpsize		; p_filesize
	dd interpsize		; p_memsz
	dd 4 			; p_flags
	dd 0 			; p_align
phdrsize equ $ - phdr

	;; PT_LOAD header
	dd 1			; p_type
	dd 0 			; p_offset
	dd origin		; p_vaddr
	dd 0			; p_paddr
	dd filesize		; p_filesz
	dd memsize		; p_memsz
	dd 7			; p_flags - 0x1=x, 0x2=w, 0x4=r
	dd 0x1000		; p_align

	;; PT_DYNAMIC header
	dd 2			; p_type
	dd dynamic-origin	; p_offset
	dd dynamic		; p_vaddr
	dd 0			; p_addr
	dd dynamicsize		; p_filesize
	dd dynamicsize		; p_memsz
	dd 6			; p_flags
	dd 4			; p_align

interp:
	db "/lib/ld-linux.so.2",0
interpsize equ $-interp
strtab:
	db 0
libsdl:
	db "libSDL-1.2.so.0", 0
libgl:
	db "libGL.so.1", 0

dynamic:
	dd 1			; DT_NEEDED
	dd libsdl - strtab
	dd 1			; DT_NEEDED
	dd libgl - strtab
	dd 5			; DT_STRTAB
	dd strtab
	dd 6			; DT_SYMTAB - needed otherwise segfault
	dd 0
	dd 21			; DT_DEBUG
debug:	dd 0
	dd 0			; DT_NULL
dynamicsize equ $-dynamic

_start:
	enter 20, 0

	mov ebx, [debug] ; Pointer to debug structure
	mov ebx, [ebx+4] ; Link map
	mov ebx, [ebx+12]
	mov ebx, [ebx+12]

	mov esi, __import_hash
	mov edi, __import_addr
	mov ecx, __num_imports

.symbol_loop:
	lodsd
	pusha
	call get_symbol
	mov DWORD [esp+28], eax
	popa
	stosd
	loop .symbol_loop

	push 0x00000020 ; SDL_INIT_VIDEO
	call [_SDL_Init]
	add esp, 4

	push 0x80000002 ; SDL_OPENGL | SDL_FULLSCREEN
	push DWORD 0 ; Default bit depth
	push DWORD 768
	push DWORD 1024
	call [_SDL_SetVideoMode]
	add esp, 16

setshaders:
	push DWORD GL_VERTEX_SHADER
	call [_glCreateShader]
	mov [ebp-4], eax
	add esp, 4

	push DWORD GL_FRAGMENT_SHADER
	call [_glCreateShader]
	mov [ebp-8], eax
	add esp, 4

	call [_glCreateProgram]
	mov [ebp-12], eax

	push 0
	push pvsh
	push 1
	push DWORD [ebp-4]
	call [_glShaderSource]
	mov eax, [ebp-8]
	mov [esp], eax
	mov DWORD [esp+8], pfsh
	call [_glShaderSource]
	add esp, 16

	push DWORD [ebp-4]
	call [_glCompileShader]
	mov eax, [ebp-8]
	mov [esp], eax
	call [_glCompileShader]
	add esp, 4

	push DWORD [ebp-4]
	push DWORD [ebp-12]
	call [_glAttachShader]
	mov eax, [ebp-8]
	mov [esp+4], eax
	call [_glAttachShader]
	add esp, 8

	push DWORD [ebp-12]
	call [_glLinkProgram]
	call [_glUseProgram]
	add esp, 4

mainloop:
	call [_SDL_GetTicks]
	mov ebx, eax	
.loop0:
	push DWORD [one]
	push DWORD [one]
	push DWORD [one]
	push DWORD [one] ; This one's a dummy value just to grow the stack, but this will probably compress better than sub esp, 4
	call [_SDL_GetTicks]
	sub eax, ebx
	add ebx, eax
	mov [esp], eax
	fild DWORD [esp]
	fdiv DWORD [speed]
	fstp DWORD [esp]
	call [_glRotatef]
	add esp, 16

	push DWORD 1
	push DWORD 1
	push DWORD -1
	push DWORD -1
	call [_glRecti]
	add esp, 16

	call [_SDL_GL_SwapBuffers]

	lea eax, [ebp-20]
	push DWORD eax
	call [_SDL_PollEvent]
	add esp, 4

	cmp BYTE [ebp-20], 2 ; SDL_KEYDOWN
	jz .loop0end
	cmp BYTE [ebp-20], 12 ; SDL_QUIT
	jz .loop0end
	jmp .loop0
.loop0end:

	call [_SDL_Quit]

	xor eax, eax
	inc eax
	int 0x80

get_dynamic_entry: ; esi: dyn, edi: type, esi contains new pointer
.loop0:
	cmp [esi], edi
	jz .found
	add esi, 8
	jmp .loop0
.found:
	mov esi, [esi+4]
	ret

get_symbol: ; eax: symbol, ebx: link_map
	enter 8, 0
	mov [ebp-8], eax

.libloop:
	test ebx, ebx
	jz .found
	mov [ebp-4], ebx

	mov eax, [ebx+8] ; link_map->l_ld
	mov esi, eax
	mov edi, 5 ; DT_STRTAB
	call get_dynamic_entry
	mov ebx, esi
	mov esi, eax
	mov edi, 6 ; DT_SYMTAB
	call get_dynamic_entry
	mov edx, esi
	mov esi, eax
	mov edi, 4 ; DT_HASH
	call get_dynamic_entry
	mov ecx, [esi+4]

.symbolloop:
	mov esi, [edx] ; st_name
	add esi, ebx ; string table
.hash_symbol:
	xor edi, edi

.loop:
	xor eax, eax
	lodsb
	test al, al
	jz .end

	sub eax, edi
	shl edi, 6
	add eax, edi
	shl edi, 10
	add eax, edi
	mov edi, eax

	jmp .loop
.end:
	cmp edi, [ebp-8]
	jz .found
	add edx, 16
	loop .symbolloop

	mov ebx, [ebp-4]
	mov ebx, [ebx+12]
	jmp .libloop
.found:
	mov eax, [edx+4]
	mov ebx, [ebp-4]
	add eax, [ebx]
	leave
	ret

__num_imports equ 15

__import_hash:
dd 0x070d6574 ; SDL_Init
dd 0x39b85060 ; SDL_SetVideoMode
dd 0x64949d97 ; SDL_PollEvent
dd 0x7eb657f3 ; SDL_Quit
dd 0xda43e6ea ; SDL_GL_SwapBuffers
dd 0xd1d0b104 ; SDL_GetTicks
dd 0x93854326 ; glRotatef
dd 0xd419e200 ; glRecti
dd 0x6b4ffac6 ; glCreateShader
dd 0x078721c3 ; glCreateProgram
dd 0xc609c385 ; glShaderSource
dd 0xc5165dd3 ; glCompileShader
dd 0x30b3cfcf ; glAttachShader
dd 0x133a35c5 ; glLinkProgram
dd 0xcc55bb62 ; glUseProgram

vsh: db "varying vec4 p;void main(){p=sin(gl_ModelViewMatrix[1]*9.0);gl_Position=gl_Vertex;}", 0
fsh: db "varying vec4 p;void main(){float r,t,j;vec4 v=gl_FragCoord/400.0-1.0;r=v.x*p.r;for(int j=0;j<7;j++){t=v.x+p.r*p.g;v.x=t*t-v.y*v.y+r;v.y=p.g*3.0*t*v.y+v.y;}gl_FragColor=vec4(mix(p,vec4(t),max(t,v.x)));}", 0;

pvsh: dd vsh
pfsh: dd fsh

speed:
	dd 200.0
one:
	dd 1.0

filesize equ $ - origin
	; fake bss
ABSOLUTE origin+filesize

__import_addr:
_SDL_Init: resd 1
_SDL_SetVideoMode: resd 1
_SDL_PollEvent: resd 1
_SDL_Quit: resd 1
_SDL_GL_SwapBuffers: resd 1
_SDL_GetTicks: resd 1
_glRotatef: resd 1
_glRecti: resd 1
_glCreateShader: resd 1
_glCreateProgram: resd 1
_glShaderSource: resd 1
_glCompileShader: resd 1
_glAttachShader: resd 1
_glLinkProgram: resd 1
_glUseProgram: resd 1

memsize equ $ - origin
