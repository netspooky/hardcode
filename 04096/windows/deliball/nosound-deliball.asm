;           Compile in FASM 1.64            ;
; By Devreci (Ýbrahim inci) www.devreci.tk  ;

format PE GUI 4.0
entry basla

include 'include\win32a.inc'

section '.data' data readable writeable
ynl db 1
oyns db 'Oyuncu->'
pnb db '000'
pno db '000'
bilg db '<-Bilgisayar'
puan db '-puan-'
bslk db 'Deli Ball - (By Ýbrahim Ýnci) -',0
clss db 'DBB',0
wncl dd 0,WProc,0,0,0,0,0,16,0,clss
binf dd 40,296,297,180001h,0,111h,31h,44h,0,0,wncl+16
acx dd -1.6f
ydd dd	-13.0f,263.0f
drc dd 4.004f,40.0f,1.95f,3.5f
leg dd 18.0f
ckz  dd 0.3f
dgd db 0
ss1 dd ?
mm dd ?
mem2 dd ?
mmb dd ?
hwnd dd ?
hdc dd ?
rgs dd 1710,78445
msg dd ?,?,?,?,?,?,?
time dd ?
hiz dd 1000
ntr dd 2.0f
kkp dd 1.1f,213.0f
topx dd -0.2f,253.2f
topy dd -40.0f,300.0f
bal dd 120.0f,131.0f,40,40,0
balc dd -20,20,40,40,400.0f,-20,2.0f,2.0f,2.0f
oync dd -10,10,20,20,80.0f,-10,0.3f,0.5f,0.3f
drg dd 140.0f
tur dd -20.0f,150.0f
oyn dd 100.0f,272.0f,80,20,0
blg dd 100.0f,2.0f,80,20,0
hzm1 dd 0.1f,20.0f
hzm2 dd ?,?
bnr dd -10.0f,4.0f

