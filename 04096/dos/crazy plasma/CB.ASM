RELEASE=1
.model small,pascal
.code
.386
  org 100h
start:
  call getmem
  call getfont
  call smoothfont
  call finfont
  mov   ax,13h
  int   10h
  call makepal
  mov  ptinc,0
  mov  ax,map1
  mov  edx,08B6CF109h
  call plasma
  mov  al,0
  mov  ds,map1
  call plot4,94,63
  call plot4,95,60
  mov  ptinc,128
  mov  ax,map2
  mov  edx,03C7003F1h
  call plasma
  cli
mainloop:
  call pic
  call updtext
  call fillscreen
  in   al,60h
  cmp  al,1
  jz   fin
  mov  al,bright
  inc  al
  cmp  al,65
  jae  full1
  mov  bright,al
full1:
  mov  eax,dtx
  add  xobs,eax
  mov  eax,dty
  add  yobs,eax
  mov  eax,dtz
  add  zobs,eax
  mov  eax,dtc
  add  ceiling,eax
  mov  ax,dta
  add  a,ax
  mov  ax,dth
  add  h,ax
  mov  eax,ddx
  add  dtx,eax
  mov  eax,ddy
  add  dty,eax
  mov  eax,ddz
  add  dtz,eax
  mov  eax,ddc
  add  dtc,eax
  dec  globticks
  jnz  mainloop
  push cs
  pop  ds
  mov  si,comptr
  add  si,20
  mov  comptr,si
  mov  ax,[si]
  add  globticks,ax
  jz   fin
  movsx  eax,word ptr [si+2]
  sal    eax,8
  mov    dtx,eax
  movsx  eax,word ptr [si+4]
  sal    eax,8
  mov    dty,eax
  movsx  eax,word ptr [si+6]
  sal    eax,8
  mov    dtz,eax
  movsx  eax,word ptr [si+8]
  sal    eax,8
  mov    dtc,eax
  movsx  eax,word ptr [si+10]
  sal    eax,8
  mov    ddx,eax
  movsx  eax,word ptr [si+12]
  sal    eax,8
  mov    ddy,eax
  movsx  eax,word ptr [si+14]
  sal    eax,8
  mov    ddz,eax
  movsx  eax,word ptr [si+16]
  sal    eax,8
  mov    ddc,eax
  movsx  ax,byte ptr [si+18]
  mov    dta,ax
  movsx  ax,byte ptr [si+19]
  mov    dth,ax
  jmp    mainloop
fin:
  call pic
  call fillscreen
  add   dtx,65536*16
  add   dtz,65536*6
  add   h,8
  add   a,16
  dec   bright
  jnz   fin
  sti
  mov  dx,offset finalmsg
reallyquit:
  push dx
  mov  ax,3
  int  10h
  pop  dx
  mov  ah,9
  push cs
  pop  ds
  int  21h
  mov  ah,4ch
  int  21h

pic proc near
  pushad
  movzx  eax,h

  call   sin
  mov    ebp,eax
  movzx  eax,h

  call   cos
  mov    ecx,eax
  movzx  eax,a

  call   sin
  mov    ebx,eax
  movzx  eax,a

  call   cos
  mov    cosa,eax
  sub    eax,ebx
  mov    esi,eax
  imul   ebp
  shrd   eax,edx,16
  neg    eax
  add    eax,xobs
  push   eax
  sub    eax,ecx
  mov    xlu,eax
  pop    eax
  add    eax,ecx
  mov    xru,eax
  mov    eax,ecx
  imul   esi
  shrd   eax,edx,16
  add    eax,zobs
  push   eax
  sub    eax,ebp
  mov    zlu,eax
  pop    eax
  add    eax,ebp
  mov    zru,eax
  mov    eax,ebx
  add    eax,cosa
  add    eax,yobs
  mov    yu,eax
  mov    eax,ebx
  neg    eax
  imul   ebp
  shrd   eax,edx,23
  mov    dx1,eax
  mov    eax,ebx
  imul   ecx
  shrd   eax,edx,23
  mov    dz1,eax
  mov    eax,cosa
  neg    eax
  sar    eax,7
  mov    dy1,eax
  xor    ax,ax
  mov    es,ax
  mov    eax,dword ptr es:[0]
  mov    oldvect,eax
  mov    word ptr es:[0],offset divhandler
  mov    word ptr es:[2],cs
  mov    counter,0
  mov    es,framebuffer
