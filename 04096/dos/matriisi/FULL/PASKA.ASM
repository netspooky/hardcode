	IDEAL
	P386

segment cseg byte public 'Code'
	assume  cs:cseg, ds:cseg
	org 100h                ;com file

;²²²² Some kewlcool equations ²²²²

halfrate        equ true                ;tummempi tunneli
psychedelic_funkin      equ     true    ;xor-plasma
nasty_memalloc          equ     true    ;since DOS/Win95 _should_ release
					;all memory we have allocated, we
					;shouldn't need to release it.. :)
assume_segments         equ     true    ;nasty assumption that CS=DS=ES when
					;program starts. It SHOULD be :)
assume_memory_enuff     equ     true    ;don't check for memory allocation
					;errors :)

put_info                equ     true    ;put information about author to the COM

black_color             equ      0

include 'macros.inc'

routine:
;
; make the initialisation
;

IFNDEF  assume_segments
	push            cs
	pop             ds
	push            cs
	pop             es
ENDIF

;get lingua
@prompti:       
mov ah,9
mov dx,offset choosel
int 21h
mov ah,0
int 16h
sub al,'A'
cmp al,3
ja  @prompti
mov ah,0
mov [langskhip],ax
		
;ÍÍÍÍÍÍÍÍÍ prepare memory allocation
	     mov ah,62h                  ;get psp address
	     int 21h
	     mov ah,4ah                  ;get the useless memory free
	     mov bx,4096
	     int 21h

IFNDEF  assume_memory_enuff
	     jc  malloc_error
ENDIF

;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍ allocate memory
	     mov        di,offset alphaprecalc
	     mov        cx,6
	    memallocloop:
	     mov        ah,48h
	     ;if no error occured during previous call to INT 21h,
	     ;BX is unmodified -> mov bx,4096 not necessary.
	     ;request for 256*256 bitmap
	     int 21h
IFNDEF  assume_memory_enuff
	     jc  malloc_error
ENDIF
	     stosw
	     loop       memallocloop

	     mov        si,offset offset tunnel
	     lodsw
	     mov        gs,ax
	     lodsw
	     mov        fs, ax

IFNDEF  assume_memory_enuff
	     jmp        @no_merror
malloc_error:
	     ret
ENDIF
	     @no_merror:

;set segments ok

	getfont
	generate_cosinetable
	mov     ax,13h
	int     10h
	generate_palette
push cs
pop ds
hook_timer

	precalc_tunnel

;
; the stuff runs here.. vittu RAI!
;

;script:
;       3s    k„nnykk„        ("mokia elite-gsm")
;       2s    keskustelu1     ("do you want to know what the matrix is?")
;       3s    matriisi-efekti
;       2s    keskustelu2     ("vittu s„ tosta mit„„n tajuu")
;                             ("ota tosta pilsu, niin rupeet s„kin tajuumaan")
;       1s   "pilleri"       ("lsd")
;       2s  keskustelu3     ("ei pillerit o kulmikkaita")
;                           ("en viittinyt koodata py”reet„")
;       5s  monologi1
;       7s  tunneli+monologi2
;                               ("ja kaikki pahat agentit putoavat matriisin sy”veriin")
;       8s  yksikk”matriisi ("the matrix has you")

length1 equ 2048+1024 ; 3 sekuntia
length2 equ length1+2048+1024
length3 equ length2+4096-1024
length4 equ length3+2048
length5 equ length4+1024
length6 equ length5+2048
length7 equ length6+1024*5
length8 equ length7+1024*7
length9 equ length8+1024*5

final_length equ length8+1024*5

initialframe equ 0

call clear_vscreen

mov [dword cs:frameskip],initialframe
 mainlooppi:
	push    cs
	pop     ds
	cmp     [dword frameskip],length1
	jae     @phase2
;############
mov ax,[vscreen]
mov es,ax
mov ax,[fontpointer]
mov fs,ax
call kannykka
cmp [dword frameskip],2048
jbe @phase_ready
mov  si, offset text0
mov  dx, 1
mov  di, 20*320+100
mov  al, 100
call DrawText
	jmp     @phase_ready
@phase2:
	cmp [dword frameskip], length2
	jae @phase3

;#############

call keanu_morf
cmp [dword frameskip], length2-2048
jbe @phase2r
mov  di,80*320+10
mov  si, offset atext1
call DrawText
cmp [dword frameskip], length2-2048+512
jbe @phase2r
mov  di,90*320+10
mov si, offset atext11
call Drawtext

cmp [dword frameskip], length2-1024
jbe @phase2r
mov  di,80*320+200
mov  si, offset btext1
call DrawText

