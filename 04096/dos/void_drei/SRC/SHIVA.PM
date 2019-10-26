CODE_32 SEGMENT

;makes teh next precalc dot
precalc_dot proc
        pushad
        add precalcpos, 8
        lea edi, [ebp+(320*24)*4]
        add edi, precalcpos
        dec dword ptr [edi]
        call flipfunction
        popad
ret
precalc_dot endp

;sets display bank edx
setbank proc
        pushad
        mov ax, 04f05h
        xor ebx, ebx 
        int 10h      
        popad
ret
setbank endp

getgrafaddr proc
        push ebp
        mov ax, 02h
        mov bx, 0a000h     
        int 31h
        pop ebp
        mov es, ax        
ret
getgrafaddr endp

;some 256-grayscales blitter
flipgray proc
        pushad
        push es
        call getgrafaddr
        lea esi, [ebp+(320*20)*4+1] ;screen is always ebp
        xor edi, edi
        mov ecx, 320*200/4
        @blitloop1:
            mov al, [esi]
            mov ah, [esi+4]
            shl eax, 16
            mov al, [esi+8]
            mov ah, [esi+12]
            ror eax, 16
            mov es:[edi], eax
            add esi, 16
            add edi, 4
        dec ecx
        jnz @blitloop1
        pop es
        popad        
ret
flipgray endp

fliphi proc
        pushad
        push es
        call getgrafaddr
        mov esi, ebp ;screen is always ebp
        
        xor ecx, ecx
        @linesloop:
        push ecx
            ;set target bank
            mov edx, ecx 

           imul edx, 640*2*4

            xor edi, edi ;offset in segment
            mov di, dx
            shr edx, 16  ;bank number (64k banks)

            call setbank

            mov ecx, 320
            @xcopyhi:
                mov eax, [esi]
                mov es:[edi], eax
                mov es:[edi+4], eax
                add esi, 4
                add di, 8
                jc @bankagain
                @backtocopy:
            dec ecx
            jnz @xcopyhi

        pop ecx
        inc ecx
        cmp ecx, 240
        jne @linesloop

        pop es
        popad
ret
        @bankagain:
        inc edx ;set next bank
        call setbank
        xor edi, edi
        jmp @backtocopy
fliphi endp

;low res (best) blitter, like in party version
fliplo proc ;this code just "assumes" 64k bank size and 0 pitch
        pushad
        push es
        call getgrafaddr
        mov esi, ebp ;screen is always ebp
        mov al, 5 ;copy full 5 segments
        xor edx, edx ;bank 0
        @bankloop:
            call setbank
            xor edi, edi
            mov ecx, 010000h shr 2
            rep movsd
            inc edx
        dec al
        jnz @bankloop
        pop es
        popad
ret
fliplo endp                    

;edi = dest
invert proc
     mov ecx, (320*240)/2
     @invloop:
         xor dword ptr [edi], 0ffffffffh
         xor dword ptr [edi+4], 0ffffffffh
         add edi, 8
     dec ecx
     jnz @invloop
ret
invert endp

;background renderer

;same as grid. return st(0), st(1) scaled & centerd x/y
getrealxy proc
     push ecx
     sub cl, 11
     sub ch, 20
     mov dl, 2
     @getrealloop:
         movsx eax, ch
         shl eax, 3
         mov [esi], eax
         fild dword ptr [esi]
         mov ch, cl
     dec dl
     jnz @getrealloop
     pop ecx
ret
getrealxy endp

;cl=x, ch=y, esi=dest (x,y,s)
;esi, ebx, ecx: keep em save
grid_putlinear proc
     movzx eax, cl
     shl eax, 3
     mov [esi], eax
     movzx eax, ch
     shl eax, 3
     add eax, globalt
     mov [esi+4], eax
     mov dword ptr [esi+8], 0ffh
ret
grid_putlinear endp

;esi, ebx, ecx: keep em save
;cl/ch : x/y esi: dest
grid_waves proc
     call getrealxy
     fld st(1)
     fld st(1)

     mov al, 2
     @twiceloop:
        fiadd globalt
        fidiv i_32
        fsin
        fimul i_127
        fxch st(1)
     dec al
     jnz @twiceloop

     faddp st(3), st(0)
     faddp st(1), st(0)
     fistp dword ptr [esi]
     fistp dword ptr [esi+4]

     mov dword ptr [esi+8], 0feh