mlop:
  mov    eax,yobs
  dw     03D66h         ;cmp eax,yu
yu dd 0
  push   ds
  jng    else1
line1:
  mov    eax,yobs
  sub    eax,yu
  mov    var1,eax
  mov    eax,zobs
  dw     02D66h         ;sub eax,zlu
zlu dd 0
  imul   yobs
  idiv   var1
  add    eax,zobs
  ror    eax,16
  mov    ebx,eax
  mov    bh,bl
  mov    eax,xobs
  dw     02D66h         ;sub eax,xlu
xlu dd 0
  imul   yobs
  idiv   var1
  add    eax,xobs
  ror    eax,16
  mov    edi,eax
  mov    bl,al
  mov    eax,zlu
  dw     02D66h         ;sub eax,zru
zru dd 0
  imul   yobs
  idiv   var1
  sar    eax,8
  ror    eax,16
  mov    esi,eax
  mov    ch,al
  mov    eax,xlu
  dw     02D66h         ;sub eax,xru
xru dd 0
  imul   yobs
  idiv   var1
  mov    ds,map1
  jmp    common
else1:
line2:
  mov    eax,yobs
  sub    eax,yu
  mov    var1,eax
  mov    eax,ceiling
  sub    eax,yobs
  mov    var2,eax
  mov    eax,zlu
  sub    eax,zobs
  imul   var2
  idiv   var1
  add    eax,zobs
  ror    eax,16
  mov    ebx,eax
  mov    bh,bl
  mov    eax,xlu
  sub    eax,xobs
  imul   var2
  idiv   var1
  add    eax,xobs
  ror    eax,16
  mov    edi,eax
  mov    bl,al
  mov    eax,zru
  sub    eax,zlu
  imul   var2
  idiv   var1
  sar    eax,8
  ror    eax,16
  mov    esi,eax
  mov    ch,al
  mov    eax,xru
  sub    eax,xlu
  imul   var2
  idiv   var1
  mov    ds,map2
common:
  db     0BFh        ;mov di,counter
counter dw 0
  sar    eax,8
  ror    eax,16
  mov    edx,eax
  mov    cl,al
  mov    dx,1
  mov    si,0
  shl    di,8
  sub    di,2
  mov    bp,128
lop:
  mov    al,[bx]
  add    edi,edx
  adc    bl,cl
  add    ebx,esi
  adc    bh,ch
  mov    ah,[bx]
  add    edi,edx
  adc    bl,cl
  add    ebx,esi
  adc    bh,ch
  mov    es:[di],ax
  dec    bp
  jnz    lop
endif1:
  pop    ds
  dw     0B866h           ;mov eax,dx1
dx1 dd 0
  add    xlu,eax
  add    xru,eax
  dw     0B866h           ;mov eax,dz1
dz1 dd 0
  add    zlu,eax
  add    zru,eax
  dw     02E66h,00681h,offset yu  ;add yu,dy1
dy1 dd 0
  inc    counter
  cmp    counter,200
  jnz    mlop
  xor    ax,ax
  mov    es,ax
  dw     0B866h  ;mov eax,oldvect
oldvect dd 0
  mov    dword ptr es:[0],eax
  popad
  ret
endp

cos proc near
  add    ax,256
endp

sin proc near
  push   dx
  and    ax,1023
  push   ax
  and    ax,511
  sub    ax,256
  cwde
  imul  eax,eax
  neg   eax
  add   eax,65536
  pop   dx
  cmp   dx,512
  jbe   sinok
  neg   eax
sinok:
  pop   dx
  ret
endp

Plot4:  push    bp
        mov     bp,sp
        mov     bh,[bp+4]
        mov     bl,[bp+6]
        and     al,63
        add     al,ptinc
        mov     [bx],al
        neg     bl
        dec     bl
        mov     [bx],al
        neg     bh
        dec     bh
        mov     [bx],al
        inc     bl
        neg     bl
        mov     [bx],al
        pop     bp
        ret     4

