;#########################################################################
;                            HxCIntro 2001 Intro
;                           by Del Nero Jean Francois 
;                               (c)  HxC 2001
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;				  13/12/2001
;#########################################################################
;#
;# 'Main'
;#
;#########################################################################
;#########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model

      option casemap :none  ; case sensitive
      OPTION SCOPED        
                     

      include HxCIntro.inc     ; local includes for this file

      include .\mods_rout\mod32.inc

      include .\mods_data\mod1.inc
      include .\mods_data\mod2.inc
      include .\mods_data\mod3.inc
      include .\mods_data\mod4.inc

      include .\graphx_data\font.inc
      include .\graphx_code\effet.inc
      include .\objs3d_data\obj3d.inc

; #########################################################################

.code

ALIGN 4

;*****************************************************************************************
;* Timer Proc 1Hz
;*****************************************************************************************

TimerProc PROC hWndc:DWORD  ,uMsg2:DWORD, idEvent:DWORD,dwtime:DWORD
pushad

	cmp idEvent,1
	jne suite12
	cmp ds:[benchstatus],0
	je benchmwr

	mov esi,offset benchtemp
	mov ax,ds:[compteurimage]
	call WDIGIT
	mov esi,offset benchtemp2
	mov ax,ds:[compteurpolygone]
	call WDIGIT
	invoke SetWindowText,hWndc,ADDR benchtitle

	mov ds:[benchtemp],20h
	mov ds:[benchtemp+1],20h
	mov ds:[benchtemp+2],20h
	mov ds:[benchtemp+3],20h
	mov ds:[benchtemp+4],20h
	mov ds:[benchtemp+5],20h

	mov ds:[benchtemp2],0h
	mov ds:[benchtemp2+1],0h
	mov ds:[benchtemp2+2],0h
	mov ds:[benchtemp2+3],0h
	mov ds:[benchtemp2+4],0h
	mov ds:[benchtemp2+5],0h
	mov ds:[benchtemp2+6],0h


benchmwr:
	call CalcSpeedFactor
	xor ax,ax
	mov ds:[compteurimage],ax
suite12:
	finTimerProc:
 popad
 ret
TimerProc ENDP

;*****************************************************************************************
; Thread Principal -> Deroulement intro
;*****************************************************************************************

ALIGN 4

TreadPrincip PROC hWnd2:DWORD
LOCAL hProc:HANDLE
	invoke GetDC,hWnd
	mov myDC,eax
	invoke GetCurrentProcess
	mov hProc,eax
	mov ds:[pointeurobjet],offset obj6
	call SetRotation

@@forever:

;traitement

bsoucle:
	call CalcBlur
	xor cx,cx ;
	mov esi,ds:[pointeurobjet] 
bouclesd:
	call AffichePolygone
	inc cx
	;mov ch,ds:[esi+18]
	cmp byte ptr ds:[esi+18],00h
	je finobject
	add esi,19
	jmp bouclesd
finobject:

	mov ds:[compteurpolygone],cx

	call copyVimage

	cmp ds:[ModeAuto],0
	jne suitezfin
	;jmp suitezfin
	cmp ds:[compteurx],0
	je suitey
	dec ds:[compteurx]
	jnz suitey
	mov ax,ds:[SpeedFactor]
	add ds:[Xangle],ax
	mov ax,ds:[compteurxv]
	mov ds:[compteurx],ax

suitey:
	cmp ds:[compteury],0
	je suitez
	dec ds:[compteury]
	jnz suitez
	mov ax,ds:[SpeedFactor]
	add ds:[Yangle],ax
	mov ax,ds:[compteuryv]
	mov ds:[compteury],ax
suitez:
	cmp ds:[compteurz],0
	je suitezfin
	dec ds:[compteurz]
	jnz suitezfin
	mov ax,ds:[SpeedFactor]
	add ds:[Zangle],ax
	mov ax,ds:[compteurzv]
	mov ds:[compteurz],ax