ret
grid_waves endp

;cl=x, ch=y, esi=dest (x,y,s)
;esi, ebx, ecx: keep em save
grid_traceplanes proc
     call getrealxy
     ;compute the stupid direction vector
     pushad
     lea esi, [matrix]
     lea edi, [esp-126] ;[tempmem]
     lea ebx, [edi+12]
     fstp dword ptr [edi]
     fstp dword ptr [edi+4]
     mov dword ptr [edi+8], 0437f0000h ;=255.0
     call mattrans
     ;[edi+12] = direction, origin is zero ;)
     fld dword ptr [edi+12]
     fld dword ptr [edi+16]
     fld dword ptr [edi+20]
     popad

    fild i_255
    fdiv st(0), st(1)        
    fld st(3)                               
    fmul st(0), st(1)                       
    fabs                   
    fistp dword ptr [esi]                  
                                            
    fld st(2)               
    fmul st(0), st(1)        
    fabs                     
    fistp dword ptr [esi+4]

    fabs
    fchs
    ;fimul i_16
    fistp dword ptr [esi+8]
    shl dword ptr [esi+8], 3
    cmp byte ptr [esi+9], 255
    jz @noclamp
        mov word ptr [esi+8], -255
    @noclamp:
                            
    fninit
ret
grid_traceplanes endp


;esi = first grid entry, edi = dest
drawblock proc
     push ecx
     lea ebx, [esp-126] ;tempmem
     mov edx, 20
     @computeloop1:
         mov eax, [esi+edx]
         shl eax, 3
         mov [ebx+edx*2], eax
         mov eax, [esi+edx+(((320/8)+1)*12)]
         sub eax, [esi+edx]
         mov [ebx+edx*2+4], eax
     sub edx, 4
     jns @computeloop1

     mov cl, 8
     @yblockloop:
         mov edx, 16
         @computeloop2:
             ;compute horizontal deltas
             mov eax, [ebx+edx]
             shl eax, 3
             mov [ebx+edx+48], eax
             mov eax, [ebx+edx+24]
             sub eax, [ebx+edx]
             mov [ebx+edx+4+48], eax
             ;add vertival deltas
             mov eax, [ebx+edx+4]
             add [ebx+edx], eax
             mov eax, [ebx+edx+4+24]
             add [ebx+edx+24], eax
         sub edx, 8
         jns @computeloop2
         mov ch, 8
         @xblockloop:
             push ecx
             xor eax, eax
             mov ax, [ebx+48]
             mov al, [ebx+57]             
             db 08dh, 094h, 085h  ;lea edx, [eax*4+ ] 
             texturemapptr:
             dd texturebase

             xor eax, eax
             mov ah, [ebx+65]

             ;very slow, but size _does_ matter ;)
             ;mov cl, 4
             ;@fuckyloop:
             ;  mov al, [edx]
             ;  mov ch, [shademap+eax]
             ;  mov [edi], ch
             ;  inc edx
             ;  inc edi
             ;  dec cl
             ;jnz @fuckyloop

             rept 3
             mov al, [edx]
             mov cl, [shademap+eax]
             mov [edi], cl
             inc edx
             inc edi
             endm

             ;add horizontal deltas (same size as in loop!)
             ;wow! even slightly pairing optimized ;)
             mov eax, [ebx+52]
             mov ecx, [ebx+60]
             mov edx, [ebx+68]
             add [ebx+48], eax
             add [ebx+56], ecx
             add [ebx+64], edx

             inc edi

             pop ecx
         dec ch
         jnz @xblockloop
         add edi, (320-8)*4
     dec ecx
     jnz @yblockloop

     pop ecx
ret
drawblock endp 

;sprite drawer
;esi = sprite descriptor, ebx = cliptop, 0=clipbot, edx=offset
;al = 0: completly out al=1: drawit
clipme proc
     xor ecx, ecx 
     push esi
     add esi, edx
     ;clip it!
     mov eax, [esi+16]
     cmp eax, ebx
     jge @clipped
     add eax, [esi+8]
     cmp eax, ebx
     jng @noclip1
         xchg eax, ebx
         sub eax, [esi+16]
         mov [esi+8], eax
     @noclip1:

     mov eax, [esi+16]
     cmp eax, ecx
     jge @noclip2
         add eax, [esi+8]
         cmp eax, ecx
         jle @clipped
         mov [esi+8], eax
         mov eax, [esi+16]
         neg eax
        imul eax, [esi+28]
         mov [esi+44], eax
         mov dword ptr [esi+16], ecx
     @noclip2:

     mov al, 1
     pop esi
