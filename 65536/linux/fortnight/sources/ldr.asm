
global _start
extern BZ2_bzBuffToBuffDecompress

section .data use32
  compressedstuff:
  incbin filus
  endofcs:

  sys_exit equ 1    ; int exitcode
  sys_read equ 3    ; int fd, char *buf, int count
  sys_write equ 4   ; int fd, char *buf, int count
  sys_open equ 5    ; char *file, int flag, int mode
  sys_close equ 6   ; int fd
  sys_creat equ 8   ; int fd, int mode
  sys_execve equ 11 ; char *file, char **argv, char **envp

  filename db "/tmp/sux3", 0
  argv dd 0
  envp dd 0
  tempbsize dd 1000000


section .text use32
_start:
  mov eax, esp
  add eax, 4
  mov [argv], eax
  l1:
    add eax, 4
    cmp dword[eax],0
  jnz l1
  add eax, 4
  mov [envp], eax
  
  push dword 0
  push dword 0
  push dword endofcs-compressedstuff
  push dword compressedstuff
  push dword tempbsize
  push dword tempbuf
  call BZ2_bzBuffToBuffDecompress
 
  mov eax, sys_creat
  mov ebx, filename
  mov ecx, 700q
  int 0x80
  mov ebx, eax
   
  mov eax, sys_write
  mov ecx, tempbuf
  mov edx, [tempbsize]
  int 0x80
 
  mov eax, sys_close
  int 0x80
 
  mov eax, sys_execve
  mov ebx, filename
  mov ecx, [argv]
  mov edx, [envp]
  int 0x80

  mov eax, sys_exit
  int 0x80

section .bss
  tempbuf resb 1000000


