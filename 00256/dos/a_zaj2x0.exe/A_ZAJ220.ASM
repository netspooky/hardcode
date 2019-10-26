      ;CODE:Larry/HêV+    27-01-99
      ;A programozas alantos szintjeit megcelzo,tudatosan kaotikus hangulatot
      ;teremto csoppseg..
        .386

assume cs:kood,ds:kood
kood segment use16
        org 0100h

;        baseport        =       210h
        baseport        =       220h ;GUS baziscim
;        baseport        =       230h
;        baseport        =       240h
;        baseport        =       250h
;        baseport        =       260h

start:
       mov al,13h
       int 10h

;Sample copy
;       xor di,di;<-    mov dword ptr[offset gusaddrlo],eax
trsmp0:mov cl,255;59           ;59 byte a zongorka!
           ;mov si,offset tesztsample
           mov si,0100;A kodot jatszuk le !
trsmp:lodsb         ;DS:SI
      mov bl,al
;      mov dx,word ptr[baseport]
;      add dx,103h
      mov dx,baseport+103h
      mov al,43h
      out dx,al
      inc dx
      mov ax,di;mov ax,word ptr[gusaddrlo]
      out dx,ax
      dec dx
      mov al,44h
      out dx,al
      inc dx
      inc dx
      xor ax,ax;mov al,byte ptr[gusaddrhi]
      out dx,al
      inc dx
      inc dx
      mov al,bl
      out dx,al

      inc di;inc word ptr[gusaddrlo];add word ptr[gusaddrlo],1
      loop trsmp

;------------------
;Hang parameterek beallitasa
      mov cx,0201h           ;start lo
      xor bx,bx
;      mov ah,02h
      pusha
      call setgusreg
      popa
      inc ch                    ;start hi
;      pusha
      call setgusreg
;      popa
      inc ch;      inc ah
      inc bl    ;mov bx,1
      call setgusreg
      mov cx,0901h    ;hangero
;      mov cl,1
       mov bh,0cfh      ;mov bx,0cf90h
      call setgusreg
;      xor ax,ax
;      mov cl,0
      xor cx,cx
      mov bl,8
      call setgusreg
;----------------------------

;Itt szamoljuk ki a kepet

       push 0a000h
       pop es
       mov si,320       ;yk-t szorozzuk ezzel
       mov bx,offset szorz
again2:mov bp,179
again: mov [bx],bp
       mov cx,400h    ;4*256 pont egy ivre
       fldz
       fistp dword ptr[si+0ffh]
sinmak:nop
       fld dword ptr[si+0ffh]
       fsincos
       fimul word ptr[bx]
       fistp word ptr[cxk]+1
       fimul word ptr[bx]
       fistp word ptr[cyk]+1
       fld dword ptr[si+0ffh]
       fadd dword ptr[_lep]
       fstp dword ptr[si+0ffh]
cyk:   mov ax,1234h
       add ax,100     ;<=yoff
       mul si
cxk:   mov di,1234h;word ptr[xk]
       add di,di
       add di,160     ;<=xoff
       add di,ax
       mov ax,cx
       sub ax,bp
       mov ah,al
       stosw
       stosw
       loop sinmak
       dec bp
       jnz short again
;==================================================
aga3:  mov ch,38h;04fh ;Lassitjuk !
idee:  out 0,al
;       in al,0
       loop idee
       mov ch,1
;       mov al,0
       mov dx,03c8h
       out dx,al
       inc dx
sc1:   mov al,bh
       out dx,al
       neg al;       mov al,0
       out dx,al
shr al,3
       out dx,al
       add bx,0ffh;41h-2;0ffh;041h-2
       loop sc1
pusha
sub word ptr[gfrekv],0f347h;Ez joo
;sub word ptr[gfrekv],03347h;03347h
;and word ptr[gfrekv],03344h;03347h
mov bx,word ptr[gfrekv]
mov cx,0101h;mov cl,1
;mov ah,1
call setgusreg
popa


        in al,60h
        cmp al,1
       jnz short aga3
;xor ax,ax
xor bx,bx
xor cx,cx
;xor cx,cx
call setgusreg

       ret

;\===========================================================================/
setgusreg proc ;AL:szolam szama(=0!) BX:adat!
               ;CH:GUS regiszter szama
               ;CL=0 byte-os adat   CL<>0 word-os
;      mov dx,word ptr[baseport]
;      add dx,102h
      mov dx,baseport+102h
mov al,0;<-!!!
      out dx,al
      out dx,al
      out dx,al
      inc dx
      mov al,ch;mov al,ah         ;reg. kivalasztas
      out dx,al
      inc dx  ;word
      mov ax,bx
      or cl,cl
      jnz short setgw
      inc dx
      out dx,al
      ret
setgw:out dx,ax
      ret
endp

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_lep:  db  0dbh,0fh,0c9h,3bh;Ivre szamolt SINUS leptek 2pi/1024 float
gfrekv:dw  ?;GUS freki
szorz: dw  ?
ends
end start