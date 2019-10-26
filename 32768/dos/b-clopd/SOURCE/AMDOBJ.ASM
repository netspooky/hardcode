;Source for the Amusic-Playerobject
;6.12.1995 by Conqueror / îœ$$$
;
;Note: Diz was written for packed modules!
;      And please do not use modules bigger than 64k !!! It doesn't work!
;
;This player stores all datas and stuff into one userdefined-workbuffer.
;No other dos memory is needed!!!
;

JUMPS

PUBLIC _InitAdlib
PUBLIC _AdlibPlayer
PUBLIC _StopAdlib
PUBLIC _AdlibState

FreqStart       =       156h            ; low end of frequency in each octave
FreqEnd         =       2aeh            ; high end of frequency in each octave
FreqRange       =       FreqEnd-FreqStart


WrkBuff_TrackBase       equ 0           ;Pointer to each track
WrkBuff_TrackPtr        equ 480h        ;Offsets in current tracks
WrkBuff_TrackDelay      equ 492h        ;Delay for current tracks
WrkBuff_CurrPtn         equ 49Bh        ;
WrkBuff_CurrLine        equ 49Ch        ;
WrkBuff_SongDelay       equ 49Dh        ;
WrkBuff_CurrSpeed       equ 49Eh        ;
WrkBuff_CurrEvent       equ 49Fh        ;privat Buffer!!!
WrkBuff_LastEvent       equ 4A4h        ;
WrkBuff_CarrVol         equ 510h
WrkBuff_ModVol          equ 519h

WrkBuffSize equ 522h


.model small
.code
main:
.186

_AdlibState     db 0            ;set to zero if adlib not detected!!!


ev_pitch        equ 0
ev_oct          equ 1
ev_sam          equ 2
ev_cmd          equ 3
ev_params       equ 4

ev_vol          equ 5   ;lastvol
ev_arpeggio     equ 6
ev_pitching     equ 7
ev_tpdest       equ 9
ev_lastparams   equ 11  ;for TonePortamento and stuff!!!
LastEventSize   equ 12


FreqParams      dw 343,363,385,408,432,458,485,514,544,577,611,647

oldint08        dw 0,0

ModPtr          dw 0,0
WrkPtr          dw 0,0



;----- InitAdlib ----------
;
; This proc fills the work buffer with pointers, defaults and stuff.
; Call this to create a buffer for a tune!!!
;


;ds:si = Modulepointer
;es:di = Workbuffer
;al = playmode (0=interrupt 1=polling)

_InitAdlib proc near
	pusha
	push    ax

	mov     cs:[ModPtr],si
	mov     ax,ds
	mov     cs:[ModPtr+2],ax
	mov     cs:[WrkPtr],di
	mov     ax,es
	mov     cs:[WrkPtr+2],ax


	call    Adlib_Reset

;---- Clear Workbuffer
	push    di
	xor     ax,ax
	mov     cx,WrkBuffSize/2
	rep     stosw
	pop     di

;---- Init trackpointer
	mov     bl,ds:[si+933]          ;number of patterns
	inc     bl
	xor     bh,bh
	imul    bx,18
	lea     si,[si+bx+1072]         ;offset of the tracks
	lodsw
	mov     cx,ax
ia_GetTrackPtrLoop:
	lodsw                           ;read trackposition
	mov     bx,ax
	add     bx,bx
	mov     es:[di+bx],si           ;store pointer into trackptrtab!
	xor     dl,dl
ia_SearchNextTrack:
	lodsb
	test    al,128
	jnz     ia_Jump
	lodsw
	inc     dl
	jmp     ia_GetNextEvent
ia_Jump:
	and     al,127
	add     dl,al
ia_GetNextEvent:
	cmp     dl,64
	jb      ia_SearchNextTrack
	loop    ia_GetTrackPtrLoop

	mov     word ptr es:[di+WrkBuff_SongDelay],0606h   ;default tempo!!!

	pop     ax
	mov     cs:[irqmod],al
	cmp     al,1
	jz      ia_PollingMode

