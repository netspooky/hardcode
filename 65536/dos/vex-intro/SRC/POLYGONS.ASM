comment #
/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/
#



;// the polygon routine... uses 16bit fixed point for all coordinates
;// this looks much better for spacecuts, since it leaves no black lines
;// between two planes
;// has problems with division by zero in this version...
;// so watch out for further releases!

model large,c
.386
locals

.data

maxpts equ 16

public poly_width
public poly_minx
public poly_maxx
public poly_miny
public poly_maxy
public poly_scrseg
public poly_col
public poly_tbmp
public poly_twid
public poly_x
public poly_y
public poly_len
public poly_tx
public poly_ty
public poly_dtx
public poly_dty

poly_width dw 320
poly_minx dw 0
poly_maxx dw 320
poly_miny dw 0
poly_maxy dw 200
poly_scrseg dw 0
poly_col db 0
poly_tbmp dd 0
poly_twid dw 0
poly_y dw 0
poly_x dw 0
poly_len dw 0
poly_tx dd 0
poly_ty dd 0
poly_dtx dd 0
poly_dty dd 0

.code

public fillpolygon
public vshadepolygon
public vtexturepolygon


fillpolygon proc uses si di, pts:dword, n:word, col:word, fill:dword, scrseg:word
local pt:dword:2*maxpts*2,maxy:word,ny1:word,ny2:word,dx1:dword,dx2:dword,x1:dword,x2:dword
  cld
  mov ax,n
  cmp ax,maxpts
  jg @@done
  cmp ax,3
  jl @@done

;2*copy pts to stack array
  push ds
  push ss
  pop es
  lea di,pt
  lds si,pts
  mov cx,n
  shl cx,1
  push cx
  rep movsd
  pop cx
  mov si,word ptr pts
  rep movsd
  pop ds

;find smallest and largest y
  mov ebx,pt+4
  mov edx,ebx
  lea di,pt       ;di=minp
  lea si,pt+8
  mov cx,n
  dec cx
@@lminmax:
    mov eax,dword ptr ss:[si+4]
    cmp eax,ebx
    jge @@nomin
      mov di,si
      mov ebx,eax
  @@nomin:
    cmp eax,edx
    jle @@nomax
      mov edx,eax
  @@nomax:
  add si,8
  loop @@lminmax

  add ebx,0ffffh
  shr ebx,16
  add edx,0ffffh
  shr edx,16

;clip y coordinates
  mov ax,poly_miny
  mov cx,poly_maxy
  cmp ax,dx
  jge @@done
  cmp cx,bx
  jle @@done
  cmp ax,bx
  jle @@minok
    mov bx,ax
@@minok:
  cmp cx,dx
  jge @@maxok
    mov dx,cx
@@maxok:

;init vars
  mov maxy,dx
  mov poly_y,bx
  mov ny1,bx
  mov ny2,bx
  mov ax,scrseg
  mov poly_scrseg,ax
  mov al,byte ptr col
  mov poly_col,al
  mov si,di
  mov ax,n
  shl ax,3
  add si,ax      ;di=p1,si=p2
  jmp @@chkloop
@@drawloop:
;reached a new point?
    mov ax,ny1
    cmp	ax,poly_y
    jle @@newseg1
    mov ax,ny2
    cmp ax,poly_y
    jle @@newseg2
@@cont2:
    mov ebx,x1
    mov ecx,x2

;sort x coordinates for line
    add ebx,0ffffh
    shr ebx,16
    add ecx,0ffffh
    shr ecx,16
    cmp cx,bx
    jge @@swap
      xchg cx,bx
  @@swap:

;clip x coordinates for line
    cmp bx,poly_maxx
    jge @@nofill
    cmp cx,poly_minx
    jle @@nofill
    cmp bx,poly_minx
    jge @@x1ok
      mov bx,poly_minx
  @@x1ok:
    cmp cx,poly_maxx
    jle @@x2ok
      mov cx,poly_maxx
  @@x2ok:

;init fill vars
    sub cx,bx
    jz @@nofill
    mov poly_x,bx
    mov poly_len,cx
    call fill

;update vars
  @@nofill:
    mov eax,dx1
    add x1,eax
    mov eax,dx2
    add x2,eax
    inc poly_y
@@chkloop:
  mov ax,poly_y
  cmp ax,word ptr maxy
  jl @@drawloop
@@done:
  ret

