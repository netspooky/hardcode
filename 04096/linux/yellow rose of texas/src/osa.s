	.file	"osa.c"
.globl param
	.data
	.align 32
	.type	param, @object
	.size	param, 153
param:
	.byte	0
	.byte	127
	.byte	102
	.byte	0
	.byte	0
	.byte	-5
	.byte	15
	.byte	0
	.byte	23
	.byte	8
	.byte	50
	.byte	102
	.byte	51
	.byte	0
	.byte	-33
	.byte	33
	.byte	0
	.byte	23
	.byte	12
	.byte	50
	.byte	102
	.byte	51
	.byte	5
	.byte	-7
	.byte	-15
	.byte	0
	.byte	23
	.byte	16
	.byte	0
	.byte	127
	.byte	51
	.byte	25
	.byte	-17
	.byte	64
	.byte	12
	.byte	25
	.byte	24
	.byte	0
	.byte	-112
	.byte	0
	.byte	15
	.byte	-10
	.byte	38
	.byte	-17
	.byte	25
	.byte	32
	.byte	25
	.byte	51
	.byte	35
	.byte	25
	.byte	-12
	.byte	12
	.byte	0
	.byte	23
	.byte	34
	.byte	0
	.byte	127
	.byte	51
	.byte	25
	.byte	-17
	.byte	12
	.byte	25
	.byte	38
	.byte	36
	.byte	0
	.byte	127
	.byte	51
	.byte	25
	.byte	-17
	.byte	-25
	.byte	25
	.byte	38
	.byte	40
	.byte	25
	.byte	51
	.byte	35
	.byte	25
	.byte	-10
	.byte	0
	.byte	25
	.byte	0
	.byte	44
	.byte	-25
	.byte	-51
	.byte	0
	.byte	25
	.byte	-10
	.byte	0
	.byte	38
	.byte	0
	.byte	46
	.byte	-25
	.byte	-51
	.byte	0
	.byte	25
	.byte	-7
	.byte	0
	.byte	115
	.byte	0
	.byte	47
	.byte	-25
	.byte	-51
	.byte	0
	.byte	25
	.byte	-5
	.byte	12
	.byte	64
	.byte	0
	.byte	48
	.byte	0
	.byte	0
	.byte	0
	.byte	25
	.byte	-17
	.byte	64
	.byte	5
	.byte	25
	.byte	56
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	-74
	.byte	-89
	.byte	56
	.byte	25
	.byte	57
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	23
	.byte	-89
	.byte	56
	.byte	25
	.byte	58
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	23
	.byte	-89
	.byte	56
	.byte	0
	.byte	59
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	125
	.byte	-89
	.byte	56
	.byte	0
.globl paramf
	.bss
	.align 32
	.type	paramf, @object
	.size	paramf, 36
paramf:
	.zero	36
.globl kukka
	.data
	.align 32
	.type	kukka, @object
	.size	kukka, 84
kukka:
	.long	0
	.long	1056964608
	.long	0
	.long	0
	.long	0
	.long	0
	.long	1036831949
	.long	-1102263091
	.long	0
	.long	1050253722
	.long	-1097229926
	.long	0
	.long	1056964608
	.long	-1097229926
	.long	0
	.long	1058642330
	.long	-1102263091
	.long	0
	.long	1058642330
	.long	-1090519040
	.long	0
.globl kukka_morph
	.align 32
	.type	kukka_morph, @object
	.size	kukka_morph, 84
kukka_morph:
	.long	0
	.long	1056964608
	.long	0
	.long	0
	.long	0
	.long	0
	.long	1045220557
	.long	-1102263091
	.long	0
	.long	1050253722
	.long	-1105618534
	.long	0
	.long	1045220557
	.long	0
	.long	0
	.long	1036831949
	.long	0
	.long	0
	.long	0
	.long	1036831949
	.long	0
	.section	.data.cst4,"aM",@progbits,4
	.align 4
.LC0:
	.long	919391437
	.align 4
.LC1:
	.long	926102323
	.align 4
.LC2:
	.long	1059481190
	.text
.globl analyysi
	.type	analyysi, @function
analyysi:
	xorl	%esi, %esi
	xorl	%ebx, %ebx
.L9:
	movw	(%edi,%ebx,2), %cx
	pushl	%ecx
	filds	(%esp)
	addl	$4, %esp
	fmuls	.LC0
	fstps	buf(,%ebx,4)
	movswl	%cx,%edx
	testl	%edx, %edx
	jns	.L7
	negl	%edx
.L7:
	cmpl	%esi, %edx
	jl	.L4
	movl	%edx, %esi
