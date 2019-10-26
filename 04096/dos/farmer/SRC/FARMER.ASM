

part1=1  ;literki etc.
part2=1  ;stars wonders
part3=1  ;2d bump mapping
part4=1  ;kura's water
part5=1  ;two ZOOOOOM-rotators

.386
assume cs:code
code segment use16


Segment0	equ 06000h
Segment1	equ 07000h	;makeTlo
Segment2	equ 08000h	;toonel#1.1
Segment3	equ 09000h	;toonel#1.2
SegmentEkr	equ 0a000h

o		equ offset
w		equ word ptr
b		equ byte ptr
d		equ dword ptr


org 100h
start:
	push cs
	pop ax
	cmp ax,5000h
	jge _exit

	push cs
	pop es
	lea di,cos
	mov cx,1024
 MakeCos:
	mov _angle,cx
	fldpi
	fimul _angle
	fidiv _512
	fcos
	fimul _128
	fistp wyn
	mov ax,wyn
	mov es:[di],ax
	inc di
	inc di
	dec cx
	jnz MakeCos

	call GetFontAddr
	INCLUDE INC\bway.inc
	call make_Bump
	call calc_toonel

	mov ax,Segment1
	mov es,ax
	call Make_Tlo

	mov ax,13h
	int 10h
	call SetPal

	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment1
	mov ds,ax
	xor si,si
	mov cx,16000
	rep movsd

IFDEF part1
	; writeln 'FARMER'
	lea bp,ple
	mov ax,0a000h
	mov es,ax
	mov di,320*72+19
	mov ax,SegFont
	mov ds,ax
	call napis4
	lea bp,ple2
	mov ax,0a000h
	mov es,ax
	mov di,320*130+19
	mov ax,SegFont
	mov ds,ax
	call napis1

	; make fleshes
	call flesh
	call SetPal
	mov di,(320*24)+134
	call draw_Kura
	mov cx,230
 du:	call wait_vbl
	loop du
	call flesh
	call setPal
ENDIF

IFDEF part2
	mov ax,Segment1
	mov ds,ax
	mov ax,Segment0
	mov es,ax
	xor si,si
	xor di,di
	mov dx,128
 u1:	mov cx,256
	rep movsb
	add si,320-256
	dec dx
	jnz u1
	mov dx,128
 q1:	mov cx,256
	rep movsb
	sub si,320+256
	dec dx
	jnz q1

	mov cx,280
 keyeStars:
	push cx
	call draw_toonel
	mov di,(170*320)+315-16*2
	call draw_kura2
	call drawSeg1
	add liczn,258*2
	call wait_vbl
	pop cx
	dec cx
	jnz keyeStars
ENDIF

IFDEF part3
	call flesh

	mov ax,SegmentEkr
	mov es,ax
	call zerofill

	mov jest_czekanie,1
	mov ax,Segment0
	mov es,ax
	xor di,di
	xor ax,ax
	mov cx,32000
	rep stosw
	lea bp,ple4
	mov ax,SegFont
	mov di,320*72+19
	mov ds,ax
	call napis4

	mov ax,Segment1
	mov es,ax
	xor di,di
	xor ax,ax
	mov cx,32000
	rep stosw

	;mov jest_czekanie,1
	lea bp,ple3
	mov ax,SegFont
	mov di,320*72+19
	mov ds,ax
	call napis4

	mov di,20*320+130
	call draw_kura
	mov di,20*320+60
	call draw_kura
	mov di,20*320+200
	call draw_kura
	mov di,125*320+130
	call draw_kura
	mov di,125*320+60
	call draw_kura
	mov di,125*320+200
	call draw_kura
	call soften
	call Soften

	mov cx,200
 keye2:
	push cx

	cmp flesz_kura,0
	jne pleop
	mov flesz_kura,1
	call calc_Bump
	call setPal
 pleop:
	call wait_vbl
	call calc_bump

	pop cx
	dec cx
	jnz keye2
ENDIF

