;
; This demo was made by Zien/Nocturnal (Tom Robert Bryntesen)
; The texture code was ripped from "spark of hope" by 
; khamoon/Tube27.
;
; You can not use code from this into in any commercial products.
;

; vesa modes:
;   010dh = 1:5:5:5
;   010eh = 5:6:5
;   010fh = 8:8:8:8 ;123fps
;   0110h = hires


               .model small
			.386
			.code
			org  100h
begin:         jmp  main
;*****************************************************************************
;debug		equ	1

;------------- included ------------------------------------------------------
include structs.asm
include matrix.asm
include spline.asm
include plasma.asm
include tunnel.asm
include event.asm
include texture.asm

;------------- common floating point values ----------------------------------
f_256		dd	256.0
f_016          dd   0.166666
f_64k          dd   65536.0
dw_3           dw   3
dw_4           dw   4
dw_8           dw   8                   ;used by spline
dd_320		label dword
dw_320         dw   320
			dw	0
f_1024		dd	1024.0

;------------- camera spline data -------------------------------------------
spline_camerax dd      0.0,     0.0,   0.0,    0.0,    0.0, 2300.0, 3000.0, 3900.0,  4900.0, 5800.0, 7000.0
spline_cameray dd  -5200.0,  -300.0, -300.0, -20.0, -100.0, -100.0,-800.0,  -150.0,  -120.0,-100.0, -100.0
spline_cameraz dd      0.0,     0.0, 400.0,  800.0, 1200.0, 1500.0, 1700.0,  1300.0, 1800.0, 1600.0, 1600.0
spline_cam_ax  dd      3.0,     0.9 ,  0.6 ,   0.37 , 0.37,   0.77,  1.27,   1.0,    0.0,  -1.5,    -1.5
spline_cam_ay  dd      0.0,     0.0,   0.0,    0.0,   -1.0,   -1.6,  11.0,   -1.6,    -2.7, -1.6,   -1.5

spline_camerat tstruc    <0.0, 0.003, 12.0>
spline_camera  dw   5
               dw   offset spline_camerax
               dw   offset spline_cameray
               dw   offset spline_cameraz
               dw   offset spline_cam_ax 
               dw   offset spline_cam_ay 

spline_camerax2 dd      0.0,     0.0,   0.0,    0.0,   0.0,   0.0
spline_cameray2 dd   -200.0,  -50.0, -40.0,  -30.0,  -30.0,  -30.0
spline_cameraz2 dd      0.0,     0.0,   0.0,    0.0,   0.0,   0.0
spline_cam_ax2  dd      1.5,     1.5 ,  0.0 ,   0.0,   0.0,  -8.0
spline_cam_ay2  dd      16.0,    8.0,   4.0,    2.0,   1.0,  -0.5
spline_camerat2 tstruc    <0.0, 0.003, 12.0>
spline_camera2 dw   5
               dw   offset spline_camerax2
               dw   offset spline_cameray2
               dw   offset spline_cameraz2
               dw   offset spline_cam_ax2
               dw   offset spline_cam_ay2 

cameraPoints	point3	<0.0, 0.0, 0.0>
			point3	<-1.0, -0.625, 1.0>
			point3	<1.0, -0.625, 1.0>
			point3	<-1.0, 0.625, 1.0>

;
particle2Add	point3	<0.05, 0.32, 0.25>
;
plane_far		dd	1024.0;2048.0
ty_delta		dd	0.005	;1/200
yValue		dd	32.0
;
particlePos	point3	<-2024.0, -100.0, 1600.0>
aParticleDir	point3	<8.0, 0.0, 0.0>

;------------- memory stuff --------------------------------------------------
bufferSeg_r	dw	0
bufferSeg_g	dw	0
bufferSeg_b	dw	0
ligthMap		dw	0
textureSeg1    dw   0
textureSeg2    dw   0
textureSeg3    dw   0
extraSeg		dw	0

temp_dw        dw   0
temp_dd        dd   0

currentParticle	dw	0
;
;------------  plane values ------------------
ty			dd	0
l_t			dd	0.0

ldx			dd	0
ldy			dd	0
ldz			dd	0

rdx			dd	0
rdy			dd	0
rdz			dd	0

intersection_xl dd	0
intersection_yl dd	0
intersection_zl dd	0

intersection_xr dd	0
intersection_yr dd	0
intersection_zr dd	0
delta_x		dd	0
delta_y		dd	0
screen_y		dd	0
inv_color		dd	0
inv_color_rgb	dd	0;0a0e0f0h
;
;------------- stuff ---------------------------------------------------------
cameraWC		label 	point3
p0			point3	<>
p1			point3	<>
p2			point3	<>
p3			point3	<>

cameraMatrix	matrix	<>
cameraDist	label	point3
cameraPos		point3	<>
cameraAngleX	dd		0
cameraAngleY	dd		0
cameraAngle	point3	<>
cameraAngle2	point3	<>

particle_count	equ		256*2
particle_count2 dw		0;particle_count;0
particlesLocal	point3	particle_count dup(<>)
particleAngles dd		particle_count dup(0)
particleAnglesDelta dd	particle_count dup(0)
particles		point3	particle_count dup(<>)
particlesDir	point3	particle_count dup(<>)
;particleSpeed	dd		particle_count dup(0)
particlesWC	point3	particle_count dup(<>)
particlePos2	point3	<0.0, 0.0, 0.0>;1024.0>

particleAngle	point3	<>
particleMatrix matrix	<>

fooMatrix		matrix	<>
fooAngle		point3	<>

angle		dd	0

omni			dd	16*16 dup(0)
omni2		dd	16*16 dup(0)
omni_x		dd	0
omni_y		dd	0
particle_x	dd	0
particle_y	dd	0