.L4:
	incl	%ebx
	cmpl	$1023, %ebx
	jle	.L9
	pushl	%esi
	filds	(%esp)
	addl	$4, %esp
	fmuls	.LC1
	flds	.LC2
	fmuls	max_sample
	faddp	%st, %st(1)
	fstps	max_sample
	cmpl	$47, beat
	jle	.L1
	movl	$0x0, %eax
	movl	%eax, max_sample
.L1:
	ret
	.size	analyysi, .-analyysi
	.section	.data.cst4
	.align 4
.LC5:
	.long	1077936128
	.align 4
.LC7:
	.long	-1073741824
	.align 4
.LC8:
	.long	1056964608
	.text
.globl splineTCP
	.type	splineTCP, @function
splineTCP:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$16, %esp
	movl	12(%ebp), %edx
	movl	16(%ebp), %ecx
	xorl	%eax, %eax
.L18:
	flds	8(%ebp)
	fadd	%st(0), %st
	fmuls	8(%ebp)
	flds	8(%ebp)
	fmul	%st(1), %st
	flds	8(%ebp)
	fmul	%st(0), %st
	fsts	-4(%ebp)
	fmuls	.LC5
	fsubr	%st, %st(1)
	fld1
	faddp	%st, %st(2)
	fxch	%st(1)
	fmuls	12(%edx,%eax,4)
	flds	-4(%ebp)
	fmuls	8(%ebp)
	fld	%st(0)
	fmuls	.LC7
	faddp	%st, %st(3)
	fxch	%st(2)
	fmuls	24(%edx,%eax,4)
	faddp	%st, %st(1)
	fxch	%st(1)
	fsubp	%st, %st(2)
	fxch	%st(1)
	fadds	8(%ebp)
	fld1
	fsubs	paramf+4
	fstps	-8(%ebp)
	fld1
	fadds	paramf+12
	fld1
	fsubs	paramf+8
	fsts	-12(%ebp)
	fmul	%st(1), %st
	flds	12(%edx,%eax,4)
	fsubs	(%edx,%eax,4)
	fmulp	%st, %st(1)
	fld1
	fsubs	paramf+12
	fld1
	fadds	paramf+8
	fld	%st(1)
	fmul	%st(1), %st
	flds	24(%edx,%eax,4)
	fsubs	12(%edx,%eax,4)
	fmul	%st, %st(1)
	fxch	%st(4)
	faddp	%st, %st(1)
	flds	-8(%ebp)
	fmulp	%st, %st(1)
	fmulp	%st, %st(5)
	flds	.LC8
	fmul	%st, %st(5)
	fxch	%st(6)
	faddp	%st, %st(5)
	fld1
	fsubrs	8(%ebp)
	flds	-4(%ebp)
	fmulp	%st, %st(1)
	fxch	%st(4)
	fmulp	%st, %st(1)
	fmulp	%st, %st(2)
	fmuls	-12(%ebp)
	flds	36(%edx,%eax,4)
	fsubs	24(%edx,%eax,4)
	fmulp	%st, %st(1)
	faddp	%st, %st(1)
	flds	-8(%ebp)
	fmulp	%st, %st(1)
	fmulp	%st, %st(1)
	fmulp	%st, %st(2)
	faddp	%st, %st(1)
	fstps	(%ecx,%eax,4)
	incl	%eax
	cmpl	$1, %eax
	jle	.L18
	leave
	ret
	.size	splineTCP, .-splineTCP
	.local	r.0
	.comm	r.0,12,4
	.local	r_morph.1
	.comm	r_morph.1,12,4
	.local	n.2
	.comm	n.2,12,4
	.local	rf.3
	.comm	rf.3,3264,32
	.section	.data.cst4
	.align 4
.LC10:
	.long	1031798784
	.align 4
.LC11:
	.long	1065353216
	.align 4
.LC12:
	.long	1028198363
	.align 4
.LC13:
	.long	1032805417
	.align 4
.LC14:
	.long	1056964608
	.align 4
.LC15:
	.long	1002740646
	.align 4
.LC16:
	.long	1058642330
	.align 4
.LC17:
	.long	1028443341
	.align 4
.LC18:
	.long	990057071
	.align 4
.LC19:
	.long	981668463
	.align 4
.LC20:
	.long	1064514355
	.align 4
.LC21:
	.long	1063172178
	.align 4
.LC22:
	.long	1062333317
	.align 4
.LC23:
	.long	1066192077
	.text
.globl spline3DMorph
	.type	spline3DMorph, @function
spline3DMorph:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$12, %esp
	xorl	%esi, %esi
	movl	$0, -16(%ebp)
