; 3D particle system in a 512-byte boot sector ("fountain of sparks" demo)
; Written for #asm compo #8 by Rusty Wagner

; To run:
; 1. Write fountain.bin to the boot sector of a floppy disk.  This can be done with rawrite.exe or debug.com with
;    fountain.bin as input.  (For debug.com, use the command "w 100 0 0 1" to write to A:)
; 2. Boot your system with the floppy in the drive (be sure to set your BIOS to boot A: before the hard disks).

; Note: If you have a USB keyboard, legacy keyboard support needs to be enabled.  Without this, DOS and boot sector
;       code won't be able to read from your keyboard.
; Note: This code will not run on Bochs (it has a bug in the pusha instruction).

; Assembled using NASM

	bits	16
	org		0x7c00		; boot sector is loaded at 0x0000:0x7c000

	particlecount			EQU 256		; currently must be multiple of 256
	
	particle_display		EQU	0
	particle_pos_x			EQU 2
	particle_pos_y			EQU 4
	particle_pos_z			EQU 6
	particle_vel_x			EQU 8
	particle_vel_y			EQU 10
	particle_vel_z			EQU 12
	particle_bright			EQU 14
	particle_structsize		EQU 16

	; Select address of particles such that the end of the array is 0xa000 (segment for video memory)
	particles				EQU 0xa000 - particle_structsize * particlecount	; particles = 0x9000 for 256 particles
	
	fademask				EQU 0x4001				; mask for optimizing fade loop, no init required

	diffuse_val				EQU particles - 2		; storage for error diffusion dithering (no initialization required)

	backbuffer_seg			EQU particles			; backbuffer_seg = particles allows for some extra optimizations


start:
	; Set up a stack in a known location (highest part of segment 0x0000)
	push	cs
	pop		ss				; ss = 0
	xor		sp, sp

	cld						; direction = forward
	push	cs
	pop		ds				; ds = 0

init:
	; Switch to 320x200x8 mode
	mov		ax, 0x13
	int		0x10
	
	; Clear interrupts, everything onward will be done using direct hardware access.
	; Allows us to not have to worry about what conventional memory we have available
	; (some BIOSes and extensions like to place things at the high end of memory
	; in segment 0x9000, which is needed for the back buffer).
	cli
	
	mov		dx, 0x3c8
	xor		ax, ax
	out		dx, al			; palette write index = 0

	inc		dx
	
	; Use 0x3c9 as the initial random seed.  The random algorithm used just needs any
	; nonzero value to work.
	mov		fs, dx

	; Palette is set up to produce 16 shades of orange and 16 shades of gray, with all
	; combinations of the two.  For color indicies, the high nibble represents the
	; brightness of the orange component, and the low nibble represents the brightness
	; of the gray component.  The gray "floor" will be static in the low nibble of the
	; back buffer, with the orange high nibble representing the animated particles.
	mov		cx, 16
	xor		bx, bx
genpalmainloop:
	pusha
	mov		cl, 16
genpaloutloop:
	mov		al, bh
	call	outpalentry
	mov		al, bh
	sub		al, ah
	call	outpalentry
	mov		al, bl
	out		dx, al
	inc		bx
	inc		bx
	loop	genpaloutloop
	popa
	add		bh, 4
	inc		ah
	loop	genpalmainloop


	push	cs
	pop		es				; es = 0

	; Generate entries for all of the particles.  All particles are initially invisible,
	; but will be regenerated at different intervals to create a continous effect.
	
	; cl = 0
	mov		ch, particlecount / 256
	mov		di, particles
	push	di
setupparticlesloop:
	mov		bh, cl			; brightness = time to live = loop counter
	mov		al, 0			; not visible
	call	genparticle
	loop	setupparticlesloop

	; di = 0xa000 (from end of setup loop)

	; Clear the upper part of the back buffer to black.  The rest will be overwritten
	; by the floor generation code.
	pop		es				; es = backbuffer_seg
	xor		ax, ax			; ax = 0
	xchg	ax, di			; di = 0, al = 0 (since di was 0xa000)
	mov		ch, (320 * 136) / 256
	rep		stosb


	; Floor generator.  The floor is generated using 3D lighting calculations with
	; one static point light (at the center of the fountain) to produce a floor that
	; appears to be lit by the fountain particles.
	mov		bx, 36				; bx = screenpos.y
genfloorloop:
	mov		ax, -160			; ax = screenpos.x
	mov		cx, 320
