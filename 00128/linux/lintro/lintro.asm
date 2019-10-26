%ifndef W
%define W 1280
%define H 1024
%endif

BITS 32
	org 0		;for the fbpath address trick
			;some kernels dislike zero value

	db 7fh, "ELF"	;e_ident	;program header overlapped
	dd 1		;1 = ELFCLASS32	;p_type, 1 = PT_LOAD
	dd 0				;p_offset
	dd $$				;p_vaddr
	dw 2		;e_type		;p_addr
			;2 = ET_EXE
	dw 3		;e_machine
			;3 = EM_386
	dd start	;e_version	;p_filesz
					;much bigger than actual size but ok
					;should be = p_memsz
	dd start	;e_entry	;p_memsz
	dd 4		;e_phoff	;p_flags
			;program header offest
fbpath:	; = 32
	db "/dev"	;e_shoff	;p_align
	db "/fb0"	;e_flags
	dw 0		;e_ehsize, surprisingly can be a zero!
			;this zero terminates string "/dev/fb0"
	dw 20h		;e_phentsize
			;pheader size
	dw 1		;e_phnum
start:	;code injection
	mov bl, 32	;e_shentsize	;ebx <- fbpath
	mov cl, 2	;e_shnum	;O_RDWR
					;don't know why O_WRONLY don't work
					;potentially it can save one byte by inc ecx
	mov al, 5	;e_shstrndx
	;end of elf header, 52 bytes total
	;OMG! I overlapped pheader with eheader, injected fb path
	;and 6 bytes of code and it still works!

	;eax = ebx = ecx = edx = esi = edi = 0

	;open("/dev/fb0", O_RDRW);
	int 80h		;eax <- fd

	;mmap(NULL, buflen, PROT_WRITE, MAP_SHARED, fd, 0);
	push edx	;edx = 0
	push eax	;fd
	push byte 1	;MAP_SHARED
	mov al, 90
	push eax	;we need to set second bit for PROT_WRITE, 90 = 01011010
			;and setting PROT_WRITE automatically set PROT_READ
	push W*H*4	;buffer size
	push edx	;NULL
	mov ebx, esp	;args pointer
	int 80h		;eax <- buffer pointer
	;after 71 bytes of headers+setup we have frame buffer pointer!

	push eax
	shrd ebx, ecx, 10	;cl = 2, sets red color to 10xxxxxxb
L0:	mov ecx, W*H
	pop edi
	push edi
L:	mov ebp, W
	mov eax, ecx
	cdq
	div ebp
	mov ebp, eax
	add dl, bl
	xor ebp, edx
	and dx, 255
	sub edx, byte 127
	imul al
	imul edx, edx
	add eax, edx
	mov al, ah
	add eax, ebx
	or eax, ebp
	mov ah, al
	stosd
	loop L
	dec ebx
	jmp short L0	;don't know why my linux nasm generates
			;long (5 bytes!) jump if not forced to short