.L36:
	xorl	%edi, %edi
.L35:
	pushl	%eax
	pushl	$r.0
	movl	-16(%ebp), %eax
	leal	(%eax,%eax,2), %ebx
	sall	$2, %ebx
	leal	kukka(%ebx), %eax
	pushl	%eax
	flds	.LC10
	pushl	%edi
	fimull	(%esp)
	fsts	-20(%ebp)
	fstps	(%esp)
	call	splineTCP
	addl	$12, %esp
	pushl	$r_morph.1
	addl	$kukka_morph, %ebx
	pushl	%ebx
	pushl	-20(%ebp)
	call	splineTCP
	xorl	%edx, %edx
	addl	$16, %esp
.L34:
	leal	(%esi,%esi,2), %eax
	addl	%edx, %eax
	flds	8(%ebp)
	fsubrs	.LC11
	fmuls	r.0(,%edx,4)
	flds	8(%ebp)
	fmuls	r_morph.1(,%edx,4)
	faddp	%st, %st(1)
	fstps	rf.3(,%eax,4)
	incl	%edx
	cmpl	$2, %edx
	jle	.L34
	leal	(%esi,%esi,2), %eax
	flds	.LC12
	pushl	%esi
	fimull	(%esp)
	addl	$4, %esp
	fsin
	fmuls	.LC13
	fstps	rf.3+8(,%eax,4)
	incl	%esi
	incl	%edi
	cmpl	$15, %edi
	jle	.L35
	incl	-16(%ebp)
	cmpl	$3, -16(%ebp)
	jbe	.L36
	movl	$0, -16(%ebp)
	leal	-1(%esi), %eax
	cmpl	%eax, -16(%ebp)
	jge	.L49
