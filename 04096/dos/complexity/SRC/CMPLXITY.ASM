;
; C O M P L E X i T Y
; full source
; 4k-iNTRO for ASM'95 by Blala / BYTEAM
; won the 7th price
; no comments.. i don't like lots of comments!
;

.386
jumps
code segment use16
assume cs:code,ds:code
org 100h
start:

;
; ----------------- THE START ----------------------------------------
;

mov ax,13h
int 10h
mov al,0e3h
mov dx,3c2h
out dx,al
mov al,0ffh
out 21h,al

;
; ----------------- GET BiOS FONT ------------------------------------
;

getfont:
mov di,offset font
mov cx,256-32
cik1_getfont:
push cx
mov ax,256
sub ax,cx
mov ah,9
mov bx,32
mov cl,1
int 10h
xor si,si
push ds 0a000h
pop ds
mov cl,8
cik2_getfont:
movsw
movsw
movsw
movsw
add si,320-8
loop cik2_getfont
pop ds cx 
loop cik1_getfont

;
; ----------------- SiNUS GENERATOR ----------------------------------
;

singen:
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

;
; ----------------- JULiA GENERATOR ----------------------------------
;

xcorner = -108582h
ycorner = -013419h
xsize =    020252h
ysize =    018013h
xgap = xsize / 320
ygap = ysize / 200
xpar =    -0d5438h
ypar =     031de4h

push es 7000h
pop es
xor di,di
mov ebp,ycorner
mov cx,200
cik1_julia:
push cx
mov esi,xcorner
mov cx,320
cik2_julia:
push cx esi ebp
mov iter,0
cik_iter:
mov eax,esi
imul eax
shrd eax,edx,20
mov ebx,eax
xchg ecx,eax
mov eax,ebp
imul eax
shrd eax,edx,20
sub ebx,eax
add ecx,eax
mov eax,ebp
imul esi
shrd eax,edx,19
lea ebp,[eax+ypar]
lea esi,[ebx+xpar]
inc iter
mov al,iter
cmp al,255
je enditer
cmp ecx,400000h
jb cik_iter       
enditer:
shr al,3      
add al,128
stosb
pop ebp esi cx
add esi,xgap
loop cik2_julia
pop cx
add ebp,ygap
loop cik1_julia
pop es
setpal_julia:
mov dx,3c8h
mov ax,128
out dx,al
inc dx
mov cl,32
cik1_paljulia:
xchg ah,al
out dx,al
out dx,al
xchg ah,al
out dx,al
inc ax
loop cik1_paljulia

;
; ----------------- MAiN CODE ----------------------------------------
;

call erase                   
call copy                   
mov si,offset face_vextor
call realvextor
mov si,offset queen_vextor
call realvextor
mov si,offset face2_vextor
call realvextor
mov si,offset text_end
call text_writer

;
; ----------------- END CODE -----------------------------------------
;

xor ax,ax
out 21h,al
mov al,3h
int 10h

imulshrd:
imul eax
onlyshrd:
shrd eax,edx,16
retn

;
; ----------------- OTHER ROUTiNES -----------------------------------
;

erase:
push es ds 7000h 8000h
jmp yahoo

copy:
push es ds 8000h 0a000h
yahoo:
pop es ds
mov cx,16000
xor si,si
xor di,di
rep movsd
pop ds es
retn

;
; ----------------- REALVEXTOR ---------------------------------------
;

realvextor:
lodsw
push si
xchg ax,si
call text_writer
pop si
mov dx,3c8h
xor ax,ax
out dx,al
inc dx
mov cx,2
cik1_setpal:
push cx
lodsw
xchg bx,ax
lodsw
xchg bp,ax
push si
xor di,di
xor si,si
mov cl,64
cik2_setpal:
mov ax,di
out dx,al
xchg ah,al
out dx,al
mov ax,si
out dx,al
add di,bx
add si,bp
loop cik2_setpal
pop si cx
loop cik1_setpal
lodsb
mov faceflag,al
lodsw
xchg bx,ax
lodsw
push si
mov si,bx
call ax
pop si
mov di,offset xr
mov cx,5
rep movsw
mov cl,5
cik1_realvextor:
lodsb
cbw
stosw
loop cik1_realvextor
lodsw
xchg ax,cx

;
; ----------------- GLOBAL VECTORROUTiNE -----------------------------
;

vector:                     
cik_main:
push cx

