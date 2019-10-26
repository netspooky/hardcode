DEMO  SEGMENT 
   .386
ASSUME CS:DEMO,DS:DEMO 

ORG  100H               
MAIN:  JMP  start               

Palette LABEL BYTE
	i = 0
	REPT 63 
		DB      i, 0, i
		i = i+1
	ENDM
	i = 0
	REPT 63 
		DB      63, 0, 63-i
		i = i+1
	ENDM
	i = 0
	REPT 63 
		DB      63-(i shr 1), 0, i
		i = i+1
	ENDM
	i = 0
	REPT 63 
		DB      31-(i shr 1), 0, 63-i
		i = i+1
	ENDM



text1 db "This 4kb intro is called: SENSORY OVERL$"
text2 DB "OAD. Created by Raw-Head of SENSORY    $"
text3 DB "OVERLOAD.                              $"

Text DB "              This intro was written by the South African",0dh,0ah
     DB "                      Demo group called : SENSORY OVERLOAD",0dh,0ah
     DB "                  And competed at Optimise`95 in South Africa",0dh,0ah
     DB " ",0dh,0ah
     DB "                               Enjoy,Raw-Head$"

Endtext DB "’ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕSENSORY OVERLOAD 1995ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ∏",0dh
	DB "≥ Created by Andrew Griffiths(aka Raw-Head) of SENSORY OVERLOAD.  Hope you     ≥",0dh
	DB "≥ enjoyed it! This is my first compo proggy EVER!  But I thinx there will be   ≥",0dh
	DB "≥ more,so if you enjoyed this one, look out for more Raw-Head/SENSORY OVERLOAD ≥",0dh
	DB "≥ productions! BTW This intro loox really kewl in complete darkness! Try it!   ≥",0dh
	DB "‘ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕæ$"
 

COSDATA db 255,255,255,255,255,255,255,255,255,255,255,254,254,254,254,254,254,254,253,253,253,253,253,252,252,252,252,251,251,251
	db 251,250,250,250,249,249,249,248,248,248,247,247,247,246,246,245,245,244,244,244,243,243,242,242,241,241,240,240,239,239
	db 238,237,237,236,236,235,235,234,233,233,232,231,231,230,229,229,228,227,227,226,225,225,224,223,222,222,221,220,219,219
	db 218,217,216,215,215,214,213,212,211,210,210,209,208,207,206,205,204,204,203,202,201,200,199,198,197,196,195,194,193,192
	db 192,191,190,189,188,187,186,185,184,183,182,181,180,179,178,177,176,175,174,172,171,170,169,168,167,166,165,164,163,162
	db 161,160,159,158,157,155,154,153,152,151,150,149,148,147,146,145,143,142,141,140,139,138,137,136,135,134,132,131,130,129
	db 128,127,126,125,124,122,121,120,119,118,117,116,115,114,113,111,110,109,108,107,106,105,104,103,102,101,99,98,97,96
	db 95,94,93,92,91,90,89,88,87,86,85,84,82,81,80,79,78,77,76,75,74,73,72,71,70,69,68,67,66,65
	db 65,64,63,62,61,60,59,58,57,56,55,54,53,52,52,51,50,49,48,47,46,46,45,44,43,42,41,41,40,39
	db 38,37,37,36,35,34,34,33,32,31,31,30,29,29,28,27,27,26,25,25,24,23,23,22,21,21,20,20,19,19
	db 18,17,17,16,16,15,15,14,14,13,13,12,12,12,11,11,10,10,9,9,9,8,8,8,7,7,7,6,6,6
	db 5,5,5,5,4,4,4,4,3,3,3,3,3,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1
	db 1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,3,3,3,3,3,4,4,4,4,5,5,5
	db 5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,11,11,12,12,12,13,13,14,14,15,15,16,16,17,17
	db 18,19,19,20,20,21,21,22,23,23,24,25,25,26,27,27,28,29,29,30,31,31,32,33,34,34,35,36,37,37
	db 38,39,40,41,41,42,43,44,45,46,46,47,48,49,50,51,52,52,53,54,55,56,57,58,59,60,61,62,63,64
	db 65,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,84,85,86,87,88,89,90,91,92,93,94
	db 95,96,97,98,99,101,102,103,104,105,106,107,108,109,110,111,113,114,115,116,117,118,119,120,121,122,124,125,126,127
	db 128,129,130,131,132,134,135,136,137,138,139,140,141,142,143,145,146,147,148,149,150,151,152,153,154,155,157,158,159,160
	db 161,162,163,164,165,166,167,168,169,170,171,172,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191
	db 192,192,193,194,195,196,197,198,199,200,201,202,203,204,204,205,206,207,208,209,210,210,211,212,213,214,215,215,216,217
	db 218,219,219,220,221,222,222,223,224,225,225,226,227,227,228,229,229,230,231,231,232,233,233,234,235,235,236,236,237,237
	db 238,239,239,240,240,241,241,242,242,243,243,244,244,244,245,245,246,246,247,247,247,248,248,248,249,249,249,250,250,250
	db 251,251,251,251,252,252,252,252,253,253,253,253,253,254,254,254,254,254,254,254,255,255,255,255,255,255,255,255,255,255