Adjust: push    bp
        mov     bp,sp
        push    cx
        mov     bh,[bp+8]
        mov     bl,[bp+10]
        xor     ax,ax
        or      al,[bx]
        jnz     EndAdj
        mov     cx,[bp+6]
        sub     cx,[bp+14]
        add     cx,[bp+4]
        sub     cx,[bp+12]
        shl     cx,1
        mov     ax,cs:randseed
        mov     dx,8405H
        mul     dx
        inc     ax
        mov     cs:randseed,ax
        imul    cx
        xor     ax,ax
        mov     bh,[bp+12]
        mov     bl,[bp+14]
        mov     al,[bx]
        add     dx,ax
        mov     bh,[bp+4]
        mov     bl,[bp+6]
        mov     al,[bx]
        add     ax,dx
        shr     ax,1
        call    Plot4,word ptr [bp+10],word ptr [bp+8]
EndAdj: pop     cx
        pop     bp
        ret     12

SubDiv proc near
arg x1:word,y1:word,x2:word,y2:word
        push    si
        push    di
        mov     si,x1
        mov     di,y1
        mov     ax,x2
        sub     ax,si
        cmp     al,2
        jae     SDOk1
        mov     ax,y2
        sub     ax,di
        cmp     al,2
        jb      SDEnd
SDOk1:  add     si,x2
        shr     si,1
        add     di,y2
        shr     di,1
        call    Adjust,x1,y1,si,y1,x2,y1
        mov     cx,ax
        call    Adjust,x2,y1,x2,di,x2,y2
        add     cx,ax
        call    Adjust,x1,y2,si,y2,x2,y2
        add     cx,ax
        call    Adjust,x1,y1,x1,di,x1,y2
        add     ax,cx
        shr     ax,2
        call    Plot4,si,di
        call    SubDiv,x1,y1,si,di
        call    SubDiv,si,y1,x2,di
        call    SubDiv,si,di,x2,y2
        call    SubDiv,x1,di,si,y2
SDEnd:  pop     di
        pop     si
        ret
endp

plasma proc near     ;ax=segment
        push    ds
        mov     ds,ax
        mov     es,ax
        xor     di,di
        mov     cx,32768
        xor     ax,ax
        cld
        rep     stosw
        mov     al,dl
        call    plot4,0,0
        mov     al,dh
        call    plot4,127,0
        rol     edx,16
        mov     al,dl
        call    plot4,0,127
        mov     al,dh
        call    plot4,127,127
        call    subdiv,0,0,127,127
        pop     ds
        ret
endp

fillscreen proc near
  push ds
  cld
  mov     dx,3dah
sync:
  in      al,dx
  test    al,8
  jz      Sync
  call    setpal

  mov     ds,framebuffer
  mov     ax,0a000h
  mov     es,ax
  mov     di,32
  xor     si,si
  mov     dx,200
move1lin:
  mov     cx,64
  rep     movsd
  add     di,64
  dec     dx
  jnz     move1lin
  pop     ds
  ret
endp

getmem proc near
  mov  ah,62h
  int  21h
  mov  es,bx
  mov  bx,4096
  mov  ah,4ah
  int  21h
  mov  ah,48h
  mov  bx,4096*4
  int  21h
  jc   memerror
  mov  framebuffer,ax
  add  ax,4096
  mov  map1,ax
  add  ax,4096
  mov  map2,ax
  add  ax,4096
  mov  fontseg,ax
  ret
memerror:
  mov  dx,offset memmsg
  jmp  reallyquit
memmsg db 'Out of memory !',13,10,'$'

endp

makepal proc near
  push cs
  pop  es
  mov  di,offset pal
  xor  ax,ax
pallop1:
  xor  al,al
  stosb
  mov  al,ah
  stosb
  xor  al,al
  stosb
  inc  ah
  cmp  ah,64
  jb   pallop1
  xor  ah,ah
pallop2:
  mov  al,ah
  stosb
  xor  al,al
  stosb
  stosb
  inc  ah
  cmp  ah,64
  jb   pallop2
  xor  ah,ah
pallop3:
  xor  al,al
  stosb
  stosb
  mov  al,ah
  stosb
  inc  ah
  cmp  ah,64
  jb   pallop3
  xor  ah,ah
  ret
endp

setpal proc near
  mov  dx,3c8h
  xor  al,al
  out  dx,al
  inc  dx
  push cs
  pop  ds
  mov  si,offset pal
  mov  cx,768
  mov  bl,bright
