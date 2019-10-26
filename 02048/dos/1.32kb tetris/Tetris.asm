;Programmed by Vzub Pnukem
;e-mail: ultrasergman@hotmail.com

.model tiny
.code
.286
org 100h

Start:
	mov ax, 3			;Set video mode
	int 10h

	mov ax, 0100h			;mov ah, 1
	mov cx, 2607h			;mov ch, 100000b
	int 10h				;Turn off cursor

	push bp				;SaveHiScore won't work without it

        mov bp, offset Font
        mov cx, 4
        mov dx, 219
	mov bx, 1000h
        mov ax, 1100h
        int 10h				;Set font
        
	push word ptr 0b800h		;Video segment
	pop es

	call Randomize
	call InstallTimer
	
NewGame:
	xor di, di
	mov cx, 2000
	mov ax, 700h			;mov al, 0  mov ah, 7
	rep stosw			;Clear screen and set color 7

	call DrawBorders

	mov di, 184
	mov si, offset sNext
	call PrintText
	mov di, 272
	mov si, offset sHiScore
	call PrintText
	mov di, 3430
	mov si, offset sScore
	call PrintText
	mov di, 1304
        mov si, offset sSpeed
        call PrintText
	mov di, 1392
	mov si, offset sRotation
	call PrintText        

	mov di, 292
	mov ax, HiScore
	call PrintNumber

	mov Score, 0

	call ChooseGame
	
	call Rand
	mov NextShape, ax
	call NewShape
	call DrawNextShape
MainLoop:
	mov di, 3444
	mov ax, Score
	call PrintNumber

	mov bp, 219
	call DrawShape

WaitKey:
        mov ah, 1
        int 16h
        jnz GetKey

	mov al, Counter
	test al, al
	jnz WaitKey

	mov ah, 5
	mov ch, 80			;Scan code
	int 16h				;Put it to keyboard buffer

GetKey:
        xor bp, bp
        call DrawShape

	mov bl, CurShapeFrame
	mov dx, CurShapePos

	xor ax, ax
	int 16h

	cmp ah, 72
	jz RotateShape

	cmp ah, 75
	jz MoveLeft

	cmp ah, 77
	jz MoveRight

	cmp ah, 80
	jz MoveDown

	cmp ah, 1
	jnz MainLoop
	
	jmp EndGame

MoveLeft:
        sub dx, 8
MoveRight:
	add dx, 4
	call TestCollision
	jc MainLoop
	mov CurShapePos, dx
	jmp MainLoop

RotateShape:
	add bl, 2
	and bl, 7			;If 8 then set to 0
        call TestCollision
	jc EndRotateShape
	mov CurShapeFrame, bl
EndRotateShape:
	jmp MainLoop

MoveDown:
	add dx, 160
	call TestCollision
	jc PlaceInGrid
	mov CurShapePos, dx
	jmp EndMoveDown
PlaceInGrid:
	mov bp, 219
	call DrawShape
	call CheckLines

	call NewShape

	xor bx, bx
	mov dx, 72
	call TestCollision
	jc GameOver

	call DrawNextShape
EndMoveDown:
	mov si, offset SpeedTable
	add si, Speed
	mov al, [si]
	mov Counter, al
	jmp MainLoop

GameOver:
        call UpdateHiScore
        mov di, 1344
        mov si, offset sGameOver
        call PrintText
        mov di, 1510
        mov si, offset sAgain
        call PrintText
Again:
        xor ax, ax
        int 16h
	cmp ah, 49
	jz EndGame
	cmp ah, 21
	jnz Again
	jmp NewGame

EndGame:
	pop bp
	call UpdateHiScore
	call SaveHiScore
	call RemoveTimer
	mov ax, 3
	int 10h
	ret

DrawBlock PROC
;IN:	bx = screen offset, bp = scan code
;OUT:	nothing

	mov di, bx
	mov ax, bp
	stosb
	inc di
	test al, al
	jz EmptyChar
	inc al
EmptyChar:
	stosb
	ret
DrawBlock ENDP

