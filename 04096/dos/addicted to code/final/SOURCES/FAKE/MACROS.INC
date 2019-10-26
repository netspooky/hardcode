;****************************** Some macros ***********************************
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
