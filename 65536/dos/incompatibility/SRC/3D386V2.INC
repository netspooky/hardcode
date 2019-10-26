;
;  incompatibility version - d_xeltol & d_yeltol are added
;
;  ByTeaM 80386 3D Rotation Calculator
;  Coded by KiNG RoByMuS
;  Fully optimized 32 bit calculations,
;  using extra fasten method (!)...
;  Only for using as INClude file (! Routines finished by RETN !)
;  You can copy this routine to everyone, it's Public Domain...
;
;Usage:
;------
; *Call InitRotate* function to calculate SINus/COSinus values
;  - Input: DS:SI buffer of XRot/YRot/ZRot (6 byte - Pro-radian [0..1023])
; *Call Calc3D* function for each point to calculation
;  - This function calculates 2D coordinates from 3D coordinates
;  - Input: DS:SI buffer of 3D-XCoord/3D-YCoord/3D-ZCoord (1 signed word each)
;           ES:DI buffer for calculated X/Y coordinates   (Same format...)
; *Call ProRotate* function to rotate at specified CenterPoint
;  - Works only if NOT perspective
;  - Input: Same as Calc3D + AX/BX/CX = X/Y/Z coordinates of rotation...
; *D_Perspective* control byte : 0 = Normal 3D, 1 = Perspective 3D
; *D_EyeDist* (DWord) controls the EyeDistance (effects only prespective 3D)
;

;
;32 bit Sinus Table
;
D_SinTable label dword
include sintable.386

;
;Definitions
;
D_XC_ EQU word ptr DS:[SI]
D_YC_ EQU word ptr DS:[SI+2]
D_ZC_ EQU word ptr DS:[SI+4]
D_X_  EQU word ptr ES:[DI]
D_Y_  EQU word ptr ES:[DI+2]
d_z_  equ word ptr es:[di+4]

;
;Control Datas
;
D_EyeDist dd 200
D_Perspective db 0
D_Xeltol dw 0
D_Yeltol dw 0
D_PersZEltol dd 0
d_realxeltol dw 0
d_realyeltol dw 0

;
;Temporary datas for FAST calculus
;Used in main code...
;
D_XC DD ?
D_YC DD ?
D_ZC DD ?
D_X  DD ?
D_Y  DD ?
D_z  dd 0
D_xa dd 0
D_ya dd 0
D_za dd 0
;
;Temporary datas for FAST calculus
;Filled in InitRotate
;
D_sinx dd 0
D_cosx dd 0
D_siny dd 0
D_cosy dd 0
D_sinz dd 0
D_cosz dd 0
;
;Code begin...
;
.386
;
;Initialize Rotate -  see notes 
;
InitRotate:
push esi
push eax
push ebx
push edi
push ecx
push es
push cs
pop es
mov edi,offset D_sinx
mov cx,3
D_Cik1:
lodsw
push ax
and ax,1023
shl ax,2
mov bx,ax
assume es:code
mov eax,dword ptr es:D_SinTable[bx]    ;Calculate SINus
stosd
pop ax
add ax,256
and ax,1023
shl ax,2
mov bx,ax
mov eax,dword ptr es:D_SinTable[bx]    ;Calculate COSinus
;assume es:data1
stosd
loop D_Cik1
pop es
pop ecx
pop edi
pop ebx
pop eax
pop esi
retn

;
;Main Calculator -  see notes 
;
Calc3D:
push eax
push ebx
push ecx
push edx
mov ax,D_xc_
add ax,cs:d_realxeltol
cwd
mov word ptr cs:D_xc,ax
mov word ptr cs:D_xc+2,dx
mov ax,D_yc_
add ax,cs:d_realyeltol
cwd
mov word ptr cs:D_yc,ax
mov word ptr cs:D_yc+2,dx
mov ax,D_zc_
cwd
mov word ptr cs:D_zc,ax
mov word ptr cs:D_zc+2,dx
push ds
push cs
pop ds
;
;XA=XC*COS(Z)-YC*SIN(Z)
;
mov eax,cs:D_YC
imul cs:D_SinZ
mov ebx,edx
mov ecx,eax
mov eax,cs:D_XC
imul cs:D_CosZ
sub eax,ecx
sbb edx,ebx
shrd eax,edx,16
mov cs:D_XA,eax
;
;YA=XC*SIN(Z)+YC*COS(Z)
;
mov eax,cs:D_XC
imul cs:D_SinZ
mov ebx,edx
mov ecx,eax
mov eax,cs:D_YC
imul cs:D_CosZ
add eax,ecx
adc edx,ebx
shrd eax,edx,16
mov cs:D_YA,eax
;
;Y=YA*COS(X)-ZC*SIN(X)
;
mov eax,cs:D_ZC
imul cs:D_SinX
mov ebx,edx
mov ecx,eax
mov eax,cs:D_YA
imul cs:D_CosX
sub eax,ecx
sbb edx,ebx
shrd eax,edx,16
mov cs:D_Y,eax
;
;ZA=YA*SIN(X)+ZC*COS(X)
;
mov eax,cs:D_YA
imul cs:D_SinX
mov ebx,edx
mov ecx,eax
mov eax,cs:D_ZC
imul cs:D_CosX
add eax,ecx
adc edx,ebx
shrd eax,edx,16
mov cs:D_ZA,eax
;
;X=XA*COS(Y)+ZA*SIN(Y)
;
mov eax,cs:D_XA
imul cs:D_CosY
mov ebx,edx
mov ecx,eax
mov eax,cs:D_ZA
imul cs:D_SinY
add eax,ecx
adc edx,ebx
shrd eax,edx,16
mov cs:D_X,eax
;
;Check for perspective calculus
;
;Z=ZA*COS(Y)-XA*SIN(Y)
;
mov eax,cs:D_XA
imul cs:D_SinY
mov ebx,edx
mov ecx,eax
mov eax,cs:D_ZA
imul cs:D_CosY
sub eax,ecx
sbb edx,ebx
shrd eax,edx,16
;
;ECX = Z
;
mov ecx,eax         
mov cs:D_z_,cx
mov ebx,cs:D_EyeDist
add ecx,cs:d_PersZEltol

cmp cs:D_perspective,0
je D_NotPers
;
;X=(X*EYEDIST)/(EYEDIST-Z)
;
mov eax,cs:D_X
imul ebx
push ebx
sub ebx,ecx
idiv ebx
pop ebx
mov cs:D_X,eax
;
;Y=(Y*EYEDIST)/(EYEDIST-Z)
;
mov eax,cs:D_Y
imul ebx
sub ebx,ecx
idiv ebx
mov cs:D_Y,eax
;
;It's all dudes
;
D_NotPers:
pop ds
mov eax,cs:D_X
add ax,cs:D_xeltol
mov cs:D_X_,ax
mov eax,cs:D_Y
add ax,cs:D_yeltol
mov cs:D_Y_,ax
pop edx
pop ecx
pop ebx
pop eax
retn