plasma_points	db	22 dup(0)

splines_in_t   dd   0
splines_rel_t  dd   0
;
spline_val     dd   0
spline_t_1     dd   0
spline_t_3     dd   0
spline_3t_3    dd   0
spline_3t_2    dd   0
spline_3t_1    dd   0
;
texturePtr	dw	0
;
PIT_FREQ       equ  01234DDh
int_seg        dw   0
int_off        dw   0
;

frameNr		dw	0;3000;2200
;
FontOfs		dw	0
FontSeg		dw	0
;
hitVR		db	0
;
matrix_x       matrix    <>
matrix_y       matrix    <>
matrix_z       matrix    <>
matrix_trnstmp matrix    <>
matrix_multemp matrix    <>
;
textAlpha		db	0
horisonAlpha	dw	0
horisonColor	dd	08fcfffh;0a0e0f0h
;
random_init    dd   1010111000110111101010011011b
;
omniColor		db	100,115,155,0
omniColor2	db	155,100,115,0
;
screenWidth	dw	320/2
screenHeight	dw	200/2
;
dw_1neg		dw	-1
;
twirlFirstTime	db	1
f_32neg		dd	24.0
fooRadius		dd		290.0;1048576.0;1024.0
fooMul		dd		0.1
;
;------------- Matrix stuff --------------------------------------------------
dptr			equ	dword ptr
r0             equ  0*16
r1             equ  1*16
r2             equ  2*16
r3             equ  3*16
c0             equ  0
c1             equ  4
c2             equ  8
c3             equ  12
identity		dd	1.0, 0.0, 0.0, 0.0
			dd	0.0, 1.0, 0.0, 0.0
			dd	0.0, 0.0, 1.0, 0.0
			dd	0.0, 0.0, 0.0, 1.0
;--------------------------------------------
;text		db	"Horison by Zien",0
;text			db	"    Horison    ",0
text			db	"  Horison 4k   ",0

;--------------------------------------------
event_data  	label function
			function  <offset setCamera, 0, 2300>
			function  <offset setCamera2, 3000, 5500>
			function  <offset plane, 0, 2300>
			function  <offset plane, 3000, 5000>
			function  <offset display_tunnel, 2300, 3000>
			
			function  <offset updateParticle, 396, 2300>
			
			function  <offset updateTwirlParticles, 3000, 6000>
			;function  <offset updateParticle, 3000, 6000>

			function  <offset setInvParticleMatrix, 0, 5600>;2300>
			function  <offset setTunnelMatrix, 2300, 3000>
			function  <offset drawParticles,  0, 60000>

;	        	function  <offset inc_textAlpha, 128,128+255>
;        		function  <offset dec_textAlpha, 700,700+255>
	        	function  <offset inc_textAlpha2, 128,128+127>
        		function  <offset dec_textAlpha2, 700,700+127>

			function  <offset pre_drawText1, 128,700+127>
			
			
	        	function  <offset inc_textAlpha2, 2400,2400+127>
        		function  <offset dec_textAlpha2, 2800,2800+127>
			function  <offset pre_drawText2, 2400,2800+127>
	        	function  <offset inc_textAlpha2, 3450,3450+127>
        		function  <offset dec_textAlpha2, 3700,3700+127>
			function  <offset pre_drawText2, 3450,3700+127>

			function  <offset fadeOutPlane1, 3000-17, 3000>
			function  <offset fadeInTunnel1, 3000, 3000+51>

			function  <offset fadeInHorison, 777,777+255*4>
			
			function  <offset fadeOutPlane1, 2300-17, 2300>
			function  <offset fadeInTunnel1, 2300, 2300+51>

			function  <offset blit_8_8_8, 0, 5000>

			function  <offset exit, 4000, 5000>;3940, 5000>
;			function  <offset blit_565, 0, 4600>
;			function  <offset blit_555, 0, 4600>
;			function  <offset blit_fakeSvga, 0, 4600>
event_array    array     <27, offset event_data>

pre_drawText2:	mov	ax,((42*4)/16)+((320*4*(100-16))/16)
			jmp	drawText2
inc_textAlpha2:add	textAlpha,2
			ret
dec_textAlpha2:sub	textAlpha,2
			ret

pre_drawText1:	mov	ax,((42*4)/16)+((320*4*32)/16)
			jmp	drawText2
;inc_textAlpha: inc textAlpha
;			ret
;dec_textAlpha: dec textAlpha
;			ret

fadeInHorison: mov	eax,horisonColor
			movzx edx, horisonAlpha
			shr	edx,2
			push	ebx
			call	color_mul_24
			pop	ebx
			mov	inv_color_rgb,eax
			inc	horisonAlpha
			ret
fadeOutAlpha	db	255
fadeOutAdd	dd	0
fadeOutPlane1:	movzx edx,fadeOutAlpha
			mov	esi,fadeOutAdd
			call	fadeBuffer
			sub	fadeOutAlpha,0fh
			add	fadeOutAdd,0f0f0fh
			ret
fadeInTunnel1:	movzx edx,fadeOutAlpha
			mov	esi,fadeOutAdd
			call	fadeBuffer
			add	fadeOutAlpha,05h
			sub	fadeOutAdd,050505h
			ret

