;mooon
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;15-10-2011


;Planning and writing time ~2h
;Optimizing time ~8h

;Let's start with a simple trigonometry.
;I want to make a dot spheres rotating around axis z (angle phi) and x (angle alpha).
;Each point at the sphere has spherical coordinates (r, theta, phi).
;It's easy to find the cartesian coordinates of points after rotations:

;|1	0		0		|   |r*sin(theta)*cos(phi)	|
;|0	cos(alpha)	-sin(alpha)	| * |r*sin(theta)*sin(phi)	| =
;|0	sin(alpha)	cos(alpha)	|   |r*cos(theta)		|	


;x = r*sin(theta)*cos(phi)
;y = r*sin(theta)*sin(phi)cos(alpha)-r*cos(theta)*sin(alpha)
;z = Doesn't matter.

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
				;Instead of storing point coordinates in array,
				;let's generate the same spherical coordinates for the each point
				;on the fly in each frame cycle and then modify 
				;each phi angle values by the current global phi value.
				;Then we just need to do the math and find x and y.
				
	fldz			;This is the value of global phi and alpha angles.
				;For the 'r' we need the constant slightly below 100 
				;(half-height of the screen). The reverse value of
	fldl2t			;lg2(10)/320 = 0.01038... fits very well, r = 96.3,
	fidiv word [c320+2]	;and direct value is used for the incrementing the 
				;global angles phi and alpha.
				;At the address [c320+2] there is a immediate value 320
				;of imul operation.
	mov bp, sp		;For cpu-gpu data transfer via push/pop.

L0:	mov bh, 6		;There are 6*256 points in spheres.
L:	pusha
	fild word [bp-8]	;bx = theta
	fsincos
	fild word [bp-9]	;bl * 256 + ff(from sp value) = phi
	fadd st0, st4		;Add global phi to the phi of each point. 
	fsincos
	fld st5
	fsincos			
				;Now all 8 fpu registers are in use =)
	fmul st3, st0
	fdiv st0, st6
	fistp word [bp-6]	;Also cos(theta)
	fmul st3, st0
	fdiv st0, st5
	fistp word [bp-14]	;and sin(theta) is used for finding the center 
				;coordinates of the small globe (si, dx). 
	fmul st0, st3
	fdiv st0, st4
	fistp word [bp-16]	;Save y in di.
	fmulp st2, st0
	fsubp st1, st0
	fdiv st0, st1
	fistp word [bp-2]	;Save x in ax.
	popa
	push 24			;Set default globe point color - grey.
	test bl, 3		;Every 4th point belongs to the small globe.
	jnz BIG			;If the point is in small globe then:
	sar ax, 1		;1) Scale the small globe (it's two times smaller than the big one).
	sar di, 1
	sar si, 1		;2) Go from circular to elliptic trajectory.
	add ax, si		;3) Place small sphere center to this trajectory.
	add di, dx
	pop dx			;4) Empty stack
	push 31			;and set the color value to white.
BIG:	

				;Remaining part is the same for both spheres.
	add di, 160		;Place the origin to the screen center.
	add ax, 100
c320:	imul ax, 320
	add di, ax		;Find the screen buffer address of current point.
	pop ax			;Pop the color value.
	stosb
	dec bx
	jnz L			;Loop through all points in set.
	
MB:	mov al, [es:di]		;Simple motion blur effect.
				;In some reason reading from the screen buffer
				;is very slow in Windows XP dos emulation 
				;while writing is reasonably fast.
				;It's fast in dosbox though.
				;For higher speed change this part (and kill the effect) to
				;xor ax, ax
				;dec cx
				;rep stosb
	cmp al, 17
	jl D
	dec ax			;Decrease color 31->...->16
D:	stosb
	loop MB
	fadd st1, st0		;Increment the global phi value
	fadd st1, st0		;twice for longer point plumes.
	in al, 60h
	dec al
	jnz L0
	ret
				
				;My english and code sucks, 
				;but try to enjoy this 128b and hello from Russia!



