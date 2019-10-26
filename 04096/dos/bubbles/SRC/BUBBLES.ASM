maxspheres=42
max2spheres=128*2
;frame_o_meter = 1

.386p
jumps

;ษออออออออออออออออออออออออออออออออป
;บ bubbles / byteam / pieslice'96 บ
;ศออออออออออออออออออออออออออออออออผ

b equ byte ptr
w equ word ptr
d equ dword ptr
o equ offset

_align macro n
db (n-((($-start)+100h) mod n)) dup (?)
endm

code segment use16
assume cs:code,ds:code
org 100h
start:

nop

;--------------------------------------; rpmi

.386p
push sp
pop ax
cmp ax,sp
je noexitpm
exitpm:
retn                                   ; nincs 386. kar..     
;                 
noexitpm:
pushf
pushf
pop ax
or ah,30h
push ax
popf
pushf
pop ax
popf
test ah,30h
jz exitpm
mov eax,cr0
test al,1            
jnz exitpm           
;
xor al,1
push 0
push cs
pop ebx
shl ebx,4
db 66h
add bx,offset nolimitgdt-8    
dw 0                          
mov gdtbase32,ebx             
lgdt gdtaddress               
mov bx,8                      
push ds es
cli
mov cr0,eax                   
jmp initpmode_1
initpmode_1:                  
mov ds,bx
mov es,bx
mov fs,bx
mov gs,bx                     
;
and al,not 1
mov cr0,eax                   
jmp initpmode_2
initpmode_2:                  
sti
pop es ds                     
.386

;--------------------------------------; "rendering" text.. :)
mov ah,9
mov dx,o pleasewait
int 21h

;--------------------------------------; sinus (de)generator
mov di,offset sintable+256*2+512*2
mov si,di
mov ecx,192h*0ffh
singencycle:
mov ebp,10000h     
mov eax,ecx
call imulshrd
push eax
mov ebx,2a8240b7h
imul ebx
sub ebp,edx
pop eax
call imulshrd
mov ebx,01f2ba9dh
imul ebx
xchg eax,edx
add eax,ebp
imul ecx
call onlyshrd
shr eax,1
sub si,2
mov ds:[si-512*2],ax
mov ds:[di-512*2],ax
neg ax
mov ds:[si],ax
stosw
sub ecx,192h       
jns singencycle

;--------------------------------------; get bios 8x16 font
mov ax,1130h
mov bh,6
int 10h
push ds es
pop ds es
mov si,bp
mov di,o font
mov cx,128
cik1_getfont:
push cx
mov cl,16
cik2_getfont:
push cx
lodsb
mov bl,al
mov cl,8
cik3_getfont:
xor al,al
rcl bl,1
jnc t1_getfont
mov al,15
t1_getfont:
stosb
loop cik3_getfont
pop cx
loop cik2_getfont
pop cx
loop cik1_getfont
push cs
pop ds

;--------------------------------------; depacking textures
mov si,o textures
mov di,o depackedtextures
mov cl,4
mov bx,0101h
cik0_depack:
push cx
mov cl,128
cik1_depack:
lodsb
aam
org $-1
db 16
add ax,bx
stosw
loop cik1_depack
pop cx
add bx,1010h
loop cik0_depack

;--------------------------------------; generate the palette table
mov si,o palette
mov di,o paltable
mov cx,64
cik1_gpt:
push cx
mov cl,64
cik2_gpt:
push si cx
cmp cl,32
ja t1_gpt
mov bl,32
sub bl,cl
xor bh,bh
mov ax,256
movzx dx,b ds:[si]
sub ax,dx
mul bx
shr ax,5
add al,ds:[si]
mov red,ax
mov ax,256
movzx dx,b ds:[si][1]
sub ax,dx
mul bx
shr ax,5
add al,ds:[si][1]
mov green,ax
mov ax,256
movzx dx,b ds:[si][2]
sub ax,dx
mul bx
shr ax,5
add al,ds:[si][2]
mov blue,ax
;
jmp short t2_gpt
t1_gpt:
mov bl,64
sub bl,cl
mov al,ds:[si]
mul bl
shr ax,5
mov red,ax
mov al,ds:[si][1]
mul bl
shr ax,5
mov green,ax
mov al,ds:[si][2]
mul bl
shr ax,5
mov blue,ax
t2_gpt:
;
mov si,o reducedpalette
mov bp,-1
mov cl,192
push di
cik3_gpt:
mov al,ds:[si]
xor ah,ah
sub ax,red
imul ax
mov di,ax
mov bx,dx
mov al,ds:[si][1]
xor ah,ah
sub ax,green
imul ax
add di,ax
adc bx,dx
mov al,ds:[si][2]
xor ah,ah
sub ax,blue
imul ax
add di,ax
adc bx,dx
or bx,bx
jnz t3_gpt
cmp di,bp
jae t3_gpt
mov bp,di
pop di
push di
xor al,al
sub al,cl
mov ds:[di],al
t3_gpt:
add si,3
loop cik3_gpt
pop di
inc di
pop cx si
loop cik2_gpt
add di,192
add si,3
pop cx
loop cik1_gpt

;--------------------------------------; rendering spheres
push es 7000h
pop es
xor ax,ax
mov di,ax
mov cx,32768
rep stosw
;
push 8000h
pop es
xor di,di
mov which,o depackedtextures+256*0
call renderasphere
mov di,128
mov which,o depackedtextures+256*1
call renderasphere
mov di,128*256
mov which,o depackedtextures+256*2
call renderasphere
mov di,128+128*256
mov which,o depackedtextures+256*3
call renderasphere
pop es

;--------------------------------------; generate larusse table

push es 0
pop es
mov edi,180000h                        ; az a biztos :)
mov cx,200-32
cik1_glt:
push cx
mov ax,100-16
sub ax,cx
mov si,ax
imul ax
mov bx,ax
mov cx,320
cik2_glt:
push cx bx
mov ax,160
sub ax,cx
mov bp,ax
imul ax
add ax,bx
movzx eax,ax
call sqrt
add bx,441-190
mov ax,si
imul temp512
idiv bx
cwde
shl eax,9
push eax
mov ax,bp
imul temp512
idiv bx
cwde
pop ebx
add eax,ebx
mov es:[edi],eax
add edi,4
pop bx cx
loop cik2_glt
pop cx
loop cik1_glt
pop es

;--------------------------------------; rendering map for part 2

push 0
pop fs
mov edi,110000h
mov eax,40404040h
xor cx,cx
cik1_erasemap:
mov fs:[edi],eax
add edi,4
loop cik1_erasemap
mov edi,1f0000h
xor eax,eax
mov ecx,65536*2
cik1_erasezbuf:
mov fs:[edi],eax
add edi,4
dec ecx
jnz cik1_erasezbuf
;

xor bp,bp
xor dx,dx
xor di,di
mov cx,1000
cik1_lotofspheres:
push bp cx dx di
call random
call random
and ax,63;
add ax,15
mov s_size,ax
call random
and ax,511
mov s_xcoord,ax
call random
and ax,511
mov s_ycoord,ax
call random
shr ax,1
xchg ax,si
add bp,di
mov s_texture,bp
call putsphere
pop di dx cx bp
xor bp,128
xor dx,128*256
xor di,dx
loop cik1_lotofspheres

mov xsize,320
mov ysize,200-32
mov rendereltolas,0

;--------------------------------------; code

mov ax,3508h
int 21h
mov old08seg,es
mov old08ofs,bx
mov ax,3509h
int 21h
mov old09seg,es
mov old09ofs,bx
push ds 
pop es
mov ax,2508h
mov dx,o timer
int 21h
mov ax,2509h
mov dx,o keyboard
int 21h
mov cx,4295h
call pit                               ; 100hz
;

mov dx,3c8h
xor al,al
out dx,al
mov di,o vgapalette
mov cx,768
inc dx
in al,dx
in al,dx
in al,dx
cikkk:
in al,dx
shl al,2
stosb
loop cikkk

