cseg	segment
	assume cs:cseg
	org	100h
Start:
	pop	ds
	push	ds
	mov	ds:[417h],al
	ret
cseg	ends
	end	Start