;
; ----------------- rotate the points and the normals ----------------
;

calculate:
mov si,offset xr
call initrotate
mov cx,12345
org $-2
pointsnum dw 0
push cx
mov d_perspective,1
mov si,offset points
mov di,offset rotated_points
call calcik
pop cx                     
push d_xadd d_yadd
mov si,offset normals
mov di,offset rotated_normals
mov d_perspective,0
mov d_xadd,0
mov d_yadd,0
call calcik
pop d_yadd d_xadd

;
; ----------------- erase the virtual screen -------------------------
;

call erase

;
; ----------------- draw the faces to the virtual screen -------------
;

drawfaces:
mov cx,12345
org $-2
facesnum dw 0
mov si,offset faces
mov di,offset sortedfaces
push di cx di cx
mov dx,offset faces
cik1_drawfaces:
mov bx,ds:[si]
mov ax,ds:rotated_points[bx][4]
mov bx,ds:[si+2]
add ax,ds:rotated_points[bx][4]
mov bx,ds:[si+4]
add ax,ds:rotated_points[bx][4]
add ax,5000
add si,8
stosw
mov ax,dx
stosw
add dx,8
loop cik1_drawfaces
pop cx si
call binch
pop cx si       
cik2_drawfaces:
push cx si
mov si,ds:[si+2]
mov cx,3
mov di,offset pointbuf
mov bp,offset gourbuf
cik9_drawfaces:
mov bx,ds:[si]
inc si
inc si
mov eax,dword ptr ds:rotated_points[bx]
stosd     
mov ax,ds:rotated_normals[bx][4]
test ax,ax
jns t1df
neg ax
t1df:
cmp al,64
jb t2df
dec ax
t2df:
xchg di,bp
stosw
xchg di,bp
loop cik9_drawfaces
cmp faceflag,cl   
jz t4df
cmp si,offset faces+face_facesnum*8
jb t4df
add dword ptr gourbuf,00400040h
add byte ptr gourbuf[4],40h
t4df:
push es 8000h
pop es

;
; ----------------- POLYFILLER ---------------------------------------
;

gouraud:
mov si,gourbuf
mov di,gourbuf[2]
mov bp,gourbuf[4]
mov eax,dword ptr pointbuf
mov ebx,dword ptr pointbuf[4]
mov ecx,dword ptr pointbuf[8]
cmp eax,ebx
jle g_ok1
xchg eax,ebx
xchg si,di
g_ok1:
cmp eax,ecx
jle g_ok2
xchg eax,ecx
xchg si,bp
g_ok2:
cmp ebx,ecx
jle g_ok3
xchg ebx,ecx
xchg di,bp
g_ok3:
mov p1,eax
mov p2,ebx
mov p3,ecx
push di         
push eax ecx
sub ax,bx       
mov ecx,ebx
mov edx,eax
sar edx,16
sar ecx,16
sub ecx,edx
call makeadiv
mov q1_2,eax    
mov ax,di
sub ax,si
call makeacolordiv
mov cq1_2,eax
pop ecx eax
push ecx
sub ax,cx
mov edx,eax
sar edx,16
sar ecx,16
sub ecx,edx
call makeadiv
mov q1_3,eax
mov ax,bp
sub ax,si
call makeacolordiv
mov cq1_3,eax
pop ecx
mov ax,bx
sub ax,cx
sar ebx,16
sar ecx,16
sub ecx,ebx
call makeadiv
mov q2_3,eax
mov ax,bp
sub ax,di
call makeacolordiv
mov cq2_3,eax
movzx eax,si
shl eax,16
mov ebx,eax                
movsx edi,word ptr p2[2]   
call mul320
mov ecx,edi
movsx edi,word ptr p1[2]   
call mul320
mov si,word ptr p1
shl esi,16                 
mov ebp,esi                
jmp cikvege

uppertri:
cmp edi,320*200
jae nohorizline_u
call horizline
nohorizline_u:
add edi,320
sub esi,q1_2
sub ebp,q1_3
add eax,cq1_2
add ebx,cq1_3

cikvege:
cmp ecx,edi
jne uppertri
pop ax
shl eax,16                 
mov si,word ptr p2
shl esi,16                 
mov ecx,edi
movsx edi,word ptr p3[2]
call mul320
xchg ecx,edi
jmp cikvege_l