IFDEF part4
	call flesh
	mov ax,0a000h
	mov es,ax
	call ZeroFill
	call setPal


	push cs
	pop es
	lea di,obrazek
	mov cx,128*128
	mov al,63
	rep stosb

	mov jest_czekanie,1

	mov ax,Segment2
	mov es,ax
	call zeroFill

	mov licznikBump,0
 _part4:

	mov bx,licznikBump
	add licznikBump,6
	shl bx,2
	mov ax,[trasaWater+0][bx]
	sar ax,1
	add ax,128
	mov bp,ax
	mov ax,[trasaWater+2][bx]
	sar ax,2
	add ax,54
	shl ax,8
	add bp,ax
	mov ax,Segment2
	mov es,ax
	mov w es:[bp],0fefeh
	cmp licznikBump,360
	jl sluchamy_tiamata2
	mov licznikBump,0
 sluchamy_tiamata2:

	call CalculateWater
	call DrawWater
	call wait_vbl
	call DrawWaterOnScreen
	mov di,(170*320)+315-16*2
	call draw_kura2
	cmp wewne,30
	jl bez_napis
	cmp wewne,580
	je outtt
	cmp wewne,380
	je ploe
	cmp wewne,330
	je ploe
	cmp wewne,280
	je ploe
	cmp wewne,230
	je ploe
	cmp wewne,180
	je ploe
	cmp wewne,130
	je ploe
	cmp wewne,80
	jne loe
 ploe:
	push es
	mov ax,Segment2
	mov es,ax
	mov di,(256*50)+120
	lea si,kura
	mov ch,13
 p11:	mov cl,16
 p22:	mov al,cs:[si]
	or al,al
	jz p33
	mov ax,0fefeh
	mov es:[di],ax
 p33:	add di,2
	inc si
	dec cl
	jnz p22
	add di,256-32
	dec ch
	jnz p11
	pop es
 loe:
	mov cx,ileFont
	lea si,ple5
	lea di,ple6
 heyOp: mov al,cs:[si]
	cmp al,'$'
	je outOp
	mov cs:[di],al
	inc si
	inc di
	loop heyOp
 outOp: mov b cs:[di],'$'
	inc ileFont
	lea bp,ple6
	mov di,320*180+1
	mov ax,SegFont
	mov ds,ax
	call napis1
 bez_napis:
	inc wewne

	call wait_vbl
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment0
	mov ds,ax
	xor si,si
	mov cx,32000
	rep movsw

	jmp _part4
outtt:

ENDIF


IFDEF part5

	mov ax,Segment0
	mov ds,ax
	mov ax,Segment2
	mov es,ax
	mov fs,ax
	mov si,(30*320)+32
	xor di,di
	mov dx,128
 pleR1: mov cx,256
	rep movsb
	add si,320-256
	dec dx
	jnz pleR1
	mov dx,128
 pleR2: mov cx,256
	rep movsb
	sub si,320+256
	dec dx
	jnz pleR2

	mov ax,Segment0
	mov es,ax
	xor di,di
	mov al,10
	mov cx,64000
	rep stosb


	mov cx,180
 _part5:
	push cx

	mov ax,kat_1
	mov kat,ax
	mov SegAdd,0
	call rotater
	mov ax,kat_2
	mov kat,ax
	mov SegAdd,1
	call rotater
	add kat_1,6
	sub kat_2,8


	call drawRotozoomonScreen
	mov di,(170*320)+315-16*2
	call draw_kura2

	call wait_vbl
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment0
	mov ds,ax
	xor si,si
	mov cx,32000
	rep movsw

	pop cx
	loop _part5


	call flesh
	call SetPal

	mov jest_czekanie,0

	lea bp,ple7
	mov ax,SegFont
	mov di,320*42+19
	mov ds,ax
	call napis4

	lea bp,ple8
	mov di,320*120+19
	call napis1
	lea bp,ple9
	mov di,320*150+19
	call napis1

	mov cx,100
 ddy:	call wait_vbl
	loop ddy

	call maz



ENDIF


	call flesh
	call setpal

	mov ax,Segment3
	mov fs,ax
	mov es,ax
	xor di,di
	mov cx,65535
	xor al,al
	rep stosb
	push cs
	pop ds

	mov bx,0
	mov cx,16
 jajkuj:
	push cx bx
	xor di,di
	add di,bx
	call dKuraz
	mov di,20
	add di,bx
	call dKuraz
	mov di,40
	add di,bx
	call dKuraz
	mov di,60
	add di,bx
	call dKuraz
	mov di,80
	add di,bx
	call dKuraz
	mov di,100
	add di,bx
	call dKuraz
	mov di,120
	add di,bx
	call dKuraz
	mov di,140
	add di,bx
	call dKuraz
	mov di,160
	add di,bx
	call dKuraz
	mov di,180
	add di,bx
	call dKuraz
	mov di,200
	add di,bx
	call dKuraz
	mov di,220
	add di,bx
	call dKuraz
	mov di,240
	add di,bx
	call dKuraz
	pop bx cx
	add bx,256*16
	loop jajkuj

	mov jest_czekanie,1
	mov ileFont,1

	mov kolorr,119
	mov wewne,0


	mov cx,300