;*****************************************************************************
main:
; bufferSeg_r -> ligthMap = buffer
; textureSeg1 = texture
; textureSeg2 = tunnel
; textureSeg3 = tunnel

               mov	ax,cs
               add	ax,(1024*64/16)
               mov	ds:[bufferSeg_r],ax
               add	ax,256*256/16
               mov	ds:[bufferSeg_g],ax
               add	ax,256*256/16
               mov	ds:[bufferSeg_b],ax
               add	ax,256*256/16
               mov	ds:[ligthMap],ax
               add	ax,256*256/16
               mov	ds:[textureSeg1],ax
               add	ax,256*256/16
               mov	ds:[textureSeg2],ax
               add	ax,256*256/16
               mov	ds:[textureSeg3],ax
               add	ax,256*256/16
               mov	ds:[extraSeg],ax
               add	ax,1024*32/16
               cmp	ax,0a000h
               jae	exit2
               
			mov  ax,3508h
			int  21h                      ;save old timer adress
			mov  ds:[int_seg],es
			mov  ds:[int_off],bx
			mov  ax,2508h
               mov	dx,offset houseKeeper
			int  21h                      ;set new timer rutine
			mov  al,34h                   ;set timer to 23 ticks/sec
			out  43h,al
               mov  al,(PIT_FREQ/23)and 255
			out  40h,al
               mov  al,(PIT_FREQ/23)shr 8
               out  40h,al
               
               finit
               fnstcw    ds:temp_dw
               or        ds:temp_dw,0000110000000000b
               fldcw     ds:temp_dw                   ;enable chop mode

			mov	texturePtr,offset TexMakeTab11
			call	generateTexture

			;--- generate font ---
			; put text in tempSeg
			mov	ax,1130h				;Get system font table 
			mov	bh,6					;Font number (8x16)
			int	10h					;Call bios function
			mov	FontOfs,bp			;Save font table offset
			mov	FontSeg,es			;Save font table segment	
			mov	gs,fontSeg
			mov	es,textureSeg2;extraSeg;textureSeg2
			mov	cx,0ffffh/2
			xor	ax,ax
			xor	di,di
			rep	stosb
			mov	si,offset text
			mov	di,8
forEachLetter: lodsb
			and 	ax,0ffh
			jz	short endOfLine
			shl	ax,4			;16 bytes in each letter
			add	ax,fontOfs
			mov	bx,ax
			mov	cx,16		;for each line
forEachline:	mov	dl,gs:[bx]
			inc	bx
			mov	bp,8			;for each pixel in line
forEachPixel:	xor	ax,ax
			shl	dl,1
			jnc	short blackPixel
			dec	ax			;fills ax with 1'ns
blackPixel:	mov	es:[di+256*1],ax
			stosw			;fill 2x2 blocks
			dec	bp
			jnz	short forEachPixel
			add	di,256-16*1+256*1	;next line
			loop	forEachLine
			add	di,-256*16*2+16*1
			jmp	short forEachLetter
endOfLine:	xor	dx,dx
			mov	bp,3
			mov	ebx,edx
			call	Blur256				;blur text
			
			;--- sets up 32bit text ---
			;mov	es,textureSeg2
			mov	fs,extraSeg
			mov	gs,textureSeg1
			xor	si,si
			xor	di,di
			mov	cx,256*32
make32bitText:	mov	eax,gs:[di]
			movzx edx, byte ptr es:[si]
			call	color_mul_24
			mov	fs:[di],eax
			inc	si
			add	di,4			
			loop	make32bitText
			;--- end sets up 32bit text ---
			;--- end generate font ---
skipFont:
			mov	texturePtr,offset TexMakeTab8
			call	generateTexture

			push	cs
			pop	es

			call	generateOmni
			call	gen_tunnel2

               mov  ax,4f02h
               ;mov  bx,101h;010fh;010dh       ;640*480*256
               mov  bx,010fh ;32bit
               ;mov  bx,010dh ;15bit               
               ;mov  bx,010eh ;16bit               
               int  10h
               ;call	setFakeModeSvga
               
looping:		
			push	cs
			pop	es
			inc	frameNr
			mov	ax,frameNr
			mov	si,offset event_array
			call	event_do
			
			in   al,60h
			dec  al                  ;someone hugged ESC?
			jnz  looping

;----------------------------------------
exit:		in   al,21h                   ;set timer to 18.3 ticks/sec
			mov  dl,al
			mov  al,255
			out  21h,al
			mov  al,34h
			out  43h,al
			xor  ax,ax
			out  40h,al
               ;mov  al,ah
			out  40h,al
			mov  al,90h
			out  43h,al
			mov  al,dl
			out  21h,al
			mov  ax,2508h            ;restore old timer
			mov  dx,ds:[int_off]
			mov  ds,ds:[int_seg]
			int  21h
exit2:		mov  ax,03
			int  10h
			mov  ah,4ch
			int  21h                 ;exit			
			ret
;*****************************************************************************
;
; input:
;  esi = add value
;  edx = scale value
;
fadeBuffer	proc
			push	es
			mov	es,bufferSeg_r
			mov	bp,200
fadeBuffer_y:	mov	cx,320
			xor	di,di
fadeBuffer_x:	mov	eax,es:[di]
			call	color_mul_24
			add	eax,esi
			mov	es:[di],eax
			add	di,4
			loop	fadeBuffer_x
			mov	ax,es
			add	ax,320*4/16
			mov	es,ax
			dec	bp
			jnz	short fadeBuffer_y
			pop	es
			ret
fadeBuffer	endp
;*****************************************************************************
; sets the matrix for the particle in the tunnel
; also generates and updates particles
;
setTunnelMatrix	proc
			push	cs
			pop	es
			mov	si,offset cameraMatrix
			mov	di,offset identity
			call	matrix_load
			mov	si,offset cameraMatrix
			mov	di,offset particlePos2
			call	matrix_translate

			mov	si,offset particles
			mov	cx,particle_count
tunnelParticleUpdate:			
			fild dw_8
			fld	dword ptr ds:[si].point3_z
			faddp
			fcom 	f_1024			;ty<1.0
			fstsw	ax
			shr	ah,1
			jc	short tunnel_wrapz
			fsub	f_1024