NewShape PROC
;IN:	nothing
;OUT:	nothing

	mov ax, NextShape
	shl ax, 3
	mov CurShape, ax
	mov CurShapeFrame, 0
	mov CurShapePos, 72
        call Rand
        mov NextShape, ax
	ret
NewShape ENDP

DrawShape PROC
;IN:	nothing
;OUT:	nothing

        mov ax, CurShape
        add al, CurShapeFrame
	mov si, offset Shapes
	add si, ax
	mov bx, CurShapePos
	mov dx, 1
ShapeDraw:
	mov cx, 4
DrawRow:
	mov ax, [si]
	and ax, dx
	jz EmptyBlock
	call DrawBlock
EmptyBlock:
	shl dx, 1
	jz EndDrawShape
        add bx, 4
        loop DrawRow
        add bx, 144
        jmp ShapeDraw
EndDrawShape:
	ret
DrawShape ENDP

DrawNextShape PROC
;IN:	nothing
;OUT:	nothing

        mov ax, NextShape
        shl ax, 3
	mov si, offset Shapes
	add si, ax
        mov bx, 500
	mov dx, 1
NextShapeDraw:
	mov cx, 4
NextDrawRow:
	xor bp, bp
	call DrawBlock
	mov ax, [si]
	and ax, dx
	jz NextRow
        mov bp, 219
	call DrawBlock
NextRow:
	shl dx, 1
	jz EndDrawNextShape
        add bx, 4
        loop NextDrawRow
        add bx, 144
        jmp NextShapeDraw
EndDrawNextShape:
	ret
DrawNextShape ENDP

TestCollision PROC
;IN:	bx = ShapeFrame, dx = ShapePos
;OUT:	CF is set on error

	pusha
        mov ax, CurShape
        add al, bl			;Next frame
	mov si, offset Shapes
	add si, ax
        mov bx, dx			;ShapePos
	mov dx, 1
CollisionTest:
	mov cx, 4
TestRow:
	mov ax, [si]
	and ax, dx
	jz SkipCollisionTest
	mov al, es:[bx]
	mov ah, es:[bx+2]
        test ax, ax
	jnz CollisionDetected
SkipCollisionTest:
	shl dx, 1
	jz NoCollisionDetected
        add bx, 4
        loop TestRow
        add bx, 144
        jmp CollisionTest
NoCollisionDetected:
	popa
	clc
	ret
CollisionDetected:
	popa
	stc
	ret
TestCollision ENDP

CheckLines PROC
;IN:	nothing
;OUT:	nothing

	mov dx, 3096
	xor bx, bx
TestNextLine:
	mov di, dx
	mov cx, 24
LineTesting:
	mov al, es:[di]
	add di, 2
	test al, al
	jz NotFullLine
	loop LineTesting

	inc bx

	sub di, 208
MoveLines:
	mov cx, 24
MoveLine:
	mov al, es:[di]
	mov es:[di+160], al
	add di, 2
	loop MoveLine
	sub di, 208		;there's a bug
	jnc MoveLines
	
	add dx, 160
NotFullLine:
	sub dx, 160
	cmp dx, 56
	jnz TestNextLine

	test bx, bx
	jz EndCalcScore
	shl bx, 1
	dec bx
	cmp bx, 7
	jnz EndCalcScore
	mov bx, 15
EndCalcScore:
	mov ax, Score
	add ax, bx
	cmp ax, Temp
	jb DontSpeedUp
	add Temp, 50

	push ax
	mov bx, Speed
	inc bl
	cmp bl, 10
	jnz DontResetSpeed
	xor bx, bx
DontResetSpeed:
	mov Speed, bx
	mov si, offset SpeedTable
	add si, bx
	mov al, [si]
	mov Counter, al
	
	mov di, 1318
	mov ax, bx
	call PrintNumber
	pop ax

DontSpeedUp:
	mov Score, ax
	ret
CheckLines ENDP

DrawBorders PROC
;IN:	nothing
;OUT:	nothing

	mov di, 54
	mov al, 186
	xor ch, ch
DrawSides:
	stosb
	add di, 49
	stosb
	add di, 109
	inc ch
	cmp ch, 20
	jne DrawSides
	mov al, 200
	stosb
	mov al, 205