m dw ?
ma dw ?
m1 dw ?
m1a dw ?
m2 dw ?
m2a dw ?
n dw ?
na dw ?
n1 dw ?
n1a dw ?
n2 dw ?
n2a dw ?
xxadd dw ?
yadd dw ?

;VARs for FLAMES
t dw ?
col1 db ?
col2 db ?
randseed dw ?

x dw ?
y dw ?
d dw ?
xo dw ?
c1 dw ?
c2 dw ?
c3 dw ?
c4 dw ?
c5 dw ?
timer dw ?
a dw ?
b dw ?
c dw ?
x1 dw ?
x2 dw ?
y1 dw ?
y2 dw ?
num dw ?
col db ?
ccol db ? 
kol dw ?
r db ?

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±One of the Palettes±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
init_pal proc near
mov col,-1
mov r,0
@pal1:
   mov    dx,3c8h
   mov    al,col
   out    dx,al
   inc    dx
   mov    al,r
   out    dx,al
   mov    al,0
   out    dx,al
   out    dx,al
   inc    col
   inc    r
cmp col,63
jne @pal1
   mov    dx,3c8h
   mov    al,7
   out    dx,al
   inc    dx
   mov    al,0
   out    dx,al
   out    dx,al
   out    dx,al
mov r,0
@pal2:
   mov    dx,3c8h
   mov    al,col
   out    dx,al
   inc    dx
   mov    al,63
   out    dx,al
   mov    al,r
   out    dx,al
   mov    al,0
   out    dx,al
   inc    col
   inc    r
cmp col,126
jne @pal2
mov r,0
@pal3:
   mov    dx,3c8h
   mov    al,col
   out    dx,al
   inc    dx
   mov    al,63
   out    dx,al
   out    dx,al
   mov    al,r
   out    dx,al
   inc    col
   inc    r
cmp col,189
jne @pal3
@pal4:
   mov    dx,3c8h
   mov    al,col
   out    dx,al
   inc    dx
   mov    al,63
   out    dx,al
   out    dx,al
   out    dx,al
   inc    col
cmp col,193 
jne @pal4
mov r,63
@pal5:
   mov    dx,3c8h
   mov    al,col
   out    dx,al
   inc    dx
   mov    al,r
   out    dx,al
   out    dx,al
   out    dx,al
   inc    col
   dec    r
cmp col,255
jne @pal5
ret
init_pal endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Beggining of Flames±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FLAMES proc near
call init_pal        ;calls the procedure to set FIREY palette
;set hotspots
xor ax,ax
xor bx,bx
xor cx,cx
xor dx,dx
mov ax,0a000h
mov es,ax
mov a,63680
@next_hot:            ;loop for placing `HOTSPOTS` for the fire
mov di,a
mov al,255
mov es:[di],al
add a,3
cmp a,64000
jnae @next_hot

;randomly smooth/blend the bottom line(199) to make it more realistic
mov randseed,4321h
@mover_x:
mov bx,0a000h
mov es,bx
mov di,63680
add di,x
mov al,es:[di]     ;getpixel at 63680(begining of line 199) + X
mov col,al
;simple random(sort of) number generator
mov     ax,[RandSeed]
mov     dx,8405h
mul     dx     ;ax*dx with result in dx:ax
inc     ax
mov     [RandSeed],ax
mov t,0
cmp dl,128
jae @decer
mov t,9
jmp @finish
@decer:mov t,-9
@finish:
mov bx,0a000h
mov es,bx
mov di,63680
add di,x
mov al,col
cbw
add ax,t
mov es:[di],al     ;putpixel at 63680(begining of line 199) + X
inc x
cmp x,320
jne @mover_x

