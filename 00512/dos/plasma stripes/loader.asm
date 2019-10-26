.386
.model tiny

	yummy MACRO zug
	local mode,ndn
	  mode = 1
	  irpc gz, zug
	    if mode eq 1
	      ndn = @InStr(,<0123456789ABCDEF>,&gz )+4Fh
	      mode = 2
	    else
	      db @InStr(,<0123456789ABCDEF>,&gz )+4Fh , ndn
	      mode = 1
	    endif
	  endm
	ENDM
	
	_xor_ax MACRO imm
	  db 35h
	  dw &imm
	ENDM
	
	_xor_al MACRO imm
	  db 34h,&imm
	ENDM


;==============================================
sort SEGMENT PUBLIC USE16
.startup
	
	db "SORT" ;)

	push 	2242h
	pop 	ax
	sub 	ax, 2120h
	_xor_al 4Ah
	push 	ax	;ax = 0168h
	
	pop 	bx
	push 	bx	;bx holds address of yummy code. do not modify
	
	pop 	sp	;set up sp the end of [buf]

;====the following is pushed on the stack:
;			cld
;@@loop:	lodsw				;read two bytes
;			cmp 	al, 0;
;			jnz @f
;			push 	bx			;payload
;			ret
;@@:		and 	ax, 2F2Fh	
;		 	shl 	ah, 4
;		 	or		al, ah
;		 	stosb				;write back one
;		jmp @@loop

;====push 041EEh
	push 	6321h
	pop 	ax
	sub 	ax, 2133h
	push 	ax			;ax == 41EE
;====push 0EBAAh
	sub 	ax, 5644h
	push 	ax			;ax == EBAA
;====push 0C40Ah
	push 	212Bh
	pop 	ax
	sub 	ax, 5D21h
	push 	ax			;ax == C40A
;====push 04E4h
	push 	2621h
	pop 	ax
	sub 	ax, 213dh
	push 	ax			;ax == 04E4
;====push 0C02Fh
	sub 	al, 7Eh 	;ax == 0466
	sub 	ax, 4437h
	push 	ax			;ax == C02F
;====push 2F25h
	push 	2F25h		;ax == C02F
;====push 0C353h
	_xor_ax 235Ch
	sub 	ax, 2020h
	push 	ax			;ax == C353
;====push 0275h
	push 	2321h
	pop 	ax
	_xor_ax 2154h
	push 	ax			;ax == 0275
;====push 3Ch
	push 	3Ch
;====push 0ADFCh
	push 	2121h
	pop 	ax
	sub 	ax, 7325h
	push 	ax
	
	pop 	sp	;get sp out of the code area (sp == ADFC)
	
	push 	bx
	pop 	di	;di=yummy
	push 	bx
	pop 	si	;si=yummy
	
	buf db ":D SATURN!!RAYGUN :D"
        
payload:
	yummy <B81300CD106800A007D9EEE9970060B80001CD167402CD2061D9E9DEC1D9C02E>
	yummy <DE361302D9FB2EDF061502DCC9DECA2EDF1EB5032EDF1EB3032E8306B503642E>
	yummy <8106B303A000BD3E018BC52E2B06B303F7E08BD88BC12E2B06B503F7E01BC32E>
	yummy <1306B103C1E8042EA3AF032EDF06AF03D9FAF7E13BC17C0B2EC12EAF03082EDE>
	yummy <0EAF032EDF1EAF0369F9400103FD2EA1AF03240F0428AA4D75AF490F856FFF2E>
	yummy <8306B10332B9C800E963FF77772200227777220022777722002277772200227E>
	yummy <10FEDCBA9876543210FEDCBA>

sort ENDS
end