ret
     @clipped:
     xor eax, eax
     pop esi
ret
clipme endp

;esi = sprite descriptor, edi = dest
putsprite proc
     ;basic setup

     mov eax, 10000h
     cdq
    idiv dword ptr [esi-16]
     mov [esi+24], eax
     mov [esi+28], eax

     fldz
     fstp qword ptr [esi+40]

     xor edx, edx
     mov ebx, CLIPTOP
     call clipme
     cmp al, 0
     jz @completlyout

     mov edx, -4
     mov ebx, CLIPRIGHT
     call clipme
     cmp al, 0
     jz @completlyout

     mov eax, [esi+44]
     mov [esi+36], eax

     mov ecx, [esi+16]
    imul ecx, 320
     add ecx, [esi+12]
     lea edi, [edi + ecx*4]

     mov ecx, [esi+8]

     @yspriteloop:
          push ecx edi
          mov ecx, [esi+4]
          mov eax, [esi+40]
          mov [esi+32], eax
          @xspriteloop:
              xor ebx, ebx
              mov bl, [esi+32+1]
              mov bh, [esi+36+1]
              shl ebx, 2
              add ebx, [esi]              
              ;ebx = source, edi = dest
              rept 3
              mov ah, [edi]
              add ah, [ebx]
              db 0d6h
              or al, ah
              mov [edi], al
              inc ebx
              inc edi
              endm
             
              mov eax, [esi+24]
              inc edi
              add [esi+32], eax
          dec ecx
          jnz @xspriteloop
          pop edi ecx
          add edi, 320*4
          mov eax, [esi+28]
          add [esi+36], eax
     loop @yspriteloop
     @completlyout:
ret
putsprite endp

;particel system

;esi = particel data, ecx = number, globalt set.
;return = eax number of total particels for fx
;has to write (esi relativ):
;0      x,y,z
;12     basesize
;0+28   source image
;20+28  alpha value
particel_spiral proc
       mov [esi], ecx
       fild dword ptr [esi]
       fld st(0)
       fisub globalt
       fidiv i_16
       fsincos
       fmul st(0), st(2)
       fstp dword ptr [esi]
       fmul st(0), st(1)
       fstp dword ptr [esi+4]
       ffree st(0)
       xor eax, eax
       mov [esi+8], eax

       mov eax, ecx
       shr eax, 1
       add eax, 4
       cmp ecx, 1
       jnz @noz
            mov eax, 128

            push eax
            mov eax, globalt
            test byte ptr [bigflag], 010000000b
            jz @noflash
                 and byte ptr [bigflag], 01111111b
                 add eax, 32
                 mov endt, eax                 
            @noflash:

            mov eax, endt
            sub eax, globalt
            js @nof
               pop ebx
               shl eax, 5
               add eax, 128
               push eax
            @nof:

            pop eax

       @noz:
       mov [esi+12], eax
       lea eax, [textures+256*256*4*5]
       mov [esi+0+28], eax
      ; mov eax, 0ffh
      ; mov [esi+20+28], eax
       mov eax, 128
ret
particel_spiral endp

;esi = particel data, ecx = number, globalt set.
;has to write (esi relativ):
;0      x,y,z
;12     basesize
;0+28   source image
;20+28  alpha value
particel_starfield proc
       mov edx, 8
       @loadrandom:
          push ecx
          add ecx, edx
          movsx eax, byte ptr [ecx*2+noisemap]          
          push eax
          fild dword ptr [esp]
          pop eax
          fstp dword ptr [esi+edx]
          pop ecx
       sub edx, 4
       jns @loadrandom

       fld dword ptr [esi]
       fisub i_127
       fimul i_16
       fiadd globalt
       fstp dword ptr [esi]

       fld dword ptr [esi+8]
       fabs
       fidiv i_16
       fistp dword ptr [esi+12]
       add dword ptr [esi+12], 2
       lea eax, [textures+(256*256*4)*4]
       mov [esi+0+28], eax
      ; mov eax, 0ffh
      ; mov [esi+20+28], eax

       cmp ecx, 1
       jnz @nofirst
           fldz
           fst qword ptr [esi]
           fstp dword ptr [esi+8]
           fild globalt
           fidiv i_64
           fsin
           fabs
           fld1
           faddp st(1), st(0)
           fimul i_255
           fistp dword ptr [esi+12]
       @nofirst:
       mov eax, 1024
