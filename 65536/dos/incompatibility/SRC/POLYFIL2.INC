;
;N-Sided poly filler v2.0
;(C)oded by RoByMuS
;
;In:
;    DS:SI - coords, 1 integer X/Y
;    AL    - color
;    AH    - points num - min 2!
;    ES    - video seg -> 320x200
;    DS:BX - gouraud/texture datas...
;            4 byte for each vertox..
;            gouraud: 1 color, 3 free
;            else   : w/x,w/y
;    FS    - texture segment (256x256)
;

gouraud:
gouraudpoly:
mov cs:isitgouraud,1
mov cs:poly_hlineofs,offset hline_gouraud
jmp realpolyfill

dualgouraudpoly:
mov cs:isitgouraud,1
mov cs:poly_hlineofs,offset hline_dualgour
jmp realpolyfill

mandeltexture:
mov cs:isitgouraud,1
mov cs:poly_hlineofs,offset hline_mtexture
jmp realpolyfill

texture:
texturepoly:
mov cs:isitgouraud,1
mov cs:poly_hlineofs,offset hline_texture
jmp realpolyfill

tunnelpoly:
mov cs:poly_hlineofs,offset hline_tunnel
jmp polyfill2

patternpoly:
mov cs:poly_hlineofs,offset hline_pattern
jmp polyfill2

polyfill:
mov cs:poly_hlineofs,offset horizline1_poly

polyfill2:
mov cs:isitgouraud,0
realpolyfill:
mov di,bx
sub di,si               ;DI = difference beetween vertox / gouraud
mov cs:poly_eleje,si
mov cs:poly_color,al
movzx cx,ah
dec cx
shr ax,8
shl ax,2   ;*4
add ax,si
mov cs:poly_vege,ax
;
;Minkival...
;
mov bx,si
mov dx,ds:[si+2]
poly_minkival:
add si,4
mov ax,ds:[si+2]
cmp ax,ds:[bx+2]
jg poly_notmin
mov bx,si
poly_notmin:
cmp dx,ds:[si+2]
jg poly_notmax
mov dx,ds:[si+2]
poly_notmax:
loop poly_minkival
mov cs:leftofs,bx
mov cs:rightofs,bx
;
;Clip Down
;
cmp dx,ds:[bx+2]
je poly_nothing2do              ;azert sem fog lefagyni!
cmp dx,200
jb poly_dok
or dx,dx
js poly_nothing2do             ;legnagyobb is kint van...
mov dx,199
poly_dok:
mov cs:poly_maxline,dx
mov ax,ds:[bx+2]
cmp ax,199
jg poly_nothing2do             ;semmi sincs benn...
mov cs:linenumber,ax
mov cs:polynext,1
;
;Let's clip up!
;
or ax,ax
jns poly_noclip   ;no clipping needed

mov cs:polynext,0
mov cs:linenumber,0

;
;Do the left clipping...
;
mov si,cs:leftofs

mov bx,di          ;double indexing

leftclipsearch:
movsx edi,word ptr ds:[si]
movsx ebp,word ptr ds:[si+2]
cmp cs:isitgouraud,0
je nogouraudleftclip
mov eax,dword ptr ds:[si+bx]
mov cs:gouraudtempval,eax
nogouraudleftclip:
cmp si,cs:poly_eleje
jne Poly_Left_add_clip
mov si,cs:poly_vege
poly_Left_add_clip:
sub si,4
cmp word ptr ds:[si+2],0
js leftclipsearch            ;megkeressuk, hogy hol er be a kepbe!
mov cs:leftofs,si

movsx eax,word ptr ds:[si]
movsx ecx,word ptr ds:[si+2]
sub eax,edi
sub ecx,ebp
shl eax,16
cdq
idiv ecx
mov cs:leftadd,eax
not ebp          ;negativnak kell lennie, coool!!!!! - neg/dec
imul ebp
shl edi,16
add eax,edi
mov cs:leftpos,eax  ;ennyi lenne ????

cmp cs:isitgouraud,0
je nogouraudleftclip2
mov ax,ds:[si+bx]
sub ax,word ptr cs:gouraudtempval
shl eax,16
cdq
idiv ecx
mov cs:leftgouraudadd1,eax
imul ebp
movsx edi,word ptr cs:gouraudtempval
shl edi,16
add eax,edi
mov cs:leftgouraudval1,eax
;
mov ax,ds:[si+bx+2]
sub ax,word ptr cs:gouraudtempval+2
shl eax,16
cdq
idiv ecx
mov cs:leftgouraudadd2,eax
imul ebp
movsx edi,word ptr cs:gouraudtempval+2
shl edi,16
add eax,edi
mov cs:leftgouraudval2,eax

