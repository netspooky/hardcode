;land.asm       lunar lander clone 2k game compo
;               by mcarp


.model tiny
.386

e       equ     65536
esh     equ     16

video   equ     0A000h
w       equ     320*10
h       equ     7
.code

        org     100h


main    proc

        mov     ax,ds                   ;deallocate all but 128k mem
        mov     es,ax
        mov     ah,4Ah
        mov     bx,2000h
        int     21h

        push    cs
        pop     ds

        mov     ah,35h                  ;get and save old int 09h vector
        mov     al,09h
        int     21h
        mov     word ptr old_int9[0],bx
        mov     word ptr old_int9[2],es

        push    ds                      ;set new int 09h vector
        push    cs
        pop     ds
        mov     dx,offset key_int
        mov     ah,25h
        mov     al,09h
        int     21h
        pop     ds



        push    cs
        pop     es
        mov     di,offset keyis
        mov     cx,257
        rep     stosb


        mov     ah,48h                  ;allocate       starbuf
        mov     bx,1000h                ;64k
        int     21h
        mov     starbuf,ax              ;save the pointer
        mov     es,ax

        mov     cx,16384
        xor     di,di
        xor     eax,eax
        rep     stosd

        mov     cx,200                  ;init stars
m00:
        push    cx
        mov     r2,61440
        call    rnd
        mov     di,cx
        mov     r2,8
        call    rnd
        add     cx,24
        mov     byte ptr es:[di],cl
        pop     cx
        loop    m00



        mov     ah,48h                  ;allocate       vidbuf
        mov     bx,1000h                ;64k
        int     21h
        mov     vidbuf,ax               ;save the pointer

        mov     es,ax


        mov     ah,0                    ;init random seed
        int     1Ah                     ; to timer
        mov     word ptr r3[0],dx       ;
        mov     word ptr r3[2],cx       ;

        mov     ax,0013h
        int     10h


m0:
        mov     restart,0
        mov     xf,0
        mov     yf,0
        mov     landptr,0
        mov     fuel,2000
        call    init


m1:
        push    ds                      ;put stars on buffer
        mov     si,word ptr starx[2]

        mov     ax,starbuf
        mov     ds,ax
        xor     di,di
        mov     cx,16000
        mov     eax,0
        rep     movsd
        pop     ds

        call    keytest

        mov     eax,landptr
        shr     eax,1
        mov     starx,eax


        call    bullets
        call    aliens

        call    draw



        mov     edx,yf
        add     sy,edx                   ;add up trust
        cmp     sy,0
        jnl     m1a
        sub     sy,edx
        mov     yf,0
m1a:

        mov     eax,sy                   ;test for ground collide
        sar     eax,esh
        add     ax,9
        mov     bx,word ptr landptr[2]
        add     bx,word ptr sx[2]
        shl     bx,1
        add     bx,offset land
        ;add     bx,4
        mov     cx,6
m2:
        cmp     ax,[bx]
        jg      m2a                     ;a hit
        add     bx,2
        loop    m2
        jmp     m3                      ;not a hit
m2a:
        sub     sy,edx

        cmp     sx,160*e
        jl      m2b
        cmp     sx,170*e
        jg      m2b

        mov     eax,xf
        sub     landptr,eax
        jmp     m2c
m2b:
        add     sx,eax



m2c:
        cmp     xf,e                    ;test for crash
        jg      m2e                     ;
        cmp     xf,-e                   ;
        jl      m2e                     ;
        cmp     yf,e                    ;
        jg      m2e                     ;
m2d:
        mov     xf,0                    ;a safe landing
        mov     yf,0                    ;
        cmp     landed,0                ;
        jne     m4                      ;
        mov     ax,500                  ;
        sub     ax,word ptr sy[2]       ;
        add     fuel,600                ;
        mov     landed,1                ;
        jmp     m4                      ;
m2e:
        mov     landed,1                ;a crash
        mov     xf,0
        mov     yf,0
        dec     ships
        mov     fuel,2000
        cmp     ships,0
        jne     m4
        mov     done,1
        jmp     m4
m3:
        add     yf,e/64                 ;not a hit, add gravity
m4:


        call    ship


        mov     dx,3dah                 ;vert wait
VRT:
        in      al,dx
        test    al,8
        jnz     VRT

