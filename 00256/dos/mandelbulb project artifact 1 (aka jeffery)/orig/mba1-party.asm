;
;	mandleblub 256byte demo by alih/wow/unreal
;
	org 100h

; constants
maxiter	equ	8

; take the 16 freom the int 10h
sixteen equ 103h


	; set mode 13h
	mov al,13h
	int 10h

	; set es: to screen
	push 0a000h		; also used for rlimit - remmeber to change that if we change this!!!
	pop es

	; screen pointer

loopi:
;	mov di,64000
	mov word [wy],-100
	;fninit
	; yloop
	; set st0 to -1 for y
	;fld1
	;fstp dword [wy]
ypxloop:
	mov dl,160
	mov word [wx],-80
	; set st1 to -1 for x
	;fld1
	;fstp dword [wx]
xpxloop:

	; set st2 to -1 for z
	mov word [wz],-15
	mov bh,15
zloop:
	fninit

	fild word[rot]
	fmul dword[zstep]
	fsincos


	mov si,8
cxl:
	fild word [wx+si]
	fmul dword[xstep+si]
	sub si,4
	jnc cxl
				
	; z -> -sin()y+cos()z

	; state: so0->x,st1->y,st2->z,st3->cos,st4->sin
	fld st1
	; state: sto->z',st1->x,st2->y,st3->z,st4->cos,st5->sin
	fmul st5
	fld st3
	; state: st1->zy, st1->z',st2->x,st3->y,st4->z,st5->cos,st6->sin
	fmul st5
	fsubp st1
	fst dword [oz]
	; state: sto->z',st1->x,st2->y,st3->z,st4->cos,st5->sin

	; y -> -sin()x+cos()cos()y+cos()sin()z
	fld st1
	; state: st0->y',st1->z',st2->x,st3->y,st4->z,st5->cos,st6->sin
	fmul st6
	fld st3
	; state: st1->yy,st1->y',st2->z',st3->x,st4->y,st5->z,st6->cos,st7->sin
	fmul st6
	fmul st6
	fsubp st1
	; state: st0->y',st1->z',st2->x,st3->y,st4->z,st5->cos,st6->sin
	fld st5
	; state: st1->yy,st1->y',st2->z',st3->x,st4->y,st5->z,st6->cos,st7->sin
	fmul st6
	fmul st7
	faddp st1
	; state: st0->y',st1->z',st2->x,st3->y,st4->z,st5->cos,st6->sin
	fst dword [oy]
	
	; x -> cos()x + sin()cos()y + sin()sin()z
	fld st2
	; state: st0->x',st1->y',st2->z',st3->x,st4->y,st5->z,st6->cos,st7->sin
	fmul st6
	fxch st6
	; state: st0->cos,st1->y',st2->z',st3->x,st4->y,st5->z,st6->x',st7->sin
	fmul st4
	fmul st7
	; state: st0->ycossin,st1->y',st2->z',st3->x,st4->y,st5->z,st6->x',st7->sin
	fxch st0,st7
	; state: st0->sin,st1->y',st2->z',st3->x,st4->y,st5->z,st6->x',st7->ycossin
	fmul st0
	fmul st5
	; state: st0->zsinsin,st1->y',st2->z',st3->x,st4->y,st5->z,st6->x',st7->ycossin
	fadd st6
	fadd st7
	fst dword [ox]

	; state: st0->x',st0->y', st1->z',st2->x,st3->y,st4->z,st5->cos*x,st6->sin
	ffree st3
	ffree st4
	ffree st5
	ffree st6
	ffree st7


	; state: st0->x',st0->y', st1->z'
	; set maxIter
	mov dh,maxiter

iterloop:
	; okay, go!
	; state: x,y,z = st0,st1,st2

	; each time we do this for x,y,z, it pushes to the stack
	; x=st0,y=st1,z=st2
	; square it
	mov cx,3
