; ------------------------------------------------------
; 1kPack v0.6 - Depacker
; Written by Franck "hitchhikr" Charlet / Neural
; ------------------------------------------------------
; buildblock RELEASE
; CAPT "[SOURCEDIR]nasmw.exe" -f bin "%2" -o "%1.bin" -s -O9
; buildblockend

; !!! ONLY VALID FOR D3DX9_30.DLL !!!
; You'll have to modify this if you wnat to use another d3dx9 dll
D3DX_D3DXCompileShader					equ		0xda6de

;D3DX_GetTickCount						equ		(D3DX_D3DXCompileShader-0x574)
;D3DX_srand								equ		(D3DX_D3DXCompileShader-0x5c4)
;D3DX_rand								equ		(D3DX_D3DXCompileShader-0x5f8)
;D3DX_calloc							equ		(D3DX_D3DXCompileShader-0x664)
;D3DX_malloc							equ		(D3DX_D3DXCompileShader-0x66c)
;D3DX_GetModuleHandle					equ		(D3DX_D3DXCompileShader-0x528)

D3DX_exit								equ		(D3DX_D3DXCompileShader-0x5e8)
D3DX_GetProcAddress						equ		(D3DX_D3DXCompileShader-0x5a4)
D3DX_LoadLibrary						equ		(D3DX_D3DXCompileShader-0x5a0)
D3DX_QueryPerformanceCounter			equ		(D3DX_D3DXCompileShader-0x570)

D3DX_inflateinit						equ		(0x1ff446-D3DX_D3DXCompileShader)
D3DX_inflate							equ		(0x1ff464-D3DX_D3DXCompileShader)

;D3DX_D3DXCreateTextureFromFileInMemoryEx equ	(D3DX_D3DXCompileShader-0xc1341)

NBR_FUNCTIONS							equ		4

POS_fnc_exit							equ		0x410090
POS_fnc_D3DXCompileShader				equ		0x410094
POS_fnc_GetProcAddress					equ		0x4100b8
POS_fnc_LoadLibrary						equ		0x4100b4
POS_fnc_QueryPerformanceCounter			equ		0x4100bc

Z_FULL_FLUSH							equ		3

										bits	32

_SubSystem 								equ		2
_Image_Base 							equ		0x400000

start:									db		"MZ"							; 00
										mov		ebx, 0x41004b					; 02 (5)
										mov		ecx, ebx						; 07 (2) we need to load ecx as it is 0 under vista
										lea		eax, [ebx + (0x38 - 0x4b)]		; 09 (3) table_offsets
_PE_Header:								db		"PE"							; 0c (c: push eax / d: inc ebp)
										db		0, 0							; 0e must be 0 (e: add byte ptr [eax],al)
										db		0x4c, 0x1						; 10 machine 386 (10: dec esp / 11: add dword ptr [ecx],eax)
										dw		0x0001							; 12 Number of sections (13: add byte ptr [eax],al)
										db		0								; 14
										push	NBR_FUNCTIONS					; 15 (2)
										pop		ecx								; 17 (1)
										inc		esp								; 18 (1)
set_addresses_loop:						mov		edx, [ebx + (0x94 - 0x4b)]		; 1b (3) D3DXCompileShader
										mov		edi, edx						; 19 (2) save D3DXCompileShader
										jmp		core_loop						; 1e (2)
										dw		(_fOpt_Header - _Opt_Header) 	; 20 size of optional header
										dw		0x0303							; 22 Characteristics
_Opt_Header:							dw		0x010b							; 24 0x10b = PE32 0x20b = PE32+ (0x107 = ROM)
core_loop:								movzx	esi, byte [eax]					; 26 (3)
										inc		eax								; 29 (1)
										sub		edx, [ebx + esi]				; 2a (3) Calc the offset address Linker revision code here 27 Size of code 28
										mov		edx, [edx]						; 2d (2) Take the api address
										mov		[ebx + esi], edx				; 2f (3) SizeOfInitializedData/SizeOfUninitializedData 30
										jmp		do_loop							; 32 (2)

										dd		0x00010002						; 34 Entry Point 34