mov cx,64
ciki:
push cx
mov bl,cl
call vsync
mov cx,768
mov si,o vgapalette
mov dx,3c8h
xor al,al
out dx,al
inc dx
cikik:
lodsb
mul bl
mov al,ah
out dx,al
loop cikik
pop cx
loop ciki

mov ax,13h
int 10h

;--------------------------------------; setting up global palette

mov dx,3c8h
mov al,64
out dx,al
inc dx
mov cx,576
mov si,o reducedpalette
cik1_setpal:
lodsb
shr al,2
out dx,al
loop cik1_setpal

;--------------------------------------; main code!!

mov si,o byteamtext
mov bp,-320
call writer

mov si,o bubblestext
mov bp,320*184+320-9*8
call writer

mov cx,80
mov di,15*320
mov si,(200-15)*320-2
cik1_dezign:
push cx es 0a000h
pop es
mov ax,0f0fh
stosw
stosw
mov es:[si],ax
mov es:[si-2],ax
sub si,4
push si di
call vsync
pop di si es cx 
loop cik1_dezign

;--------------------------------------; part 1

mov di,o spheres
mov cl,maxspheres
mov ax,-1
mov bx,-6500
xor dx,dx
xor si,si
xor bp,bp
cik0_initspheres:
xchg ax,bx
stosw
xchg ax,bx
stosw
stosw
xchg ax,dx
add ax,si
stosw
sub ax,si
xchg ax,dx
sub bx,(6000)/maxspheres
xor dx,128
xor bp,128*256
xor si,bp
loop cik0_initspheres

mov ax,timercounter
mov oldtimercounter,ax
mov tempfade,ax

cik0_part1:
call erase
;
mov cx,maxspheres
mov si,o spheres
cik1_part1:
push si cx
lodsw
cmp ax,256
jl suxx1_part1
xchg bp,ax
lodsw
cwd
shld dx,ax,9
shl ax,9
idiv bp
add ax,160
mov s_xcoord,ax
lodsw
cwd
shld dx,ax,9
shl ax,9
idiv bp
add ax,100-16
mov s_ycoord,ax
lodsw
mov s_texture,ax
mov ax,512*127
xor dx,dx
div bp
mov s_size,ax
;
mov si,65000
sub si,bp
call putsphere
;
suxx1_part1:
pop cx si
add si,8
loop cik1_part1
;
call vsync
call fade
call kirak

mov bp,timercounter
sub bp,oldtimercounter
shl bp,4+1
mov si,o spheres
mov cx,maxspheres
cikk:
lodsw
sub ax,bp
cmp ax,256
jg t1
cmp ax,-512
jg t1
add ax,6571
push ax
call sub1_updatespheres
inc si 
inc si
call sub1_updatespheres
dec si 
dec si
pop ax
t1:
mov ds:[si-2],ax
add si,6
loop cikk

mov ax,timercounter
mov oldtimercounter,ax

cmp timercounter,700
jb cik0_part1

;--------------------------------------; part 2

mov ax,timercounter
mov tempfade,ax

cik0_part2:
;
mov bx,timercounter
shl bx,2
push bx
and bx,2046
mov ax,sintable[bx]
cwd
idiv constans
add ax,256
movzx ebp,ax
add ebp,110000h
pop bx
add bx,bx
and bx,2046
mov ax,sintable[bx]
cwd
idiv constans
add ax,256
movzx eax,ax
shl eax,9
add ebp,eax
;
mov cx,320*(200-32)
mov esi,180000h
push ds es 0 4000h
pop es ds
xor di,di
cik1_part2:
mov eax,ds:[esi]
add eax,ebp
add esi,4
mov al,ds:[eax]
stosb
loop cik1_part2
pop es ds
;
call vsync
call fade
call kirak
;
cmp timercounter,1700
jb cik0_part2

;--------------------------------------; part 3

push cs
pop es

mov ax,timercounter
mov tempfade,ax

