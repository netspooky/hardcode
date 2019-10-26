; Code Segment Wonder Land 256.
; by miURA==srw  2006/03/27-31
;
;	2ch party (http://2chparty.net/)
;


		org			100h



Width	equ		320
Height	equ		160

TextureSize		equ		128
TextureSizeBits	equ		7
OffsetTemp1		equ		12



{
	mov			al, 13h
	int			10h
	
	push		word 0a000h		;VRAM
	pop			es
	push		word 04000h		;バックバッファ
	pop			fs
	
	
	;
	;	main loop
	;
	{
		;
		;	バックバッファをクリア
		;
		push		es
		push		fs
		pop			es
		mov			ax, 9292h
		xor			di, di
		mov			cx, Width * Height / 2
		rep stosw
		pop			es
		
		
		mov			di, Data + OffsetTemp1
		mov			cx, TextureSize * TextureSize
		mov			ax, TextureSize / 2
		mov			word [di + 2], ax
		{
			fninit
			
			mov			bx, cx
			xor			ax, ax
			mov			al, byte [cs:bx]
			mov			word [di], ax
			fild		word [di]
			
			mov			ax, cx
			and			ax, TextureSize - 1
			shl			ax, 1
			mov			word [di], ax
			fild		word [di]				; texX
			fisub		word [di + 2]			; texX-size/2
			fadd		st1
			
			mov			ax, cx
			shr			ax, TextureSizeBits 
			mov			word [di], ax
			fild		word [di]
			fisub		word [di + 2]
			
			fld			st2			;texY
			
			;	texY, (texZ-size/2)*scale, (texX-size/2)*scale
			
			
			;	Y軸回転
			;	x' = cos(-t)*x + sin(-t)*z
			;	y' = y
			;	z' = -sin(-t)*x + cos(-t)*z
			fld			dword [di+8]
			fchs
			fsincos						; sin(-t), cos(-t), Y, Z, X
			fld			st1				; cos(-t), sin(-t), cos(-t), Y, Z, X
			fmul		st5				; cos(-t)*X, sin(-t), cos(-t), Y, Z, X
			fld			st1				; sin(-t), cos(-t)*X, sin(-t), cos(-t), Y, Z, X
			fmul		st5				; sin(-t)*Z, cos(-t)*X, sin(-t), cos(-t), Y, Z, X
			fadd		st1				; x'=cos(-t)*X+sin(-t)*Z, cos(-t)*X, sin(-t), cos(-t), Y, Z, X
			
			fxch		st2				; sin(-t), NN, x', cos(-t), Y, Z, X
			fmul		st6				; sin(-t)*X, NN, x', cos(-t), Y, Z, X
			fchs						; -sin(-t)*X, NN, x', cos(-t), Y, Z, X
			fxch		st3				; cos(-t), NN, x', -sin(-t)*X, Y, Z, X
			fmul		st5				; cos(-t)*Z, NN, x', -sin(-t)*X, Y, Z, X
			fadd		st3				; z'=-sin(-t)*X+cos(-t)*Z, NN, x', -sin(-t)*X, Y, Z, X
			ffree		st3				; z', NN, x', NN, y', Z, X
			ffree		st6				; z', NN, x', NN, y', Z
			ffree		st5				; z', NN, x', NN, y'
			fld			st4				; y', z', NN, x', NN, y'
			fld			st3				; x', y', z', NN, x', NN, y'
			ffree		st6				; x', y', z', NN, x'
			ffree		st4				; x', y', z'
			;つーか無駄ありすぎな希ガス
			
			;	Y軸平行移動
			fild		word [ObjTranslateY]	; Offset, x, y, z
			fadd		st2				; y', x, y, z
			fxch		st1				; x, y, n, z
			fld			st3				; z, x, y
			
			;	透視変換
			fxch		st2				; y, z, x
			fdiv		st1				; y/z, z, xs
			fld			st2				; x, y/z, z, x
			fdiv		st2				; x/z, y/z, z, x
			
			;	はぁ・・
			
			mov			word [di], Width
			fimul		word [di]		; width*px, py, z
			fxch		st1				; py, width*px, z
			fimul		word [di]		; height*py, width*px, z
			fxch		st1				; width*px, height*py, z
			
			
			
			fistp		word [di + 4]	;x
			cmp			word [di + 4], Width
			
			fxch		st1
			fistp		word [di + 6]	;y
			
			mov			ax, word [di + 6]	;y
			imul		bx, ax, Width
			mov			ax, word [di + 4]	;x
			add			bx, ax
			
			mov			si, cx
			mov			al, byte [cs:si]
			add			byte [fs:bx], al
			
			dec			cx
			jnz			not_end
			jmp			short break
		not_end:
			jmp			continue
		}
		
		fld			dword [ObjRotAngleDelta]
		fld			dword [di + 8]
		fadd		st1
		fst			dword [di + 8]
		
		
		;
		;	VRAMを更新(バックバッファ->VRAM転送)
		;
		push		ds
		push		fs
		pop			ds
		
		mov			si, 0
		mov			di, Width * ((200 - Height) / 2)
		mov			cx, Width * Height / 2
		rep	movsw
		
		pop			ds
		
		
		;
		;	ESCキーチェック
		;
		mov			ax, 0
		in			al, 60h
		cbw
		dec			ax
		jz			break
		jmp			continue
	}
	
	mov			al, 03h
	int			10h
	ret
}

ObjTranslateY		dw	40
ObjRotAngleDelta	dd	0.001
					db	'2chparty'
Data:

