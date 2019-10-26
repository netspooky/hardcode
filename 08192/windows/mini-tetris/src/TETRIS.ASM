format PE GUI 4.0
entry basla

macro CA v1,[arg]
{
common
if ~ arg eq
reverse
push arg
common
end if
call dword v1
}



include 'include\win32a.inc'


section '.data' data readable writeable



  _title db 'Mini-Tetris',0

  mmn  dd 0
  yerm dd ?
_Next db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFE,0xFF,0xFF,0xDE,0xF0,0xEE,0x73,0xFD,0xD6,0xF3,0x5A,0xDF,0xDD,0x63,0xDB,0xCF,0xFD,0xB6,0xCE,0x5C,0xFF,0xCB,0xB7,0x76,0xEF,0xFE,0x3B,0x87,0x6F,0x7F,0xE7,0xBF
      db 0xFF,0xC0,0x3E,0x7B,0xFF,0xFF,0x7F,0xEF,0xBF,0xFF,0xFB,0xFE,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF0
_Puan db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xEF,0xFF
db 0xFF,0xFF,0xFF,0xFE,0xFE,0x30,0x31,0xDF,0x3F,0xEF,0xED
db 0x6D,0x6D,0xF5,0xFE,0xFE,0xE6,0xE7,0x4F,0x6F,0xC1,0xEF
db 0x6F,0x79,0x77,0x7F,0x67,0x7B,0x77,0xDB,0x77,0xF7,0xB7
db 0xB8,0xBD,0xC7,0xFD,0x7B,0xFF,0xFF,0xFF,0xFF,0xEF,0xBF
db 0xFF,0xFF,0xFF,0xFF,0x07,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
_IBo db 0xFF,0xFF,0xFF,0xFF,0xFF,0xA6,0x8A,0xAA,0xEA,0xCB,0xAA,0xAA
db 0xAA,0xEA,0xBB,0xAA,0x8A,0xAA,0xEA,0xBB,0xAA,0xEA
db 0xAA,0xEA,0xBB,0xA6,0x18,0xA0,0xE8,0xCB,0xAF,0xFB
db 0xFF,0xEF,0xFF,0xFF,0xFF,0xBF,0xFF,0xFB,0xBF,0xFF
db 0xFF,0xEF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
db 0xFF,0xFD,0xFF,0xFF,0xFF,0xFF,0xFE,0xFF,0xF3,0x73
db 0x33,0x8E,0xFF,0xEE,0xAA,0xEB,0xB6,0xFF,0xEE,0xAA
db 0x2B,0xB6,0xFF,0xEE,0xAA,0xAB,0x8D,0x7F,0xF3,0x73
db 0x73,0xB5,0x7F,0xFF,0xFB,0xFB,0x8F,0xFF,0xFF,0xFF
db 0xFF,0xFF,0xFF
_Gamo db 0xFF,0xFF,0xFF,0xBF,0xC3,0xF7,0xC3,0xB8,0x3D,0xF3,0xDF,0xB3,0x7E,0xF5,0xDF,0xB7,0x7F,0x76
db 0xDF,0xC7,0x6F,0x76,0x81,0xDB,0x8F,0x67,0x6F,0x5D,0xE6,0x6F,0x6F,0xBD,0xF8,0xEF
db 0x80,0xC3,0xFF,0xCF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
db 0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xF7,0xFF,0xFE,0xFF,0x8B,0x7D
db 0x7E,0xE1,0x33,0x7B,0x7E,0xEF,0x7B,0xBB,0x66,0xEF,0x60,0x03,0x6A,0xEF,0x7F,0xDB
db 0x9C,0xC0,0xBF,0xEB,0x9E,0x77,0xDD,0xF3,0x9E,0x77,0xE1,0xFB,0xBE,0x40

