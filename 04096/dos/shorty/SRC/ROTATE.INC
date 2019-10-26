Sine:
  mov dx, bx
  and dx, 1023
  mov si, dx
  shl si, 2
  mov eax, [cos_tabel.si]
  sar eax, 9
  ret


InitializeRotMatrix:

mov bx,Rot
call Sine
mov cosx,eax
mov cosy,eax
mov cosz,eax
add bx, 256
call Sine
mov sinx, eax
mov siny, eax
mov M31, eax
mov sinz, eax

mov eax,cosy
imul EAx,CosZ
SAR  EAx,15
mov M11,Eax

mov eax,cosy
imul EAx,SinZ
SAR  EAx,15
mov M21,Eax

mov eax,cosx
neg eax
imul EAx,SinZ
SAR  EAx,15
Mov  EBx,EAx
mov eax,sinx
imul EAx,SinY
SAR  EAx,15
imul EAx,CosZ
SAR EAx,15
sub ebx,eax
mov M12,Ebx

mov eax,Sinx
imul EAx,SinZ
SAR  EAx,15
mov ebx,eax
mov eax,Cosx
imul EAx,SinY
SAR  EAx,15
imul EAx,CosZ
SAR EAx,15
sub ebx,eax
mov M13,Ebx

mov eax,cosx
imul EAx,CosZ
SAR EAx,15
mov ebx,eax
mov eax,sinx
imul EAx,SinY
SAR  EAx,15
imul EAx,SinZ
SAR  EAx,15
sub ebx,eax
mov M22,Ebx

mov eax,sinx
neg eax
imul EAx,CosZ
SAR  EAx,15
mov ebx,eax
mov eax,cosx
imul EAx,SinY
SAR  EAx,15
imul EAx,SinZ
SAR  EAx,15
sub ebx,eax
mov M23,Ebx

mov eax,Cosx
imul eAx,CosY
SAR  EAx,15
mov M33,Eax

mov eax,Sinx
imul EAx,CosY
SAR  EAx,15
mov M32,Eax
ret


rotatem:				; ds:[si] pointer to points/normals
					; ds:[bp] segment pointer to rpoints/rnormals
					; cx number of points/normals
 @RotateNextPoint:
    push   cx

    mov    di, ds:[si]
    movsx  edi, di			 ; X
    mov    cx, ds:[si+2]
    movsx  ecx, cx			 ; Y
    mov    dx, ds:[si+4]
    movsx  edx, dx			 ; Z

    mov    eax, M11
    imul   eax, edi
    mov    ebx, eax

    mov    eax, M12
    imul   eax, ecx
    add    ebx, eax

    mov    eax, M13
    imul   eax, edx
    add    eax, ebx
    sar    eax, 15
    mov    ds:[bp], ax	       ; New X

    mov    eax, M21
    imul   eax, EDi
    mov    ebx, eax

    mov    eax, M22
    imul   eax, ecx
    add    ebx, eax

    mov    eax, M23
    imul   eax, edx
    add    eax, ebx
    sar    eax, 15
    mov    ds:[bp+2], ax       ; New Y

    mov    eax, M31
    imul   eax, edi
    mov    ebx, eax

    mov    eax, M32
    imul   eax, ecx
    add    ebx, eax

    mov    eax, M33
    imul   eax, edx
    add    eax, ebx
    sar    eax, 15
    mov    ds:[bp+4], ax       ; New Z

    pop    cx
    add    si, 6
    add    bp, 6
    dec    cx
    jnz    @RotateNextPoint
    ret



Add_Perspectief:		; ds:si pointer to points
				; cx number of points
@NextPoint:
    push   cx

    movsx  ebx, word ptr ds:[si+4]		; Z
    add    ebx, 07530h				; bx = z+30000
    mov    eax, ebx
    shr    eax, 1
    mov    word ptr ds:[si+4], ax

    mov    eax, 65535*20			; Rommelen
    cdq
    idiv   ebx

    movsx  ebx, word ptr ds:[si]
    imul   ebx, eax
    sar    ebx, 14				; Rommelen
    add    bx, 160
    mov    ds:[si], bx

    movsx  ebx, word ptr ds:[si+2]
    imul   ebx, eax
    sar    ebx, 14				; Rommelen
    add    bx, 100
    mov    ds:[si+2], bx

    pop    cx
    add    si, 6
    loop   @NextPoint
    ret
