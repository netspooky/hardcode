.text

#ifndef S_WIDTH
# define S_WIDTH 800
#endif
#ifndef S_HEIGHT
# define S_HEIGHT 600
#endif
#ifndef SDL_FLAGS
# define SDL_FLAGS 2
#endif
#ifndef S_RATIO
# define S_RATIO 0x3faaaaab
#endif

_loader_ehdr_main:
	.byte 127
	.ascii "ELF"
	.byte 1
	.byte 1
	.byte 1
	.byte 0
	.long 0
	.long 0
	.short 2
	.short 3
	.long 1
	.long _start
	.long _loader_ehdr_phdr0 - _loader_ehdr_main
	.long 0
	.long 0
	.short _loader_ehdr_mainE - _loader_ehdr_main
	.short _loader_ehdr_phdr1 - _loader_ehdr_phdr0
	.short ( _loader_ehdr_phdrE - _loader_ehdr_phdr0 ) / ( _loader_ehdr_phdr1 - _loader_ehdr_phdr0 )
	.short 0
	.short 0
	.short 0
_loader_ehdr_mainE:

.type	SDLSoundOut, @function
SDLSoundOut:
	pushal
	movl	40(%esp), %edi
	movl	44(%esp), %ecx
	shrl	$2, %ecx
	movl	_sdlout_pos, %esi
	leal	(%esi,%ecx), %eax
	cmpl	$3276799, %eax
	jle	_SDLSoundOut_copy
	movl	$3276800, %ecx
	subl	%esi, %ecx
	testl	%ecx, %ecx
	jle	_SDLSoundOut_clear

_SDLSoundOut_copy:
	addl	%ecx, _sdlout_pos
	leal	Clinkster_MusicBuffer(,%esi,4), %esi
	rep movsl
	jmp	_SDLSoundOut_end

_SDLSoundOut_clear:
	xorl %eax,%eax
	movl 44(%esp), %ecx
	rep stosb

_SDLSoundOut_end:
	popal
	ret

.type	rnd, @function
rnd:
	imull	$2147483629, rngState, %edx
	addl	$2147483587, %edx
	cmpl	$-1, %edx
	setae	%al
	movzbl	%al, %eax
	addl	%edx, %eax
	movl	%eax, rngState
	xorl	%edx,%edx
	divl	4(%esp)
	movl	%edx, %eax
	ret

.type	frnd, @function
frnd:
	pushl	$257
	call	rnd
	pushl   %eax
	fildl	(%esp)
	fidivl	.LC2
	addl	$8, %esp
	ret

frnd2:
	call frnd
	fadd	%st(0), %st
	fld1
	fsubrp	%st, %st(1)
	ret

// esi = buffer
// edi = program
// ebp = attrib sizes
setProgram:
	popl	%ebx

	pushl	%esi
	pushl	$34962
	call	*_loader_table+96

	pushl	%edi
	call	*_loader_table+80

	pushl	%ebp
	pushl	%edi
	call	selectLayout

	pushl	$.LC22
	pushl	%edi
	call	*_loader_table+128

	pushl	$uniforms
	pushl	$11
	pushl	%eax
	call	*_loader_table+28

	pushl	%ebx
	ret

selectLayout:
	pushal

	movl	40(%esp), %edi
	xorl	%esi, %esi
	movl	$3, %ebx
	movb	$48, attrName+1
_selectLayout_loop:
	pushl	$attrName
	pushl	40(%esp)
	call	*_loader_table+52
	movl	%eax, %ebp

	pushl	%eax
	call	*_loader_table+120

	leal	(,%esi,4), %eax
	pushl	%eax
	pushl	$44
	pushl	$0
	pushl	$5126
	movzbl	(%edi), %eax
	addl	%eax, %esi
	pushl	%eax
	pushl	%ebp
	call	*_loader_table+124

	addl	$36,%esp
	incb	attrName+1
	incl	%edi
	decl	%ebx
	jne	_selectLayout_loop

	popal
	ret


.globl	_start
.type	_start, @function
_start:
	movl $_loader_table,%edi
_loader_main:
	pushl %edi
	movl (%edi), %eax
	pushl %eax
	movl _loader_rdebug , %eax
	movl 4(%eax) , %eax
	movl 12(%eax) , %eax
	movl 12(%eax) , %eax
	pushl %eax