daclop:
  lodsb
  mul  bl
  shr  ax,6
  out  dx,al
  loop daclop
  ret
endp

getfont proc near
  push  ds
  mov   es,fontseg
  mov   di,1
  mov   ax,1130h
  mov   bh,6
  push  es
  int   10h
  mov   si,bp
  push  es
  pop   ds
  pop   es
  mov   dx,2032
fontlop1:
  lodsb
  mov   ah,al
  mov   cx,8
fontlop2:
  xor   al,al
  rol   ah,1
  jnc   fontskip1
  mov   al,63
fontskip1:
  stosb
  stosb
  push  di
  add   di,14
  stosb
  stosb
  pop   di
  loop  fontlop2
  add   di,16
  dec   dx
  jnz   fontlop1
  pop   ds
  ret
endp

smoothfont proc near
  push  ds
  mov   es,fontseg
  xor   di,di
  mov   ds,fontseg
  mov   si,255
smtlop1:
  xor   di,di
  mov   cx,256
smtlop2:
  lodsb
  add   al,byte ptr [si+1]
  add   al,byte ptr [si-16]
  add   al,byte ptr [si+16]
  shr   al,2
  stosb
  loop  smtlop2
  push  si
  sub   si,255
  xor   di,di
  xchg  si,di
  mov   cx,256
  cld
  rep   movsb
  pop   si
  cmp   si,253*256
  jbe   smtlop1
  pop   ds
  ret
endp

finfont proc near
  mov   es,fontseg
  xor   di,di
  mov   cx,65535
fflop:
  add   byte ptr es:[di],64
  inc   di
  loop  fflop
  ret
endp

dchar proc near ;di=address al=char
  push  ds
  mov   ds,fontseg
  xor   si,si
  shl   ax,9
  add   si,ax
  mov   es,framebuffer
  mov   dx,32
dlop1:
  mov   cx,16
dlop2:
  lodsb
  cmp  al,8+64
  jb   nostor
  mov  es:[di],al
nostor:
  inc  di
  loop dlop2
  add  di,256-16
  jc   quitchar
  dec  dx
  jnz  dlop1
quitchar:
  pop  ds
  ret
endp

dtext proc near ;si-asciiz string di-target
  push  cs
  pop   ds
  lodsb
  test  al,al
  jz    dtend
  push  si
  push  di
  call  dchar
  pop   di
  pop   si
  mov   ax,di
  add   al,16
  jnc   okdt
  add   ax,32*256
  jc    dtend
okdt:
  mov   di,ax
  jmp   dtext
dtend:
  ret
endp

updtext proc near
  mov  si,offset text1
  mov  di,16
  call dtext
  mov  si,offset text3
  mov  di,8+256*(227-56)
  call dtext
  mov  ax,ticks
  cmp  ax,504
  ja   newtext
  add  ax,4
conttext:
  mov  ticks,ax
  mov  di,256
  sub  di,ax
  cmp  ax,256
  jbe  ok11
  neg  di
ok11:
  shl  di,8
  shl  ax,3
  call sin
  shr  eax,12
  add  ax,16
  add  di,ax
  mov  si,curtext
  call dtext
  ret

newtext:
  mov  si,curtext
  dec  si
find:
  inc  si
  cmp  byte ptr cs:[si],0
  jnz  find
  inc  si
  mov  curtext,si
  mov  ax,2
  jmp  conttext

endp

divhandler:
  push bp
  mov  bp,sp
  add  word ptr [bp+2],6
  pop  bp
  iret
text1 db ' Crazy Plasma',0

text2:
      db 'Ladies (?) and  '
      db ' gentlemen(!)',0
      db 'I proudly(???)  '
      db '   present',0
      db 'my first intro  '
      db '    called',0
      db ' Crazy Plasma',0
      db 'OK, let''s go!',0
      db 'I know it was   '
      db 'nothing new...',0
      db ' The following   '
      db 'effect won''t    '
      db 'be too...',0,0,0
      db '-Some rotates?  '
      db '-No problem!',0
      db 'Take a close    '
      db 'look at these   '
      db 'clouds...',0
      db 'Let''s stop for  '
      db 'a while...',0
      db '  Next, some    '
      db 'vertical moves',0
      db ' Hey, look at    '
      db '   this !',0
      db '  Aren''t you    '
      db ' getting sick   '
      db '     yet?',0
      db 'I have a good   '
      db 'news for you:',0
      db ' That''s all...',0
      db ' ',0
      db ' ',0
      db ' ',0