;---- Init the Timer-IRQ
	cli
	mov     ax,3508h
	int     21h
	mov     cs:[oldint08],bx
	mov     cs:[oldint08+2],es

	mov     ax,2508h
	push    cs
	pop     ds
	mov     dx,offset TimerProc
	int     21h

	mov     ax,5D37h        ;50Hz
	out     40h,al
	mov     al,ah
	out     40h,al
	sti

ia_PollingMode:

	popa
	ret
_InitAdlib endp


_StopAdlib proc near
	push    ds

	cmp     cs:[irqmod],1
	jz      sa_Polling

	cli
	mov     al,-1
	out     40h,al
	out     40h,al

	mov     ax,2508h
	push    cs:[oldint08+2]
	pop     ds
	mov     dx,cs:[oldint08]
	int     21h
	sti

sa_Polling:
	call    Adlib_Reset
	pop ds
	ret
_StopAdlib endp


irqmod  db 0

TimerProc proc near
	push    ax ds es si di
	lds     si,dword ptr cs:[ModPtr]
	les     di,dword ptr cs:[WrkPtr]
	call    _AdlibPlayer
	mov     al,20h
	out     20h,al
	pop     di si es ds ax
	iret
TimerProc endp




;------ Adlib Player --------
;
; This is the mainfunction of the player jump into this code 50 times a sec.
; (or what ever your songtempo is)
;



;ds:si = Modulepointer
;es:di = Workbuffer


_AdlibPlayer proc near
	cmp     cs:[_AdlibState],0
	jz      ap_NoAdlibPresent
	pusha
	mov     al,byte ptr es:[di+WrkBuff_SongDelay]
	dec     al
	jnz     ap_JustDoTheFX

	mov     al,byte ptr es:[di+WrkBuff_CurrSpeed]
	mov     byte ptr es:[di+WrkBuff_SongDelay],al
	cmp     byte ptr es:[di+WrkBuff_CurrLine],0
	jnz     ap_ContPtn
	call    CalcTrackPtr
ap_ContPtn:

	mov     cs:[breakstate],0

	xor     cx,cx
ap_ChannelLoop:
	mov     bx,cx

	mov     al,byte ptr es:WrkBuff_TrackDelay[di+bx]
	and     al,127
	jz      ap_TryToGetEvent
	dec     byte ptr es:WrkBuff_TrackDelay[di+bx]
	jmp     ap_StillWaiting

ap_TryToGetEvent:
	mov     byte ptr es:WrkBuff_TrackDelay[di+bx],0
	add     bx,bx
	mov     bp,es:WrkBuff_TrackPtr[di+bx]

	mov     al,ds:[bp]      ;Is it a delay??? Then wait!!!
	test    al,128
	jz      ap_NewEvent
	dec     al
	inc     word ptr es:WrkBuff_TrackPtr[di+bx]
	mov     bx,cx
	mov     byte ptr es:WrkBuff_TrackDelay[di+bx],al
	jmp     ap_StillWaiting

ap_NewEvent:
	add     word ptr es:WrkBuff_TrackPtr[di+bx],3

;---- Decode current event


	mov     byte ptr es:[di+WrkBuff_CurrEvent+ev_params],al
	mov     ax,ds:[bp+1]
	mov     dl,al
	and     dl,0Fh
	mov     byte ptr es:[di+WrkBuff_CurrEvent+ev_cmd],dl
	mov     dx,ax
	shr     dx,4
	and     dl,11111b
	mov     byte ptr es:[di+WrkBuff_CurrEvent+ev_sam],dl
	mov     al,ah
	shr     al,1
	and     al,7
	mov     byte ptr es:[di+WrkBuff_CurrEvent+ev_oct],al
	shr     ah,4
	mov     byte ptr es:[di+WrkBuff_CurrEvent+ev_pitch],ah


;############# update channel !! ###########

	imul    bp,cx,LastEventSize

;--- change instrument???
	mov     al,es:[di+WrkBuff_CurrEvent+ev_sam]
	or      al,al
	jz      uc_NoInstrChange
	mov     es:[di+WrkBuff_LastEvent+ev_sam+bp],al  ;update instrument
	mov     byte ptr es:[di+WrkBuff_LastEvent+ev_vol+bp],3Fh