mov a,199
@next_y:
;calc height (199-the y value of the flame-line that is currently being drawn)
mov ax,199
sub ax,a
shr ax,5
mov t,ax

mov ax,a
mov y,ax
mov x,0
@next_x:
;getpixel the colors from surrounding area to blend the flame
mov     ax,0a000h
mov     es,ax
mov     DI,X
mov     Dx,y
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
add     di,dx
mov     al,es:[di]
mov     col,al
sub di,1
mov al,es:[di]
mov col1,al
add di,2
mov al,es:[di]
mov col2,al
;get color values(col,col1,col2) and ADD and SHR 2 and subract from height
xor ax,ax
xor bx,bx
mov al,col
mov bl,al
add ax,bx
xor bx,bx
mov bl,col1
add ax,bx
xor bx,bx
mov bl,col2
add ax,bx
shr ax,2
mov bx,t
sub ax,bx
;is the color more than 250?
cmp ax,250
ja @blacker
@goback:
mov     bx,0a000h
mov     es,bx
mov     DI,X
mov     Dx,y
dec     dx
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
add     di,dx
mov     es:[di],ax

jmp @thats_it

@blacker:mov ax,0
	 jmp @goback
@thats_it:inc x
	  cmp x,320
	  jne @next_x
dec a  ;move up to next line
cmp a,80
jne @next_y

ret
FLAMES endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Beggining of scroll±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
SCROLLY PROC NEAR
MOV DH,1   
MOV DL,2
DEC DH     
DEC DL     
MOV BH,0     
MOV AH,2     
INT 10h
mov ah,9
mov dx,offset text1
int 21h
mov timer,0
@next_letter:
    mov dx,3DAh
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
mov col,1
mov x,0
@x_again:
inc x
mov y,0
@y_again:
mov     ax,0a000h
mov     es,ax
mov     Dx,y
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
inc     dx
mov     di,dx
mov     al,es:[di]
push    di
mov     Dx,y
sub     dx,150
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
add     dx,340
mov     di,dx
mov     es:[di],al

pop di
dec di
add di,x
mov al,es:[di]
dec di                 ;{change to SUB DI,2 for small letterz}
mov es:[di],al

mov     Dx,y
sub     dx,150
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
add     dx,x
mov     di,dx
mov al,es:[di]
cmp al,0
jne @shader
@rett:
dec di
mov es:[di],al
jmp @fin
@shader:inc al
	jmp @rett
@fin:
inc y
cmp y,9
jne @y_again
cmp x,320
jne @x_again
inc timer
cmp timer,310
je @newtext
cmp timer,600
je @newtext2
@goback2:
cmp timer,920
jne @next_letter
jmp @E_scroll

@newtext:
MOV DH,1   
MOV DL,2
DEC DH     
DEC DL     
MOV BH,0     
MOV AH,2     
INT 10h
mov ah,9
mov dx,offset text2
int 21h
jmp @goback2

@newtext2:
MOV DH,1   
MOV DL,2
DEC DH     
DEC DL     
MOV BH,0     
MOV AH,2     
INT 10h
mov ah,9
mov dx,offset text3
int 21h
jmp @goback2

@E_scroll:
ret
SCROLLY ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Beggining of Plasma±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
PLASMAS proc near
mov     dx,3D4h
mov     al,9
out     dx,al
inc     dx
in      al,dx
and     al,0f0h
add     al,7               ;change for quality****************************
out     dx,al
call pal1
mov timer,0
mov si,14
mov al,byte ptr cosdata[si]
mov c3,ax
mov c,0
mov d,0
@againy2:
mov ax,c
mov c2,ax
mov ax,c
mov c4,ax
mov c5,ax
mov x,0   
     call drawplasma2
     add d,10
     sub c,20
     mov ax,d
     mov xo,ax
     inc timer
     cmp timer,122         ;make longer than 122?**************************
jne @againy2
mov c,0
mov d,0
mov timer,0
@againy:
mov ax,c
mov c2,ax
mov ax,d
mov c4,ax
mov c5,ax
mov x,0    
     call drawplasma
     add d,10
     sub c,20
     mov ax,d
     mov xo,ax
     inc timer
     cmp timer,122         ;make longer than 122?**************************
