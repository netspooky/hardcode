;#########################################################################
;                             HxCIntro 2001 Intro
;                          by Del Nero Jean Francois 
;                               (c)  HxC 2001
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;				  13/12/2001
;#########################################################################
;#
;# Effets Graphiques 3d, 2d
;#
;#########################################################################

;*****************************************************************************************
;* Efface Buffer
;*****************************************************************************************

clearscr proc
 pushad
	mov esi,ds:[pImageBuffer]
	mov ecx,SCREEN_WIDTH*SCREEN_HEIGHT/4
	xor eax,eax
bo1:
	mov ds:[esi],eax
	add esi,4
	dec ecx
	jnz bo1
	mov ds:[esi],eax
 popad
 ret
clearscr endp

ALIGN 4 

;*****************************************************************************************
;* Blur
;*****************************************************************************************

CalcBlur Proc
 pushad
	cmp ds:[BlurONOFF],0
	je okcalcblur
	call clearscr
 popad
 ret

okcalcblur:
	mov edi,ds:[pImageBuffer]
	mov al,ds:[BlurMode]
	cmp al,4
	jb ModeManu
	mov ax,ds:[compteurnb]
	and ax,1100000000000B
	ror ax,11
ModeManu:
	cmp al,0
	je suiteblur1
	cmp al,1
	je suiteblur2
	cmp al,2
	je suiteblur3
	cmp al,3
	je suiteblur4
	jmp suiteblur4

suiteblur1:
	call CalcBlur1
	jmp FinBlur

suiteblur2:
	call CalcBlur2
	jmp FinBlur
suiteblur3:
	call CalcBlur3
	jmp FinBlur
suiteblur4:
	call CalcBlur4
	jmp FinBlur

FinBlur:
 popad
 ret

CalcBlur endP


ALIGN 4

;*****************************************************************************************
;* Blur 'vert'
;*****************************************************************************************

CalcBlur1 PROC
 push EBP

	cmp ds:[couleurmode],0
	je somme1D
	call SwitchColorMode0
somme1D:
	mov eBP,64000
somme1:

	MOV bl,DS:[EDI-1]
	MOV al,DS:[EDI+1]
	MOV cl,DS:[EDI-SCREEN_WIDTH]
	MOV dl,DS:[EDI+SCREEN_WIDTH]

	xor ah,ah
	xor bh,bh
	xor ch,ch
	add ax,bx
	xor dh,dh
	add ax,cx
	add ax,dx
	shr ax,2
	mov Ds:[edi],al

	inc edi

	dec eBP
	jnz somme1

 pop EBP
 RET
CalcBlur1 ENDP


;*****************************************************************************************
;* Blur 'bleu'
;*****************************************************************************************

ALIGN 4
CalcBlur2 PROC
 push ebp
	cmp ds:[couleurmode],2
	je somme1D
	call SwitchColorMode2
somme1D:
	mov eBP,64000
somme2:

	MOV bl,DS:[EDI-1]
	MOV al,DS:[EDI+1]
	MOV cl,DS:[EDI]
	MOV dl,DS:[EDI-SCREEN_WIDTH]
	xor ah,ah
	xor bh,bh
	xor ch,ch
	add ax,bx
	xor dh,dh
	add ax,cx
	add ax,dx

	shr ax,2
	mov Ds:[edi],al
	inc edi
	dec eBP
	jnz somme2
 pop ebp
 RET

CalcBlur2 ENDP

;*****************************************************************************************
;* Blur 'rouge'
;*****************************************************************************************

ALIGN 4

CalcBlur3 PROC
 push ebp
	cmp ds:[couleurmode],1
	je somme1D
	call SwitchColorMode1
somme1D:
	mov eBP,64000
somme3:
	MOV dl,DS:[EDI+SCREEN_WIDTH]
	MOV bl,DS:[EDI-1]
	MOV cl,DS:[EDI]
	MOV al,DS:[EDI+1]
	xor ah,ah
	xor bh,bh
	xor ch,ch
	add ax,bx
	xor dh,dh
	add ax,cx
	add ax,dx
	shr ax,2
	mov Ds:[edi],al
	inc edi
	dec ebp
	jnz somme3
 pop ebp
 RET
CalcBlur3 ENDP

ALIGN 4

;*****************************************************************************************
;* Blur 'decrementation'
;*****************************************************************************************

CalcBlur4 PROC
 push ebp

	cmp ds:[couleurmode],1
	je somme1D
	call SwitchColorMode1

somme1D:

	push edi
	xor dx,dx
	mov ax,ds:[SpeedFactor]
	add ds:[tempblur],ax
	cmp ds:[tempblur],30
	jna jpkhlh
	mov ds:[tempblur],0
	inc dx
jpkhlh:

	cmp dl,1
	jne jp54542

	cld
	mov ecx,64000/4 ;dl=1
	mov esi,ds:[pBackUp]
	xchg esi,edi
	rep movsd 
	jmp gg

jp54542:
	;dl=0
	mov eBP,64000
	mov esi,ds:[pBackUp]
	bouclecopy1:
	mov dh,ds:[edi]
	cmp dh,255
	jne suite1
	mov dh,ds:[esi]
suite1:
	mov ds:[esi],dh
	inc edi
	inc esi
	dec ebp
	jnz bouclecopy1
gg:

pop edi

	mov eBP,64000/2
	mov esi,ds:[pBackUp]
bouclecopy1b:
	mov dx,ds:[esi]
	cmp dh,0
	je jp77
	dec dh
jp77:
	cmp dl,0
	je jp77b
	dec dl
jp77b:
	mov ds:[edi],dx
	add esi,2
	add edi,2
	dec ebp
	jnz bouclecopy1b
	
 pop ebp
 RET
CalcBlur4 ENDP


;*****************************************************************************************
;* Generation de la palette
;*****************************************************************************************

ALIGN 4

CalcPalette PROC
	 mov edi,OFFSET Win_Palette
	 mov ecx,255
	 xor dl,dl
	 mov dh,dl
	 mov bl,dl
	 mov al,0
bouclecol1:
	  mov al,bl ;bleu
	  stosb
	  mov al,dl
	  stosb
	  mov al,dh ;rouge
	  stosb
	  inc edi
	  add dh,1
	  cmp dh,255
	  jne bouclecol1
 	  mov al,255
	  stosb
	  stosb
	  stosb
	  inc edi
 ret
CalcPalette ENDP

ALIGN 4

;*****************************************************************************************
;* ' ->  vert'
;*****************************************************************************************

SwitchColorMode0 Proc
 push edi
	cmp ds:[couleurmode],0
	je finsw1f
	mov edi,OFFSET Win_Palette
	xor ecx,ecx
bouclecol1bbf:
	MOV AL,DS:[EDI]
	CMP AL,0
	JNE SUITE1bbf
	MOV AL,DS:[EDI+2]
	CMP AL,0
	JE COLSUIVBBBf
	DEC BYTE PTR DS:[EDI+2]
	INC BYTE PTR DS:[EDI+1]
	JMP COLSUIVBBf
COLSUIVBBBf:
	CMP CL,254
	JNE COLSUIVBBf
	MOV DS:[couleurmode],0
	JMP finsw1f
SUITE1bbf:
	DEC BYTE PTR DS:[EDI]
	INC BYTE PTR DS:[EDI+1]
	JMP COLSUIVBBf
COLSUIVBBf:
	ADD EDI,4
	INC CL
	cmp cl,255
	jne bouclecol1bbf
	mov al,255
	stosb
	stosb
	stosb
finsw1f:

 pop edi
ret
SwitchColorMode0 ENDP

;*****************************************************************************************
;* ' ->  rouge'
;*****************************************************************************************

ALIGN 4

SwitchColorMode1 Proc

 push edi
	cmp ds:[couleurmode],1
	je finsw1

	mov edi,OFFSET Win_Palette
	xor ecx,ecx
bouclecol1bb:
	MOV AL,DS:[EDI]
	CMP AL,0
	JNE SUITE1bb
	MOV AL,DS:[EDI+1]
	CMP AL,0
	JE COLSUIVBBB
	DEC BYTE PTR DS:[EDI+1]
	INC BYTE PTR DS:[EDI+2]
	JMP COLSUIVBB