uc_NoInstrChange:

;--- change the pitch???
	mov     al,es:[di+WrkBuff_CurrEvent+ev_pitch]
	or      al,al
	jz      uc_NoPitch
	cmp     byte ptr es:[di+WrkBuff_CurrEvent+ev_cmd],8
	jz      uc_NoPitch
	mov     es:[di+WrkBuff_LastEvent+ev_pitch+bp],al    ;update pitch
	mov     al,es:[di+WrkBuff_CurrEvent+ev_oct]
	mov     es:[di+WrkBuff_LastEvent+ev_oct+bp],al

;--- play the new note!
	mov     word ptr es:[di+WrkBuff_LastEvent+ev_Pitching+bp],0
	jmp     uc_Ready

uc_NoPitch:
	call    SetChannelVol


uc_Ready:       ;ready with updating the channel!!!


;---- Check the FX

	mov     bx,es:[di+WrkBuff_CurrEvent+ev_cmd]
	mov     es:[di+WrkBuff_LastEvent+ev_cmd+bp],bx
	or      bh,bh
	jz      uc_NoNewLastParam
	mov     es:[di+WrkBuff_LastEvent+ev_lastparams+bp],bh
uc_NoNewLastParam:
	mov     ax,bx
	and     bx,0Fh
	add     bx,bx
	mov     dx,cs:[CmdPtrTab1+bx]
	or      dx,dx
	jz      amd_NoCommand
	push    cx
	call    dx
	pop     cx


amd_NoCommand:
	cmp     byte ptr es:[di+WrkBuff_CurrEvent+ev_cmd],8
	jz      ap_StillWaiting
	cmp     byte ptr es:[di+WrkBuff_CurrEvent+ev_pitch],0
	jz      ap_StillWaiting
	call    PlayNote



ap_StillWaiting:
	inc     cx
	cmp     cx,9
	jb      ap_ChannelLoop


;---- Go next line !
	cmp     cs:[breakstate],0
	jz      ap_GoNormal

	mov     al,cs:[breakptn]
	mov     byte ptr es:[di+WrkBuff_CurrPtn],al
	mov     al,cs:[breakline]
	mov     byte ptr es:[di+WrkBuff_CurrLine],al
	or      al,al
	jz      ap_CheckSongLoop

;--- Calculate offset into new pattern
	call    CalcTrackPtr

	xor     bx,bx
ap_CalcOffsLoop:
	mov     bp,es:[di+WrkBuff_TrackPtr+bx]
	xor     ch,ch
	mov     cl,byte ptr es:[di+WrkBuff_CurrLine]
	xor     dh,dh                                   ;dh=trackdelay
ap_RowLoop:
	or      dh,dh
	jz      ap_GetNewEvent
	dec     dh
	jmp     ap_GoOn
ap_GetNewEvent:
	mov     al,ds:[bp]
	test    al,128
	jnz     ap_MakeDelay
	add     bp,3
	xor     dh,dh
	jmp     ap_GoOn
ap_MakeDelay:
	inc     bp
	and     al,127
	dec     al
	mov     dh,al
ap_GoOn:
	inc     ch
	cmp     ch,cl
	jb      ap_RowLoop
	mov     es:[di+WrkBuff_TrackPtr+bx],bp
	mov     bp,bx
	shr     bp,1
	or      dh,128
	mov     es:[di+WrkBuff_TrackDelay+bp],dh
	add     bl,2
	cmp     bl,18
	jb      ap_CalcOffsLoop


	jmp     ap_CheckSongLoop

ap_GoNormal:
	inc     byte ptr es:[di+WrkBuff_CurrLine]
	cmp     byte ptr es:[di+WrkBuff_CurrLine],64
	jb      ap_ByeBye
	mov     byte ptr es:[di+WrkBuff_CurrLine],0
	inc     byte ptr es:[di+WrkBuff_CurrPtn]

ap_CheckSongLoop:
	mov     al,byte ptr es:[di+WrkBuff_CurrPtn]
	cmp     ds:[si+932],al
	ja      ap_ByeBye
	mov     word ptr es:[di+WrkBuff_CurrPtn],0

