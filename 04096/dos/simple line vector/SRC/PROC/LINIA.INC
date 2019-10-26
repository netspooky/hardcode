;*********************************************************
;*                                                       *

;*    Plik GRAF13.ASM (kod «r¢dˆowy pliku GRAF13.OBJ)    *
;*    Moduˆ zawieraj¥cy procedur© do rysowania odcinka   *
;*    w trybie 320x200x256.                              *
;*    (c)1994 Paweˆ Czubiliäski                          *
;*                                                       *
;*********************************************************

;-> Line13 <---------------------------------------------;
;Procedura do kre˜lenia odcinka w trybie 320x200x256.    ;
;Typ     : NEAR                                          ;
;Wejscie : DI:BX <-- Xp,Yp                               ;
;          BP:CX <-- Xk,Yk                               ;
;             AL <-- Kolor odcinka                       ;
;Wyj˜cie : nie ma                                        ;
;Modyf.  : BX,CX,DX,DI,BP,FLAGS                          ;
;--------------------------------------------------------;
LINE13_GL:    neg     bp
              cmp     bp,cx
              jc      LINE13_GL2
LINE13_GL1:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              xchg    bp,cx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,cx
              sub     dx,bp
              inc     cx
              std
LINE13_GL1a:  stosb
              or      dx,dx
              js      LINE13_GL1b
              sub     dx,bp
              loop    LINE13_GL1a  ;DEC xn
              ret
LINE13_GL1b:  sub     dx,bx
              add     di,320
              loop    LINE13_GL1a
              ret
LINE13_GL2:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,bp
              sub     dx,cx
              inc     cx
              cld
LINE13_GL2a:  stosb
              or      dx,dx
              jnl     LINE13_GL2b
              add     dx,bp
              add     di,319
              loop    LINE13_GL2a
              ret
LINE13_GL2b:  add     dx,bx
              add     di,318
              loop    LINE13_GL2a
              ret
LINE13_G:     sub     bp,di
              jc      LINE13_GL
              jne     LINE13_GP
              jmp     LINE13_PION
LINE13_GP:    cmp     bp,cx
              jnc     LINE13_GP2
LINE13_GP1:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,bp
              sub     dx,cx
              inc     cx
              cld
LINE13_GP1a:  stosb
              or      dx,dx
              jnl     LINE13_GP1b
              add     dx,bp
              add     di,319
              loop    LINE13_GP1a
              ret
LINE13_GP1b:  add     dx,bx
              add     di,320
              loop    LINE13_GP1a
              ret
LINE13_GP2:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              xchg    bp,cx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,bp
              sub     dx,cx
              inc     cx
              cld
LINE13_GP2a:  stosb
              or      dx,dx
              jnl     LINE13_GP2b
              add     dx,bp
              loop    LINE13_GP2a
              ret
LINE13_GP2b:  add     dx,bx
              add     di,320
              loop    LINE13_GP2a
	      ret

LINE13:       mov     dx,0A000h
              mov     es,dx
              sub     cx,bx
              jc      LINE13_D
              jne     LINE13_G
LINE13_POZ:   sub     bp,di
              jc      LINE13_POZL
LINE13_POZP:  xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     cx,bp
              inc     cx
              cld
              rep     stosb
              ret
LINE13_POZL:  neg     bp
              xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     cx,bp
              inc     cx
              std
              rep     stosb
              ret
LINE13_PION:  or      cx,cx
              js      LINE13_PIOND
LINE13_PIONG: xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              inc     cx
              cld
LINE13_PIONGa:stosb
              add     di,319
              loop    LINE13_PIONGa
              ret
LINE13_PIOND: neg     cx
              xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              inc     cx
              cld
LINE13_PIONDa:stosb
              sub     di,321
              loop    LINE13_PIONDa
              ret
LINE13_D:     sub     bp,di
              je      LINE13_PION
              jnc     LINE13_DP
LINE13_DL:    neg     cx
              neg     bp
              cmp     bp,cx
              jnc     LINE13_DL2
LINE13_DL1:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,cx
              sub     dx,bp
              inc     cx
              cld
LINE13_DL1a:  stosb
              or      dx,dx
              js      LINE13_DL1b
              sub     dx,bp
              sub     di,321
              loop    LINE13_DL1a
              ret
LINE13_DL1b:  sub     dx,bx
              sub     di,322
              loop    LINE13_DL1a
              ret
LINE13_DL2:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              xchg    bp,cx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,cx
              sub     dx,bp
              inc     cx
              std
LINE13_DL2a:  stosb
              or      dx,dx
              js      LINE13_DL2b
              sub     dx,bp
              loop    LINE13_DL2a
              ret
LINE13_DL2b:  sub     dx,bx
              sub     di,320
              loop    LINE13_DL2a
              ret
LINE13_DP:    neg     cx
              cmp     bp,cx
              jc      LINE13_DP2
LINE13_DP1:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              xchg    bp,cx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,bp
              sub     dx,cx
              inc     cx
              cld
LINE13_DP1a:  stosb
              or      dx,dx
              jnl     LINE13_DP1b
              add     dx,bp
              loop    LINE13_DP1a
              ret
LINE13_DP1b:  add     dx,bx
              sub     di,320
              loop    LINE13_DP1a
              ret
LINE13_DP2:   xchg    bh,bl
              add     di,bx
              shr     bx,2
              add     di,bx
              mov     bx,bp
              sub     bx,cx
              shl     bx,1
              shl     bp,1
              mov     dx,cx
              sub     dx,bp
              inc     cx
              cld
LINE13_DP2a:  stosb
              or      dx,dx
              js      LINE13_DP2b
              sub     dx,bp
              sub     di,321
              loop    LINE13_DP2a
              ret
LINE13_DP2b:  sub     dx,bx
              sub     di,320
              loop    LINE13_DP2a
	      ret
;--------------------------------------------------------;
Line13P       PROC              ;Rysowanie odcinka
              mov     di,Xp
              mov     bx,Yp
              mov     dx,Xk
              mov     cx,Yk
              mov     al,KOLOR
              mov     bp,dx
	      call    Line13
	      ret
Line13P       ENDP
;--------------------------------------------------------;