_loader_read_map:
	movl 8(%eax), %esi
	xorl %ecx,%ecx
_loader_dyntab_entry:
	lodsl
	testl %eax, %eax
	je _loader_dyntab_ok
	cmpl $1879047925, %eax
	cmovel (%esi) , %edx
	subl $4, %eax
	cmovel (%esi), %ecx
	decl %eax
	cmovel (%esi), %ebp
	decl %eax
	cmovel (%esi), %edi
	lodsl
	jmp _loader_dyntab_entry
_loader_dyntab_ok:
	movl %edi, %esi
	orl %ecx,%ecx
	je _loader_lgsc
	movl 4(%ecx) , %edi
	jmp _loader_check_symbol
_loader_lgsc:
	pushal
	movl	(%edx), %ecx
	movl	8(%edx), %ebx
	movl	4(%edx), %edi
	testl	%ecx, %ecx
	leal	16(%edx,%ebx,4), %eax
	leal	4(%ecx,%ebx), %ebx
	leal	(%edx,%ebx,4), %ebp
	cmovel	%ecx, %ebx
	je	lgsc_5
	leal	(%eax,%ecx,4), %esi
	xorl	%ebx, %ebx
lgsc_1:
	movl	(%eax), %edx
	testl	%edx, %edx
	je	lgsc_4
	subl	%edi, %edx
	leal	0(%ebp,%edx,4), %ecx
	movl	$1, %edx
	testb	$1, (%ecx)
	jne	lgsc_3
lgsc_2:
	incl	%edx
	testb	$1, -4(%ecx,%edx,4)
	je	lgsc_2
lgsc_3:
	addl	%edx, %ebx
lgsc_4:
	addl	$4, %eax
	cmpl	%esi, %eax
	jne	lgsc_1
lgsc_5:
	movl	%ebx,(%esp)
	addl	%edi,(%esp)
	popal
_loader_check_symbol:
	lodsl
	addl %ebp , %eax
	xorl %ecx, %ecx
_loader_read_char:
	movsbl (%eax), %edx
	incl %eax
	testb %dl, %dl
	je _loader_hashed_string
	movl %ecx, %ebx
	sall $1 , %ebx
	shrl $1, %ecx
	addl %ebx, %ecx
	addl %edx, %ecx
	jmp _loader_read_char
_loader_hashed_string:
	cmpl %ecx , 4(%esp)
	je _loader_found_symbol
	addl $12 , %esi
	decl %edi
	jne _loader_check_symbol
	popl %eax
	movl 12(%eax), %eax
	pushl %eax
	jmp _loader_read_map
_loader_found_symbol:
	lodsl
	popl %edi
	addl (%edi) , %eax
	popl %ecx
	popl %edi
	stosl
	movl (%edi), %edx
	testl %edx , %edx
	jne _loader_main

	pushl	$SDL_FLAGS
	pushl	$0
	pushl	$S_HEIGHT
	pushl	$S_WIDTH
	call	*_loader_table+88

	call	Clinkster_GenerateMusic

	pushl	$0
	pushl	$SDLSoundFmt
	call	*_loader_table+84

	xorl	%ebp, %ebp
	movl	%ebp, vbIndex
	movl	$150 , %edi
	movl	$lines, %ecx
.L17:
	// ebx <- vertices <- rnd(64)
	pushl	$64
	call	rnd
	leal	64(%eax), %ebx

	// lines[ i ].offset = offset
	movl	%ebp, (%ecx)
	addl	$4,%ecx
	// offset += ( lines[ i ].count = vertices );
	movl	%ebx, (%ecx)
	addl	$4,%ecx
	addl	%ebx, %ebp

	//vbTemp[ VB_LINE_OFFSET_X ] = 2.f * frnd( ) - 1.f;
	call	frnd2
	fstps	vbTemp+4

	//vbTemp[ VB_LINE_OFFSET_Y ] = 2.f * frnd( ) - 1.f;
	call	frnd2
	fstps	vbTemp+8

	//vbTemp[ VB_LINE_OFFSET_Z ] = 2.f * frnd( ) - 1.f;
	call	frnd2
	fstps	vbTemp+12

	//vbTemp[ VB_LINE_OFFSET_T ] = 2.f * frnd( ) - 1.f;
	call	frnd2
	fstps	vbTemp+16

	//vbTemp[ VB_COLOUR ] = frnd( );
	call	frnd
	fstps	vbTemp+32

	xorl	%esi,%esi
