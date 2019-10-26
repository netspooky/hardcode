#  code.inc - the actual code part for 'sesamstr'
#	
#  Copyright (C) 1999 Jorik Blaas and Tijs van Bakel
#  Jorik Blaas <jrk@vengeance.et.tudelft.nl> (avoozl)
#  Tijs van Bakel <smoke@casema.net> (smoke)
# 
#  This file is part of sesamstr, a 4k linux intro
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2, or (at your option)
#  any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; see the file COPYING.  If not, write to
#  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

## wait for the vertical retrace (IBM VGA compatibles only) ##

vga_waitretrace:
	movw	$0x3da, %dx
  vga_waitretrace1:	
	inb	%dx, %al
	testb	$8, %al
	jnz	vga_waitretrace1
  vga_waitretrace2:	
	inb	%dx, %al
	testb	$8, %al
	jz	vga_waitretrace2
	ret

## vga_setpal - set the palette registers of the vga
##		input:	%esi - palette (3bytes a color)
##			%al - start color
##			%ecx - number of colors to set * 3
vga_setpal:
	movw	$0x3c8, %dx
	outb	%al, %dx
	incw	%dx
	rep
	outsb
	ret

dsp_sound:
	dsp_do_more_fragments:	
		movl	file_dev_dsp, %ebx
		movl	$54, %eax
		movl	$0x8010500c, %ecx
		movl	$audio_buf_info, %edx
		int	$0x80

		movl	$audio_buf_info, %edx
		movl	(%edx), %eax		# get free nr of fragments
		cmpl	$0, %eax
		je	dsp_no_free_frags

			movl	8(%edx), %edx
			movl	$dsp_buf, %edi
	
			pushl	%edx
			movl	%edx, %ecx
			call	music
			popl	%edx
	
			movl	file_dev_dsp, %ebx
			movl	$4, %eax
			movl	$dsp_buf, %ecx
			int	$0x80

	jmp	dsp_do_more_fragments
	dsp_no_free_frags:

	ret

## lightning
	
lightning_pal:
	movb	$0, %al
	movw	$0x3c8, %dx
	outb	%al, %dx
	incw	%dx

	cmpl	$60, lght_fade
	jb	lght_pal_fade_out
	
		movb	$63, %al
		outb	%al, %dx
		outb	%al, %dx
		outb	%al, %dx

		ret
	lght_pal_fade_out:	
		movb	$0, %al
		outb	%al, %dx
		outb	%al, %dx
		outb	%al, %dx

		movl	lght_fade, %eax
		sarl	$2, %eax
	
		outb	%al, %dx
		outb	%al, %dx
		outb	%al, %dx
	
		sarl	$1, %eax
		movl	%eax, %ebx
		sarl	$1, %ebx
		addl	%ebx, %eax

		outb	%al, %dx
		outb	%al, %dx
		outb	%al, %dx
	
		subl	%ebx, %eax
		outb	%al, %dx
		outb	%al, %dx
		outb	%al, %dx
	
	ret
	