ap_ByeBye:
	popa
ap_NoAdlibPresent:
	ret


ap_JustDoTheFX:
	mov     byte ptr es:[di+WrkBuff_SongDelay],al

;---- Check the FX

	xor     cx,cx
	xor     bp,bp
ap_FXLoop:
	mov     bx,cx
	test    byte ptr es:WrkBuff_TrackDelay[di+bx],128
	jnz     ap_DontDoIt
	mov     bx,es:[di+WrkBuff_LastEvent+ev_cmd+bp]
	mov     ax,bx
	and     bx,0Fh
	add     bx,bx
	mov     dx,cs:[CmdPtrTab2+bx]
	or      dx,dx
	jz      ap_DontDoIt
	push    cx
	call    dx
	pop     cx
ap_DontDoIt:
	add     bp,LastEventSize
	inc     cx
	cmp     cx,9
	jb      ap_FXLoop
	jmp     ap_ByeBye

_AdlibPlayer endp



Adlib_Reset proc near

	;*** Check Adlib ***

	mov     dx,388h
	mov     al,2
	out     dx,al
	jmp     $+2
	inc     dl
	mov     al,1
	out     dx,al   ;set timer#1
	jmp     $+2
	dec     dl
	in      al,dx
	and     al,01000000b    ;received??
	jz      ar_CardOK
	ret

ar_CardOK:
	mov     cs:[_AdlibState],1


	mov     bx,1
ar_ResetLoop:
	mov     ax,bx
	and     al,0E0h
	cmp     al,40h
	jnz     ar_ClearReg
	mov     ah,63
ar_ClearReg:
	mov     al,bl
	call    Adlib_OUT
	inc     bl
	jnz     ar_ResetLoop

	mov     ax,02001h
	call    Adlib_OUT
	ret
Adlib_Reset endp





CalcTrackPtr proc near
	mov     bl,es:[di+WrkBuff_CurrPtn]
	xor     bh,bh
	mov     bl,ds:[si+bx+3A6h]      ;current pattern
	imul    bx,18
	mov     cx,9
	lea     bp,WrkBuff_TrackPtr[di]
ctp_ChLoop:
	push    bx
	mov     bx,ds:[si+bx+430h]      ;current track
	add     bx,bx
	mov     ax,es:[di+bx]
	mov     bx,cx
	mov     byte ptr es:[di+WrkBuff_TrackDelay-1+bx],0
	pop     bx
	mov     es:[bp],ax      ;store trackptr
	add     bp,2
	add     bx,2
	dec     cl
	jnz     ctp_ChLoop
	ret
CalcTrackPtr endp




CmdPtrTab1      dw offset InitArpeggio
		dw offset SlideFreqUp
		dw offset SlideFreqDown
		dw 0
		dw offset SetInsVol
		dw offset JumpPattern
		dw offset PtnBreak
		dw offset SetSongSpeed
		dw offset InitTonePortamento
		dw offset ExtCmds
		dw 0
		dw 0
		dw 0
		dw 0
		dw 0
		dw 0



;###### Commands Type#1 #######
;
;ah = Parameter of the Command
;es:[bp] = LastEvent



InitArpeggio:
	mov     byte ptr es:[di+WrkBuff_LastEvent+ev_arpeggio+bp],0
	ret

SetInsVol:
	mov     byte ptr es:[di+WrkBuff_LastEvent+ev_vol+bp],ah
	call    SetChannelVol
	ret


SetSongSpeed:
	or      ah,ah
	jz      sss_Zero
	cmp     ah,32
	jb      sss_Delay

sss_Freq:       ;change interrupt frequence
	cmp     cs:[irqmod],1
	jz      sss_polling
	mov     cl,ah
	xor     ch,ch
	mov     dx,0012h
	mov     ax,34DCh
	div     cx
	jmp     sss_Set
sss_Zero:
	mov     ax,-1
sss_Set:
	out     40h,al
	mov     al,ah
	out     40h,al
sss_polling:
	ret

