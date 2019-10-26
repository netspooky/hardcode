comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



	.data
	
texGenCallTbl	label dword
	TEX_END			= 0
		dd offset texMakeDone
		dd 0
	TEX_GEN_STREIFEN	= 1
		dd offset texGenStreifen
		dd 8
	TEX_GEN_PLASMA		= 2
		dd offset texGenPlasma
		dd 4
	TEX_FLT_BUMP		= 3
		dd offset texFltBump
		dd 3
	TEX_FLT_DISPLACE	= 4
		dd offset texFltDisplace
		dd 4
	TEX_MIX_MULTIPLY	= 5
		dd offset texMixMultiply
		dd 3
	TEX_MIX_BLEND		= 6
		dd offset texMixBlend
		dd 5
		
texRandMul	dd 0.001;

	
sampleTexScript label byte

		db TEX_GEN_STREIFEN
		db 5			; zielebene
		db 000h			; x and mask
		db 000h			; y and mask
		db 000h			; test mask
		db 190,181,126,0	; farbe

		db TEX_GEN_PLASMA
		db 0			; zielebene
		dw 386			; startwert
		db 128			; tiefe

		db TEX_GEN_STREIFEN
		db 1			; zielebene
		db 000h			; x and mask
		db 020h			; y and mask
		db 020h			; test mask
		db 64,64,64,0		; farbe

		db TEX_GEN_STREIFEN
		db 2			; zielebene
		db 000h			; x and mask
		db 0FFh			; y and mask
		db 048h			; test mask
		db 32,32,32,0		; farbe
		
		db TEX_MIX_BLEND
		db 3
		db 1
		db 2
		db 127
		db 127

		db TEX_FLT_BUMP
		db 4			; ziel
		db 0			; quelle
		db 2			; stärke

		db TEX_FLT_BUMP
		db 4			; ziel
		db 0			; quelle
		db 2			; stärke
		
		db TEX_MIX_MULTIPLY
		db 6
		db 0
		db 5

		db TEX_FLT_BUMP
		db 6			; ziel
		db 4			; quelle
		db 2			; stärke

		db TEX_FLT_BUMP
		db 6			; ziel
		db 3			; quelle
		db 1			; stärke
		
		db TEX_GEN_PLASMA
		db 7			; zielebene
		dw 386			; startwert
		db 128			; tiefe

		db TEX_FLT_DISPLACE
		db 0			; ziel
		db 7			; dispmap
		db 6			; pixelmap
		db 2			; glättung

		db TEX_END		; ende des texturscripts
		

	.data?

texGenLayerTbl	dd 32 dup(?)		; maximal 32 ebenen


	.code
	
        .mmx

;in edi immer zielebene übergeben

texGenStreifen	proc near
	mov	ecx,256*256-1
	
	streifloop:
       		mov     ebx,ecx
       		and	bl,[esi+1]		; x and maske
       		and	bh,[esi+2]		; y and maske
       		xor     bl,bh
		mov	eax,[esi+4]		; farbe
       		test    bl,[esi+3]		; test maske
       		jz      noclear
       		xor	eax,eax
	noclear:
		stosd

	dec	ecx
	jns	streifloop		
	
	ret
texGenStreifen	endp


texGenPlasma	proc near
	fild	word ptr [esi+1]	; startwert für random
	fmul	[texRandMul]
	fstp	[randseed]

	movzx	edx,byte ptr [esi+3]	; tiefe
depthloop:
	
	; plasma um zufällige werte erhöhen
	xor	ecx,ecx
randomYloop:
	xor	cl,cl	
randomXloop:
	mov	eax,edx
	call	randomi
	add	[edi+ecx*4],eax
	add	cl,dl
	jnz	randomXloop
	add	ch,dl
	jnz	randomYloop
	
	; zwischenwerte interpolieren
	push	edx
	mov	dh,dl
	shr	dh,1
intYloop:
	xor	cl,cl
intXloop:
	mov	ebx,ecx
	mov	eax,ecx
	; horizontal
	mov	esi,[edi+eax*4]
	push	esi
	add	al,dl
	mov	ebp,[edi+eax*4]
	add	esi,ebp
	shr	esi,1
	sub 	al,dh
	mov 	[edi+eax*4],esi
	
	; vertikal
	pop	esi
	;mov 	esi,[edi+ebx*4]
	add	bh,dl
	add 	esi,[edi+ebx*4]
	add	ebp,esi
	shr	esi,1
	sub	bh,dh
	mov 	[edi+ebx*4],esi
	
	; diagonal
	add	bh,dh
	add	bl,dl
	add	ah,dh
	add 	ebp,[edi+ebx*4]
	shr	ebp,2
	mov	[edi+eax*4],ebp

	; fertig
	add	cl,dl
	jnz	intXloop

	add	ch,dl
	jnz	intYloop

	; schrittweite halbieren und nochmal
	pop	edx
	shr	edx,1
	jnz	depthloop
	
	; farbig machen
	mov	ecx,256*256
	mov	esi,edi
colloop:
	lodsd
	mov	ah,al
	shl	eax,8
	mov	al,ah
	stosd
	loop	colloop
	
	ret
texGenPlasma	endp


texFltBump	proc near
	mov	bl,[esi+2]		; glättung
	mov	bh,bl
	add	bh,bh
	
	movzx	eax,byte ptr [esi+1]	; quelle
	mov	esi,[ecx+eax*4]
	
	pxor	mm7,mm7
	mov	eax,256*256-1