COLSUIVBBB:
	CMP CL,254
	JNE COLSUIVBB
	MOV DS:[couleurmode],1
	JMP finsw1
SUITE1bb:
	DEC BYTE PTR DS:[EDI]
	INC BYTE PTR DS:[EDI+2]
	JMP COLSUIVBB
COLSUIVBB:
	ADD EDI,4
	INC CL
	cmp cl,255
	jne bouclecol1bb
	mov al,255
	stosb
	stosb
	stosb
finsw1:
 pop edi
 ret
SwitchColorMode1 ENDP

;*****************************************************************************************
;* ' ->  bleu'
;*****************************************************************************************

ALIGN 4

SwitchColorMode2 Proc
 push edi
	cmp ds:[couleurmode],2
	je finsw1f

	mov edi,OFFSET Win_Palette
	xor ecx,ecx
bouclecol1bbf:
	MOV AL,DS:[EDI+1]
	CMP AL,0
	JNE SUITE1bbf
	MOV AL,DS:[EDI+2]
	CMP AL,0
	JE COLSUIVBBBf
	DEC BYTE PTR DS:[EDI+2]
	INC BYTE PTR DS:[EDI]
	JMP COLSUIVBBf
COLSUIVBBBf:
	CMP CL,254
	JNE COLSUIVBBf
	MOV DS:[couleurmode],2
	JMP finsw1f
SUITE1bbf:
	DEC BYTE PTR DS:[EDI+1]
	INC BYTE PTR DS:[EDI]
	JMP COLSUIVBBf
COLSUIVBBf:
	ADD EDI,4
	INC CL
	cmp cl,255
jne bouclecol1bbf
	mov al,255
	stosb
	stosb
	stosb
finsw1f:
 pop edi
 ret
SwitchColorMode2 ENDP


;*****************************************************************************************
;* Ligne....
;*****************************************************************************************

ALIGN 4

LIGNE PROC ;Y1 X1  ;Y2 X2 
 PUSHAD               
	mov eax,DS:[Y1]
	mov ebx,DS:[Y2]
	mov ecx,DS:[X1]
	mov edx,DS:[X2]

	mov DS:[VY1],eax
	mov DS:[VY2],ebx
	mov DS:[VX1],ecx
	mov DS:[VX2],edx

	mov ebp,ds:[pVImageBuffer]

	cmp DS:[VY1],0FFFh
	ja FIN
	cmp DS:[VY2],0FFFh
	ja FIN


	xor edi,edi 
	mov eax, VSCREEN_WIDTH
	mul dword ptr ds:[VY1]
	ADD EAX, ds:[VX1]
	ADD EDI, EAX   
	MOV EBX,DS:[VY2]
	MOV EDX,DS:[VY1]
	SUB EBX,EDX
	MOV EDX,VSCREEN_WIDTH
	CMP EBX,0     ;BX=ydiff
	JNS SUITED
	NEG EBX
	MOV EDX,-VSCREEN_WIDTH  ;DX=yincr
SUITED:
	MOV ECX,1
	mov EAX,DS:[VX2]
	SUB EAX,DS:[VX1]
	JNS SUITE2
	NEG EAX
	NEG ECX
SUITE2:     ; BX=ydiff DX=yincr AX=Xdiff CX=Xincr
	XOR esi,esi       
	MOV DS:[XINCR],ECX
	MOV DS:[YINCR],EDX
	MOV EDX,EAX
	CMP EAx,EBX
	JBE XMINEUR
	MOV ECX,EAX
	INC ECX
	MOV AL,255;DS:[COULEUR]

BOUCLEMAJEUR:
	MOV DS:[eDI+ebp],AL
	ADD EDI, DS:[XINCR]
	ADD eSI,eBX
	CMP eSI,eDX
	JBE SUITE3
	SUB eSI,eDX
	ADD EDI,DS:[YINCR]
SUITE3:
	DEC ECX
	JNZ BOUCLEMAJEUR
	JMP FIN
XMINEUR:
	MOV ECX,EBX
	INC ECX
	MOV AL,DS:[COULEUR]
	
