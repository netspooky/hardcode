;<<<Endlogo_anzeigen>>>
;Zeigt das Endlogo an und beendet das Programm
;Ein: -
;Aus: -
Endlogo_anzeigen:
 push	cs
 pop	ds
 push	0B800h
 pop	es
 xor	di,di
 lea	si,Endlogo
 mov	dx,3DAh
 mov	bl,9
 mov	cx,4A4h			;L„nge des gepackten Logos
 cld
 xor	ax,ax
 mov	fs,ax
Logo_anzeigen:
 lodsb
 cmp	al,10h
 jae	Logo_anzeigen_2
 and	ah,0F0h
 or	ah,al
 jmp	Logo_anzeigen_10
Logo_anzeigen_2:
 cmp	al,18h
 je	Logo_anzeigen_3
 jnc	Logo_anzeigen_4
 sub	al,10h
 shl	al,2
 and	ah,8Fh
 or	ah,al
 jmp	Logo_anzeigen_10
Logo_anzeigen_3:
 mov	di,fs
 add	di,0A0h
 mov	fs,di
 jmp	Logo_anzeigen_10
Logo_anzeigen_4:
 mov	bp,cx
 mov	cx,1
 cmp	al,19h
 jne	Logo_anzeigen_7
 lodsb
 xchg	al,cl
 mov	al,20h
 dec	bp
 jmp	Logo_anzeigen_8
Logo_anzeigen_7:
 cmp	al,1Ah
 jne	Logo_anzeigen_9
 lodsb
 dec	bp
 xchg	al,cl
 lodsb
 dec	bp
Logo_anzeigen_8:
 inc	cx
Logo_anzeigen_9:
 rep	stosw
 mov	cx,bp
Logo_anzeigen_10:
 loop	Logo_anzeigen
 mov	ah,4Ch
 int	21h