section '.code' code readable executable
ckcz:
xor byte [edi+3],0x80
fld dword [edi+4]
fld st0
fabs
fcom [ckz]
fstsw ax
fstp st0
sahf
ja repli
test byte [edi+7],0x80
jz karci
fsub [ckz]
jmp repli
karci:
fadd [ckz]
repli:
fstp dword [edi+4]
ret
rokz:
mov edx,rgs
fild dword [edx]
fcos
fstp dword [edx]
fild dword [edx+4]
fsin
fstp dword [edx+4]
fild word [edx]
fild word [edx+4]
fstp dword [bnr]
fstp dword [bnr+4]
mov [bal],120.0f
mov [bal+4],131.0f
ret
syatr:
pop edx
pop edi
add edi,2
mov bl,3
reugz:
inc byte [edi]
cmp byte [edi],57
jb sercc
mov byte [edi],48
dec edi
dec bl
jnz reugz
sercc:
call edx
atrr:
mov ecx,[esp+8]
mov ebx,[esp+4]
fld dword [ebx]
fcom [kkp]
fstsw ax
sahf
ja retgel2
fstp st0
jmp rezist
retgel2:
fsub dword [ecx]
fstp dword [ebx]
rezist:
ret 8
eksl:
mov ecx,[esp+8]
mov ebx,[esp+4]
fld dword [ebx]
fcom [kkp+4]
fstsw ax
sahf
jb retgel
fstp st0
jmp rezist2
retgel:
fadd dword [ecx]
fstp dword [ebx]
rezist2:
ret 8
keyco:
invoke GetAsyncKeyState,[esp+4]
cmp ax,0x7fff
ret 4
egmm:
push esi
mov edx,[esi+12]
yersnc:
mov ecx,[esi+8]
asjasdu:
fild dword [esi]
fmul st0,st0
fild dword [esi+4]
fmul st0,st0
faddp st1,st0
fcom dword [esi+16]
fstsw ax
sahf
jb sdfyfhf
mov al,0
stosb
stosb
stosb
fstp st0
jmp vocagm
sdfyfhf:
fld st0
fdiv dword [esi+24]
fistp word [esp]
mov ax,[esp]
not ax
stosb
fld st0
fdiv dword [esi+28]
fistp word [esp]
mov ax,[esp]
not ax
stosb
fdiv dword [esi+32]
fistp word [esp]
mov ax,[esp]
not ax
stosb
vocagm:
inc dword  [esi]
loop asjasdu
mov eax,[esi+20]
mov dword [esi],eax
dec dword [esi+4]
dec edx
jne yersnc
pop esi
ret
krvr:
push ebp
mov ebp,[esp+8]
push eax
push eax
fld dword [ebp]
fistp dword [esp]
fld dword [ebp+4]
fistp dword [esp+4]
pop ebx
pop eax
sub eax,297
not eax
mov ecx,296
mul ecx
add eax,ebx
mov ecx,eax
shl eax,1
add eax,ecx
mov edi,eax
mov ebx,eax
add edi,[mm]
mov esi,[ebp+16]
mov edx,[ebp+12]
skdjfh:
mov ecx,[ebp+8]
push edi
push ebx
ssdfsd:
mov al,255
cmp ebx,400000
ja sdfhduu
cmp byte [esi],0
jne yerkzn
cmp byte [esi+1],0
jne yerkzn
cmp byte [esi+2],0
jne yerkzn
add esi,3
add edi,3
jmp sdfhduu
yerkzn:
cmp byte [edi+1],60
jb redde
mov [dgd],1
redde:
movsw
movsb
sdfhduu:
add ebx,3
loop ssdfsd
pop ebx
pop edi
sub edi,888
sub ebx,888
dec edx
jne skdjfh
pop ebp
ret 4
drww:
invoke SetDIBitsToDevice,[hdc],3,27,296,297,0,0,0,297,[mm],binf,0
invoke SetTextColor,[hdc],040h
invoke SetBkMode,[hdc],0
invoke TextOut,[hdc],125,4,puan,6
invoke TextOut,[hdc],10,4,oyns,8
invoke TextOut,[hdc],220,4,bilg,12
invoke SetTextColor,[hdc],0b00000h
cmp [ynl],0
je ketret
invoke SetBkMode,[hdc],2
mov [ynl],0
ketret:
invoke TextOut,[hdc],75,5,pnb,3
invoke TextOut,[hdc],185,5,pno,3
ret
crtt:
pop esi
pop edx
pop ecx
pop ebx
pop eax
invoke	CreateWindowEx,WS_EX_CLIENTEDGE ,clss,0,50000000h,eax,ebx,ecx,edx,[hwnd],0,[wncl+16],0
call esi
basla:
invoke GlobalAlloc,0,1500000
mov [mm],eax
mov edi,eax
mov ecx,600000
add eax,ecx
xchg ebx,eax
xor eax,eax
rep stosb
xchg eax,ebx
mov [mem2],eax
mov edi,eax
add eax,200000
mov [bal+16],eax
add eax,50000
mov [oyn+16],eax
dec eax
mov [blg+16],eax
add eax,80000
mov [ss1],eax
mov dx,297
kdytdg:
mov cx,296
erters:
push ax
push dx
push cx
fild word [esp+2]
fild word [esp]
fmulp st1,st0
fsin
fmul st0,st0
fmul [drg]
fistp word [esp+4]
pop cx
pop dx
pop ax
stosb
dec cx
jne erters
dec dx
jne kdytdg
mov esi,edi
sub esi,2600
mov edi,[ss1]
mov ecx,0x3a
add edi,ecx
rep movsb
mov edi,[bal+16]
mov esi,balc
call egmm
mov edi,[oyn+16]
add edi,30000
mov esi,oync
call egmm
mov esi,[oyn+16]
mov edi,esi
inc edi
add esi,30000
mov dl,20
dfggsdf:
mov ecx,30
sdsdf:
lodsb
stosb
loop sdsdf
mov bl,[edi-1]
mov bh,[edi-2]
mov dh,[edi-3]
mov cl,60
dhsetre:
mov al,bl
stosb
mov al,bh
stosb
mov al,dh
stosb
loop dhsetre
mov cl,30
rep movsb
dec dl
jne dfggsdf
invoke GetModuleHandle,0
mov [wncl+16],eax
invoke	LoadIcon,0,32512
mov [wncl+20],eax
invoke	LoadCursor,0,32512
mov [wncl+24],eax
invoke	RegisterClass,wncl
invoke	CreateWindowEx,0,clss,bslk,10ca0000h,180,50,308,358,0,0,[wncl+16],0
mov [hwnd],eax
push 1
push 25
push 300
push 300
call crtt
push 180
push 2
push 30
push 20
call crtt
push 70
push 2
push 30
push 20
call crtt
invoke GetDC,[hwnd]
mov [hdc],eax
invoke GetSysColor,15
invoke SetBkColor,[hdc],eax
invoke GetStockObject,ANSI_VAR_FONT
invoke SelectObject,[hdc],eax
call rokz
sdfeeg:
inc [hiz]
invoke GetTickCount
mov ebx,eax
sub eax,[time]
cmp eax,200
jb sertt
cmp [hiz],10
ja reffg
mov [hiz],5000
reffg:
mov [time],ebx
fld [hzm1+4]
fidiv [hiz]
fst [hzm1]
fld st0
fmul [drc+8]
fstp [hzm2+4]
fmul [drc+12]
fstp [hzm2]
xor eax,eax
mov [hiz],eax
sertt:
push 39
call keyco
jb rewqq2
push hzm1
push oyn
call eksl
rewqq2:
push 37
call keyco
jb rewqq
push hzm1
push oyn
call atrr
rewqq:
fld [bal+4]
fcom [tur+4]
fstsw ax
fstp st0
sahf
ja terver
fld [blg]
fsub [tur]
fsub [bal]
ftst
fstsw ax
sahf
fstp st0
jb rerve
push hzm2+4
push blg
call atrr
jmp terver
rerve:
push hzm2+4
push blg
call eksl
terver:
mov esi,bal
mov edi,bnr
mov ecx,hzm2
mov edx,topx
fld dword [edi+4]
fld dword [edi]
fld st0
fmul st0,st0
fld st2
fmul st0,st0
faddp st1,st0
fsqrt
fdiv st2,st0
fdivp st1,st0
fstp dword [edi]
fstp dword [edi+4]
fld dword [esi]
fcom dword [edx]
fstsw ax
sahf
ja seffx
fld1
faddp st1,st0
call ckcz
seffx:
fcom dword [edx+4]
fstsw ax
sahf
jb resx
fld1
fsubp st1,st0
call ckcz
resx:
fld dword [edi]
fmul dword [ecx]
fadd st0,st1
fstp dword [esi]
fld dword [edi+4]
fmul dword [ecx]
fadd dword [esi+4]
fstp dword [esi+4]
fstp st0
fld dword [esi+4]
fcom  dword [edx+12]
fstsw ax
sahf
jb ssdef
inc [ynl]
push pno
call syatr
call rokz
jmp seryt
ssdef:
fcom dword [edx+8]
fstsw ax
sahf
ja seryt
inc [ynl]
push pnb
call syatr
call rokz
seryt:
fstp st0
mov edi,[mm]
mov esi,[mem2]
mov ecx,90000
sdjfhd:
movsb
mov ax,0x2828
stosw
loop sdjfhd
xor eax,eax
mov cx,32500
rep stosd
push bal
call krvr
mov [dgd],0
push oyn
call krvr
push blg
call krvr
cmp [dgd],0
je koler
mov edx,bnr
mov ecx,bal
fld dword [ecx+4]
fcom [ydd]
fstsw ax
fstp st0
sahf
jb koler
fld dword [ecx+4]
fcom [ydd+4]
fstsw ax
fstp st0
sahf
ja koler
and byte [edx+7],0x7f
fld dword [ecx+4]
fcom  [tur+4]
fstsw ax
fstp st0
sahf
jb remci
fld dword [ecx+4]
fsub [ntr]
fstp dword [ecx+4]
xor byte [edx+7],0x80
fld dword [ecx]
fsub [oyn]
jmp tutra
remci:
fld dword [ecx+4]
fadd [ntr]
fstp dword [ecx+4]
fld dword [ecx]
fsub [blg]
tutra:
fsub [leg]
fdiv [drc+4]
fadd dword [edx]
fstp dword [edx]
koler:
invoke	PeekMessage,msg,NULL,0,0,PM_REMOVE
invoke	TranslateMessage,msg
invoke	DispatchMessage,msg
cmp [msg+4],12h
je wwedfg
call drww
jmp sdfeeg
wwedfg:
invoke ReleaseDC,[hwnd],[hdc]
invoke GlobalFree,[mm]
invoke	ExitProcess,[msg+8]
xor eax,eax
ret

proc WProc,hwnd,wmsg,wparam,lparam
push	ebx esi edi
cmp [wmsg],WM_DESTROY
je  wmdestroy
defwndproc:
invoke	DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
jmp finish
wmdestroy:
invoke	PostQuitMessage,0
xor	eax,eax
mov [msg+4],12h
finish:
pop	edi esi ebx
ret
endp

section '.idata' import data readable writeable

  library kernel32,'kernel32.dll',\
	  user32,'user32.dll',\
	  gdi32,'gdi32.dll'



  include 'include\apia\kernel32.inc'
  include 'include\apia\user32.inc'
  include 'include\apia\gdi32.inc'