jne @againy
jmp @plasma_finished

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:PAL1, pal select∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
PAL1:
	MOV     DX,3c8h                 ; Setup palette.
	MOV     AL,0
	OUT     DX,AL
	INC     DX
	MOV     CX,768
	MOV     SI,offset palette       ; Prestored...
@@pl1:
	 LODSB
	 OUT    DX,AL
	 LOOP   @@pl1        

ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:part of drawplasm2∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
DrawPlasma2:
mov y,0
xor di,di
mov bx,0a000h
mov es,bx
mov cx,720
@start_y_loop2:
mov x,0
inc y
mov ax,xo
mov c1,ax
add c2,3
sub c5,2
@start_x_loop2:
add x,2
xor  dx,dx
mov  ax,c1
div  cx
mov  c1,dx

xor  dx,dx
mov  ax,c2
div  cx
mov  c2,dx

xor  dx,dx
mov  ax,c4
div  cx
mov  c4,dx

xor  dx,dx
mov  ax,c5
div  cx
mov  c5,dx

	 mov si,c1
	 mov al,byte ptr cosdata[si]
	 mov kol,ax

	 mov si,c2
	 mov al,byte ptr cosdata[si]
	 add kol,ax

	 mov ax,c3
	 add kol,ax        

	 mov si,c4
	 mov al,byte ptr cosdata[si]
	 add kol,ax

	 mov si,c5
	 mov al,byte ptr cosdata[si]
	 sub kol,ax
	 shr kol,2
	 add c1,2    
	 add c5,720
	 mov     ax,kol
	 mov     ah,al  
	 stosw
cmp x,318
jne @start_x_loop2
add di,2
cmp y,50           ;change for quality**********************
jne @start_y_loop2
jmp @endp2
@endp2:
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:part of drawplasma∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞
DrawPlasma:
mov y,0
xor di,di
mov cx,720
@start_y_loop:
mov x,0
inc y
mov ax,xo
mov c1,ax
add c2,3
sub c5,2
@start_x_loop:
add x,2
xor  dx,dx
mov  ax,c1
div  cx
mov  c1,dx

xor  dx,dx
mov  ax,c2
div  cx
mov  c2,dx

xor  dx,dx
mov  ax,c4
div  cx
mov  c4,dx

xor  dx,dx
mov  ax,c5
div  cx
mov  c5,dx

	 mov si,c1
	 mov al,byte ptr cosdata[si]
	 mov kol,ax

	 mov si,c2
	 mov al,byte ptr cosdata[si]
	 add kol,ax

	 mov ax,c3
	 add kol,ax        

	 mov si,c4
	 mov al,byte ptr cosdata[si]
	 add kol,ax

	 mov si,c5
	 mov al,byte ptr cosdata[si]
	 sub kol,ax
	 shl kol,3
	 add c1,1    
	 add c5,720
	 mov     ax,kol
	 mov     ah,al  
	 stosw
cmp x,318
jne @start_x_loop
add di,2
cmp y,50              ;change for quality**************************
jne @start_y_loop
jmp @endp
@endp:
ret
@plasma_finished:
ret
PLASMAS endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Beggining of BOBS!!±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
Shadebobs2 proc near
mov ax,xxadd
add x,ax
mov ax,yadd
add y,ax  
mov a,0
mov b,0
mov     DI,X
add     di,a
mov     Dx,y
add     dx,b
mov     bx,dx
shl     dx,8
shl     bx,6
add     dx,bx
add     di,dx
@loo4:
inc b
mov a,0
@loo3:
mov     col,1
mov ax,0a000h
mov es,ax
mov al,es:[di]
add col,al
mov al,col
mov es:[di],al

inc a
inc di
cmp a,50
jne @loo3
add di,320
sub di,50
cmp b,50
jne @loo4

cmp x,270
jae @negx2
cmp x,1
jbe @negx2

@bakcer2:
cmp y,150
jae @negy2
cmp y,1
jbe @negy2
jmp @endit2

@negy2:neg yadd
       jmp @endit2

@negx2:neg xxadd
       jmp @bakcer2