part6:
	push cx

	call kuraz
	call drawKurazOnScreen

	mov di,(320*24)+134
	call draw_Kura
	mov di,(320*124)+134
	call draw_Kura

	mov cx,ileFont
	lea si,plea
	lea di,ple6
 heyO1: mov al,cs:[si]
	cmp al,'$'
	je outO1
	mov cs:[di],al
	inc si
	inc di
	loop heyO1
 outO1: mov b cs:[di],'$'
	inc ileFont
	lea bp,ple6
	mov di,320*(100-7)+10
	mov ax,SegFont
	mov ds,ax
	call napis1
 bez_napis1:
	inc wewne

	cmp wewne,70
	jl dpd
	mov wewne,0
	inc ileFont
 dpd:
	call wait_vbl
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment0
	mov ds,ax
	xor si,si
	mov cx,32000
	rep movsw

	pop cx
	loop part6



	mov jest_Czekanie,1

	mov ax,segment0
	mov es,ax
	call zerofill

	mov guruCol,63*3
	lea bp,pleb
	mov ax,SegFont
	mov di,320*72+19
	mov ds,ax
	call napis4

	mov flesz_kura,0

	call make_Bump
	call flesh

	mov ax,SegmentEkr
	xor di,di
	mov es,ax
	xor ax,ax
	mov cx,32000
	rep stosw

	mov ax,Segment1
	mov es,ax
	xor di,di
	xor ax,ax
	mov cx,32000
	rep stosw


	;mov jest_czekanie,1
	lea bp,pleb
	mov ax,SegFont
	mov di,320*72+19
	mov ds,ax
	call napis4

	mov di,20*320+130
	call draw_kura
	mov di,20*320+60
	call draw_kura
	mov di,20*320+200
	call draw_kura
	mov di,125*320+130
	call draw_kura
	mov di,125*320+60
	call draw_kura
	mov di,125*320+200
	call draw_kura
	call soften
	call Soften

	mov cx,180
 keye2dd:
	push cx

	cmp flesz_kura,0
	jne pleopdd
	mov flesz_kura,1
	call calc_Bump
	call setPal
 pleopdd:
	call wait_vbl
	call calc_bump

	pop cx
	dec cx
	jnz keye2dd




	mov ax,Segment3
	mov es,ax
	xor di,di
	mov cx,65535
 oddq:	mov al,es:[di]
	cmp al,63
	jne niccc
	sub al,10	
	mov es:[di],al
 niccc:	inc di
	loop oddq

	call flesh
	call setpal


	mov gupui,1
	mov kolorr,3eh*2-13

	mov ax,Segment0
	mov es,ax
	xor di,di
	mov al,10
	mov cx,64000
	rep stosb


	mov cx,240
 _part55:
	push cx

	mov ax,kat_1
	mov kat,ax
	call rotater2
	add kat_1,6
	sub kat_2,8


	call polozyc
	mov di,(170*320)+315-16*2
	call draw_kura2

	mov kolorr,3eh
	mov ax,SegFont
	mov ds,ax
	lea bp,int1
	mov di,320*20+10
	call napis1
	lea bp,int2
	mov di,320*35+10
	call napis1


	mov kolorr,64+63
	lea bp,int5
	mov di,320*100+10
	call napis1
	lea bp,int6
	mov di,320*115+10
	call napis1
	lea bp,int7
	mov di,320*130+10
	call napis1

	mov kolorr,64+64+64+3eh
	lea bp,int8
	mov di,320*155+10
	call napis1


	call wait_vbl
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment0
	mov ds,ax
	xor si,si
	mov cx,32000
	rep movsw

	pop cx
	loop _part55

	call maz
 _exit:
	mov ax,3
	int 10h


	ret










