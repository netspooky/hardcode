;http://ulamspiral.blogspot.com/2008_06_01_archive.html
; All The Ulam
; Do not be mad watching on list
; i produced PureBasic algo to fasm source
; next was reducing to 230 bytes
; goblinish 13:04 27-07-2012
;check if(Math.round(Math.sqrt(pInt)*3.14159265)%2==0)

org 100h
use16
mov al,13h
int 10h
mov bh,0A0h
mov fs,bx
mov bh,080h
mov es,bx


; For j=1 To 25;8
  ;MOV   word [v_j],1
_For3:
;  MOV   ax,25
;  CMP   ax,word [v_j]
  ;CMP   word [v_j],25
;  JL   _Next4
; x.i=159
;;  MOV  word [bp],159;MOV       word [v_x],159
 mov cx,159
; y.i=99
  MOV	 si,99;word [bp+2],99;[v_y],99

 xor eax,eax
   MOV	 dword [bp+14],eax;0;[v_move],0
; move.i=0
  MOV	 word [bp+8],ax;0;[v_move],0
; moveswitch.i=0
  ;;MOV	 word [bp+10],ax;0;[v_moveswitch],0
; For k=0 To 20000*5+1800
  MOV	 dword [bp+14],eax;0;[v_k],0
  inc al
; direction.i=1
  mov bx,ax;MOV  word [bp+4],ax;1;[v_direction],1
; moves.i=1
  MOV	 di,ax;word [bp+6],ax;1;[v_moves],1
; bl=[v_direction],bh=[v_moveswitch]???????
_For5:
  ;MOV   eax,101800
  ;CMP   eax,dword [bp+14];[v_k]
  ;CMP   dword [bp+14],101800;[v_k]
  ;JL   _Next6
; 
; Select direction
  ;mov ax,[bp+4];[v_direction]
  ;PUSH  dword [v_direction]
  CMP	 bl,1;ax,1;[esp]
  JNE	_Case1
; x=x+1
  INC	 cx;word [bp];[v_x]
; Case 2
  JMP	_EndSelect1
_Case1:
  CMP	 bl,2;[esp]
  JNE	_Case2
; y=y-1
  DEC	 si;word [bp+2];[v_y]
; Case 3
  JMP	_EndSelect1
_Case2:
  CMP	 bl,3;[esp]
  JNE	_Case3
; x=x-1
  DEC	 cx;word [bp];[v_x]
; Case 4
  JMP	_EndSelect1
_Case3:
  CMP	 bl,4;[esp]
  JNE	_Case4
; y=y+1
  INC	 si;word [bp+2];[v_y]
; EndSelect
_Case4:
_EndSelect1:
  ;POP   eax
; 
; move=move+1
  ;;INC  word [bp+8];[v_move]
; If move=moves;If move=moves
  MOV	 ax,word [bp+8];[v_move]
  inc ax
  CMP	 ax,di;word [bp+6];[v_moves]
  JNE	_EndIf8
; move=0
  ;;MOV  word [bp+8],0;[v_move],0
; moveswitch=moveswitch+1
  INC	 bh;word [bp+10];[v_moveswitch]
; If moveswitch = 2;If moveswitch = 2
  ;MOV   ax,word [bp+10];[v_moveswitch]
  ;CMP   ax,2
  cmp bh,2;word [bp+10],2
  JNE	_EndIf10
; moveswitch=0;
  xor bh,bh;MOV	 word [bp+10],0;[v_moveswitch],0
; moves=moves+1
  INC	 di;word [bp+6];[v_moves]
; EndIf
_EndIf10:
; direction=direction+1
  INC	 bl;word [bp+4];[v_direction]
; If direction > 4
  ;MOV   ax,word [bp+4];[v_direction]
  CMP	 bl,4
  JLE	_EndIf12
; direction = 1
  MOV	 bl,1;word [bp+4],1;[v_direction],1
; EndIf
_EndIf12:
; EndIf
 xor ax,ax