@endit2: 
ret
shadebobs2 endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±Main body of BOBS!!±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
BOBS proc near
mov xxadd,1
mov yadd,1
mov timer,0
mov m1,150
mov n1,100
mov m2,251
mov n2,50
mov m2a,1
mov n2a,-1
mov m,1
mov n,1
mov ma,1
mov na,1
mov m1a,-1
mov n1a,1

@next_bob:
inc timer
mov ax,m
mov x,ax
mov ax,n
mov y,ax
mov ax,ma
mov xxadd,ax
mov ax,na
mov yadd,ax
call shadebobs2
mov ax,x
mov m,ax
mov ax,y
mov n,ax
mov ax,xxadd
mov ma,ax
mov ax,yadd
mov na,ax
mov ax,m1
mov x,ax
mov ax,n1
mov y,ax
mov ax,m1a
mov xxadd,ax
mov ax,n1a
mov yadd,ax
call shadebobs2
mov ax,x
mov m1,ax
mov ax,y
mov n1,ax
mov ax,xxadd
mov m1a,ax
mov ax,yadd
mov n1a,ax
mov ax,m2
mov x,ax
mov ax,n2
mov y,ax
mov ax,m2a
mov xxadd,ax
mov ax,n2a
mov yadd,ax
call shadebobs2
mov ax,x
mov m2,ax
mov ax,y
mov n2,ax
mov ax,xxadd
mov m2a,ax
mov ax,yadd
mov n2a,ax
cmp timer,1000                     
je @realend2
jmp @next_bob
@realend2:
ret
BOBS endp

;±±±±±±±±±±±±±±±±±±±±±±±Main part of flash letterz!±±±±±±±±±±±±±±±±±±±±±±±±±
LETTERZ PROC NEAR
mov    dx,3c8h
mov    al,5
out    dx,al
inc    dx
mov    al,0
out    dx,al
mov    al,0
out    dx,al
mov    al,0
out    dx,al
mov col,0
mov bx,500
mov ax, 1000
mul bx 
mov cx, dx
mov dx, ax
mov ah, 86h
int 15h
call @s_letter
call @e_letter
call @n_letter
call @s_letter
call @o_letter
call @r_letter
call @y_letter
mov bx,1000
mov ax, 1000
mul bx
mov cx, dx
mov dx, ax
mov ah, 86h
int 15h
call @o_letter
call @v_letter
call @e_letter
call @r_letter
call @l_letter
call @o_letter
call @a_letter
call @d_letter
ret
LETTERZ ENDP

TEXTINTRO PROC NEAR
mov ax,0003h
int 10h
mov ah,1
mov cx,1400h
int 10h
mov bx,500
mov ax, 1000
mul bx
mov cx, dx
mov dx, ax
mov ah, 86h
int 15h
mov    dx,3c8h
mov    al,7
out    dx,al
inc    dx
mov    al,0
out    dx,al
out    dx,al
out    dx,al
MOV DH,10   
MOV DL,5
DEC DH     
DEC DL     
MOV BH,0     
MOV AH,2     
INT 10h
mov ah,9
mov dx,offset text
int 21h

mov r,0
@fader:
mov    dx,3c8h
mov    al,7
out    dx,al
inc    dx
mov    al,r
out    dx,al
out    dx,al
out    dx,al
    mov dx,3DAh
a1:
    in al,dx
    and al,08h
    jnz a1
a2:
    in al,dx
    and al,08h
    jz  a2
inc r
mov al,60
cmp r,al
jne @fader
mov bx,5000
mov ax,1000
mul bx
mov cx, dx
mov dx, ax
mov ah, 86h
int 15h
@fader2:
mov    dx,3c8h
mov    al,7
out    dx,al
inc    dx
mov    al,r
out    dx,al
out    dx,al
out    dx,al
    mov dx,3DAh
b1:
    in al,dx
    and al,08h
    jnz b1
b2:
    in al,dx
    and al,08h
    jz  b2
dec r
mov al,0
cmp r,al
jne @fader2
ret
TEXTINTRO ENDP