cik0_part3:
;
mov di,o spheres2
mov cx,max2spheres/4
push cx
mov si,-3000
cik1_init2spheres:
push cx
mov bx,si
add bx,bx
mov ax,timercounter
shl ax,3+1
add bx,ax
push bx
add bx,512
and bx,2046
mov ax,ds:sintable[bx]
sar ax,9
add ax,64+32
stosw
pop bx
and bx,2046
mov ax,ds:sintable[bx]
sar ax,9
add ax,64+32
stosw
mov ax,si
stosw
xor ax,ax
stosw
pop cx 
add si,6000*4/max2spheres
loop cik1_init2spheres
;
mov si,o spheres2
mov di,o spheres2+max2spheres/4*8
pop cx
cik2_init2spheres:
lodsw
neg ax
stosw
movsw
movsw
lodsw
xor ax,128
stosw
loop cik2_init2spheres
;
mov si,o spheres2
mov di,o spheres2+max2spheres/2*8
mov cx,max2spheres/2
cik3_init2spheres:
movsw
lodsw
neg ax
stosw
movsw
lodsw
xor ax,128*256
stosw
loop cik3_init2spheres
;

mov bx,timercounter
push bx
shl bx,2
and bx,2046
mov bp,sintable[bx]
sar bp,9
add bp,192
pop bx 
mov rot[4],bx
shl bx,2
push bx
and bx,2046
mov ax,sintable[bx]
imul bp
shrd ax,dx,9+8
mov rot[2],ax
pop bx
add bx,bx
and bx,2046
mov ax,sintable[bx]
imul bp
shrd ax,dx,9+8
mov rot[0],ax
;
mov si,o rot
call initrotate
mov si,o spheres2
mov di,o spheres3
mov cx,max2spheres
call calcik

;
call erase
;
mov cx,max2spheres
mov si,o spheres3
cik1_kirakspheres:
push cx si
mov bp,ds:[si+4]
cmp bp,50
jl t1_kirakspheres
lodsw
imul const2
idiv bp
add ax,160
mov s_xcoord,ax
lodsw
imul const2
idiv bp
add ax,100-16
mov s_ycoord,ax
lodsw
mov ax,60*300
xor dx,dx
div bp
mov s_size,ax
lodsw
mov s_texture,ax
neg bp
add bp,32000
mov si,bp
call putsphere
t1_kirakspheres:
pop si cx
add si,8
loop cik1_kirakspheres
;
call vsync
call fade
call kirak
;
cmp timercounter,2600
jb cik0_part3

;--------------------------------------; part 4 :)
mov selfmodify,48h

mov ax,timercounter
mov tempfade,ax

cik0_suxx:
call vsync
call fade
call kirak
cmp timercounter,2750
jb cik0_suxx

mov cx,6
mov si,o greetstable
cik1_part4:
push cx si
lodsw
xchg ax,bp
lodsw
xchg ax,si
call writer
pop si cx
add si,4
loop cik1_part4

waiiiit:
cmp timercounter,3450
jb waiiiit

mov ax,timercounter
mov tempfade,ax

cik0_fadedown:
call vsync
call fadedown
cmp timercounter,3525
jb cik0_fadedown


;--------------------------------------; main code ends here..
vege_keyboard:
xor cx,cx
call pit
mov ax,2508h
lds dx,d cs:old08ofs
int 21h
mov ax,2509h
lds dx,d cs:old09ofs
int 21h
push cs
pop ds
mov ax,3
int 10h
mov ah,9
mov dx,o endtext
int 21h
int 20h

imulshrd:
imul eax
onlyshrd:
shrd eax,edx,16
retn

sub1_updatespheres:
call random
sar ax,7
cmp ax,50
jg t1_sub1_updatespheres
cmp ax,-50
jnl sub1_updatespheres
t1_sub1_updatespheres:
mov ds:[si],ax
retn

temp512 dw 251                         ;)
constans dw 207
const2 dw 300

