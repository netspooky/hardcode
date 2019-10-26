 org 7C00h

                    JMP     START
                    NOP                                        

bsOEM_NAME            DB      'MSDOS5.0'      ;  8 bytes
bsBYTES_PER_SECTOR    DW      0
bsSECTORS_PER_CLUSTER DB      0
bsRESERVED_SECTORS    DW      0
bsFAT_COPIES          DB      0
bsROOT_DIR_ENTRIES    DW      0
bsTOTAL_DISK_SECTORS  DW      0
bsMEDIA_DESCRIPTOR    DB      0
bsSECTORS_PER_FAT     DW      0
bsSECTORS_PER_TRACK   DW      0
bsSIDES               DW      0
bsHIDDEN_SECTORS_HIGH DW      0
bsHIDDEN_SECTORS_LOW  DW      0
bsTOTAL_NUM_SECTORS   DD      0
bsPHYS_DRIVE_NUMBER_1 DB      0
bsPHYS_DRIVE_NUMBER_2 DB      0
bsBOOT_RECORD_SIG     DB      29h
bsVOL_SERIAL_NUM      DD      1F61A800h
bsVOLUME_LABEL        DB      'NO NAME    '   ; 11 bytes
bsFILE_SYSTEM_ID      DB      'FAT16   '      ;  8 bytes

;[========================================================================]
;     Disk Parameter Block
;
;     The DPB is located in the ROM BIOS at the address pointed to by 0078h.
;     The 11 bytes starting from START are overwritten at COPY_DPB with the
;     DPB (7C3E-7C48).  This is what the area looks like *after* the copy
;     at COPY_DPB:
;[========================================================================]
dpbCONTROL_TIMERS     DW      0
dpbMOTOR_OFF_DELAY    DB      0
dpbBYTES_PER_SECTOR   DB      0
dpbSECTORS_PER_TRACK  DB      0
dpbGAP_LENGTH         DB      0
dpbDATA_LENGTH        DB      0
dpbFORMAT_GAP_LENGTH  DB      0
dpbFORMAT_FILLER_BYTE DB      0
dpbHEAD_SETTLE_TIME   DB      0
dpbMOTOR_START_TIME   DB      0

;[========================================================================]
;     Following the copy of the DPB, more information is copied over
;     previously existing code:
;[========================================================================]
cpbsHIDDEN_SECTORS_HIGH DW      0
cpbsHIDDEN_SECTORS_LOW  DW      0

                        DB      0
                        DB      0
                        DB      0

cpbsHIDDEN_SECTORS_HIGH_ DW      0
cpbsHIDDEN_SECTORS_LOW_  DW      0

;[========================================================================]
;     Here is the start of the boot sector code.  Note that the first 11
;     bytes will be destroyed later on as described above.
;[========================================================================]
START               CLI                     ; Disable interrupts

 mov ax,13h
 int 10h
;gensin
		push	cs
		pop	es

;		mov	di, $A000;sint
		mov	di, sint
;		push di
		xor cl,cl;mov   cl, 0A0h
		mov	bx, 5F5h
		xor	dx, dx

genl:
		mov	ax, dx
		sar	ax, 0Bh
		sub	bx, ax
		shl	ax, 2
		sub	bx, ax
		add	dx, bx
		mov	al, dh
		stosb
		mov	ax, bx
		sar	ax, 9
		add	al, dh
		stosb
		dec	cl
		jnz	short genl

;		push 0A000h
;		pop es
;------------------------------
;pop bx
 xor bx,bx
;   zx:=sin_tab[angle mod 64];
;   zy:=cos_tab[angle mod 64];
ch_lp:
	mov ax,cs
	add ah,$10
	mov es,ax

 push bx
;; movsx si,byte [cs:bx];zx
 movsx si,byte [cs:sint+bx];zx
 add bl,40;+16
;; movsx bx,byte [cs:bx];zy
 movsx bx,byte [cs:sint+bx];zy

;
;  { centrowanie }
;  fx_:=65536-((xmax div 2)*(zx+zy));
;  fy_:=65536-((ymax div 2)*(zx-zy));

	mov ax,si
	add ax,bx
	cwd
	mov cx, 160
	imul cx
	neg ax
;;	mov [cs:fx_],ax
	push ax
;fy_
	mov ax,si
	sub ax,bx
	cwd
	mov cx, 100
	imul cx
	neg ax
;;	mov [cs:fy_],ax
	mov bp,ax
	pop dx
 xor di,di
;   for j:=0 to ymax-1 do begin
;mov dx,[cs:fx_]
;mov bp,[cs:fy_]
ylp:
;      fx:=fx_; fy:=fy_;
;mov dx,[cs:fx_]
;mov bp,[cs:fy_]

push bp
push dx

mov cx,320
;      for i := 0 to xmax-1 do begin
xlp:
;bx=zy,si=zx,di,bp,cx,ax


;       if (fx xor fy) shr 8 and $10=0 then
;        bmp.Canvas.Pixels[i,j]:=clWhite
;       else
;        bmp.Canvas.Pixels[i,j]:=clBlack;

mov ax,bp
xor ax,dx
and ah,$10
mov al,ah
je putt
dec al
putt:
stosb

;       if not(form1.Zoom1.Checked) then
;        fx:=fx+zx;    // zoomer

add dx,si;(2) SI=zx,BP=fy_,DX=fx_,;BX=_zy
;       fy:=fy-zy;
sub bp,bx
loop xlp


;      if not(form1.Stretch1.checked) then
;       fx_:=fx_+zy;   // stretch 
pop dx
add dx,bx

;      if not(form1.Zoom1.Checked) then
;       fy_:=fy_+zx;   // zoomer
pop bp
add bp,si;(1)

;   end;
cmp di,64000
jne ylp
;------------copy to screen---------

		mov	dx, 3DAh

w1:
		in	al, dx		; Video status bits:
					; 0: retrace.  1=display is in vert or horiz retrace.
					; 1: 1=light pen is triggered; 0=armed
					; 2: 1=light pen switch is open; 0=closed
					; 3: 1=vertical sync pulse is occurring.
		test	al, 8
		jz	short w1

w2:
		in	al, dx		; Video	status bits:
					; 0: retrace.  1=display is in vert or horiz retrace.
					; 1: 1=light pen is triggered; 0=armed
					; 2: 1=light pen switch	is open; 0=closed
					; 3: 1=vertical	sync pulse is occurring.
		and	al, 8
		jnz	short w2

	push es
	pop ds
	push word 0A000h
	pop es
	xor si,si
	xor di,di
	mov ch,0FAh
	rep movsb
;-----------------------------------
pop bx
inc bl
in al,60h
dec al
jne ch_lp
ret
;-------------------------------
 sint:

times 499-($-$$) db 0
LoaderName	db 'BOOTOR     '	; Имя файла загрузчика
BootMagic	dw 0xAA55	; Сигнатура загрузочного сектора