;±±±±±±±±±±±±±±±±±±±±±±±±±±± Start of program ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;runtime 10/8=2min4sec. 
;size    10/8=3517bytes. 
START:
call TEXTINTRO
mov ax,0013h
int 10h
call LETTERZ
call pal1
mov x,1
mov y,1
mov xxadd,1
mov yadd,1
mov timer,0
@loopya:
call shadebobs2
inc timer
cmp timer,3000        ;could make longer!***********************************
jne @loopya
mov ax,0013h
int 10h
mov x,0
mov y,0
call flames
call scrolly
mov ax,0013h
int 10h
call PLASMAS
mov ax,0013h
int 10h
call init_pal
mov col,55
call @4k_letter
call bobs
mov ax,0013h
int 10h
call letterz
jmp @get_out_of_here

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:to draw rectangle∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


m_rec:
mov ax,y1
mov b,ax
mov ax,0a000h
mov es,ax
mov di,x1
mov ax,y1
mov bx,y1
shl bx,6
shl ax,8
add ax,bx
add di,ax
@repy:
mov ax,x1
mov a,ax
@repx:
inc a
mov al,5
stosb
mov ax,x2
cmp a,ax
jne @repx
inc b
add di,320
mov ax,x2
mov bx,x1
sub ax,bx
sub di,ax
mov ax,y2
cmp b,ax
jne @repy
ret

;mov ax,x1
;mov a,ax
;mov     ax,0a000h
;mov     es,ax
;@looper1:
;   mov ax,y1
;   mov b,ax
;   inc a
;@looper2:
;   inc b
;   mov     DI,a  
;   mov     Dx,b
;   mov     bx,dx
;   shl     dx,8
;   shl     bx,6
;   add     dx,bx
;   add     di,dx 
;   mov     al,5
;   add     al,col
;   mov     es:[di],al
;mov ax,y2
;cmp b,ax
;jnae @looper2
;mov ax,x2
;cmp a,ax 
;jnae @looper1
;ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:to draw diag.line∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


cro:
mov ax,x1
mov a,ax
@looper5:
	 inc a
	 mov c,0
	 mov ax,y1
	 mov b,ax
@looper6:mov ax,0a000h
	 mov es,ax
	 mov DI,a  
	 mov Dx,b
	 mov bx,dx
	 shl dx,8
	 shl bx,6
	 add dx,bx
	 add di,dx
	 add di,c
	 mov al,5
	 add al,col
	 mov es:[di],al
	 mov ax,num
	 add c,ax
	 inc b
	 mov ax,y2
	 cmp b,ax
	 jnae @looper6
	 mov ax,x2
	 cmp a,ax
	 jnae @looper5
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:up_down_clear∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


UP_DOWN_CL:
mov ccol,0
@loopery3:
   mov bx,1             ;delay 2ms **************************************!
   mov ax, 1000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h
   mov    dx,3c8h
   mov    al,5
   out    dx,al
   inc    dx
   mov    al,ccol
   out    dx,al
   mov    al,ccol
   out    dx,al
   mov    al,ccol
   out    dx,al
   inc    ccol
   mov    al,63
   cmp    ccol,al
   jne @loopery3
    mov dx,3DAh          ;*****************************************remove!
@1:
    in al,dx
    and al,08h
    jnz @1
@2:
    in al,dx
    and al,08h
jz  @2
@loopery4:
   mov bx,1              ;delay 2ms**************************************!
   mov ax, 1000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h
   mov    dx,3c8h
   mov    al,5
   out    dx,al
   inc    dx
   mov    al,ccol
   out    dx,al
   mov    al,ccol
   out    dx,al
   mov    al,ccol
   out    dx,al
   dec    ccol
   mov    al,0
   cmp    ccol,al
   jne @loopery4
    mov dx,3DAh
@3:
    in al,dx
    and al,08h
    jnz @3
@4:
    in al,dx
    and al,08h