suitezfin:

	mov ax,ds:[Xtransa]
	add ds:[Xangle],ax
	mov ax,ds:[Ytransa]
	add ds:[Yangle],ax
	mov ax,ds:[Ztransa]
	add ds:[Zangle],ax

	mov ax,ds:[Xtransam]
	add ds:[Xangle],ax
	mov ax,ds:[Ytransam]
	add ds:[Yangle],ax
	mov ax,ds:[Ztransam]
	add ds:[Zangle],ax

	xor ax,ax
	mov ds:[Xtransam],ax
	mov ds:[Ytransam],ax
	mov ds:[Ztransam],ax

	mov ax,ds:[SpeedFactor]
	add ds:[compteurnb],ax

	xor ax,ax
	mov bx, ds:[compteurnb]
	and bx,10000000000000b
	jz nochange
	inc al
nochange:
	call SwitchObj

	xor ax,ax
	mov bx, ds:[compteurnb]
	and bx,100000000000b
	jz nochangen
	inc al
nochangen:

	cmp ds:[benchstatus],0
	jne benchmr
	cmp al,1
	jne zeroww
	cmp ds:[titlepointeur],offset hxctitle
	je finchanehj
	mov edi,offset hxctitle
	mov ds:[titlepointeur],edi
	invoke SetWindowText,hWnd,edi
	jmp finchanehj
zeroww:
	cmp ds:[titlepointeur],offset powerofasm
	je finchanehj
	mov edi,offset powerofasm
	mov ds:[titlepointeur],edi
	invoke SetWindowText,hWnd,edi
finchanehj:

benchmr:

	call ScrollText

	push hWnd
	call DIB_Draw          ;/copie dans fenetre

	inc ds:[compteurimage]

	call SetRotation
lklkdjelf:
	cmp ds:[ThreadStatus],0ffh
	jne @@forever


@@exit:
	invoke ReleaseDC,hWnd,myDC ;
	mov ds:[ThreadStatus],011h
	ret
TreadPrincip ENDP

;*****************************************************************************************
;* Point d'entrée du prog
;*****************************************************************************************
start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
      invoke ExitProcess,eax


;*****************************************************************************************
;* Initialisation Intro....
;*****************************************************************************************

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

	invoke LoadIcon,hInst,500    ; icon ID
	mov hIcon, eax

	mov wc.cbSize,         sizeof WNDCLASSEX
	mov wc.style,          CS_BYTEALIGNWINDOW;CS_HREDRAW or CS_VREDRAW \
                             ;CS_BYTEALIGNWINDOW
	mov wc.lpfnWndProc,    offset WndProc
	mov wc.cbClsExtra,     NULL
	mov wc.cbWndExtra,     NULL
	m2m wc.hInstance,      hInst
	mov wc.hbrBackground,  COLOR_BTNFACE+1
	mov wc.lpszMenuName,   NULL
	mov wc.lpszClassName,  offset szClassName
	m2m wc.hIcon,          hIcon
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,        eax
	m2m wc.hIconSm,        hIcon

	invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

     
	invoke GetSystemMetrics,SM_CXSIZEFRAME
	lea ebx,[SCREEN_WIDTH+eax+eax]
 
	invoke GetSystemMetrics,SM_CYSIZEFRAME
	lea edi,[SCREEN_HEIGHT+eax+eax]

	invoke GetSystemMetrics,SM_CYCAPTION
	add edi,eax

	invoke GetSystemMetrics,SM_CYBORDER
	add edi,eax
	sub edi,3 ; !FIXME
	sub ebx,2
    
  	mov Wty, eax
	invoke CreateWindowEx,WS_EX_LEFT,
                        ADDR szClassName,
                        ADDR szDisplayName,
                        NULL,;WS_OVERLAPPEDWINDOW,
                        16,16,ebx,edi,
                        NULL,NULL,
                        hInst,NULL
	mov   hWnd,eax

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,DmaBufSize*2 + 100  
	mov  hMemory3,eax
	invoke GlobalLock,eax

	mov  ds:[pBufferSound],eax

	mov  ds:[wavehdrpointer1],eax
	add eax,DmaBufSize 
	mov  ds:[wavehdrpointer2],eax

	mov edi,ds:[pBufferSound]
	mov ecx,DmaBufSize*2  
	shr ecx,2
	add ecx,4
	mov eax,00800080h

	rep stosd es:[edi]

	invoke waveOutGetNumDevs
	cmp eax,0
	je SuiteSansSon

	invoke waveOutOpen,offset SoundH,WAVE_MAPPER,Addr pWAVEFORMATEXftag,hWnd,0,CALLBACK_WINDOW  
	cmp eax,MMSYSERR_NOERROR 
	jne SuiteSansSon
	xor eax,eax
	mov ds:[dwflags1],EAX
	mov ds:[dwflags2],EAX

	invoke waveOutPrepareHeader,SoundH,addr wavehdrpointer1,sizeof WAVEHDR
	cmp eax,MMSYSERR_NOERROR 
	jne ExitLoop

	invoke waveOutPrepareHeader,SoundH,addr wavehdrpointer2,sizeof WAVEHDR
	cmp eax,MMSYSERR_NOERROR 
	jne ExitLoop

	xor eax,eax
	mov esi,offset moddump1
	mov ecx,DmaBufSize
	mov ebx,ds:[pBufferSound]

	xor edx,edx
	mov dl,4
	shl edx,16
	mov dh,2
	mov dl,16

	call INITMOD
	invoke waveOutReset,SoundH

	mov ds:[status],1
	jmp SuiteAvecSon