tunnel_wrapz:	fstp	dword ptr ds:[si].point3_z
			add	si,size point3
			loop	tunnelParticleUpdate			
			ret
setTunnelMatrix	endp
;*****************************************************************************
; ax = offset into buffer in segments
;
drawText2		proc
			add	ax,bufferSeg_r
			mov	es,ax
			
			mov	fs,extraSeg
			mov	dx,32
drawTextY2:	xor	si,si
			xor	di,di
			mov	cx,256
			push	dx
drawTextX2:	mov	eax,fs:[si]
			movzx edx, textAlpha
			call	color_mul_24
			mov	edx,es:[di]
			call	color_add_24
			add	si,4
			mov	es:[di],eax
			add	di,4			
			loop	drawTextX2
			mov	ax,fs
			add	ax,256*4/16
			mov	fs,ax
			mov	ax,es
			add	ax,320*4/16
			mov	es,ax			
			pop	dx
			dec	dx
			jnz	short drawTextY2
			;cmp	textAlpha,255
			;je	jmp2ret
			;inc	textAlpha
			ret
drawText2		endp
;*****************************************************************************
generateRandomParticles	proc
			mov	cx,particle_count*3
			mov	si,offset particles
genRanParticle:push	cx
			mov	cx,10
			call	getRandom
			sub	eax,1024/2
			mov	temp_dd,eax
			fild	temp_dd
			fstp	dword ptr [si]
			add	si,4
			pop	cx
			loop	genRanParticle
			ret
generateRandomParticles	endp
;*****************************************************************************
;
setParticleDir2	proc
			push	cs
			pop	es
			mov	si,offset particleMatrix
			mov	di,offset identity
			call	matrix_load
			mov	si,offset particleMatrix
			mov	di,offset particleAngle
			call	matrix_rotate
			
			push	cx
			mov	cx,3
			mov	bx,offset particle2Add
			mov	di,offset particleAngle
particle2addloop:
			fld	dword ptr [bx]
			fadd	dword ptr [di]
			fstp dword ptr [di]
			add	bx,4
			add	di,4
			loop	particle2addloop
			pop	cx
			
			; update current particle
			imul	bx,currentParticle,size point3
			mov	di,bx
			mov	bp,bx
			add	bp,offset particles
			fldz
			fst  dword ptr ds:[bp]
			fst  dword ptr ds:[bp+4]
			fstp dword ptr ds:[bp+8]
			mov	bx,offset aParticleDir
			add	di,offset particlesDir
			call	matrix_transformVector

			inc	particle_count2
			inc	currentParticle
			cmp	currentParticle, particle_count
			jb	jmp2ret
			mov	currentParticle,0
			ret
setParticleDir2	endp
;*****************************************************************************
updateTwirlParticles	proc
			;push	cs
			;pop	es
			shr	twirlFirstTime,1
			jnc	short updateParticle;twirlSkipGenerate
			
			mov	texturePtr,offset TexMakeTab10
			call	generateTexture
			push	cs
			pop	es
			
			mov	inv_color_rgb,0
			
			fldz
			fst  dword ptr particlePos.point3_x
			fst  dword ptr particlePos.point3_y
			fstp dword ptr particlePos.point3_z
twirlSkipGenerate:

			;jmp	updateParticle
			;call	updateParticle
			;ret
updateTwirlParticles	endp
;-----------------------------------------			
updateParticle	proc
			mov	cx,9
updateParticleLoop:
			push	cx
			call	setParticleDir2
			pop	cx
			loop	updateParticleLoop

			mov	cx,particle_count*3
			mov	di,offset particles
			mov	bx,offset particlesDir
updatePloop:	fld	dword ptr ds:[bx]
			fadd dword ptr ds:[di]
			fstp dword ptr ds:[di]
			add	di,4
			add	bx,4			
			loop	updatePloop
			ret
updateParticle	endp
;*****************************************************************************
setInvParticleMatrix	proc
			mov	ax,cs
			mov	es,ax
			
			call	cameraNeg

			mov	si,offset cameraMatrix
			mov	di,offset identity
			call	matrix_load
			
			mov	si,offset cameraMatrix
			mov	di,offset cameraAngle2
			call	matrix_rotate
			mov	si,offset cameraMatrix
			mov	di,offset cameraAngle
			call	matrix_rotate
			mov	si,offset cameraMatrix
			mov	di,offset cameraPos
			call	matrix_translate

			mov	si,offset cameraMatrix
			mov	di,offset particlePos
			call	matrix_translate

			call	cameraNeg

			ret
setInvParticleMatrix	endp
;*****************************************************************************
cameraNeg		proc
			mov	si,offset cameraPos
			mov	cx,11
cameraNeg_loop:fld	dword ptr [si]
			fimul	dw_1neg
			fstp dword ptr [si]
			add	si,4
			loop	cameraNeg_loop
			ret
cameraNeg		endp
;*****************************************************************************
drawParticles	proc
			; draw points, particle system, whatever			
			mov	si,offset cameraMatrix
			mov	bx,offset particles
			mov	di,offset particlesWC
			mov	cx,particle_count
			cmp	cx,particle_count2
			jbe	transformParticlePoints2
			mov	cx,particle_count2
			cmp	cx,0
			je	jmp2ret
transformParticlePoints2:
			push	bx
			push	di
			push	si
			push	cx			
			call	matrix_transformVector
			fld	ds:[di].point3_z
			fistp temp_dd
			cmp	temp_dd,1
			jl	short particleOutOfScreen2
			fld		ds:[di].point3_x
			fimul	screenWidth
			fdiv		ds:[di].point3_z
			fistp	dword ptr ds:[particleStore1]+2
			fld		ds:[di].point3_y
			fimul	screenHeight
			fdiv		ds:[di].point3_z
			fistp	dword ptr ds:[particleStore2]+2
			;--- put pixel ---
