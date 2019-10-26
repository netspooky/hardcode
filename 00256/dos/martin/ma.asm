org 100h
use16

;finit
;mov ax,1234h b8 34 12

;mov ax,v_b-v_a 4 bytes
loc_401101:

;10x to wbc for teh clue;)
; cx:dx registerpair holds value to wait for in microseconds
; 000f4240 (hex) is 1000000 = 1 second

;      mov cx,0Fh;2h
;      mov dx,4240h;07c0h
;      mov ah,86h
;      int 15h
m1:
 loop m1


mov al,12h
int 10h


;loc_401101:
;;;a.f=Abs( Random(100)-50 )
;; call random_405A30
;;; mov [bp], dx
;;; fild        word [bp]
;; fst  dword [bp]


;b.f=Abs( Random(100)-50 )
 call	random_405A30
; mov   [bp+36], dx
; fild  word [bp+36]
 fst	dword [bp+4];[cs:v_b]

;c.f=Abs( Random(100)-50 )
 call	random_405A30
; mov   [bp+36], dx
 fst	dword[bp+8];[cs:v_c]

;a.f=Abs( Random(100)-50 )
 call	random_405A30
 fst	dword [bp]

;               fld     dword[bp]            ; s.f=6.0-Abs((a+b+c)/30.0)
		fadd	dword[bp+4];[cs:v_b]
		fadd	dword[bp+8];[cs:v_c]
		fidiv	 [cs:flt_40B030]
		fabs
		fchs
		fiadd	 [cs:flt_40B034]
		fst	dword[bp+12];[cs:v_s]

;               xor eax,eax
;               mov     [cs:xold], eax  ; xold.f=0
;               mov     [cs:yold], eax  ; yold.f=0
 fldz
 fst dword [bp+28];[cs:xold]
 fst dword [bp+32];[cs:yold]
 fst dword [bp+16]

;clr.a=9
 mov si,0C09h

;; xor ax,ax
;                mov     [cs:v_t], ax;0  ; v_t
xor bx,bx
;;		mov	[cs:v_tc], ax;0 ; v_tc
 xor di,di
 
loc_4011E5:

push bx
fld	dword [bp+32];[cs:yold]
fmul	dword [bp+12];[cs:v_s]
fist word [bp+36]
mov dx,[bp+36]
add dx,240
; js no_plot

fld	dword [bp+28];[cs:xold]
fmul	dword [bp+12];[cs:v_s]
fist word [bp+36]
mov cx,[bp+36]
add cx,320

cmp dx,480
jnl no_plot

mov ax,si
xor bl,bl
int 10h
no_plot:
;0cH писать графическую точку (слишком медленно для большинства приложений!)
;    вход:  BH = номер видео страницы
;           DX,CX = строка,колонка
;           AL = значение цвета (+80H означает XOR с точкой на экране)
;  mov ax,0C0Fh;xchg AX,CX  ;CX - колонка x, AL - цвет
;  sub BH,BH   ;0 страница
;  int 10h
;
;	       mov     dx, 3DAh
;waitvr:
;	       in      al, dx
;	       test    al, 8
;	       jnz     short waitvr
;loc_448:
;	       in      al, dx
;	       and     al, 8
;	       jz      short loc_448
;------------------------------------------------------
; si.b=0
;?  xor bl,bl

; If xold>0
  FLD	 dword [bp+28];[cs:xold]
  FCOMP  dword [bp+16];dword [cs:F2]
  FNSTSW ax
  TEST	 ah,41h
  JNE	_EndIf6
; si=1
  inc bl
; ElseIf xold<0
  jne _EndIf5;JMP       _EndIf5
_EndIf6:
;  FLD   dword [cs:xold]
;  FCOMP  dword [bp+16];dword [cs:F2]
;  FNSTSW ax
  TEST	 ah,1h
  JE	_EndIf7
; si=-1
  dec bl
; EndIf
_EndIf5:
_EndIf7:
; 
; xnew.f=yold-si*Sqr( Abs(b*xold-c) ),si is sign()
  FLD	 dword [bp+32];[cs:yold]
  MOVSX  ax,bl
  
pop bx

  MOV	 word [bp+36],ax;MOV     word [esp-4],ax
  FILD	 word [bp+36];[cs:yold]
  FLD	 dword [bp+4];[cs:v_b]
  FMUL	 dword [bp+28];[cs:xold]
  FSUB	 dword [bp+8];[cs:v_c]
  FABS
  FSQRT
  FMULP  st1,st0
  FSUBP  st1,st0
  FST	 dword [bp+20];[cs:v_xnew]
;------------------------------------------------------

		fld	dword [bp]	      ; ynew.f=a-xold
		fsub	dword [bp+28];[cs:xold]
		fst	dword [bp+24];[cs:v_ynew]

;		fld	dword [bp+24];[cs:v_ynew] ; yold=ynew
		fst	dword [bp+32];[cs:yold]

		fld	dword [bp+20];[cs:v_xnew]
		fst	dword [bp+28];[cs:xold]   ;  xold=xnew

;		fld	dword [bp+24];[cs:v_ynew] ; yold=ynew
;		fst	dword [bp+32];[cs:yold]

 inc di
;               movsx   ebx, [cs:v_t]
;               inc     ebx
;               mov     eax, ebx
;               mov     [cs:v_t], ax

;               movsx   ebx, [cs:v_t]
;               cmp     bx, 3E8h        ; if t>1000
		cmp	di, 3E8h	; if t>1000
		jle	short loc_401315

 inc bx
;;		movsx	ebx, [cs:v_tc]
;;		inc	ebx
;;		mov	eax, ebx
;;		mov	[cs:v_tc], ax

		inc si
		and si,0f0fh

		xor di,di;mov   [cs:v_t], 0

loc_401315: ; Until tc>(tcmax-1)
;;		mov	bx, [cs:v_tc]
;               movsx   edi, [cs:word_40BFA4]
;               dec     edi
tcmax equ 120
		cmp	bx, tcmax-1;edi
		jle	loc_4011E5

 in al,60h
 dec al
 jne	loc_401101
; jmp	loc_401101

random_405A30:
r:mov ax,1234h
 xor ax,0AA55h
 shl ax,1
 adc ax,0118h
 mov [cs:r+1],ax
 cwd
 mov bx,100
 idiv bx
 sub dx,50
 jns done_abs
 neg dx
done_abs:
 mov [bp+36],dx
 fild word [bp+36]
 ret

;---------------------------------------
flt_40B030	dw 30;dd 30.0
flt_40B034	dw 6;dd 6.0

;v_ynew dd 0.0
;v_xnew dd 0.0

;xold   dd 0
;yold   dd 0

;v_t    dw 0
;v_tc	dw 0

;F2 dd 0

;v_a:;   dd 0.0
;v_b    dd 0.0
;v_c    dd 0.0
;v_s    dd 0.0

