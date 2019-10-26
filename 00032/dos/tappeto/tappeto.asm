bits	16
org  	0x100

;
;           M      TAPPETO      M
;        ZMN          ^          DMO    
;       MM8    A torotonnato's    +MM,
;     7MMM        production       MMMO
;     MMMMN           ^           OMMMM
;     MMMMMMMMN8MMMMMMMMMMMMM8NMMMMMMMM
;     NMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
;       MM MMMMMMMMMMMMMMMMMMMMMMM~NM
;          OMM MMM8MMM?MMMNMMM MM8
;              MM  MMMMMMM  MM
;             +MMMM=MMMMM?MMMMM			contact: torotonnato@gmail.com
;              MMMMMMMMMMMMMMM					  ~have a quartic day.
;                MMM$MMM~MNM7			
;                 IMMMMMMMM				preconditions:
;                 M,MMM7M M					ah = 0
;                  NZ M IM					bx = 0
;                   MMMMM					top of memory = 0x9FFF
;
;******************************************************************************

%define EVOLUTION 0

		mov al, 0x13					;						
		int 10h							;
		les ax, [ bx ]					;
		mov si, 320						;
L:		lea ax, [ di - 16 ]				;
		sub dx, dx						;
		div si							;
		add ax, bx						;
		mul dx							;
		mul ax							; pixel = ((x&255)*((y+frame)&255))^2
%if   	EVOLUTION = 1					;
		mul bh							; pixel *= frame >> 8
%elif 	EVOLUTION = 2					;
		cmp al, 0						;
		jz w							;
		add al, bh						; pixel += pixel ? ( frame >> 8 ) : 0
%endif									;
w:		stosb							;
		loop L							;
		inc bx							;
		in ax, 0x60						;
		dec ax							;
		jnz L							;
		ret								;
