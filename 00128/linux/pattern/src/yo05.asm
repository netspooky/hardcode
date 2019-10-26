; pattern by w23/yolp
; 128 bytes intro for linux
; 	code: w23 (me@w23.ru)
;
; 	somewhat based on (128b) lintro by frag/fsqrt (pzagrebin@gmail.com)
; 		(which in turn is based on (256b) blin elfom by yolp :D)
;
; http://yolp.omgwtf.ru/
;
; greetings to
;	frag/fsqrt
; 	orbitaldecay


%ifndef W
%define W 1280
%define H 800
%endif

BITS 32
%ifndef SAFE
org 40000h
%else
global _start
%endif

; header overlappery by frag/fsqrt
fd_dsp:
	db 7fh, "ELF"	;e_ident	;program header overlapped
	dd 1		;1 = ELFCLASS32	;p_type, 1 = PT_LOAD
	dd 0				;p_offset
	dd $$				;p_vaddr
	dw 2		;e_type		;p_addr
			;2 = ET_EXE
	dw 3		;e_machine
			;3 = EM_386
	dd _start	;e_version	;p_filesz
					;much bigger than actual size but ok
					;should be = p_memsz
	dd _start	;e_entry	;p_memsz
	dd 4		;e_phoff	;p_flags	; this tiny dword is a huge source of PAIN, as 4 means the section is read-only
			;program header offest
_start: ; exactly 8 bytes here for random garbage
	push edx	; 1b	; terminating zero for string
	push "/dsp"	; 5b	; begin storing device string
	jmp short resume ; 2b -- continue running somewhere else
	; = 8bytes!
	dw 0		;e_ehsize, (not! :D) surprisingly can be a zero!
	dw 20h		;e_phentsize
			;pheader size
	dw 1		;e_phnum

; end of essential headers
; what's left is related to section headers, which are none
	; e_shentsize
	; e_shnum
	; e_shstrndx

resume:
	;eax = ebx = ecx = edx = esi = edi = 0
	push "/dev"	; complete string

; open("/dev/dsp", O_RDWR)
	mov ebx, esp
	mov cl, 2	;O_RDWR
	mov al, 5	; open syscall
	int 80h		;eax <- fd
	push eax ; store for later

; open("/dev/fb0", O_RDRW);
	mov	al, 5			; open
	mov dword [ebx+4], "/fb0"	; change string to /dev/fb0
	int 80h		;eax <- fd

	;mmap(NULL, buflen, PROT_WRITE, MAP_SHARED, fd, 0);
	push edx	;offset, edx = 0
	push eax	;fd
	push byte 1	;MAP_SHARED
	mov al, 90	;mmap syscall number
	push eax	; flags
		;we need to set second bit for PROT_WRITE, 90 = 01011010
		;and setting PROT_WRITE automatically set PROT_READ
	push W*H*4	; framebuffer size (will be reused later)
	push edx	;desired address (edx = 0)
	mov ebx, esp	;args pointer
	int 80h		;eax <- buffer pointer
	pop edx ; skip zero, so stack top = fb size

	; store framebuffer address
	push eax

; now stack contains:
	; fb addr
	; fb size
	; 16 bytes of unreusable garbage
	; dsp fd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mainloop:

	; pick up and store for next loop
	pop edi		; fb addr
	pop ecx 	; fb size
	push ecx
	push edi

	push esi ;store sample counter

	; generate shit
genloop:
	mov eax, esi

	; all this intro is located in these three tiny instructions
	; everything else is just a framework
	shr eax, 11
	add eax, esi
	mul esi

; good but <s>8</s><s>7</s>4 bytes more than limit
;	shr eax, 9
;	mov ebx, esi
;	shr ebx, 13
;	or eax, ebx
;	mul esi


	; store and increment sample count
	stosb
	inc esi
	loop genloop

	; restore sample counter
	pop esi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; write samples
sndplay:
; write syscall
	pop	ecx					; ecx = buffer ptr, (push2)
	push ecx
	mov	ebx, [esp+24]		; ebx = fd_dsp
	push 	4
	pop	eax					; eax = __NR_write = 4
	cdq	; edx = 0
	inc	dh					; edx = count = 256
	add esi, edx	; sample counter += 256
	int 0x80

	jmp short mainloop