maz:
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov si,64000-320
	mov cx,100
 ops:	push di cx
	xor al,al
	mov cx,320
	rep stosb
	mov di,si
	mov cx,320
	rep stosb
	pop cx di
	add di,320
	sub si,320
	call wait_vbl
	dec cx
	jnz ops
	ret




kat_1	dw 0
kat_2	dw 0
ileFont dw 1
wewne	dw 0	;napis po wodzie



dkuraz:
	lea si,kura
	mov dx,13
 pioa:	mov cx,16
	rep movsb
	add di,256-16
	dec dx
	jnz pioa
	ret


DrawKurazOnScreen:
	mov ax,Segment1
	mov ds,ax
	xor si,si
	mov ax,Segment0
	mov es,ax
	xor di,di
	mov bp,200
	xor bx,bx
 qqw1:	mov cx,320
	xor dx,dx
 qqw2:	mov bl,dh
	mov al,ds:[si][bx]
	mov es:[di],al
	mov es:[di+320],al
	inc di
	add dx,(256*256)/320
	dec cx
	jnz qqw2
	add si,256
	dec bp
	jnz qqw1
	ret

DrawWaterOnScreen:
	mov ax,Segment1
	mov ds,ax
	mov si,128*4
	mov ax,Segment0
	mov es,ax
	xor di,di
	mov bp,100
	xor bx,bx
 dw1:	mov cx,320
	xor dx,dx
 dw2:	mov bl,dh
	mov al,ds:[si][bx]
	mov es:[di],al
	mov es:[di+320],al
	inc di
	add dx,(128*256)/320
	dec cx
	jnz dw2
	add si,128
	add di,320
	dec bp
	jnz dw1
	ret

DrawRotoZoomOnScreen:
	mov ax,Segment1
	mov ds,ax
	xor si,si
	mov ax,Segment0
	mov es,ax
	mov di,15
	mov bp,200
	xor bx,bx
 dq11:	mov cx,256
	xor dx,dx
 dq21:	movsb
	dec cx
	jnz dq21
	add di,320-256
	dec bp
	jnz dq11
	ret


; 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
	INCLUDE inc\water.inc
	INCLUDE inc\polozyc.inc
	INCLUDE inc\tlo.inc
	INCLUDE inc\rotater.inc
	INCLUDE INC\kolo.inc
	INCLUDE INC\kuraz.inc
	INCLUDE inc\toonel.inc
	INCLUDE inc\bump.inc
; 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

 zeroFill:
	xor di,di
	xor al,al
	mov cx,65535
	rep stosb
	ret

 jest_czekanie db 0

 napis4:
	mov si,OFsFont
	movzx ax,byte ptr cs:[bp]
	cmp ax,'$'
	je out_of_kura
	imul ax,14
	add si,ax
	push di
	mov ch,14
 cz1:	mov cl,8
	lodsb
 cz2:	test al,10000000b
	jz pli
	mov bl,guruCol
	mov bh,guruCol
	mov es:[di+0],bx
	mov es:[di+2],bx
	mov es:[di+4],bx
	mov es:[di+322],bx
	mov es:[di+324],bx
	mov es:[di+642],bx
	mov es:[di+644],bx
	mov es:[di+962],bx
 pli:	rol al,1
	add di,6
	dec cl
	jnz cz2
	add di,(320*4)-(8*6)
	dec ch
	jnz cz1
	pop di
	add di,8*6
	inc bp
	cmp jest_czekanie,1
	je napis4
	mov cx,40
 ra1:	call wait_vbl
	loop ra1
	jmp napis4
 out_of_kura:
	ret

 kolorr db 3eh
 gurucol db 7fh
 gupui db 0

 napis1:
	mov si,OFsFont
	movzx ax,byte ptr cs:[bp]
	cmp ax,'$'
	je oqt_of_kura
	imul ax,14
	add si,ax
	push di
	mov ch,14
 cq1:	mov cl,8
	lodsb
 cq2:	test al,10000000b
	jz pqi
	mov bl,kolorr
	mov b es:[di],bl
 pqi:	rol al,1
	inc di
	dec cl
	jnz cq2
	add di,320-8
	dec ch
	jnz cq1
	cmp gupui,1
	je plum_P
	mov d es:[di-17*320],0bfbfbfbfh
	mov d es:[di-17*320+4],0bfbfbfbfh
 plum_P:
	pop di
	add di,8
	inc bp
	cmp jest_czekanie,1
	je napis1
	mov cx,2
 rq1:	call wait_vbl
	loop rq1
	jmp napis1
 oqt_of_kura:
	ret


