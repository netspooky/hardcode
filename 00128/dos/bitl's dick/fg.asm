	org 100h
	use16

	   mov	ax,12h		      ; set mode to 640x480x16
	   int	10h

mov cx,1;640
;ROWS = 480
;START = 2
;FINISH = 3.999
fld1
fadd st,st;2
fst qword [bp+14h];r
fsub [cs:fin]
mov word [bp],640;cx
fidiv word [bp]
fstp qword [bp+0Ch]; dr
@rlp:
;FOR R = START TO FINISH STEP (FINISH - START) / COLUMNS. 640 steps?
mov word [bp],0Ah
fld1
fidiv word [bp]
fstp qword [bp+4];x=.1

mov di,1;i=1
@i:
;X = R * (X - X * X), or x*(1-x)
fld1
fsub qword [bp+4];1-x
fmul qword [bp+4];*x
fmul qword [bp+14h];*r
;fmul R?
fstp qword [bp+4];X
cmp di,30
jc @nexti
;fld qword [bp+4]
fld1
fsub qword [bp+4]
mov word [bp],480;rows
fimul word [bp]
fistp word [bp]
  mov DX,[bp];0Ah   ;строка y
  push cx
  mov ax,0C0Fh;xchg AX,CX  ;CX - колонка x, AL - цвет
  sub BH,BH   ;0 страница
  int 10h
  pop cx
;PSET ((R - START) * COLUMNS / (FINISH - START), ROWS - (X - TOP/=0) * ROWS * VPCT/=1)
;use cx instead of x
@nexti:
inc di
cmp di,130
jne @i
;some r++
fld qword [bp+14h]
fsub qword [bp+0Ch]
fstp qword [bp+14h]
;loop @rlp
inc cx
cmp cx,640
jnz @rlp
int 20h
fin dd 3.999