;--------------------------------------; shit random
random:
push ecx ebx
mov eax,rnd1
mov ebx,rnd2
mov ecx,rnd3
xor eax,ebx
add ebx,ecx
xor ecx,1d3e56f2h
add ebx,98679fadh
ror eax,17
mov rnd1,ecx
mov rnd2,eax
mov rnd3,ebx
pop ebx ecx
retn

rnd1 dd 12498feah
rnd2 dd 02feabb2h
rnd3 dd 9c2c74f2h

;--------------------------------------; shit fade
fade:
mov si,o reducedpalette
mov bx,timercounter
sub bx,tempfade
add bx,bx
cmp bx,255	
jbe t1_fade
mov bx,255
t1_fade:
neg bx
add bx,255
mov cx,192*3
mov dx,3c8h
mov al,64
out dx,al
inc dx
cik1_fade:
lodsb
shr al,2
mov bh,al
neg al
add al,64
mul bl
mov al,ah
add al,bh
out dx,al
loop cik1_fade
retn

fadedown:
mov bx,timercounter
sub bx,tempfade
shl bx,2
cmp bx,255
jbe t1_fade_
mov bx,255
t1_fade_:
neg bx
add bx,255
mov cx,256
mov dx,3c8h
xor al,al
out dx,al
inc dx
cik1_fade_:
mov al,bl
shr al,2
out dx,al
out dx,al
out dx,al
loop cik1_fade_
retn


;--------------------------------------; putsphere

kilog_ps:
pop ax ax
retn

clip_ps:
cmp bx,cx
jge kilog_ps
cmp bx,si
jle kilog_ps
add cx,si  
cmp bx,cx
jle t01_ps
mov dx,cx
sub dx,si
sub dx,bx
mov ds:[di][0],dx 
t01_ps:
cmp bx,0
jge t02_ps
mov dx,bx
sub dx,si                              
mov ds:[di][0],dx
push ax
mov ax,bx
cwd
shld dx,ax,15
shl ax,15
idiv si       
mov ds:[di][2],ax
pop ax
xor bx,bx
t02_ps:
retn

xsize dd 512
ysize dd 512

putsphere:
push si
mov ax,256*128
xor dx,dx
mov si,1234h
org $-2
s_size dw ?
div si
xchg ax,bp
;
mov cx1_ps,si
mov cx2_ps,si
xor ax,ax
mov dx1_ps,ax
mov dx2_ps,ax
;
neg si
mov dx,si
sar dx,1
mov ax,1234h
org $-2
s_ycoord dw ?
add ax,dx
mov bx,1234h
org $-2
s_xcoord dw ?
add bx,dx
;
mov cx,w xsize
mov di,o cx2_ps
call clip_ps
xchg ax,bx
mov cx,w ysize
mov di,o cx1_ps
call clip_ps
xchg ax,bx

cwde
movzx ebx,bx
mul d xsize
add eax,ebx
xchg eax,edi

add edi,12345678h
org $-4
rendereltolas dd 0d0000h

pop si

push ds es 7000h 8000h 4000h 5000h
pop gs es ds fs
;
xor ebx,ebx
mov cx,cs:cx1_ps
mov dx,cs:dx1_ps        
cik1_ps:
push dx edi cx
mov bh,dh
;
mov cx,cs:cx2_ps
mov dx,cs:dx2_ps        
cik2_ps:
mov bl,dh
mov ax,fs:[ebx*2]
or ax,ax
jz t3_ps
add ax,si
t3_ps:
cmp ax,gs:[edi*2]
jbe t0_ps
mov gs:[edi*2],ax
mov al,ds:[bx][1234h]
org $-2
s_texture dw 0
mov es:[edi],al
t0_ps:
inc edi
add dx,bp
dec cx
jnz cik2_ps
;
pop cx edi dx
add edi,cs:xsize
add dx,bp
loop cik1_ps
pop es ds
;
retn