BOUCLEXMINEUR:
	MOV DS:[eDI+ebp],AL
	ADD EDI,DS:[YINCR]
	ADD ESI,EDX
	JLE SUITE4
	SUB ESI,EBX
	ADD EDI,ds:[XINCR]

SUITE4:
	DEC ECX
	JNZ BOUCLEXMINEUR
FIN:
 POPAD
 RET
LIGNE ENDP

;*****************************************************************************************
;* copie ds:[pVImageBuffer]->ds:[pImageBuffer] +clear ds:[pVImageBuffer]
;*****************************************************************************************

ALIGN 4

copyVimage PROC
 pushad
	mov edi,ds:[pVImageBuffer]
	add edi,640*100+160
	mov esi,ds:[pImageBuffer]

	xor bl,bl
	mov edx,200
	MOV ECX,320

boucle1:
	mov al,ds:[edi]
	test al,al
	je jsuife1
	mov ds:[esi],al
	mov ds:[edi],bl
jsuife1:
	inc esi
	inc edi
	dec ecx
	jnz boucle1
	add edi,320
	mov ecx,320
	dec edx
	jnz boucle1

 popad
 ret
copyVimage ENDP

;*****************************************************************************************
;* Affiche un caractere....
;*****************************************************************************************

ALIGN 4

PutChar Proc ; ax=x bx=y cl=no cara
 pushad
       push ax
	xor ch,ch
	mov ax,cx
	mov dx,16*15
	mul dx
	xor edi,edi
	mov di,ax
	add edi,offset fonts
	mov ax,SCREEN_WIDTH
	mul bx
       pop cx
	xor ebx,ebx
       push cx
	add cx,15
	cmp cx,SCREEN_WIDTH
	jnae jperer
	sub cx,SCREEN_WIDTH
	mov bx,cx
jperer:
       pop cx
	add ax,cx
	xor esi,esi
	mov si,ax
	sub si,2
	add esi,ds:[pImageBuffer];
	mov cl,16
	sub cl,bl
	mov dl,16
bouclecopycara:
	mov al,ds:[edi]
	cmp al,255
	je fdsfds
	mov al,255
	mov ds:[esi],al
fdsfds:
	inc edi
	inc esi
	dec cl
	jnz bouclecopycara
	add esi,SCREEN_WIDTH - 16
	add esi,ebx
	add edi,ebx
	mov cl,16
	sub cl,bl
	dec dl
	jnz bouclecopycara
 popad
 ret
PutChar Endp

;*****************************************************************************************
;* Gestion du scroll txt....
;*****************************************************************************************

ALIGN 4

ScrollText Proc
Pushad
	mov ax,ds:[SpeedFactor]
	mov ds:[syntxt],ax
boucleaffb:
	cmp ds:[syntxt],0
	je finScrollText

	dec ds:[syntxt]

	mov edi,ds:[pointeurchar]
	xor ax,ax
	mov al,ds:[xposichara]
	mov dh,20

boucleaffichechaine:
	mov cl,ds:[edi]
	cmp cl,'a'
	jnae suite6565
	cmp cl,'z'
	jnbe suite6565 
	sub cl,'a'
	jmp ghj12
suite6565:
	cmp cl,'A'
	jnae jpde
	cmp cl,'Z'
	jnbe jpde 
	sub cl,'A'
	jmp ghj12
jpde:
	cmp cl,'0'
	jnae jpde2
	cmp cl,'9'
	jnbe jpde2
	sub cl,'0'-26
	jmp ghj12

jpde2:
	cmp cl,20h
	jne jpfgdgf
	mov cl,26+26
	jmp ghj12
jpfgdgf:
	cmp cl,'.'
	jne ghj
	mov cl,36
	jmp ghj12
ghj:
	cmp cl,','
	jne ghj2
	mov cl,50
	jmp ghj12
ghj2:
	cmp cl,'$'
	jne ghj3
	mov cl,37
	jmp ghj12
ghj3:
	cmp cl,'+'
	jne ghj4
	mov cl,38
	jmp ghj12
ghj4:
	cmp cl,'-'
	jne ghj5
	mov cl,39
	jmp ghj12
ghj5:
	cmp cl,'('
	jne ghj6
	mov cl,40
	jmp ghj12