lightning:	
	call	clear

	decl	lght_fade
	jnz	no_new_lightning

		movl	$63, lght_fade

		pushl	%edi
		movl	$lightning_level_data, %edi

		movl	$0, %esi
		movl	$9, %ecx
		lght_init_level:
			movl	$40, %ebx
			call	random
			addl	$5, %edx

			addl	%edx, %esi
			cmpl	$200, %esi
			jle	lght_no_clip_y
			movl	$0, %edx
		  lght_no_clip_y:	
			shll	$16, %edx
			movl	%edx, (%edi, %ecx, 8)

			movl	$20000, %eax
			imull	%ecx				# max = 20000*level
			pushl	%eax
			movl	%eax, %ebx
			call	random
			popl	%eax
			sarl	$1, %eax
			subl	%eax, %edx
			movl	%edx, 4(%edi, %ecx, 8)		# stepsize = rnd(max)-max/2
		decl	%ecx
		jnz	lght_init_level

		movl	$160, %ebx
		call	random
		movl	%edx, %esi
		addl	$80, %esi
		shll	$16, %esi
		movl	%esi, lght_x

		popl	%edi

	no_new_lightning:

	# esi = x coordinate << 16

	movl	lght_x, %esi
	movl	$lightning_level_data, %ebx

	# render a few lines from top of screen to bottom
	movl	$9, %ecx
  lght_level:
		pushl	%ebx

		pusha
		pushl	%ebx
		movl	$10000, %ebx
		call	random
		subl	$5000, %edx
		popl	%ebx
		addl	%edx, 4(%ebx, %ecx, 8)
		addl	$0, (%ebx, %ecx, 8)
		popa

		movl	4(%ebx, %ecx, 8), %edx		# stepsize << 16 
		movl	(%ebx, %ecx, 8), %ebx		# height << 16
		shrl	$16, %ebx
		jz	lght_skip_line
	
		incl	%ebx
		# ebx = height
		# edx = stepsize << 16
	  lght_scanline:
			movl	%esi, %eax
			sarl	$16, %eax
	
			pushl	%edi
			addl	%eax, %edi

			movb	$3, %al
			stosb
			decb	%al
			stosb
			decb	%al
			pushl	%ecx
			decl	%ecx
			rep
			stosb
			popl	%ecx
			incb	%al
			stosb

			popl	%edi

			addl	$320, %edi
			addl	%edx, %esi
	
		decl	%ebx
		jnz	lght_scanline
	  lght_skip_line:	
		popl	%ebx	
	
	decl	%ecx
	jnz	lght_level	

	ret

	# input:	%esi = pointer to multiplytable
	#		%ecx = multiply factor (0..256)
lightning_fade:
	movb	$5, %ebx
  lght_next_color:	
	lodsw
	movl	%eax, %ebx
	movb	%cl, %al
	outb	%al, %dx
	movb	%bl, %al
	outb	%al, %dx
	movb	%bl, %al
	outb	%al, %dx
	movb	%bh, %al
	outb	%al, %dx
	
	ret

## random - return a random value in edx
## input:	%ebx = maximum
	
random:
	pushl	%ebx
	pushl	%ecx
	movl	rand, %eax
	movl	$23875213, %edx
	mull	%edx
	addl	$23875732, %eax
	andl	$(256*256*256-1), %eax
	movl	%eax, rand
	cdq
	divl	%ebx
	popl	%ecx
	popl	%ebx
	ret

## zoom_texture, c version by avoozl, ported to asm by smoke
## zooms a 256x256 texture and draw it on a 320 byte wide buffer
##
## input:	%esi:	SRCBUF (256x256x256)
##		%edi:	DESTBUF (320x?x256)
##		%ebx:	pointer to (x0, y0, x1, y1) 4+4+4+4 bytes
## on return everything is broken

## using the stack could take less bytes