.L15:
	call	frnd2
	fidivl	.LC4
	fstps	vbTemp+20

	call	frnd2
	fidivl	.LC4
	fstps	vbTemp+24

	call	frnd2
	fidivl	.LC4
	fstps	vbTemp+28

	pushl	%esi
	fildl	(%esp)
	fstps	vbTemp

	pushal
	movl vbIndex, %eax
	leal vertices(,%eax,4) , %edi
	movl $vbTemp , %esi
	movl $11, %ecx
	addl %ecx, vbIndex
	rep movsl
	popal

	incl	%esi
	decl	%ebx
	jne	.L15

.L14:
	decl	%edi
	jne	.L17

	pushl	$initJunk
	pushl	$4
	call	*_loader_table+8

	pushl	$initJunk
	pushl	$4
	call	*_loader_table+24

	movl	$1, %ebx
.L19:
	pushl	%ebx
	pushl	$36386
	call	*_loader_table+112

	pushl	%ebx
	pushl	$34962
	call	*_loader_table+96

	movl	vbIndex, %eax
	sall	$8, %eax
	pushl	$35042
	pushl	$0
	pushl	%eax
	pushl	$34962
	call	*_loader_table+16

	pushl	%ebx
	pushl	$0
	pushl	$35982
	call	*_loader_table+32

	incl	%ebx
	cmpl	$4, %ebx
	jne	.L19

	pushl	$4
	pushl	$34962
	call	*_loader_table+96

	movl	vbIndex, %eax
	sall	$2, %eax
	pushl	$35044
	pushl	$vertices
	pushl	%eax
	pushl	$34962
	call	*_loader_table+16

	movl	vbIndex, %eax
	xorl	%edx,%edx
	movl	$11,%ecx
	divl	%ecx
	movl	%eax, vbIndex

	pushl	$34913
	call	*_loader_table+108

	pushl	$34370
	call	*_loader_table+108

	pushl	$3042
	call	*_loader_table+108

	movl	$.LC6, sources
	xorl	%ebx, %ebx
	xorl	%ebp, %ebp

.L23:
	pushl	shaderDefs(%ebx)
	call	*_loader_table+4

	leal	shaderDefs+8(%ebx) , %esi
	xorl	%eax,%eax
	xorl	%ecx,%ecx
.L21:
	incl	%ecx
	lodsb
	movl	shaderParts(,%eax,4), %edx
	movl	%edx, sources(,%ecx,4)
	decl	shaderDefs+4(%ebx)
	jne	.L21

.L20:
	incl	%ecx
	incl	%ebp

	pushl	$0
	pushl	$sources
	pushl	%ecx
	pushl	%ebp
	call	*_loader_table+100

	pushl	%ebp
	call	*_loader_table+36

	addl	$17, %ebx
	cmpl	$15, %ebp
	jne	.L23

	movl	$16, %ebx
	xorl	%esi,%esi
.L25:
	call	*_loader_table+76
	call	*_loader_table+76

	incl	%esi
	pushl	%esi
	pushl	%ebx
	call	*_loader_table+48

	leal	1(%ebx), %edi
	leal	9(%esi), %eax
	pushl	%eax
	pushl	%edi
	call	*_loader_table+48

	pushl	$15
	pushl	%edi
	call	*_loader_table+48

	pushl	$35980
	pushl	$varyings
	pushl	$3
	pushl	%ebx
	call	*_loader_table+12

	pushl	%ebx
	call	*_loader_table+20

	pushl	%edi
	call	*_loader_table+20

	addl	$2 , %ebx
	cmpl	$5, %esi
	jne	.L25

	call	*_loader_table+76
	pushl	$7
	pushl	$26
	call	*_loader_table+48
	pushl	$9
	pushl	$26
	call	*_loader_table+48
	pushl	$26
	call	*_loader_table+20

	call	*_loader_table+76
	pushl	$6
	pushl	$27
	call	*_loader_table+48
	pushl   $35980
	pushl	$varyings
	pushl	$3
	pushl	$27
	call	*_loader_table+12
	pushl	$27
	call	*_loader_table+20

	call	*_loader_table+76
	pushl	$6
	pushl	$28
	call	*_loader_table+48
	pushl	$8
	pushl	$28
	call	*_loader_table+48
	pushl   $35980
	pushl	$gVaryings
	pushl	$3
	pushl	$28
	call	*_loader_table+12
	pushl	$28
	call	*_loader_table+20

	pushl	$0
	call	*_loader_table+60

	call	*_loader_table+104
	movl	%eax, timeCurrent

	pushl	$0
	call	*_loader_table+40