_Sayi db 0xE7,0xDB,0xBD,0xBD,0xBD,0xBD,0xBD,0xDB,0xE7,0xC1,0xF7,0xF7,0xF7,0xF7,0xF7,0xF7,0xC7,0xF7,0x81,0x9D,0xED,0xF7,0xFB,0x9D,0xBD,0xBD,0xC3,0xC3,0xBD,0xBD,0xFD,0xFD,0xC3,0xFD,0xBD,0xC3,0xF1,0xFB,0x81,0xBB,0xDB,0xEB,0xEB,0xF3,0xFB,0xC3,0xBD,0xBD,0xFD,0xBD,0x83,0xBF,0xBF,0x81
      db 0xE3,0xDD,0xBD,0xBD,0x9D,0xA3,0xBF,0xDD,0xE1,0xF7,0xF7,0xF7,0xF7,0xF7,0xFB,0xBB,0xBB,0xC1,0xC3,0xBD,0xBD,0xBD,0xC3,0xDB,0xBD,0xBD,0xC3,0x87,0xBB,0xFD,0xC5,0xB9,0xBD,0xBD,0xBB,0xC3

  mm dd ?
  mme dd ?
  hwnd dd ?
  inst dd ?
  msg MSG
  hdc dd ?
  Rect dd 0,0,0,0
  say db 0,0,0,0,0,0,0
  syi dd 10
  kctbn dw ?