DrawBottom:
	inc di
	stosb
	inc ch
	cmp ch, 44
	jne DrawBottom
	mov al, 188
	inc di
	stosb
	ret
DrawBorders ENDP

ChooseGame PROC
;IN:	nothing
;OUT:	nothing

	mov di, 1348
	mov si, offset sChooseLev
	call PrintText
	mov di, 1508
	mov si, offset sChooseRot
	call PrintText

        xor bx, bx

Select:
	mov di, 1318
	mov ax, bx
	push bx
	call PrintNumber		;Print speed
	pop bx

	mov di, 1412
	mov al, Rotation
	add al, 221
	stosb				;Print rotation
	
	xor ax, ax
	int 16h
	
	cmp ah, 28
	jz SetOptions
	
	cmp ah, 75
	jz RotateLeft

	cmp ah, 77
	jz RotateRight

	cmp ah, 72
	jz IncreaseSpeed

	cmp ah, 80
	jnz Select
	test bx, bx
	jz Select
	dec bx
	jmp Select

IncreaseSpeed:
	cmp bx, 9
	jz Select
	inc bx
	jmp Select

RotateRight:
	mov al, Rotation
	mov Rotation, 0
	jmp ChangeRotation
RotateLeft:
	mov al, Rotation
	mov Rotation, 1
ChangeRotation:
	cmp Rotation, al
	jz Select
	push bx
	call ReverseFrames
	pop bx
	jmp Select

SetOptions:
	mov di, 1344
	mov ax, 700h			;mov al, 0  mov ah, 7
	mov cx, 16
	rep stosw
	mov di, 1504
	mov cx, 16
	rep stosw
	
	mov Speed, bx
	mov si, offset SpeedTable
	add si, bx
	mov al, [si]
	mov Counter, al

	ret
ChooseGame ENDP

ReverseFrames PROC
;IN:	nothing
;OUT:	nothing

	mov cx, 7
	mov si, offset Shapes
ChangeFrames:
	mov ax, [si+2]
	mov bx, [si+6]
	mov [si+2], bx
	mov [si+6], ax
	add si, 8
	loop ChangeFrames
	ret
ReverseFrames ENDP

InstallTimer PROC
;IN:	nothing
;OUT:	nothing

        push es
        mov ax, 351Ch
        int 21h
        mov word ptr [Old1Ch], bx
        mov word ptr [Old1Ch+2], es
        pop es
        mov ah, 25h
        mov dx, offset int1Ch
        int 21h

	mov dx, 2e9bh			;1193180/100Hz
	mov al, 034h
	out 043h, al
	mov al, dl
	out 040h, al
	mov al, dh
	out 040h, al

        ret
InstallTimer ENDP

int1Ch PROC
;IN:	nothing
;OUT:	nothing

	mov al, cs:Counter
	test al, al
	jz EndTimer
	dec al
	mov cs:Counter, al
EndTimer:
	iret
int1Ch ENDP

RemoveTimer PROC
;IN:	nothing
;OUT:	nothing

        mov ax, 251ch
        lds dx, [Old1Ch]
        int 21h

	mov al, 034h
	out 043h, al
	xor al, al
	out 040h, al
	out 040h, al
       	ret
RemoveTimer ENDP

Randomize PROC
;IN:	nothing
;OUT:	nothing

	xor ax, ax
	int 1Ah
	mov RandSeed, dx
        ret
Randomize ENDP

Rand PROC
;IN:	nothing
;OUT:	ax = random number

	mov al, 16
	mov dx, RandSeed
r_loop:
	rol dx, 1
	jnc r_skip
	xor dx, 0ah
r_skip:
	dec al
	jne r_loop
	mov ax, dx
	mov RandSeed, dx

	xor dx, dx
	mov cx, 7			;Limit
	div cx
	mov ax, dx

        ret
Rand ENDP

PrintNumber PROC
;IN:    ax = number, di = screen offset
;OUT:	nothing

	mov bx, 10			;For dividing by 10
	xor cx, cx			;Clear count of digits