text3 db 'A 4K for GP III',0

curtext dw offset text2
comptr dw offset comlist-20
comlist:   ;ticks:word (128=1 text cycle,0=finish)
           ;dx,dy,dz,dceil:word
           ;ddx,ddy,ddz,ddceil:word
           ;da,dh:byte
dw 384                   ;first 3 texts wait
dw 0,0,0,0
dw 0,0,0,0
db 0,0

dw 128                   ;"crazy bitmaps"-bit faster
dw 0,0,0,0
dw 2,0,0,0
db 0,0

dw 64                    ;"ok, let's go"-accelerate
dw 256,0,0,0
dw 8,0,0,0
db 0,0

dw 64                    ;Walk
dw 768,0,0,0
dw 0,0,0,0
db 0,0

dw 128                   ;"pause" - still accelerate
dw 768,0,0,0
dw 8,0,0,0
db 0,0

dw 64                    ;"this was nothing new"
dw 1792,0,0,0            ;slowdown & accel again
dw -28,0,0,0
db 0,0

dw 64
dw 0,0,0,0
dw 16,0,0,0
db 0,0

dw 128                  ;"the following..." -speedup
dw 1024,0,0,0
dw 32,0,0,0
db 0,0

dw 32                  ;change direction
dw 5120,0,0,0
dw -160,0,128,0
db 0,0

dw 32                  ;change direction
dw 0,0,4096,0
dw 128,0,-128,0
db 0,0

dw 32
dw 4096,0,0,0
dw -128,0,128,0
db 0,0

dw 32                  ;change direction
dw 0,0,4096,0
dw 128,0,-128,0
db 0,0

dw 64                   ;some rotates-first slowly left
dw 4096,0,0,0
dw 0,0,0,0
db 0,3

dw 32                   ;fast right
dw 4096,0,0,0
dw 0,0,0,0
db 0,-12

dw 32                   ;fast left
dw 4096,0,0,0
dw 0,0,0,0
db 0,6

dw 64                   ;climb up
dw 4096,256,0,0
dw -32,0,0,0
db 0,16

dw 64
dw 2048,-256,0,0           ;and down
dw 0,0,0,0
db 0,16

dw 128
dw 2048,-120,0,0
dw -16,1,0,0
db 0,1

dw 32                      ;up
dw 0,384,0,0
dw 0,0,0,0
db 0,1

dw 32                      ;and down
dw 0,-384,0,0
dw 0,0,0,0
db 0,1

dw 64                      ;ceiling down
dw 0,0,0,-230
dw 0,0,0,0
db 0,2

dw 32
dw 0,128,0,256
dw 0,0,0,0
db 0,1

dw 32
dw 0,0,0,0
dw 0,0,0,0
db 16,0

dw 64
dw 256,32,128,32
dw 0,0,0,0
db 8,14

dw 128
dw 512,-16,256,-16
dw 0,0,0,0
db 9,15

dw 128
dw 1024,16,512,16
dw 0,0,0,0
db 12,18

dw 128
dw 2048,0,1024,0
dw 0,0,0,0
db 13,19

dw 128
dw 4096,1,2048,2
dw 128,8,64,16
db 14,21

dw 0

finalmsg:
db '­ Crazy Plasma !'
if RELEASE eq 1
db ' by MUFL0N/STONES'
endif
db 13,10,10
db '...read .nfo for more .nfo...',13,10
db '$MS'
randseed dw 17362
ceiling dd 60*65536
xobs dd 0
yobs dd 30*65536
zobs dd 0
h dw 256
a dw 0
globticks dw 1
ticks dw 1
txtpos dw 0
ptinc db 0
bright db 0
dtx dd 0
ddx dd 0
dty dd 0
ddy dd 0
dtz dd 0
ddz dd 0
dtc dd 0
ddc dd 0
dta dw 0
dth dw 0
var1 dd ?
var2 dd ?
cosa dd ?
map1 dw ?
map2 dw ?
framebuffer dw ?
fontseg dw ?
pal db 768 dup (?)
;stack 32768
end start
