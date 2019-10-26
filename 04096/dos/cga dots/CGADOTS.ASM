.MODEL tiny
.CODE
.STARTUP
.8086
; Compile with TASM
; Link with TLINK /T

;CALC_FPS = 1

	jmp short Real_Start
KbdInt:
     push ax
     cli
     in         al,60h
     mov        cs:c,al
     in      al,61H             ;get value of keyboard control lines
     mov     ah,al              ; save it
     or      al,80h             ;set the "enable kbd" bit
     out     61H,al             ; and write it out the control port
     xchg    ah,al              ;fetch the original control port value
     out     61H,al             ; and write it back

     mov        al,20h
     out        20h,al
     sti
     pop ax
     iret

Error:
	mov dx,offset mem_error		; Write	Error message
	mov ah,9
	int 21h
	int 20h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;       STARTUP        ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Real_Start:
	mov bx,1000h	 		; shrink program memory size to 64 K
	mov ah,4ah                     
	int 21h
	mov ah,48h
	mov bx,400h                     ; get 16K for buffer
	int 21h
	jc error
	mov es,ax

        push es
	mov ax,3509h			; save old Kbd Int 09h
	int 21h
	mov cs:OldK,bx
	mov cs:OldK+2,es
        pop es
	mov ax,2509h			; set new Kbd int
	mov dx,offset KbdInt
	int 21h

        mov ax,04h			; switch to 320x200 CGA
        int 10h

        push es				; unpack picture1 to pic_buf
        push ds
        pop es
        lea si,packpic1
        lea di,pic_buf
        mov cx,3878
        call depack
        pop es

	lea bp,stab1			; BP = stab1. [BP+512] = stab2

ifdef CALC_FPS
        call timer			; tim = timer
        mov tim,ax
        mov tim+2,dx

        mov ax, tim			; tim = tim + 18
        add ax, t18
        mov tim, ax
        mov ax, tim+2
        adc ax, t18+2
        mov tim+2, ax

endif
Main_Loop:

        cli				; disable interrupts
	lea si,pic_buf			; copy picture to frame buffer ES:0
	xor di,di
	mov cx,02000h
	rep movsw

ifdef CALC_FPS
        mov ah,2			; slow int 10h draw FPS
        xor dx,dx
        xor bh,bh
        int 10h
        lea si,sfps
        lodsb
        mov cl,al
        xor ch,ch
@wr:    lodsb
        mov ah,0eh
        mov bl,3
        xor bh,bh
        int 10h
        loop @wr
endif
        xor si,si                       ; SI = loop counter

dots_loop:
					;stab1[(xst1+xspd1+i*dx1) mod slen1]

        mov di,xst1
        add di,si

        mov cx,di	;mul 3
        shl di,1
        add di,cx

        and di,511

        mov al,[bp+di]
	cbw
        mov bx,ax

					;stab2[(xst2+xspd2+i*dx2) mod slen2]
        mov di,xst2
        add di,si

        shl di,1	;mul 4
        shl di,1

        and di,511

        mov al,[bp+di+512]
        cbw
        add ax,bx
        add ax,110

        mov bx,ax                       ; Save X coord in BX

					;stab1[(yst1+yspd1+i*dy1) mod slen1]
        mov di,yst1
        add di,si

        mov cx,di	;2    mul 5
        shl di,1	;2
        shl di,1	;2
        add di,cx	;3

        and di,511

        mov al,[bp+di]
        cbw
        mov dx,ax
					;stab2[(yst2+yspd2+i*dy2) mod slen2]
        mov di,yst2
        add di,si

        mov cx,di 	;2    mul 3
        shl di,1	;2
        add di,cx	;3

        and di,511

        mov al,[bp+di+512]
	cbw
        add ax,dx

;Caller:
;  AX = y-coordinate (0-199)
;  BX = x-coordinate (0-319)