section '.code' code readable executable
  klvy:
  invoke GetAsyncKeyState,[esp+4]
  cmp ax,0x1000
  ret 4

  saytpl:
  xor ecx,ecx
  mov [kctbn],cx
  mov cl,10
  mov eax,[syi]
  aas_zx:
  test eax,eax
  jz ss_rt
  xor edx,edx
  div ecx
  inc [kctbn]
  jmp aas_zx
  ss_rt:
  add [syi],ecx
  mov esi,say
  inc esi
  ter_kt:
  lodsb
  inc al
  mov [esi-1],al
  cmp al,10
  jb sa_az
  mov al,0
  mov [esi-1],al
  jmp ter_kt
  sa_az:
  ret


  sayver:
  push ebp
  mov edi,51152
  mov esi,say
  mov ebx,_Sayi
  xor eax,eax
  mov edx,eax
  mov bp,[kctbn]
  wes_aa:
  mov cl,9
  lodsb
  and al,0x0f
  mul cl
  pusha
  add ebx,eax
  CA yazil,ebx,8,9,edi,0x0080080
  popa
  sub edi,32
  dec bp
  jne wes_aa
  pop ebp
  ret


  yazil:
  mov esi,[esp+4]
  mov edi,[mm]
  mov bh,0
  add edi,[esp+16]
  mov eax,[esp+20]
  mov edx,[esp+12]
  ks_sg:
  push edi
  mov ecx,[esp+12]
  fre_se:
  cmp bh,0
  jne  ser_tr
  mov bl,[esi]
  inc esi
  mov bh,8
  ser_tr:
  dec bh
  shl bl,1
  jc yt_ser
  mov [edi],eax
  yt_ser:
  add edi,4
  loop fre_se
  pop edi
  add edi,784
  dec dx
  jne ks_sg
  ret 20


  cukur:
  mov edi,[mm]
  xor edx,edx
  mov ecx,edx
  mov cl,196
  mov eax,[esp+8]
  mul ecx
  add eax,[esp+4]
  mov ebx,eax
  shl ebx,2
  mov eax,[esp+16]
  xor edx,edx
  mov ecx,edx
  mov cx,784
  mul ecx
  mov ecx,[esp+12]
  push ebx
  as_dd:
  mov dword [edi+ebx],0x00d0ebf0
  add ebx,eax
  mov dword [edi+ebx],0x00586568
  sub ebx,eax
  add ebx,4
  loop as_dd
  pop ebx
  mov eax,[esp+12]
  shl eax,2
  mov ecx,[esp+16]
  push ebx
  as_wd:
  mov dword [edi+ebx],0x00586568
  add ebx,eax
  mov dword [edi+ebx],0x00d0f5ff
  sub ebx,eax
  add ebx,784
  loop as_wd
  pop ebx
  add ebx,788
  mov edx,[esp+16]
  dec dx
  sub ax,4
  mov esi,[esp+20]
  we_dd:
  mov ecx,[esp+12]
  dec cx
  we_ss:
  mov dword [edi+ebx],esi
  add ebx,4
  loop we_ss
  sub ebx,eax
  add ebx,784
  dec edx
  jne we_dd
  ret 20

  clientR:
  invoke GetClientRect,[hwnd],Rect
  ret

  updt:

  CA cukur,63,5,131,201,0x00102530
  CA cukur,11,133,40,40,0x00b0cbd0
  CA cukur,6,59,51,20,0xc0cbd0
  call sayver
  call diznok
  cmp [basl],0
  je dtsd_er
  call nnktdz
  dtsd_er:
  cmp [fnsh],0
  je  sfrrd_ete
  CA yazil,_Gamo,32,24,86704,0xffff
  sfrrd_ete:

  eupdt:
  mov eax,Rect
  mov ebx,[mme]
  invoke StretchDIBits,[hdc],[eax],[eax+4],[eax+8],[eax+12],0,0,[ebx+4],[ebx+8],[mm],ebx,0,0x00CC0020
  ret

  zeromem:
  push	    eax
  push	    edi
  push	    ecx
  mov	    edi,[esp+16]
  mov	    ecx,[esp+20]
  xor	    ax,ax
  repe	    stosb
  pop	    ecx
  pop	    edi
  pop	    eax
  retn	    8

  basla:
	invoke GlobalAlloc,0,500000
	mov [mm],eax
	invoke LocalAlloc,0,3000
	mov ebx,eax
	mov ecx,1000
	mov [mme],eax
	add eax,ecx
	mov [mmn1],eax
	add eax,ecx
	mov [mmn],eax
	CA zeromem,ebx,300
	mov dword [ebx+4],WindowProc
	push ebx
	invoke	GetModuleHandle,0
	mov	[inst],eax
	pop ebx
	mov [ebx+16],eax
	push ebx
	invoke	LoadIcon,[inst],2
	pop ebx
	mov	[ebx+20],eax
	push ebx
	invoke	LoadCursor,0,IDC_ARROW
	pop ebx
	mov  [ebx+24],eax
	mov  byte [ebx+28],2
	mov  dword [ebx+36],_title
	push ebx
	invoke	RegisterClass,ebx
	pop ebx
	CA zeromem,ebx,300
	mov byte [ebx],0x28
	mov word [ebx+4],196
	mov word [ebx+8],215
	mov byte [ebx+12],1
	mov byte [ebx+14],32
	invoke	CreateWindowEx,0,_title,_title,WS_OVERLAPPEDWINDOW+WS_VISIBLE,128,128,204,243,NULL,NULL,[inst],NULL
	mov	[hwnd],eax
	invoke GetDC,eax
	mov [hdc],eax
	invoke SetStretchBltMode,eax,4
	call clientR

  mov edi,[mm]
	mov esi,edi
	mov eax,0x00b0cbd0
	mov ecx,50760
	rep stosd
	CA yazil,_Next,36,13,141960,0
	CA yazil,_Puan,44,13,66680,0
	CA yazil,_IBo,40,19,6312,0x00600000
	CA noktr,rrnk,[mmn1]
	call zerola
	call verss
	call updt

  msg_loop:
	invoke GetMessage,msg,NULL,0,0
	or	eax,eax
	jz	end_loop

	invoke	TranslateMessage,msg
	invoke	DispatchMessage,msg
	jmp	msg_loop

  end_loop:
	invoke ReleaseDC,[hwnd],[hdc]
	invoke GlobalFree,[mm]
	invoke LocalFree,[mme]
	invoke	ExitProcess,[msg.wParam]



vertip:
push eax
mov [msj],0
mov edi,[mmn]
add edi,[yerm]
xor eax,eax
mov ebx,eax
mov bl,[hgtp]
shl bx,3
mov al,[kctp]
cmp al,4
jb qqa_we
mov al,0
mov [kctp],al
qqa_we:
shl ax,1
mov esi,tipl
add esi,ebx
add esi,eax
lodsw
mov bh,4
ss_oun:
mov bl,4
ww_assx:
shr ax,1
jnc rr_ee
wwa_qqs:
cmp cl,11
jne ww_ees
push ax
mov al,[edi]
test al,al
jz wwsd_rr
mov [msj],al
wwsd_rr:
pop ax
jmp rr_ee
ww_ees:
mov byte [edi],cl
rr_ee:
inc edi
dec bl
jne ww_assx
sub edi,25
dec bh
jne ss_oun
pop eax
cmp [msj],0
ret



diznok:
mov edi,[mm]
add edi,4960
mov esi,[mmn]
add esi,42
xor ecx,ecx
mov edx,ecx
mov dl,20
ww_ttdf:
mov cl,13
qqa_btt:
lodsb
test al,al
jz wdd_ed
call ne_krv
wdd_ed:
add edi,40
loop qqa_btt
add edi,7320
add esi,8
dec dx
jne ww_ttdf
ret

ne_krv:
push edi
push esi
push ecx
push ebx
mov esi,[mmn1]
xor ecx,ecx
mov bl,10
wwsz_rr:
mov cl,10
rep movsd
add edi,744
dec bl
jne wwsz_rr
pop ebx
pop ecx
pop esi
pop edi
ret

noktr:
push ebp
mov esi,nokt
mov ebp,[esp+8]
mov edi,[esp+12]
mov dl,50
wss_ws:
xor ecx,ecx
mov ebx,ecx
lodsb
mov bl,al
mov cl,al
and cl,0xf
shr bl,4
shl ecx,2
shl ebx,2
mov eax,[ebp+ebx]
stosd
mov eax,[ebp+ecx]
stosd
dec dl
jne wss_ws
pop ebp
ret

sonrk:
push ebx
invoke GetTickCount
pop ebx
add eax,[yerm]
xor al,ah
and al,15
cmp al,10
jb zz_wawrs
and al,7
zz_wawrs:
mov [sonr],al
ret

proc WindowProc, hwnd,wmsg,wparam,lparam
	push	ebx esi edi
	cmp	[wmsg],WM_DESTROY
	je	wmdestroy
	cmp [wmsg],WM_KEYDOWN
	je wm_keydn
	cmp [wmsg],WM_CREATE
	je wm_craet
	cmp [wmsg],WM_TIMER
	je wm_timer
	cmp [wmsg],WM_PAINT
	je wm_pint
	cmp   [wmsg],WM_SIZE
	je wm_sizz
	cmp   [wmsg],WM_SIZING
	je wm_sizz

  defwndproc:
	invoke	DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
	jmp	finish

  wm_keydn:
  mov eax,[wparam]
  cmp al,0x0d
  jne qqq_etr
  cmp [basl],0
  ja dt_etf
  call zerola
  inc [basl]
  dt_etf:
  jmp defwndproc

  qqq_etr:
  cmp al,0x1b
  jne qqq_sss
  call zerola
  call verss
  jmp defwndproc
  qqq_sss:

  cmp [basl],0
  je xxz_qwa
  cmp al,0x20
  jne xxz_qwa
  mov cl,0
  call vertip
  mov al,[kctp]
  inc [kctp]
  mov cl,11
  call vertip
  je qq_ataz
  inc [yerm]
  mov cl,11
  call vertip
  je qq_ataz
  inc [yerm]
  mov cl,11
  call vertip
  je qq_ataz
  sub [yerm],3
  mov cl,11
  call vertip
  je qq_ataz
  dec [yerm]
  mov cl,11
  call vertip
  je qq_ataz
  add [yerm],2
  mov [kctp],al
  jmp wsa_tryr
  qq_ataz:
  mov [omsg],0
  mov [umsg],0
  wsa_tryr:
  mov cl,1
  call vertip
  xxz_qwa:
  jne defwndproc


  wm_timer:
  cmp [wparam],0xafac
  jne  defwndproc

   cmp [basl],0
   je  dggf_ytggv
   cmp [umsg],0
   je qq_aaz
   cmp [yerm],480
   jb erff_yer
   mov [vss],1
   mov [fnsh],1
   mov [basl],0

   erff_yer:
   mov [yerm],510
   xor ax,ax
   mov [kctp],al
   mov	[umsg],al
   mov	[omsg],al
   mov al,[sonr]
   mov [hgtp],al
   call kontrl
   call sonrk
   qq_aaz:

  inc [timb]
  cmp [timb],7
  jb QQ_ww
  mov cl,0
  mov [timb],cl
  call vertip
  sub word [yerm],21
  mov cl,11
  call vertip
  mov bl,[msj]
  cmp bl,0
  je QQ_ww
  cmp [omsg],0
  jne  qqa_www
  inc [umsg]
  qqa_www:
  mov [omsg],bl
  add word [yerm],21
  QQ_ww:
  mov cl,1
  call vertip
  mov cl,0
  call vertip
  mov eax,[yerm]
  push eax
  CA klvy,0x25
  jb sedd_k
  dec [yerm]
  sedd_k:
  CA klvy,0x27
  jb sedd_f
  inc [yerm]
  sedd_f:
  CA klvy,0x28
  jb sedd_fk
  sub [yerm],21
  sedd_fk:
  mov cl,11
  call vertip
  pop eax
  mov bl,[msj]
  cmp bl,0
  je aaz_eew
  mov [yerm],eax
  aaz_eew:
  sub [yerm],21
  mov cl,11
  call vertip
  jne wwq_ww
  mov [omsg],0
  mov [umsg],0
  wwq_ww:
  add [yerm],21
  mov cl,1
  call vertip
  call updt
  jmp defwndproc
  dggf_ytggv:
  inc [timb]

  cmp [timb],4
  jb QQ_wttw
  mov [timb],0
  cmp [vss],20
  ja jdy_yg
  inc [vss]
  call verss
  jdy_yg:


  QQ_wttw:
  call updt
  jmp defwndproc




  wm_craet:
  invoke SetTimer,[hwnd],0xafac,50,0
  jmp  defwndproc


  wm_sizz:
  invoke GetPixel,[hdc],0,0
  inc eax
  je defwndproc
  wm_pint:
  call clientR
  call eupdt
  jmp  defwndproc

  wmdestroy:
	invoke KillTimer,[hwnd],0xafac
	invoke	PostQuitMessage,0
	 xor	 eax,eax
  finish:
	pop	edi esi ebx
	return