;--------------------------------------; renderasphere
renderasphere:
mov temp2_ras,di
push 7000h
pop fs
mov cx,128
cik1_ras:
push cx
mov ax,64
sub ax,cx
mov temp1_ras,ax
mov bx,6
imul bx
imul ax
mov bx,27                              ; aspect ratio ๗ 1.2 :)
idiv bx
xchg ax,bp
mov cx,128
cik2_ras:
push cx
mov ax,64
sub ax,cx
mov si,ax
imul ax
add ax,bp
neg ax
add ax,64*64
js t1_renderasphere
imul ax
shrd ax,dx,12
push ax
;
cwde
call sqrt
push di
sub di,temp2_ras
add di,di
mov fs:[di],ax
pop di
mov bx,16
add bx,ax
mov ax,temp1_ras
shl ax,7-2
cwd
idiv bx
push ax
mov ax,si
shl ax,7-2
cwd
idiv bx
pop bx
and bl,15
and al,15
shl bl,4
or bl,al
xor bh,bh
mov dl,ds:depackedtextures[bx][1234h]
org $-2
which dw ?
;
pop ax
push dx
shr ax,6
sub ax,63
sbb dx,dx
and dx,ax
add dx,63      
mov al,dl
pop dx
mov ah,dl

;
xchg ax,bx
mov al,ds:paltable[bx]
jmp t2_renderasphere
t1_renderasphere:
push di
sub di,temp2_ras
add di,di
mov w fs:[di],0 
pop di
mov al,64
t2_renderasphere:
stosb
pop cx
loop cik2_ras
pop cx
add di,128
loop cik1_ras
retn

;--------------------------------------; erase / kirak

erase:
push es 5000h
pop es
xor di,di
xor eax,eax
mov cx,16384
push cx cx
rep stosd
push 6000h
pop es cx
rep stosd
push 4000h
pop es cx
mov eax,40404040h
rep stosd
pop es
retn

kirak:
push ds es 4000h 0a000h
pop es ds
mov cx,80*(200-32)
xor si,si
mov di,320*16
rep movsd
pop es ds
retn

;--------------------------------------; writer
writer:
push es 0a000h
pop es
mov bx,timercounter
cik1_writer:
add bx,5
lodsb
cmp al,0
jz endcik1_writer
push si
xor ah,ah
shl ax,7
add ax,o font
xchg si,ax
mov di,bp
mov cx,16
cik2_writer:
push cx
mov cl,8
cik33_writer:
lodsb
or al,al
jz t00_writer
selfmodify db 90h
mov es:[di],al
t00_writer:
inc di
loop cik33_writer
add di,320-8
pop cx
loop cik2_writer
add bp,8
pop si
cik3_writer:
cmp timercounter,bx
jb cik3_writer
jmp cik1_writer
endcik1_writer:
pop es
retn

;--------------------------------------; vsync
vsync:
ifdef frame_o_meter
mov dx,3c8h
xor al,al
out dx,al
inc dx
out dx,al
out dx,al
out dx,al
endif
mov dx,3dah
w1:
in al,dx
test al,8
jnz w1
w2:
in al,dx
test al,8
jz w2
ifdef frame_o_meter
mov dx,3c8h
xor al,al
out dx,al
inc dx
out dx,al
out dx,al
mov al,35
out dx,al
endif  
retn

;--------------------------------------; sqrt
sqrt:
or eax,eax
jz t1_sqrt
push si di
mov edx,eax
bsr ecx,edx
mov bx,1
shr cl,1
shr edx,16
shl bx,cl
mov cx,4
mov di,ax
mov si,dx
cik1_sqrt:
div bx
add bx,ax
rcr bx,1
mov ax,di
mov dx,si
loop cik1_sqrt
movzx eax,bx
pop di si
t1_sqrt:
retn

;--------------------------------------; (very) old 3d rotator..

d_x_  equ word ptr ds:[di]
d_y_  equ word ptr ds:[di+2]
d_z_  equ word ptr ds:[di+4]