.L26:
	call	*_loader_table+104
	subl	timeCurrent, %eax
	addl	%eax, timeCurrent
	addl	%eax, timeOffset
	cmpl	$75000, timeOffset
	jg	.L27

	fildl	c_ticklength
	fildl	c_timeoffset
	fildl	_sdlout_pos
	faddp	%st, %st(1)
	fimull	.LC0
	fdivp	%st, %st(1)
	// st(0) = musicPos

	xorl	%ebx,%ebx
.L57:
	pushl	%ebx
	fsts	(%esp)
	pushl	%ebx
	call	Clinkster_GetInstrumentTrigger
	// st(1) = musicPos , st(0) = instrumentTrigger
	fisubrl	.LC7
	fidivl	.LC7
	ftst
	fnstsw	%ax
	sahf
	jbe	.L64
	fsts	uniforms(,%ebx,4)
.L64:
	fstp	%st(0)
	incl	%ebx
	cmpl	$6, %ebx
	jne	.L57

	fildl	.LC10
	fcomip
	jbe	.L65

	fildl	lcPos
	fcomip
	ja	.L65

.L63:
	testb	$127, lcPos
	je	.L39
	pushl	timeOffset
	jmp	.L40

.L39:
	incl	curSeed
	pushl	$67108864

.L40:
	popl	transitionStart
	addl	$64, lcPos

.L65:
	fld	%st(0)
	fisubl	.LC11
	fidivl	.LC12
	fstps	uniforms+32

	fld	%st(0)
	fmuls	.LC13
	fildl	.LC14
	fcomip	%st(2)
	jbe	.L59

	fstp	%st(1)
	fsubrs	.LC15
	jmp	.L43

.L59:
	fildl	.LC16
	fcomip	%st(2)
	fstp	%st(1)
	jbe	.L60

	fsubs	.LC17
	jmp	.L43

.L60:
	fsubrs	.LC18

.L43:
	fstps	uniforms+36

	fildl	timeOffset
	fld	%st(0)
	fidivl	.LC19
	fstps	uniforms+24

	fildl	transitionStart
	fsubrp	%st(1)
	fidivl	.LC20
	fstps	uniforms+28

	// Aspect ratio!
	movl	$S_RATIO, uniforms+40

	pushl	$35977
	call	*_loader_table+108

	movl $4 , %esi
	movl curSeed , %edi
	leal 16(%edi,%edi), %edi
	movl $seedAttribSizes , %ebp
	call setProgram

	pushl	$1
	pushl	$36386
	call	*_loader_table+112

	pushl	$0
	call	*_loader_table+56

	pushl	vbIndex
	pushl	$0
	pushl	$0
	call	*_loader_table+136

	call	*_loader_table+116

	movl $3 , %esi
	movl $28 , %edi
	movl $renderAttribSizes , %ebp
	call setProgram

	pushl	$2
	pushl	$36386
	call	*_loader_table+112

	pushl	$0
	call	*_loader_table+56

	pushl	$3
	pushl	$0
	call	*_loader_table+0

	call	*_loader_table+116

	movl $1 , %esi
	decl %edi
	call setProgram

	pushl	$3
	pushl	$36386
	call	*_loader_table+112

	pushl	$0
	call	*_loader_table+56

	pushl	$1
	pushl	$0
	call	*_loader_table+0

	pushl	$2
	pushl	$34962
	call	*_loader_table+96

	pushl	$renderAttribSizes
	pushl	$27
	call	selectLayout

	pushl	$2
	pushl	$0
	call	*_loader_table+0

	call	*_loader_table+116

	pushl	$35977
	call	*_loader_table+68

	pushl	$16384
	call	*_loader_table+72

	pushl	$1
	pushl	$770
	call	*_loader_table+92

	movl $3 , %esi
	decl %edi
	call setProgram

	pushl	$3
	pushl	$0
	call	*_loader_table+0

	pushl	$771
	pushl	$770
	call	*_loader_table+92

	incl %esi
	movl curSeed, %edi
	leal 17(%edi,%edi), %edi
	movl $seedAttribSizes , %ebp
	call setProgram

	movl	$lines , %ebx