_EndIf8:
MOV	 word [bp+8],ax
; 
; If Int(j+Sqr(k*1.618))%5 = 0
  ;;FILD         word [bp+12];[v_j]
  FILD	 dword [bp+14];[v_k]
  FMUL	 dword [D1]
  FSQRT
  ;;FADDP  st1,st0
  FISTP  word [bp];+18];[D2];dword [D2]
  MOV	 ax,[bp];+18];[D2];eax,[D2]
  add ax,[bp+12];;
  ;;;;;;;;;;;;;;shr ax,1 only for pattern
  push cx
  MOV	 cx,5;replace divisor to diff.effects
  xor dx,dx
  ;CDQ
  IDIV	 cx
  pop cx
  AND	 dx,dx
  JNE	_EndIf16;4

; If (y<199) And (y>0) And (x<319) And (x>0)
  ;MOV   ax,si;word [bp+2];[v_y]
  CMP	 si,199
  JGE	 _EndIf16;No0
  ;;MOV  ax,word [bp+2];[v_y]
  AND	 si,si;ax,ax
  JLE	 _EndIf16;No1
  ;MOV   ax,cx;word [bp];[v_x]
  CMP	 cx,319
  JGE	 _EndIf16;No2
  ;;MOV  ax,word [bp];[v_x]
  AND	 cx,cx;ax,ax
  JLE	 _EndIf16;No2
;Ok2:--------- fuck stupid compiler
;  MOV   ax,1;eax,1
;  JMP   End2
;No2:
;  XOR   ax,ax;eax,eax
;End2:
;  AND   ax,ax;eax,eax
;  JE    No1
;Ok1:
;  MOV   ax,1;eax,1
;  JMP   End1
;No1:
;  XOR   ax,ax;eax,eax
;End1:
;  AND   ax,ax;eax,eax
;  JE    No0
;Ok0:
;  MOV   ax,1;eax,1
;  JMP   End0
;No0:
;  XOR   ax,ax;eax,eax
;End0:
;  AND   ax,ax;eax,eax
;  JE   _EndIf16
; Plot(x,y,RGB(255*(j&1),0,0));255*(j>>1),0))
 push di
 mov di,si;mov ax,si;[bp+2];[v_y]
 imul di,320;imul ax,320
 add di,cx;add ax,cx;[bp];[v_x]
 ;;?mov di,ax
 mov ax, [bp+12];[v_j]
 and al, 1; rem op for some effect
 shl al,2;or use and al, 1 for back effect
 stosb;mov byte [es:di],al;4
 pop di
; EndIf
_EndIf16:
; EndIf
_EndIf14:
; Next k
_NextContinue6:
  INC	 dword [bp+14];[v_k]
  CMP	 dword [bp+14],101800
  JNE	_For5
_Next6:
		mov	dx, 3DAh
@wait4retrace:
		in	al, dx
		and	al, 8
		jz	short @wait4retrace
 ;push ds
 push es;08000h
 pop ds
 push fs;0A000h
 pop es
 ;cld
 xor si,si
 xor di,di
 ;push cx
 ;push si
 mov cx,320*200
 rep movsb
 ;pop si
 ;pop cx
 push ds
 pop es
 push cs
 pop ds
; Next j; place copy here!
_NextContinue4:
  INC	 word [bp+12];[v_j]
  ;MOV   eax,101800
  ;CMP   dword [bp+14],101800;[v_k]
  ;Jnz  _For3;_Next6
  in al, 60h
  dec al
  jz _EndIf2
 jmp _For3;JNO _For3
_Next4:
_EndIf2:
 int 20h
;----------------------------------------------
;v_j dw 1;[bp+12]
;v_k dd 1;[bp+14]
;v_x dw 1;[bp]
;v_y dw 1;[bp+2]
;v_direction dw 1;[bp+4]
;v_moves dw 1;[bp+6]
;v_move dw 1;[bp+8]
;v_moveswitch dw 1;[bp+10]
D1: dd 1.618;-137438953,1073341267
;D2: dd 0