;Returns:
;  AH = bit mask
;  BX = byte offset in buffer
;  CL = number of bits to shift left
;  ES = video buffer segment

  mov     cl,bl           ;{ CL := low-order byte of x}
  xchg    ah,al           ;{ AX := 100h * y}
  shr     ax,1            ;{ AL := 80h * (y&1)}
  add     bh,al           ;{ BX := x + 8000h*(y&1)}
  xor     al,al           ;{ AX := 100h*(y/2)}
  add     bx,ax           ;{ BX := x + 8000h*(y&1) + 100h*(y/2)}
  shr     ax,1
  shr     ax,1            ;{ AX := 40h*(y/2)}
  add     bx,ax           ;{ BX := x + 8000h*(y&1) + 140h*(y/2)}
  shr     bx,1
  shr     bx,1            ;{ BX := x/4 + 2000h*(y&1) + 50h*(y/2)}
  mov     ah,3            ;{ AH := unshifted bit mask}
  and     cl,ah           ;{ CL := x & 3}
  xor     cl,ah           ;{ CL := 3 - (x & 3)}
  shl     cl,1            ;{ CL := # bits to shift left}

;  mov   al,1 ;{AH = bitmask, AL = color}
mov dx,si
and dx,1
inc dl
mov al,dl

  shl   ax,cl ;{AH = bit mask in proper position, AL = pixel value in proper position}
  not   ah ;{AH = inverse bit mask}
  and   es:[bx],ah ;{zero the pixel value}
  or    es:[bx],al ;{set the pixel value}

; ES:AX = frame buffer
; CX = X
; DX = Y
;            XOR  BX,BX
;	    TEST CL,1
;	    JZ   @CONTINUE
;	    MOV  BX,2000H
;@CONTINUE:  SHR  CX,1
;	    MOV  AL,80
;	    MUL  CL
;
;	    MOV  CX,DX
;	    NOT  CL
;	    AND  CL,00000011B
;	    SHL  CL,1
;
;	    SHR  DX,1
;	    SHR  DX,1
;
;	    ADD  AX,DX
;	    ADD  BX,AX
;
;	    MOV  AH,ES:[BX]
;	    ROR  AH,CL
;	    AND  AH,11111100B
;;;;	    MOV  AL,C
;mov dx,si
;and dx,3
;mov al,dl
;	    OR   AH,AL
;	    ROL  AH,CL
;	    MOV  ES:[BX],AH

;;;; end draw pixel

        inc si
        cmp si,dots
        je draw_frame
        jmp dots_loop

draw_frame:
;	mov  dx,03dah			; Retrace
;bettan:
;	in   al,dx
;	test al,8
;	je   bettan
;bettan2:
;	in   al,dx
;	test al,8
;	jne  bettan2

;	push ds				; Draw video buffer
;	push es
;	push es
;	pop ds	;38 ticks

mov dx,ds	;2
mov bx,es	;2
mov ds,bx	;2
	mov ax,0b800h
	mov es,ax
	xor si,si
	xor di,di
	mov cx,8000
	rep movsw
        sti
mov es,bx	;2
mov ds,dx	;2
;	pop es
;	pop ds	;16 ticks

ifdef CALC_FPS
        inc fps
        call timer
        mov timm,ax
        mov timm+2,dx

        mov ax, tim+2
        cmp ax,timm+2
        ja      IsGtr
        jb      NotGtr
        mov     ax, tim             ;Fall through to here if H.O. 
        cmp     ax, timm             ; dwords are equal.
        ja      IsGtr
NotGtr: 
	push es
	push ds
	pop es
        lea di,sfps+1
        mov dx,fps
        call word2hex
	pop es
        mov fps,0
        call timer
        mov tim,ax
        mov tim+2,dx
        mov ax, tim
        add ax, t18
        mov tim, ax
        mov ax, tim+2
        adc ax, t18+2
        mov tim+2, ax

IsGtr:
endif

					;xst1:=(xst1+xspd1)
        add xst1,4
					;yst1:=(yst1+yspd1)
        add yst1,2
					;xst2:=(xst2+xspd2)
        add xst2,2
					;yst2:=(yst2+yspd2)
        add yst2,3

        cmp dots,256
        je no_inc
        inc dots
no_inc:
        cmp c,1
	jz finish
        jmp main_loop

finish:

	mov ax,3
	int 10h
        push ds
	mov ax,2509h
	mov dx,cs:OldK
	mov ds,cs:oldK+2
	int 21h
        pop ds
        mov ah,49h                      ; release mem for buf
        int 21h
	lea dx,copyr		; Write	copyr msg
	mov ah,9
	int 21h
	int 20h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;      PROCEDURES      ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;DS:SI = pack data
;ES:DI = unpack buffer
;CX = length
depack:
        lodsb
        cmp al,090h
        je repeat
        mov bl,al		; save last data
        stosb
        loop depack
        jmp short adone
repeat:
        lodsb
        test al,al
        jz do_marker
	mov dx,cx
        xor ch,ch
        mov cl,al               ; repeat count
        mov al,bl               ; data
        rep stosb
	mov cx,dx
        loop depack
        jmp short adone
do_marker:
        mov al,090h
        mov bl,al
        stosb
        loop depack    
adone:
        ret


ifdef CALC_FPS
timer:
	push	ds		; Preserve data segment
	pushf			; Keep interrupt flag
	xor	ax,ax		; Zero
	mov	ds,ax		; Address BIOS data area
	cli			; Don't want a tick to interrupt us
	mov	ax,ds:[46Ch]	; Get loword of count
	mov	dx,ds:[46Eh]	; Get hiword of count
	popf			; Restore interrupt flag as provided
	pop	ds		; Restore data segment
	ret			; Return tick count in DX|AX

;DI = buf
byte2hex:
       push    cx
       mov     cx,2
L1:    rol     dl,4
       mov     ax,300fh
       and     al,dl
       aaa
       aad     11h
       stosb
       loop    L1
       pop     cx
       ret
word2hex:
       push    cx
       mov     cx,2
L2:    rol     dx,8
       call    byte2hex
       loop    L2
       pop     cx
       ret
endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;      DATA AREA       ;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ALIGN WORD

xst1         dw 100
xst2         dw 800
yst1         dw 300
yst2         dw 700
dots	     dw 1

stab1        db 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h, 3Ah, 3Bh, 3Bh, 3Ch
             db 3Dh, 3Eh, 3Fh, 40h, 41h, 42h, 43h, 44h, 44h, 45h, 46h, 47h
             db 48h, 48h, 49h, 4Ah, 4Bh, 4Bh, 4Ch, 4Dh, 4Eh, 4Eh, 4Fh, 50h
             db 50h, 51h, 51h, 52h, 52h, 53h, 53h, 54h, 54h, 55h, 55h, 56h
             db 56h, 56h, 57h, 57h, 57h, 58h, 58h, 58h, 58h, 58h, 59h, 59h
             db 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 58h
             db 58h, 58h, 58h, 58h, 57h, 57h, 57h, 56h, 56h, 56h, 55h, 55h
             db 54h, 54h, 53h, 53h, 52h, 52h, 51h, 51h, 50h, 50h, 4Fh, 4Eh
             db 4Eh, 4Dh, 4Ch, 4Bh, 4Bh, 4Ah, 49h, 48h, 48h, 47h, 46h, 45h
             db 44h, 44h, 43h, 42h, 41h, 40h, 3Fh, 3Eh, 3Dh, 3Ch, 3Bh, 3Bh
             db 3Ah, 39h, 38h, 37h, 36h, 35h, 34h, 33h, 32h, 31h, 30h, 2Fh
             db 2Eh, 2Dh, 2Ch, 2Bh, 2Ah, 29h, 29h, 28h, 27h, 26h, 25h, 24h
             db 23h, 22h, 21h, 20h, 20h, 1Fh, 1Eh, 1Dh, 1Ch, 1Ch, 1Bh, 1Ah
             db 19h, 19h, 18h, 17h, 16h, 16h, 15h, 14h, 14h, 13h, 13h, 12h
             db 12h, 11h, 11h, 10h, 10h, 0Fh, 0Fh, 0Eh, 0Eh, 0Eh, 0Dh, 0Dh
             db 0Dh, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh
             db 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch
             db 0Dh, 0Dh, 0Dh, 0Eh, 0Eh, 0Eh, 0Fh, 0Fh, 10h, 10h, 11h, 11h
             db 12h, 12h, 13h, 13h, 14h, 14h, 15h, 16h, 16h, 17h, 18h, 19h
             db 19h, 1Ah, 1Bh, 1Ch, 1Ch, 1Dh, 1Eh, 1Fh, 20h, 20h, 21h, 22h
             db 23h, 24h, 25h, 26h, 27h, 28h, 29h, 29h, 2Ah, 2Bh, 2Ch, 2Dh
             db 2Eh, 2Fh, 30h, 31h, 32h, 33h, 34h, 35h, 36h, 37h, 38h, 39h
             db 3Ah, 3Bh, 3Bh, 3Ch, 3Dh, 3Eh, 3Fh, 40h, 41h, 42h, 43h, 44h
             db 44h, 45h, 46h, 47h, 48h, 48h, 49h, 4Ah, 4Bh, 4Bh, 4Ch, 4Dh
             db 4Eh, 4Eh, 4Fh, 50h, 50h, 51h, 51h, 52h, 52h, 53h, 53h, 54h
             db 54h, 55h, 55h, 56h, 56h, 56h, 57h, 57h, 57h, 58h, 58h, 58h
             db 58h, 58h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h, 59h
             db 59h, 59h, 59h, 58h, 58h, 58h, 58h, 58h, 57h, 57h, 57h, 56h
             db 56h, 56h, 55h, 55h, 54h, 54h, 53h, 53h, 52h, 52h, 51h, 51h
             db 50h, 50h, 4Fh, 4Eh, 4Eh, 4Dh, 4Ch, 4Bh, 4Bh, 4Ah, 49h, 48h
             db 48h, 47h, 46h, 45h, 44h, 44h, 43h, 42h, 41h, 40h, 3Fh, 3Eh
             db 3Dh, 3Ch, 3Bh, 3Bh, 3Ah, 39h, 38h, 37h, 36h, 35h, 34h, 33h
             db 32h, 31h, 30h, 2Fh, 2Eh, 2Dh, 2Ch, 2Bh, 2Ah, 29h, 29h, 28h
             db 27h, 26h, 25h, 24h, 23h, 22h, 21h, 20h, 20h, 1Fh, 1Eh, 1Dh
             db 1Ch, 1Ch, 1Bh, 1Ah, 19h, 19h, 18h, 17h, 16h, 16h, 15h, 14h
             db 14h, 13h, 13h, 12h, 12h, 11h, 11h, 10h, 10h, 0Fh, 0Fh, 0Eh
             db 0Eh, 0Eh, 0Dh, 0Dh, 0Dh, 0Ch, 0Ch, 0Ch, 0Ch, 0Ch, 0Bh, 0Bh
             db 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Bh, 0Ch
             db 0Ch, 0Ch, 0Ch, 0Ch, 0Dh, 0Dh, 0Dh, 0Eh, 0Eh, 0Eh, 0Fh, 0Fh
             db 10h, 10h, 11h, 11h, 12h, 12h, 13h, 13h, 14h, 14h, 15h, 16h
             db 16h, 17h, 18h, 19h, 19h, 1Ah, 1Bh, 1Ch, 1Ch, 1Dh, 1Eh, 1Fh
             db 20h, 20h, 21h, 22h, 23h, 24h, 25h, 26h, 27h, 28h, 29h, 29h
             db 2Ah, 2Bh, 2Ch, 2Dh, 2Eh, 2Fh, 30h, 31h

stab2        db 32h, 33h, 33h, 34h, 35h, 36h, 36h, 37h, 38h, 38h, 39h, 3Ah
             db 3Ah, 3Bh, 3Ch, 3Ch, 3Dh, 3Eh, 3Eh, 3Fh, 40h, 40h, 41h, 42h
             db 42h, 43h, 43h, 44h, 44h, 45h, 45h, 46h, 47h, 47h, 47h, 48h
             db 48h, 49h, 49h, 4Ah, 4Ah, 4Bh, 4Bh, 4Bh, 4Ch, 4Ch, 4Ch, 4Dh
             db 4Dh, 4Dh, 4Dh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Fh, 4Fh, 4Fh
             db 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh
             db 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Dh, 4Dh, 4Dh, 4Dh, 4Ch, 4Ch
             db 4Ch, 4Bh, 4Bh, 4Bh, 4Ah, 4Ah, 49h, 49h, 48h, 48h, 47h, 47h
             db 47h, 46h, 45h, 45h, 44h, 44h, 43h, 43h, 42h, 42h, 41h, 40h
             db 40h, 3Fh, 3Eh, 3Eh, 3Dh, 3Ch, 3Ch, 3Bh, 3Ah, 3Ah, 39h, 38h
             db 38h, 37h, 36h, 36h, 35h, 34h, 33h, 33h, 32h, 31h, 31h, 30h
             db 2Fh, 2Eh, 2Eh, 2Dh, 2Ch, 2Ch, 2Bh, 2Ah, 2Ah, 29h, 28h, 28h
             db 27h, 26h, 26h, 25h, 24h, 24h, 23h, 22h, 22h, 21h, 21h, 20h
             db 20h, 1Fh, 1Fh, 1Eh, 1Dh, 1Dh, 1Dh, 1Ch, 1Ch, 1Bh, 1Bh, 1Ah
             db 1Ah, 19h, 19h, 19h, 18h, 18h, 18h, 17h, 17h, 17h, 17h, 16h
             db 16h, 16h, 16h, 16h, 16h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
             db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 16h, 16h, 16h, 16h
             db 16h, 16h, 17h, 17h, 17h, 17h, 18h, 18h, 18h, 19h, 19h, 19h
             db 1Ah, 1Ah, 1Bh, 1Bh, 1Ch, 1Ch, 1Dh, 1Dh, 1Dh, 1Eh, 1Fh, 1Fh
             db 20h, 20h, 21h, 21h, 22h, 22h, 23h, 24h, 24h, 25h, 26h, 26h
             db 27h, 28h, 28h, 29h, 2Ah, 2Ah, 2Bh, 2Ch, 2Ch, 2Dh, 2Eh, 2Eh
             db 2Fh, 30h, 31h, 31h, 32h, 33h, 33h, 34h, 35h, 36h, 36h, 37h
             db 38h, 38h, 39h, 3Ah, 3Ah, 3Bh, 3Ch, 3Ch, 3Dh, 3Eh, 3Eh, 3Fh
             db 40h, 40h, 41h, 42h, 42h, 43h, 43h, 44h, 44h, 45h, 45h, 46h
             db 47h, 47h, 47h, 48h, 48h, 49h, 49h, 4Ah, 4Ah, 4Bh, 4Bh, 4Bh
             db 4Ch, 4Ch, 4Ch, 4Dh, 4Dh, 4Dh, 4Dh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh
             db 4Eh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh, 4Fh
             db 4Fh, 4Fh, 4Fh, 4Fh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Eh, 4Dh, 4Dh
             db 4Dh, 4Dh, 4Ch, 4Ch, 4Ch, 4Bh, 4Bh, 4Bh, 4Ah, 4Ah, 49h, 49h
             db 48h, 48h, 47h, 47h, 47h, 46h, 45h, 45h, 44h, 44h, 43h, 43h
             db 42h, 42h, 41h, 40h, 40h, 3Fh, 3Eh, 3Eh, 3Dh, 3Ch, 3Ch, 3Bh
             db 3Ah, 3Ah, 39h, 38h, 38h, 37h, 36h, 36h, 35h, 34h, 33h, 33h
             db 32h, 31h, 31h, 30h, 2Fh, 2Eh, 2Eh, 2Dh, 2Ch, 2Ch, 2Bh, 2Ah
             db 2Ah, 29h, 28h, 28h, 27h, 26h, 26h, 25h, 24h, 24h, 23h, 22h
             db 22h, 21h, 21h, 20h, 20h, 1Fh, 1Fh, 1Eh, 1Dh, 1Dh, 1Dh, 1Ch
             db 1Ch, 1Bh, 1Bh, 1Ah, 1Ah, 19h, 19h, 19h, 18h, 18h, 18h, 17h
             db 17h, 17h, 17h, 16h, 16h, 16h, 16h, 16h, 16h, 15h, 15h, 15h
             db 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h, 15h
             db 16h, 16h, 16h, 16h, 16h, 16h, 17h, 17h, 17h, 17h, 18h, 18h
             db 18h, 19h, 19h, 19h, 1Ah, 1Ah, 1Bh, 1Bh, 1Ch, 1Ch, 1Dh, 1Dh
             db 1Dh, 1Eh, 1Fh, 1Fh, 20h, 20h, 21h, 21h, 22h, 22h, 23h, 24h
             db 24h, 25h, 26h, 26h, 27h, 28h, 28h, 29h, 2Ah, 2Ah, 2Bh, 2Ch
             db 2Ch, 2Dh, 2Eh, 2Eh, 2Fh, 30h, 31h, 31h


packpic1     db 000h, 090h, 0FCh, 00Ah, 0AAh, 0A8h, 000h, 090h, 04Bh, 00Fh
             db 0FFh, 0FFh, 0E3h, 0FFh, 0FCh, 000h, 090h, 020h, 03Fh, 000h
             db 000h, 030h, 000h, 090h, 009h, 030h, 00Fh, 000h, 090h, 017h
             db 02Ah, 082h, 0FFh, 0FFh, 02Fh, 0FFh, 0FFh, 0FAh, 000h, 090h
             db 01Eh, 033h, 003h, 0C0h, 0C0h, 000h, 003h, 0F0h, 000h, 030h
             db 00Ch, 030h, 00Ch, 030h, 0F0h, 003h, 0C0h, 00Ch, 000h, 090h
             db 018h, 0BFh, 0FFh, 0FEh, 0BFh, 0FFh, 0FFh, 0FFh, 0C0h, 000h
             db 090h, 01Dh, 03Ch, 00Ch, 000h, 0C0h, 000h, 00Ch, 0C0h, 000h
             db 000h, 0C0h, 000h, 0C0h, 0C0h, 0F0h, 00Fh, 000h, 030h, 0F0h
             db 0FFh, 0F0h, 000h, 090h, 014h, 02Fh, 0FFh, 0FFh, 0F2h, 0FFh
             db 090h, 004h, 080h, 000h, 090h, 01Ch, 0CCh, 00Fh, 003h, 000h
             db 000h, 0C0h, 0C0h, 000h, 003h, 000h, 003h, 000h, 003h, 030h
             db 0C3h, 000h, 0F0h, 030h, 003h, 000h, 090h, 014h, 002h, 0FFh
             db 0FFh, 0FFh, 0C8h, 0BFh, 0C2h, 0FFh, 0FFh, 0FFh, 0F0h, 000h
             db 090h, 01Bh, 003h, 00Ch, 000h, 003h, 000h, 000h, 003h, 000h
             db 000h, 03Ch, 000h, 03Ch, 000h, 003h, 00Ch, 00Ch, 000h, 0C0h
             db 0C0h, 0F0h, 030h, 000h, 090h, 013h, 00Ah, 0FFh, 0FFh, 0FEh
             db 00Ah, 0AAh, 0ABh, 023h, 0FFh, 0E2h, 0AAh, 000h, 090h, 01Bh
             db 030h, 00Fh, 0C0h, 03Fh, 0F0h, 000h, 00Ch, 000h, 0C0h, 030h
             db 000h, 030h, 000h, 00Ch, 000h, 03Fh, 0C3h, 000h, 0FFh, 0FFh
             db 0C0h, 000h, 090h, 013h, 0AAh, 0FFh, 0FFh, 0FCh, 0AAh, 0AAh
             db 0A8h, 0F8h, 000h, 03Ch, 002h, 0ACh, 000h, 090h, 042h, 00Ah
             db 0AAh, 0FFh, 0FFh, 0F0h, 00Ah, 0AAh, 08Fh, 0C0h, 000h, 00Fh
             db 002h, 0ABh, 080h, 000h, 090h, 041h, 00Ah, 0AAh, 0AFh, 0FFh
             db 0C0h, 000h, 002h, 0FCh, 000h, 000h, 002h, 0C0h, 0AAh, 0C0h
             db 000h, 090h, 041h, 02Ah, 0AAh, 0AAh, 0ABh, 0CFh, 0FFh, 0FFh
             db 08Bh, 0FFh, 0FFh, 0FEh, 02Ch, 00Ah, 0F0h, 000h, 090h, 041h
             db 0AAh, 090h, 003h, 000h, 000h, 00Fh, 0FBh, 0FFh, 0AFh, 0FFh
             db 0F0h, 0C0h, 0B0h, 000h, 090h, 041h, 0AAh, 090h, 003h, 000h
             db 0FFh, 0FBh, 0EAh, 0A0h, 08Fh, 0FFh, 0FEh, 0E2h, 0C0h, 000h
             db 090h, 03Fh, 00Fh, 0D7h, 0FFh, 0FFh, 0FFh, 0FEh, 00Ah, 0AAh
             db 080h, 000h, 0AAh, 03Fh, 0FFh, 0A2h, 02Fh, 0C0h, 000h, 090h
             db 040h, 0A8h, 0A0h, 00Fh, 0FFh, 0FEh, 000h, 028h, 083h, 0E8h
             db 00Ah, 02Ah, 0A0h, 000h, 00Fh, 0F0h, 000h, 090h, 040h, 002h
             db 0AAh, 0AAh, 003h, 0FEh, 0A8h, 0ABh, 0FFh, 0EAh, 0F0h, 000h
             db 02Ah, 0ABh, 0CAh, 0BCh, 000h, 090h, 040h, 00Ah, 080h, 02Ah
             db 0AAh, 08Eh, 0A8h, 0ABh, 0FFh, 0EAh, 0BFh, 0FFh, 0FFh, 0EAh
             db 0F0h, 0AEh, 0BFh, 0FAh, 0FCh, 000h, 090h, 03Dh, 00Ah, 0AAh
             db 02Ah, 0AAh, 0AAh, 022h, 0ABh, 0FFh, 0EAh, 0AFh, 0FFh, 0FFh
             db 0EAh, 0BAh, 02Ah, 0B8h, 0AAh, 0B0h, 000h, 090h, 03Dh, 00Ah
             db 0AAh, 0A8h, 00Ah, 0AAh, 0A2h, 0ABh, 0FFh, 0FAh, 0BFh, 0FFh
             db 0FFh, 0EAh, 0FFh, 00Ah, 0AAh, 0A0h, 000h, 090h, 03Eh, 002h
             db 0AAh, 0AAh, 0A8h, 02Ah, 02Ah, 0AAh, 0FFh, 0FFh, 0FFh, 0F8h
             db 028h, 0BFh, 0FEh, 020h, 0A8h, 000h, 090h, 03Fh, 002h, 0AAh
             db 0AAh, 0AAh, 0A2h, 0E2h, 0AAh, 0FFh, 0CFh, 0FFh, 090h, 003h
             db 0FCh, 0A8h, 008h, 000h, 090h, 040h, 0AAh, 0AAh, 0AAh, 0A3h
             db 0F0h, 0AAh, 0F0h, 0FEh, 000h, 02Ah, 003h, 0FFh, 0CAh, 000h
             db 090h, 042h, 02Ah, 0AAh, 0AAh, 0AFh, 0F2h, 08Ah, 0AFh, 0FBh
             db 08Fh, 0FAh, 0A8h, 0FEh, 000h, 090h, 043h, 00Ah, 0AAh, 0AAh
             db 08Ah, 0CAh, 0AAh, 02Bh, 0FFh, 0F2h, 0BFh, 00Fh, 0F8h, 000h
             db 090h, 043h, 002h, 0AAh, 0A8h, 0AAh, 0AAh, 0AAh, 0A0h, 0BFh
             db 0FFh, 08Ah, 0FCh, 008h, 0A8h, 000h, 090h, 043h, 02Ah, 0AAh
             db 090h, 003h, 0A8h, 0A0h, 02Fh, 0F8h, 02Ah, 0A9h, 000h, 090h
             db 045h, 0AAh, 02Ah, 0AAh, 0AAh, 0A8h, 0AFh, 0FEh, 02Ah, 0AAh
             db 0A0h, 000h, 090h, 045h, 00Ah, 080h, 0AAh, 0AAh, 0A8h, 080h
             db 0B8h, 0CAh, 0AAh, 0AAh, 0A0h, 000h, 090h, 045h, 020h, 000h
             db 0AAh, 0A2h, 0BFh, 0FFh, 0FAh, 0AAh, 0A8h, 000h, 090h, 049h
             db 003h, 0FFh, 0FFh, 0FFh, 028h, 000h, 090h, 04Ah, 02Fh, 0FFh
             db 0FFh, 0FFh, 0F0h, 000h, 090h, 049h, 003h, 0FFh, 090h, 003h
             db 0FCh, 080h, 000h, 090h, 047h, 026h, 0BEh, 0FFh, 090h, 004h
             db 0C0h, 000h, 090h, 047h, 01Ah, 099h, 0A5h, 0AAh, 0FFh, 0FFh
             db 0FFh, 0FEh, 000h, 090h, 047h, 096h, 05Ah, 0AAh, 09Ah, 0AAh
             db 0AAh, 099h, 0A5h, 080h, 000h, 090h, 046h, 06Ah, 06Ah, 0AAh
             db 06Ah, 0A9h, 08Ah, 0AAh, 0AAh, 040h, 000h, 090h, 045h, 002h
             db 06Ah, 050h, 026h, 09Ah, 0AAh, 049h, 0AAh, 0A9h, 040h, 000h
             db 090h, 045h, 009h, 095h, 000h, 029h, 0A9h, 065h, 00Ah, 059h
             db 054h, 000h, 090h, 046h, 026h, 094h, 000h, 001h, 055h, 040h
             db 026h, 000h, 090h, 048h, 099h, 040h, 000h, 000h, 000h, 00Ah
             db 0AAh, 0AAh, 0FFh, 000h, 090h, 045h, 002h, 055h, 000h, 000h
             db 005h, 05Ah, 0A9h, 0AAh, 0A2h, 0FFh, 0C0h, 000h, 090h, 044h
             db 009h, 094h, 000h, 000h, 000h, 05Ah, 065h, 0AAh, 0A2h, 0FFh
             db 0F0h, 000h, 090h, 044h, 029h, 050h, 000h, 000h, 000h, 005h
             db 0A6h, 0AAh, 0A2h, 0BFh, 0FEh, 000h, 090h, 044h, 09Ah, 040h
             db 000h, 000h, 000h, 001h, 05Ah, 0AAh, 0A0h, 0ABh, 0FFh, 080h
             db 000h, 090h, 042h, 00Ah, 095h, 000h, 000h, 000h, 028h, 000h
             db 06Ah, 0AAh, 0A3h, 0AAh, 0FFh, 0F0h, 000h, 090h, 042h, 029h
             db 095h, 000h, 000h, 003h, 0FFh, 03Fh, 0C0h, 0A6h, 080h, 00Bh
             db 02Fh, 0FFh, 000h, 090h, 042h, 095h, 094h, 000h, 000h, 0BFh
             db 00Ah, 0BFh, 0FFh, 0CAh, 0A3h, 0EAh, 0A8h, 0BFh, 080h, 000h
             db 090h, 040h, 001h, 0A9h, 050h, 000h, 002h, 0BFh, 000h, 002h
             db 0AAh, 08Ah, 0A2h, 002h, 02Fh, 0C3h, 0E0h, 000h, 090h, 040h
             db 026h, 069h, 040h, 000h, 002h, 0A0h, 000h, 056h, 0AAh, 090h
             db 003h, 092h, 0AAh, 0BEh, 000h, 090h, 03Fh, 002h, 0A9h, 069h
             db 000h, 090h, 003h, 005h, 0AAh, 090h, 004h, 0A6h, 002h, 0FFh
             db 0C0h, 000h, 090h, 03Eh, 016h, 09Ah, 0A5h, 000h, 090h, 003h
             db 056h, 0AAh, 090h, 004h, 0A5h, 060h, 0AFh, 0F8h, 000h, 090h
             db 03Dh, 001h, 069h, 09Ah, 054h, 000h, 000h, 000h, 009h, 05Ah
             db 0AAh, 0A9h, 0AAh, 0AAh, 0AAh, 09Ah, 095h, 00Bh, 0FFh, 080h
             db 000h, 090h, 03Ch, 006h, 0AAh, 0A6h, 050h, 000h, 000h, 000h
             db 055h, 0AAh, 0AAh, 096h, 0AAh, 096h, 0A0h, 000h, 000h, 000h
             db 0FFh, 0BAh, 000h, 090h, 03Bh, 001h, 06Ah, 06Ah, 0AAh, 040h
             db 000h, 000h, 002h, 056h, 0AAh, 0AAh, 0A5h, 060h, 000h, 0ABh
             db 080h, 000h, 0AAh, 0A8h, 0AFh, 0FCh, 000h, 090h, 03Ah, 026h
             db 0A6h, 09Ah, 0A5h, 040h, 000h, 090h, 005h, 00Ah, 0A0h, 01Ah
             db 0AAh, 0CAh, 0AAh, 0AAh, 02Fh, 0A2h, 0AFh, 0C0h, 000h, 090h
             db 038h, 00Fh, 0C9h, 069h, 06Ah, 055h, 000h, 090h, 004h, 02Ah
             db 0AAh, 0ABh, 000h, 0AAh, 0AAh, 0CAh, 0AAh, 080h, 0AFh, 0FFh
             db 08Ah, 000h, 090h, 038h, 0AFh, 0FEh, 082h, 009h, 0AAh, 054h
             db 000h, 090h, 003h, 002h, 0AAh, 0AAh, 0BCh, 000h, 0AAh, 0AAh
             db 0CAh, 08Ah, 0A0h, 002h, 0FFh, 0FEh, 000h, 090h, 038h, 02Fh
             db 0A2h, 0FFh, 0F8h, 02Ah, 064h, 000h, 090h, 003h, 02Ah, 0AAh
             db 0ABh, 0F0h, 002h, 0AAh, 0AAh, 0F3h, 0FFh, 080h, 000h, 02Fh
             db 0FFh, 0F0h, 000h, 090h, 037h, 008h, 0BFh, 0FFh, 0FAh, 002h
             db 0BFh, 0F0h, 000h, 000h, 000h, 0AAh, 0AAh, 0AFh, 080h, 002h
             db 0AAh, 0AAh, 0F3h, 0FFh, 080h, 000h, 00Ah, 0BEh, 000h, 090h
             db 038h, 00Fh, 0FFh, 0FFh, 080h, 000h, 0BFh, 0F0h, 000h, 000h
             db 002h, 0AAh, 0AAh, 0FEh, 000h, 002h, 0AAh, 000h, 003h, 0FEh
             db 000h, 000h, 000h, 020h, 000h, 090h, 038h, 00Bh, 0FFh, 0E0h
             db 000h, 000h, 0BFh, 0FCh, 000h, 000h, 002h, 0AAh, 0ABh, 0F0h
             db 000h, 000h, 02Ah, 0AAh, 0FCh, 0FEh, 000h, 090h, 03Dh, 0A8h
             db 000h, 000h, 000h, 0BFh, 0FEh, 000h, 0AAh, 0FFh, 08Ah, 0AFh
             db 0C0h, 000h, 002h, 0AAh, 0AAh, 0AEh, 0BCh, 000h, 090h, 041h
             db 02Fh, 0FEh, 002h, 0ABh, 0FFh, 0FEh, 0BFh, 000h, 000h, 002h
             db 04Ah, 0FFh, 0FEh, 000h, 090h, 042h, 02Bh, 000h, 00Ah, 0AFh
             db 0FFh, 0FFh, 0CEh, 000h, 000h, 003h, 0FFh, 0FFh, 0FFh, 080h
             db 000h, 090h, 043h, 02Ah, 0BFh, 0FFh, 0FFh, 0F0h, 000h, 000h
             db 0AAh, 0FFh, 0FFh, 0FFh, 0C0h, 000h, 090h, 043h, 0ABh, 0FFh
             db 0FFh, 0FFh, 0C0h, 000h, 000h, 0ABh, 0FFh, 0FFh, 0FFh, 0F0h
             db 000h, 090h, 042h, 002h, 0AFh, 0FFh, 0FFh, 0FFh, 0C0h, 000h
             db 000h, 0ABh, 0FFh, 0FFh, 0FFh, 0F2h, 000h, 090h, 042h, 00Ah
             db 0FFh, 090h, 003h, 080h, 000h, 000h, 0ABh, 0FFh, 0FFh, 0FFh
             db 0FCh, 000h, 090h, 042h, 0ABh, 0FFh, 0FFh, 0FFh, 0FEh, 000h
             db 000h, 000h, 0ABh, 0FFh, 0FFh, 0FFh, 0FEh, 080h, 000h, 090h
             db 041h, 0AFh, 0FFh, 0FFh, 0FFh, 0F8h, 000h, 000h, 000h, 0ABh
             db 0FFh, 090h, 003h, 0C0h, 000h, 090h, 040h, 00Ah, 0BFh, 0FFh
             db 0FFh, 0FFh, 0F0h, 000h, 000h, 000h, 0ABh, 0FFh, 090h, 003h
             db 0E0h, 000h, 090h, 040h, 0AAh, 0FFh, 090h, 003h, 0C0h, 000h
             db 000h, 000h, 0ABh, 0FFh, 090h, 003h, 0F0h, 000h, 090h, 03Fh
             db 002h, 0AFh, 0FFh, 090h, 003h, 0C0h, 000h, 000h, 000h, 0ABh
             db 0FFh, 0FFh, 081h, 066h, 040h, 000h, 090h, 03Fh, 02Ah, 0BFh
             db 0FFh, 090h, 003h, 080h, 000h, 000h, 002h, 0AAh, 0FFh, 0C2h
             db 05Ah, 096h, 066h, 000h, 090h, 03Fh, 0AAh, 0FFh, 090h, 003h
             db 0FEh, 000h, 000h, 000h, 002h, 0AAh, 0A0h, 0A5h, 0AAh, 0AAh
             db 0AAh, 080h, 000h, 090h, 03Eh, 0ABh, 0FFh, 090h, 003h, 0FEh
             db 000h, 000h, 000h, 002h, 0A8h, 066h, 09Ah, 0AAh, 0AAh, 0AAh
             db 0A0h, 000h, 090h, 03Eh, 054h, 03Fh, 0FFh, 0FFh, 0FFh, 0FEh
             db 000h, 000h, 000h, 00Ah, 085h, 056h, 0AAh, 090h, 003h, 0A4h
             db 000h, 090h, 03Dh, 005h, 055h, 068h, 0FFh, 0FFh, 0FFh, 0FEh
             db 000h, 090h, 003h, 056h, 0AAh, 090h, 004h, 0A9h, 000h, 090h
             db 03Dh, 056h, 0A6h, 0A9h, 09Ah, 0FFh, 0FFh, 0FCh, 000h, 090h
             db 003h, 05Ah, 0AAh, 090h, 005h, 0A0h, 000h, 090h, 03Bh, 005h
             db 069h, 0AAh, 0A9h, 06Ah, 02Fh, 0FFh, 0F8h, 000h, 090h, 003h
             db 059h, 0AAh, 090h, 004h, 0A6h, 068h, 000h, 090h, 03Bh, 055h
             db 0AAh, 090h, 003h, 0A2h, 0FFh, 0F0h, 000h, 090h, 003h, 056h
             db 0AAh, 090h, 006h, 000h, 090h, 03Ah, 001h, 05Ah, 0AAh, 090h
             db 004h, 02Fh, 0F0h, 000h, 090h, 003h, 059h, 0AAh, 090h, 006h
             db 040h, 000h, 090h, 039h, 015h, 06Ah, 0AAh, 090h, 003h, 0A9h
             db 062h, 0F0h, 000h, 090h, 003h, 056h, 0AAh, 090h, 006h, 058h
             db 000h, 090h, 038h, 001h, 059h, 06Ah, 0AAh, 06Ah, 0AAh, 0AAh
             db 0A9h, 0AAh, 030h, 000h, 090h, 003h, 015h, 0AAh, 090h, 006h
             db 04Fh, 000h, 090h, 038h, 005h, 06Ah, 0AAh, 090h, 006h, 0A0h
             db 000h, 000h, 0BFh, 0FFh, 0C5h, 069h, 0AAh, 090h, 003h, 09Ah
             db 0A3h, 0FFh, 0FEh, 000h, 090h, 035h, 00Bh, 0E0h, 015h, 0AAh
             db 090h, 007h, 0A8h, 000h, 002h, 0FFh, 0FFh, 0FCh, 05Ah, 0AAh
             db 090h, 003h, 098h, 0FFh, 0FFh, 0FFh, 080h, 000h, 090h, 034h
             db 03Fh, 0FEh, 015h, 0AAh, 0A6h, 0AAh, 090h, 005h, 080h, 000h
             db 003h, 0FFh, 0FFh, 0FFh, 0C6h, 0AAh, 090h, 003h, 08Fh, 0FFh
             db 0FFh, 0FAh, 0C0h, 000h, 090h, 02Ah, 030h, 000h, 090h, 008h
             db 0FFh, 0FFh, 0F2h, 0A5h, 0AAh, 090h, 005h, 062h, 0FFh, 000h
             db 002h, 0AFh, 0FFh, 0FFh, 0FCh, 0AAh, 0AAh, 0AAh, 0A2h, 0FFh
             db 0FFh, 0FFh, 0AAh, 0A0h, 000h, 090h, 00Ch, 00Ch, 003h, 00Fh
             db 003h, 0C0h, 03Ch, 03Ch, 000h, 003h, 0C3h, 003h, 003h, 000h
             db 0C3h, 0C0h, 000h, 00Ch, 00Ch, 003h, 00Fh, 003h, 00Fh, 000h
             db 000h, 0FCh, 000h, 090h, 004h, 0C0h, 000h, 090h, 008h, 0AFh
             db 0FFh, 0FFh, 02Ah, 09Ah, 0AAh, 090h, 003h, 0A5h, 02Fh, 0FFh
             db 0C0h, 000h, 0AAh, 0ABh, 0FFh, 090h, 007h, 0FEh, 0AAh, 0A8h
             db 000h, 090h, 00Ch, 0C0h, 003h, 030h, 000h, 0C0h, 033h, 0CCh
             db 000h, 000h, 00Ch, 000h, 003h, 003h, 000h, 0C3h, 0C3h, 0C0h
             db 00Ch, 00Ch, 003h, 00Ch, 003h, 000h, 003h, 030h, 000h, 000h
             db 0FCh, 03Fh, 003h, 000h, 0FCh, 00Ch, 0C0h, 000h, 090h, 005h
             db 0AAh, 0FFh, 0FFh, 0F1h, 0AAh, 090h, 005h, 0FFh, 0FFh, 0C0h
             db 000h, 000h, 02Ah, 0AFh, 0FFh, 090h, 006h, 0AAh, 0AAh, 0A8h
             db 000h, 090h, 00Bh, 003h, 000h, 000h, 0C0h, 000h, 000h, 00Ch
             db 030h, 000h, 000h, 003h, 000h, 030h, 00Ch, 000h, 0C0h, 0C0h
             db 000h, 0C0h, 030h, 003h, 030h, 003h, 000h, 030h, 030h, 000h
             db 00Ch, 003h, 000h, 0C3h, 00Ch, 003h, 0CFh, 000h, 090h, 006h
             db 0AAh, 0BFh, 0FFh, 0FFh, 0E2h, 0AAh, 0AAh, 06Ah, 09Ah, 08Fh
             db 0FFh, 0FEh, 080h, 000h, 090h, 003h, 00Ah, 0FAh, 0AAh, 0AAh
             db 0BFh, 0FEh, 0AAh, 080h, 000h, 090h, 00Dh, 003h, 000h, 000h
             db 0C0h, 00Ch, 000h, 030h, 030h, 000h, 000h, 00Ch, 003h, 000h
             db 00Ch, 003h, 003h, 0F0h, 00Ch, 000h, 030h, 00Ch, 030h, 00Ch
             db 000h, 000h, 0C0h, 000h, 030h, 003h, 003h, 00Ch, 03Ch, 00Ch
             db 00Ch, 000h, 090h, 006h, 02Ah, 0ABh, 0FFh, 0FFh, 0FFh, 0F0h
             db 002h, 059h, 0A2h, 0FFh, 0FFh, 0E0h, 000h, 090h, 01Ah, 003h
             db 000h, 030h, 03Fh, 0F0h, 003h, 000h, 03Fh, 000h, 03Fh, 0C0h
             db 03Fh, 0F0h, 003h, 0F0h, 0F0h, 030h, 0FFh, 0C0h, 00Fh, 0C0h
             db 00Fh, 0C0h, 000h, 003h, 000h, 000h, 03Fh, 000h, 0FCh, 00Fh
             db 003h, 0F0h, 030h, 000h, 090h, 007h, 02Ah, 0ABh, 0FFh, 090h
             db 006h, 0F8h, 000h, 090h, 01Ch, 03Fh, 000h, 000h, 030h, 0FCh
             db 000h, 090h, 009h, 00Ch, 030h, 000h, 090h, 018h, 02Ah, 0ABh
             db 0FFh, 090h, 004h, 0A8h, 000h, 090h, 01Fh, 030h, 0C0h, 000h
             db 090h, 027h, 002h, 0AAh, 0AAh, 0AAh, 000h, 090h, 0FFh, 090h
             db 0FFh, 090h, 0A4h, 0BBh, 0BBh, 0B8h, 0BBh, 080h, 000h, 090h
             db 030h, 0F0h, 000h, 090h, 016h, 002h, 0FBh, 0BBh, 0FBh, 08Bh
             db 0FBh, 0BBh, 0A0h, 000h, 090h, 01Dh, 00Fh, 0F0h, 0F0h, 03Fh
             db 0FFh, 0C0h, 000h, 0F0h, 000h, 00Fh, 0FFh, 00Fh, 0FFh, 00Fh
             db 0C0h, 000h, 0C0h, 00Ch, 000h, 090h, 018h, 02Bh, 0BBh, 0BAh
             db 0BBh, 090h, 003h, 000h, 090h, 01Eh, 033h, 00Ch, 000h, 0C0h
             db 000h, 00Fh, 030h, 000h, 000h, 030h, 000h, 030h, 0C0h, 0F0h
             db 00Fh, 0C0h, 030h, 000h, 090h, 017h, 00Bh, 0BBh, 0FBh, 0B8h
             db 0FBh, 0BBh, 0FBh, 0BBh, 0F8h, 000h, 090h, 01Dh, 030h, 00Ch
             db 003h, 000h, 000h, 030h, 0C0h, 000h, 003h, 000h, 003h, 000h
             db 0F0h, 0F0h, 033h, 000h, 03Fh, 030h, 0C0h, 0F0h, 000h, 090h
             db 014h, 0BBh, 0BBh, 0BBh, 0B3h, 080h, 02Bh, 0BBh, 0BBh, 0BBh
             db 080h, 000h, 090h, 01Ch, 0CCh, 000h, 003h, 000h, 003h, 0FFh
             db 0FCh, 000h, 00Ch, 000h, 00Ch, 000h, 003h, 00Fh, 00Ch, 000h
             db 0C0h, 0C0h, 00Ch, 000h, 090h, 014h, 023h, 0BBh, 0FBh, 0FBh
             db 082h, 0ABh, 0F8h, 02Bh, 0FBh, 0BBh, 0FFh, 000h, 090h, 01Bh
             db 00Ch, 00Ch, 000h, 00Ch, 000h, 000h, 003h, 000h, 0C0h, 030h
             db 000h, 030h, 000h, 00Ch, 00Ch, 00Ch, 003h, 000h, 0CFh, 000h
             db 030h, 000h, 090h, 013h, 0AAh, 0BBh, 0BBh, 0BAh, 02Ah, 0AAh
             db 0AAh, 038h, 000h, 038h, 002h, 080h, 000h, 090h, 019h, 00Fh
             db 0C0h, 000h, 090h, 005h, 00Fh, 000h, 090h, 003h, 003h, 0F0h
             db 000h, 090h, 019h, 008h, 0AAh, 0FBh, 0BBh, 0F8h, 02Ah, 0AAh
             db 0A2h, 0F0h, 000h, 03Eh, 00Ah, 0ABh, 000h, 090h, 042h, 002h
             db 0AAh, 0BBh, 0BBh, 0B0h, 000h, 000h, 03Bh, 000h, 000h, 003h
             db 080h, 0AAh, 080h, 000h, 090h, 041h, 00Ah, 0AAh, 0AAh, 0FBh
             db 08Ah, 0AAh, 0AFh, 0E0h, 03Bh, 0FBh, 0F8h, 0E0h, 02Ah, 0E0h
             db 000h, 090h, 041h, 02Ah, 0AAh, 0AAh, 0AAh, 08Bh, 0BAh, 0A0h
             db 0BBh, 090h, 003h, 08Bh, 000h, 0B0h, 000h, 090h, 041h, 0AAh
             db 090h, 003h, 000h, 03Bh, 0F0h, 000h, 0AAh, 0ABh, 0FBh, 0BAh
             db 000h, 090h, 041h, 00Bh, 090h, 000h, 000h, 090h, 003h, 003h
             db 0BAh, 0B0h, 02Ah, 00Ah, 08Bh, 0BBh, 080h, 0B8h, 000h, 090h
             db 040h, 00Ah, 0BAh, 0ABh, 0FBh, 0FBh, 0FBh, 0AAh, 0A8h, 002h
             db 080h, 02Ah, 03Bh, 0FAh, 080h, 00Bh, 0E0h, 000h, 090h, 040h
             db 00Ah, 0AAh, 0A0h, 0BBh, 0BAh, 02Ah, 0ABh, 08Fh, 0AAh, 088h
             db 0AAh, 088h, 02Ah, 00Bh, 0B0h, 000h, 090h, 040h, 008h, 02Ah
             db 0AAh, 0A8h, 0BAh, 0A8h, 0ABh, 0FFh, 0AAh, 0F8h, 0BBh, 0EBh
             db 0ABh, 0CAh, 0B8h, 0AAh, 0A0h, 0A0h, 000h, 090h, 03Dh, 00Ah
             db 0A8h, 02Ah, 0AAh, 0A0h, 028h, 0ABh, 0BFh, 0AAh, 0AFh, 0BBh
             db 0BBh, 0AAh, 0B8h, 0AAh, 0BBh, 083h, 0B0h, 000h, 090h, 03Dh
             db 00Ah, 0AAh, 080h, 0AAh, 0AAh, 082h, 0ABh, 0FBh, 0FAh, 0AFh
             db 0FBh, 0FBh, 0EAh, 0BAh, 00Ah, 002h, 0AAh, 000h, 090h, 03Eh
             db 002h, 0AAh, 0AAh, 0A2h, 0AAh, 0A2h, 0AAh, 0BBh, 0FFh, 0FFh
             db 0BBh, 083h, 0FAh, 0FBh, 022h, 0AAh, 000h, 090h, 03Fh, 002h
             db 0AAh, 0AAh, 0AAh, 002h, 08Ah, 0AAh, 0FBh, 0BBh, 0FBh, 0ABh
             db 0FAh, 0BFh, 0FAh, 0A8h, 0A0h, 000h, 090h, 040h, 0AAh, 0AAh
             db 0AAh, 0A3h, 0B2h, 0AAh, 0BBh, 0ABh, 0BBh, 0C2h, 0FBh, 08Bh
             db 022h, 0A0h, 000h, 090h, 041h, 0AAh, 0AAh, 0AAh, 0ABh, 0F2h
             db 02Ah, 0B2h, 0FBh, 02Fh, 0EAh, 0A8h, 0FAh, 0C8h, 000h, 090h
             db 042h, 02Ah, 0AAh, 0AAh, 02Bh, 0B2h, 0A0h, 0ABh, 0BBh, 08Ah
             db 0BAh, 0A3h, 0BAh, 000h, 090h, 043h, 00Ah, 0AAh, 0AAh, 0A0h
             db 02Ah, 0AAh, 08Ah, 0BBh, 0F8h, 020h, 0BBh, 083h, 080h, 000h
             db 090h, 043h, 0AAh, 090h, 004h, 0A2h, 00Bh, 0BBh, 0BBh, 0C2h
             db 0AAh, 0A0h, 000h, 090h, 043h, 00Ah, 0AAh, 02Ah, 0AAh, 0AAh
             db 0A8h, 0AAh, 080h, 002h, 0AAh, 0AAh, 000h, 090h, 045h, 02Ah
             db 08Ah, 0AAh, 0AAh, 0A8h, 02Fh, 0BBh, 02Ah, 0AAh, 000h, 00Ah
             db 000h, 090h, 044h, 002h, 0A0h, 02Ah, 0AAh, 0A8h, 0BFh, 08Bh
             db 0EAh, 0AAh, 0AAh, 080h, 000h, 090h, 048h, 0A2h, 0BFh, 0FFh
             db 0F8h, 0AAh, 080h, 000h, 090h, 049h, 00Bh, 0FFh, 0FFh, 0FFh
             db 088h, 000h, 090h, 04Ah, 0BBh, 0FFh, 0FFh, 0FFh, 0FAh, 000h
             db 090h, 049h, 03Fh, 0FFh, 090h, 004h, 080h, 000h, 090h, 047h
             db 026h, 05Ah, 0A7h, 0FFh, 090h, 003h, 0F8h, 000h, 090h, 047h
             db 0A6h, 09Ah, 0A9h, 066h, 095h, 0A5h, 06Ah, 05Ah, 080h, 000h
             db 090h, 046h, 069h, 0A5h, 055h, 0A9h, 066h, 09Ah, 069h, 0A9h
             db 080h, 000h, 090h, 045h, 002h, 06Ah, 055h, 096h, 0AAh, 099h
             db 045h, 09Ah, 0A9h, 040h, 000h, 090h, 045h, 00Ah, 0A6h, 040h
             db 015h, 05Ah, 0A9h, 04Ah, 0A6h, 095h, 000h, 090h, 046h, 00Ah
             db 0A5h, 000h, 016h, 069h, 054h, 00Ah, 015h, 050h, 000h, 090h
             db 046h, 099h, 050h, 000h, 000h, 000h, 002h, 0AAh, 0A8h, 0B8h
             db 000h, 090h, 046h, 099h, 040h, 000h, 005h, 080h, 02Ah, 0AAh
             db 0AAh, 0FFh, 000h, 090h, 045h, 002h, 065h, 000h, 000h, 001h
             db 056h, 0AAh, 0AAh, 0A3h, 0BFh, 0F0h, 000h, 090h, 044h, 006h
             db 090h, 000h, 000h, 000h, 000h, 019h, 0AAh, 0AAh, 0A2h, 0FFh
             db 0FCh, 000h, 090h, 044h, 0A9h, 040h, 000h, 000h, 000h, 001h
             db 0AAh, 0AAh, 0A0h, 0ABh, 0FFh, 080h, 000h, 090h, 042h, 001h
             db 095h, 040h, 000h, 090h, 003h, 066h, 0AAh, 0A3h, 02Ah, 0FFh
             db 0E0h, 000h, 090h, 042h, 009h, 069h, 000h, 000h, 000h, 0BFh
             db 0CEh, 01Ah, 0AAh, 0AAh, 0A0h, 0BBh, 0F8h, 000h, 090h, 042h
             db 0A6h, 0A4h, 000h, 000h, 02Ah, 0BEh, 0BFh, 0FFh, 0C0h, 00Bh
             db 0CFh, 0CBh, 0FFh, 000h, 090h, 041h, 002h, 09Ah, 054h, 000h
             db 000h, 0BBh, 082h, 0ABh, 0BBh, 0CAh, 0A3h, 0B0h, 0BBh, 0AFh
             db 0C0h, 000h, 090h, 040h, 009h, 059h, 060h, 000h, 00Ah, 0A8h
             db 000h, 098h, 000h, 000h, 000h, 09Ah, 04Ah, 0A8h, 0B0h, 000h
             db 090h, 040h, 096h, 0A9h, 040h, 000h, 000h, 000h, 001h, 05Ah
             db 0AAh, 090h, 003h, 0A8h, 0A8h, 0BFh, 000h, 090h, 03Fh, 00Ah
             db 0AAh, 065h, 000h, 090h, 003h, 015h, 0AAh, 090h, 004h, 09Ah
             db 08Ah, 0BFh, 0E0h, 000h, 090h, 03Eh, 016h, 0A6h, 095h, 000h
             db 000h, 000h, 001h, 05Ah, 06Ah, 0AAh, 090h, 004h, 058h, 0ABh
             db 0FEh, 000h, 090h, 03Dh, 006h, 0AAh, 0AAh, 054h, 000h, 000h
             db 000h, 015h, 06Ah, 0A6h, 0A9h, 056h, 099h, 06Ah, 0AAh, 056h
             db 08Ah, 0BFh, 0E0h, 000h, 090h, 03Ch, 01Ah, 0AAh, 0AAh, 050h
             db 000h, 000h, 000h, 055h, 0AAh, 0A6h, 0AAh, 09Ah, 090h, 000h
             db 00Ah, 000h, 000h, 02Ah, 0BAh, 03Bh, 080h, 000h, 090h, 03Ah
             db 002h, 0AAh, 0AAh, 0A5h, 040h, 000h, 000h, 005h, 059h, 0A9h
             db 0A5h, 060h, 008h, 002h, 0ABh, 080h, 02Ah, 0AAh, 0AAh, 00Ah
             db 0FBh, 0C0h, 000h, 090h, 038h, 002h, 0A9h, 096h, 0A9h, 0A5h
             db 000h, 090h, 005h, 0AAh, 0AAh, 080h, 02Ah, 0AAh, 08Ah, 0AAh
             db 0A0h, 0BBh, 0B8h, 0ABh, 0C0h, 000h, 090h, 037h, 00Bh, 0FBh
             db 0A0h, 0A5h, 0AAh, 095h, 000h, 090h, 004h, 08Ah, 0AAh, 0ABh
             db 000h, 0AAh, 0AAh, 0CAh, 0A2h, 020h, 02Bh, 0FBh, 0B2h, 000h
             db 090h, 038h, 03Bh, 0BAh, 02Bh, 0B2h, 06Ah, 068h, 000h, 090h
             db 003h, 00Ah, 0AAh, 0AAh, 0B8h, 000h, 0AAh, 0AAh, 080h, 0BBh
             db 080h, 000h, 0BBh, 0BBh, 080h, 000h, 090h, 037h, 00Ah, 00Fh
             db 0FBh, 0FAh, 080h, 008h, 0E0h, 000h, 000h, 000h, 0AAh, 0AAh
             db 0ABh, 080h, 002h, 0AAh, 0AAh, 0B3h, 0FBh, 080h, 000h, 00Bh
             db 0FBh, 080h, 000h, 090h, 037h, 003h, 0BBh, 0BBh, 0A0h, 002h
             db 0BBh, 0B0h, 000h, 000h, 002h, 0AAh, 0AAh, 0BAh, 000h, 000h
             db 0AAh, 0AAh, 0B3h, 0BAh, 000h, 000h, 002h, 0A8h, 000h, 090h
             db 038h, 02Bh, 0FBh, 0BAh, 000h, 000h, 0BBh, 0B0h, 000h, 000h
             db 006h, 0AAh, 0AAh, 0B8h, 000h, 000h, 000h, 0AAh, 0F0h, 0BAh
             db 000h, 090h, 03Ch, 002h, 0BAh, 080h, 000h, 000h, 0BBh, 0B8h
             db 000h, 02Ah, 0B8h, 0AAh, 0ABh, 0B0h, 000h, 002h, 0AAh, 0AAh
             db 0B8h, 0BAh, 000h, 090h, 03Dh, 028h, 000h, 000h, 000h, 0BBh
             db 0FAh, 000h, 0AAh, 0FBh, 0F2h, 0ABh, 080h, 000h, 002h, 0A2h
             db 000h, 090h, 044h, 02Bh, 0B8h, 002h, 0ABh, 0BBh, 0BBh, 02Ah
             db 000h, 000h, 000h, 0BBh, 0BBh, 0BBh, 080h, 000h, 090h, 041h
             db 028h, 000h, 02Ah, 0BBh, 0FBh, 0BBh, 0E8h, 000h, 000h, 00Ah
             db 0FBh, 0BBh, 0FBh, 080h, 000h, 090h, 043h, 0AAh, 0BBh, 0BBh
             db 0BBh, 0B0h, 000h, 000h, 0AAh, 0BBh, 0BBh, 0BBh, 080h, 000h
             db 090h, 042h, 002h, 0ABh, 0FBh, 0BBh, 0FBh, 0C0h, 000h, 000h
             db 0ABh, 0FBh, 0FBh, 0BBh, 0F0h, 000h, 090h, 042h, 00Ah, 0BBh
             db 090h, 003h, 080h, 000h, 000h, 0ABh, 0BBh, 0BBh, 0BBh, 0B8h
             db 000h, 090h, 042h, 02Ah, 0FBh, 0BBh, 0FBh, 0BBh, 000h, 000h
             db 000h, 0ABh, 0FBh, 0BBh, 0FBh, 0BAh, 000h, 090h, 042h, 0ABh
             db 0BBh, 0BBh, 0BBh, 0B8h, 000h, 000h, 000h, 0ABh, 0BBh, 090h
             db 003h, 000h, 090h, 041h, 00Ah, 0BBh, 0BBh, 0FBh, 0FBh, 0F0h
             db 000h, 000h, 000h, 0ABh, 0BBh, 0FBh, 0FBh, 0FBh, 0C0h, 000h
             db 090h, 040h, 02Ah, 0BBh, 090h, 003h, 0B0h, 000h, 000h, 000h
             db 0ABh, 0BBh, 090h, 003h, 0B0h, 000h, 090h, 03Fh, 002h, 0ABh
             db 0BBh, 0FBh, 0BBh, 0FBh, 080h, 000h, 000h, 000h, 0ABh, 0FBh
             db 0BBh, 0FAh, 0AAh, 0B8h, 000h, 090h, 03Fh, 00Ah, 0ABh, 0BBh
             db 090h, 003h, 080h, 000h, 000h, 000h, 0AAh, 0BBh, 0B8h, 0A6h
             db 0A5h, 06Ah, 000h, 090h, 03Fh, 02Ah, 0BBh, 0FBh, 0FBh, 0FBh
             db 0BBh, 000h, 000h, 000h, 002h, 0AAh, 0BAh, 01Ah, 0AAh, 0AAh
             db 0AAh, 080h, 000h, 090h, 03Dh, 002h, 0AAh, 0BBh, 090h, 003h
             db 0BAh, 000h, 000h, 000h, 002h, 0AAh, 029h, 0AAh, 090h, 003h
             db 0A0h, 000h, 090h, 03Eh, 02Ah, 0FBh, 0BBh, 0FBh, 0BBh, 0FAh
             db 000h, 000h, 000h, 002h, 0A1h, 055h, 0A6h, 0AAh, 0AAh, 0AAh
             db 098h, 000h, 090h, 03Dh, 001h, 05Ah, 083h, 0BBh, 0BBh, 0BBh
             db 0BAh, 000h, 000h, 000h, 00Ah, 016h, 095h, 0AAh, 090h, 004h
             db 000h, 090h, 03Dh, 015h, 09Ah, 0AAh, 02Bh, 0FBh, 0FBh, 0F8h
             db 000h, 090h, 003h, 05Ah, 0AAh, 090h, 004h, 0A6h, 080h, 000h
             db 090h, 03Bh, 001h, 05Ah, 0AAh, 055h, 054h, 0BBh, 0BBh, 0B8h
             db 000h, 090h, 003h, 059h, 0AAh, 090h, 004h, 0A9h, 050h, 000h
             db 090h, 03Bh, 015h, 0A6h, 0AAh, 066h, 096h, 08Bh, 0BBh, 0F0h
             db 000h, 090h, 003h, 05Ah, 0AAh, 090h, 004h, 0A9h, 068h, 000h
             db 090h, 03Bh, 055h, 0AAh, 090h, 003h, 0A8h, 0BBh, 0B0h, 000h
             db 090h, 003h, 059h, 09Ah, 0AAh, 090h, 005h, 000h, 090h, 03Ah
             db 005h, 06Ah, 0AAh, 090h, 004h, 04Bh, 0B0h, 000h, 090h, 003h
             db 056h, 09Ah, 0AAh, 090h, 005h, 060h, 000h, 090h, 039h, 056h
             db 09Ah, 0AAh, 090h, 003h, 0A5h, 068h, 0B0h, 000h, 090h, 003h
             db 016h, 0AAh, 090h, 006h, 090h, 000h, 000h, 090h, 038h, 005h
             db 05Ah, 0AAh, 090h, 006h, 0A0h, 000h, 000h, 00Fh, 0F8h, 005h
             db 06Ah, 069h, 0AAh, 090h, 003h, 068h, 0BFh, 0E8h, 000h, 090h
             db 035h, 002h, 0C0h, 005h, 0AAh, 090h, 007h, 050h, 000h, 000h
             db 0BFh, 0FFh, 0F1h, 06Ah, 0AAh, 090h, 003h, 0A5h, 00Fh, 0FFh
             db 0FFh, 080h, 000h, 090h, 034h, 02Fh, 0F8h, 015h, 0AAh, 090h
             db 007h, 094h, 000h, 002h, 0FFh, 0FFh, 0FFh, 016h, 0AAh, 090h
             db 003h, 0A2h, 0FFh, 0FFh, 0FBh, 080h, 000h, 090h, 02Ah, 00Fh
             db 0C0h, 000h, 090h, 007h, 0BFh, 0FFh, 009h, 09Ah, 0AAh, 090h
             db 004h, 0A9h, 0AAh, 0B8h, 000h, 002h, 0BBh, 0FFh, 0FFh, 0F2h
             db 096h, 0AAh, 0A6h, 0AAh, 03Fh, 0FFh, 0FFh, 0AAh, 0A0h, 000h
             db 090h, 00Ch, 003h, 0FCh, 000h, 0FFh, 000h, 003h, 0FCh, 000h
             db 000h, 0FFh, 000h, 0FCh, 000h, 03Fh, 000h, 000h, 003h, 0F0h
             db 000h, 0FCh, 000h, 0FCh, 000h, 000h, 03Ch, 000h, 090h, 004h
             db 0C0h, 000h, 090h, 008h, 0BFh, 0FFh, 0FCh, 069h, 09Ah, 0AAh
             db 090h, 003h, 0A9h, 05Bh, 0FFh, 000h, 002h, 0AAh, 0BBh, 0FFh
             db 0FFh, 0AAh, 0AAh, 0AAh, 08Fh, 0FFh, 0FFh, 0FBh, 0AAh, 0A8h
             db 000h, 090h, 00Ch, 030h, 003h, 03Ch, 000h, 0C0h, 030h, 0CCh
             db 000h, 000h, 003h, 000h, 003h, 003h, 000h, 0C0h, 000h, 000h
             db 00Ch, 00Ch, 003h, 00Ch, 003h, 000h, 003h, 0CCh, 000h, 090h
             db 004h, 0C0h, 000h, 000h, 03Ch, 000h, 090h, 005h, 0ABh, 0FFh
             db 0FFh, 0C9h, 06Ah, 0AAh, 090h, 003h, 0A6h, 0BFh, 0FFh, 0C0h
             db 000h, 00Ah, 0AAh, 0BBh, 0FFh, 090h, 005h, 0FBh, 0AAh, 0AAh
             db 0A8h, 000h, 090h, 00Ch, 0C0h, 000h, 0C0h, 000h, 000h, 003h
             db 030h, 000h, 000h, 03Fh, 000h, 00Ch, 00Ch, 000h, 0FCh, 0FCh
             db 000h, 030h, 030h, 003h, 030h, 003h, 000h, 00Ch, 030h, 000h
             db 00Fh, 03Ch, 0C0h, 0C3h, 003h, 003h, 03Ch, 0C0h, 000h, 090h
             db 005h, 0AAh, 0BFh, 0FFh, 0FEh, 086h, 0AAh, 090h, 003h, 0A2h
             db 0FFh, 0FBh, 080h, 000h, 000h, 002h, 0AAh, 0BBh, 0FFh, 0FFh
             db 0FBh, 0FBh, 0FBh, 0BAh, 0AAh, 0AAh, 080h, 000h, 090h, 00Bh
             db 003h, 000h, 000h, 0C0h, 03Fh, 000h, 00Fh, 0F0h, 000h, 000h
             db 003h, 000h, 0C0h, 00Ch, 003h, 000h, 0C0h, 003h, 000h, 030h
             db 00Ch, 030h, 00Ch, 000h, 0FFh, 0FFh, 000h, 030h, 003h, 000h
             db 0C3h, 00Ch, 003h, 00Ch, 000h, 090h, 006h, 0AAh, 0ABh, 0FFh
             db 0FFh, 0FAh, 009h, 0AAh, 0AAh, 0A6h, 03Fh, 0FBh, 0B8h, 000h
             db 090h, 006h, 002h, 0AAh, 000h, 090h, 011h, 003h, 000h, 000h
             db 0F0h, 03Ch, 000h, 0C0h, 030h, 000h, 03Ch, 03Ch, 00Ch, 00Ch
             db 00Fh, 00Ch, 0CCh, 030h, 030h, 030h, 03Ch, 030h, 03Ch, 030h
             db 000h, 000h, 0C0h, 000h, 030h, 0F3h, 003h, 00Ch, 0CCh, 00Ch
             db 030h, 000h, 090h, 006h, 02Ah, 0AAh, 0BFh, 0FFh, 0FFh, 0FFh
             db 0FEh, 0AAh, 08Fh, 0FFh, 0BAh, 080h, 000h, 090h, 01Bh, 0C0h
             db 0C0h, 000h, 030h, 003h, 000h, 090h, 009h, 03Ch, 000h, 090h
             db 018h, 002h, 0AAh, 0BBh, 0FFh, 090h, 004h, 0BBh, 080h, 000h
             db 090h, 01Fh, 0C0h, 000h, 090h, 00Ah, 003h, 0F0h, 000h, 090h
             db 018h, 002h, 0AAh, 0BBh, 0BBh, 0FBh, 0FBh, 0AAh, 0A0h, 000h
             db 090h, 01Fh, 03Fh, 000h, 090h, 0FFh, 090h, 0D2h

mem_error    db  'No memory!',13,10,'$'
copyr        db  'Tronix (c) 2013',13,10,'$'

ifdef CALC_FPS
fps     dw 0 
sfps    db 4,'????'
t18     dw 18,0
tim     dw ?,?
timm    dw ?,?
endif

c       DB ?	; char from KBD

OldK    DW ?	; old int 09h vector
	DW ?

pic_buf      db 16383 dup (?)

END