genfloorrowloop:
	pusha

	; y = z / screenpos.y
	xchg	ax, cx
	mov		dx, 0x10
	xor		ax, ax
	idiv	bx
	mov		bx, ax
	
	; x = y * screenpos.x
	cwd
	imul	cx

	; The (x, y, z) position of the pixel on the floor we are generating has been found,
	; calculate the light amount

	imul	dx, dx
	sar		bx, 8
	sub		bx, byte 0x4c
	imul	bx, bx
	add		bx, dx				; bx = x^2 + y^2
	call	rand
	add		bx, ax				; add in a random factor to give it a little bit of texture

	mov		ah, 0x5f			; ax ~= 0x5f00
	cwd
	idiv	bx					; light amount = 0x5f00 / (x^2 + y^2 + rand)

	sub		ax, 12				; subtract out some light to make it pure black a bit away from the light source
	jc		neglight			; write out black if the light value goes negative

	mov		bx, ax
	shr		ax, 4				; divide light amount by 16 to get a good light radius

	; Error diffusion dithering to make things look smooth
	shl		bx, 12
	add		[diffuse_val], bx
	adc		ax, 0

	cmp		al, 15				; clamp light amount to 15 (only have 16 shades of gray in the palette)
	jbe		notcenter
	mov		al, 15
	stosb
neglight:
	xor		al, al
notcenter:
	stosb

	popa
	inc		di
	inc		ax
	loop	genfloorrowloop

	inc		bx
	cmp		bl, 100
	jb		genfloorloop


	; Start of main render loop
render:
	; es = backbuffer_seg
	; cx = 0
	push	es
	
	; cl = 0
	mov		ch, particlecount / 256
	pop		si							; si = particles
	push	si
renderloop:
	push	cx
	
	mov		di, si
	
	lodsw					; ax = particle.display
	test	al, al

	lodsw
	xchg	ax, bx			; bx = particle.pos.x
	lodsw
	xchg	ax, dx			; dx = particle.pos.y
	lodsw
	xchg	ax, cx			; cx = particle.pos.z

	jz		nodisplay
	
	pusha

	; Render particle
	mov		bp, [si+particle_bright-particle_vel_x]
	call	displayparticle

	; Render particle reflection
	shr		bp, 1
	mov		di, bp
	shr		di, 1
	sub		bp, di
	neg		dx
	add		dh, 0x20
	call	displayparticle

	popa

nodisplay:

	lodsw					; ax = particle.velocity.x
	add		[si+particle_pos_x-particle_vel_y], ax		; particle.pos.x += particle.velocity.x
	lodsw					; ax = particle.velocity.y
	add		dx, ax			; particle.pos.y += particle.velocity.y
	cmp		dh, 0x10		; if particle.pos.y >= 0x1000, the particle has hit the floor
	jl		nobounce

	; Bounce the particle off the floor (divide speed by 4, negate velocity.y)
	mov		dx, 0x1000
	mov		cl, 2
	sar		ax, cl
	sar		word [si+particle_vel_x-particle_vel_z], cl
	sar		word [si+particle_vel_z-particle_vel_z], cl
	neg		ax

nobounce:
	inc		ax				; particle.velocity.y += 2 (gravity)
	inc		ax
	mov		[si+particle_pos_y-particle_vel_z], dx
	mov		[si-2], ax
	lodsw					; ax = particle.velocity.z
	add		[si+particle_pos_z-particle_bright], ax		; particle.pos.z += particle.velocity.z

	sub		word [si], 0xa0	; particle.brightness -= 0xa0
	lodsw
	jnc		noregen

	; Renegerate particle if brightness goes negative
	push	es
	push	cs
	pop		es
	mov		al, 1
	mov		bh, 0xff
	call	genparticle
	pop		es
noregen:
	
	pop		cx
	loop	renderloop

	; Wait for VSYNC, locks framerate to 60 FPS and prevents artifacts
	mov		dx, 0x3da
vsyncwait1:
	in		al, dx
	test	al, 8
	jnz		vsyncwait1
	
vsyncwait2:
	in		al, dx
	test	al, 8
	jz		vsyncwait2
	
	; Copy back buffer to video memory

	; cx = 0
	; si = 0xa000
	push	es
	pop		ds			; ds = backbuffer_seg

	mov		es, si		; es = 0xa000
	xor		di, di
	xor		si, si
	mov		ch, 0x40
	mov		bp, cx		; bp = fademask - 1
	rep		movsd

	; si = 0
	; cl = 0

	; Fade out the existing orange component of the back buffer instead of clearing to create a motion blur effect
	mov		ch, 0x10
	dec		si			; si = -1
mainfadeloop:
	inc		bp
	inc		bp
	cmp		[bp+si], si
	jnz		fadenoskip
	lea		di, [di+16]
	jmp		short fadeloopend
fadenoskip:
	mov		dx, 1