endp

nnktdz:
mov edi,[mm]
xor eax,eax
mov al,[sonr]
shl ax,2
mov ebx,kyun
add ebx,eax
add edi,[ebx]
shl ax,1
mov esi,tipl
add esi,eax
lodsw

mov dh,4

ss_rr_sss:
mov dl,4
ss_rr_DD:
shr ax,1
jnc ss_e_rs
call  nnktver
ss_e_rs:
sub edi,32
dec dl
jne ss_rr_DD
add edi,6400
dec dh
jne ss_rr_sss
ret


nnktver:
pusha
mov esi,nnk2
mov ebp,rrnk

mov dh,8
rrr_dgdf:
mov dl,4
rr_fyft:
xor ecx,ecx
xor ebx,ebx
lodsb
mov bl,al
mov cl,al
and cl,0xf
shr bl,4
shl ecx,2
shl ebx,2
mov eax,[ebp+ebx]
stosd
mov eax,[ebp+ecx]
stosd
dec dl
jne rr_fyft
add edi,752
dec dh
jne rrr_dgdf
popa
ret

indir:
pusha
mov esi,edi
add esi,21
inc edi
inc esi
ssw_recfd:
mov cl,13
mov al,1
rep movsb
add edi,8
add esi,8
dec dl
jne ssw_recfd
call saytpl
popa
ret

kontrl:
mov edi,[mmn]
add edi,41
mov dl,20
sst_rtrf:
xor ecx,ecx
mov cl,13
wws_trref:
mov al,ch
cmp [edi+ecx],al
je qq_ersdd
loop wws_trref
call indir
sub edi,21
inc dl
qq_ersdd:
add edi,21
dec dl
jne sst_rtrf
ret


verss:
mov edi,[mmn]
add edi,42
mov esi,pres
mov dl,[vss]
mov dh,0
sfd_ytef:
mov cl,13
wes_tesdc:
test dh,dh
jnz  wwa_trf
lodsb
mov bl,al
mov dh,8
wwa_trf:
mov al,0
shl bl,1
jnc gym_dd
mov al,1
gym_dd:
stosb
dec dh
loop wes_tesdc
add edi,8
dec dl
jne  sfd_ytef
ret