SuiteSansSon:
	mov ds:[StatusSon],0
SuiteAvecSon:
      
	call CalcPalette

 
	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,SCREEN_WIDTH*SCREEN_HEIGHT*2
	mov  hMemory4,eax
	invoke GlobalLock,eax
	mov ds:[pImageBuffer2],eax


	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,SCREEN_WIDTH*SCREEN_HEIGHT*2
	mov  hMemory5,eax
	invoke GlobalLock,eax
	mov ds:[pImageBuffer],eax

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,VSCREEN_WIDTH*VSCREEN_HEIGHT*2
	mov  hMemory6,eax
	invoke GlobalLock,eax
	mov ds:[pVImageBuffer],eax

	invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,SCREEN_WIDTH*SCREEN_HEIGHT*2
	mov  hMemory8,eax
	invoke GlobalLock,eax
	mov ds:[pBackUp],eax


	mov esi,eax
	mov edi,ds:[pImageBuffer]
	xor eax,eax
	mov ecx,SCREEN_WIDTH*SCREEN_HEIGHT*2
bouclefeerfefe:
	mov ds:[esi],eax
	mov ds:[edi],eax
	sub ecx,4
	jnz bouclefeerfefe

	invoke CreateThread,NULL,MAIN_THREAD_STACKSIZE_KB*1024,ADDR TreadPrincip,hWnd,NULL,ADDR MainThreadHandle
	mov ds:[MainThreadHandle],eax
	invoke SetThreadPriority,eax,THREAD_PRIORITY_BELOW_NORMAL

	invoke ShowWindow,hWnd,SW_SHOWNORMAL
	invoke UpdateWindow,hWnd

	invoke SetTimer,hWnd,1,1000,offset TimerProc


      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

StartLoop:
	xor ebx,ebx
        invoke GetMessage,ADDR msg,NULL,ebx,ebx
        cmp eax, ebx
        je ExitLoop
        invoke TranslateMessage, ADDR msg
        invoke DispatchMessage,  ADDR msg
        jmp StartLoop
ExitLoop:
	mov ds:[status],6

	invoke waveOutReset,SoundH

	invoke waveOutBreakLoop,SoundH
	invoke waveOutBreakLoop,SoundH
	invoke waveOutBreakLoop,SoundH
	invoke waveOutBreakLoop,SoundH

	invoke waveOutUnprepareHeader,SoundH,addr wavehdrpointer1,sizeof WAVEHDR
	invoke waveOutUnprepareHeader,SoundH,addr wavehdrpointer2,sizeof WAVEHDR

	call CLOSEMODSYS

	invoke waveOutClose,SoundH

    return msg.wParam

WinMain endp