fadeloop:
	mov		al, [di]
	sub		al, 0x10
	jnc		fadenotblack
	or		[bp+si], dx
	add		al, 0x10
fadenotblack:
	mov		[di], al
	inc		di
	add		dx, dx
	jnz		fadeloop
fadeloopend:
	loop	mainfadeloop

	push	cs
	pop		ds
	pop		es			; es = backbuffer_seg
	
	; Check for keypress
	in		al, 0x64
	shr		al, 1
	jnc		render

exit:
	; Key pressed, exit by rebooting (won't work on Bochs, but will on anything else...)

	; si = -1
	; cx = 0
	push	si
	push	cx
	retf				; jmp 0xffff:0x0000


; Input:
;   al = base color
;   bl = added color
; Output:
;   al = final color
outpalentry:
	add		al, bl
	cmp		al, 63
	jb		entryok
	mov		al, 63
entryok:
	out		dx, al
	ret


; Input:
;   es:di = particle to generate
;	al = display particle?
;	bx = time to display
; Output:
;   ax = ????
;   bx = ????
;   es:di = next particle
genparticle:
	stosw					; write particle.display
	xor		ax, ax
	stosw					; particle.pos.x = 0
	mov		ah, 0x10
	stosw					; particle.pos.y = 0x1000
	mov		ah, 0x4c		; particle.pos.z = 0x4c00
	call	gendir			; particle.velocity.x = random number between -32 and 31
	mov		ax, -0xc4		; particle.velocity.y = -0xc4
	call	gendir			; particle.velocity.z = random number between -32 and 31
	xchg	ax, bx
	stosw					; write particle.brightness (also gives time to live)
	ret


; Writes ax to es:di, random number between -32 and 31 to the next word at es:di+2
gendir:
	stosw
	call	rand
	sub		ax, 0x20
	stosw
	ret


; Output
;   ax = Random number in range 0-63
rand:
	; Get next random number
	mov		ax, fs
	imul	ax, byte 13
	xchg	ah, al
	mov		fs, ax
	and		ax, 0x3f
	ret


; bx = x
; dx = y
; cx = z
; bp = brightness
displayparticle:
	pusha
	xchg	ax, dx
	mov		di, 100
	call	project			; screenpos.y = (y / z) + 100
	xchg	ax, bx
	mov		di, 160
	call	project			; screenpos.x = (x / z) + 160
	imul	bx, di			; bx = screenpos.y * 320
	add		bx, ax			; bx = (screenpos.y * 320) + screenpos.x (offset of pixel in back buffer)

	; Draw the 4x3 pixel particle using the intensity array (holds count to shift the brightness to the right)
	mov		si, intensity - 1
	mov		ax, 4
	xchg	ax, bp
disploop:

	mov		ch, 3
disprowloop:
	push	ax
	push	bx
	mov		cl, [si]
	shr		ah, cl
	and		ah, 0xf0				; AND color so that it only affects the orange component of the color
	mov		al, [es:bx]				; al = color currently in back buffer
	cmp		al, ah					; if al > color to write, don't add any more brightness (makes motion blur look better)
	jae		notmax
	add		al, ah					; Add color to the one currently on the screen
	jnc		notmax					; Check for overflow
	or		al, 0xf0				; Color overflowed, so max out the orange component
notmax:
	mov		[es:bx], al				; Write to back buffer
	shr		bx, 3
	mov		byte [bx+fademask], 0	; Update fade mask so that the pixel will fade to black gradually
	pop		bx
	pop		ax

	inc		si
	inc		bx
	dec		ch
	jnz		disprowloop

	lea		bx, [bx+di-3]
	dec		bp
	jnz		disploop
	popa
	ret


intensity:	db    1, 3		; First entry (3) comes from the ret instruction (0xc3), as a shift count of 0xc3 is interpreted as 3
			db 1, 0, 1
			db 1, 1, 1
			db 3, 2, 3


; Input:
;   ax = coord
;   cx = z coord
;   di = max screen offset / 2
; Output:
;   ax = screen offset
;   dx = ????
;   di = max screen offset
project:
	cwd
	xchg	al, dl
	xchg	ah, dl			; dx:ax = coord * 256 (gives some extra precision to the projection)
	idiv	cx				; ax = offset from screen center = (coord * 256) / z
	add		ax, di			; ax = screen pos (0 = top left)
	add		di, di			; di = max screen offset

	; Check to see if pixel within the bounds of the screen
	cmp		ax, di
	jb		dispnotoutofrange
dispoutofrange:
	; Pixel out of range, need to return from displayparticle (the only function project is called from)
	pop		ax		; scrap return value
	popa
dispnotoutofrange:
	ret


	; Required data for a valid boot sector
	times	510-($-$$) db 0
	dw		0xaa55