sss_Delay:      ;just change the delay value
	mov     es:[di+WrkBuff_CurrSpeed],ah
	mov     byte ptr es:[di+WrkBuff_SongDelay],ah
	ret





SlideFreqUp:
	mov     bl,cl

	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	mov     dh,byte ptr es:[di+WrkBuff_LastEvent+ev_oct+bp]
	call    GetFreq
	mov     dx,ax

	mov     cl,byte ptr es:[di+WrkBuff_LastEvent+ev_params+bp]
	xor     ch,ch
	add     word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp],cx
	add     ax,word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp]

	cmp     ax,FreqRange*7+305
	jb      sfu_OK
	mov     ax,FreqRange*7+305
	sub     ax,dx
	mov     word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp],ax
	mov     ax,FreqRange*7+305
sfu_OK:
	call    SetFreq
	ret



SlideFreqDown:
	mov     bl,cl
	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	mov     dh,byte ptr es:[di+WrkBuff_LastEvent+ev_oct+bp]
	call    GetFreq
	mov     dx,ax

	mov     cl,byte ptr es:[di+WrkBuff_LastEvent+ev_params+bp]
	xor     ch,ch
	sub     word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp],cx
	add     ax,word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp]

	or      ax,ax
	jns     short sfd_OK
	not     dx
	mov     word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp],dx
	xor     ax,ax
sfd_OK:
	call    SetFreq
	ret




SetCarrModVol proc near
	mov     al,es:[di+WrkBuff_CurrEvent+ev_params]
	xor     ah,ah
	mov     dl,10
	div     dl
	or      al,al
	jz      short scmv_SetMod
	mov     dh,ah
	xor     ah,ah
	mov     dl,7
	mul     dl
	xor     al,03Fh
	xor     al,al
	mov     es:[di+WrkBuff_CarrVol+bx],al
	mov     ah,dh
scmv_SetMod:
	or      ah,ah
	jz      scmv_byebye
	mov     al,ah
	xor     ah,ah
	mov     dl,7
	mul     dl
	xor     al,3Fh
	mov     es:[di+WrkBuff_ModVol+bx],al
scmv_byebye:
	ret
SetCarrModVol endp







InitTonePortamento:
	mov     al,byte ptr es:[di+WrkBuff_CurrEvent+ev_pitch]
	or      al,al
	jz      itp_NoPitch
	mov     dh,byte ptr es:[di+WrkBuff_CurrEvent+ev_oct]
	call    GetFreq
	mov     word ptr es:[di+WrkBuff_LastEvent+ev_tpdest+bp],ax
	call    TonePortamento
itp_NoPitch:
	ret





TonePortamento:
	push    si
	push    cx
	mov     si,word ptr es:[di+WrkBuff_LastEvent+ev_tpdest+bp]
	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	xor     ah,ah
	mov     dh,byte ptr es:[di+WrkBuff_LastEvent+ev_oct+bp]
	call    GetFreq
	mov     dx,ax
	mov     bx,word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp]
	add     dx,bx

	xor     ch,ch
	mov     cl,byte ptr es:[di+WrkBuff_LastEvent+ev_lastparams+bp]
	cmp     dx,si
	ja      tp_down
	jb      tp_up
tp_byebye:
	mov     word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp],bx
	mov     ax,dx
	pop     bx
	pop     si
	call    SetFreq
	ret

tp_up:
	add     bx,cx
	add     dx,cx
	cmp     dx,si
	jbe     tp_byebye
	mov     dx,si
	mov     cx,dx
	sub     cx,ax
	mov     bx,cx
	jmp     tp_byebye


tp_down:
	sub     bx,cx
	sub     dx,cx
	cmp     dx,si
	jae     tp_byebye
	mov     dx,si
	sub     dx,ax
	mov     bx,dx
	mov     dx,si
	jmp     tp_byebye


ExtCmdsTab label word
	dw offset CellTrem
	dw offset CellVib
	dw offset SlideVolUp
	dw offset SlideVolDown
	dw offset SlideVolUp
	dw offset SlideVolDown
	dw 0
	dw 0
	dw 0
	dw 0