zoom_texture:

	cmpl	$319, (%ebx)
	jge	zoom_bail_out
	cmpl	$199, 4(%ebx)
	jge	zoom_bail_out
	cmpl	$0, 8(%ebx)
	jle	zoom_bail_out
	cmpl	$0, 12(%ebx)
	jle	zoom_bail_out
	
	movl	%esi, zoom_src

	movl	zoom_u0, %eax
	movw	%ax, zoom_u
	movl	zoom_v0, %eax
	movw	%ax, zoom_v
	
	movl	zoom_u1, %eax
	subl	zoom_u0, %eax
	cdq
	movl	8(%ebx), %ecx
	subl	(%ebx), %ecx
	idivl	%ecx
	movw	%ax, zoom_u_step

	movl	zoom_v1, %eax
	subl	zoom_v0, %eax
	cdq
	movl	12(%ebx), %ecx
	subl	4(%ebx), %ecx
	idivl	%ecx
	movw	%ax, zoom_v_step

	# clipping

	cmpl	$0, (%ebx)
	jge	zoom_no_clip_x0
		movl	(%ebx), %eax
		imulw	zoom_u_step
		negl	%eax
		movw	%ax, zoom_u
		movl	$0, (%ebx)
  zoom_no_clip_x0:	

	cmpl	$0, 4(%ebx)
	jge	zoom_no_clip_y0
		movl	4(%ebx), %eax
		imulw	zoom_v_step
		negl	%eax
		movw	%ax, zoom_v
		movl	$0, 4(%ebx)
  zoom_no_clip_y0:	

	cmpl	$319, 8(%ebx)
	jle	zoom_no_clip_x1
		movl	$319, 8(%ebx)
  zoom_no_clip_x1:	

	cmpl	$199, 12(%ebx)
	jle	zoom_no_clip_y1
		movl	$200, 12(%ebx)
  zoom_no_clip_y1:	

	# set screen offset

	addl	(%ebx), %edi
	movl	4(%ebx), %eax
	sall	$6, %eax
	leal	(%eax,%eax,4), %eax		# dest += x+320*y
	addl	%eax, %edi

	movl	8(%ebx), %ecx
	subl	0(%ebx), %ecx
	movl	%ecx, zoom_width
		
	movl	12(%ebx), %ecx
	subl	4(%ebx), %ecx
	movl	%ecx, zoom_height
	zoom_ol:	
		pushl	%ecx

		xorl	%eax, %eax
		movl	zoom_src, %esi
		movw	zoom_v, %ax
		xorb	%al, %al
		addl	%eax, %esi
	
		movw	zoom_u, %bx
		movw	zoom_u_step, %dx
	
		## in the main loop we use
		##	%ecx:	loopcounter
		##	%ebx:	u (texture coord)
		##	%edx:	u_step

		movl	zoom_width, %ecx
		zoom_il:

			incl	%edi
			movw	%bx, %ax
			shrw	$8, %ax
			movb	(%esi, %eax), %al
			cmpb	zoom_bgcol, %al
			jz	zoom_il_transparent
				movb	%al, (%edi)
		  zoom_il_transparent:
			addw	%edx, %ebx
		
		loop	zoom_il

 		addl	$320, %edi
		subl	zoom_width, %edi

		movw	zoom_v_step, %ax
		addw	%ax, zoom_v
	
		popl	%ecx
	loop	zoom_ol
zoom_bail_out:
	xorl	%eax,%eax
	movl	$zoom_coord, %edi
	stosl
	stosl
	incl	%eax
	sall	$16, %eax
	stosl
	stosl
	
	ret

## sin_precalc - precalc sine table with 64k entries
## done by smoke
	
sin_precalc:
	
	movl	$65536, %ebx
	loopSin:	
	 	fldpi
		fimull	sin_x
		fidivl	sin_degrees
		fsin
		fimull	sin_scale
		fistpl	sin_temp
	
		movl	sin_temp,%eax
		movl	%eax,sine(,%ebx,4)

		incl	sin_x

	decl	%ebx 
	jge	loopSin

	ret

	
## road_to_nowhere - a simple road racing effect
## input:	%edi = screen

road_to_nowhere_pal:
	xorl	%ecx, %ecx
	movl	$road_pal, %edi
	movb	$0, %al
	stosb
	stosb
	stosb
	movb	$20, %al
	stosb
	stosb
	movb	$40, %al
	stosb
	movb	$64, %cl
	nogpal:
		movb	%cl, %al
		stosb
		stosb
		stosb
	loop nogpal
	movl	$road_pal, %esi
	movb	$192, %ecx
	movb	$0, %al
	call	vga_setpal
	ret
	