calcik:
push cx
calc3d:
pusha
push di
mov di,offset d_xc
movsw
movsw
movsw
pop di
mov bx,offset d_sinx
mov ax,d_yc
imul w [bx][8]
mov bp,dx
mov cx,ax
mov ax,d_xc
imul w [bx][10]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov d_xa,ax
mov ax,d_xc
imul w [bx][8]
mov bp,dx
mov cx,ax
mov ax,d_yc
imul w [bx][10]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov d_ya,ax
mov ax,d_zc
imul w [bx]
mov bp,dx
mov cx,ax
mov ax,d_ya
imul w [bx][2]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov d_y_,ax
mov ax,d_ya
imul w [bx]
mov bp,dx
mov cx,ax
mov ax,d_zc
imul w [bx][2]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov d_za,ax
mov ax,d_xa
imul w [bx][6]
mov bp,dx
mov cx,ax
mov ax,d_za
imul w [bx][4]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov d_x_,ax
mov ax,d_xa
imul w [bx][4]
mov bp,dx
mov cx,ax
mov ax,d_za
imul w [bx][6]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov d_z_,ax
popa
mov ax,ds:[si][6]
mov ds:[di][6],ax
add si,8
add di,8
pop cx
dec cx
jnz calcik
retn

initrotate:
pusha
mov di,offset d_sinx
mov cx,3
d_cik1:
lodsw
mov dl,2
d_cik001:
push ax
and ax,1023
shl ax,1
mov bx,ax
mov ax,word ptr sintable[bx]    
stosw
pop ax
add ax,256
dec dl
jnz d_cik001
loop d_Cik1
popa
retn

;--------------------------------------; timer & keyboard interrupt

pit:
mov al,36h
out 43h,al
mov al,cl
out 40h,al
mov al,ch
out 40h,al
retn

timercounter dw 0
oldtimercounter dw 0
writercounter dw 0

timer:
push ax
inc cs:timercounter
mov al,20h
out 20h,al
pop ax
iret

keyboard:
push ax
mov al,20h
out 20h,al
in al,60h
cmp al,1
pop ax
jz vege_keyboard
iret

;--------------------------------------; data

pleasewait db 'rendering..$'
byteamtext db 'byteam',0
bubblestext db 'bubbles',0
endtext db 'bubbles / byteam / pieslice''96',13,10,'$'

greetstable label word
dw 320*030+027,o greets0
dw 320*060+065,o greets1
dw 320*080+065,o greets2
dw 320*100+065,o greets3
dw 320*120+065,o greets5
dw 320*140+065,o greets4

greets0 db 'short greetinx() to ->',0
greets1 db '-> DARKSiDE',0
greets2 db '-> AGRESSiVE GiANTS',0
greets3 db '-> HAPPENiNG',0
greets4 db '-> ASTROiDEA',0
greets5 db '-> SiLiCON BRAiN',0

gdtaddress label qword
dw 1ch 
gdtbase32 dd ?
nolimitgdt label qword
dw 0ffffh  
dw 0       
db 0       
db 92h     
db 0ffh    
db 0       

palette label
include palette.inc

reducedpalette label
include reduced.inc
textures label
include textures.inc

_align 16
sintable dw 1024 dup (?)
paltable db 256*64 dup (?)   
font db 128*8*16 dup (?)
depackedtextures db 1024 dup (?) 
vgapalette db 768 dup (?)

d_xc dw ?
d_yc dw ?
d_zc dw ?
d_x  dw ?
d_y  dw ?
d_z  dw ?
d_xa dw ?
d_ya dw ?
d_za dw ?
d_sinx dw ?
d_cosx dw ?
d_siny dw ?
d_cosy dw ?
d_sinz dw ?
d_cosz dw ?

old08ofs dw ?
old08seg dw ?
old09ofs dw ?
old09seg dw ?

red dw ?
green dw ?
blue dw ?

temp1_ras dw ?
temp2_ras dw ?
cx1_ps dw ?
dx1_ps dw ?
cx2_ps dw ?
dx2_ps dw ?

spheres dw maxspheres*4 dup (?)

rot dw ?,?,?

tempfade dw ?

spheres2 dw 4*max2spheres dup (?)
spheres3 dw 4*max2spheres dup (?)


;--------------------------------------; the end

code ends
end start

