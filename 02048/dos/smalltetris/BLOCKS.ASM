.MODEL TINY


	public	Items


BLOCK	equ		254

COLOR1	equ		65
COLOR2	equ     36
COLOR3	equ     23
COLOR4	equ     19
COLOR5	equ     45
COLOR6	equ     78
COLOR7	equ     124

.DATA
Items label word
	db	BLOCK,	COLOR1,	176,  40,  40,  40
	db	BLOCK,	COLOR1,	214,   1,   1,   1
	db	BLOCK,	COLOR1,	176,  40,  40,	40
	db	BLOCK,	COLOR1,	214,   1,	1,	 1

	db	BLOCK,	COLOR2,	215,  40,  40,	 1
	db	BLOCK,	COLOR2,	217,  38,	1,	 1
	db	BLOCK,	COLOR2,	215,   1,  40,	40
	db	BLOCK,	COLOR2,	215,   1,	1,	38

	db	BLOCK,	COLOR3,	217,  40,  39,	 1
	db	BLOCK,	COLOR3,	215,   1,	1,	40
	db	BLOCK,	COLOR3,	215,   1,  39,	40
	db	BLOCK,	COLOR3,	255,  40,	1,	 1

	db	BLOCK,	COLOR4,	215,   1,	1,	39
	db	BLOCK,	COLOR4,	215,  40,	1,	39
	db	BLOCK,	COLOR4,	216,  39,	1,	 1
	db	BLOCK,	COLOR4,	216,  39,	1,	40

	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1
	db	BLOCK,	COLOR5,	215,   1,  39,	 1

	db	BLOCK,	COLOR6,	215,   1,  40,	 1
	db	BLOCK,	COLOR6,	216,  39,	1,	39
	db	BLOCK,	COLOR6,	215,   1,  40,	 1
	db	BLOCK,	COLOR6,	216,  39,	1,	39

	db	BLOCK,	COLOR7,	216,   1,  38,	 1
	db	BLOCK,	COLOR7,	216,  40,	1,	40
	db	BLOCK,	COLOR7,	216,   1,  38,	 1
	db	BLOCK,	COLOR7,	216,  40,	1,	40
end