nogouraudleftclip2:

;
;Do the right clipping...
;
mov si,cs:rightofs

rightclipsearch:
movsx edi,word ptr ds:[si]
movsx ebp,word ptr ds:[si+2]
cmp cs:isitgouraud,0
je nogouraudrightclip
mov eax,dword ptr ds:[si+bx]
mov cs:gouraudtempval,eax
nogouraudrightclip:
add si,4
cmp si,cs:poly_vege
jne Poly_Right_add_clip
mov si,cs:poly_eleje
poly_right_add_clip:
cmp word ptr ds:[si+2],0
js rightclipsearch            ;megkeressuk, hogy hol er be a kepbe!
mov cs:rightofs,si

movsx eax,word ptr ds:[si]
movsx ecx,word ptr ds:[si+2]
sub eax,edi
sub ecx,ebp
shl eax,16
cdq
idiv ecx
mov cs:rightadd,eax
not ebp          ;negativnak kell lennie, coool!!!!!   neg/dec
imul ebp
shl edi,16
add eax,edi
mov cs:rightpos,eax  ;ennyi lenne ????

cmp cs:isitgouraud,0
je nogouraudrightclip2
mov ax,ds:[si+bx]
sub ax,word ptr cs:gouraudtempval
shl eax,16
cdq
idiv ecx
mov cs:rightgouraudadd1,eax
imul ebp
movsx edi,word ptr cs:gouraudtempval
shl edi,16
add eax,edi
mov cs:rightgouraudval1,eax
;
mov ax,ds:[si+bx+2]
sub ax,word ptr cs:gouraudtempval+2
shl eax,16
cdq
idiv ecx
mov cs:rightgouraudadd2,eax
imul ebp
movsx edi,word ptr cs:gouraudtempval+2
shl edi,16
add eax,edi
mov cs:rightgouraudval2,eax

nogouraudrightclip2:

mov di,bx

poly_noclip:
;
;Do it!
;
poly_do:
call Poly_Left
call Poly_Right
push di
call cs:[poly_hlineofs]
pop di
inc cs:linenumber
mov ax,cs:linenumber
cmp ax,cs:poly_maxline
jbe poly_do
;
;Ready.
;

poly_nothing2do:

retn

Poly_Left:
cmp cs:polynext,1
je Poly_LeftNext
mov ax,cs:linenumber
mov si,cs:leftofs
cmp ax,ds:[si+2]
je Poly_LeftNext
mov eax,cs:leftadd
add cs:leftpos,eax
mov eax,cs:leftgouraudadd1
add cs:leftgouraudval1,eax
mov eax,cs:leftgouraudadd2
add cs:leftgouraudval2,eax
retn
Poly_LeftNext:
mov si,cs:leftofs
movsx eax,word ptr ds:[si]
mov cs:leftpos,eax
movsx ecx,word ptr ds:[si+2]

cmp cs:isitgouraud,0
je nogourleft1
mov bx,di
mov ebx,dword ptr ds:[si+bx]
mov cs:gouraudtempval,ebx
nogourleft1:


cmp si,cs:poly_eleje
jne Poly_Left_add
mov si,cs:poly_vege
poly_Left_add:
sub si,4
Poly_LeftNext2:
mov cs:leftofs,si

movsx ebx,word ptr ds:[si]
movsx edx,word ptr ds:[si+2]
sub eax,ebx    ;X diff
sub ecx,edx    ;Y diff
neg eax   ;UnOptimized
neg ecx   ;UnOptimized
shl eax,16
cdq
;dec ecx
;jbe
jecxz poly_leftnext
idiv ecx
mov cs:leftadd,eax

shl cs:leftpos,16

cmp cs:isitgouraud,0
je noleftgouraud

mov bx,di

movsx edx,word ptr cs:gouraudtempval
shl edx,16
mov cs:leftgouraudval1,edx
movsx eax,word ptr ds:[si+bx]
shl eax,16
sub eax,edx
cdq
jecxz nodiv_001
idiv ecx
nodiv_001:
mov cs:leftgouraudadd1,eax
movsx edx,word ptr cs:gouraudtempval+2
shl edx,16
mov cs:leftgouraudval2,edx
movsx eax,word ptr ds:[si+bx+2]
shl eax,16
sub eax,edx
cdq
jecxz nodiv_002
idiv ecx
nodiv_002:
mov cs:leftgouraudadd2,eax