road_to_nowhere:
	xorl	%ecx, %ecx
	movl	graph_mem, %edi
	addl	$320*100, %edi
	movb	$100, %cl
  road_next_line:
		pushl	%ecx

		movl	$road_table, %esi
	
		pushl	%edi
		movl	%esi, %edi

		movl	%ecx, %eax
		sall	$1, %eax
		subl	frame_count, %eax
		subl	frame_count, %eax
		sarl	$3, %eax
		andb	$1, %al
		incb	%al
		movb	%al, 9(%edi)

		addl	$6, %edi
	
		# calc width
		movl	$2500, %eax
		movl	$30, %ebx
		addb	%cl, %bl
		cdq
		idivl	%ebx
	
		movl	%eax, %edx
		stosb
		leal	3(%edi),%edi
		stosb

		subl	$11, %edi

		# calc left border
		movl	frame_count, %ebx
		sall	$1, %ebx
		addl	%ecx, %ebx
		sall	$8, %ebx
		andl	$256*256-1, %ebx
		movl	sine(,%ebx,4), %ecx
		sarl	$9, %ecx

		movl	%ecx, %eax
		subl	%edx, %eax
		subl	$110, %eax
		movl	%eax, %ecx
		stosb
	
		addl	$15, %edi

		movw	$300, %ax
		subw	%dx, %ax	# subtract twice the width of
		subw	%dx, %ax	#          a side of the road
		subw	%cx, %ax	# subtract the left border
		stosb

		popl	%edi

		popl	%ebx		# return ECX in EBX
		pushl	%ebx
		sarl	$1, %ebx
		addl	$12, %ebx
	
		xorl	%eax, %eax
		xorl	%ecx,%ecx
		movb	$9, %cl
	  road_next_pixel:
			pushl	%ecx
			lodsb
			movb	%al, %cl
			lodsb
			imull	%ebx
			sarl	$2, %eax
			rep	
				stosb
			popl	%ecx
		decb	%cl
		jnz	road_next_pixel

		popl	%ecx
	decb	%cl
	jnz	road_next_line

	movb	$2, zoom_bgcol
	movl	graph_mem, %edi
	movb	$0, %al
	movl	$100*320, %ecx
	rep	
	stosb
	movl	graph_mem, %edi

	movb	$0, zoom_bgcol	
	movl	$road_text, %esi
	lodsb
	movzbl	%al, %ecx
	movl	frame_count, %edx
	shll	$1, %edx
	subl	$70*40, %edx
	call	scroller

	movb	$127, zoom_bgcol
	
	ret

## graaf_dup
## input:	%ecx = sqrt(amount of blocks)
##		%edi = destination (320x200)
##		%esi = source texture (256x256)
graaf_dup_pal:
	movl	$graaf_pal, %esi
	movl	$16*3, %ecx
	movb	$0, %al
	call	vga_setpal
	ret

graaf_dup1:
	movb	$2, zoom_bgcol	
graaf_dup0:
	sall	$11, %ecx
	movl	$graaf_texture, %esi

	pushl	%edi
	negl	%ecx
	movl	%ecx, %eax
	movl	$zoom_coord, %edi

	stosl
	stosl	
	negl	%eax
	stosl
	stosl
	popl	%edi

	movl	$127<<8, %eax
	addl	%eax, zoom_u0
	addl	%eax, zoom_u1
	addl	%eax, zoom_v0
	addl	%eax, zoom_v1

	addl	$32, %edi
	
	movl	$graaf_dup_coords, %ebx
	movl	$0, 0(%ebx)
	movl	$0, 4(%ebx)
	movl	$256, 8(%ebx)
	movl	$200, 12(%ebx)

	call	zoom_texture
	
	
	ret
	
## uncompress_graphics:	
##	the 16 color graphics have 2 pixels stored in one byte
##	this routine unpacks them into a 256x256 texture
##	(every source pixel is zoomed to 8x8 pixels)
	
## input:	%edi - destination texture (256x256x8BIT)
##		%esi - source graphic to decompress (32x32xPACKED)
	
uncompress_graphics:
	
	movb	$42, %dh
	ugfx_next_row:

		movb	$32, %dl
		ugfx_next_col:
	
			lodsb
			movb	%al, %bl
			andb	$15, %al
			shrb	$4, %bl

			movb	$6, %bh
			ugfx_next_block_line:

				xchg	%bl, %al
 				stosb
				stosb
				stosb
				stosb

				xchg	%bl, %al
 				stosb
				stosb
				stosb
				stosb

				addl	$256-8, %edi
	
			decb	%bh
			jnz	ugfx_next_block_line

			subl	$(6*256)-8, %edi
	
		decb	%dl
		jnz	ugfx_next_col

		addl	$(5*256), %edi
	
	decb	%dh
	jnz	ugfx_next_row

	ret

## grover_bounce - near/far effect with grover

grover_bounce_pal:
	movl	$grover_pal, %esi
	movl	$16*3, %ecx
	movb	$0, %al
	call	vga_setpal
	ret
	
