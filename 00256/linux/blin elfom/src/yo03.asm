%ifndef W
%define	W	1280
%define	H	800
;%define	W	640
;%define	H	480
%endif

%define PIXSZ (W*H)
%define MEMSZ (W*H*4)	; 3 for 24

%define	O(a)	(ebp+(a-$$))
%define	A(a)	[O(a)]
%define	Wa	A(width)
%define	Ha	A(height)
%define Pa	A(pixcount)

; unsafe version does not contain all there headers and shit
%ifndef SAFE

BITS 32
org	0x00040000

ehdr:		; begin elf header
elf_ident:		; elf identification (16 bytes)
fd_dsp:	; next 4 bytes
	db	0x7F, "ELF"		; elf magic, 4 bytes

dsp_count:	; next 4 bytes
;phdr:	; TODO inject program header
	db	1	; ei_class, must be 1 == ELFCLASS32		; p_type [1/4], must be 1

; 11 bytes ready for garbage
	db	1	; ei_data, should be 1 == ELFDATA2LSB, but seems to be ignored
	db	1	; ei_verion, should be 1 == EV_CURRENT, but seems to be ignored
;	times 9 db	0 ; ei_pad, 9 bytes, can be anything we want!

; too heavy for me atm :(
;	db	0, 0, 0						; p_type [2-4/4], must be 0,0,0 (last 3 bytes, 8 left)
;	dd	0							; p_offset (4 bytes, 4 left), must be 0 -- the beginning of file
;	dd	$$							; p_vaddr (4 bytes, 0 left, have to overlap), must be $$ -- the value of org

; [yo03]
devname:
	db	'/dev/dsp', 0	; string, reusable, 

	dw	2			; e_type, must be 2 = ET_EXE	TODO	; p_paddr[2/4], unused
	dw	3			; e_machine, must be 3 = EM_386	TODO	; p_paddr[4/4], unused

	dd	1 ; TODO _start		; e_version, can be garbage			; p_filesz, must be >= 256
	dd	_start		; e_entry, must be correct		TODO	; p_memsz, must be >= p_filesz
	dd	phdr - $$	; e_phoff, must be correct			TODO 4	; p_flags, 4 means read-only

; % clean
;	dd	0
;	dd	0
; % dirty
width:	dd	W			; e_shoff						TODO	; p_align, can be garbage
height:	dd	H			; e_flags

	dw	ehdrsize	; e_ehsize
	dw	phdrsize	; e_phentsize

; % clean
;	dw	1
;	dw	0
;	dw	0
;	dw	0
;	ehdrsize	equ		$ - ehdr

; program header overlap
phdr:
	dw	1			; e_phnum, must be 1			; p_type [1-2/4], must be 1 = PT_LOAD
	dw	0			; e_shentsize, must be 0		; p_type [3-4/4]. must be 0
	dw	0			; e_shnum, must be 0			; p_offset [1-2/4], must be 0 -- beginning of the file
	dw	0			; e_shstrndx, must be 0			; p_offset [3-4/4]. must be 0

; end of elf header
ehdrsize      equ     $ - ehdr

; continuation of program header
	dd	$$			; p_vaddr, must be $$ -- the value of org
	dd	$$			; p_paddr, unused, can be garbage
	dd	filesize	; p_filesz, must be >= filesize (~256)

; % clean
;	dd	filesize	; p_memsz, must be >= p_filesz
; % dirty
pixcount: dd	PIXSZ		; PIXSZ is at least 320*200=64000 (>> req 256)

speed:	dd	7			; p_flags, ?? must be 7 for writable vars and buffers ??
	dd	0x1000		; p_align, ?? must be reasonable 0x1000 ??

phdrsize        equ     $ - phdr

; % clean
;width: dd	W
;height:	dd	H
;pixcount:	dd	PIXSZ

%else
; this is the safe version and we must behave
%endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; VYTIRAJTE NOGI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_start:				; all regs are zero, convenient!
	mov	ebp, $$		; this is convenient too!

; open("/dev/dsp", O_RDWR)
	mov	al, 5
	lea	ebx, A(devname)
	mov	cl, 2
	int 0x80

; store fd
	mov A(fd_dsp), eax

; open("/dev/fb0", O_RDWR)
	mov	al, 5			; open
	mov	dword [ebx+4], "/fb0"
	int 0x80
        
; void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
; buffer = mmap(NULL, buflen, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
        
; filling parameters for mmap (in backward order)
	push	edx			; offset (edx is now 0)
	push	eax			; eax stores fd from the previous call
	push	1			; 1 MAP_SHARED
	push	3
	push	MEMSZ		; full framebuffer size
	push	edx			; 0 desired address
	mov	al, 90			; mmap syscall
	mov	ebx, esp		; pointer to args 
	int	0x80

; store framebuffer address
	push	eax

; now we're ready

; (esi = sample_number (=time))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; mainloop
mainloop:

video:
	mov	ecx, Pa
; make edi = buffer addr
	pop	edi
	push	edi

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; do pixels
pixelloop:
	mov	eax, ecx
	cdq
	div	dword Wa	; => eax = y, edx = x

; oh
	push	edx
	push	eax
	or	eax, edx
	mov	ebx, esi
	sar	ebx, 7
	imul ebx
	pop	ebx
	pop	edx
	xor	ebx, edx
	sal	ebx, 8
	xor	eax, ebx

;	mov	bh, al
;	shl	ebx, 2
;	or	eax, ebx
;	xor	eax, A(devname)

; write and loop
; 24
;	stosb
;	shr eax, 8
;	stosb
;	shr	eax, 8
;	stosb
;	shr	eax, 8
; 32
	stosd
	loop pixelloop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; do samples
audio:
	inc	ch	; ecx = buffer_size = 256 => 8000/256 ~= 30 fps

; we can trash edi here -- it's already in stack

	mov	ebx, ebp
	inc	bh	; add 256 (buffer size) to ebx -- buffer in free space just after this file contents
	push	ebx		; push2
	push	ebx		; push3
	pop	edi			; push3
sndgen:
	mov eax, esi
	inc esi

; lovely!
	shr	eax, 10
	or	al, 180
;	mul	dword A(devname+6)	; good
;	mul	dword A(_start)		; standart
	mul	dword A(_start+11)	; goood!
	mul	esi
	stosb
	loop	sndgen

sndplay:
; write syscall
	pop	ecx					; ecx = buffer ptr, (push2)
	mov	ebx, A(fd_dsp)		; ebx = fd
	push 	4
	pop	eax					; eax = __NR_write = 4
	xor	edx, edx
	inc	dh					; edx = count = 256
	int 0x80

	jmp mainloop

; safe version only. also, not reachable
%ifdef SAFE
exit:
        xor	eax, eax
        inc	eax                 ; 1 = exit syscall
        int	0x80
%endif

filesize      equ     $ - $$
