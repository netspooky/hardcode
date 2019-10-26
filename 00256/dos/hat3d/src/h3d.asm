org 100h
use16

 mov al,13h
 int 10h
 mov bh,0A0h
 mov es,bx
; For ZI.w=-64 To 64
  MOV	 dx,-64;word [v_ZI],-64
_For3:
  MOV	 ax,64
  CMP	 ax,dx;word [v_ZI]
  JL	_Next4
; ZS.f=zi*zi*5.0625
  MOVSX  eax,dx;word [v_ZI]
  mov [bp],eax
  fild dword [bp]
  FIMUL  dword [bp]
  FMUL	 dword [F1]
  FSTP	 dword [bp-20h];?[v_ZS]

; XL.w=Int(Sqr(20736-ZS))
 FILD	 word [D1];fsub [d1].fchs?
 FSUB	dword [bp-20h];?[v_ZS]
 FSQRT
 FISTP word [bp]
 mov ax,[bp]
 MOV	 cx,ax;word [v_XL],ax
; For XI.w=-XL To XL;0-xl
 neg ax
  MOV	 si,ax;word [v_XI],ax
_For5:
  MOVSX  eax,cx;?word [v_XL]
  CMP	 ax,si;word [v_XI]
  JL	_Next6
; XT.f=Sqr(XI*XI+ZS)*XF
  MOVSX  eax,si;word [v_XI]
  MOV	 dword [esp-4],eax
  FILD	 dword [esp-4]
;?  MOVSX  eax,word [v_XI]

;?  MOV  dword [esp-4], eax
  MOV	 dword [bp], eax
;?  FIMUL  dword [esp-4]
  FIMUL  dword [bp]

  FADD	 dword [bp-20h];?[v_ZS]
  ;-FADD         dword [F2]
  FSQRT
  FMUL	 dword [v_XF]
  FSTP	 dword [v_XT]
; YY.f=(Sin(XT)+Sin(XT*3)*0.4)*56
  FLD	 dword [v_XT]
  FSIN
  FLD	 dword [v_XT]
  FIMUL   word [F3]
  FSIN
  FMUL	 dword [F4]
  FADDP  st1,st0

  FIMUL   word [F5]

; X1.w=XI+ZI+160
;  MOVSX  ebx,si
;  MOVSX  eax,dx
;  ADD   ebx,eax
  mov bx,si
  add bx,dx
  ADD	 bx,[C160];160

  ;MOV   eax,ebx
  ;MOV   word [v_X1],bx;ax
; Y1.w=90-YY+ZI
;?  FLD  dword [v_YY]
  FCHS
  MOVSX  eax,dx;word [v_ZI]
  MOV	 dword [bp], eax
  FIADD  dword [bp]
  FIADD  word [F6]
  FISTP  word [bp];;?[v_Y1]
  
  mov di,[C160];320
  add di,di
  push di
  imul di,word [bp];;?[v_Y1]
  add di,bx;word [v_X1]
  ;?mov al,04h
  ;?stosb
;  mov byte [es:di],4
  pop bx
  mov al,4
linelp:
 mov byte [es:di],al
 xor al,al
 add di,bx
 jnc linelp;quitl
; mov byte [es:di],0
; jmp linelp
;quitl:
; Plot(X1,Y1,RGB(255,0,0))
;; LineXY(X1,Y1+1,X1,191,0)

; Next XI
_NextContinue6:
  INC	 si;word [v_XI]
  JNO	_For5
_Next6:
; Next ZI
_NextContinue4:
  INC	 dx;word [v_ZI]
  JNO	_For3
_Next4:
 int 20h
; 
F1: dd 5.0625
v_XF: dd 0.03272492438555
C160:dw 160
F3: dw 3
F4: dd 0.4
F5: dw 56
F6: dw 90
D1: dw 20736
;v_ZS: dd ?;not constant

v_XT:; dd ?;only variable
;-v_YY dd 1;once
;v_ZI dw 1
;?v_XL dw 1;once
;v_XI dw 1;once
;-v_X1 dw 1
;v_Y1 dw 1