noleftgouraud:
retn


Poly_Right:
shr cs:polynext,1    ;Oooops, egyben toroltuk is
jc Poly_RightNext
mov ax,cs:linenumber
mov si,cs:rightofs
cmp ax,ds:[si+2]
je Poly_RightNext
mov eax,cs:rightadd
add cs:rightpos,eax
mov eax,cs:rightgouraudadd1
add cs:rightgouraudval1,eax
mov eax,cs:rightgouraudadd2
add cs:rightgouraudval2,eax
retn
Poly_RightNext:
mov si,cs:Rightofs
movsx eax,word ptr ds:[si]
mov cs:Rightpos,eax
movsx ecx,word ptr ds:[si+2]

cmp cs:isitgouraud,0
je nogouright1
mov bx,di
mov ebx,dword ptr ds:[si+bx]
mov cs:gouraudtempval,ebx
nogouright1:

add si,4
cmp si,cs:poly_vege
jne Poly_Right_add
mov si,cs:poly_eleje
jmp Poly_RightNext2
poly_right_add:
Poly_RightNext2:
mov cs:Rightofs,si

movsx ebx,word ptr ds:[si]
movsx edx,word ptr ds:[si+2]
sub eax,ebx    ;X diff
sub ecx,edx    ;Y diff
neg eax   ;UnOptimized
neg ecx   ;UnOptimized
shl eax,16
cdq
;dec ecx
;jbe
jecxz poly_rightnext
idiv ecx
mov cs:rightadd,eax

shl cs:rightpos,16

cmp cs:isitgouraud,0
je norightgouraud

mov bx,di

movsx edx,word ptr cs:gouraudtempval
shl edx,16
mov cs:rightgouraudval1,edx
movsx eax,word ptr ds:[si+bx]
shl eax,16
sub eax,edx
cdq
jecxz nodiv_003
idiv ecx
nodiv_003:
mov cs:rightgouraudadd1,eax
movsx edx,word ptr cs:gouraudtempval+2
shl edx,16
mov cs:rightgouraudval2,edx
movsx eax,word ptr ds:[si+bx+2]
shl eax,16
sub eax,edx
cdq
jecxz nodiv_004
idiv ecx
nodiv_004:
mov cs:rightgouraudadd2,eax

norightgouraud:

retn

hline_pattern:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16
cmp di,cx
jle poly_0csere_
xchg di,cx
poly_0csere_:

or cx,cx
js nothing2do_
cmp di,319
jg nothing2do_

cmp di,0
jg poly_noclipneeded_
xor di,di
poly_noclipneeded_:
cmp cx,319
jl poly_noclipneeded2_
mov cx,319
poly_noclipneeded2_:

sub cx,di
inc cx

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

mov si,cs:linenumber
and si,15
add si,cs:patternofs
mov bl,ds:[si]
;
;Just do it!
;
mov al,bl
mov ah,al
shl eax,16
mov al,bl
mov ah,al
shr cx,1
jnc poly_1_
stosb
poly_1_:
shr cx,1
jnc poly_2_
stosw
poly_2_:
jcxz poly_3_
rep stosd
poly_3_:
nothing2do_:
retn

horizline1_poly:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16
cmp di,cx
jle poly_0csere
xchg di,cx
poly_0csere:

or cx,cx
js nothing2do
cmp di,319
jg nothing2do

cmp di,0
jge poly_noclipneeded
xor di,di
poly_noclipneeded:
cmp cx,319
jle poly_noclipneeded2
mov cx,319
poly_noclipneeded2:

mostmarok_poly_hline:
sub cx,di
inc cx

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

;
;Just do it!
;
mov al,cs:poly_color
mov ah,al
shl eax,16
mov al,cs:poly_color
mov ah,al
shr cx,1
jnc poly_1
stosb
poly_1:
shr cx,1
jnc poly_2
stosw
poly_2:
jcxz poly_3
rep stosd
poly_3:
nothing2do:

retn

hline_tunnel:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16
cmp di,cx
jle poly_0csere__
xchg di,cx
poly_0csere__:

cmp cx,20
jl nothing2do__
cmp di,299
jg nothing2do__

