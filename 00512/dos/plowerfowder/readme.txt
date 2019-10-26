-- plowerfowder --

	a 501 byte ASCII entry for asmcompo.org compo #10
	by thefox <fuchs@runkkaajat.org> / aspekt  2004

-- what is it all about --

	it's a simple flower in 501 bytes. only ascii characters are
	used in the binary. this was accomplished by writing a loader
	(in loader.asm)	in ASCII which takes base64-encoded data as
	input, decodes the data to memory and runs it.

-- build how-to --

	the source code can be found under /src -directory

	what's required to build this:

		Microsoft (R) Macro Assembler ('ml.exe')
		Microsoft (R) Segmented Linker ('link.exe', used in make
			batch files as 'dlink.exe')
		Microsoft (R) C/C++ Compiler ('cl.exe')
		Microsoft (R) Incremental Linker ('link.exe')

	C-compiler and incremental linker (32-bit) are required only
	for building 256to64. you should be able to use any other
	C-compiler also.

	make_all.bat builds everything, first 256to64.exe, then
	demo.com and finally loader.com (which is the final executable)

	** DO NOT execute demo.com as its base address is not 100h **

	the binary from make_all.bat is 513 bytes, here's how to create
	a 501 byte binary:

		first run make_all.bat as normal (or make.bat if you have
		built 256to64 already)

		use hex-editor on demo.com stripping out the last six
		bytes (which should all be zeros)

		run make_phase2_only.bat

	if you want to build only 256to64, call make_256to64.bat

-- notes --

	256to64 is just a quick hack. it *will* produce 'broken' include
	files for some input file sizes. 'broken' means that the output
	file has got a last line 'byte ""' which masm will give an error
	about.

	demo itself (both loader.asm and demo.asm) could've been optimized
	a bit more also but reaching 512 bytes was enough for me this time.

-- public domain --

	yes. do anything you want with these files.
	i take no responsibility at all.

-- the binary --

	just for the heck of it, here's the demo once more (starting from
	'Z'-character, 'til the end of the file.

ZRRRfZhp!XP-Q PP]h]][(^ )^&[_f!U j$X, j Y(N*fkM @2N*f!U f1M EHuCGGGKu4GG S1.P6!X0$  %O0=0V2*O[MGNB\ SR(OXJO-)#$Z+WL'9WPI6Q/;@!'5!V=C=P=GH#D[8V?[9P=[H&D[8%D;8(E[9V>[9P]C WL'9V0!.Z-G^WL39R=[IWL+9V0).Q-G^WLG>3MC!1M@2R=DBV/O93M[*7M\$R=XF!D[>*%[?*$:+ 4"ZB^+W!KOX?@, QX$FC7V@_7ZUJ@^P!(HF=<"$"; *!(@FA(@F1@%!Z'5+'D;8D'5)W=C=9MC89M@:R=D:&D;8"%;>]N#?=4'$1HL11HD"@T  B0?@W0)&[MG8@\G9!0Q&#'Z!=@@ 1L<%"  ,!@8> &@?N@>@[ /:=0BHJ.S[^W0(/H"YB_8S9O/^'P>E_F#DA0_(N/[YS0 # ,,0  0 / !X  (  0 !M4@  $#;/P  )F9FUPH_VSPC.TD/