GetFontAddr:
	mov ah,11h	;font 8*14
	mov al,30h
	mov bh,2
	int 10h
	mov SegFont,es
	mov OfsFont,bp
	ret

SetPal:
	call wait_vbl
	xor ax,ax
	mov cx,64
	mov dx,03c8h
 sp1:	out dx,al
	inc dx
	out dx,al
	out dx,al
	out dx,al
	dec dx
	inc al
	dec cx
	jnz Sp1
	mov cx,64
	mov bl,al
 sp2:	mov al,bl
	out dx,al
	inc dx
	mov al,bl
	out dx,al
	out dx,al
	mov al,0
	out dx,al
	dec dx
	inc bl
	dec cx
	jnz Sp2
	mov cx,64
 sp3:	mov al,bl
	out dx,al
	inc dx
	mov al,bl
	out dx,al
	mov al,0
	out dx,al
	out dx,al
	dec dx
	inc bl
	dec cx
	jnz sp3
	mov cx,64
 sp4:	mov al,bl
	out dx,al
	inc dx
	mov al,0
	out dx,al
	out dx,al
	mov al,bl
	out dx,al
	dec dx
	inc bl
	dec cx
	jnz sp4
	ret


Wait_Vbl:
	mov dx,03dah
 hey:	in al,dx
	test al,8
	jne hey
 hey2:	in al,dx
	test al,8
	je hey2
	ret

flesh:
	call wait_vbl
	mov cx,256
	mov dx,03c8h
	xor bl,bl
 fl1:	mov al,bl
	out dx,al
	inc dx
	mov al,63
	out dx,al
	out dx,al
	out dx,al
	dec dx
	inc bl
	dec cx
	jnz fl1
	ret

draw_kura:
	lea si,kura
	mov ch,13
 dk1:	mov cl,16
 dk2:	mov al,cs:[si]
	or al,al
	jz ndk
	mov ah,al
	mov es:[di+000],ax
	mov es:[di+002],ax
	mov es:[di+320],ax
	mov es:[di+322],ax
	mov es:[di+640],ax
	mov es:[di+642],ax
	mov es:[di+960],ax
	mov es:[di+962],ax
 ndk:	add di,4
	inc si
	dec cl
	jnz dk2
	add di,(320*4)-(16*4)
	dec ch
	jnz dk1
	ret

draw_kura2:
	lea si,kura
	mov ch,13
 dq1:	mov cl,16
 dq2:	mov al,cs:[si]
	or al,al
	jz nqk
	mov ah,al
	mov es:[di+000],ax
	mov es:[di+320],ax
 nqk:	add di,2
	inc si
	dec cl
	jnz dq2
	add di,(320*2)-(16*2)
	dec ch
	jnz dq1
	ret

drawSeg1:
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment1
	mov ds,ax
	xor si,si
	mov cx,32000
	rep movsw
	ret

;es:di-segment
Soften:
	mov di,321
	mov ch,198
 sof1:	mov dx,318
 sof2:	mov al,es:[di-1]
	add al,es:[di+1]
	add al,es:[di-320]
	add al,es:[di+320]
	shr al,2
	mov es:[di],al
	inc di
	dec dx
	jnz sof2
	add di,2
	dec ch
	jnz sof1
	ret


flesz_kura db 0

ple	db 'FARMER$'
ple2	db 'Only KURA''s power makes it possible$'
ple3	db '+KURA+$'
ple4	db ' KURA $'
ple5	db 'Cold water+KURA = very stupid egg !$'
ple7	db 'STOP!$'
ple8	db 'And now coming up 64000 points$'
ple9	db 'big environmen KURAZ!  EGG RLZ$'
plea	db 'HERE IT IS A VERY STRANGE DUCK DUCK :($'
pleb	db '2-KURY$'

int1	db 'FARMER&KURA was coded in one day$'
int2	db 'in pure fucking r-mode...$' 
int5	db 'GREETINGS:$'
int6	db 'Absence,Pulse,Substance,Motion$'
int7	db 'Poison,Tcman,Camorra...and YOU$'
int8	db 'THANX FOR WATCHING DIZ 4KB$    '



; 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
	INCLUDE INC\kura.inc
	INCLUDE INC\vars.inc
; 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

code ends
end start