cmp di,20
jg poly_noclipneeded__
mov di,20
poly_noclipneeded__:
cmp cx,299
jl poly_noclipneeded2__
mov cx,299
poly_noclipneeded2__:

jmp mostmarok_poly_hline
nothing2do__:
retn


hline_gouraud:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16

mov eax,cs:rightgouraudval1
mov ebx,cs:leftgouraudval1

cmp di,cx
jle poly_0cseregour
xchg di,cx
xchg eax,ebx
poly_0cseregour:

or cx,cx
js nothing2dogour
cmp di,319
jg nothing2dogour

sub cx,di

;mov cs:gouraudhlinecurrent,ebx
mov ebp,ebx
sub eax,ebx
cdq
and ecx,0ffffh
jz polynodiv5
idiv ecx
polynodiv5:
;mov cs:gouraudhlineadd,eax
mov esi,eax

inc cx

or di,di
jns noleftclipgouraud1
leftclipgouraudcik:
add ebp,esi
;inc di
;dec cx
dec cx
inc di                   ; ez volt az original
jnz leftclipgouraudcik
noleftclipgouraud1:
mov ax,di
add ax,cx
cmp ax,319
jbe norightclipgouraud1
mov cx,320
sub cx,di
norightclipgouraud1:

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

mov al,cs:coloradd
cbw
cwde
shl eax,16
add ebp,eax             ; for gouraud spaceship
;
gouraudhlinecik:
mov eax,ebp
shr eax,16
;mov al,byte ptr cs:gouraudhlinecurrent+2
;mov es:[di+bx],al
stosb
;mov eax,cs:gouraudhlineadd
;add cs:gouraudhlinecurrent,eax
add ebp,esi
;inc di
loop gouraudhlinecik

eocikgouraudhline:

nothing2dogour:

retn

hline_dualgour:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16

mov eax,cs:rightgouraudval1
mov edx,cs:leftgouraudval1
mov ebx,cs:rightgouraudval2
mov esi,cs:leftgouraudval2

cmp di,cx
jle poly_0cseredgour
xchg di,cx
xchg eax,edx
xchg ebx,esi
poly_0cseredgour:

or cx,cx
js nothing2dodgour
cmp di,319
jg nothing2dodgour

sub cx,di

;mov cs:gouraudhlinecurrent,edx
push edx
sub eax,edx
cdq
and ecx,0ffffh
jecxz polynodiv4
idiv ecx
polynodiv4:
xchg eax,ebx
;mov cs:gouraudhlineadd,eax
;mov eax,ebx
mov edx,esi
;mov esi,cs:gouraudhlinecurrent	  ;ESI = current, EBX = add....
pop esi

;mov cs:gouraudhlinecurrent2,edx
push edx
sub eax,edx
cdq
jecxz polynodiv3
idiv ecx
polynodiv3:
;mov cs:gouraudhlineadd2,eax

;mov edx,cs:gouraudhlinecurrent2
pop edx
mov ebp,eax                          ;EDX = current, EBP = add

inc cx

or di,di
jns noleftclipdualgour1
leftclipdualgourcik1:
add esi,ebx
add edx,ebp
dec cx
inc di
jnz leftclipdualgourcik1
noleftclipdualgour1:
mov ax,cx
add ax,di
cmp ax,319
jbe norightclipdualgour1
mov cx,320
sub cx,di
norightclipdualgour1:

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

dgouraudhlinecik:

mov eax,edx
shr eax,8     ;AH = val (!)
push ax
mov eax,esi
pop ax
shr eax,8

;mov al,byte ptr cs:gouraudhlinecurrent+2
and al,0f0h
;mov ah,byte ptr cs:gouraudhlinecurrent2+2
shr ah,4
or al,ah
;mov es:[di+bx],al
stosb
;mov eax,cs:gouraudhlineadd
;add cs:gouraudhlinecurrent,eax
;mov eax,cs:gouraudhlineadd2
;add cs:gouraudhlinecurrent2,eax
;dgouraudhleftclip:
;inc di
add edx,ebp
add esi,ebx
loop dgouraudhlinecik

eocikdgouraudhline:
nothing2dodgour:

retn


;----------------------
hline_texture:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16

mov eax,cs:rightgouraudval2
mov edx,cs:leftgouraudval2
mov ebx,cs:rightgouraudval1
mov esi,cs:leftgouraudval1

cmp di,cx
jle poly_0cseretexti
xchg di,cx
xchg eax,edx
xchg ebx,esi
poly_0cseretexti:

or cx,cx
js nothing2dotexti
cmp di,319
jg nothing2dotexti

sub cx,di

push edx
sub eax,edx
cdq
and ecx,0ffffh
jecxz polynodiv4t
idiv ecx
polynodiv4t:
xchg eax,ebx
mov edx,esi
pop esi

push edx
sub eax,edx
cdq
jecxz polynodiv3t
idiv ecx
polynodiv3t:

pop edx
mov ebp,eax                          ;EDX = current, EBP = add

inc cx

or di,di
jns noleftcliptexti1
leftcliptexticik1:
add esi,ebx
add edx,ebp
dec cx
inc di
jnz leftcliptexticik1
noleftcliptexti1:
mov ax,cx
add ax,di
cmp ax,319
jbe norightcliptexti1
mov cx,320
sub cx,di
norightcliptexti1:

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

;xchg esi,ebx

textihlinecik:

push esi
mov eax,edx
shr eax,16
shl eax,7
shr esi,16
and si,127
add eax,esi
pop esi
;mov eax,edx
;shr eax,8     ;AH = val (!)
;push ax
;mov eax,esi   
;pop ax
;shr eax,8     ;AL = masik val (jo!)
;and eax,0ffffh

mov al,gs:[eax]
add al,cs:texturecoloradd
mov es:[di],al
inc di
add edx,ebp
add esi,ebx
loop textihlinecik

eociktextihline:
nothing2dotexti:
retn

;----------------------

hline_mtexture:
mov ecx,cs:rightpos
mov edi,cs:leftpos
sar ecx,16
sar edi,16

mov eax,cs:rightgouraudval2
mov edx,cs:leftgouraudval2
mov ebx,cs:rightgouraudval1
mov esi,cs:leftgouraudval1

cmp di,cx
jle poly_0cseretextim
xchg di,cx
xchg eax,edx
xchg ebx,esi
poly_0cseretextim:

or cx,cx
js nothing2dotextim
cmp di,319
jg nothing2dotextim

sub cx,di

push edx
sub eax,edx
cdq
and ecx,0ffffh
jecxz polynodiv4tm
idiv ecx
polynodiv4tm:
xchg eax,ebx
mov edx,esi
pop esi

push edx
sub eax,edx
cdq
jecxz polynodiv3tm
idiv ecx
polynodiv3tm:

pop edx
mov ebp,eax                          ;EDX = current, EBP = add

inc cx

or di,di
jns noleftcliptexti1m
leftcliptexticik1m:
add esi,ebx
add edx,ebp
dec cx
inc di
jnz leftcliptexticik1m
noleftcliptexti1m:
mov ax,cx
add ax,di
cmp ax,319
jbe norightcliptexti1m
mov cx,320
sub cx,di
norightcliptexti1m:

mov ax,cs:linenumber
xchg ah,al
add di,ax
shr ax,2
add di,ax

;xchg esi,ebx

textihlinecikm:

push esi
mov eax,edx
shr eax,16
shl eax,7
shr esi,16
and si,127
add eax,esi
pop esi
;mov eax,edx
;shr eax,8     ;AH = val (!)
;push ax
;mov eax,esi   
;pop ax
;shr eax,8     ;AL = masik val (jo!)
;and eax,0ffffh

mov al,gs:[eax]
test al,31
jz nomandelput
mov es:[di],al
nomandelput:
inc di
add edx,ebp
add esi,ebx
loop textihlinecikm

eociktextihlinem:
nothing2dotextim:
retn


patternofs dw ?
poly_hlineofs dw ?

polynext db ?

linenumber dw ?
poly_maxline dw ?

poly_eleje dw ?
poly_vege  dw ?
poly_color db ?

leftpos dd ?
leftadd dd ?
rightpos dd ?
rightadd dd ?

leftofs dw ?
rightofs dw ?

leftgouraudadd1 dd ?
leftgouraudadd2 dd ?
leftgouraudval1 dd ?
leftgouraudval2 dd ?

rightgouraudadd1 dd ?
rightgouraudadd2 dd ?
rightgouraudval1 dd ?
rightgouraudval2 dd ?

gouraudhlinecurrent dd ?
gouraudhlineadd dd ?
gouraudhlinecurrent2 dd ?
gouraudhlineadd2 dd ?

gouraudtempval dd ?     ;used for clipping + other

isitgouraud dw ?        ;Is there secondary data

coloradd db ?           ;gouraud
texturecoloradd db ?