fltBumpLoop:
	sub	al,bl
	movd	mm0,[esi+eax*4]
	add	al,bh
	movd	mm1,[esi+eax*4]
	sub	al,bl
	sub	ah,bl
	movd	mm2,[esi+eax*4]
	add	ah,bh
	movd	mm3,[esi+eax*4]
	sub	ah,bl
	
	punpcklbw mm0,mm7
	punpcklbw mm1,mm7
	punpcklbw mm2,mm7
	punpcklbw mm3,mm7
	
	psubw 	mm0,mm1
	psubw 	mm2,mm3
	paddw	mm0,mm2
	
	movd	mm1,[edi+eax*4]
	punpcklbw mm1,mm7
	
	paddw	mm0,mm1
	packuswb mm0,mm7
	movd	[edi+eax*4],mm0
	
	dec	eax		
	jns	fltBumpLoop
	
	ret
texFltBump	endp


texFltDisplace	proc near
	movzx	eax,byte ptr [esi+2]	; pixelquelle
	mov	ebp,[ecx+eax*4]
	mov	dl,[esi+3]		; glättung
	mov	al,[esi+1]		; dispmap
	mov	esi,[ecx+eax*4]		; pointer holen
	
	mov	ecx,256*256-1
fltDispLoop:
	mov	ebx,ecx
	; x-versatz
	mov	al,[esi+ecx*4]
	push	eax
	add	cl,dl
	sub	al,[esi+ecx*4]
	add	bl,al			; verschiebung vornehmen
	sub	cl,dl
	; y-versatz
	pop	eax
	add	ch,dl
	sub	al,[esi+ecx*4]
	add	bh,al			; verschieben
	sub	ch,dl
	
	mov	eax,[ebp+ebx*4]		; pixel holen
	mov	[edi+ecx*4],eax		; und schreiben
	
	dec	ecx
	jns	fltDispLoop
	
	ret
texFltDisplace	endp


texMixMultiply	proc near
	movzx	eax,byte ptr [esi+1]	; quelle 1
	mov	edx,[ecx+eax*4]
	mov	al,[esi+2]		; quelle 2
	mov	ebx,[ecx+eax*4]
	mov	ecx,256*256-1
	pxor	mm2,mm2
mixMultLoop:
		movd	mm0,[edx+ecx*4]
		movd	mm1,[ebx+ecx*4]
		punpcklbw mm0,mm2
		punpcklbw mm1,mm2
		pmullw	mm0,mm1
		psrlw	mm0,8
		packuswb mm0,mm2
		movd	[edi+ecx*4],mm0
	dec	ecx
	jns	mixMultLoop
	ret
texMixMultiply	endp


texMixBlend	proc near
	movzx	eax,byte ptr [esi+1]	; quelle 1
	mov	edx,[ecx+eax*4]
	mov	al,[esi+2]		; quelle 2
	mov	ebx,[ecx+eax*4]

	; multi 1 -> mm3
	movsx	ax,byte ptr [esi+3]
	mov	ecx,eax
	shl	ecx,16
	or	eax,ecx
	movd	mm3,eax
	movq	mm5,mm3
	psllq	mm5,32
	por	mm3,mm5
	
	; multi 2 -> mm4
	xor	eax,eax
	movsx	ax,byte ptr [esi+4]
	mov	ecx,eax
	shl	ecx,16
	or	eax,ecx
	movd	mm4,eax
	movq	mm5,mm4
	psllq	mm5,32
	por	mm4,mm5
	
	mov	ecx,256*256-1
	pxor	mm2,mm2
mixBlendLoop:
		movd	mm0,[edx+ecx*4]
		movd	mm1,[ebx+ecx*4]
		punpcklbw mm0,mm2
		punpcklbw mm1,mm2
		pmullw	mm0,mm3
		pmullw  mm1,mm4
		psraw	mm0,7
		psraw	mm1,7
		paddw	mm0,mm1
		packuswb mm0,mm2
		movd	[edi+ecx*4],mm0
	dec	ecx
	jns	mixBlendLoop
	ret
texMixBlend	endp


; in	esi = offset to texturescript
texMakeTextures	proc near
	pusha
	
	mov	esi,offset sampleTexScript

	mov	ecx,16
	mov	edi,offset texGenLayerTbl
	push	edi
	layerallocloop:
		mov	eax,[heapptr]
		stosd
		add	eax,256*256*4
		mov	[heapptr],eax
	loop	layerallocloop
	
	mov	eax,[texGenLayerTbl]
	mov	[scenetexture.texdata],eax
	
	pop	ecx
	mov	ebx,offset texGenCallTbl
texMakeLoop:
	xor	eax,eax
	lodsb
	
	emms
	
	pusha
	movzx	edx,byte ptr [esi]	; nummer der zielebene
	mov	edi,[ecx+edx*4]		; und pointer auf dieselbe
	call	dword ptr [ebx+eax*8]	; maschine starten
	popa
	
	add	esi,[ebx+eax*8+4]

	jmp	texMakeLoop
	
texMakeDone::
	popa
	pop	eax	;rücksprungaddresse von TEX_END löschen
	
	popa
	ret
texMakeTextures	endp

        .586p
