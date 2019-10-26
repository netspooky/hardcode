
.model tiny,Pascal
.386
dosseg
locals
bezier_only = 1

screen_seg segment para public use16
screen_seg ends

.code
extrn scanconvert2:proc

public bezier

oldsp dw 0
oldss dw 0
allocaddr dw 0
currentx dw 0
currenty dw 0
depth dw 0
bezier_t proc x1:WORD,y1:WORD,x2:WORD,y2:WORD,x3:WORD,y3:WORD,x4:WORD,y4:WORD,color:WORD
	local r1x:WORD,r1y:WORD,r2x:WORD,r2y:WORD,r3x:WORD,r3y:WORD,q1x:WORD,q1y:WORD,q2x:WORD,q2y:WORD,s1x:WORD,s1y:WORD
	mov ax,x2
	mov bx,ax
	add ax,x1
	shr ax,1
	mov r1x,ax
	mov cx,x3
	add bx,cx
	shr bx,1
	add cx,x4
	shr cx,1
	mov r3x,cx
	add cx,bx
	add ax,bx
	shr ax,1
	shr cx,1
	mov q1x,ax
	mov q2x,cx
	add ax,cx
	shr ax,1
	mov s1x,ax
	mov ax,y2
	mov bx,ax
	add ax,y1
	shr ax,1
	mov r1y,ax
	mov cx,y3
	add bx,cx
	shr bx,1
	add cx,y4
	shr cx,1
	mov r3y,cx
	add cx,bx
	add ax,bx
	shr ax,1
	shr cx,1
	mov q1y,ax
	mov q2y,cx
	add ax,cx
	shr ax,1
	mov s1y,ax
	dec depth
	cmp depth,0
	jnz ei_lopetus
	shr s1x,4
	shr s1y,4
	call scanconvert2,currentx,currenty,s1x,s1y,color
	mov ax,s1x
	mov currentx,ax
	mov ax,s1y
	mov currenty,ax
	inc depth
	ret
ei_lopetus:
	call bezier_t,x1,y1,r1x,r1y,q1x,q1y,s1x,s1y,color
	call bezier_t,s1x,s1y,q2x,q2y,r3x,r3y,x4,y4,color
	inc depth
	ret
endp
bezier proc x1:WORD,y1:WORD,x2:WORD,y2:WORD,x3:WORD,y3:WORD,x4:WORD,y4:WORD,color:WORD
	mov cl,4
	mov depth,8
	mov ax,x1
	mov currentx,ax
	mov ax,y1
	mov currenty,ax
	shr currentx,cl
	shr currenty,cl
	call bezier_t,x1,y1,x2,y2,x3,y3,x4,y4,color
	shr x4,4
	shr y4,4
	call scanconvert2,currentx,currenty,x4,y4,color
	ret

endp

do_it:

endp

end

