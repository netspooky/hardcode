;
; A "HELLO WORLD" program that runs for both Commodore 64 and MSDOS.
; Borrowed from Skurk's idea.
; Compiled in 64TASS.
; Convert .prg to .com or vice versa.
; or run the two identical files on the two different platforms.
; Thank you!
;
; Rudi.
;

*=$0801

;** 12 bytes autload: 0 SYS2086 **
.byte $0c,$08,$00,$00,$9e,$32,$30,$38,$33,$00,$00,$00,$00

;** Hello world in DOS/COM **
.byte $ba,$17,$01,$b4,$09,$cd,$21,$c3,$48,$45,$4c,$4c,$4f,$20,$57,$4f,$52,$4c,$44,$21,$24

;** Hello world in 6510 **
	ldx #0
p	lda str, x
	sta $04f0,x
	inx
	cpx #12
	bne p
	rts
str:
.enc screen
	.text "HELLO WORLD!"
.enc none