;*****************************************************************************************
;* Traitement messages
;*****************************************************************************************

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_CREATE

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
        mov ds:[ThreadStatus],0ffh
        invoke PostQuitMessage,NULL
        return 0

    .elseif uMsg == WM_DESTROY
        mov ds:[ThreadStatus],0ffh
boucleattentekilltd:
        cmp ds:[ThreadStatus],011h
        jne boucleattentekilltd
        invoke PostQuitMessage,NULL
        return 0 

   .elseif uMsg == MM_WOM_OPEN

	invoke waveOutReset,SoundH

	invoke waveOutWrite,SoundH,addr wavehdrpointer1,sizeof WAVEHDR 
	invoke waveOutWrite,SoundH,addr wavehdrpointer2,sizeof WAVEHDR 

   .elseif uMsg == MM_WOM_CLOSE
	mov ds:[status],0 
	invoke TerminateThread,MainThreadHandle,0

   .elseif uMsg == MM_WOM_DONE
 	cmp lParam ,offset wavehdrpointer1
  	jne test2
   	
	mov     edi,ds:[wavehdrpointer1]
   	mov     ecx,DmaBufSize
   	call GiveMeSample
  	invoke waveOutWrite,SoundH,offset wavehdrpointer1,sizeof WAVEHDR 
  
test2:
  	cmp lParam ,offset wavehdrpointer2
  	jne suite23
	
	mov     edi,ds:[wavehdrpointer2]
  	mov     ecx,DmaBufSize
   	call GiveMeSample
   	invoke waveOutWrite,SoundH,addr wavehdrpointer2,sizeof WAVEHDR 
suite23:

    .elseif uMsg == WM_KEYDOWN

        .if wParam == VK_F1

         push esi
	 mov esi,offset moddump1
         call StartMod
	 pop esi

        .elseif wParam == VK_F2
         push esi
	 mov esi,offset moddump2
         call StartMod
	 pop esi
       
        .elseif wParam == VK_F3
         push esi
	 mov esi,offset moddump3
         call StartMod
	 pop esi

        .elseif wParam == VK_F4
         push esi
	 mov esi,offset moddump4
         call StartMod
	 pop esi

        .elseif wParam == VK_F5
         mov ds:[BlurMode],0

        .elseif wParam == VK_F6
         mov ds:[BlurMode],1

        .elseif wParam == VK_F7
         mov ds:[BlurMode],2

        .elseif wParam == VK_F8
         mov ds:[BlurMode],3

        .elseif wParam == VK_F11
         mov ds:[BlurMode],4

        .elseif wParam == VK_RIGHT
          mov ds:[Ytransa],1

        .elseif wParam == VK_LEFT
	  mov ds:[Ytransa],-1

        .elseif wParam == VK_UP
	  mov ds:[Xtransa],1	

        .elseif wParam == VK_DOWN
	  mov ds:[Xtransa],-1

        .elseif wParam == VK_PGDN
	  mov ds:[Ztransa],1

        .elseif wParam == VK_PGUP
	  mov ds:[Ztransa],-1
        
	.elseif wParam == VK_F12
         not ds:[ModeAuto]

        .elseif wParam == VK_F
         xor ds:[FiltrageM],1
	
	.elseif wParam == VK_L
         xor ds:[BlurONOFF],1

        .elseif wParam == VK_B
         xor ds:[benchstatus],1

        .elseif wParam == VK_F9
         inc ds:[MixageCroise]
         cmp ds:[MixageCroise],3
         jne suite489784643b
         mov ds:[MixageCroise],0
         suite489784643b:
	.endif

       .elseif uMsg == WM_MOUSEMOVE
	 mov eax,lParam
	 sub ax, ds:[XMouse]
	 mov bx,ax
	 shr eax,16
 	 sub ax, ds:[YMouse]
	 mov cx,ax
	  mov eax,lParam
	  mov ds:[XMouse],ax
 	  shr eax,16
          mov ds:[YMouse],ax
	.if wParam == MK_LBUTTON
	   
	   mov ds:[Xtransam],bx
	   mov ds:[Ytransam],cx

           mov ds:[ModeAuto],0ffh

        .elseif wParam == MK_RBUTTON
           mov ds:[ModeAuto],0h
        .endif
	
	.elseif uMsg == WM_RBUTTONDOWN 
	  mov ds:[ModeAuto],0h

        .elseif uMsg == WM_KEYUP
	
	.if wParam == VK_RIGHT
          mov ds:[Ytransa],0

        .elseif wParam == VK_LEFT
          mov ds:[Ytransa],0

        .elseif wParam == VK_UP
          mov ds:[Xtransa],0	

        .elseif wParam == VK_DOWN
          mov ds:[Xtransa],0

        .elseif wParam == VK_PGDN
            mov ds:[Ztransa],0

        .elseif wParam == VK_PGUP
           mov ds:[Ztransa],0

	.endif
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