table_offsets:							db		(0x90 - 0x4b) - 0x70			; 38 BaseOfCode d3dx9 functions fixer offsets
										db		(0xb8 - 0x4b)
										db		(0xb4 - 0x4b)
										db		(0xbc - 0x4b)

										dd		((_PE_Header) - start)			; 3c BaseOfData (can also be used as PE offset at 0x3c (data:0x0c))
										
										dd		_Image_Base						; 40
										dd		0x10000							; 44 SectionAlignment (in memory)
										dd		0x00000200						; 48 FileAlignment (4b here)

z_stream_s:								dd		((packed_buf - 2) + 0x400000) - 0x4100 ; 4c next_in MajorOperatingSystemVersion/MinorOperatingSystemVersion
										dd		0								; 50 avail_in (fixed by the packer) MajorImageVersion/MinorImageVersion

										dd		4								; 54 total_in D3DXCompileShader MajorSubsystemVersion/MajorSubsystemVersion
										dd		0x00420000						; 58 next_out Reserved Win32VersionValue
										dd		0x00430000						; 5c avail_out SizeOfImage ??? <<< see a4
										dd		0x00010000						; 60 total_out SizeOfHeaders

do_loop:								loop	set_addresses_loop				; 64 (2) msg CheckSum
										inc		ebx								; 66 (1)
										push	ebp								; 67 (1) (that would be the method but we don't care)
										dw		_SubSystem						; 68 state Subsystem (add al,byte ptr [eax])
										dw      0                               ; 6a (2) DLL Characteristics (add byte ptr [eax],al)
										dd		0x00000000						; 6c zalloc SizeOfStackReserve (MUST be zero for zlib)
										dd		0x00000001						; 70 zfree SizeOfStackCommit (We need at least 1 for winmm.dll)
										dd		0x00000000					    ; 74 opaque SizeOfHeapReserve must be 0) IID
										jmp		depacker						; 78 (2) depack it
										dw		0x0000						    ; 7a data_type SizeOfHeapCommit
										dd		0								; 7c adler LoaderFlags
										dd		2								; 80 reserved NumberOfRvaAndSizes (must be 2)
										dd		0x0001009c						; 84 Export Table Name
										dd		0x00010094						; 88 Import Table IAT

										dd		0x00010078						; 8c IID entry Resource Table 
										dd		D3DX_exit						; 90 Exception Table
										dd		0x8000000e						; 94 Certificate & Table import e(D3DXCompileShader) or 2b(D3DXCreateTextureFromFileInMemoryEx)
										dd		0								; 98 Base Relocation Table
_fOpt_Header:
										db		"d3dx9_30"						; 9c Debug
										dd		0x00420000						; a4 <<< see 5c
										dd		0x00010000						; a8
										dd		0x00000200						; ac
										dd		0x00000031						; b0 also used as ZLIB_VERSION
										dd		D3DX_LoadLibrary				; b4
										dd		D3DX_GetProcAddress				; b8
										dd		D3DX_QueryPerformanceCounter	; bc
depacker:
										dec		byte [ebx + (0x70 - 0x4c)]		; c0 (4) SizeOfStackCommit = 0 (a NULL pointer is needed for zlib)
										; edi = D3DXCompileShader
										lea		esi, [edi + D3DX_inflateinit]	; (6)
										; zlib only tests the first char
										lea		eax, [ebx + (0xb0 - 0x4c)]		; (3)

										push	ebx								; (1) z_stream_s

										push	0x38							; (2) z_stream_s structure size
										push	eax								; (1) version
										push	ebx								; (1) z_stream_s
										call	esi								; (2) 
										add		esi, (D3DX_inflate - D3DX_inflateinit) ; (3)
										call	esi								; (2)
										push	dword [ebx + (0xa4 - 0x4c)]		; (3) c0 jump to the code at 420000 (used as stream header too)
										ret                                     ; (1) (used as stream header too)
packed_buf:
