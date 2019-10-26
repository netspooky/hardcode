.386
CODE SEGMENT BYTE PUBLIC USE16
ASSUME CS:CODE

EXTRN sintab:NEAR
PUBLIC InitSinTab

InitSinTab proc far
           xor cx,cx
           mov si,offset sintab
           fninit
           fldpi
           fidiv Diver
           fldz
@01:       fld ST(0)
           fsin
           fimul Scale
           fistp Result
           mov ax,result
           mov [si],al
           inc si
           fadd ST,ST(1)
           inc cl
           jnz @01
           retf
Diver      dw 128
Scale      dw 64
Result     dw ?
InitSinTab endp

CODE ENDS
END