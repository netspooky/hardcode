 org 100h
 use16

 mov al,13h
 int 10h

_For6:
 xor di,di
 push 09000h
 pop es

drlp:
		xor	dx, dx
		mov	ax, di
		mov	bx, 140h
		div	bx


   sub ax,100
   MOV	 word [bp],ax;;MOV	 word [v_y1],ax

 sub dx,160
 MOV	 word [bp+2],dx;;MOV	 word [v_x1],dx
 
; tt.u=x1*x1+y1*y1+1
  MOVSX  ebx,word [bp+2];;[v_x1]
  ;MOVSX  eax,word [bp+2];;[v_x1]
  ;IMUL	 ebx,eax
  IMUL	 ebx,ebx
  
  MOVSX  ecx,word [bp];;MOVSX  ecx,word [v_y1]

 ; MOVSX  eax,word [bp];;MOVSX  eax,word [v_y1]

  IMUL	 ecx,ecx;;eax
  ADD	 ebx,ecx
  INC	 ebx
  ;MOV   eax,ebx
  ;MOV    word [v_tt],bx



;  MOVSX  eax,word [bp+2];;[v_x1]
;  MOV	 dword [esp-4],eax
;  FILD	 dword [esp-4]
  
  FILD	 word [bp+2]
  
  FMUL	 dword [F1]
  MOVZX  eax,bx;word [v_tt]
  MOV	 dword [esp-4], eax
  FIDIV  dword [esp-4]
  FADD	 dword [v_d]
  ;;FADD         dword [F2]
  FSIN
  
;  MOVSX  eax,word [bp];;[v_y1]
;  MOV	 dword [esp-4],eax
;  FILD	 dword [esp-4]

  FILD	 word [bp]

  FMUL	 qword [D1]
  MOVZX  eax,bx;word [v_tt]
  MOV	 dword [esp-4], eax
  FIDIV  dword [esp-4]
  FADD	 dword [v_d]
  ;;FADD         qword [D2]
  FSIN
  FCOMPP
  FNSTSW ax
  xor bl,bl
  TEST	 ah,1h
  JE	_EndIf9
  mov bl,0Fh

_EndIf9:
; Plot(x,y,RGB (255,0,0))
  mov al,bl
  stosb
  or di,di
  jnz drlp

; d=d+0.1
  FLD	 dword [v_d]
  FADD	 dword [F3]
  FSTP	 dword [v_d]


@loc_1045C:
		mov	dx, 3DAh;wait4retrace
@loc_10136:
		in	al, dx
		and	al, 8
		jz	short @loc_10136
;@loc_1013B:
;               in      al, dx
;               and     al, 8
;               jnz     short @loc_1013B

		xor di,di
		xor si,si

 push es
 pop ds
 push 0A000h
 pop es
 mov cx,64000
 rep movsb
 
 push cs
 pop ds
 in  al,60h
 cmp al,1
 jnz _For6;@loc_1045C
 ; jmp _For6;JMP        _Repeat3
 ret
F1: dd 1132396544;;;;;;;;;;255
;;F2: dd 0
F3: dd 1036831949
D1: dd 0,1081073664;,?
;;D2: dd 0,0
v_d:;; dd 0
;v_x dw 1
;v_y dw 1
;v_x1 dw 1
;v_y1 dw 1
;v_tt dw 1