.L47:
	pushl	4(%ebx)
	pushl	(%ebx)
	pushl	$3
	call	*_loader_table+136
	addl	$8, %ebx
	cmpl	$lines+1200, %ebx
	jne	.L47

	call	*_loader_table+132

	pushl	$sources
	call	*_loader_table+44
	addl	$2116, %esp

	cmpb	$3, sources
	jne	.L26
	cmpl	$27, sources+8
	jne	.L26

.L27:
	call	*_loader_table+64

	// Exit
	movl $1 , %eax
	xorl %ebx, %ebx
	int $0x80

.type _loader_table , @object
_loader_table:
	.long 1791415934
	.long 25064179
	.long 4004342
	.long 2210949764
	.long 4012629
	.long 10092544
	.long 1617672600
	.long 4076940
	.long 156097101
	.long 62719254
	.long 19659261
	.long 7868833
	.long 25085159
	.long 2446535542
	.long 2952836492
	.long 19678546
	.long 80578
	.long 256483
	.long 40906
	.long 62661376
	.long 4076919
	.long 7866686
	.long 122947276
	.long 1599541
	.long 3996034
	.long 25334841
	.long 3139982
	.long 102576
	.long 1361182342
	.long 647068994
	.long 1642660014
	.long 515685118
	.long 1827148134
	.long 764672812
	.long 4014085
	.long 0

.type lcPos , @object
lcPos:
	.long	64

.type timeOffset , @object
timeOffset:
	.long 0

.type	shaderDefs, @object
.size	shaderDefs, 300
shaderDefs:
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	8
	.byte	5
	.byte	9
	.byte	6
	.byte	7
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	9
	.byte	5
	.byte	10
	.byte	6
	.byte	7
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	10
	.byte	5
	.byte	11
	.byte	6
	.byte	7
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	11
	.byte	5
	.byte	12
	.byte	6
	.byte	7
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	12
	.byte	5
	.byte	13
	.byte	6
	.byte	7
	.long	35633
	.long	2
	.byte	1
	.byte	14
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.long	35633
	.long	2
	.byte	3
	.byte	16
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.long	36313
	.long	2
	.byte	2
	.byte	15
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.long	35632
	.long	1
	.byte	17
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	8
	.byte	5
	.byte	9
	.byte	6
	.byte	18
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	9
	.byte	5
	.byte	10
	.byte	6
	.byte	18
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	10
	.byte	5
	.byte	11
	.byte	6
	.byte	18
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	11
	.byte	5
	.byte	12
	.byte	6
	.byte	18
	.long	35633
	.long	9
	.byte	1
	.byte	2
	.byte	3
	.byte	4
	.byte	12
	.byte	5
	.byte	13
	.byte	6
	.byte	18
	.long	35632
	.long	1
	.byte	19
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0

.type SDLSoundFmt , @object
SDLSoundFmt:
	.long	44100
	.short -32752
	.byte	2
	.byte	0
	.short	512
	.long	0
	.short	0
	.long	SDLSoundOut
	.long	0

.type	transitionStart, @object
.size	transitionStart, 4
transitionStart:
	.long	67108864

.type	renderAttribSizes, @object
.size	renderAttribSizes, 3
renderAttribSizes:
	.byte	4
	.byte	4
	.byte	3

.type	seedAttribSizes, @object
.size	seedAttribSizes, 3
seedAttribSizes:
	.byte	1
	.byte	4
	.byte	4

.type	attrName, @object
.size	attrName, 3
attrName:
	.byte	97
	.byte	97
	.byte	0

.LC23:
	.string	"g1"
.LC24:
	.string	"g2"
.LC25:
	.string	"g3"

.type	gVaryings, @object
.size	gVaryings, 12
gVaryings:
	.long	.LC23
	.long	.LC24
	.long	.LC25

.LC26:
	.string	"o1"
.LC27:
	.string	"o2"
.LC28:
	.string	"o3"

.type	varyings, @object
.size	varyings, 12
varyings:
	.long	.LC26
	.long	.LC27
	.long	.LC28