lowertri:
cmp edi,320*200
jae nohorizline_l
call horizline
nohorizline_l:
add edi,320
sub esi,q2_3
sub ebp,q1_3
add eax,cq2_3
add ebx,cq1_3

cikvege_l:
cmp edi,ecx
jne lowertri

;
; ----------------- END OF THE POLYFiLLER ----------------------------
;

pop es
pop si cx
add si,4
loop cik2_drawfaces

;
; ----------------- vsync --------------------------------------------
;

call vsync

;
; ----------------- copy ---------------------------------------------
;

call copy

;
; ----------------- additions ----------------------------------------
;

mov si,offset xrot
mov cl,5
additions_short:
lodsw
add [si+offset xr-offset xrot-2],ax
loop additions_short
pop cx
loop cik_main
retn

;
; ----------------- HORIZLINE FOR THE POLYFILLER ---------------------
;

makeacolordiv:
makeadiv:
shl eax,16
makeahorizdiv:
cdq
jcxz donotdiv
idiv ecx
donotdiv:
retn

mul320:
mov edx,edi
shl edi,2
add edi,edx
shl edi,6
retn

horizline:
push ecx esi eax ebx
mov ecx,ebp
shr ecx,16
shr esi,16
sub cx,si
jns noswap
neg cx
mov esi,ebp
shr esi,16
xchg eax,ebx       
noswap:
push di
cmp si,320
jge nomoreh
push eax
add di,si                
sub eax,ebx
mov bx,si
neg eax
call makeahorizdiv
mov si,ax
shr eax,8
pop edx
ror edx,16
mov al,dl
ror edx,16
or bx,bx
jns rightclip
pop di
push di
leftclip:
add dx,si
adc al,ah
dec cx
js nomoreh
inc bx
js leftclip
rightclip:
add bx,cx
cmp bx,320
jb horizlinecik
add cx,319
sub cx,bx
horizlinecik:
stosb
add dx,si
adc al,ah
dec cx
jns horizlinecik
nomoreh:
pop di
pop ebx eax esi ecx
retn

;
; ----------------- OBJECT GENERATORS --------------------------------
;

genface:
mov si,offset face_points
mov di,offset points
mov cx,face_pointsnum
cik1_decompress_face:
lodsb
cbw
stosw
neg ax
mov ds:[di-2][face_pointsnum*8],ax
lodsb
cbw
mov ds:[di][face_pointsnum*8],ax
stosw
lodsb
cbw
mov ds:[di][face_pointsnum*8],ax
stosw
stosw
loop cik1_decompress_face
mov si,offset face_faces
mov di,offset faces
mov cx,face_elsok
cik2_decompress_face:
mov dx,3
cik3_decompress_face:
lodsb
xor ah,ah
shl ax,3
stosw
add ax,face_pointsnum*8
mov ds:[di-2][face_facesnum*8],ax
dec dx
jnz cik3_decompress_face
mov ax,-1      
stosw
mov word ptr ds:[di-2][face_facesnum*8],-1
loop cik2_decompress_face
mov dl,3
mov cl,face_masodikak
mov bx,28
cik4_decompress_face:
call sub_decompress_face
lodsb
db 0d4h,16            
mov bp,ax
shl ax,12
sar ax,12
add bx,ax
call sub_decompress_face
mov ax,bp
shl ax,4
sar ax,12
add bx,ax
loop cik4_decompress_face
mov facesnum,face_facesnum*2
mov pointsnum,face_pointsnum*2
call calcnormals
retn

sub_decompress_face:
mov ax,bx
shl ax,3
stosw
add ax,face_pointsnum*8
mov ds:[di-2][face_facesnum*8],ax
dec dl
jnz t9_decompress_face
mov dl,3
mov ax,-1
stosw
mov word ptr ds:[di-2][face_facesnum*8],-1
t9_decompress_face:
retn