ExtCmds proc near
	mov     al,es:[di+WrkBuff_CurrEvent+ev_params]
	xor     ah,ah
	mov     dl,10
	div     dl
	add     al,al
	xor     ah,ah
	mov     bx,ax
	mov     ax,cs:[ExtCmdsTab+bx]
	or      ax,ax
	jz      ec_dont
	call    ax              ;ah=param
ec_dont:
	ret
ExtCmds endp


Adlib_BD db 0   ;contents of register BDh

CellTrem proc near
	or      ah,ah
	jz      ct_Clear
	or      cs:[Adlib_BD],128
	jmp     ct_set
ct_Clear:
	and     cs:[Adlib_BD],not 128
ct_set:
	mov     ah,cs:[Adlib_BD]
	mov     al,0BDh
	call    Adlib_OUT
	ret
CellTrem endp


CellVib proc near
	or      ah,ah
	jz      cv_Clear
	or      cs:[Adlib_BD],64
	jmp     ct_set
cv_Clear:
	and     cs:[Adlib_BD],not 64
cv_set:
	jmp     ct_set
CellVib endp





SlideVolUp proc near
	mov     bh,es:[di+WrkBuff_LastEvent+ev_vol+bp]
	mov     al,es:[di+WrkBuff_LastEvent+ev_params+bp]
	xor     ah,ah
	mov     bl,10
	div     bl

	add     bh,ah
	cmp     bh,63
	jbe     sv_done
	mov     bh,63
sv_done:
	mov     es:[di+WrkBuff_LastEvent+ev_vol+bp],bh
sv_hallo:
	call    SetChannelVol
	ret
SlideVolUp endp


SlideVolDown proc near
	mov     bh,es:[di+WrkBuff_LastEvent+ev_vol+bp]

	mov     al,es:[di+WrkBuff_LastEvent+ev_params+bp]
	xor     ah,ah
	mov     bl,10
	div     bl

	sub     bh,ah
	jns     sd_done
	xor     bh,bh
sd_done:
	mov     es:[di+WrkBuff_LastEvent+ev_vol+bp],bh

	call    SetChannelVol
	ret
SlideVolDown endp




breakstate      db 0
breakline       db 0
breakptn        db 0

PtnBreak proc near
	mov     al,es:[di+WrkBuff_CurrEvent+ev_params]
	and     al,3Fh
	mov     cs:[breakline],al
	mov     al,byte ptr es:[di+WrkBuff_CurrPtn]
	inc     al
	mov     cs:[breakptn],al
	mov     cs:[breakstate],1
	ret
PtnBreak endp


JumpPattern proc near
	mov     al,es:[di+WrkBuff_CurrEvent+ev_params]
	mov     cs:[breakptn],al
	mov     cs:[breakline],0
	mov     cs:[breakstate],1
	ret
JumpPattern endp






CmdPtrTab2      dw offset Arpeggio
		dw offset SlideFreqUp
		dw offset SlideFreqDown
		dw 0
		dw 0
		dw 0
		dw 0
		dw 0
		dw offset TonePortamento
		dw offset ExtCmds2
		dw 0
		dw 0
		dw 0
		dw 0
		dw 0
		dw 0


;###### Commands Type#2 #######
;
;ah = Parameter of the Command
;es:[bp] = LastEvent



Arpeggio:
	mov     al,ah
	and     ax,07Fh
	jz      arp_OFF
	mov     bl,10
	div     bl
	mov     bh,byte ptr es:[di+WrkBuff_LastEvent+ev_arpeggio+bp]
	mov     bl,bh
	inc     bl
	cmp     bl,3
	jb      arp_goon
	xor     bl,bl
arp_goon:
	mov     byte ptr es:[di+WrkBuff_LastEvent+ev_arpeggio+bp],bl

	cmp     bh,1
	jz      arp_PlayFirst
	cmp     bh,2
	jz      arp_PlaySecond

arp_PlayNormal:
	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	jmp     ActualPitch

arp_PlayFirst:
	add     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	jmp     ActualPitch

arp_PlaySecond:
	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_pitch+bp]
	add     al,ah