Loop_Until_Zero:
	xor dx, dx			;Clear DX for divide
	div bx				;Get rightmost digit
	push dx				;Put it on stack
	inc cx				;Increment digit count
	test ax, ax			;If AX still non-zero,
	jne Loop_Until_Zero		;we're not done
Print_Loop:
	pop dx				;Get next digit
	add dl, 30h			;Make digit printable
	mov es:[di], dl
	add di, 2
	loop Print_Loop
	ret
PrintNumber ENDP

PrintText PROC
;IN:    di = screen offset, si = text offset
;OUT:   nothing

NextChar:
	lodsb
	test al, al
	jz EndPrintText
	stosb
	inc di
	jmp NextChar
EndPrintText:
	ret
PrintText ENDP

UpdateHiScore PROC
;IN:	nothing
;OUT:	nothing

	mov ax, Score
	cmp HiScore, ax
	ja DontSaveHiScore
	mov HiScore, ax
DontSaveHiScore:
        ret
UpdateHiScore ENDP

SaveHiScore PROC
;IN:	nothing
;OUT:	nothing

	push ds
	mov ax, 1203h
	int 2fh
	lds dx, ds:[bp-1ah]		;Take file name
	mov ax, 3d01h			;Open file
	int 21h
	mov bx, ax			;Save file handle
	pop ds

	mov ax, 4200h			;Move reading pointer
	xor cx, cx
	mov dx, offset HiScore-Start
	int 21h
	mov ah, 40h			;Write new HiScore
	lea dx, HiScore
	mov cx, 2
	int 21h
	mov ah, 3eh			;Close file
	int 21h
	ret
SaveHiScore ENDP

CurShape	DW 0
CurShapePos	DW 0
CurShapeFrame	DB 0
NextShape	DW 0

Rotation	DB 0

Shapes          DW 0017h, 0446h, 0074h, 0622h ;J
                DW 0066h, 0066h, 0066h, 0066h ;box
                DW 0036h, 0462h, 0036h, 0462h ;z
                DW 0072h, 0262h, 0027h, 0464h ;pyramid
                DW 008eh, 0644h, 00e2h, 0226h ;L
                DW 000fh, 2222h, 000fh, 2222h ;-
                DW 0063h, 0264h, 0063h, 0264h ;s

RandSeed	DW ?

Score		DW 0
HiScore		DW 0
Temp		DW 50

sNext		DB 'Next:', 0
sScore		DB 'Score:', 0
sHiScore	DB 'Hi-Score:', 0
sSpeed          DB 'Speed:', 0
sRotation	DB 'Rotation:', 0

sGameOver	DB 'G A M E  O V E R', 0
sAgain		DB 'Again (Y/N)', 0
sChooseLev	DB 'Choose speed', 0
sChooseRot	DB 'and rotation', 0

Old1Ch          DD ?
Speed		DW 0
Counter		DB 0
SpeedTable	DB 80, 50, 34, 28, 22, 18, 16, 14, 12, 11

Font            DB 00000000b
                DB 01111111b
                DB 01111111b
                DB 01111111b
		DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b
		DB 01111111b
                DB 01111111b
                DB 01111111b
                DB 01111111b

                DB 00000000b
                DB 11111111b
                DB 11111111b
		DB 11111111b
		DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b
		DB 11111111b
                DB 11111111b
                DB 11111111b
                DB 11111111b

                DB 00000000b
                DB 00000000b
                DB 11111100b
                DB 00000100b
                DB 00000100b
                DB 00000100b
                DB 00000100b
                DB 00000100b
                DB 00000100b
                DB 00000100b
                DB 00010101b
                DB 00001110b
                DB 00000100b
                DB 00000000b
                DB 00000000b
                DB 00000000b

                DB 00000000b
                DB 00000000b
                DB 00111111b
                DB 00100000b
                DB 00100000b
                DB 00100000b
                DB 00100000b
                DB 00100000b
                DB 00100000b
                DB 00100000b
                DB 10101000b
                DB 01110000b
                DB 00100000b
                DB 00000000b
                DB 00000000b
                DB 00000000b
END Start