ret
particel_starfield endp

;esi = particel data, ecx = number, globalt set.
;has to write (esi relativ):
;0      x,y,z
;12     basesize
;0+28   source image
;20+28  alpha value
particel_osci proc
        push es
        mov es, sb_dmasel
            mov [esi], ecx
            fild dword ptr [esi]
            fidiv i_64
            fsincos
            mov  al, byte ptr es:[ecx*8]
            xor al, 80h
            movsx eax, al
            jns @@nos
            neg eax
            @@nos:
            add eax, eax
            mov [esi], eax
            fimul dword ptr [esi]
            fstp dword ptr [esi+4]
            fimul dword ptr [esi]
            fstp dword ptr [esi]            
        pop es
        fldz
        fstp dword ptr [esi+8]
        lea eax, [textures+256*256*4*3]
        mov [esi+0+28], eax
        mov dword ptr [esi+12], 10
        mov eax, 255
ret      
particel_osci endp


;esi = particel data, ecx = number, globalt set.
;has to write (esi relativ):
;0      x,y,z
;12     basesize
;0+28   source image
;20+28  alpha value
particel_star proc
       lea edi, [tempvector]
       push ecx
       sub ecx, 256
       push ecx
       fild dword ptr [esp]
       pop ecx
       pop ecx
       mov eax, ecx
       xor edx, edx
       mov ebx, 3
      idiv ebx
       inc dl
       mov dh, 3
       push edi
       @setloop:
           xor eax, eax
           stosd
           cmp dh, dl
           jnz @novalue
               fst dword ptr [edi-4]
           @novalue:
       dec dh
       jnz @setloop
       fstp st(0)
       pop edi

       mov ebx, esi
       push esi ecx
       lea esi, [matrixbuffer]
       shr ecx, 2
      imul ecx, 3*3*8
       add esi, ecx
       call mattrans
       pop ecx esi

       mov eax, 16
       mov [esi+12], eax
       lea eax, [textures+256*256*4*3]
       mov [esi+0+28], eax
       ;mov eax, 0ffh
       ;mov [esi+20+28], eax
       mov eax, 512
ret
particel_star endp

;ebx = particel movement function, edi = dest
renderparticels proc
     xor ecx, ecx
     @particelsloop:
           lea esi, [esp-126] ;[particelbuffer]
           pushad
           call ebx ;get the actual poition
           cmp eax, ecx
           jbe @retnow
           popad
           ;and now rotate & perspective transform the bitch

           pushad
           mov edi, esi
           lea ebx, [esi+16]
           lea esi, [matrix]
           call mattrans
           popad

           ;but perspective, we do
           fld dword ptr [esi+24]
           fiadd i_zoff
           ftst
           fnstsw ax ;hope that is safe here
           sahf
           jae @zclipped
           fild i_255
           fdivrp st(1), st(0)
           fld st(0)
           fmul dword ptr[esi+20]
           fistp dword ptr [esi+16+28]
           ;add dword ptr [esi+16+28], 120
           fmul dword ptr[esi+16]
           fistp dword ptr [esi+12+28]
           ;add dword ptr [esi+12+28], 160
           ;compute width/height - now, just set it
           mov eax, [esi+12]
           mov [esi+4+28], eax
           mov [esi+8+28], eax
           ;fixup position (without real w/h!!)          
           shr eax, 1
           push eax
           sub eax, 160
           sub [esi+12+28], eax
           pop eax
           sub eax, 120
           sub [esi+16+28], eax
           ;draw her
           add esi, 28
           pushad
           call putsprite
           popad
           @zclipped:
           fninit
           inc ecx
     jmp @particelsloop
     @retnow:
     popad
     fninit
ret
renderparticels endp

;included files

include matrix.inc
include texture.inc

;documentation

;particel descriptor
;0      xpos, ypos, zpos
;12     base size         
;16     xrot, yrot, zrot
;28     sprite descriptor

;sprite descriptor (width/height always 256)
;0      source pointer
;4      dest width
;8      dest height
;12     dest x
;16     dest y
;20     alpha
;24     dxs
;28     dys
;32     xs
;36     ys
;40     xs0
;44     ys0
;48