zerola:
	xor eax,eax
	mov [fnsh],al
	mov [basl],al
	mov [vss],20
	mov [sonr],al
	mov [hgtp],al
	mov [kctp],al
	mov [umsg],al
	mov [omsg],al
	mov [timb],al
	mov [msj],al

	mov [kctbn],1
	mov edi,say
	xor eax,eax
	mov ecx,eax
	mov cl,6
	rep stosb
	mov edi,[mmn]
	mov cx,800
	mov al,44
	push edi
	rep stosb
	pop edi
	mov al,66
	mov cl,42
	push edi
	rep stosb
	pop edi
	add edi,42
	mov bl,25
	ri_kori:
	mov cl,13
	mov al,0
	rep stosb
	add edi,8
	dec bl
	jne ri_kori
	call sonrk
	mov [hgtp],al
	xor al,1
	mov [sonr],al
	mov [yerm],509
	mov [basl],0
	ret

section '.idata' import data readable writeable

  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL' ,\
	  gdi32,'GDI32.DLL'

  include 'include\apia\gdi32.inc'
  include 'include\apia\kernel32.inc'
  include 'include\apia\user32.inc'


fnsh db ?
basl db ?
vss db	?
sonr db ?
hgtp db ?
kctp db ?
umsg db ?
omsg db ?
timb db ?
msj db ?
mmd dd ?
mmn1 dd ?
rrnk dd 0xffffff,0xc5c0c0,0x858080,0xff8040,0x804000,0x9b4e00,0xb95c00,0xd26900


nokt db  0x01,0x11,0x11,0x11,0x10
     db  0x13,0x44,0x44,0x44,0x32
     db  0x14,0x35,0x55,0x53,0x42
     db  0x14,0x56,0x66,0x65,0x42
     db  0x14,0x56,0x77,0x65,0x42
     db  0x14,0x56,0x77,0x65,0x42
     db  0x14,0x56,0x66,0x65,0x42
     db  0x14,0x35,0x55,0x53,0x42
     db  0x13,0x44,0x44,0x44,0x32
     db  0x02,0x22,0x22,0x22,0x21

tipl  dw 0x0C60,0x04C8,0x0C60,0x04C8
      dw 0x4460,0x2e00,0xC440,0x0E80
      dw 0x4e40,0x4e40,0x4e40,0x4e40
      dw 0x4640,0x4E00,0x4C40,0x0E40
      dw 0x0020,0x0020,0x0020,0x0020
      dw 0x0220,0x0600,0x0220,0x0600
      dw 0x0660,0x0660,0x0660,0x0660
      dw 0x2222,0x0f00,0x2222,0x0f00
      dw 0x06C0,0x08C4,0x06C0,0x08C4
      dw 0x044C,0x08E0,0x0644,0x00E2

nnk2 db 0x22,0x22,0x22,0x22
     db 0x10,0x00,0x00,0x02
     db 0x10,0x00,0x00,0x02
     db 0x10,0x04,0x40,0x02
     db 0x10,0x04,0x40,0x02
     db 0x10,0x00,0x00,0x02
     db 0x10,0x00,0x00,0x02
     db 0x11,0x11,0x11,0x11

kyun dd 107580,105212,105228,105212,111472,107552,107568, 107552,107584,112300

pres db 0xfc,0xfd,0x05,0x58,0x2a,0x00,0x03,0xcf
     db 0xa0,0x10,0x80,0x40,0x1f,0x38,0x02,0xa4
     db 0x09,0x3e,0x01,0x02,0x40,0x2a,0x7D,0x32
     db 0xa0,0x15,0x24,0x02,0xa7,0xd3,0x28,0x00,0xB0


section '.rsrc' resource data readable


  directory RT_ICON,icons,\
	    RT_GROUP_ICON,group_icons

  resource icons,\
	   1,LANG_NEUTRAL,icon_data

  resource group_icons,\
	   2,LANG_NEUTRAL,main_icon


  icon main_icon,icon_data,'tetris.ico'