ActualPitch:    ;Play the Arpeggio!!!
	mov     dh,byte ptr es:[di+WrkBuff_LastEvent+ev_oct+bp]
	cmp     al,12
	jbe     arp_PitchOK
	sub     al,12
	inc     ah
arp_PitchOK:
	cmp     dh,8
	jb      arp_OctOK
	mov     dh,7
	mov     al,12
arp_OctOK:
	mov     bl,dl
	call    GetFreq
	add     ax,word ptr es:[di+WrkBuff_LastEvent+ev_pitching+bp]
	mov     bl,cl
	call    SetFreq
arp_OFF:
	ret



ExtCmdsTab2 label word
	dw 0
	dw 0
	dw offset SlideVolUp
	dw offset SlideVolDown
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0

ExtCmds2 proc near
	mov     al,es:[di+WrkBuff_LastEvent+ev_params+bp]
	xor     ah,ah
	mov     dl,10
	div     dl
	add     al,al
	xor     ah,ah
	mov     bx,ax
	mov     ax,cs:[ExtCmdsTab2+bx]
	or      ax,ax
	jz      ec2_dont
	call    ax              ;ah=param
ec2_dont:

	ret
ExtCmds2 endp










;al=note
;dh=octave
;->ax is absolute freq

GetFreq proc near
	push    si cx

	dec     al
	add     al,al
	xor     ah,ah
	mov     si,ax
	mov     cx,cs:[FreqParams+si]
	sub     cx,FreqStart

	mov     al,dh
	and     ax,7
	mov     dx,FreqRange
	mul     dx
	add     ax,cx

	pop     cx si
	ret
GetFreq endp



;ax=absolute freq
;bl=channel

SetFreq proc near
	or      ax,ax
	jns     short sf_ok
	xor     ax,ax
sf_ok:
	cmp     ax,FreqRange*7+305
	jb      sf_ok2
	mov     ax,FreqRange*7+305
sf_ok2:


	push    si cx
	mov     cx,FreqRange
	xor     dx,dx
	div     cx              ; extracts octave in AX and freq. in DX
	add     dx,FreqStart

	mov     cl,al
	mov     al,0A0h
	add     al,bl
	mov     ah,dl
	call    Adlib_OUT

	mov     al,0B0h
	add     al,bl
	mov     ah,cl
	add     ah,ah
	add     ah,ah
	or      ah,dh
	or      ah,100000b
	call    Adlib_OUT

	pop     cx si
	ret
SetFreq endp



;al=register
;ah=value
;
Adlib_OUT proc near
	push    ax dx
	mov     dx,388h
	out     dx,al
	rept    6
	in      al,dx
	endm

	inc     dl
	mov     al,ah
	out     dx,al
	dec     dl
	rept    22
	in      al,dx
	endm
	pop     dx ax
	ret
Adlib_OUT endp





