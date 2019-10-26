; blip34
; 2012 by quasimodo
; Needs Covox!
;
; Its an approximation of 
; (t*(t>>10)*~(t>>10))&(t>>13)
; running at ~9.4 kHz (i have got no idea why)
;
; I really wanted this to be a 32 byte intro,
; but the only way i am seeing to reduce the
; size further is to change the tune.
; I could have added stuff to make a propper
; 64b or bigger intro, but since i am proud of
; how far i got i release it as a 34b.
;
; Big Thanks go to frag for his pcm32 intro,
; and of course to Viznut for starting this madness.
;
; Also i guess i should be greating titan :)

	org 100h

start:	in	al, 40h
	cmp	al, cl
	jne	start
	dec	ecx
	mov	eax, ecx
	shr	eax, 10
	mov	bx, ax
	not	bx
	mul	bx
	mul	cx
	shr	bx, 3
	and	ax, bx
	mov	dx, 378h
	out	dx, al
	jmp	start
