;------------------------------------------------------------
;	DPMI-based PMODE kernel
;
;	Mikolaj Felix 06/11/01, 14/01/02
;	mfelix@polbox.com
;------------------------------------------------------------

.386p

include kernel.inc

STACK_SIZE equ 1000h
DPMI_AREA_SIZE equ 1000h

;------------------------------------------------------------
;	16-bit code
;------------------------------------------------------------

code16 segment para public use16
	assume cs:code16, ds:code32

start16:
	mov	eax,code32
	mov	ds,ax

	; check if DPMI host is present
	mov	ax,1687h
	int	2fh
	or	ax,ax
	jz	dpmi_installed

	mov	dx,small offset dpmi_err1
	jmp	err_quit

dpmi_installed:
	; is 32-bit mode supported?
	test	bl,1
	jnz	mode32_ok

	mov	dx,small offset dpmi_err2
	jmp	err_quit

mode32_ok:
	; save DPMI routine address
	mov	small word ptr dpmi_switch[0],di
	mov	small word ptr dpmi_switch[2],es

	; get physical address of code
	mov	eax,code32
	shl	eax,4
	mov	small code32_base,eax

	; write address to descriptors
	;mov	di,small offset desc_code32
	;or	dword ptr [di+2],eax
	;mov	di,small offset desc_data32
	;or	dword ptr [di+2],eax

	mov	ebx, eax
	shr	ebx, 16
	
	mov	di, small offset desc_code32
	mov	word ptr [di + 2], ax
	mov	byte ptr [di + 4], bl
	mov	byte ptr [di + 7], bh

	mov	di, small offset desc_data32
	mov	word ptr [di + 2], ax
	mov	byte ptr [di + 4], bl
	mov	byte ptr [di + 7], bh


	; set es to DPMI private area
	mov	ax,dpmi_area
	mov	es,ax

	; switch to PMODE
	mov	ax,1
	call	small dword ptr dpmi_switch
	jnc	mode_switched

	mov	dx,small offset dpmi_err3
	jmp	err_quit

mode_switched:
	mov	ax,ds
	mov	es,ax
	
	; allocate code descriptor
	xor	ax,ax
	mov	cx,1
	int	31h
	mov	small sel_code32,ax
	
	; set code descriptor
	mov	bx,ax
	mov	ax,0ch
	mov	edi,offset desc_code32
	int	31h

	; allocate data descriptor
	xor	ax,ax
	mov	cx,1
	int	31h
	mov	small sel_data32,ax
	
	; set data descriptor
	mov	bx,ax
	mov	ax,0ch
	mov	edi,offset desc_data32
	int	31h
	
	; jump to 32-bit segment
	push	small dword ptr sel_code32
	push	large offset start32
	db	66h,0cbh

err_quit:
	mov	ah,09h
	int	21h
	mov	ah,4ch
	int	21h

code16 ends

dpmi_area segment para public use16
	db DPMI_AREA_SIZE dup(?)
dpmi_area ends

;------------------------------------------------------------
;	32-bit code
;------------------------------------------------------------

code32 segment para public use32
	assume cs:code32, ds:code32

dpmi_err1	db 'DPMI host not installed!',10,13,'$'
dpmi_err2	db '32-bit PMODE unsupported!',10,13,'$'
dpmi_err3	db 'Unable to switch mode!',10,13,'$'

dpmi_switch	dd ?
code32_base	dd ?

; fa = 11111010b	code read / exec
; cf = 11001111b
; f2 = 11110010b	data read / write
desc_code32	db 0ffh,0ffh,0h,0h,0h,0fah,0cfh,0h
desc_data32	db 0ffh,0ffh,0h,0h,0h,0f2h,0cfh,0h


sel_code32	dw ?
sel_data32	dw ?

start32:
	; set selectors
	mov	ax,sel_data32
	mov	ds,ax
	mov	es,ax
	mov	ss,ax

	; init stack
	mov	esp,stack_seg
	sub	esp,large code32
	shl	esp,4
	add	esp,STACK_SIZE-4

	call	_main

	; return to RM and quit
	mov	ah,4ch
	int	21h

code32 ends

stack_seg segment para stack 'stack'
	db STACK_SIZE dup(?)
stack_seg ends

end start16