.LC6:
	.string	"#version 150\n"
.LC22:
	.string	"a"
.LC29:
	.string	"out vec4 o1,o2;out vec3 o3;"
.LC30:
	.string	"float w(float e){return fract(sin(e*12.9898)*43758.5453);}"
.LC31:
	.string	"mat2 f(float e){return mat2(cos(e),-sin(e),sin(e),cos(e));}"
.LC32:
	.string	"uniform float a[12];in float a0;in vec4 a1,a2;vec3 g(float e,vec3 d){"
.LC33:
	.string	";}vec3 h(float e,vec3 d){"
.LC34:
	.string	";}vec3 i(float e,vec3 d){vec3 v=mix(g(e,d),h(e,d),clamp(a[7],0.,1.));v.zy*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/3.31);return v;}void main(){float e=a[6]+a1.w*200.+a0*.0125;"
.LC35:
	.string	"vec3 d=a1.xyz+a2.xyz;o1=vec4(o3=i(e,d),1.),o3-=i(e-.01,d),e=(1.+a2.a)*64.,o2=vec4(pow(vec3(pow(a0/e,.25),.5*a0/e,.5*pow(a0/e-.5,2.)),vec3(1./(1.+a[3]))),.5+a[2]/2.),o3=vec3(o3.x+w(gl_VertexID+e),o3.y+.2,o3.z+w(gl_VertexID+a[6]))*.06;}"
.LC36:
	.string	"return vec3((4.+a[0])*cos(e),(4.+a[1])*sin(e),2.*sin(e)*cos(e*.7))+d*.5"
.LC37:
	.string	"e*=.25;return vec3(cos(4.*e)-pow(cos(3.*e),3.),sin(7.*e)-pow(sin(e),3.),cos(2.*e)-pow(sin(2.*e),3.))*vec3(2.+a[1],2.,3.+a[0])+d*.3"
.LC38:
	.string	"e*=.125;return vec3(cos(e*6.5)*sin(e),cos(e*26.)*cos(e),.5*(cos(e*.5)+a[0]*sin(e*7.)*cos(e)))*(5.+a[2])+d*.2*(a[1]+1)"
.LC39:
	.string	"e*=.125;return vec3(cos(e*13.)*sin(e),cos(e*13.)*cos(e),.5*(cos(e*.5)+a[0]*sin(e*7.)*cos(e)))*(5.+a[2])+d*.2*(a[1]+1)"
.LC40:
	.string	"e=e*.125+a[5];vec3 s=vec3(cos(e*13.)*sin(e),cos(e*13.)*cos(e),cos(e*13.)*sin(e*13.));return s*(5.+a[2])+d*.2*mix(s,vec3(1.),a[0])*(a[1]+1.)"
	.align 4
.LC41:
	.string	"return vec3(4.*pow(sin(e),3.),3.25*cos(e)-1.25*cos(2.*e)-.5*cos(3.*e)-.25*cos(4.*e),4.*sin(e*.25))+d*vec3(a[0],a[1],a[4])"
.LC42:
	.string	"in vec4 a0,a1;in vec3 a2;void main(){o1=a0,o2=a1,o3=a2;}"
.LC43:
	.ascii	"uniform float a[12];layout(points)in;layout(points,max_verti"
	.ascii	"ces=1)out;in vec4 o"
	.string	"1[1],o2[1];in vec3 o3[1];out vec4 g1,g2;out vec3 g3;void main(){float l=clamp(a[9],.015,.15);if(o2[0].w>l){g1=o1[0]+vec4(o3[0],0.),g2=o2[0]-vec4(0.,0.,0.,l),g3=mix(o3[0],vec3(w(o1[0].x+a[6])*.2,.5+w(o1[0].y+a[6])*.2,w(o1[0].z+a[6])*.2),.02);EmitVertex();}}"
.LC44:
	.ascii	"uniform float a[12];i"
	.string	"n vec4 a0,a1;out vec4 d,e;void main(){e=a0,e.xz*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/1.65),e.z-=40.,gl_Position=e*mat4(4.828427/a[10],0.,0.,0.,0.,4.828427,0.,0.,0.,0.,-1.0078125,-1.00390625,0.,0.,-1.,0.),d=a1,gl_PointSize=64.*(1.5-d.a*d.a)/(length(e)-30.);}"