particleStore1:mov	ebx,0
particleStore2:mov	ebp,0
			add	ebx,160
			add	ebp,100
			mov	si,offset omni
			test	cx,1
			jz	short omniOtherColor
			mov	si,offset omni+16*16*4
omniOtherColor:call	drawOmni			
			;--- end put pixel ---			
particleOutOfScreen2:
			pop	cx
			pop	si
			pop	di
			pop	bx			
			add	bx,size point3
			add	di,size point3
			loop	transformParticlePoints2
			ret
drawParticles	endp
;*****************************************************************************
;b,g,r
;omniColor		db	255,215,215
;omniColor		db	255,115,115
;omniColor		db	100,115,155
generateOmni	proc
			mov	di,offset omni
			mov	ch,-8
generateOmni_y:mov	cl,-8
generateOmni_x:mov	al,cl
			mov	dl,ch
			cmp	al,0
			jge	short generateOmniA1
			neg	al
generateOmniA1:cmp	dl,0
			jge	short generateOmniA2
			neg	dl
generateOmniA2:add	al,dl
			cmp	al,8
			jl	short generateOmniA3
			mov	al,8
generateOmniA3:mov	dl,7
			sub	dl,al			
			mov	al,dl
			shl	al,2
			mul	dl
			movzx edx,al
			mov	eax,dword ptr omniColor
			call	color_mul_24
			mov	es:[di]+16*16*4,eax
			mov	eax,dword ptr omniColor2
			call	color_mul_24
			stosd
			inc	cl
			cmp	cl,8
			jl	short generateOmni_x
			inc	ch
			cmp	ch,8
			jl	short generateOmni_y
			ret
generateOmni	endp
;*****************************************************************************
;
; ebx = x
; edx = y
; si = ptr to omniSprite
;
drawOmni		proc
			imul	eax,ebp,320*4
			shr	eax,4
			add	ax,bufferSeg_r
			mov	es,ax
			;mov	si,offset omni
			mov	ch,16
drawOmni_y:	cmp	ebp,200
			jae	short drawOmni_nexty
			mov	cl,16
			mov	di,bx
			shl	di,2
			push	si
drawOmni_x:	cmp	di,320*4
			jae	short drawOmni_nextx
			mov	eax,es:[di]
			mov	edx,[si]
			call	color_add_24			
			mov	es:[di],eax
drawOmni_nextx:add	si,4
			add	di,4
			dec	cl
			jnz	short drawOmni_x
			pop	si
drawOmni_nexty:mov	ax,es
			add	ax,320*4/16
			mov	es,ax
			add	si,16*4
			inc	ebp
			dec	ch
			jnz	short drawOmni_y
jmp2ret:		ret
drawOmni		endp
;*****************************************************************************
setCamera		proc
               mov  si,offset spline_camerat
               call tstruc_update

               mov  si,offset spline_camerat
               mov  eax,ds:[si].tstruc_t
               mov  si,offset spline_camera
               mov  di,offset cameraDist
               call splines_getVal

			fild	dw_3
			fadd	particlePos.point3_x
			fstp	particlePos.point3_x

			ret
setCamera		endp
;*****************************************************************************
setCamera2	proc
               mov  si,offset spline_camerat2
               call tstruc_update

               mov  si,offset spline_camerat2
               mov  eax,ds:[si].tstruc_t
               mov  si,offset spline_camera2
               mov  di,offset cameraDist
               call splines_getVal

			ret
setCamera2	endp
;*****************************************************************************
;
plane		proc
			;push	cs
			;pop	es;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			mov	si,offset cameraMatrix
			mov	di,offset identity
			call	matrix_load

			fld	cameraAngleX
			fstp	cameraAngle2.point3_x
			fld	cameraAngleY
			fstp	cameraAngle.point3_y

			;mov	si,offset cameraMatrix
			mov	di,offset cameraPos
			call	matrix_translate

			;mov	si,offset cameraMatrix
			mov	di,offset cameraAngle
			call	matrix_rotate
			;mov	si,offset cameraMatrix
			mov	di,offset cameraAngle2
			call	matrix_rotate
			

			;mov	si,offset cameraMatrix
			mov	bx,offset cameraPoints
			mov	di,offset cameraWC
			mov	cx,4
transformCameraPoints:
			call	matrix_transformVector
			add	bx,size point3
			add	di,size point3
			loop	transformCameraPoints

			push	0a000h
			pop	fs
			mov	screen_y,0
; for (double ty=0.0; ty<1.0; ty+= 1.0/height)
			fldz
			fstp	ty				;double ty=0.0
plane_for_y:	fld1
			fcomp	ty			;ty<1.0
			fstsw	ax
			shr	ah,1
			jc	jmp2ret

			;push	bx
			;push	cx
			xor	bx,bx
			mov	cx,3
planeLinecalc1:fld	p3.point3_x+bx
			fsub	p1.point3_x+bx
			fmul	ty
			fadd	p1.point3_x+bx
			fld 	st(0)
			fsub	p0.point3_x+bx
			fstp	ldx+bx
			fld	p2.point3_x+bx
			fsub	p1.point3_x+bx
			faddp					;tempx
			fsub	p0.point3_x+bx
			fstp	rdx+bx
			add	bx,4
			loop	planeLinecalc1			
			fld	plane_far
			fld	yValue
			fsub	p0.point3_y
			fdiv	ldy
			fst	l_t
			fsubp
			fidiv dw_4;dw_8
			fistp temp_dw
			cmp	temp_dw,0
			jg	short length_abs
			mov	temp_dw,0