genobject:
mov pointsnum,2
xor cx,cx
mov cl,ds:[si]
push cx
push si
add si,3
sub cl,2
mov di,offset points
cik1_genobject:
push cx
lodsb
cbw
mov bx,ax
lodsb
cbw
xchg ax,bx       
mov cl,16
xor bp,bp
cik2_genobject:
push ax
imul word ptr ds:sintable[bp]
shrd ax,dx,15
stosw
pop ax
push ax bp
add bp,256*2
and bp,2047
imul word ptr ds:sintable[bp]
shrd ax,dx,15
stosw
mov ax,bx
stosw
stosw
pop bp ax
add bp,1024*2/16
inc pointsnum
loop cik2_genobject
pop cx
loop cik1_genobject
xor ax,ax
stosw
stosw
lodsb
lodsb
cbw
stosw
stosw
pop si
inc si
xor ax,ax
stosw
stosw
lodsb
lodsb
cbw
stosw
stosw
mov facesnum,16*2
pop cx
sub cl,3
mov di,offset faces
xor si,si
cik3_genobject:
push cx
mov cl,16
xor bp,bp
mov bx,8
cik4_genobject:
lea ax,[bp][si]
stosw
lea ax,[bx][si+16*8]
stosw
lea ax,[bp][si+16*8]
stosw
mov ax,-1
stosw
lea ax,[bp][si]
stosw
lea ax,[bx][si]
stosw
lea ax,[bx][si+16*8]
stosw
mov ax,-1
stosw
add bp,8
add bx,8
and bl,16*8-1
add facesnum,2
loop cik4_genobject
pop cx
add si,16*8
loop cik3_genobject
mov cl,16
mov si,pointsnum
dec si 
shl si,3
xor bx,bx
mov bp,8
push bp
cik5_genobject:
mov es:[di],bp
mov es:[di+2],bx
mov es:[di+4],si
mov word ptr es:[di+6],-1
add di,8
add bx,8
add bp,8
and bp,16*8-1
loop cik5_genobject
sub si,8
xor bx,bx
pop bp
mov cl,16
cik6_genobject:
lea ax,[bx][si][-17*8]
stosw
lea ax,[bp][si][-17*8]
stosw
mov ax,si
stosw
mov ax,-1
stosw
add bx,8
add bp,8
and bp,16*8-1
loop cik6_genobject
call calcnormals
retn

;
; ----------------- CALCULATE SURFACE NORMALS ------------------------
;

calcnormals:
mov si,offset faces
mov di,offset face_normals
mov cx,facesnum
cik1_normals:
push cx si di
mov dl,2
mov bx,[si][4]
mov bp,[si]
mov di,offset x1n
cik2_normals:
mov dh,3
cik9_normals:
mov ax,ds:points[bp]
sub ax,ds:points[bx]
cwde
stosd
inc bx
inc bx
inc bp
inc bp
dec dh
jnz cik9_normals
and bl,not 7      
mov bp,ds:[si][2]
dec dl
jnz cik2_normals   
mov si,offset x1n
mov di,offset x3n
mov bp,8
mov bx,4
mov dl,3
cik8_normals:
mov ecx,[si][bp]                  
imul ecx,[si][bx][12]
mov eax,[si][bx]
imul eax,[si][bp][12]
sub eax,ecx
stosd
xchg bp,bx
sub bp,4
dec dl
jnz cik8_normals
mov si,offset x3n
pop di
mov cl,8            
call normalize
pop si cx
add si,8
loop cik1_normals

mov di,offset normals
mov cx,pointsnum
cik3_normals:
push cx di
mov di,offset alpha
xor eax,eax
stosd
stosd
stosd
mov ax,pointsnum
sub ax,cx
shl ax,3
mov di,offset faces
mov cx,facesnum
shl cx,2
cik4_normals:
repne scasw
jnz vege_normals
push di ax
sub di,offset faces+2
and di,not 7
mov ax,ds:face_normals[di]
cwde
add alpha,eax
mov ax,ds:face_normals[di][2]
cwde
add alpha[4],eax
mov ax,ds:face_normals[di][4]
cwde
add alpha[8],eax
pop ax di
jcxz vege_normals
jmp short cik4_normals
 
vege_normals:
mov si,offset alpha
mov cl,6
pop di
call normalize
pop cx
loop cik3_normals
retn

normalize:          
push cx
xor ebx,ebx
mov cx,3
cik01_normalize:
mov eax,ds:[si]
imul eax
add ebx,eax
add si,4
loop cik01_normalize
xchg eax,ebx       
sub si,12
mov bx,1
or eax,eax
jz pointsuxxx
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
pop di si
pointsuxxx:
movsx ebx,bx
pop cx
mov eax,ds:[si]
shl eax,cl
cdq
idiv ebx
stosw
mov eax,ds:[si][4]
shl eax,cl
cdq
idiv ebx
stosw
mov eax,ds:[si][8]
shl eax,cl
cdq
idiv ebx
stosw
mov ax,-1
stosw
retn

;
; ----------------- 3D ROTATiON --------------------------------------
;

