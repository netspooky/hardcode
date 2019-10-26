; Help help
; (c) Gigasoft 12-30-2009
; Run helpfix.exe to patch helphelp.com before running.
; Works in Vista SP1 without patching.

bits 16
org 256
mov ax,1687h
int 2fh
push cs
push word continue
push es
push di
mov cx,cs
add cx,byte 18h
mov es,cx
shl ecx,4
add ecx,byte cont2-384
retf
continue:
mov bl,3bh
mov ds,bx
push byte 1bh
push ecx
mov edx,[bx-11]
o32 retf
cont2:
bits 32
mov bl,23h
mov ds,ebx
mov ss,ebx
lea esp,[ecx-1]
mov bl,9
push ebx
push ebx
push ebx
mov eax,[edx+8]
add ecx,byte text1-cont2
push ecx
push ecx
add ax,5f51h
push eax
add eax,2b599h-5f51h
jmp eax
text1 db "Hi",0