ghj6:
	cmp cl,')'
	jne ghj7
	mov cl,41
	jmp ghj12
ghj7:
	cmp cl,';'
	jne ghj8
	mov cl,42
	jmp ghj12
ghj8:
	cmp cl,'?'
	jne ghj9
	mov cl,43
	jmp ghj12
ghj9:
	cmp cl,'!'
	jne ghj10
	mov cl,44
	jmp ghj12
ghj10:
	cmp cl,'%'
	jne ghj11
	mov cl,45
	jmp ghj12
ghj11:
	cmp cl,'/'
	jne ghj12d
	mov cl,46
	jmp ghj12
ghj12d:
	cmp cl,'…'
	jne ghj1E2d
	mov cl,47
	jmp ghj12
ghj1E2d:
	cmp cl,'Š'
	jne ghj32d
	mov cl,49
	jmp ghj12
ghj32d:
	cmp cl,'‚'
	jne ghj33d
	mov cl,48
	jmp ghj12
ghj33d:
	cmp cl,'`'
	jne ghj34d
	mov cl,51
	jmp ghj12
ghj34d:
	mov cl,52
ghj12:
	mov bx,SCREEN_HEIGHT-16
	cmp ds:[syntxt],0
	jne suitehjh
	call PutChar
suitehjh:
	add ax,16
	inc edi
	cmp byte ptr ds:[edi],0
	je zerochar
retjfkdsf:
	dec dh
	jnz boucleaffichechaine

	dec ds:[xposichara]
	jnz oksuite454
	inc ds:[pointeurchar]
	mov esi,ds:[pointeurchar]
	mov ds:[xposichara],16
	cmp byte ptr ds:[esi],0
	jnz oksuite443
	mov ds:[pointeurchar],offset textcredit
oksuite443:
oksuite454:

	jmp boucleaffb
finScrollText:
 popad
 ret

zerochar:
	mov edi,offset textcredit
	jmp retjfkdsf

ScrollText EndP


;*****************************************************************************************
;* Recup de la valeur du cos et du sin....
;*****************************************************************************************

GetSinCos proc
; bx=angle (0..255)
; Returns: ax=Sin   bx=Cos
    push    ebx                  ; Save angle (use as pointer)
    and     ebx,0ffh            ; Range from 0..255
    shl     ebx,1                ; Grab a word so bx=bx*2
    mov     ax,[SinCos + ebx]    ; Get sine
    pop     ebx                  ; Restore pointer into bx
    push    eax                  ; Save sine on stack
    add     ebx,64               ; Add 64 to get cosine
    and     ebx,0ffh            ; Range from 0..255
    shl     ebx,1                ; *2 coz it's a word
    mov     ax,[SinCos + ebx]    ; Get cosine
    mov     ebx,eax               ; Save it   bx=Cos
    pop     eax                  ; Restore   ax=Sin
    ret
GetSinCos endp

;*****************************************************************************************
;* 'Initialistaion' variables rotation
;*****************************************************************************************

SetRotation proc
; Set sine & cosine of x,y,z
  push bx
   push ax
    mov     bx,ds:[Xangle]         ;
    call    GetSinCos           ;
    mov     ds:[XSin],ax           ;
    mov     ds:[XCos],bx           ;

    mov     bx,ds:[Yangle]
    call    GetSinCos
    mov     ds:[YSin],ax
    mov     ds:[YCos],bx

    mov     bx,ds:[Zangle]
    call    GetSinCos
    mov     ds:[ZSin],ax
    mov     ds:[ZCos],bx
  pop ax
 pop bx
 ret
SetRotation endp

;*****************************************************************************************
;* Rotate....
;*****************************************************************************************

 ALIGN 4

RotatePoint proc           ; Rotates the point around x,y,z
 pushad
; Gets original x,y,z values
; This can be done elsewhere
    mov   ax,[esi]    ; si = X        (movsx coz of byte)
    mov     [X],ax
    mov   ax,[esi+2]  ; si+2 = Y
    mov     [Y],ax
    mov   ax,[esi+4]  ; si+4 = Z
    mov     [Z],ax