cmp [dword frameskip], length2-512
jbe @phase2r
mov di, 90*320+200
mov si, offset btext11
call DrawText
	@phase2r:
	jmp @phase_ready
@phase3:
	cmp [dword frameskip],length3
	jae @phase4

;#############
call clear_vscreen
mov ax, [vscreen]
mov es, ax
mov ax, [fontpointer]
mov fs,ax
mov ax, [mtvscreen]
mov ds,ax
call update_matrix
push cs
pop ds
	jmp @phase_ready
@phase4:
	cmp [dword frameskip], length4
	jae @phase5
;###################
call keanu_morf
mov al, 100
mov si, offset atext2
mov di, 200+80*320
mov dx,1
call DrawText
cmp [dword frameskip], length4-1024-512
jbe @phase4r
mov si, offset atext22
mov di, 200+90*320
call DrawText

cmp [dword frameskip], length4-1024
jbe @phase4r
mov si, offset btext2
mov di, 10+80*320
call DrawText

@phase4r:
	jmp @phase_ready
@phase5:
	cmp [dword frameskip], length5
	jae @phase6
;###############
call clear_vscreen
mov ax, [vscreen]
mov es,ax       
mov cx, 100
mov di, 160-80+50*320
mov dx, 80
mov al, 100
call DrawBar
mov si, offset lsd
mov di, 160-80+50*320+20*320+20
mov al, 60
mov dx, 2
call DrawText
jmp @phase_ready

@phase6:
	cmp [dword frameskip], length6
	jae @phase7
;#################
call clear_vscreen
call keanu_morf
mov  di,80*320+160
mov  si,offset atext3
mov  dx,1
mov  al,100
call DrawText
cmp  [dword frameskip], length6-1024
jbe  @phase6r
mov  di,90*320+10
mov  si, offset btext3
call DrawText
@phase6r:
jmp @phase_ready

@phase7:
	cmp [dword frameskip], length7
	jae @phase8
;##################
call clear_vscreen
mov ax,[vscreen]
	mov es,ax       
mov al,100
mov si,offset mtext1
mov di,10*320+20
mov dx,1
call DrawText
cmp [dword frameskip], length7-4096
jbe @phase7r

mov si,offset mtext11
mov di,20*320+20
call DrawText
cmp [dword frameskip], length7-4096+1024
jbe @phase7r

mov si,offset mtext12
mov di, 30*320+20
call DrawText
cmp [dword frameskip], length7-2048
jbe @phase7r

mov si,offset mtext13
mov di, 40*320+20
call DrawText
cmp [dword frameskip], length8-1024
jbe @phase7r

mov si,offset mtext14
mov di, 50*320+20
call DrawText

@phase7r:
jmp @phase_ready

@phase8:
	cmp [dword frameskip], length8
	jae @phase9
;#######################
	mov     ax,[virtual]
	mov     es,ax
	create_plasma
	mov     ax,[vscreen]
	mov     es,ax
	mov     ax,[tunnel2]
	mov     fs,ax
	mov     ax,[virtual]
	mov     ds,ax
	draw_tunnel
	push    cs
	pop     ds
mov ax,[fontpointer]
mov fs,ax
mov al,100
mov si,offset mtext2
mov di,320*20+20
mov dx,1
call DrawText
cmp [dword frameskip], length7+1024
jbe @phase8r

mov si,offset mtext21
mov di,320*30+20
call Drawtext
cmp [dword frameskip], length7+2048
jbe @phase8r

mov si,offset mtext22
mov di,320*40+20
call DrawText
cmp [dword frameskip], length7+1024*3
jbe @phase8r

mov ax, [mtvscreen]
mov ds,ax
call update_matrix
push cs
pop ds

@phase8r:
jmp @phase_ready

@phase9:
	cmp [dword frameskip], length9
	jae @phase_ready
;################
call clear_vscreen
mov ax,[fontpointer]
mov fs,ax
mov ax,[vscreen]
mov es,ax
mov al,100
mov dx,16
mov bx,'['
matrixs equ 40*320+20
mov di,matrixs
call DrawChar
mov di,matrixs+140
mov bx,']'
call DrawChar

mov di,matrixs+20*320+80
mov si,offset m1
mov dx,2
call DrawText
mov di,matrixs+320*40+80
mov si,offset m2
call DrawText
mov di,matrixs+320*60+80
mov si,offset m3
call DrawText
mov di,matrixs+320*80+80
mov si,offset m4
call DrawText