.L41:
	movl	-16(%ebp), %eax
	leal	(%eax,%eax,2), %ebx
	sall	$2, %ebx
	flds	rf.3+20(%ebx)
	fsubs	rf.3+8(%ebx)
	fstps	n.2
	flds	rf.3(%ebx)
	fsubs	rf.3+12(%ebx)
	fstps	n.2+4
	flds	rf.3+16(%ebx)
	fsubs	rf.3+4(%ebx)
	fstps	n.2+8
	fildl	-16(%ebp)
	fld	%st(0)
	fmuls	.LC14
	flds	timef
	flds	.LC15
	fld	%st(1)
	fmul	%st(1), %st
	faddp	%st, %st(3)
	fxch	%st(2)
	fsin
	fmuls	max_sample
	fld	%st(3)
	fmuls	.LC16
	fld1
	fadd	%st, %st(1)
	fxch	%st(2)
	fmulp	%st, %st(1)
	fmulp	%st, %st(3)
	fxch	%st(2)
	fadds	rf.3+4(%ebx)
	fstps	rf.3+4(%ebx)
	fld	%st(2)
	fmuls	.LC17
	fxch	%st(1)
	fmuls	.LC18
	faddp	%st, %st(1)
	fsin
	fmuls	max_sample
	fxch	%st(2)
	faddp	%st, %st(1)
	fmulp	%st, %st(1)
	fmuls	.LC19
	fadds	rf.3+8(%ebx)
	fstps	rf.3+8(%ebx)
	subl	$12, %esp
	pushl	$2896
	call	*mlEnable
	movl	$2977, (%esp)
	call	*mlEnable
	movl	$2929, (%esp)
	call	*mlEnable
	flds	paramf+16
	fld	%st(0)
	fmuls	.LC20
	fstps	8(%esp)
	fld	%st(0)
	fmuls	.LC21
	fstps	4(%esp)
	fmuls	.LC22
	fstps	(%esp)
	call	*mlColor3f
	movl	$n.2, (%esp)
	call	*mlNormal3fv
	movl	$9, (%esp)
	call	*mlBegin
	popl	%ecx
	popl	%edi
	flds	rf.3+4(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	movl	rf.3+8(%ebx), %eax
	xorl	$-2147483648, %eax
	pushl	%eax
	pushl	rf.3(%ebx)
	call	*mlVertex3f
	popl	%eax
	popl	%edx
	flds	rf.3+16(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	movl	rf.3+20(%ebx), %eax
	xorl	$-2147483648, %eax
	pushl	%eax
	pushl	rf.3+12(%ebx)
	call	*mlVertex3f
	popl	%ecx
	popl	%edi
	flds	rf.3+16(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	pushl	rf.3+20(%ebx)
	pushl	rf.3+12(%ebx)
	call	*mlVertex3f
	popl	%eax
	popl	%edx
	flds	rf.3+4(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	pushl	rf.3+8(%ebx)
	pushl	rf.3(%ebx)
	call	*mlVertex3f
	call	*mlEnd
	addl	$12, %esp
	movl	$0x0, %eax
	pushl	%eax
	pushl	%eax
	pushl	%eax
	call	*mlColor3f
	movl	$2896, (%esp)
	call	*mlDisable
	movl	$1, (%esp)
	call	*mlBegin
	popl	%ecx
	popl	%edi
	flds	rf.3+4(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	movl	rf.3+8(%ebx), %eax
	xorl	$-2147483648, %eax
	pushl	%eax
	pushl	rf.3(%ebx)
	call	*mlVertex3f
	popl	%eax
	popl	%edx
	flds	rf.3+16(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	movl	rf.3+20(%ebx), %eax
	xorl	$-2147483648, %eax
	pushl	%eax
	pushl	rf.3+12(%ebx)
	call	*mlVertex3f
	popl	%ecx
	popl	%edi
	flds	rf.3+16(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	pushl	rf.3+20(%ebx)
	pushl	rf.3+12(%ebx)
	call	*mlVertex3f
	popl	%eax
	popl	%edx
	flds	rf.3+4(%ebx)
	fmuls	.LC23
	fstps	(%esp)
	pushl	rf.3+8(%ebx)
	pushl	rf.3(%ebx)
	call	*mlVertex3f
	call	*mlEnd
	addl	$16, %esp
	incl	-16(%ebp)
	leal	-1(%esi), %eax
	cmpl	%eax, -16(%ebp)
	jl	.L41
.L49:
	leal	-12(%ebp), %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	leave
	ret
	.size	spline3DMorph, .-spline3DMorph
	.data
	.align 4
	.type	old_frame.4, @object
	.size	old_frame.4, 4
old_frame.4:
	.long	1000
	.align 4
	.type	light_ambient.5, @object
	.size	light_ambient.5, 16
light_ambient.5:
	.long	1045220557
	.long	1045220557
	.long	1045220557
	.long	0
	.local	rz.6
	.comm	rz.6,4,4
	.section	.data.cst4
	.align 4
.LC26:
	.long	944121029
	.align 4
.LC27:
	.long	1050253722
	.align 4
.LC28:
	.long	1048576000
	.align 4
.LC29:
	.long	1033476506
	.align 4
.LC30:
	.long	1064849900
	.align 4
.LC31:
	.long	983144857
	.align 4
.LC32:
	.long	1065353216
	.align 4
.LC39:
	.long	1099956224
	.align 4
.LC40:
	.long	1069547520
	.align 4
.LC42:
	.long	994643931
	.align 4
.LC44:
	.long	981467136
	.align 4
.LC45:
	.long	1056964608
	.align 4
.LC49:
	.long	981668463
	.text
.globl osa
	.type	osa, @function
osa:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	pushl	%esi
	pushl	%ebx
	subl	$12, %esp
	movl	8(%ebp), %edi
	pushl	%edi
	fildl	(%esp)
	addl	$4, %esp
	fstps	timef
	flds	.LC26
	fimull	counter
	fsubs	.LC27
	fmuls	.LC28
	fnstcw	-14(%ebp)
	movw	-14(%ebp), %ax
	movb	$12, %ah
	movw	%ax, -16(%ebp)
	fldcw	-16(%ebp)
	fistpl	beat
	fldcw	-14(%ebp)
	cmpl	$58, beat
	jle	.L51
	movb	$1, quit
.L51:
	flds	.LC29
	pushl	%edi
	fimull	(%esp)
	addl	$4, %esp
	fldcw	-16(%ebp)
	fistpl	-20(%ebp)
	fldcw	-14(%ebp)
	movl	-20(%ebp), %eax
	cmpl	old_frame.4, %eax
	je	.L50
	movl	%eax, old_frame.4
	xorl	%ebx, %ebx
.L63:
	movsbl	param+9(%ebx,%ebx,8),%eax
	cmpl	%eax, beat
	jge	.L55
	movl	$1, %ecx
.L62:
	movl	$paramf, %edx
	flds	.LC30
	flds	(%edx,%ecx,4)
	fmulp	%st, %st(1)
	leal	(%ebx,%ebx,8), %eax
	movsbw	param(%ecx,%eax),%ax
	pushl	%eax
	filds	(%esp)
	addl	$4, %esp
	fmuls	.LC31
	faddp	%st, %st(1)
	fstps	(%edx,%ecx,4)
	incl	%ecx
	cmpl	$9, %ecx
	jle	.L62
	jmp	.L54
.L55:
	incl	%ebx
	cmpl	$15, %ebx
	jbe	.L63
.L54:
	flds	paramf+32
	movl	$0x3f800000, %esi
	pushl	%esi
	subl	$12, %esp
	fsts	8(%esp)
	fsts	4(%esp)
	fstps	(%esp)
	call	*mlClearColor
	movl	$16640, (%esp)
	call	*mlClear
	movl	$5889, (%esp)
	call	*mlMatrixMode
	call	*mlLoadIdentity

        pushl   $1083292672
        pushl   $0
        movl    $1202590843, %eax
        movl    $1065646817, %edx
        pushl   %edx
        pushl   %eax
        pushl   $1065269329
        pushl   $-343597384
        pushl   $-1082214319
        pushl   $-343597384
        pushl   %edx
        pushl   %eax
        pushl   $-1081836831
        pushl   $1202590843
        call    *mlFrustum
        addl    $52, %esp

	pushl	$5888
	call	*mlMatrixMode
	call	*mlLoadIdentity
	addl	$12, %esp
	pushl	paramf+20
	movl	$0x0, %ebx
	pushl	%ebx
	pushl	%ebx
	call	*mlTranslatef
	pushl	%ebx
	pushl	%ebx
	pushl	%esi
	flds	paramf+24
	fchs
	fmuls	.LC39
	subl	$4, %esp
	fstps	(%esp)
	call	*mlRotatef
	flds	.LC40
	fmuls	paramf+28
	fadds	rz.6
	fsts	rz.6
	addl	$32, %esp
	pushl	%esi
	pushl	%ebx
	pushl	%ebx
	subl	$4, %esp
	fstps	(%esp)
	call	*mlRotatef
	addl	$16, %esp
	cmpl	$47, beat
	jg	.L64
	subl	$12, %esp
	pushl	$2896
	call	*mlDisable
	movl	$0x40400000, (%esp)
	call	*mlLineWidth
	xorl	%esi, %esi
	addl	$16, %esp
.L74:
	subl	$12, %esp
	pushl	$3
	call	*mlBegin
	xorl	%ebx, %ebx
	addl	$16, %esp
.L73:
	pushl	%ebx
	fildl	(%esp)
	subl	$12, %esp
	fsts	-24(%ebp)
	fmuls	.LC42
	fsin
	fsubrs	.LC32
	fsts	8(%esp)
	fsts	4(%esp)
	fstps	(%esp)
	call	*mlColor3f
	addl	$12, %esp
	pushl	$0xbe99999a
	pushl	buf(,%ebx,4)
	flds	-24(%ebp)
	fmuls	.LC44
	fsubs	.LC45
	fadd	%st(0), %st
	subl	$4, %esp
	fstps	(%esp)
	call	*mlVertex3f
	addl	$16, %esp
	incl	%ebx
	cmpl	$1023, %ebx
	jle	.L73
	call	*mlEnd
	pushl	$0x3f800000
	movl	$0x0, %eax
	pushl	%eax
	pushl	%eax
	pushl	$0x42b40000
	call	*mlRotatef
	addl	$16, %esp
	incl	%esi
	cmpl	$1, %esi
	jle	.L74
.L64:
	pushl	%eax
	pushl	$light_ambient.5
	pushl	$4608
	pushl	$16384
	call	*mlLightfv
	movl	$16384, (%esp)
	call	*mlEnable
	movl	$2903, (%esp)
	call	*mlEnable
	pushl	$0x3f800000
	movl	$0x0, %eax
	pushl	%eax
	pushl	%eax
	pushl	$0x41700000
	call	*mlRotatef
	xorl	%ebx, %ebx
	addl	$32, %esp
.L79:
	pushl	$0x3f800000
	movl	$0x0, %eax
	pushl	%eax
	pushl	%eax
	pushl	$0x41f00000
	call	*mlRotatef
	flds	.LC49
	movl	%edi, (%esp)
	fimull	(%esp)
	fsin
	fmuls	.LC45
	fadds	.LC45
	fstps	(%esp)
	call	spline3DMorph
	addl	$16, %esp
	incl	%ebx
	cmpl	$11, %ebx
	jle	.L79
.L50:
	leal	-12(%ebp), %esp
	popl	%ebx
	popl	%esi
	popl	%edi
	leave
	ret
	.size	osa, .-osa
	.comm	beat,4,4
	.comm	buf,4096,32
	.comm	max_sample,4,4
	.comm	timef,4,4
	.ident	"GCC: (GNU) 3.3.1 20030626 (Debian prerelease)"
