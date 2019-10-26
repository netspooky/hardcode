proc    clear_vscreen near
        pusha
        push es
        mov ax,[vscreen]        ;tyhj„„
        mov es,ax
        xor eax,eax
        xor edi,edi
        mov ecx,16000
        rep stosd
        pop es
        popa
        ret
endp

proc    new_int70h_handler far
			cli
			pusha
                        push ds
                        push cs
                        pop  ds
                        inc [dword cs:offset frameskip]
			mov al,0ch       ;reset the clock
			out 70h,al
			in al,71h
			mov al,20h       ;send EOI
			out 20h,al
			out 0a0h,al
                        pop ds
			popa
			sti
			iret
endp

;--IN:
;       al = interrupt to fuck
;       ds:si = place to keep old int vector
;       cx:dx = new int vector ie. pointer to new routine
;--OUT:
;       [dword cs:bx] = pointer of old handler
proc swapIntVector near
        pusha
        push ds
   mov ah,35h
   int 21h                              ;get old vector
   mov [si],es         ;save it
   mov [si+2],bx
   mov ds,cx
   mov ah,25h                           ;put new handler
   int 21h
        pop ds
        popa
        ret
endp

proc   squarert near
        ;cmp     dx,0ffffh               ; check for domain error
        ;jz      error                   ; bail if it's too big

        mov     di,dx                   ; save DX:AX in DI:SI
        mov     si,ax                   ;
        mov     cx,31                   ; max bit count
FindSetBit:
        shl     ax,1                    ; do 32-bit shift left
        rcl     dx,1                    ;   of DX:AX
        jc      GotSetBit               ; if we found MSB, we're done
        loop    FindSetBit              ; keep going
GotSetBit:
        mov     bx,1                    ; set up our initial guess
        shr     cx,1                    ; log2(alpha)/2
        shl     bx,cl                   ; now shift bit into position
        mov     cx,bx                   ; save it
        dec     bx                      ; flip all lesser bits
        or      bx,cx                   ; and or the two together
        mov     cx,2                    ; our error term
top:
        mov     dx,di                   ; reload DX:AX
        mov     ax,si                   ;
        div     bx                      ; ax = dx:ax / bx
        xchg    ax,bx                   ; save current guess in ax
        add     bx,ax                   ; add two factors
        rcr     bx,1                    ; and divide by two for next guess
        sub     ax,bx                   ; Q: (current - next) < 2?
        cmp     ax,cx                   ; under threshold?
        ja      top                     ; if not, keep going
error:
        mov     dx,di                   ; reload DX:AX
        mov     ax,si                   ;
        ret
ENDP

;IN:
;       SI=x coordinate
;       CX=radius
;OUT:
;       [yc2]=y coordinate

; x^2+y^2=r^2 ->  y = sqrt(r^2-x^2)
proc    calcdistance
                        pusha

                        mov     ax,si
               dec      ax                      ;Gotta GET FIX!
                        xor     dx,dx
                        mul     ax
                        mov     bx,ax           ;BX=x^2

                        mov     ax,cx
                        xor     dx,dx
                        mul     ax
                        sub     ax,bx           ;AX=r^2-x^2

                        xor     dx,dx
                        call    squarert
                        mov     [yc2],bx

                        popa
                        ret
endp

;RANDOM NUMBER GENERATOR
;IN:
;  CX=random number ranges
;OUT:
;  DX=random number
proc    random  near
                push ax
                push bx
                mov ax,[cs:offset seed]
		mov bx,9821
		imul bx
		inc ax
		ror al,1
		add ax,8191
		rol ah,1
                mov [cs:offset seed],ax
		xor dx,dx
		div cx
                pop bx
                pop ax
                ret
endp