cmp [dword frameskip], length8+1024
jbe @phase_ready
mov si,offset ma1
mov di,90+320*10
mov dx,2
call DrawText

cmp [dword frameskip], length8+1024*3
jbe @phase_ready
mov si,offset ma2
mov di,90+320*170
mov dx,2
call DrawText

@phase_ready:
	waitretrace
	mov ax, [vscreen]
	mov es, ax
	copy_virtual

cmp [dword cs:frameskip],final_length
jae @ich_komme
	in      al,60h
	cmp     al,1            ;wait ESC
	jne     mainlooppi
@ich_komme:

;
; exit the addy
;

IFNDEF  nasty_memalloc
;ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ Release memory

	    mov  si,offset alphaprecalc
	    mov  cx,6
	    rmemloop:
	     lodsw
	     mov es,ax
	     mov ah,49h
	     int 21h
	     loop rmemloop
ENDIF

unhook_timer
	     mov ax,3
	     int 10h
push cs
pop ds
mov dx, offset jorina
mov ah,9
int 21h
	     ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; The routines
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
;--IN:   si = offset of beginner
proc kippaa near
	push cx
	push ax
	
	mov cx, [langskhip]
	jcxz @noshkip
	@shkipl:
		lodsb
		cmp  al,0
		jne  @shkipl
		dec  cx
		jnz  @shkipl
	@noshkip:                       
	pop ax
	pop cx
	ret
endp
	
;assumes ds=cs
proc    kannykka        near
xkanny  equ 60
ykanny  equ 10*320
antlev  equ 15
antpit  equ 40
runklev equ 80
runkpit equ 120
ruutpit equ 30
ruutlev equ 60
mokialev equ 1
	pusha
		mov  dx,antlev
		mov  cx,antpit
		mov  di,ykanny+xkanny+10
		mov  al,120
		call DrawBar    ;antenni
		mov  dx,runklev
		mov  cx,runkpit
		mov  di,ykanny+xkanny+antpit*320
		call DrawBar    ;runko
		mov  ax,40
		mov  dx,ruutlev
		mov  cx,ruutpit
		mov  di, ykanny+xkanny+25*320+antpit*320+(runklev-ruutlev)/2
		call DrawBar    ;ruutu

		mov  dx,mokialev
		mov  si,offset mokia
		mov  di, ykanny+xkanny+10*320+antpit*320+(runklev-mokialev*8*5)/2
		call DrawText ;mokia
		mov  si,offset elitegsm
		mov di, ykanny+xkanny+70*320+antpit*320+(runklev-mokialev*8*7)/2
		call drawText
	popa
	ret
endp

;--IN:
;       fs:bp = 8x8 font pointer
;       es = target segment
proc    naamat near
	pusha
	mov     dx, 8
	mov     bx, 1
	mov     ax, 120
	mov     di,120*320+20
	call    drawChar
	inc     bx
	mov     di,120*320+200
	call    drawChar
	popa
	ret
endp

include 'efects.asm'
include 'misc.asm'
include 'gfx.asm'

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Data area
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

seed         dw 9821                           ;Random number seed

;
; other data
;

coloadder dw    1000
fontcoord       dw      0
textcounter     dw      320*145+40

textc   dw 0
	
langskhip dw 0

label choosel
	db 'Choose language',10,13,'valj spraket du gamla hintar-pojke',10,13
	db 'valitse kieli',10,13,'wo machtest du sprechen?',10,13
	db 'A=english, B=puppel-pojkar språket, C=suomi, D=gestapo',10,13,'$'
	
label jorina
	db 'Kahden vuoden tauon j„lkeen... pelkk„„ sontaa:)$'

label m1
	db '1 0 0 0',0
	db '0 0 0 6',0
	db '1 0 0 0',0
	db '1 0 0 0',0
label m2
	db '0 1 0 0',0
	db '0 0 6 0',0
	db '0 1 0 0',0
	db '0 1 0 0',0
label m3
	db '0 0 1 0',0
	db '0 6 0 0',0
	db '0 0 1 0',0
	db '0 0 1 0',0
label m4
	db '0 0 0 1',0
	db '6 0 0 0',0
	db '0 0 0 1',0
	db '0 0 0 1',0
label ma1
	db 'Matrix',0
	db 'Matrix',0
	db 'Matrix',0
	db 'Matrix',0
label ma2
	db 'has you',0
	db 'has you',0
	db 'has you',0
	db 'has you',0

label keanu
	db 'keanu',0
	db 'keanu',0
	db 'keanu',0
	db 'kenny',0
label morfeus
	db 'Morphine',0
	db 'et Morfin',0
	db 'Morfiini',0
	db 'das Morfin',0