; Rotate around x-axis
; YT = Y * COS(xang) - Z * SIN(xang) / 256
; ZT = Y * SIN(xang) + Z * COS(xang) / 256
; Y = YT
; Z = ZT

    movsx   eax,ds:[Y]
    movsx   ebx,ds:[XCos]
    imul    ebx               ; ax = Y * Cos(xang)
    mov     ebp,eax
    movsx   eax, ds:[Z]
    movsx   ebx,ds:[XSin]
    imul    ebx               ; ax = Z * Sin(xang)
    sub     ebp,eax            ; bp = Y * Cos(xang) - Z * Sin(xang)
    sar     ebp,8             ; bp = Y * Cos(xang) - Z * Sin(xang) / 256
    mov     [Yt],bp

    movsx   eax,ds:[Y]
    movsx   ebx,ds:[XSin]
    imul    ebx               ; ax = Y * Sin(xang)
    mov     ebp,eax
    movsx   eax,ds:[Z]
    movsx   ebx,ds:[XCos]

    imul    ebx               ; ax = Z * Cos(xang)
    add     ebp,eax            ; bp = Y * SIN(xang) + Z * COS(xang)
    sar     ebp,8             ; bp = Y * SIN(xang) + Z * COS(xang) / 256
    mov     [Zt],bp

    mov     ax,[Yt]          ; 
    mov     [Y],ax
    mov     ax,[Zt]
    mov     [Z],ax

; Rotate around y-axis
; XT = X * COS(yang) - Z * SIN(yang) / 256
; ZT = X * SIN(yang) + Z * COS(yang) / 256
; X = XT
; Z = ZT

    movsx   eax,ds:[X]
    movsx   ebx,ds:[YCos]

    imul    ebx               ; eax = X * Cos(yang)
    mov     ebp,eax
    movsx   eax,ds:[Z]
    movsx   ebx,ds:[YSin]

    imul    ebx               ; eax = Z * Sin(yang)
    sub     ebp,eax            ; ebp = X * Cos(yang) - Z * Sin(yang)
    sar     ebp,8             ; ebp = X * Cos(yang) - Z * Sin(yang) / 256
    mov     [Xt],bp

    movsx   eax,ds:[X]
    movsx   ebx,ds:[YSin]

    imul    ebx               ; eax = X * Sin(yang)
    mov     ebp,eax
    movsx     eax,ds:[Z]
    movsx     ebx,ds:[YCos]

    imul    ebx               ; eax = Z * Cos(yang)
    add     ebp,eax            ;ebp = X * SIN(yang) + Z * COS(yang)
    sar     ebp,8             ; ebp = X * SIN(yang) + Z * COS(yang) / 256
    mov     [Zt],bp

    mov     ax,[Xt]          ; Switch values
    mov     [X],ax
    mov     ax,[Zt]
    mov     [Z],ax

; Rotate around z-axis
; XT = X * COS(zang) - Y * SIN(zang) / 256
; YT = X * SIN(zang) + Y * COS(zang) / 256
; X = XT
; Y = YT

    movsx     eax,ds:[X]
    movsx     ebx,ds:[ZCos]

    imul    ebx               ; ax = X * Cos(zang)
    mov     ebp,eax
    movsx   eax,ds:[Y]
    movsx   ebx,ds:[ZSin]

    imul    ebx               ; ax = Y * Sin(zang)
    sub     ebp,eax            ; bp = X * Cos(zang) - Y * Sin(zang)
    sar     ebp,8             ; bp = X * Cos(zang) - Y * Sin(zang) / 256

    mov     ds:[Xt],bp

    movsx     eax,ds:[X]
    movsx     ebx,ds:[ZSin]

    imul    ebx               ; ax = X * Sin(zang)
    mov     ebp,eax
    movsx   eax,ds:[Y]
    movsx   ebx,ds:[ZCos]

    imul    ebx               ; ax = Y * Cos(zang)
    add     ebp,eax            ; bp = X * SIN(zang) + Y * COS(zang)
    sar     ebp,8             ; bp = X * SIN(zang) + Y * COS(zang) / 256

    mov     ds:[Y],bp

    mov     bp,ds:[Xt]
    mov     ds:[X],bp

    popad
    ret
RotatePoint endp

 ALIGN 4