@bigflag:
bigflag                 dd 0

@nullstring:
nullstring db 1," "

;text
str1:
db 10,"the future"
str2:
db 6,"is now"

script:

;cases: byte, relative offset, texture index
flag_rel  equ 01000000000000000b
flag_byte equ 00100000000000000b
flag_tex  equ 0

db 100
   dw (offset textline - offset baseoffset) + flag_rel
   dw (offset str1 - offset baseoffset)
db 134
   dw (offset textline - offset baseoffset) + flag_rel
   dw (offset str2 - offset baseoffset)
db 0
   dw (offset textline - offset baseoffset) + flag_rel
   dw (offset @nullstring - offset baseoffset)
db 0
   dw (offset backfx1 - offset baseoffset) + flag_rel
   dw (offset grid_waves - offset baseoffset)
db 0
   dw (offset particelfunc1 - offset baseoffset) + flag_rel
   dw offset particel_spiral - offset baseoffset
db 230
   dw (offset texturemapptr - offset baseoffset) + flag_tex
   db 1
db 24
   dw (offset rotspeed - offset baseoffset) + flag_byte
   db 8
db 254
db 0
   dw (offset texturemapptr - offset baseoffset) + flag_tex
   db 2
db 253
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 0101b
db 254
db 125
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 010000101b
db 130
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 010000101b
db 130
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 010000101b
db 153
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 010000101b

db 0
   dw (offset rotspeed - offset baseoffset) + flag_byte
   db 4
db 0
   dw (offset texturemapptr - offset baseoffset) + flag_tex
   db 1
db 0
   dw (offset backfx1 - offset baseoffset) + flag_rel
   dw (offset grid_waves - offset baseoffset)
db 230
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 010001001b
db 254

db 0
   dw (offset texturemapptr - offset baseoffset) + flag_tex
   db 2
db 0
   dw (offset @bigflag - offset baseoffset) + flag_byte
   db 0
db 0
   dw (offset particelfunc1 - offset baseoffset) + flag_rel
   dw (offset particel_star - offset baseoffset)
db 253
   dw (offset backfx1 - offset baseoffset) + flag_rel
   dw (offset grid_traceplanes - offset baseoffset)
db 254
db 254

db 0
   dw (offset particelfunc1 - offset baseoffset) + flag_rel
   dw offset particel_osci - offset baseoffset
db 0
   dw (offset backfx1 - offset baseoffset) + flag_rel
   dw (offset grid_waves - offset baseoffset)   
db 0
   dw (offset texturemapptr - offset baseoffset) + flag_tex
   db 1

db 254
db 254
db 254

db 255
db 0

CLIPRIGHT               equ 320
CLIPTOP                 equ 240

;texture descriptors (3+n*8 bytes)
nr_textures equ 6
testtextdesc:
include textures\space.kts
include textures\gold.kts
include textures\copper.kts
include textures\blueflar.kts
include textures\star.kts
include textures\redflare.kts

CODE_32 ENDS

DATA    SEGMENT
;data
@nrbase1:
i_255                   dw 255
i_127                   dw 127
colormixers             dd offset mixadd
                        dd offset mixxor
                        dd offset mixmul
i_32                    dw 32
@zoff:
i_zoff                  dd -200
i_16                    dw 8
i_64 dw 35

precalcpos              dd 0
nextt                   dd 360
scriptptr               dd offset script

flipfunctions           dd offset fliplo
                        dd offset fliphi
                        dd offset flipgray

DATA    ENDS

ZDATA   SEGMENT

;zero data
tempmem:
costab                  dd 256 dup (?)
particelbuffer          dd 256 dup (?)
angles                  dd 3 dup (?)
matrix                  dq 3*3 dup (?)
matrixbuffer            dq 3*3*128 dup (?)
endt                    dd ?
globalt                 dd ?
tempvector              dd 3 dup (?)
vmode                   db ?
lfbaddr                 dd ?
flipfunction            dd ?

;ebp relative constants
vscreen                 equ ebp
vscreensmall            equ ebp+320*4*30
noisemap                equ vscreen+256*256*5
textures                equ noisemap+1024*1024
grid                    equ textures+nr_textures*256*256*4
shademap                equ grid+((320/8+1)*(240/8+1))*16
vscreen2                equ shademap + 010000h
softfont                equ vscreen2 + 256*256*5

texturebase             equ 1376256

ZDATA ENDS