;*****************************************************************************************
;* Initialisation du mod player
;*****************************************************************************************

StartMod Proc
	pushad
	cmp ds:[StatusSon],1
	jne finstartmod
       	xor eax,eax
	mov ecx,DmaBufSize
        mov ebx,ds:[pBufferSound]
        xor edx,edx
        mov dl,4
        shl edx,16
        mov dh,2
        mov dl,16
        call INITMOD     
finstartmod:
	popad
	ret
StartMod endP

ALIGN 4

;*****************************************************************************************
;* Copie Buffer->fenetre
;*****************************************************************************************

DIB_Draw PROC hWnd3:HWND
LOCAL myRect:RECT
 invoke GetClientRect,hWnd,ADDR myRect
 xor edx,edx
 invoke StretchDIBits,myDC,edx,edx,
                      myRect.right,
                      myRect.bottom,
                      edx,edx,
                      SCREEN_WIDTH,
                      SCREEN_HEIGHT,
                      DS:[pImageBuffer],
                      ADDR dibinf,
                      edx,        ;DIB_RGB_COLORS=0
                      SRCCOPY
 ret
DIB_Draw ENDP

ALIGN 4

;*****************************************************************************************
;* Calcul du facteur vitesse
;*****************************************************************************************

CalcSpeedFactor Proc
 pushad
	cmp ds:[speedfstatus],0
	jne finclaclf
	mov bx,ds:[compteurimage]
	cmp bx,0
	je finclaclf
	xor dx,dx
	mov ax,150
	div bx
	cmp ax,0
	jne oksuitesw
	mov ax,1
oksuitesw:
	mov ds:[SpeedFactor],ax
	mov ds:[speedfstatus],1
	finclaclf:
 popad
ret
CalcSpeedFactor EndP

;*****************************************************************************************
; Convert 16bit reg -> decimal
;*****************************************************************************************

WDIGIT Proc ;  /* AX =valeur  */
pushad
mov BX,07h
  CMP AX,10000
  JNB DOWN1                               
  CMP AX,1000
  JNB DOWN2                               
  CMP AX,100
  JNB DOWN3                               
  CMP AX,10
  JNB DOWN4
  JMP SHORT DOWN5
DOWN1:
  mov  DX,0
  mov  CX,10000
  DIV CX
  add  AL, '0'
  mov ds:[esi],al
  inc esi
  mov  AX,DX
DOWN2:
  mov  DX, 0;
  mov  CX,1000;
  DIV CX
  add AL,'0';
  mov ds:[esi],al
  inc esi
  mov  AX, DX;
DOWN3:
  mov  CL,100;
  DIV CL
  mov  DL,AH;
  add  AL,'0';
  mov ds:[esi],al
  inc esi
  mov  AL,DL;
  mov  AH,0;
DOWN4:
  mov  CL,10;
  DIV CL
  mov DL,AH;
  add  AL,'0';
  mov ds:[esi],al
  inc esi
  mov AL,DL;
DOWN5:
  add  AL,'0';
  mov ds:[esi],al
  inc esi
   xor al,al
 ; mov ds:[esi],al
  inc esi

popad
ret
WDIGIT endp

;*****************************************************************************************
;*****************************************************************************************

end start
