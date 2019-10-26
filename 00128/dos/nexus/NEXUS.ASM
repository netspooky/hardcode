;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
; nexus source - spASM'2000 ->  tasm /m3 nexus.asm | tlink /t nexus
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
demoseg    segment byte public
           assume  cs:demoseg,ds:demoseg,es:demoseg
           org 100h
.386
b equ byte ptr
w equ word ptr
d equ dword ptr
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
; CODE
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

start:  mov al,13h
        int 10h
        push 0a000h
        pop es

ml:     xor di,di

        fild w ds:[pxco]		;get angle to calc where to draw circ1 at
        fmul d (offset start+044h)-3	;3ch - somewhere between 0.01 & 0.03
        fsincos				;      close enough as im not wrapping at 256
        fimul w (offset start+02dh)	;the address of "200" in "mov si,200"
        fistp w ds:[px]
        fimul w (offset start+02dh)
        fistp w ds:[py]

        inc w ds:[pxco]

        mov bx,w ds:[py]
               
        mov si,200

dolly1: mov w dx,ds:[px]
        mov cx,320     

dollx1: call circ	;draw a pixel for circ1

        pusha
        sub dx,ds:[py] 	;move circ pos
        sub bx,ds:[px] 
        sub dx,3ch	;this 3ch is also used for fmul ^
        dec bh		;these two lines make the circs more cental on the screen
        call circ	;draw a pixel for circ2 xored onto 1st pixel
        popa

        xor al,al
        xchg al,ds:[curpix]	;puts final pixel in al & clears buf ready to xor next one
        stosb			;disp

        inc dx
        loop dollx1

        inc bx
        dec si
        jne dolly1

        mov ah,1
        int 16h
        jz ml
        mov ax,3
        int 10h
        ret


circ:   pusha		
        xchg ax,bx
        imul dx,dx           ;((x^2)+(y^2))/pxco 
        imul ax,ax
        add ax,dx
        cdq
        div w ds:[pxco]      ;pxco incs each frame so the circles will gradually get bigger
        xor b ds:[curpix],al ;combine pixels
        popa
        ret

;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
; DATA & STUFF
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

; Vars

pxco    dw 0  ; Unfortuatley, if run from windows, this HAS to be 0
              ; (Can be assembled as "?" if running from dos to save 2 bytes)
;Deleting above line and adding this following one works fine, but you
;dont get the "zoom-in" at the start
;pxco equ (offset start+4)

; BSS stuff - takes up zero bytes

px      dw ?
py      dw ?
curpix  db ?

demoseg ends
end     start