Endlogo	db 0Fh,10h,19h,4Fh,18h,19h,6,8,0DCh,0DBh,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah
 db 5,0DBh,0DCh,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,20h,20h,8,0DCh,0DBh,0DBh
 db 0DBh,7,0DBh,0DBh,0DBh,0Fh,0DBh,0DBh,20h,20h,8,1Ah,3,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,0Ah,0DBh,8,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,7,0DBh,19h,0Bh,18h,19h,5,8
 db 0DCh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,0DFh,19h,2,8,0DBh,7,0DBh,0Fh,0DBh,8
 db 0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah
 db 3,0DBh,7,0DBh,0DBh,0Fh,1Ah,0Ah,0DBh,0DFh,20h,20h,8,0DBh,0DBh,0DBh,7,0DBh
 db 0DBh,0DBh,0Fh,1Ah,3,0DBh,0DFh,19h,10h,18h,19h,4,8,0DCh,0DBh,0DBh,0DBh,7
 db 0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,19h,2,8,0DCh,0DBh,0DBh,7,0DBh,0Fh,0DBh,8,0DBh
 db 0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,8,0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh
 db 19h,4,8,1Ah,3,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,19h,2,8,0DBh,0DBh,0DBh,7
 db 0DBh,0DBh,0DBh,0Fh,0DBh,0DBh,0DFh,19h,12h,18h,19h,3,8,0DCh,0DBh,0DBh,7,0DBh
 db 0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,19h,2,8,0DBh,0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh,8
 db 0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,6,0DBh,19h,6,8,0DCh,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,3,0DBh,19h,2,8,1Ah,3,0DBh,7,0DBh,0Fh,1Ah,3,0DBh,8,0DBh,7,0DBh,0Fh,1Ah,4
 db 0DBh,19h,0Bh,18h,19h,3,8,0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,3,0DBh,19h,2
 db 0DBh,0DBh,0DBh,0DFh,19h,2,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,0DFh
 db 19h,6,8,0DBh,0DBh,0DBh,7,0DBh,0Fh,1Ah,3,0DBh,19h,4,8,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,8,0DBh,0DFh,19h,0Dh,18h,19h,3,8,0DBh,7,1Ah,4,0DBh,0Fh,0DBh,0DBh,0DBh
 db 19h,2,8,0DBh,0DBh,7,0DBh,0Fh,0DBh,0DBh,19h,2,8,0DBh,0DBh,0DBh,7,0DBh,0DBh
 db 0Fh,0DBh,0DBh,0DBh,19h,8,8,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,19h,3,8,0DBh
 db 0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,19h,12h,18h,19h,3,8,0DBh,7,0DBh,0DBh
 db 0DBh,0Fh,1Ah,3,0DBh,19h,4,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,19h,2,8,0DBh
 db 0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh,19h,7,8,1Ah,3,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh
 db 0DBh,19h,4,8,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,4,0DBh,0DCh,19h,10h,18h,19h,3,8
 db 0DBh,0DBh,7,0DBh,0Fh,1Ah,4,0DBh,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,4,0DBh,20h
 db 8,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,19h,9,8,0DBh,7,0DBh,0DBh,0Fh,1Ah,3
 db 0DBh,19h,5,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,5,0DBh,0DCh,19h,0Eh,18h,19h
 db 3,8,0DBh,7,0DBh,0Fh,1Ah,0Bh,0DBh,20h,20h,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0DBh
 db 0Fh,1Ah,3,0DBh,19h,5,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,4,0DBh,19h,4
 db 8,0DBh,0DBh,0DBh,7,1Ah,4,0DBh,0Fh,1Ah,0Ch,0DBh,19h,6,18h,19h,4Fh,18h,19h,4
 db 7,2Dh,20h,0C4h,2Dh,20h,0C4h,3Dh,2Dh,20h,0Fh
 db 'SpaceCommander, MK2K, Skipper and Tante Frieda are '
 db 7,0C4h,3Dh,2Dh,20h,0C4h,2Dh,20h,2Dh,19h,6,18h,19h,4Fh,18h,19h,3,8,0DBh,7
 db 0DBh,0DBh,0Fh,1Ah,9,0DBh,0DCh,20h,20h,8,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,6
 db 0DBh,19h,3,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,4,0DBh,8,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,0Bh,0DBh,0DCh,19h,13h,18h,19h,3,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,0DFh,20h
 db 8,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,8,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,3,0DBh
 db 0DFh,19h,8,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,19h,5,8,0DFh
 db 0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,0Ch,0DBh,0DCh,19h,9,18h,19h,3,7,0DBh,0Fh
 db 0DBh,0DBh,0DBh,19h,7,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,0DBh,0DBh,0DFh
 db 19h,0Bh,8,0DBh,7,0DBh,0DBh,0Fh,1Ah,4,0DBh,19h,0Eh,8,0DCh,0DBh,7,0DBh,0DBh
 db 0Fh,1Ah,5,0DBh,19h,9,18h,19h,3,7,0DBh,0Fh,0DBh,0DBh,0DBh,19h,6,8,1Ah,4,0DBh
 db 7,0DBh,0Fh,1Ah,3,0DBh,8,0DBh,7,0DBh,0Fh,1Ah,4,0DBh,19h,4,8,0DBh,0DBh,0DBh,7
 db 0DBh,0Fh,1Ah,3,0DBh,19h,0Ch,8,0DCh,0DBh,0DBh,7,0DBh,0Fh,1Ah,3,0DBh,0DFh,19h
 db 0Ch,18h,19h,3,8,0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh,19h,7,8,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,8,0DBh,0DFh,19h,7,8,0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,19h,0Ah,8
 db 0DCh,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,19h,0Eh,18h,19h,3,7,0DBh,0Fh,1Ah
 db 3,0DBh,20h,8,0DBh,7,0DBh,0Fh,1Ah,6,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,0DCh,19h
 db 0Ah,8,1Ah,3,0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh,19h,7,8,0DCh,0DBh,0DBh,7,0DBh
 db 0DBh,0DBh,0Fh,0DBh,0DBh,0DBh,0DFh,19h,10h,18h,19h,3,8,0DBh,7,0DBh,0DBh,0Fh
 db 0DBh,0DBh,0DBh,0DCh,20h,8,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,7,0DBh,0DBh,0Fh
 db 1Ah,5,0DBh,0DCh,19h,9,8,0DFh,0DBh,0DBh,7,0DBh,0Fh,1Ah,3,0DBh,19h,4,8,0DCh
 db 0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,3,0DBh,0DFh,19h,12h,18h,19h,3,8,0DBh,7,0DBh
 db 0Fh,1Ah,4,0DBh,20h,8,0DBh,7,0DBh,0Fh,0DBh,0DBh,0DBh,0DFh,20h,8,0DBh,7,0DBh
 db 0DBh,0Fh,1Ah,6,0DBh,0DCh,19h,7,8,0DBh,0DBh,0DBh,7,0DBh,0DBh,0Fh,0DBh,0DBh
 db 0DBh,19h,2,8,0DCh,0DBh,0DBh,7,0DBh,0DBh,0Fh,1Ah,4,0DBh,19h,14h,18h,19h,4,8
 db 0DBh,7,0DBh,0DBh,0Fh,1Ah,6,0DBh,0DFh,20h,8,0DCh,0DBh,0DBh,7,1Ah,3,0DBh,0Fh
 db 1Ah,0Dh,0DBh,20h,8,0DBh,0DBh,0DBh,7,0DBh,0Fh,1Ah,3,0DBh,8,0DBh,0DBh,7,0DBh
 db 0DBh,0DBh,0Fh,1Ah,3,0DBh,0DFh,19h,3,8,0DCh,1Ah,3,0DBh,7,0DBh,0DBh,0Fh,1Ah,6
 db 0DBh,19h,4,18h,19h,2Bh,8,0DBh,0DBh,7,0DBh,0DBh,0DBh,0Fh,1Ah,16h,0DBh,0DFh
 db 19h,6,18h,19h,4Fh,18h,19h,4Fh,18h