NoVRT:
        in      al,dx
        test    al,8
        jz      NoVRT



        push    ds                      ;dump vidbuf to screen
        push    es
        mov     ax,vidbuf
        mov     ds,ax
        mov     ax,video
        mov     es,ax
        xor     si,si
        xor     di,di
        mov     cx,16000
        rep     movsd
        pop     es
        pop     ds

        mov     ah,2                    ;scoreboard
        mov     bh,0
        mov     dh,24
        mov     dl,0
        int     10h
        mov     dx,offset fuelS
        mov     ah,9
        int     21h
        mov     eax,fuel
        call    var
        mov     dx,offset shipsS
        mov     ah,9
        int     21h
        mov     eax,ships
        call    var
        mov     dx,offset scoreS
        mov     ah,9
        int     21h
        mov     eax,score
        call    var


        cmp     done,1
        je      xit
        cmp     restart,1
        je      m0


        jmp     m1


xit:
        push    ds                      ;restore old int 09h vector
        mov     dx,word ptr old_int9[0]
        mov     ax,word ptr old_int9[2]
        mov     ds,ax
        mov     ah,25h
        mov     al,09h
        int     21h
        pop     ds


        mov     ax,0003h
        int     10h

        mov     ax,4C00h
        int     21h
main    endp

aliens  proc
        mov     cx,5 ;10
        mov     bx,offset alientab
aliens1:
        push    cx

        mov     ax,[bx]
        cmp     ax,0
        je      aliens10
        add     ax,[bx+4]

        cmp     ax,0
        jl      aliens2
        cmp     ax,309
        jg      aliens2

        mov     [bx],ax
;        call    alien
;alien   proc

        mov     si,offset a
;       cmp     word ptr [bx+4],0
;       jl      alien0
;       add     si, 90
alien0:
        mov     ax,[bx+2]
        shl     ax,6
        mov     di,ax
        shl     ax,2
        add     di,ax
        add     di,word ptr [bx]

        push    si
        mov     cx,5                    ;bullet collide?
        mov     si,offset bulltab
alien0a:
        cmp     word ptr [si],0
        je      alien0i
        mov     ax,[si]
        mov     dx,[bx]
        cmp     ax,dx
        jl      alien0i
        add     dx,9
        cmp     ax,dx
        jg      alien0i
        mov     ax,[si+2]
        mov     dx,[bx+2]
        cmp     ax,dx
        jl      alien0i
        add     dx,8
        cmp     ax,dx
        jg      alien0i

        mov     word ptr [bx],0
        mov     word ptr [si],0
        mov     landed,0
        add     score,100
        pop     si
        jmp alienx ;ret
alien0i:
        add     si,6
        loop    alien0a
        pop     si


alien0a10:
        mov     cx,7
alien1:
        push    cx

        mov     cx,10
alien2:
        lodsb
        cmp     al,0
        je      alien3
        ;add     al,9
        stosb
        jmp     alien4
alien3:
        inc     di
alien4:
        loop    alien2


        add     di,320-10
        pop     cx
        loop    alien1

alienx:
;        ret
;alien   endp

        jmp     aliens10
aliens2:
        mov     word ptr [bx],0

aliens10:
        add     bx,6
        pop     cx
        loop    aliens1_bridge
        jmp     aliens10a
aliens1_bridge:
        jmp     aliens1

aliens10a:
        inc     alienctr
        cmp     alienctr,150
        jne     aliens20

        mov     alienctr,0
        mov     bx,offset alientab
        add     bx,alienptr

        mov     [bx+4],ax


        mov     r2,150
        call    rnd
        mov     [bx+2],cx

        mov     r2,2
        call    rnd
        cmp     cx,1
        je      aliens11

        mov     ax,308
        mov     [bx],ax
        mov     ax,-2
        mov     [bx+4],ax
        jmp     aliens12

aliens11:
        mov     ax,1
        mov     [bx],ax
        mov     ax,2
        mov     [bx+4],ax

aliens12:
        add     alienptr,6
        cmp     alienptr,6*5
        jne     aliens20
        mov     alienptr,0
aliens20:



        ret

aliens  endp

bullets proc
        mov     cx,5
        mov     bx,offset bulltab
bullets1:

        mov     si,[bx]
        cmp     si,0
        je      bullets10
        add     si,[bx+4]

        cmp     si,0
        jl      bullets2
        cmp     si,319
        jg      bullets2

        mov     [bx],si
        mov     di,[bx+2]
        mov     color,13
        call    pset

        jmp     bullets10
bullets2:
        mov     word ptr [bx],0

bullets10:
        add     bx,6
        loop    bullets1

        ret
bullets endp

keytest proc
        mov     t,0

k1:

        cmp     ktab[1],1               ;esc, exit
        jne     k2
        mov     done,1
k2:

        cmp     ktab[33],1              ;alt, fire right
        jne     k2a
        mov     ax,5
        jmp     k2c
k2a:
        cmp     ktab[32],1              ;ctr, fire left
        jne     k2d
        mov     ax,-5

k2c:
        inc     firectr
        cmp     firectr,15
        jne     k2d

        mov     firectr,0
        mov     bx,offset bulltab
        add     bx,bullptr

        mov     [bx+4],ax

        mov     ax,word ptr sx[2]
        mov     [bx],ax

        mov     ax,word ptr sy[2]
        mov     [bx+2],ax


        add     bullptr,6
        cmp     bullptr,6*5
        jne     k2a
        mov     bullptr,0


k2d:
        cmp     ktab[28],1              ;enter, restart
        jne     k3
        mov     restart,1

k3:
        cmp     fuel,0
        jg      k3aa
        mov     fuel,0
        jmp     k6

k3aa:
        cmp     ktab[75],1              ;left
        jne     k4
        dec     fuel
        sub     xf,e/64
        cmp     xf,-e*2
        jnl     k3a
        add     xf,e/64
k3a:
        mov     t,180
k4:
        cmp     ktab[77],1              ;right
        jne     k5
        dec     fuel
        add     xf,e/64
        cmp     xf,e*2
        jng     k4a
        sub     xf,e/64
k4a:
        mov     t,90
k5:
        cmp     ktab[72],1              ;up
        jne     k6
        dec     fuel
        cmp     yf,-e
        jl      k5a
        sub     yf,e/32

k5a:
        mov     t,270
        jmp     k20
k6:

k20:

        mov     eax,landptr
        mov     edx,xf
        add     eax,edx

        cmp     sx,160*e
        jl      k20a

        cmp     eax,0
        jnl     k21
k20a:
        add     sx,edx
        cmp     sx,0
        jnl     k20b
        sub     sx,edx
        mov     xf,0
k20b:
        ret
k21:
        cmp     sx,170*e
        jg      k21a

        cmp     eax,(w-320)*e
        jng     k22
k21a:
        add     sx,edx
        cmp     sx,310*e
        jng     k21b
        sub     sx,edx
        mov     xf,0
k21b:
        ret
k22:
        mov     landptr,eax

        ret
keytest endp

comment #

line    proc    near
        push    bx
        push    cx
        push    dx
        push    si
        push    di
        push    ax
        mov     si,1
        mov     di,1
        mov     dx,y2
        sub     dx,y1
        jge     storey
        neg     di
        neg     dx
storey:
        mov     deldy,di
        mov     cx,x2
        sub     cx,x1
        jge     storex
        neg     si
        neg     cx
storex: mov     deldx,si
        cmp     cx,dx
        jge     setdiag
        mov     si,0
        xchg    cx,dx
        jmp     storedelsxy
setdiag:
        mov     di,0
storedelsxy:
        mov     dels,cx
        mov     delp,dx
        mov     delsx,si
        mov     delsy,di
        mov     si,x1
        mov     di,y1
        mov     ax,delp
        sal     ax,1
        mov     delse,ax
        sub     ax,cx
        mov     bx,ax
        sub     ax,cx
        mov     delde,ax
        inc     cx
lineloop:
        call    pset
        cmp     bx,0
        jge     diagonal
straight:
        add     si,delsx
        add     di,delsy
        add     bx,delse
        loop    lineloop
        jmp     lineexit
diagonal:
        add     si,deldx
        add     di,deldy
        add     bx,delde
        loop    lineloop
lineexit:
        pop     ax
        pop     di
        pop     si
        pop     dx
        pop     cx
        pop     bx
        ret
line    endp
#


pset    proc
        push    bx

        mov     ax,di
        shl     ax,6
        mov     bx,ax
        shl     ax,2
        add     bx,ax
        add     bx,si
        mov     al,color
        mov     es:[bx],al

        pop     bx
        ret
pset    endp


rnd     proc    near            ;call w/ r1 = lower limit  r2 = upper limit
        push    ax              ;        r3 = dword seed
        push    dx
        mov     ecx,r3          ;seed
        add     ecx,249D62E4h   ;
        ror     ecx,11 ;2          ;
        push    r3a
        pop     r3
        mov     r3a,ecx         ;new seed

        mov     ax,r2           ;upper
        sub     ax,r1           ; - lower
        mul     cx              ; * seed
        mov     cx,dx           ;whole part
        add     cx,r1           ; + lower
        pop     dx
        pop     ax
        ret                     ;return w/ cx = rnd number r1 - r2
rnd     endp

init    proc
        mov     bx,offset land  ;init land

        mov     r2,40
        call    rnd
        add     cx,160
        mov     di,cx

        mov     r2,h
        call    rnd
        sub     cx,h/2
        mov     r4,cx

        mov     cx,w
init1:
        push    cx

        mov     [bx],di

        mov     r2,100
        call    rnd
        cmp     cx,66
        jl      init1a


        mov     r2,h
        call    rnd
        sub     cx,h/2
        mov     r4,cx

init1a:

        add     di,r4
        cmp     di,30
        jl      init2
        cmp     di,191
        jg      init2
        jmp     init3
init2:
        sub     di,r4
init3:
        add     bx,2

        pop     cx
        loop    init1


        mov     bx,offset land+160*2    ;start ship position
        mov     ax,[bx]
        sub     ax,19
        shl     eax,esh
        mov     sy,eax
        mov     sx,155*e


        ret
init    endp

draw    proc

        mov     bx,offset land
        mov     ax,word ptr landptr[2]
        shl     ax,1
        add     bx,ax
        mov     color,31

        mov     si,0
        mov     cx,320
draw1:
        mov     di,[bx]

        call    rline

        add     bx,2
        inc     si
        loop    draw1

        ret
draw    endp

rline   proc
        push    bx
        push    cx

        mov     cx,192
        sub     cx,di

        mov     ax,di
        shl     ax,6
        mov     bx,ax
        shl     ax,2
        add     bx,ax
        add     bx,si
        mov     r2,8
rline1:

        mov     ax,cx
        shr     ax,4
        add     ax,18
        mov     es:[bx],al
        add     bx,320


        loop    rline1

        pop     cx
        pop     bx
        ret
rline   endp


ship    proc
        mov     si,offset s
        ;add     si,t

        mov     eax,sy
        sar     eax,esh
        shl     ax,6
        mov     di,ax
        shl     ax,2
        add     di,ax
        add     di,word ptr sx[2]

        mov     cx,9
ship1:
        push    cx

        mov     cx,6
ship2:
        lodsb
        cmp     al,0
        je      ship3
        stosb
        jmp     ship4
ship3:
        inc     di
ship4:
        loop    ship2


        add     di,320-6
        pop     cx
        loop    ship1




        ret
ship    endp

key_int proc
        sti                             ;ISR 09h keyboard
        push    ds
        push    ax
        push    bx

        push    cs
        pop     ds

        in      al,60h                  ;get keyboard byte
        xor     ah,ah                   ; only al valid
        mov     bx,ax                   ; into bx for table index to key state
        in      al,61h                  ;get control byte
        or      al,82h                  ;send the kb reset flip flop bits
        out     61h,al                  ; to kb control reg 
        and     al,7Fh                  ;perform the  
        out     61h,al                  ; reset
        mov     al,20h                  ;reset ints
        out     20h,al                  ; in interupt controler (pic)

        cmp     bx,128                  ;release or press?
        jl      k_i1                    ;skip if press
        sub     bx,128                  ;sub 128 if release
        mov     al,0                    ; and set table value to 0
        jmp     k_i2
k_i1:
        mov     al,1                    ;key is pressed, table value is 1
k_i2:
        mov     ktab[bx],al             ;update table for key

        mov     keyis,bl

        pop     bx
        pop     ax
        pop     ds
        iret
key_int endp

