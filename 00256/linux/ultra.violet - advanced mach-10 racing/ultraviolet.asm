; ==========================================
; ========= MACROS AND BOILERPLATE =========
; ==========================================

;WHEN I SAY BITS, YOU SAY 64!
BITS 64

;the address offset for x86-64
org 0x00400000

;a bunch of definitions so I don't have to memorize syscall numbers
%include "syscalls.asm"

;this is a hack that's 2 bytes smaller than mov!
%macro minimov 2
	push %2
	pop %1
%endmacro

; ==============================
; ========= ELF HEADER =========
; ==============================

ehdr: ; Elf64_Ehdr

e_ident:
	db 0x7F, "ELF", 2, 1, 1, 0

e_padding:
	;we have 8 bytes of padding to put code inside!
	;here we're about to close stderr so out program is quiet
	minimov rax, sys_close
	minimov rdi, 2
	jmp p_flags

e_type:
	dw 2
e_machine:
	dw 0x3e
e_version:
	dd 1
e_entry:
	dq e_padding
e_phoff:
	dq phdr - $$
e_shoff:
	dq 0
e_flags:
	dd 0
e_ehsize:
	dw ehdrsize
e_phentsize:
	dw phdrsize

; the program header starts inside of the elf header
; shamelessly adapted from the 32-bit version at
; http://www.muppetlabs.com/~breadbox/software/tiny/teensy.html

ehdrsize equ $ - ehdr

; ==================================
; ========= PROGRAM HEADER =========
; ==================================

phdr: ; Elf64_Phdr

p_type:
	dd 1

p_flags:
	;p_flags is supposed to be 0x0f, and syscall is 0x0f05;
	;the kernel only looks at the bottom byte, so I can put code here!
	syscall
	jmp p_paddr

p_offset:
	dq 0
p_vaddr:
	dq $$

p_paddr: ;apparently p_paddr can be nonsense?
	;move stack up
	push rax
	; pipe with fds on stack
	minimov rax, sys_pipe
	minimov rdi, rsp
	jmp _start

p_filesz:
	dq filesize
p_memsz:
	dq filesize
p_align:
	dq 0x10

phdrsize equ $ - phdr

; ==================================
; ========= AUTHOR NAME ;3 =========
; ==================================

blackle:
	;a null terminator so `strings` will find it >;3c
	db "made by blackle!",0 ;it's me!
	;this is a lot of unused bytes that idk what to do with


; ===========================
; ========= CODE!!! =========
; ===========================

_start:
	;we actually started execution in e_padding and jumped to
	;p_flags and then p_paddr. so check out that code if you haven't already
	syscall

	;get the pipe fds into rdi
	pop rdi 

	; fork 
	minimov rax, sys_fork
	syscall
	test rax,rax
	jz parent

; ===============================
; ========= APLAY CHILD =========
; ===============================

child:
	;dup2 read->stdin
	minimov rax, sys_dup2
	;normally we have to clear rsi for stdin (0), but
	;the register starts at 0 and we haven't touched it yet

	;also we'd usually mask out the lower bytes of rdi
	;to get the read end of the pipe, but the kernel
	;only looks at the lower bytes anyway
	syscall

	; this puts envp into rdx, assuming argc = 1
	; this is magic ;3
	minimov rdx, 16+8
	add rdx,rsp

	;setup argv as {"/bin/aplay", 0}
	push 0
	push aplay_string

	; execve aplay
	minimov rax, sys_execve

	; we just pushed the address to aplay_string so
	; we can pop it into rdi instead of doing another minimov
	pop rdi
	push rdi

	minimov	rsi, rsp
	syscall

; ============================================
; ========= SAMPLE GENERATING PARENT =========
; ============================================

parent:
	;get pipe write fd by shifting down the upper bytes
	shr rdi, 32

	;we want r14, r15, and r13 to be zero but we haven't 
	;touched them, and the kernel initialized them that way
	;so we don't have to do anything! :D
sample_loop:
	inc r14

	;push r15 onto the stack as 8 packed samples
	push r15

	;do some weird stuff to r13
	xor r13, r14
	shr r13, 1

	;make the last 2 bars sound different
	;comparing on r14w is a byte smaller somehow
	cmp r14w, 1024*2
	ja sample_loop_end
	bswap r15
	not r15

	;make the last half-bar sound noisy
	cmp r14w, 512
	ja sample_loop_end
	bswap r13d

sample_loop_end:
	;do some weird stuff to r15 that sounds cool
	xor r15, r13
	ror r15, 8
	not r15 ;this makes it sound like a ring modulator?

	;repeatedly create samples until we have 8 "bars"
	cmp r14w, 1024*8
	jnz sample_loop

write_loop:
	;write generated samples to pipe
	minimov rsi, rsp
	minimov rdx, 1024*8*8
	minimov rax, sys_write
	;uncomment this if you want to write samples to stdout
	;good for saving to a file!
	; minimov rdi, 1
	syscall

	;keep writing those same samples until we're killed
	jmp write_loop

; ================================
; ========= STRING TABLE =========
; ================================

;just one string :3

aplay_string:
	;this should be null terminated, but there is 0s in
	;memory after this that the kernel filled in for us
	db '/usr/bin/aplay'

filesize equ $ - $$
