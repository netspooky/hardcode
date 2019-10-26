;
; incompatibility version
;
; fast triangle filler v1.1 - (c) 1995 byteam - coded by blala
; include version - not optimized yet!
;
;  mov si,offset x1
;  mov ax,targetsegment
;  mov es,ax
;  mov al,color
;  call fastri
;

screen_width equ 320

x1_tri equ word ptr ds:[si]
y1_tri equ word ptr ds:[si+2]
x2_tri equ word ptr ds:[si+4]
y2_tri equ word ptr ds:[si+6]
x3_tri equ word ptr ds:[si+8]
y3_tri equ word ptr ds:[si+10]

lepes1_tri dd ?
lepes2_tri dd ?
lepes3_tri dd ?

line dw ?
line320 dw ?
color_tri db ?

horizline_ofs dw offset horizline_tri
pattern_ofs dw ?
pattern_seg dw ?

fastri_vecc:
mov cs:horizline_ofs,offset horizline_vecc_tri
jmp fastri2

fastri:
mov cs:horizline_ofs,offset horizline_tri
jmp fastri2

.386
fastri2:
push bp
mov bp,cs:horizline_ofs
;
; inicializ†l†s - megsortoljuk a pontokat
;
mov cs:color_tri,al
mov ax,ds:[si+2]
mov edx,ds:[si]
cmp ax,ds:[si+6]
jle t1_tri
mov ax,ds:[si+6]
xchg edx,ds:[si+4]
t1_tri:
cmp ax,ds:[si+10]
jle t2_tri
mov ax,ds:[si+10]
xchg edx,ds:[si+8]
t2_tri:         
mov ds:[si],edx              ; elsì a legfîlsì
;
mov ax,ds:[si+6]
mov edx,ds:[si+4]
cmp ax,ds:[si+10]
jle t3_tri
xchg edx,ds:[si+8]            ; [si+4]-en az als¢k kîzÅl a felsì
mov ds:[si+4],edx             ; [si+8]-on az als¢k kîzÅl az alsì
t3_tri:
;
; elìkÇsz°tÇs - leosztjuk
;
mov ax,ds:[si+2]
mov cs:line,ax
xchg ah,al
mov dx,ax
shr ax,2
add dx,ax
mov cs:line320,dx                ; hol kezdÅnk ?
;
mov bx,ds:[si+10]
sub bx,ds:[si+2]              ; a teljes h†romszîg magass†ga
or bx,bx
jz end1_tri
mov ax,ds:[si+8]
sub ax,ds:[si]
cwde
movsx ebx,bx
shl eax,8                     ; felszorozzuk
cdq                           ;
idiv ebx                      ; Çs leosztjuk
mov cs:lepes2_tri,eax
;
mov cx,ds:[si+6]
sub cx,ds:[si+2]              ; a h†romszîg felsì kish†romszîgÇnek magass†ga
jcxz end2_tri
mov ax,ds:[si+4]
sub ax,ds:[si]
cwde
movsx ecx,cx
shl eax,8                     ; felszorozzuk
cdq                           ;
idiv ecx                      ; Çs leosztjuk
mov cs:lepes1_tri,eax
;
; elsì fìciklus 
;
push ecx ebx si 
mov ax,ds:[si]
cwde
shl eax,8                     ; kezdì x koordin†ta
mov ebx,eax                   ; mindkÇt vonaln†l azonos
mov edx,eax                   ;
cik1_tri:
push cx ebx edx
call bp         ; horizline offset in bp
pop edx ebx
add ebx,cs:lepes1_tri
add edx,cs:lepes2_tri
inc cs:line
add cs:line320,screen_width
pop cx
loop cik1_tri
;
; m†sodik fìciklus
;
pop si eax ecx           
jmp short t0_tri
;
end2_tri:
mov eax,ebx
push eax
mov ax,ds:[si]
cwde
shl eax,8                     ; kezdì x koordin†ta
mov edx,eax                   ; mindkÇt vonaln†l azonos
mov ax,ds:[si+4]
cwde
shl eax,8
mov ebx,eax                   ;
pop eax
;
t0_tri:
sub eax,ecx                   ; m†sodik kish†romszîg magass†ga
mov ecx,eax
jcxz end1_tri
mov ax,ds:[si+8]              ; lepes1-et kell m¢dos°tani !!
sub ax,ds:[si+4]
push edx
cwde
shl eax,8                     ; fel is kÇne szorozni
cdq
idiv ecx
mov cs:lepes1_tri,eax
pop edx
;
cik2_tri:
push cx ebx edx
call bp
pop edx ebx
add ebx,cs:lepes1_tri
add edx,cs:lepes2_tri
inc cs:line
add cs:line320,screen_width
pop cx
loop cik2_tri
;
end1_tri:
pop bp
retn

;
; horizline
;
horizline_tri:
sar ebx,8
sar edx,8
cmp bx,dx
jle t1_hln
xchg bx,dx
t1_hln:

cmp bx,0
jge t6_hln
xor bx,bx
cmp dx,0
jge t6_hln
jmp noline_tri
t6_hln:
cmp dx,320
jb t5_hln
mov dx,319
cmp bx,320
jb t5_hln
jmp noline_tri
t5_hln:              ; clip

mov cx,dx
sub cx,bx
mov di,bx
add di,cs:line320
inc cx
mov al,cs:color_tri
mov ah,al
push ax
push ax
pop eax
;
shr cx,1
jnc t2_hln
stosb
t2_hln:
shr cx,1
jnc t4_hln
stosw
t4_hln:
jcxz t3_hln
rep stosd
t3_hln:
noline_Tri:
retn

;-( horizline for vecc )-;
horizline_vecc_tri:
sar ebx,8
sar edx,8
cmp bx,dx
jle t1_hln_
xchg bx,dx
t1_hln_:

cmp bx,0
jge t6_hln_
xor bx,bx
cmp dx,0
jge t6_hln_
jmp noline_tri_
t6_hln_:
cmp dx,320
jb t5_hln_
mov dx,319
cmp bx,320
jb t5_hln_
jmp noline_tri_
t5_hln_:              ; clip

mov cx,dx
sub cx,bx
mov di,bx
mov si,320
sub si,di
add di,cs:line320
add si,cs:line320
sub si,cs:d_xeltol
add si,160
inc cx
;
push ds
mov ds,cs:plasmaseg
shr cx,1
jnc t2_hln_
movsb
t2_hln_:
shr cx,1
jnc t4_hln_
movsw
t4_hln_:
jcxz t3_hln_
rep movsd
t3_hln_:
pop ds
noline_Tri_:
retn