length_abs:	xor	bx,bx
			mov	cx,3
planeLinecalc2:fld	ldx+bx
			fmul	l_t
			fadd	p0.point3_x+bx
			fmul	f_64k
			fistp intersection_xl+bx
			fld	rdx+bx
			fmul	l_t
			fadd	p0.point3_x+bx
			fmul	f_64k
			fistp intersection_xr+bx
			add	bx,4
			loop	planeLinecalc2
			;pop	cx
			;pop	bx

			movzx eax, temp_dw
			mov	temp_dd,eax
			
			mov	edx,011111111b
			sub	edx,eax
			mov	eax,inv_color_rgb
			call	color_mul_24
			mov	inv_color,eax
			
			;-- interpolate line --
			mov	eax,intersection_xr
			sub	eax,intersection_xl
			cdq
			idiv	dd_320
			mov	delta_x,eax
			mov	eax,intersection_zr
			sub	eax,intersection_zl
			cdq
			idiv	dd_320
			mov	delta_y,eax

			mov	fs,textureSeg1
			imul	eax,screen_y,320*4/16
			add  ax,bufferSeg_r
			mov	es,ax
			xor	di,di
			mov	cx,320

			mov	ebp,intersection_xl
			mov	esi,intersection_zl

			fldz
			fcomp	l_t
			fstsw	ax
			shr	ah,1
			jc	short blitLine
			mov	eax,inv_color_rgb
			rep	stosd
			jmp	short plane_for_next		
;-------------------------------------------------------
blitLine:		mov	eax,ebp					;intersection_xl
			shr	eax,(16-2)
			mov	ebx,esi					;intersection_zl
			shr	ebx,(16-9)
			and	eax,00111111100b
			and	ebx,001111111000000000b
			or	ebx,eax
			mov	eax,fs:[bx]				;get color from texture
			mov 	edx,temp_dd
			call	color_mul_24
			add	eax,inv_color
			stosd
			add	ebp,delta_x
			add	esi,delta_y
			loop	blitLine
			;-- interplate end --
plane_for_next:inc	screen_y
			fld	ty_delta
			fadd	ty
			fstp	ty				;ty+=1.0/height
			jmp	plane_for_y
plane		endp
;*****************************************************************************
; eax = a
; edx = b
; returns a*b in eax
; destroys ebx
;
color_mul_24	proc
			mov	ebx,eax
			and	eax,0111111110000000011111111b
			imul	eax,edx
			and	eax,011111111000000001111111100000000b
			and	ebx,01111111100000000b
			imul	ebx,edx
			and	ebx,0111111110000000000000000b
			or	eax,ebx
			shr	eax,8			
			ret
color_mul_24	endp
;*****************************************************************************
; eax = a
; edx = b
; returns a+b in eax
;
color_add_24	proc
			and	eax,0111111101111111011111110b
			and	edx,0111111101111111011111110b
			add	eax,edx
			mov	edx,eax
			and	edx,1000000010000000100000000b
			jz	jmp2ret
			imul	edx,0ffh
			shr	edx,8
			or	eax,edx
			ret
color_add_24	endp
;*****************************************************************************
;IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;bank_888		dw	0
blit_8_8_8	proc
waitForTimer:	cmp	hitVr,0
			je	short waitForTimer
			mov	hitVr,0


			xor	bp,bp
	          mov	ds,ds:[bufferSeg_r]
	          push	0a000h
	          pop	es
			jmp	short blit_888_start
blit_texture_8:xor	si,si
	          xor	di,di
			mov	cx,256*256/4
			rep	movsd
	          mov	ax,ds
	          add	ax,256*256/16
	          mov	ds,ax
blit_888_start:mov  dx,bp
               mov  ax,4f05h
               xor  bx,bx
               int  10h
               inc	bp
               cmp	bp,4
               jbe	short blit_texture_8
			push	cs
			pop	ds
	          ret
blit_8_8_8	endp
;ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
houseKeeper    proc near
			pusha
               inc  hitVR
			mov  al,20h
			out  20h,al
			popa
			iret
houseKeeper    endp
;*****************************************************************************






;*****************************************************************************
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
blit_555		proc
			xor	bp,bp
	          mov	ds,ds:[bufferSeg_r]
	          push	0a000h
	          pop	es
			jmp	short blit_555_start
blit_texture_5:xor	si,si
	          xor	di,di
			mov	cx,256/2
blit_555_y:	push	cx
			mov	cx,256
			xor	si,si
blit_555_x:	mov	eax,ds:[si]
			mov	edx,eax
			mov	ebx,eax
			shr	edx,16-10+3
			shr	ebx,8-5+3
			shr	eax,3
			and	edx,0111110000000000b
			and	ebx,01111100000b
			and	eax,011111b
			or	eax,edx
			or	eax,ebx
			mov	es:[di],ax
			add	si,4
			add	di,2
			loop	blit_555_x
			mov	ax,ds
	          add	ax,256*4/16;256*256/16
	          mov	ds,ax
			pop	cx
			loop	blit_555_y       
blit_555_start:mov  dx,bp
               mov  ax,4f05h
               xor  bx,bx
               int  10h
               inc	bp
               cmp	bp,2
               jbe	short blit_texture_5
			push	cs
			pop	ds
	          ret
blit_555		endp
;*****************************************************************************
blit_565		proc
			xor	bp,bp
	          mov	ds,ds:[bufferSeg_r]
	          push	0a000h
	          pop	es
			jmp	short blit_565_start
blit_texture_6:xor	si,si
	          xor	di,di
			mov	cx,256/2
blit_565_y:	push	cx
			mov	cx,256
			xor	si,si