cccd:
	fld st2
	fmul st0	; z^2,x^2,y^2
	; z2=st0,x=st1,y=st2,z=st3
	; y2=st0,z2=st1,x=st2,y=st3,z=st4
	; x2=st0,y2=st1,z2=st2,x=st3,y=st4,z=st5
	loop cccd

	; add the two together for the beta calc
	faddp st1

	; state x2y2=st0,z2=st1,x=st2,y=st3,z=st4
	; add z^2 to the whole thing to make r :)
	fadd st1,st0
	; state x2y2=st0,r=st1,x=st2,y=st3,z=st4

	; check for hugeness of r, since that'll cause
	; FP overflow
	fld dword [rlimit]
	fcomip st2
	jb overflow		; the order of this is dumb!!

	; check if we're out by iterating!
	dec dh
	jz loopOver

	; i guess not, lets keep calculating!

	; atan2(sqrt(x2y2), z)
	; note that fpatan takes x,y rather than the y,x of atan2!!
	; the good news is that the algorythm doesn't actually really care, and we can just
	; reverse it for the convincience of x87 is shit :)
	fsqrt
	fld st4
	fpatan

	; multiply that by 8
	fimul word [eight]

	; woo, beta calculated!
	; state beta=st0,r=st1,x=st2,y=st3,z=st4
	; put cos/sin of beta on the stack now, we need them later!
	fsincos
	; state cos(beta)=st0,sin(beta)=st1,r=st2,x=st3,y=st4,z=st5

	; alpha tgime - this is easier :)
	; atan2(y,x)*8 - st4,st3 :)
	fld st4
	fld st4
	fpatan
	fimul word[eight]
	fsincos
	; state cos(alpha)=st0,sin(alpha)=st1,cos(beta)=st2,sin(beta)=st3,r=st4,x=st5,y=st6,z=st7
	
	; shit, we need r8, but we're out of regs.  shiiit. gotta waste two bytes moving r to the top....
	fxch st0,st4
	; win tho - sqrt(r)^8, which is r^4, which is (r^2)^2 - thanks, newton!
	fmul st0
	fmul st0
	
	; we lack registers - free some!
	ffree st5
	ffree st6
	ffree st7

	; state r8=st0,sin(alpha)=st1,cos(beta)=st2,sin(beta)=st3,cos(alpha)=st4
	; calculate z first, so we can drop it from the end of the stack ;)
	; z=r8*cos(beta) + oz
	fld st2
	fmul st1	; +1 due to fld
	fadd dword [oz]
	; state z=st0,r8=st1,sin(alpha)=st2,cos(beta)=st3,sin(beta)=st4,cos(alpha)=st5,x=st6,y=st7

	; calc y next, so it can fall off :)
	; y = rp * sin(beta) * sin(alpha) + oy;
	fld st4
	fmul st3	; +1 due to fld
	fmul st2	; +1 due to fld
	fadd dword [oy]

	; state y=st0,z=st1,r8=st2,sin(alpha)=st3,cos(beta)=st4,sin(beta)=st5,cos(alpha)=st6,x=st7

	; finally calc x
	; x = rp * sin(beta) * cos(alpha) + oz;
	fld st6
	fmul st6	; +1 due to fld
	fmul st3	; +1 due to fld
	fadd dword [ox]

	; lets drop some state :)
	; i was going to replace this with fnsetenv
	; (fstenv at the top of the loop)
	; but it turned out to be the same number of bytes!
	ffree st3	; r8
	ffree st4	; sin/cos alpha
	ffree st5
	ffree st6	; sin/cos beta
	ffree st7
	; state x=st0,y=st0,z=st2

	; iterate!!! the escape clause is just afetr the calc of r...
	jmp short iterloop
loopOver:
	; okay, we fell out of the loop of natural
	; causes - which means we this one is a hit!
	; maybe....
	; state here: temp=st0,r=st1,x=st2;y=st3,z=st4
	
	; state here: r=st0,x=st1;y=st2,z=st3
	; dist=sqrt(r) for now!
	; but we can keep it not sqrt'd forever because
	; we don';t have enough bytes for normals anyhow :)
	;fsqrt
	fild word [sixteen]
	fcomip st1
	jnb foundZ

	; once you hit here, it MUST be 
	; state temp=st0,x=st1,y=st2,z=st3
overflow:
	; sad tiems - we didn't find shit, either due to chaos overflow or fail at dist, try the next z ;)
	inc word [wz]

	; one byte less than the FPU compare - and we can reuse it for crappy colour
	dec bh
	jnz zloop
	;fld1
	;fcomip st1
	;jnb zloop

	jmp nothingFound
foundZ:
	; FIXME: get a colour???
nothingFound:
	; ghetto colour!
	; grey
	or bh,16
	;mov bl,bh
	mov word [es:di],bx
	
	; also 2*inc is faster than using scaled addressing mode, as far asi can tell,
	; because those opcodes are le long
	inc di		; two inc's is one byte less than an add
	inc di		; two inc's is one byte less than an add
	je overit
 
	; add xstep 
	inc word [wx]

	dec dl
	jnz xpxloop

	
	; add ystep 
	inc word [wy]

	jmp ypxloop

overit:
	inc word [rot]
	jmp loopi



;	in al,60h
;	dec al
;	jz loopi

;	
;	ret

; constants
eight	dw	8
;rlimit	dd	1e25
rlimit equ 101h


; 2.0/320
xstep dd 0.012500
;xstep dd 0.00625
; 2.0/200
;ystep dd 0.020000
ystep dd 0.010000
; 2.0/32...?
zstep dd 0.062500



section .bss
ox	resd	1
oy	resd	1
oz	resd	1

wx	resd	1
wy	resd	1
wz	resd	1


x	resd	1
y	resd	1
z	resd	1
rot	resd	1
