; main.asm
BITS 64
ORG 0x08048000
GLOBAL _start

LINE_WIDTH equ 127

; elf header
ehdr:
  db  0x7F, "ELF", 2, 1, 1, 0         ;   e_ident
  times 8 db 0
  dw 2 ; e_type
  dw 0x3e ; e_machine
  dd 1 ; e_version
  dq _start ; e_entry
  dq phdr - $$ ; e_phoff
  dq 0 ; e_shoff
  dd 0 ; e_flags
  dw ehdrsize ; e_ehsize
  dw phdrsize ; e_phentsize
  dw 1 ; e_phnum: one program header
  dw 0 ; e_shentsize
  dw 0 ; e_shnum
  dw 0 ; e_shstrndx
ehdrsize equ $ - ehdr

; the program header
phdr:
  dd 1 ; p_type
  dd 7 ; p_flags
  dq 0 ; p_offset
  dq $$ ; p_vaddr
; part of ph doubles as timespec
timespec:
  dq 0 ; p_paddr
  dq 50000000 ; p_filesz
  dq 50000000 ; p_memsz
  dq 0x200000 ; p_align
phdrsize equ $ - phdr

; _start global symbol
_start:
  enter LINE_WIDTH + 1, 0
  
  mov [rsp + 42], byte 0x23
  
.l03:
  xor rsi, rsi
  ; blocker
  mov [rsp + (LINE_WIDTH - 1)], word 0x2323
  
  ; 1st pass: count spaces
  mov al, 0x23 ; edge cell
  mov cx, 0x0000 ; edge breaths
.l00:
  xor ah, ah
  ; al, bl, bh - consecutive cells contents
  ; cl, ch, ah - consecutive breath counts
  mov bx, [rsp + rsi]
  cmp bl, 0x23 ; is filled?
  jne .l09
  cmp bh, 0x23 ; is next empty
  je .l08
  inc ah
.l08:
  cmp al, 0x23 ; is prev empty
  je .l09
  inc ah
.l09:
  mov [rsp + rsi], byte 0x20
  ; check ah == 2 || ch > 0 || cl == 2
  cmp ch, 0x00
  jne .l13
  cmp ah, 0x02
  je .l13
  cmp cl, 0x02
  je .l13
  jmp .l12
.l13:
  mov [rsp + rsi - 1], byte 0x23
.l12:
  ; shift free space count
  mov cl, ch
  mov ch, ah
  ; shift cell contents
  mov al, bl
  ; next iteration?
  inc rsi
  cmp rsi, LINE_WIDTH
  jne .l00
  
  ; endline
  mov [rsp + LINE_WIDTH - 1], byte 0x0a
  
  mov rax, 35
  mov rdi, timespec
  xor rsi, rsi
  syscall
  
  mov al, 1
  mov rdi, 1
  mov rsi, rsp
  mov rdx, LINE_WIDTH
  syscall
  
  jmp .l03
filesize equ $ - $$