grover_bounce:
	# we need

	movl	$grover_texture, %esi
	movb	$0, zoom_bgcol

	call	clear

	movl	grov_diff_z, %eax
	addl	%eax, grov_z
	cmpl	$250, grov_z
	jl	grov_not_far
		movl	$-1, grov_diff_z
	grov_not_far:
	cmpl	$50, grov_z
	jg	grov_not_near
		movl	$1, grov_diff_z
	grov_not_near:

	movl	grov_diff_x, %eax
	addl	%eax, grov_x
	cmpl	$128, grov_x
	jl	grov_not_right
		movl	$-4, grov_diff_x
	grov_not_right:	
	cmpl	$0, grov_x
	jg	grov_not_left
		movl	$4, grov_diff_x
	grov_not_left:

	# calc width
	movl	grov_z, %ebx
	leal	25(%ebx), %ebx
	movl	$16384, %eax
	cdq
	idivl	%ebx
	movl	%eax, %ecx

	movl	$grov_coord, %ebx

	# calc y
	movl	grov_x, %eax
	sall	$8, %eax
	movzwl	%ax, %eax
	movl	sine(,%eax,4), %edx
	sarl	$9, %edx
	subl	$15, %edx
	sall	$7, %edx
	movl	%edx, %eax
	cdq
	idivl	grov_z
	addl	$190, %eax

	movl	%eax, 4(%ebx)
	addl	%ecx, %eax
	movl	%eax, 12(%ebx)

	sarl	$1, %ecx
	
	# calc x
	movl	grov_x, %eax
	subl	$64, %eax
	sall	$7, %eax
	cdq
	idivl	grov_z
	addl	$160, %eax

	subl	%ecx, %eax
	movl	%eax, (%ebx)
	addl	%ecx, %eax
	addl	%ecx, %eax
	movl	%eax, 8(%ebx)

	call	zoom_texture

	ret

## scroller
##		%esi - string
##		%ecx - length of string in chars
##		%edi - screen
##		%edx - offset in pixels = (chars * width of char)
scroller:
	scrl_loop_char:

		xorl	%eax, %eax
		lodsb
		shll	$16, %eax
	
		pusha

		movl	$rendered_font, %esi
		addl	%eax, %esi

		movl	$coords, %ebx
		movl	%edx, (%ebx)
		addl	$40, %edx
		movl	%edx, 8(%ebx)

		sarl	$2, %edx
		addl	frame_count, %edx
		sall	$10, %edx
		andl	$256*256-1, %edx
		movl	sine(,%edx,4), %edx
		sarl	$11, %edx
		addl	$20, %edx
		movl	%edx, 4(%ebx)
		sall	$1, %edx
		addl	$32, %edx
		movl	%edx, 12(%ebx)

		movl	$(64*3)<<8, zoom_u1
		movl	$(32*5)<<8, zoom_v1

		call	zoom_texture
		popa

		addl	$44, %edx
	
	loop	scrl_loop_char
	ret
	
## mijn fijne routine
## maakt een letter op een 256x256 texture

make_letter_blocks:

	## this routine will write to edi
	## also fucks up esi

	movl $font_blocks, %edi
	leal 64*32-64(%edi), %esi
	movl $32, %ecx
	mlbl_vertloop:
	  pushl %ecx

		  ## hack hack
                  ## sinus shit goes here

	  movl %ecx, %edx
	  shll $1, %edx
	  xorl %ebx, %ebx

	  movl $64, %ecx
	  
	  mlbl_horloop:
	    xorb %al, %al
	    cmpl %edx, %ecx
	    jb mlbl_backgroundcolor
	      movb $1, %al
	    mlbl_backgroundcolor:
	    movb %al, 2*64*32(%edi, %ebx)
	    movb %al, 3*64*32(%esi, %ebx)
	    movb %al, 0*64*32-1(%edi, %ecx)
	    movb %al, 1*64*32-1(%esi,%ecx)
	    incl %ebx
	    decl %ecx
	    jnz mlbl_horloop

	    addl $64, %edi
	    subl $64, %esi
	  
	  popl %ecx
	  loop mlbl_vertloop

	addl $3*64*32, %edi
	incl %ecx
	shll $11, %ecx      # movl 2048, ecx
	movb $1, %al       # is misschien altijd zo?
	rep
	  stosb
	
	decb %al
	incl %ecx
	shll $11, %ecx
	rep
	  stosb

	movl $rendered_font, %edi
	movl $font_codes, %esi
	movb $27, %cl
	font_charloop:
	pusha

	## start of a column

	## load column datai

		movl $3, %edx
		font_colloop:
		lodsw

		movb $5, %cl
		font_rowloop:
			movl %eax, %ebx
			andb $7, %bl
			## bl is now the current block code number

			pusha
	
			movl $font_blocks, %esi
	
			andl $7, %ebx
	
			shll $11, %ebx
			addl %ebx, %esi

			movl $32, %ebx
			rhaa_loopy:
	
				movl $64, %ecx
				rep
				movsb
				addl $256-64, %edi

			decl %ebx
			jnz rhaa_loopy
	
			popa
			addl $256*32, %edi
			
			shrw $3, %ax
			decb %cl
		jnz font_rowloop
		subl $(256*32*5-64), %edi

		decl %edx
		jnz font_colloop
	
	popa
	addl $256*256, %edi
	addl $6, %esi
	loop font_charloop

	ret