.LC45:
	.string	"in vec4 d,e;out vec4 c;void main(){float a=length(gl_PointCoord-vec2(.5));if(a>.5)discard;c=vec4(d.xyz*d.a,mix((.5-a),2.*a*a,clamp(.5-(e.z+40.)/2.,0.,1.)))*d.a;}"
.LC46:
	.ascii	"o1=vec4(i(e,a1.xyz),1"
	.string	".),o1.xz*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/1.65),o1.z-=40.,gl_Position=o1*mat4(4.828427/a[10],0.,0.,0.,0.,4.828427,0.,0.,0.,0.,-1.0078125,-1.00390625,0.,0.,-1.,0.),e=.25*a2.a+(clamp(a[9],.015,.15)-.015)*5.55,o2=vec4(e,e,e,pow(a0/128.,2.)*(o1.z+45.)*.1);}"
.LC47:
	.string	"in vec4 o2;out vec4 c;void main(){c=o2;}"

_loader_ehdr_istr:
	.string "/lib/ld-linux.so.2"
_loader_ehdr_istrE:

_loader_ehdr_st0:
	.string "libGL.so.1"
_loader_ehdr_st1:
	.string "libSDL-1.2.so.0"
_loader_ehdr_stE:

.type	shaderParts, @object
.size	shaderParts, 80
shaderParts:
	.long	.LC6
	.long	.LC29
	.long	.LC30
	.long	.LC31
	.long	.LC32
	.long	.LC33
	.long	.LC34
	.long	.LC35
	.long	.LC36
	.long	.LC37
	.long	.LC38
	.long	.LC39
	.long	.LC40
	.long	.LC41
	.long	.LC42
	.long	.LC43
	.long	.LC44
	.long	.LC45
	.long	.LC46
	.long	.LC47

.LC0:
	.long	4
.LC7:
	.long	8
.LC4:
	.long	10
.LC12:
	.long	160
.LC2:
	.long	256
.LC14:
	.long	288
.LC16:
	.long	416
.LC11:
	.long	528
.LC10:
	.long	580
.LC19:
	.long	1000
.LC20:
	.long	3310

.LC13:
	.long	982138225
.LC15:
	.long	1041865114
.LC17:
	.long	1049876234
.LC18:
	.long	1058453586

_loader_ehdr_phdr0:
	.long 1
	.long 0
	.long _loader_ehdr_main
	.long 0
	.long _loader_ehdr_eots - _loader_ehdr_main
	.long _loader_ehdr_eobs - _loader_ehdr_main
	.long 7
	.long 1
_loader_ehdr_phdr1:
	.long 3
	.long _loader_ehdr_istr - _loader_ehdr_main
	.long _loader_ehdr_istr
	.long 0
	.long _loader_ehdr_istrE - _loader_ehdr_istr
	.long _loader_ehdr_istrE - _loader_ehdr_istr
	.long 7
	.long 1
	.long 2
	.long _loader_ehdr_dt0 - _loader_ehdr_main
	.long _loader_ehdr_dt0
	.long 0
	.long _loader_ehdr_dtE - _loader_ehdr_dt0
	.long _loader_ehdr_dtE - _loader_ehdr_dt0
	.long 7
	.long 1
_loader_ehdr_phdrE:

_loader_ehdr_dt0:
	.long 5
	.long _loader_ehdr_st0
_loader_ehdr_dt1:
	.long 1
	.long _loader_ehdr_st0 - _loader_ehdr_st0
_loader_ehdr_dt2:
	.long 1
	.long _loader_ehdr_st1 - _loader_ehdr_st0
_loader_ehdr_dt3:
	.long 6
	.long 0
_loader_ehdr_dt4:
	.long 21
_loader_rdebug:
	.long 0
_loader_ehdr_dt5:
	.long 0
_loader_ehdr_dtE:


.bss
.align 4
_sdlout_pos:	.zero 4
.align 4
curSeed:	.zero 4
.align 4
initJunk:	.zero 16
.align 4
sources:	.zero 40
.align 4
rngState:	.zero 4
.align 4
uniforms:	.zero 44
.align 4
vbTemp:		.zero 44
.align 4
lines:		.zero 1200
.align 4
vbIndex:	.zero 4
.align 4
vertices:	.zero 844800
.align 4
timeCurrent:	.zero 4