label lsd
	db 'LSD',0
	db 'LSD',0
	db 'LSD',0
	db 'LSD',0


label text0
	db 'Morphine calling',0
	db 'et Morfin ringar',0
	db 'Morfiini soittaa',0
	db 'das Morfin spielen',0
	
label atext1
	db 'do you want to know',0
	db 'do you want to know',0
	db 'do you want to know',0
	db 'do you want to know',0
	label atext11
	db 'what the matrix is?',0
	db 'what the matrix is?',0
	db 'what the matrix is?',0
	db 'what the matrix is?',0
  label btext1
	db 'iccl',0
	db 'intressen==0',0
	db 'evvk',0
	db 'warum?',0
	label btext11
	db 'tell me about it',0
	db 'ber„tt„ k„r„ v„n',0
	db 'tai kerro vaan',0
	db 'sprecht sie schwein',0

label atext2
	db 'you dig?',0
	db 'hiffar du?',0
	db 'tajuuks„ muka',0
	db 'verstehen sie',0
	label atext22
	db ' ',0
	db 'hiffa, perkele!',0
	db 'tosta jotain?',0
	db 'oder schaisse?',0
  label btext2
	db 'Sure. You wanna also?',0
	db 'Sakert. Vill du ocksa?',0
	db 'Toki. Haluatko sin„kin?',0
	db 'Doch. Wollen sie ....',0

label atext3
	db 'Rectangular pill ?!!',0
	db 'vad fittan?!',0
	db 'Kulmikas pilleri?!',0
	db 'das square-tablet?!',0
  label btext3
	db '..me drink, others code',0
	db '..vill inte kooda',0
	db '..aina viitti koodata',0
	db '..ich bin so mude',0

label mtext1
	db 'And Keanu haxxored the matrix',0
	db 'och Keanu haxxoren den matriksen',0
	db 'Ja keanu hakkeroi matriisia',0
	db 'und Keanu das matrixen gehaxxored',0
label mtext11
	db 'WIntel agent Smith tried to stop him',0
	db 'Agenten Smith k„mpade stoppa honom',0
	db 'WIntelin agentti Smith yritti est„„',0
	db 'Den Wintel-agenten Smith --haltade',0
label mtext12
	db 'but finally Keanu managed to create',0
	db 'men egentligen Keanu hade koodat',0
	db 'mutta lopulta Keanu sai aikaiseksi',0
	db 'aber „ntligen Keanu hade gekoodat',0
label mtext13
	db '..matrix effect',0
	db '..en matris effekten',0
	db '..matriisiefektin',0
	db '..den matrix effekten',0
label mtext14
	db 'and beat the mean WIntel-AI',0
	db 'och vinnade den Iivil WIntel-AI',0
	db 'ja voitti ilke„n WIntel-teko„lyn',0
	db 'und ei siis mitaan clueta nyt tasta..',0

label mtext2
	db 'and the agents fell into the',0
	db 'och de agenterna fallade',0
	db 'ja agentit putosivat matriisin',0
	db 'und die agenter gefallt nach',0
label mtext21
	db 'depths of the Matrix',0
	db 'till Matrixen',0
	db 'sy”vereihin',0
	db 'das Matrix',0
label mtext22
	db 'Keanu got laid and a warez-cd',0
	db 'Keanu fick fittan och en warez-cd',0
	db 'keanu sai --llua ja warez-cd:n',0
	db 'Keanu hast gefuck und das warez-cd',0

label mokia
	db 'Mokia',0
	db 'Mokia',0
	db 'Mokia',0
	db 'Mokia',0
label elitegsm
	db 'El8-gsm',0
	db 'El8-gsm',0
	db 'El8-gsm',0
	db 'El8-gsm',0

IFDEF   put_info
label         info_msg byte
		db   'Loko/Mooze^AgL / '
		db   'v158929@proffa.cc.tut.fi'
ENDIF

frameskip  dd 0
framecount dd 0
tempframe  dd 0

nuotti          db 0
kohta           db 0

lastframe dd ?
wanha_timer dw ?, ?

alphaprecalc    dw ?
mtvscreen       dw ?
vscreen         dw ?
virtual         dw ?    ;these seven variables need to be this way :)
tunnel          dw ?
tunnel2         dw ?
fontpointer     dw ?


yc1             dw      ?
yc2             dw      ?
vadder          dw      ?
crad            dw      ?
colo1           dw      ?
costable        db     64*3     dup (?) ;don't change the order of these
sintable        db     64+256   dup (?)

ends    cseg

end routine
end