d_xc_ equ word ptr ds:[si]
d_yc_ equ word ptr ds:[si+2]
d_zc_ equ word ptr ds:[si+4]
d_X_  equ word ptr Es:[di]
d_Y_  equ word ptr Es:[di+2]
d_z_  equ word ptr es:[di+4]

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
mov ax,D_YC
imul word ptr [bx][8]
mov bp,dx
mov cx,ax
mov ax,D_XC
imul word ptr [bx][10]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov D_XA,ax
mov ax,D_XC
imul word ptr [bx][8]
mov bp,dx
mov cx,ax
mov ax,D_YC
imul word ptr [bx][10]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov D_YA,ax
mov ax,D_ZC
imul word ptr [bx]
mov bp,dx
mov cx,ax
mov ax,D_YA
imul word ptr [bx][2]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov D_Y,ax
mov ax,D_YA
imul word ptr [bx]
mov bp,dx
mov cx,ax
mov ax,D_ZC
imul word ptr [bx][2]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov D_ZA,ax
mov ax,D_XA
imul word ptr [bx][6]
mov bp,dx
mov cx,ax
mov ax,D_ZA
imul word ptr [bx][4]
add ax,cx
adc dx,bp
shrd ax,dx,15
mov D_X,ax
mov ax,D_XA
imul word ptr [bx][4]
mov bp,dx
mov cx,ax
mov ax,D_ZA
imul word ptr [bx][6]
sub ax,cx
sbb dx,bp
shrd ax,dx,15
mov cx,ax         
mov D_z_,cx
mov bx,D_EyeDist
add cx,d_PersZEltol
cmp D_perspective,0
je D_NotPers
mov ax,D_X
imul bx
push bx
sub bx,cx
idiv bx
pop bx
mov D_X,ax
mov ax,D_Y
imul bx
sub bx,cx
idiv bx
mov D_Y,ax
D_NotPers:
mov ax,D_X
add ax,D_xadd
mov D_X_,ax
mov ax,D_Y
add ax,D_yadd
mov D_Y_,ax
popa
add si,8
add di,8
pop cx
loop calcik
retn

D_EyeDist dw 500
D_Perspective db 0
D_PersZEltol dw 0

InitRotate:
pusha
mov di,offset D_sinx
mov cx,3
D_Cik1:
lodsw
mov dl,2
d_cik001:
push ax
and ax,1023
shl ax,1
mov bx,ax
mov ax,word ptr SinTable[bx]    
stosw
pop ax
add ax,256
dec dl
jnz d_cik001
loop D_Cik1
popa
retn

;
; ----------------- BiNARY EXCHANGE ----------------------------------
;

binch:
push si          
dec cx
shl cx,2
add si,cx
push si          
mov dx,8000h     
call recourse
retn

recourse:
push bp
mov bp,sp
mov si,[bp+6]    
mov di,[bp+4]    
rendez:
test ds:[si],dx
jnz csinalunkvalamit
add si,4
cmp si,di
jne rendez
add di,4
test ds:[si],dx
jz dorecourse
sub di,4
sub si,4
jmp dorecourse

csinalcsere:
mov eax,ds:[si]
xchg eax,ds:[di]
mov ds:[si],eax
add si,4
cmp si,di
jne rendez
sub si,4
jmp dorecourse

csinalunkvalamit:
test ds:[di],dx
jz csinalcsere   
sub di,4
cmp si,di
jne csinalunkvalamit
sub si,4

dorecourse:
mov ax,[bp+6]
cmp ax,si
jae norecourse1
push dx
shr dx,1
jz nomorecourse
push di
push ax
push si
call recourse
pop di
pop dx
norecourse1:
mov ax,[bp+4]
cmp di,ax
jae norecourse2
push dx
shr dx,1
jz nomorecourse
push di
push ax
call recourse
nomorecourse:
pop dx
norecourse2:
pop bp
retn 4

;
; ----------------- VSYNC --------------------------------------------
;

vsync:
mov dx,3dah
w1:
in al,dx
test al,8
jnz w1
w2:
in al,dx
test al,8
jz w2
retn

;
; ----------------- TEXT WRiTER --------------------------------------
;

text_writer:
mov dx,3c8h
mov ax,128+32
out dx,al
inc dx
mov cx,32
cik1_setpaltext:
out dx,al
out dx,al
xchg ah,al
out dx,al        
xchg ah,al
inc ax
loop cik1_setpaltext