;Plays the current event
;
;es:[di+WrkBuff_CurrEvent
;cl=Channel
;

PlayNote proc near
	push    bp
	mov     bx,cx

;--- get the pointer to current instrument in ds:bp !
	mov     al,byte ptr es:[di+WrkBuff_CurrEvent+ev_sam]
	xor     ah,ah
	mov     bp,ax
	dec     bp
	js      pn_Abort
	imul    bp,34
	lea     bp,[bp+si+30h+23]

	mov     al,ds:[bp+1]
	and     al,03Fh
	mov     es:[di+WrkBuff_ModVol+bx],al
	mov     al,ds:[bp+6]
	and     al,03Fh
	mov     es:[di+WrkBuff_CarrVol+bx],al

	cmp     byte ptr es:[di+WrkBuff_CurrEvent+ev_cmd],3
	jnz     pn_DontManipulate
	call    SetCarrModVol
pn_DontManipulate:
	mov     al,cs:[ChannelOffs+bx]
	mov     dl,4
pn_Loop:
	mov     ah,ds:[bp]
	call    Adlib_OUT
	add     al,3
	mov     ah,ds:[bp+5]
	call    Adlib_OUT
	add     al,20h-3
	inc     bp
	dec     dl
	jnz     pn_Loop

	add     al,40h          ; do E0 range now
	mov     ah,ds:[bp]
	call    Adlib_OUT
	add     al,3
	mov     ah,ds:[bp+5]
	call    Adlib_OUT


	call    SetChannelVol

	mov     al,0C0h
	add     al,bl
	mov     ah,ds:[bp+6]
	call    Adlib_OUT

	mov     al,es:[di+WrkBuff_CurrEvent+ev_pitch]
	xor     ah,ah
	dec     ax
	add     ax,ax
	mov     bp,ax
	mov     dx,cs:[FreqParams+bp]

	mov     al,0A0h
	add     al,bl
	mov     ah,dl
	call    Adlib_OUT

	mov     al,0B0h
	add     al,bl
	mov     ah,dh
	call    Adlib_OUT
	mov     dl,es:[di+WrkBuff_CurrEvent+ev_oct]
	add     dl,dl
	add     dl,dl
	or      ah,dl
	or      ah,100000b
	call    Adlib_OUT       ;...und mit neuen Daten anschalten



pn_Abort:
	pop     bp
	ret
PlayNote endp

ChannelOffs     db      20h,21h,22h,28h,29h,2ah,30h,31h,32h




VolTab  db 0,95/31,182/31,262/31,336/31,405/31,470/31,530/31,587/31,641/31
	db 693/31,741/31,788/31,832/31,875/31,916/31,955/31,993/31,1029/31
	db 1064/31,1098/31,1131/31,1163/31,1193/31,1223/31,1252/31,1280/31
	db 1308/31,1335/31,1360/31,1386/31,1410/31,1435/31,1458/31,1481/31
	db 1504/31,1526/31,1547/31,1568/31,1589/31,1609/31,1629/31,1648/31
	db 1667/31,1686/31,1704/31,1722/31,1740/31,1757/31,1774/31,1791/31
	db 1808/31,1824/31,1840/31
	db 1856/31,1871/31,1887/31,1902/31,1916/31,1931/31,1945/31,1960/31
	db 1974/31,1980/31




;Sets the lastvol of channel cl
;

SetChannelVol proc near
	pusha

;--- get the pointer to current instrument in ds:bp !
	imul    bx,cx,LastEventSize
	mov     al,byte ptr es:[di+WrkBuff_LastEvent+ev_sam+bx]
	xor     ah,ah
	mov     bp,ax
	dec     bp
	js      scv_Dont
	imul    bp,34
	lea     bp,[bp+si+30h+23]

	mov     bl,byte ptr es:[di+WrkBuff_LastEvent+ev_vol+bx]
	xor     bh,bh
	mov     dl,cs:[VolTab+bx]

	mov     bx,cx
	mov     dh,cs:[ChannelOffs+bx]
	add     dh,20h

	mov     ah,dl
	xor     ah,3Fh
	mov     al,byte ptr es:[di+WrkBuff_CarrVol+bx]
	and     al,3Fh
	add     ah,al
	cmp     ah,3Fh
	jbe     scv_OK2
	mov     ah,3Fh
scv_OK2:
	mov     al,byte ptr ds:[bp+6]           ;Carrier
	and     al,not 3Fh
	or      ah,al
	mov     al,dh
	add     al,3
	call    Adlib_OUT

	test    byte ptr ds:[bp+10],1
	jz      scv_Serial

scv_Parallel:   ;Connection is ON!!!
	mov     ah,dl
	xor     ah,3Fh
	mov     al,byte ptr es:[di+WrkBuff_ModVol+bx]
	and     al,3Fh
	add     ah,al
	cmp     ah,3Fh
	jbe     scv_OK
	mov     ah,3Fh
scv_OK:
	mov     al,byte ptr ds:[bp+1]                   ;Mod
	and     al,not 3Fh
	or      ah,al
	mov     al,dh
	call    Adlib_OUT
	jmp     scv_Dont


scv_Serial:     ;Connection is OFF!!!
	mov     ah,byte ptr ds:[bp+1]                   ;Mod
	and     ah,not 3Fh
	or      ah,byte ptr es:[di+WrkBuff_ModVol+bx]
	mov     al,dh
	call    Adlib_OUT

scv_Dont:

	popa
	ret
SetChannelVol endp

	end