sound_init_lightning:
	movb	$1, sound_lightning_on
	movw	$65535, lightning_noise
	ret
sound_init_wind:
	xorb	$1, sound_wind_on
	ret
sound_init_grover:
	xorb	$1, sound_grover_on
	ret
sound_init_tune:
	xorb	$1, sound_tune_on
	ret

## music
## input:	%edx - number of bytes to calculate
##		%edi - dsp_buffer
	
music:
	music_next_byte:

		# work out the sound effects
		incl	sound_outsize
		movl	sound_event_ptr, %eax
		movl	(%eax), %ebx
		cmpl	%ebx, sound_outsize
		jne	sound_no_action
			addl	$8, sound_event_ptr 
			movl	4(%eax), %eax
			call	*%eax	
		sound_no_action:

		pushl	%edx
		pushl	%edi

		xorl	%edi, %edi

		# eventually render the tune
		cmpb	$1, sound_tune_on
		jne	sound_no_tune
			movl    $music_pos, %ebx
			movl    (%ebx), %eax
			decl    %eax
			movl    %eax, (%ebx)
			jnz     music_not_next_note
				# set the duration till the next note in music_pos
				movl 	$1257, (%ebx)
	
				# increment the note counter
			  	movl	$music_note, %ebx
				movl	(%ebx), %edx
	
				incl	%edx
	
				cmpb	$192, %dl	# (loop music) not really needed
				je	music_end
					movl	%edx, (%ebx)
				music_end:
	
				# edx is the number of the new note, to be loaded in the
				# channel shit.
				# use notes melody[edx] and bass[edx>>1];
	
				movl	$channel, %edi
				# start writing to channel 0
		
				# clear eax so the top part is empty so we can use
				# it for adressing the step_lookup later on.
	
				movb	$4, %bl				# bl = channelnr.
				music_newnote_channel_loop:
	
					xorl	%eax, %eax
	
					cmpb	$4, %bl
					jne	music_newnote_bass_channel
						movb 	melody_data(%edx), %al	# note_number
						sarl	$1, %edx		# index/2
									# for bass
						jmp	music_newnote_continue
					music_newnote_bass_channel:
						movb	bass_data(%edx), %al
						addl	$96, %edx
					music_newnote_continue:	
	
					movb 	%al, %cl
					shrb 	$3, %cl			# freqstep_shifter
					andb	$7, %al			# note
	
					cmpb	$7, %al			# empty note ?
					jne	music_is_a_note
						cmpsl			# edi+=6
						cmpsw
						jmp	music_skip_empty_note
					music_is_a_note:	
		
						movw	step_lookup( ,%eax,2 ), %ax
			
						shll	%cl, %eax	# eax = step_value
	
						cld
						stosw			# store step
						movw	$5000, %ax
						cmpb	$4, %bl
						jne music_bass_volume
							addl $10000,%ax
						music_bass_volume:	
		
						stosw			# store volume
						cmpsw			# don't change pos
	
					# NOTE esi is fucked
					music_skip_empty_note:
	
				decb	%bl
				jnz	music_newnote_channel_loop
	
			music_not_next_note:
			
			## now we will calc/lookup the output for each of the channels
			## the channels are summed into edi
		
			movl	$channel, %esi
			xorl	%edi, %edi
	
			movb	$4, %cl
			music_loop_mix_channel:	
	
				# read the STEP
				lodsw
				movzwl 	%ax, %edx
	
				# channel now points to channel->volume
				lodsw
		
				# check against minimal volume
				cmpw	$3, %ax
				jng	music_dont_decrease_volume
					subw $2,  %ax
					movw	%ax, -2(%esi)	
				music_dont_decrease_volume:	
	
				# channel now points to channel->pos
				movzwl	(%esi), %ebx
	
				# so now dx=step, ax=volume, bx=position, esi=channel->pos
				addw	%dx, %bx
				movw	%bx, (%esi)
				addl	$2, %esi
		
				# new position has now been stored in the channel
				# time to lookup the sine for this position
				movw 	sine(,%ebx,4), %bx
		
				# mutliply to scale with volume ( bx * ax )
				imulw	%bx		# ax:dx = vol*amp
				movswl	%dx, %edx
				addl	%edx, %edi	# upperpart of edx is 0
		
			decb	%cl
			jnz	music_loop_mix_channel
	
			sarl	$8, %edi
		sound_no_tune:

		xorl	%eax, %eax

		# wind 
		cmpb	$1, sound_wind_on
		jne	sound_no_wind
			movl	$10000, %ebx
			call	random
			addw	%dx, weather_base_pos
			movzwl	weather_base_pos, %edx
			movl	sine(,%edx,4), %eax
			addw	$2, weather_amplify_pos
			movzwl	weather_amplify_pos, %edx
			movl	sine(,%edx,4), %ebx
			sarl	$4, %eax
			addl	$65536, %ebx
			imull	%ebx
			sarl	$23, %eax
		sound_no_wind:
		
		# white noise
		cmpb	$1, sound_lightning_on
		jne	sound_no_lightning
			xorl	%ebx, %ebx
			cmpw	$10, lightning_noise
			jb	sound_no_lightning
				subw	$6, lightning_noise
				movw	lightning_noise, %bx
				incl	%ebx
				pushl	%eax
				call 	random
				popl	%eax
				shrl	$12, %edx
				addl	%edx, %edi
		sound_no_lightning:

		addl	%edi, %eax
		# white noise
		cmpb	$1, sound_grover_on
		jne	sound_no_grover
			xorl	%ebx, %ebx
			subw	$8, lightning_noise
			movw	lightning_noise, %bx
			incl	%ebx
			pushl	%eax
			call 	random
			popl	%eax
			shrl	$12, %edx
			addl	%edx, %edi
		sound_no_grover:

		addl	%edi, %eax
		addb	$127, %al

		popl	%edi
		stosb				# store in the outputbuffer
		popl	%edx

	decl	%edx
	jnz	music_next_byte

	ret

leader:
	movl	lead_text_ptr, %esi
	addl	$50*320, %edi

	lodsb				# read X-offset
	movsbl	%al, %edx

	xorl	%eax, %eax
	lodsb				# read length

	# eventually update the text pointer to the next phrase
	andb	$127, %cl
	jne	leader_next_string
		addl	%eax, %esi
		movl	%esi, lead_text_ptr	
		ret
	leader_next_string:

	movzbl	%al, %ecx		# set length

	call	clear
	call	scroller

	ret
lead_text:	
		.byte	30,	6,	0,21,14,14,25,11 	# avoozl
		.byte	90,	3,	0, 13, 3		# and
		.byte	50,	5, 	18,12,14,10,4		# smoke
		.byte	10,	7,	15,17,4,18,4,13,19	# present

		.byte	50,	5,	11, 8, 13, 20, 23 	# linux

		.byte	70,	4, 	21, 8, 4, 17 
		.byte	90,	3,	13, 20, 11
		.byte	50,	5,	13, 4, 6, 4, 13
		.byte	90,	3,	25, 4, 18

		.byte	30,	6,	25, 14, 26, 3, 0, 13 	# zo dan


# format is . 1 byte xpos, 1 byte length, followed by data.
# until xpos is 0, which means 'next screen'

## helper functions
		
clear:
	pusha
	movl	graph_mem, %edi
	movl	$64000, %ecx
	movb	$0, %al
	rep
	stosb
	popa
	ret
	