push es 0a000h
pop es
xor ax,ax
lodsb
mov cx,320
mul cx
mov currentdi,ax
mov di,ax
cik1_text:
add currentdi,320*10
mov di,currentdi
mov al,ds:[si]
or al,al
je vege_text
cmp al,1
jne t1_text
inc si
jmp short cik1_text
t1_text:
cmp al,2
jne t4_text
inc si
t4_text:
lodsb
xor ah,ah
add di,ax
cik2_text:
mov cx,4
cik2_wait:
call vsync
loop cik2_wait
lodsb
sub al,32
jnb t3_text
dec si
jmp cik1_text     
t3_text:
xor ah,ah
shl ax,6          
add ax,offset font
push si
xchg ax,si
mov cx,8
cik3_text:
lodsd
or es:[di],eax
lodsd
or es:[di+4],eax
add di,320
loop cik3_text
pop si
sub di,320*8-8    
jmp cik2_text
vege_text:
mov cx,370
cik1_wait:
call vsync
loop cik1_wait
pop es
retn

;
; --------------------- OBJECTS AND TEXTS ----------------------------
;

include face.inc
include queen.inc

face_vextor:
dw offset text1
dw 1,0          
dw 0,1               
db 1                 
dw 0                 
dw offset genface    
dw 0,768-32,256      
dw -100,100          
db 5*2,0,0           
db 4,0               
dw 130               

face2_vextor:
dw offset text3
dw 1,1               
dw 101h,0            
db 1                 
dw 0                 
dw offset genface    
dw 0,768-32,256      
dw 420,-30           
db 7,-3,11           
db -2,1              
dw 260               

queen_vextor:
dw offset text2
dw 100h,0            
dw 0,0               
db 0                 
dw offset queen      
dw offset genobject  
dw 0,-270,75         
dw 50,-120           
db 4*2,6*2,5*2       
db 2,4               
dw 110               

text1:
db 28
db 14*8+4,'B Y T E A M',1            
db 16*8,'presents',1            
db 13*8,'a new 4K-iNTRO',1      
db 17*8,'called',1                     
db 10*8+4,'C O M P L E X i T Y',1     
db 08*8+4,'released at the ASMY''95'
db 0

text2:
db 62
db 16*8,'Creditz:',1
db 10*8,'code: Blala / BYTEAM',1
db 10*8+4,'objects: 3Dstudio:)'
db 0

text3:
db 25
db 11*8,'Everybody can make',1
db 4*8,'simple phong shaded solid bodies',1
db 10*8,'like this chesspiece',1
db 14*8+4,'in 4K too..',1,1
db 05*8,'But how about this cool *FACE*',1
db 06*8+4,'(410 points, 718 faces) ???'
db 0

text_end:
db 75
db 3*8,'That''s all what I can make in 4K..',1
db 13*8+4,'T H E   E N D'
db 0

;
; ----------------- GLOBAL DATA AREA ---------------------------------
;

temp1=(($-offset start) and 3)
db 4-temp1 dup (?)           

points dw 4*512 dup (?)
normals dw 4*512 dup (?)       
rotated_points dw 4*512 dup (?)
rotated_normals dw 4*512 dup (?)
sortedfaces dw 2*1024 dup (?)
faces dw 4*1024 dup (?)
face_normals dw 4*1024 dup (?)
sintable dw 1024 dup (?)
font db (256-32)*8*8 dup (?)

;
; ----------------- TEMPORARY DATA AREA ------------------------------
;

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

currentdi dw ?

x1n dd ?
y1n dd ?
z1n dd ?
x2n dd ?
y2n dd ?
z2n dd ?        
x3n dd ?
y3n dd ?
z3n dd ?     
alpha dd ?,?,?

q1_2 dd ?
q1_3 dd ?
q2_3 dd ?
cq1_2 dd ?
cq1_3 dd ?
cq2_3 dd ?
p1 dd ?
p2 dd ?
p3 dd ?
gourbuf dw ?,?,?,?
pointbuf dw ?,?,?,?,?,?,?,?

xr dw ?
yr dw ?
zr dw ?
d_xadd dw ?
d_yadd dw ?
xrot dw ?
yrot dw ?
zrot dw ?
xadd_ dw ?
yadd_ dw ?

faceflag db ?
iter db ?

;
; ----------------- THE END ------------------------------------------
;

code ends
end start