;new point at line 1
@@newseg1:
  add di,8
  mov eax,dword ptr ss:[di+4]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_y
  jle @@newseg1
  mov ny1,ax

  mov ebx,dword ptr ss:[di+4]
  sub ebx,dword ptr ss:[di-4]
  mov cx,poly_y
  shl ecx,16
  sub ecx,dword ptr ss:[di-4]

  mov eax,dword ptr ss:[di]
  sub eax,dword ptr ss:[di-8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dx1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[di-8]
  mov x1,eax

  mov ax,ny2
  cmp ax,poly_y
  jg @@cont2

;new point at line 2
@@newseg2:
  sub si,8
  mov eax,dword ptr ss:[si+4]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_y
  jle @@newseg2
  mov ny2,ax

  mov ebx,dword ptr ss:[si+4]
  sub ebx,dword ptr ss:[si+12]
  mov cx,poly_y
  shl ecx,16
  sub ecx,dword ptr ss:[si+12]

  mov eax,dword ptr ss:[si]
  sub eax,dword ptr ss:[si+8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dx2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[si+8]
  mov x2,eax

  jmp @@cont2
endp

vshadepolygon proc uses si di, pts:dword, cols:dword, n:word, shade:dword, scrseg:word
local co:dword:2*maxpts*2,pt:dword:2*maxpts*2,maxx:word,nx1:word,nx2:word,dy1:dword,dy2:dword
local tx1:dword,tx2:dword,dtx1:dword,dtx2:dword,y1:dword,y2:dword
  cld
  mov ax,n
  cmp ax,maxpts
  jg @@done
  cmp ax,3
  jl @@done

;2*copy pts and verts to stack array
  push ds
  push ss
  pop es
  lea di,pt
  lds si,pts
  mov cx,n
  shl cx,1
  push cx
  rep movsd
  pop cx
  mov si,word ptr pts
  push cx
  rep movsd
  pop cx
  lea di,co
  lds si,cols
  push cx
@@copycols:
    movsd
    add di,4
  sub cx,2
  jnz @@copycols
  pop cx
  lea si,co
  push ss
  pop ds
  rep movsd
  pop ds

;find smallest and largest x
  mov ebx,pt
  mov edx,ebx
  lea di,pt       ;di=minp
  lea si,pt+8
  mov cx,n
  dec cx
@@lminmax:
    mov eax,dword ptr ss:[si]
    cmp eax,ebx
    jge @@nomin
      mov di,si
      mov ebx,eax
  @@nomin:
    cmp eax,edx
    jle @@nomax
      mov edx,eax
  @@nomax:
  add si,8
  loop @@lminmax

  add ebx,0ffffh
  shr ebx,16
  add edx,0ffffh
  shr edx,16

;clip x coordinates
  mov ax,poly_minx
  mov cx,poly_maxx
  cmp ax,dx
  jge @@done
  cmp cx,bx
  jle @@done
  cmp ax,bx
  jle @@minok
    mov bx,ax
@@minok:
  cmp cx,dx
  jge @@maxok
    mov dx,cx
@@maxok:

;init vars
  mov maxx,dx
  mov poly_x,bx
  mov nx1,bx
  mov nx2,bx
  mov ax,scrseg
  mov poly_scrseg,ax
  mov si,di
  mov ax,n
  shl ax,3
  add si,ax      ;di=p1,si=p2
  jmp @@chkloop
@@drawloop:
;reached a new point?
    mov ax,nx1
    cmp	ax,poly_x
    jle @@newseg1
    mov ax,nx2
    cmp ax,poly_x
    jle @@newseg2
@@cont2:
    mov ebx,y1
    mov ecx,y2

;sort y coordinates for line
    add ebx,0ffffh
    shr ebx,16
    add ecx,0ffffh
    shr ecx,16
    cmp cx,bx
    jge @@swap
      xchg cx,bx
  @@swap:

;clip y coordinates for line
    cmp bx,poly_maxy
    jge @@nofill
    cmp cx,poly_miny
    jle @@nofill
    cmp bx,poly_miny
    jge @@y1ok
      mov bx,poly_miny
  @@y1ok:
    cmp cx,poly_maxy
    jle @@y2ok
      mov cx,poly_maxy
  @@y2ok:

;init fill vars
    sub cx,bx
    jz @@nofill
    mov poly_y,bx
    mov poly_len,cx

    mov ebx,y1
    sub ebx,y2
    mov cx,poly_y
    shl ecx,16
    sub ecx,y1

    mov eax,tx1
    sub eax,tx2
    mov edx,eax
    shl eax,16
    sar edx,16
    idiv ebx      ; careful here!
    mov poly_dtx,eax
    imul ecx
    shrd eax,edx,16
    add eax,tx1
    mov poly_tx,eax

    call shade

;update vars
  @@nofill:
    mov eax,dy1
    add y1,eax
    mov eax,dy2
    add y2,eax
    mov ebx,x1
    mov eax,dtx1
    add tx1,eax
    mov eax,dtx2
    add tx2,eax

    inc poly_x
@@chkloop:
  mov ax,poly_x
  cmp ax,word ptr maxx
  jl @@drawloop
@@done:
  ret

;new point at line 1
@@newseg1:
  add di,8
  mov eax,dword ptr ss:[di]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_x
  jle @@newseg1
  mov nx1,ax

  mov ebx,dword ptr ss:[di]
  sub ebx,dword ptr ss:[di-8]
  mov cx,poly_x
  shl ecx,16
  sub ecx,dword ptr ss:[di-8]

  mov eax,dword ptr ss:[8*maxpts*2+di]
  sub eax,dword ptr ss:[8*maxpts*2+di-8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dtx1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+di-8]
  mov tx1,eax

  mov eax,dword ptr ss:[di+4]
  sub eax,dword ptr ss:[di-4]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dy1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[di-4]
  mov y1,eax

  mov ax,nx2
  cmp ax,poly_x
  jg @@cont2

;new point at line 2
@@newseg2:
  sub si,8
  mov eax,dword ptr ss:[si]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_x
  jle @@newseg2
  mov nx2,ax

  mov ebx,dword ptr ss:[si]
  sub ebx,dword ptr ss:[si+8]
  mov cx,poly_x
  shl ecx,16
  sub ecx,dword ptr ss:[si+8]

  mov eax,dword ptr ss:[8*maxpts*2+si]
  sub eax,dword ptr ss:[8*maxpts*2+si+8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dtx2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+si+8]
  mov tx2,eax

  mov eax,dword ptr ss:[si+4]
  sub eax,dword ptr ss:[si+12]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dy2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[si+12]
  mov y2,eax

  jmp @@cont2
endp

vtexturepolygon proc uses si di, pts:dword, verts:dword, n:word, bmp:dword, wid:word, col:word, texture:dword, scrseg:word
local vr:dword:2*maxpts*2,pt:dword:2*maxpts*2,maxx:word,nx1:word,nx2:word,dy1:dword,dy2:dword
local tx1:dword,ty1:dword,tx2:dword,ty2:dword,dtx1:dword,dty1:dword,dtx2:dword,dty2:dword,y1:dword,y2:dword
  cld
  mov ax,n
  cmp ax,maxpts
  jg @@done
  cmp ax,3
  jl @@done

;2*copy pts and verts to stack array
  push ds
  push ss
  pop es
  lea di,pt
  lds si,pts
  mov cx,n
  shl cx,1
  push cx
  rep movsd
  pop cx
  mov si,word ptr pts
  push cx
  rep movsd
  pop cx
  lea di,vr
  lds si,verts
  push cx
  rep movsd
  pop cx
  mov si,word ptr verts
  rep movsd
  pop ds

;find smallest and largest x
  mov ebx,pt
  mov edx,ebx
  lea di,pt       ;di=minp
  lea si,pt+8
  mov cx,n
  dec cx
@@lminmax:
    mov eax,dword ptr ss:[si]
    cmp eax,ebx
    jge @@nomin
      mov di,si
      mov ebx,eax
  @@nomin:
    cmp eax,edx
    jle @@nomax
      mov edx,eax
  @@nomax:
  add si,8
  loop @@lminmax

  add ebx,0ffffh
  shr ebx,16
  add edx,0ffffh
  shr edx,16

;clip x coordinates
  mov ax,poly_minx
  mov cx,poly_maxx
  cmp ax,dx
  jge @@done
  cmp cx,bx
  jle @@done
  cmp ax,bx
  jle @@minok
    mov bx,ax
@@minok:
  cmp cx,dx
  jge @@maxok
    mov dx,cx
@@maxok:

;init vars
  mov maxx,dx
  mov poly_x,bx
  mov nx1,bx
  mov nx2,bx
  mov ax,scrseg
  mov poly_scrseg,ax
  mov al,byte ptr col
  mov poly_col,al
  mov eax,bmp
  mov poly_tbmp,eax
  mov ax,wid
  mov poly_twid,ax
  mov si,di
  mov ax,n
  shl ax,3
  add si,ax      ;di=p1,si=p2
  jmp @@chkloop
@@drawloop:
;reached a new point?
    mov ax,nx1
    cmp	ax,poly_x
    jle @@newseg1
    mov ax,nx2
    cmp ax,poly_x
    jle @@newseg2
@@cont2:
    mov ebx,y1
    mov ecx,y2

;sort y coordinates for line
    add ebx,0ffffh
    shr ebx,16
    add ecx,0ffffh
    shr ecx,16
    cmp cx,bx
    jge @@swap
      xchg cx,bx
  @@swap:

;clip y coordinates for line
    cmp bx,poly_maxy
    jge @@nofill
    cmp cx,poly_miny
    jle @@nofill
    cmp bx,poly_miny
    jge @@y1ok
      mov bx,poly_miny
  @@y1ok:
    cmp cx,poly_maxy
    jle @@y2ok
      mov cx,poly_maxy
  @@y2ok:

;init fill vars
    sub cx,bx
    jz @@nofill
    mov poly_y,bx
    mov poly_len,cx

    mov ebx,y1
    sub ebx,y2
    mov cx,poly_y
    shl ecx,16
    sub ecx,y1

    mov eax,tx1
    sub eax,tx2
    mov edx,eax
    shl eax,16
    sar edx,16
    idiv ebx      ; careful here!
    mov poly_dtx,eax
    imul ecx
    shrd eax,edx,16
    add eax,tx1
    mov poly_tx,eax

    mov eax,ty1
    sub eax,ty2
    mov edx,eax
    shl eax,16
    sar edx,16
    idiv ebx      ; careful here!
    mov poly_dty,eax
    imul ecx
    shrd eax,edx,16
    add eax,ty1
    mov poly_ty,eax

    call texture

;update vars
  @@nofill:
    mov eax,dy1
    add y1,eax
    mov eax,dy2
    add y2,eax
    mov ebx,x1
    mov eax,dtx1
    add tx1,eax
    mov eax,dtx2
    add tx2,eax
    mov eax,dty1
    add ty1,eax
    mov eax,dty2
    add ty2,eax

    inc poly_x
@@chkloop:
  mov ax,poly_x
  cmp ax,word ptr maxx
  jl @@drawloop
@@done:
  ret

;new point at line 1
@@newseg1:
  add di,8
  mov eax,dword ptr ss:[di]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_x
  jle @@newseg1
  mov nx1,ax

  mov ebx,dword ptr ss:[di]
  sub ebx,dword ptr ss:[di-8]
  mov cx,poly_x
  shl ecx,16
  sub ecx,dword ptr ss:[di-8]

  mov eax,dword ptr ss:[8*maxpts*2+di]
  sub eax,dword ptr ss:[8*maxpts*2+di-8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dtx1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+di-8]
  mov tx1,eax

  mov eax,dword ptr ss:[8*maxpts*2+di+4]
  sub eax,dword ptr ss:[8*maxpts*2+di-4]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dty1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+di-4]
  mov ty1,eax

  mov eax,dword ptr ss:[di+4]
  sub eax,dword ptr ss:[di-4]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dy1,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[di-4]
  mov y1,eax

  mov ax,nx2
  cmp ax,poly_x
  jg @@cont2

;new point at line 2
@@newseg2:
  sub si,8
  mov eax,dword ptr ss:[si]
  add eax,0ffffh
  shr eax,16
  cmp ax,poly_x
  jle @@newseg2
  mov nx2,ax

  mov ebx,dword ptr ss:[si]
  sub ebx,dword ptr ss:[si+8]
  mov cx,poly_x
  shl ecx,16
  sub ecx,dword ptr ss:[si+8]

  mov eax,dword ptr ss:[8*maxpts*2+si]
  sub eax,dword ptr ss:[8*maxpts*2+si+8]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dtx2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+si+8]
  mov tx2,eax

  mov eax,dword ptr ss:[8*maxpts*2+si+4]
  sub eax,dword ptr ss:[8*maxpts*2+si+12]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dty2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[8*maxpts*2+si+12]
  mov ty2,eax

  mov eax,dword ptr ss:[si+4]
  sub eax,dword ptr ss:[si+12]
  mov edx,eax
  shl eax,16
  sar edx,16
  idiv ebx      ; careful here!
  mov dy2,eax
  imul ecx
  shrd eax,edx,16
  add eax,dword ptr ss:[si+12]
  mov y2,eax

  jmp @@cont2
endp

end
