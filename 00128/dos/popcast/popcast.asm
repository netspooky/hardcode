;		
;		P O P C A S T  127b
;		
;		by HellMood
;		mail : storrryteller@hotmail.com
;		http://www.pouet.net/user.php?who=97586
;		https://www.facebook.com/mood.hell
;
;		Short Guide : Use ENTER & SPACE to toggle fx
;					  Use ESC to quit


P1:		mov ax,0x13			; 320*200*8
X:		cmpsw				; framecounter
S:		cwd					; int10h overflow & DIV
		int 0x10			; set mode/pixel

		inc cx				; next pixel
		jz X				; next frame?

		mov bx,320			; make x, y
		mov ax,cx			; from pixelcounter
		div bx				; ax = y / dx = x

		add dx,ax
		mov bp,dx			; bp = "r"

		mul bx				
		div bp				; ax = "w"

		sub bp,di			; move effect

R:		mov bx,ax			; (bx,ax) modbyte = C3 = ret
		and ax,bp			; mask
		and al,16			; inside rect?
		jz F				; skip pixelshade if not

		in al,0x60			; of course be so kind
		dec al
		jz R+1				; quit on escape
		cmp al,56			; 56 + 1 = "Space"
		jz P2				; loop on "Space"

		xchg bp,ax			; recover "w"

		sub ax,di			; flow/roll effect
		shr ax,3
		shr bx,3 			; texture zoom
		add al,bl
		aam 3				; tex/shade offset...

		mov dl,72			;... palette index
		mul dl
		add al,bl			; "w" influence
		add al,30			; final offset

F: 		mov ah,0x0C			; = set pixel
		jmp short S			; repeat

P2:		xor cx,cx			; the bonus dragon
		mov ax,0x12			; in mini HD ;)
		cwd					; 
		xor bx,bx			; page = 0
		
S2: 	int 0x10

		push cx				; save x
		sub cx,dx			; ifs1
		add cx,351			; ifs1
		shr cx,1			; ifs1
		pop di				; get x
		add dx,di   		; ifs2
		shl bp,1			; set CF before
		shr dx,1			; ifs2
		jnc B				; ifs branch
		xchg cx,dx			; xy swap
		not cx				; on branch
		add cx,720			; and mirror
		inc bp				; iter hist -> col
B:		in al,0x60
		dec al
		jz R+1				; quit on escape
		cmp al,27			; 27 + 1 = "Enter"
		jz P1				; loop on "Enter"
		mov ax,bp			; don't destroy iter hist
		aad 4				; compress and offset
		and al,15			; mask (for real msmdos)
		mov ah,0x0C
		jmp short S2