blit_565_x:	mov	eax,ds:[si]
			mov	edx,eax
			mov	ebx,eax
			shr	edx,16-11+3
			shr	ebx,8-6+3
			shr	eax,3
			and	edx,01111100000000000b
			and	ebx,011111100000b
			and	eax,011111b
			or	eax,edx
			or	eax,ebx
			mov	es:[di],ax
			add	si,4
			add	di,2
			loop	blit_565_x
			mov	ax,ds
	          add	ax,256*4/16;256*256/16
	          mov	ds,ax
			pop	cx
			loop	blit_565_y       
blit_565_start:mov  dx,bp
               mov  ax,4f05h
               xor  bx,bx
               int  10h
               inc	bp
               cmp	bp,2
               jbe	short blit_texture_6
			push	cs
			pop	ds
	          ret
blit_565		endp
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
blueTable		dw	16 dup(0)
setFakeModeSvga	proc
               mov  ax,4f02h
               mov  bx,101h;010fh;010dh       ;640*480*256
               int  10h

			xor  ax,ax
			mov  dx,3c8h
			out  dx,al
			inc  dx
			
			mov	bh,0
setGreen1:	mov	cx,16
			mov	bl,0
setRed:		mov	al,bl
			shr	al,2
			out	dx,al
			xor	ax,ax
			out	dx,al
			mov	al,bh
			out	dx,al
			add	bl,17
			dec	cx
			jnz	setRed
			add	bh,7;8
			cmp	bh,32+16+8;64
			jb	setGreen1

			xor	bx,bx
setGreen2:	mov	cx,16
			mov	bl,0
setBlue:		xor	ax,ax
			out	dx,al
			mov	al,bl
			shr	al,2
			out	dx,al
			mov	al,bh
			out	dx,al
			add	bl,17
			dec	cx
			jnz	setBlue
			add	bh,7;8
			cmp	bh,32+16+8;64
			jb	setGreen2
			
			mov	di,offset blueTable
			mov	bx,1
			mov	cx,16
setBlueTable:	mov	al,bl
			shr	al,2
			mov	ah,bh
			shr	ah,2
			adc	ah,1
			test	ah,01000b
			jz	short blueTableOK
			mov	ah,0111b
blueTableOK:	add	ah,128
			shl	ax,4
			mov	cs:[di],ax
			add	di,2
			add	bl,2
			add	bh,2
			loop	setBlueTable
			
			ret
setFakeModeSvga	endp
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
drawTexture	proc
			mov	fs,cs:[textureSeg1]
			mov  es,cs:[bufferSeg_r]			
			xor	dx,dx
drawTextureY:	xor	si,si
			xor	di,di
			xor	cx,cx
drawTextureX:	mov	eax,fs:[si]
			mov	es:[di],eax
			add	si,4
			add	di,4
			inc	cx
			cmp	cx,128;320
			jb	drawTextureX
			
			mov	ax,es
			add	ax,320*4/16
			mov	es,ax
			mov	ax,fs
			add	ax,128*4/16
			mov	fs,ax			
			inc	dx
			cmp	dx,128;200
			jb	drawTextureY
			ret
drawTexture	endp
;*****************************************************************************
drawTexture8	proc
			mov	fs,extraSeg;cs:[textureSeg1]
			mov  es,cs:[bufferSeg_r]			
			xor	dx,dx
drawTexture8Y:	xor	si,si
			xor	di,di
			xor	cx,cx
drawTexture8X:	movzx eax,byte ptr fs:[si]
			mov	es:[di],eax
			add	si,1
			add	di,4
			inc	cx
			cmp	cx,256;320
			jb	drawTexture8X
			
			mov	ax,es
			add	ax,320*4/16
			mov	es,ax
			mov	ax,fs
			add	ax,256/16
			mov	fs,ax			
			inc	dx
			cmp	dx,128;200
			jb	drawTexture8Y
			ret
drawTexture8	endp
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

one_line		dw	320 dup(0)
two_line		dw	320 dup(0)

nextBank		dw	0
nextSeg		dw	0
diether		dd	0

diether_r		dd	0
diether_g		dd	0
diether_b		dd	0
color		dd	0
color_green	dd	0
color_blue	dd	0
blit_lineCount	dw	0
bank_888		dw	0
;
blit_fakeSvga	proc
			push	ds
			push	fs
			push	gs
	          mov	gs,cs:[bufferSeg_r]
	          push	0a000h
	          pop	es
			mov	bank_888,0
			mov  dx,0
               mov  ax,4f05h
               xor  bx,bx
               int  10h
			xor	si,si
	          mov	di,40*640
			mov	nextSeg,256*256/4
			mov	nextBank,(256*256-40*640)/2
	          mov	cx,320*200		;320*200*4/4
	          xor	ax,ax
	          xor	bx,bx
	          mov	diether_r,0
	          mov	diether_g,0
	          mov	diether_b,0
	          mov	blit_lineCount,200
blit_fake:	call	getLine
			mov	bp,offset one_line
			call	drawLine
			dec	blit_lineCount
			jnz	blit_fake
	          pop	gs
	          pop	fs
	          pop	ds
	          ret
	          ret
blit_fakeSvga	endp
;*****************************************************************************
getLine		proc
			mov	cx,320
			mov	bp,offset one_line
getLine_loop:	mov	eax,gs:[si]
			mov	ebx,eax
			and 	eax,0000011110000111100001111b		;eax = diether
			and 	ebx,0111100001111000011110000b		;ebx = values
			
			add	eax,diether
			test	eax,0000100000000000000000000b
			jz	short noRoverflow
			add	ebx,0000100000000000000000000b
			sub	eax,0000011110000000000000000b
noRoverflow:	test	eax,0000000000001000000000000b
			jz	short noGoverflow
			add	ebx,0000000000001000000000000b
			sub	eax,0000000000000111100000000b
noGoverflow:	test	eax,0000000000000000000010000b
			jz	short noBoverflow
			add	ebx,0000000000000000000010000b
			sub	eax,0000000000000000000001111b
noBoverflow:	mov	diether,eax
			
			test	ebx,1000000010000000100000000b
			jz	short noOverflow
			test	ebx,1000000000000000000000000b
			jz	short wrapDiether_r
			or	ebx,0111100000000000000000000b
wrapDiether_r:	test	ebx,0000000010000000000000000b
			jz	short wrapDiether_g
			or	ebx,0000000001111000000000000b
wrapDiether_g:	test	ebx,0000000000000000100000000b
			jz	short wrapDiether_b
			or	ebx,0000000000000000011110000b
wrapDiether_b:				
noOverflow:
			mov	eax,ebx
			
			shr	bx,3
			and	bx,0000011110b
			mov	dx,cs:[blueTable+bx]
			
			mov	ebx,eax
			shr	eax,16+4
			shr	ebx,8+4
			and	eax,01111b
			and	ebx,01111b
			mov	ah,bl
			add	ah,128
			or	ax,dx			
blit_no_overflow:
			mov	cs:[bp],ax	;eax
			xchg	al,ah
			mov	cs:[bp]+320*2,ax
			add	si,4
			add	bp,2
			
			dec	nextSeg
			jnz	blit_fake_seg
			mov	nextSeg,256*256/4
               mov	ax,gs
               add	ax,256*256/16
               mov	gs,ax
               xor	si,si
blit_fake_seg:
			
			dec	cx
			jnz	getLine_loop
			
			ret
getLine		endp
;--------------------------------------
drawLine		proc
			mov	cx,320*2/2
drawLine_loop:	mov	eax,cs:[bp]
			mov	es:[di],eax
			add	bp,4
			add	di,4			
			sub	nextBank,2
			jnz	blit_fake_bank
			mov	nextBank,256*256/2
			inc	bank_888
               mov  dx,bank_888
               mov  ax,4f05h
               xor  bx,bx
               int  10h
blit_fake_bank:dec	cx
			jnz	drawLine_loop

			ret
drawLine		endp
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
;input    cx = number of bits to generate
;output   eax = random number
;-------------------------------------------------
getRandom      proc
			push	bx
			push	edx
			xor  eax,eax
			mov  bl,byte ptr random_init
			and  bl,1
Gen_bit:       shl  eax,1
			mov  edx,random_init
			shr  edx,9
			xor  bl,dl
			shr  edx,5
			xor  bl,dl
			bt   ebx,1
			rcr  random_init,1
			setc bl
			or   al,bl
			loop gen_bit
			pop	edx
			pop	bx
			ret
getRandom      endp
;*****************************************************************************
IFDEF debug   ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
; Waitborder - Wait for next VR
Waitborder     PROC NEAR
               mov  dx,3dah
wbr1:          in   al,dx
               test al,8
               jnz  short wbr1
wbr2:          in   al,dx
               test al,8
               jz   short wbr2
			ret
Waitborder     ENDP
ENDIF               ;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;*****************************************************************************
			END	BEGIN







;*****************************************************************************
updateTwirlParticles	proc
			push	cs
			pop	es
			shr	twirlFirstTime,1
			jnc	twirlSkipGenerate
			
			mov	texturePtr,offset TexMakeTab10
			call	generateTexture
			push	cs
			pop	es
			
			mov	inv_color_rgb,0
			
			fldz
			fst  dword ptr particlePos.point3_x
			fst  dword ptr particlePos.point3_y
			fstp dword ptr particlePos.point3_z
			jmp	twirlSkipGenerate
			
			
			;---------------------------------
			; generate twirl particles
			; y=0; x=z=random
			; angle = 0
			; angleDelta = 1024 - length(x,z)
			;
			mov	cx,particle_count
			mov	di,offset particlesLocal
			mov	bp,offset particleAnglesDelta
twirlGenLoop:	push	cx
			mov	cx,8
			call	getRandom
			sub	eax,256/2
			mov	temp_dd,eax
			fld1
			fldz
			fstp	dword ptr ds:[di].point3_y
			fild	temp_dd
			fst  dword ptr ds:[di].point3_x			
			fmul st,st
			mov	cx,8
			call	getRandom
			sub	eax,256/2
			mov	temp_dd,eax
			fild	temp_dd
			fst 	dword ptr ds:[di].point3_z
			fmul	st,st
			faddp
			fsqrt
			fdiv fooRadius
			fsubr
			fmul	st,st
			fmul	st,st
			fmul	fooMul
			fstp	dword ptr ds:[bp]
			add	bp,4
			add	di,size point3
			pop	cx
			loop	twirlGenLoop			

twirlSkipGenerate:

			call	updateParticle
			ret


			xor	bp,bp
			xor	dx,dx
			mov	cx,particle_count
transformParticles:
			push	cx
			push	dx
			push	bp
			mov	si,offset fooMatrix;cameraMatrix
			mov	di,offset identity
			call	matrix_load
			fld	dword ptr [bp]+particleAngles
			fadd dword ptr [bp]+particleAnglesDelta
			fst	dword ptr [bp]+particleAngles
			fstp fooAngle.point3_y
			mov	si,offset fooMatrix
			mov	di,offset fooAngle
			pusha
			call	matrix_rotate
			popa
			
			mov	bx,offset particlesLocal
			mov	di,offset particles
			add	bx,dx
			add	di,dx
			call	matrix_transformVector
			pop	bp
			pop	dx
			add	dx,size point3
			add	bp,4
			pop	cx
			loop transformParticles
			ret
updateTwirlParticles	endp
;*****************************************************************************
