_Code SEGMENT WORD PUBLIC 'CODE'
      ASSUME  cs:_Code, ds:_Code
      ORG     100h

.386
	      ;email: smart-bomb@msn.com (someone took legend!)
First:
 jmp Start
 RandomBytes DB 180,137,148,074,077,198,004,194,208,181,012,106,220,202,096
	     DB 246,223,015,243,093,134,196,014,152,120,077,159,166,068,072
	     DB 212,211,151,252,233,058,178,250,063,137,028,255,173,005,147
	     DB 026,027,204,073,012,076,098,077,242,250,103,071,041,042,165
	     DB 105,106,182,084,162,053,048,149,021,117,231,067,201,097,074
	     DB 235,162,161,110,025,144,178,233,213,006,139,234,110,173,129
	     DB 132,119,091,104,069,015,063,250,016,100,094,125,040,121,066
	     DB 161,139,040,240,167,130,100,028,200,118,193,153,213,005,054
	     DB 019,027,085,033,001,137,168,139,211,021,049,174,116,092,039
	     DB 180,237,136,023,194,103,118,126,053,085,025,151,044,237,025
	     DB 114,070,223,192,070,172,066,023,008,083,202,076,060,123,065
	     DB 087,012,124,053,221,151,193,237,085,139,021,162,105,245,030
 Credits     DB "DpEfE!CZ!MfHfOE%" ;CoDeD BY LeGeND
 Color	     DB 0
 Blue	     DB 0

Start:
 mov ax, 0013h		  ;VGA video mode
 int 10h

 mov bx, 0		  ;clear Buffer
again0:
 mov Buffer[bx], 0
 inc bx
 cmp bx, 64000
 jnz again0

 mov dx, 03c7h		  ;create color palette
 xor bx, bx
again1:
 mov al, Color
 out dx, al
 add dx, 2
 mov al, 0
 out dx, al
 out dx, al
 mov al, Blue
 out dx, al
 inc Color
 test Color, 05h
 jz incBlue
next:
 inc bx
 sub dx, 2
 cmp bx, 255
 jnz again1
 jmp paldone
incBlue:
 inc Blue
 jmp next
paldone:

MainLoop:
 mov dx, 03dah		  ;wait for vertical retrace
wr1:
 in al, dx
 test al, 08h
 jnz wr1
wr2:
 in al, dx
 test al, 08h
 jz wr2

 mov bx, 63360		  ;create random bottom line
again2:
 in al, 40h
 add al, RandomBytes[bx-63360]
 mov Buffer[bx], al
 inc bx
 cmp bx, 64000
 jnz again2

 mov bx, 320		  ;smudge Buffer
smudgepixel:
 xor ah, ah
 mov al, Buffer[bx+1]
 mov dx, ax
 mov al, Buffer[bx-1]
 add dx, ax
 mov al, Buffer[bx+320]
 add dx, ax
 mov al, Buffer[bx-320]
 add dx, ax
 shr dx, 2
 or  dl, dl
 jz nodec
 dec dl
nodec:
 mov Buffer[bx-320], dl
 inc bx
 cmp bx, 64000
 jnz smudgepixel

 push ds		  ;write Buffer to VGA; this is the slow way, here's
 mov ax, 0a000h 	  ;the fast way, but for some reason it doesn't work!
 mov es, ax		  ;  push ds		  ;(please e-mail me on this)
 xor di, di		  ;  mov ax, 0a000h
again3: 		  ;  mov es, ax
 mov bx, di		  ;  mov ax, WORD PTR Buffer
 mov al, Buffer[bx]	  ;  mov ds, ax
 mov es:[di], al	  ;  xor si, si
 inc di 		  ;  xor di, di	    ;pick one
 cmp di, 63360		  ;  mov cx, 16000  ;16000, 32000, 64000
 jnz again3		  ;  rep movsd	    ;movsd, movsw, movsb
 pop ds 		  ;  pop ds	    ;make sure its CLD'd

 in al, 60h		  ;check for esc key
 cmp al, 01h
 jnz MainLoop

 mov ax, 0003h		  ;reset video mode
 int 10h

 mov bx, 0		  ;revert Credits
again4:
 mov al, Credits[bx]
 sub al, 1
 mov Credits[bx], al
 inc bx
 cmp bx, 46
 jnz again4

 mov ah, 09h		  ;display Credits
 mov dx, OFFSET Credits
 int 21h

 int 20h		  ;quit to dos

 Buffer      DB 0 DUP(?)  ;DUP'ing the Buffer at the END saves 64,000 bytes
			  ;and your computers sanityÄ-Ù
_Code ENDS
      END First
