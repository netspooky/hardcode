;****************************** Some macros ***********************************
WriteText	MACRO string 
local label1,label0
	pusha
	jmp	label1
label0:
	db string
	db '$',0
label1:
	mov	ah,9h
	mov	dx,offset label0
	int	21h
	popa
ENDM
;=============================================================================;
WritelnText	MACRO string 
local label1,label0
	pusha
	jmp	label1
label0:
	db string
	db 0dh,0ah,'$',0
label1:
	mov	ah,9h
	mov	dx,offset label0
	int	21h
	popa
ENDM

;****************************** 32bit macros ***********************************
lrep	MACRO		;&&
	db 	66h	;&&
	rep		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lstosb	MACRO		;&&
	db 	67h	;&&
	stosb		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
llodsb	MACRO		;&&
	db 	67h	;&&
	lodsb		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lmovsb	MACRO		;&&
	db 	67h	;&&
	movsb		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lloop	MACRO _lloop	;&&
	db 	67h	;&&
	loop 	_lloop	;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lstosw	MACRO 		;&&
	db 	67h	;&&
	stosw		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lstosd	MACRO 		;&&
	db 	67h	;&&
	stosd		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
llodsw	MACRO 		;&&
	db 	67h	;&&
	lodsw		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
llodsd	MACRO 		;&&
	db 	67h	;&&
	lodsdd		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lmovsw	MACRO 		;&&
	db 	67h	;&&
	movsw		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
lmovsd	MACRO 		;&&
	db 	67h	;&&
	movsd		;&&
ENDM			;&&	
;&&&&&&&&&&&&&&&&&&&&&&&&&&