jz  @4
    xor di,di
    mov ax,0a000h
    mov es,ax
    xor ax,ax
    mov cx,32000
    rep stosw
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter SSSSSSSSS∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@s_letter:
mov x1,0
mov y1,0
mov x2,319
mov y2,40
call m_rec
mov x1,0
mov y1,160
mov x2,319
mov y2,199
call m_rec
mov x1,0
mov y1,40
mov x2,50
mov y2,80
call m_rec
mov x1,270
mov y1,80
mov x2,319
mov y2,160
call m_rec
mov x1,0
mov y1,80
mov x2,319
mov y2,120
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter EEEEEEEEE∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@e_letter:
mov x1,0
mov y1,0
mov x2,50
mov y2,199
call m_rec
mov x1,50
mov y1,0
mov x2,319
mov y2,40
call m_rec
mov x1,50
mov y1,160
mov x2,319
mov y2,199
call m_rec
mov x1,50
mov y1,80
mov x2,160
mov y2,120
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter NNNNNNNNN∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@n_letter:
mov x1,0
mov y1,0
mov x2,100
mov y2,199
call m_rec
mov x1,219
mov y1,0
mov x2,319
mov y2,199
call m_rec
mov x1,0
mov y1,0
mov x2,121
mov y2,199
mov num,1
call cro
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter OOOOOOOOO∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@o_letter:
mov x1,0
mov y1,0
mov x2,319
mov y2,40 
call m_rec
mov x1,0
mov y1,0
mov x2,50
mov y2,199
call m_rec
mov x1,270
mov y1,0
mov x2,319
mov y2,199
call m_rec
mov x1,0
mov y1,160
mov x2,319
mov y2,199
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter RRRRRRRRR∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@r_letter:
mov x1,0
mov y1,0
mov x2,50
mov y2,199
call m_rec
mov x1,0
mov y1,0
mov x2,319
mov y2,40
call m_rec
mov x1,270
mov y1,0
mov x2,319
mov y2,120
call m_rec
mov x1,0
mov y1,80
mov x2,319
mov y2,120
call m_rec
mov x1,50
mov y1,120
mov x2,160
mov y2,199
mov num,2
call cro
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter YYYYYYYYY∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@y_letter:
mov x1,40
mov y1,0
mov x2,90
mov y2,80
mov num,1
call cro
mov x1,230
mov y1,0
mov x2,280
mov y2,80
mov num,-1
call cro 
mov x1,120
mov y1,60
mov x2,200
mov y2,199
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter VVVVVVVVV∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@v_letter:
mov x1,0
mov y1,80
mov x2,70
mov y2,199
mov num,1
call cro
mov x1,250
mov y1,80
mov x2,319
mov y2,199
mov num,-1
call cro 
mov x1,0
mov y1,0
mov x2,70
mov y2,80
call m_rec
mov x1,250
mov y1,0
mov x2,319
mov y2,80
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter LLLLLLLLL∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@l_letter:
mov x1,0
mov y1,0
mov x2,60
mov y2,199
call m_rec
mov x1,60
mov y1,160
mov x2,319
mov y2,199
call m_rec 
mov x1,260
mov y1,120
mov x2,319
mov y2,160
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter AAAAAAAAA∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


@a_letter:
mov x1,0
mov y1,0
mov x2,319
mov y2,40
call m_rec
mov x1,0
mov y1,0
mov x2,50
mov y2,199
call m_rec 
mov x1,270
mov y1,0
mov x2,319
mov y2,199
call m_rec
mov x1,0
mov y1,80
mov x2,319
mov y2,120
call m_rec
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter DDDDDDDDD∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@d_letter:
mov x1,0
mov y1,0
mov x2,50
mov y2,199
call m_rec
mov x1,0
mov y1,0
mov x2,200
mov y2,40
call m_rec 
mov x1,0
mov y1,160
mov x2,200
mov y2,199
call m_rec
mov x1,160
mov y1,0
mov x2,220
mov y2,100
mov num,1
call cro
mov x1,260
mov y1,100
mov x2,319
mov y2,199
mov num,-1
call cro
call UP_DOWN_CL
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞Sub-section:letter 4K4K4K4K∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞


@4k_letter:
mov x1,90
mov y1,1
mov x2,140
mov y2,199
call m_rec
mov x1,90
mov y1,1
mov x2,140
mov y2,93
mov num,-1
call cro
mov x1,-1
mov y1,92
mov x2,180
mov y2,140
call m_rec
mov x1,150
mov y1,1
mov x2,200
mov y2,199
call m_rec
mov x1,250
mov y1,1
mov x2,300
mov y2,102
mov num,-1
call cro
mov x1,150
mov y1,100
mov x2,200
mov y2,199
mov num,1
call cro
ret

;∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞EXit&End part&stuff&function∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞

@get_out_of_here:
mov ax,0003h
int 10h
mov ah,1
mov cx,1400h
int 10h
mov ah,9
mov dx,offset endtext
int 21h
mov  ax,4c00h  ; This function exits the program
int  21h       ; and returns control to DOS.
DEMO ends
end main