;*****************************************************************************************
;* 3D -> 2D Transform....
;*****************************************************************************************

ShowPoint Proc ; 3D -> 2D
  push dx
  push bp
    mov     ax,DS:[Xoff]           ; Xoff*X / Z+Zoff = screen x
    mov     bx,DS:[X]
    add     bx,ds:[Xdepl]
    imul    bx
    mov     bx,DS:[Z]
    add     bx,ds:[Zdepl]
    add     bx,DS:[Zoff]           ; Distance

    idiv    bx
    add     ax,[Mx]             ; Centre
    mov     bp,ax               ; X
;--------------------

    mov     ax,DS:[Yoff]           ; Yoff*Y / Z+Zoff = screen y
    mov     bx,DS:[Y]
    add     bx,ds:[Ydepl]
    imul    bx

    mov     bx,DS:[Z]
    add     bx,ds:[Zdepl]
    add     bx,DS:[Zoff]           ; Distance

    idiv    bx
    add     ax,[My]             ; Centre on 
  mov bx,ax
  mov ax,bp
  pop bp
  pop dx
 ret
ShowPoint endp


;*****************************************************************************************
;* Affichage d'un polygone
;*****************************************************************************************
ALIGN 4

AffichePolygone Proc   ;eSi=pointeur sur polygone
 Pushad
 	push esi
	 xor eax,eax
	 xor ebx,ebx
	 call RotatePoint
	 call ShowPoint
	 add esi,6
	
	 mov ds:[X1],eax
	 mov ds:[Y1],ebx
	
	 call RotatePoint
	 call ShowPoint
	 mov ds:[X2],eax
	 mov ds:[Y2],ebx
	 call LIGNE

	 add esi,6
	
	 call RotatePoint
	 call ShowPoint
	 mov ds:[X1],eax
	 mov ds:[Y1],ebx
	 call LIGNE
	
	pop esi
	
	call RotatePoint
	call ShowPoint
	mov ds:[X2],eax
	mov ds:[Y2],ebx
	call LIGNE
 popad
 ret
AffichePolygone EndP   ;Si=pointeur sur polygone



;*****************************************************************************************
;* Gestion changement obj 3d ...
;*****************************************************************************************

 ALIGN 4

SwitchObj Proc ;al= 0 > hxc al=1 >cube
 pushad
	cmp bx,ds:[timingold]
	jne changeobjdir
	mov ds:[timingold],bx

	mov ax,ds:[Zposi]
	cmp ds:[Zdepl],ax
	jne changezm

	cmp ds:[Zposi],4000
	jae changeobjj
 popad
 ret

changeobjdir:
	mov ds:[timingold],bx
	mov ds:[Zposi],4000
	mov ax,5
	;imul ds:[SpeedFactor]
	mov ds:[Direction],ax;5
	;mov ds:[ObjActif],al
 popad
 ret

changeobjj:
	mov ebx,ds:[ObjActifb]
	add ds:[ObjActifb],4+4*2
	mov eax,ds:[objectliste+ebx]
	cmp eax,0
	jne jkfjlerfjlervr
	mov ds:[ObjActifb],0
	xor ebx,ebx

jkfjlerfjlervr:
	mov eax,ds:[objectliste+ebx]
	mov ds:[pointeurobjet],eax

	mov esi,offset objectliste

	mov ax,ds:[esi+ebx+4]
	mov ds:[compteurxv],ax
	mov ds:[compteurx],ax

	mov ax,ds:[esi+ebx+4+2]
	mov ds:[compteuryv],ax
	mov ds:[compteury],ax

	mov ax,ds:[esi+ebx+4+2+2]
	mov ds:[compteurzv],ax
	mov ds:[compteurz],ax

	mov ax,ds:[esi+ebx+4+2+2+2]

	mov ds:[Zposi],10

	;mov ds:[Direction],-5
	mov ax,-5
	;imul ds:[SpeedFactor]
	mov ds:[Direction],ax;5

 popad
 ret

changezm:
	mov ax,ds:[Direction]
	add ds:[Zdepl],ax
 popad
 ret
SwitchObj EndP

;*****************************************************************************************
;*****************************************************************************************

