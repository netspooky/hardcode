; Run this program to patch helphelp.com before running it.

imp macro name:REQ,np:REQ
bleh textequ @CatStr(<__imp__&name&@>,%np*4)
%extrn bleh:dword
@CatStr(name,< equ >,%bleh)
endm
impj macro name:REQ,np:REQ
bleh textequ @CatStr(<_&name&@>,%np*4)
%extrn bleh:near32
@CatStr(name,< equ >,%bleh)
endm
.586p
.model flat
impj _lopen,2
impj _lwrite,3
impj _llseek,3
impj LoadLibraryA,1
impj GetProcAddress,2
imp ExitProcess,1
includelib kernel32.lib
.code
_startested:
push 1
push offset helpcom
call _lopen
xchg ebx,eax
push offset ntvdmname
call LoadLibraryA
xchg edi,eax
mov edx,[edi+60]
mov edx,[edi+edx+80h]
push edx
xor ecx,ecx
mov edx,[edi+edx]
findexitpr1:
mov eax,[edi+edx]
add edx,4
inc ecx
cmp dword ptr [edi+eax+2],'tixE'
jnz findexitpr1
pop edx
mov edx,[edi+edx+16]
add edx,edi
lea eax,[edx+ecx*4-4]
mov esi,edi
findexitpr:
cmp word ptr [esi],15ffh
jnz notexitpr
cmp eax,[esi+2]
jz foundexitpr
notexitpr:
inc esi
jmp findexitpr
foundexitpr:
push 0
push 41h
push ebx
call _llseek
push esi
mov eax,esp
push 2
push eax
push ebx
call _lwrite
pop eax
push offset wowseb
push edi
call GetProcAddress
findcall1:
inc eax
cmp dword ptr [eax],0e80875ffh
jnz findcall1
add eax,[eax+4]
add eax,8
sub eax,esi
push eax
mov eax,esp
push 4
push eax
push ebx
push 0
push 45h
push ebx
call _llseek
call _lwrite
pop eax
ret
ntvdmname db "ntvdm.exe",0
wowseb db "WOWSysErrorBox",0
helpcom db "helphelp.com",0
end _startested