var     proc                            ;bin-->dec, call with eax=var
        push    eax
        push    ebx
        push    ecx
        push    edi
        push    es


        mov     ecx,0
var1:
        mov     edx,0
        mov     ebx,10
        div     ebx

        inc     ecx

        add     dl,48
        push    edx

        cmp     eax,0
        je      var2

        jmp     var1

var2:
        cmp     ecx,0
        je      var3

        pop     edx
        mov     ah,2
        int     21h
        dec     ecx
        jmp     var2

var3:
        mov     ah,2
        mov     dl,32
        int     21h


        pop     es
        pop     edi
        pop     ecx
        pop     ebx
        pop     eax
        ret
var     endp



s       db      00,00,11,11,00,00
        db      00,11,00,00,11,00
        db      11,00,00,00,00,11
        db      11,00,00,00,00,11
        db      11,00,00,00,00,11
        db      00,11,11,11,11,00
        db      00,11,00,00,11,00
        db      11,00,00,00,00,11
        db      11,00,00,00,00,11

comment #
        db      00,00,00,00,11,11,00,00,00,00   ;90
        db      00,00,00,11,00,00,11,00,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,14,11,00,00,00,00,11,00,00
        db      14,14,14,11,11,11,11,00,00,00
        db      00,14,14,11,00,00,11,00,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00


        db      00,00,00,00,11,11,00,00,00,00   ;180
        db      00,00,00,11,00,00,11,00,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,14,00
        db      00,00,00,11,11,11,11,14,14,14
        db      00,00,00,11,00,00,11,14,14,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00


        db      00,00,00,00,11,11,00,00,00,00   ;270
        db      00,00,00,11,00,00,11,00,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,11,00,00,00,00,11,00,00
        db      00,00,00,11,11,11,11,00,00,00
        db      00,00,00,11,14,14,11,00,00,00
        db      00,00,11,14,14,14,14,11,00,00
        db      00,00,11,00,14,14,00,11,00,00
#

;a      db      00,00,00,00,00,00,00,00,00,00
a       db      00,00,00,00,12,12,00,00,00,00
        db      00,00,12,12,00,00,12,12,00,00
        db      00,12,00,00,00,00,00,00,12,00
        db      12,00,12,00,12,12,00,12,00,12
        db      00,12,00,00,00,00,00,00,12,00
        db      00,00,12,12,00,00,12,12,00,00
        db      00,00,00,00,12,12,00,00,00,00
;       db      00,00,00,00,00,00,00,00,00,00
comment #
        db      12,12,12,12,00,00,00,00,00,00
        db      00,12,00,00,12,12,00,00,00,00
        db      00,00,12,00,00,00,12,12,00,00
        db      00,00,00,12,00,00,00,00,12,00
        db      00,00,00,12,00,00,00,00,00,12
        db      00,00,00,12,00,00,00,00,12,00
        db      00,00,12,00,00,00,12,12,00,00
        db      00,12,00,00,12,12,00,00,00,00
        db      12,12,12,12,00,00,00,00,00,00
#

fuelS   db      'Fuel: $'
shipsS  db      'Ships: $'
scoreS  db      'Score: $'
fuel    dd      2000
ships   dd      5
score   dd      0

done    db      0

xf      dd      0
yf      dd      0
t       dw      0

r1      dw      0                       ;lower limit
r2      dw      h                       ;upper limit
r3      dd      0                       ;seed
r3a     dd      0
r4      dw      ?

x1      dw      0                       ;line sub variables
y1      dw      0
x2      dw      639
y2      dw      479

starx   dd      0

landptr dd      0
landed  db      1

                ;      x,y,xf
bulltab dw      5 dup (0,0,5)
bullptr dw      0

alientab dw     5 dup (0,0,0)
alienptr dw     0
alienctr dw     0


keyis   db      ?
ktab    db      256 dup (?)             ;key table

old_int9 dd     ?


deldy   dw      ?
deldx   dw      ?
dels    dw      ?
delp    dw      ?
delse   dw      ?
delde   dw      ?
delsx   dw      ?
delsy   dw      ?

color   db      ?
x       dw      ?
y       dw      ?
sx      dd      ?
sy      dd      ?

vidbuf  dw      ?
starbuf dw      ?

restart db      ?

land    dw      w dup (?)

firectr db      ?
        end     main
