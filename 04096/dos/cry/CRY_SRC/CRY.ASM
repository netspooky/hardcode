;
;     ÜÛ   Û² ÛÛ   Û² ÛÛÛÛÛÜ  ÛÛÛÛÛÜ  ÛÛÛÛÛÛÛ ÛÛ      ÛÛ ÜÛÛÛÛÜ  ÜÛÛÛÛ² Û²
;     Û²   Û² ÛÛÜ  Û² ÜÜ  ßÛÛ ÜÜ  ßÛÛ Û²   Û² ÛÛ      Û²   ÜÛÛß ÛÛß     Û²
;     Û²ÛÛÛÛ²  ßÛÛÛÛ² Û²   Û² Û²   ÛÛ Û²   Û² ÛÛ ÛÛ²  Û² ÜÛÛß   ÛÛ ÛÛ²  Û²
;     Û²   Û²      Û² Û² ÛÛÛ² Û²   ÛÛ Û²   Û² ÛÛÜ     Û² ÛÛ     ÛÛÜ
;     Û²   Û²      Û² Û²      Û²   ÛÛ Û²ÛÛÛÛ²  ßÛÛÛÛ² Û² ßÛÛÛÛ²  ßÛÛÛÛ² Û²
;                  Û²
;   ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
;                       ÖÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ·
;        ---ÄÄÄÄÄÄÄÄÄÄÄÍµ      úPúRúEúSúEúNúTúSú      ÆÍÄÄÄÄÄÄÄÄÄÄÄ---
;                       ÓÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ½
;
;                             ßßßÛÜ  ßßßÛÜ  ß  ÛÜ
;                             Û      Û  ÛÛ  Û  ÛÛ
;                             Û  ÜÜ  ÛßÛÛ   ßßßÛÛ
;         4Kb Intro called    ÛÜÜÛÛ  Û  ÛÛ  ÛÜÜÛÛ    by Ozir / Hypnotize
;
;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù
;
;    Yes... Here it is ... Source to the 4Kb called 'CRY'
;                                             by Ozir / Hypnotize ...
;
;    You can of coz uses this code in your production but
;                                 remember that riping code is very Lame!
;
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Equ's                                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaxObjects         equ 6                         ;how many objects
MaxLevels          equ 25                        ;how many levels in object
MaxRots            equ 10                        ;how many points on circle
RotsAdd            equ 360/MaxRots               ;angle for circle add
MaxPoints          equ MaxLevels*MaxRots         ;how many points
MaxFaces           equ MaxRots*2*(MaxLevels-1)   ;how many faces
ObjectSize         equ MaxLevels*2               ;obj size in bytes
MaxVectorSteps     equ 30            ;(*)        ;how steps in object blend
EyeDist            equ 500                       ;distance to objects
CenterX            equ 160                       ;screen x center
CenterY            equ 100                       ;screen y center
AngleStepX         equ 6                         ;rotate about x axis
AngleStepZ         equ 8                         ;rotate about z axis
BlendTime          equ 60                        ;how max frames for blend
ScrollTime         equ 50                        ;how long scrool screen
EventTime          equ 230           ;(*)        ;time from envent to event
;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù
                   .386c
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Start of program                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                   assume cs:code, ds:code
code               segment use16 para
                   org 100h

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init Intro ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

start:             mov bx,sp                  ;set min of memory
                   add bx,15
                   shr bx,4
                   mov ax,ss
                   add bx,ax
                   mov ax,es
                   sub bx,ax
                   mov ah,4Ah
                   int 21h

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Make Full Sinus Table ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov si,offset cs:sinus
                   mov di,offset cs:trg
                   mov eax,010000h
                   mov cs:[di+360],eax
                   neg eax
                   mov cs:[di+1080],eax
                   mov bp,di
                   add bp,360              ;4*90
                   mov cx,90
MakeFullSinLoop:   mov al,cs:[si]
                   movzx eax,al
                   shl eax,8               ;conv to 16bit quality
                   mov cs:[di],eax         ;1/5
                   mov cs:[di+1440],eax    ;5/5 (360*4)
                   mov cs:[bp+360],eax     ;2/5 (90*4)
                   mov cs:[bp+1800],eax    ;6/5
                   neg eax
                   mov cs:[di+720],eax     ;3/5 (180*4)
                   mov cs:[bp+1080],eax    ;4/5 (270*4)
                   add di,4
                   inc si
                   sub bp,4
                   loop MakeFullSinLoop

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init Memory ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov bx,1024
                   mov cx,512
                   mov dx,4096

                   mov ax,cs
                   add ax,3072 ;48kb after now
                   mov cs:SegFaces,ax
                   add ax,bx ;(16kb)
                   mov cs:SegSort,ax
                   add ax,bx ;(16kb)
                   mov cs:Seg2d,ax
                   add ax,bx ;(16kb)
                   mov cs:SegPoints,ax      ;actual points (dw)
                   add ax,cx ;(8kb)
                   mov cs:SegNormals,ax     ;actual normals (dw)
                   add ax,cx ;(8kb)
                   mov cs:SegFacNor,ax      ;temp buffer for normals to fac's
                   add ax,cx ;(8kb)
                   mov cs:SegPointsDD,ax
                   add ax,bx ;(16kb)
                   mov cs:SegNormalsDD,ax
                   add ax,bx ;(16kb)
                   mov cs:SegPointsAddDD,ax
                   add ax,bx ;(16kb)
                   mov cs:SegNormalsAddDD,ax
                   add ax,bx ;(16kb)
                   mov cs:SegTexture,ax     ;texture segment
                   add ax,dx ;(64kb)
                   mov cs:SegScreen,ax      ;temp screen
                   add ax,dx ;(64kb)
                   mov cs:SegBack,ax        ;background
                   add ax,dx ;(64kb)

                   mov cs:SegStart,ax       ;start of points table

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Create all Objects ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,cs:SegStart
                   push ax

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Create Faces ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,cs:SegFaces
                   mov ds,ax
                   xor di,di
                   mov cx,MaxLevels
                   dec ecx
                   xor bp,bp               ;start fac

CreateFacY:        push ecx
                   mov cx,MaxRots
                   dec ecx
                   xor dx,dx               ;actual x

CreateFacX:        mov ax,bp
                   add ax,dx
                   push ax
                   mov ds:[di],ax          ;start+x
                   mov ds:[di+6+2],ax      ;start+x
                   add ax,MaxRots
                   mov ds:[di+2],ax        ;start+x+rots
                   inc ax
                   mov ds:[di+4],ax        ;start+x+rots+1
                   mov ds:[di+6+4],ax      ;start+x+rots+1
                   pop ax
                   inc ax
                   mov ds:[di+6],ax        ;start+x+1
                   add di,12

                   inc dx
                   loop CreateFacX

                   mov ax,bp
                   mov ds:[di+6],ax        ;start
                   add ax,MaxRots
                   mov ds:[di+4],ax        ;start+rots
                   mov ds:[di+6+4],ax      ;start+rots
                   dec ax
                   mov ds:[di],ax          ;start+rots-1
                   mov ds:[di+6+2],ax      ;start+rots-1
                   add ax,MaxRots
                   mov ds:[di+2],ax        ;start+rots-1+rots
                   add di,12

                   pop ecx
                   add bp,MaxRots
                   loop CreateFacY

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Create Normals and Vertexs ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov si,offset cs:FirstObject
                   mov cx,MaxObjects
LoopObject:        push si ecx

                   mov ax,cs:SegPoints
                   mov es,ax
                   xor di,di
                   call CreateVertexs
                   call CreateFNormals
                   call CreateNormals

                   mov ax,cs:SegStart
                   mov es,ax
                   mov ax,cs:SegPoints
                   mov ds,ax
                   xor si,si
                   xor di,di
                   mov cx,8192
                   rep movsb
                   mov ax,cs:SegStart
                   add ax,512
                   mov es,ax
                   mov ax,cs:SegNormals
                   mov ds,ax
                   xor si,si
                   xor di,di
                   mov cx,8192
                   rep movsb

                   add word ptr cs:SegStart,1024   ;(16kb)

                   pop ecx si
                   add si,50
                   loop LoopObject

                   pop ax
                   mov cs:SegStart,ax

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Init Vga Mode ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,0013h
                   int 10h

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Set 'Init' Palette ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   xor ax,ax
                   xor bx,bx
                   mov cx,02a00h
                   mov di,offset palette1
                   push di
                   mov ebp,128
                   push ebp
                   call CreatePalette

                   pop ebp
                   pop di
                   add di,128*3
                   xor ax,ax
                   mov bx,03f2ah
                   xor cx,cx
                   call CreatePalette

                   mov si,offset palette1
                   call setpalette

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Scroll Texture ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   push cs
                   pop ds
                   mov ax,0a000h
                   mov fs,ax

                   mov cx,101+ScrollTime
movetxt:           push ecx
                   call writetexture
                   pop ecx
                   loop movetxt

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Flash ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov si,offset cs:palette1
                   mov di,offset cs:WhitePal
                   call SetFade

                   call GoFade

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Remapping Texture ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,0a000h
                   mov ds,ax
                   mov es,ax
                   xor si,si
                   xor di,di
                   mov cx,64000
RemapTexture:      lodsb
                   shr al,2
                   stosb
                   loop RemapTexture

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Create BackGround ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   xor si,si
                   xor di,di
                   mov ax,cs:SegBack
                   mov es,ax
                   mov cx,64000
                   rep movsb

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Blend to New Palette ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   xor ax,ax
                   mov bx,03f00h
                   mov cx,028h
                   mov di,offset cs:palette1
                   mov ebp,64
                   push di
                   push ebp
                   call CreatePalette

                   mov ax,0283fh
                   mov bx,03f00h
                   mov cx,03f3fh
                   pop ebp
                   pop di
                   add di,64*3
                   call CreatePalette

                   xor ax,ax
                   mov bx,02d00h
                   xor cx,cx
                   mov di,offset cs:palette1
                   add di,128*3
                   mov ebp,100
                   call CreatePalette

                   mov ax,02dh
                   mov bx,03f00h
                   mov cx,03f3fh
                   mov di,offset cs:palette1
                   add di,(128+100)*3
                   mov ebp,20
                   call CreatePalette

                   mov ax,03f3fh
                   mov bx,ax
                   mov cx,ax
                   mov di,offset cs:palette1
                   add di,(128+100+20)*3
                   mov ebp,20
                   call CreatePalette

                   mov si,offset cs:WhitePal
                   mov di,offset cs:palette1
                   call SetFade

                   call GoFade

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Show Logo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   call ShowLogo

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Create Texture for Enviroment ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,0a000h
                   mov fs,ax
                   mov ax,cs:SegTexture
                   mov gs,ax

                   mov ebp,-100
                   xor di,di          ;point
                   mov cx,200

CR_LoopY:          push ecx di
                   mov eax,ebp
                   imul ebp
                   mov esi,eax        ;esi=y^2

                   mov cx,256         ;max x
                   mov ebx,-128

CR_LoopX:          push ebx ecx
                   mov eax,ebx
                   imul ebx
                   add eax,esi
                   mov ecx,eax
                   call sqrt
                   shr eax,9
                   push ax
                   mov dl,64
                   sub dl,al

                   mov al,fs:[di]     ;screen
                   add al,dl
                   add al,128
                   mov bx,cs:TempTexture
                   pop dx
                   add dx,offset cs:LightTable
                   push bx
                   mov bx,dx
                   add al,cs:[bx]
                   pop bx
                   mov gs:[bx],al     ;textura
                   inc word ptr cs:TempTexture

                   pop ecx ebx
                   inc di
                   inc ebx
                   loop CR_LoopX

                   pop di ecx
                   inc ebp
                   add di,320
                   loop CR_LoopY

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ SetUp ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov eax,EventTime
                   mov cs:TimeCheck,eax
                   call PrepareMorphing

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Flash ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov si,offset cs:palette1
                   mov di,offset cs:WhitePal
                   call SetFade

                   call GoFade

                   call CopyBack
                   call CopyData
                   call Normalize
                   call Perspective
                   call Sort
                   call DrawObject
                   call ShowScreen

                   mov si,offset cs:WhitePal
                   mov di,offset cs:palette1
                   call SetFade

                   call GoFade

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù
MainLoop:          mov eax,cs:Timer
                   inc eax
                   mov cs:Timer,eax

                   cmp eax,cs:TimeCheck
                   jne NothingNew

                   mov eax,cs:TimeCheck
                   add eax,EventTime
                   mov cs:TimeCheck,eax

                   mov eax,MaxVectorSteps
                   mov cs:FadeTimer,eax

NothingNew:        mov eax,cs:FadeTimer
                   cmp eax,0
                   je NoMorphing

                   dec eax
                   mov cs:FadeTimer,eax

                   call Morphing

                   mov eax,cs:FadeTimer
                   cmp eax,0
                   jne NoMorphing

                   call PrepareMorphing
                   mov eax,cs:ObjectCount
                   inc eax
                   mov cs:ObjectCount,eax

                   cmp eax,MaxObjects-1
                   je LastObject

NoMorphing:        call CopyBack

                   call CopyData
                   call Normalize

                   call Rotate
                   call Perspective
                   call Sort

                   call DrawObject

                   call ShowScreen

                   in al,60h
                   cmp al,1
                   je ThisIsEnd
                   jmp MainLoop

LastObject:        xor eax,eax

LastLoop:          push eax
                   call CopyBack
                   call CopyData
                   call Normalize
                   call Rotate
                   call Perspective
                   call Sort
                   call DrawObject
                   call ShowScreen
                   pop eax
                   inc eax
                   cmp eax,EventTime
                   jne LastLoop

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Flash ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

ThisIsEnd:         mov si,offset cs:palette1
                   mov di,offset cs:WhitePal
                   call SetFade

                   call GoFade

                   call CopyBack
                   call ShowScreen

                   mov si,offset cs:WhitePal
                   mov di,offset cs:palette1
                   call SetFade

                   call GoFade

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Show Logo ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   call ShowLogo

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Darkness Screen ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov si,offset cs:palette1
                   mov di,offset cs:BlackPal
                   call SetFade

                   call GoFade

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Done Vga Mode ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ax,0003h
                   int 10h

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Show Info ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov dx,offset cs:info
                   push cs
                   pop ds
                   mov ah,09
                   int 21h

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Exit ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

exit:              mov ax,4c01h
                   int 21h
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Draw Object on Screen Temp                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DrawObject:        mov ax,cs:SegFaces
                   mov gs,ax
                   mov ax,cs:seg2d
                   mov ds,ax

                   mov ax,cs:SegNormals
                   mov es,ax
                   mov cx,MaxFaces
                   mov ax,cs:SegSort
                   mov fs,ax
                   xor si,si

DrawLoop:          mov ax,fs:[si+2]
                   shl ax,1
                   mov di,ax
                   shl ax,1
                   add di,ax           ;di=face_no*6

                   mov bx,gs:[di]
                   shl bx,1
                   mov bp,bx
                   shl bx,1
                   add bp,bx
                   mov ax,ds:[bp]
                   movsx eax,ax
                   mov cs:env_x1,eax
                   mov ax,ds:[bp+2]
                   movsx eax,ax
                   mov cs:env_y1,eax
                   ;N1
                   mov ax,es:[bp]
                   movsx eax,ax
                   mov cs:env_n1x,eax
                   mov ax,es:[bp+2]
                   movsx eax,ax
                   mov cs:env_n1y,eax

                   mov bx,gs:[di+2]
                   shl bx,1
                   mov bp,bx
                   shl bx,1
                   add bp,bx
                   mov ax,ds:[bp]
                   movsx eax,ax
                   mov cs:env_x2,eax
                   mov ax,ds:[bp+2]
                   movsx eax,ax
                   mov cs:env_y2,eax
                   ;N2
                   mov ax,es:[bp]
                   movsx eax,ax
                   mov cs:env_n2x,eax
                   mov ax,es:[bp+2]
                   movsx eax,ax
                   mov cs:env_n2y,eax

                   mov bx,gs:[di+4]
                   shl bx,1
                   mov bp,bx
                   shl bx,1
                   add bp,bx
                   mov ax,ds:[bp]
                   movsx eax,ax
                   mov cs:env_x3,eax
                   mov ax,ds:[bp+2]
                   movsx eax,ax
                   mov cs:env_y3,eax
                   ;N3
                   mov ax,es:[bp]
                   movsx eax,ax
                   mov cs:env_n3x,eax
                   mov ax,es:[bp+2]
                   movsx eax,ax
                   mov cs:env_n3y,eax

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Visible Test ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov ebx,cs:env_y2
                   sub ebx,cs:env_y3
                   mov eax,cs:env_x1
                   imul ebx                  ;ax=x1*(y2-y3)
                   mov ebp,eax

                   mov ebx,cs:env_y3
                   sub ebx,cs:env_y1
                   mov eax,cs:env_x2
                   imul ebx                  ;ax=x2*(y3-y1)
                   add ebp,eax

                   mov ebx,cs:env_y1
                   sub ebx,cs:env_y2
                   mov eax,cs:env_x3
                   imul ebx                  ;ax=x3*(y1-y2)
                   add ebp,eax               ;cx=x1(y2-y3)+x2(y3-y1)+x3(y1-y2)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                   push si ecx ds fs gs es
                   mov ax,cs:SegScreen
                   mov es,ax
                   mov ax,cs:SegTexture
                   mov ds,ax
                   cmp ebp,0
                   jge NoVisible
                   call enviroment
NoVisible:         pop es gs fs ds ecx si

                   add si,4
                   dec ecx
                   cmp ecx,0
                   je DrawStop
                   jmp DrawLoop
DrawStop:          ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Show Temporary Screen                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ShowScreen:        call Raster
                   mov ax,cs:SegScreen
                   mov ds,ax
                   mov ax,0a000h
                   mov es,ax
                   xor si,si
                   xor di,di
                   mov ecx,16000
                   rep movsd

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Copy BackGround to Screen Temp                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CopyBack:          mov ax,cs:SegBack
                   mov ds,ax
                   mov ax,cs:SegScreen
                   mov es,ax
                   xor si,si
                   xor di,di
                   mov ecx,16000
                   rep movsd
                   ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Show Logo                                                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ShowLogo:          mov ax,cs:SegBack
                   mov es,ax
                   mov ax,0a000h
                   mov fs,ax

                   xor bx,bx
                   mov cx,40
PutLoop1:          push ecx bx
                   call PutLogo
                   call Raster
                   call Raster
                   call Raster
                   pop bx ecx
                   inc bx
                   loop PutLoop1

                   mov cx,200
PutLoopDelay:      push ecx
                   call Raster
                   pop ecx
                   loop PutLoopDelay

                   mov cx,40
PutLogo2:          push ecx bx
                   call PutLogo
                   call Raster
                   call Raster
                   call Raster
                   pop bx ecx
                   dec bx
                   loop PutLogo2
                   ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Put Logo on Screen                                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;es-source screen
;fs-dest screen
PutLogo:           mov si,offset cs:logo
                   mov bp,offset cs:logosize
                   mov cx,56
                   mov di,75*320

LineLoop:          push ecx di
                   mov al,cs:[bp]
                   movsx ecx,al
                   inc bp

ElementLoop:       push ecx di

                   xor eax,eax
                   mov al,cs:[si]
                   add di,ax
                   add di,40
                   inc si
                   mov al,cs:[si]
                   movsx ecx,al
                   inc si

PointLoop:         mov al,es:[di]
                   add al,bl
                   mov fs:[di],al
                   inc di
                   loop PointLoop

                   pop di ecx
                   loop ElementLoop

                   pop di ecx
                   add di,320
                   loop LineLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Prepare Morphing                                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PrepareMorphing:   mov ax,cs:SegStart
                   mov ds,ax
                   add ax,1024
                   mov es,ax
                   mov ax,cs:SegPointsDD
                   mov fs,ax
                   mov ax,cs:SegPointsAddDD
                   mov gs,ax
                   call CalcVectorFade

                   mov ax,cs:SegStart
                   add ax,512
                   mov ds,ax
                   add ax,1024
                   mov es,ax
                   mov ax,cs:SegNormalsDD
                   mov fs,ax
                   mov ax,cs:SegNormalsAddDD
                   mov gs,ax
                   call CalcVectorFade

                   mov ax,cs:SegStart
                   add ax,1024
                   mov cs:SegStart,ax
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Morphing (one step)                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Morphing:          mov ax,cs:SegPointsDD
                   mov ds,ax
                   mov ax,cs:SegPointsAddDD
                   mov es,ax
                   call VectorFade

                   mov ax,cs:SegNormalsDD
                   mov ds,ax
                   mov ax,cs:SegNormalsAddDD
                   mov es,ax
                   call VectorFade

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Copy Points & Normals from DD bufer to DW tables                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CopyData:          mov ax,cs:SegPointsDD
                   mov ds,ax
                   mov ax,cs:SegPoints
                   mov es,ax
                   call CopyDD2DW

                   mov ax,cs:SegNormalsDD
                   mov ds,ax
                   mov ax,cs:SegNormals
                   mov es,ax
                   call CopyDD2DW
                   ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Copy DD to DW                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ds-source with dd
;es-dest with dw
CopyDD2DW:         mov cx,MaxPoints
                   mov ebx,ecx
                   add ecx,ebx
                   add ecx,ebx

                   xor si,si
                   xor di,di

CopyDD2DWLoop:     mov eax,ds:[si]
                   shr eax,16
                   mov es:[di],ax

                   add si,4
                   add di,2
                   loop CopyDD2DWLoop
                   ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Vector Fade                                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ds-vectors (dd)
;es-vectors add (dd)
VectorFade:        xor si,si
                   mov cx,MaxPoints
                   mov ebx,ecx
                   add ecx,ebx
                   add ecx,ebx

VecFadeLoop:       mov eax,es:[si]
                   add ds:[si],eax
                   add si,4
                   loop VecFadeLoop
                   ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Calculate Vector Fade from Object to Object                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;in: ds-start points (dw)
;    es-end points (dw)
;
;out: fs-start points (dd)
;     gs-step points (dd) (ADD)

CalcVectorFade:    mov cx,MaxPoints
                   mov ebx,ecx
                   add ecx,ebx
                   add ecx,ebx                        ;maxpoints*3
                   mov ebp,MaxVectorSteps
                   xor si,si
                   xor di,di
CalcVecStep:       mov ax,ds:[si]
                   movsx eax,ax
                   shl eax,16
                   mov fs:[di],eax

                   mov ax,es:[si]
                   movsx eax,ax
                   mov bx,ds:[si]
                   movsx ebx,bx
                   sub eax,ebx
                   shl eax,16
                   cdq
                   idiv ebp
                   mov gs:[di],eax  ;plus

                   add si,2
                   add di,4
                   loop CalcVecStep
                   ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Normalize len of vector to const                                          ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ebp-len of new vector
Normalize:         mov ebp,99
                   mov ax,cs:SegNormals
                   mov ds,ax
                   mov cx,MaxPoints
                   xor si,si

NorLoop:           push ecx
                   mov ax,ds:[si]
                   cwde
                   imul eax
                   mov ecx,eax
                   mov ax,ds:[si+2]
                   cwde
                   imul eax
                   add ecx,eax
                   mov ax,ds:[si+4]
                   cwde
                   imul eax
                   add ecx,eax
                   call Sqrt
                   shr eax,8
                   mov ebx,eax

                   mov ax,ds:[si]       ;x
                   cwde
                   imul ebp
                   idiv ebx
                   mov ds:[si],ax

                   mov ax,ds:[si+2]     ;y
                   cwde
                   imul ebp
                   idiv ebx
                   mov ds:[si+2],ax

                   mov ax,ds:[si+4]     ;z
                   cwde
                   imul ebp
                   idiv ebx
                   mov ds:[si+4],ax

                   pop ecx
                   add si,6
                   loop NorLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create V Normals (to vertexs)                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CreateNormals:     mov ax,cs:SegFaces
                   mov ds,ax
                   mov ax,cs:SegFacNor
                   mov es,ax
                   mov ax,cs:SegNormals
                   mov fs,ax

                   xor bp,bp

;ds-seg to faces [si]
;es-seg to normals to faces
;fs-seg to normals to vertexs [bp]

                   mov cx,MaxPoints
                   xor edx,edx        ;actual point
VLoop:             push ecx

                   xor ax,ax
                   mov cs:NormalX,ax
                   mov cs:NormalY,ax
                   mov cs:NormalZ,ax

                   mov cx,MaxFaces
                   xor si,si          ;offset to faces

FLoop:             cmp dx,ds:[si]
                   je YesAdd
                   cmp dx,ds:[si+2]
                   je YesAdd
                   cmp dx,ds:[si+4]
                   je YesAdd
                   jmp NoAdd

YesAdd:            mov ax,es:[si]
                   add cs:NormalX,ax
                   mov ax,es:[si+2]
                   add cs:NormalY,ax
                   mov ax,es:[si+4]
                   add cs:NormalZ,ax

NoAdd:             add si,6
                   loop FLoop

                   mov ax,cs:NormalX
                   cwde
                   shr eax,2
                   mov fs:[bp],ax
                   mov ax,cs:NormalY
                   cwde
                   shr eax,2
                   mov fs:[bp+2],ax
                   mov ax,cs:NormalZ
                   cwde
                   shr eax,2
                   mov fs:[bp+4],ax
                   add bp,6

                   pop ecx
                   inc edx
                   dec ecx
                   cmp ecx,0
                   je CreateEnd
                   jmp VLoop
CreateEnd:         ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create F Normals (to faces)                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CreateFnormals:    mov ax,cs:SegFaces
                   mov ds,ax
                   mov ax,cs:SegPoints
                   mov es,ax
                   mov ax,cs:SegFacNor
                   mov fs,ax
                   mov cx,MaxFaces
                   xor di,di
                   xor si,si

;ds-seg to faces [si]
;es-seg to points
;fs-seg to buf normals to faces (di)

CreateFloop:       push ecx
                   push di

                   mov ax,ds:[si]  ;first ver
                   shl ax,1
                   mov bx,ax
                   shl ax,1
                   add bx,ax       ;bx=off to 1 ver

                   mov ax,ds:[si+2] ;second ver
                   shl ax,1
                   mov bp,ax
                   shl ax,1
                   add bp,ax        ;bp=off to 2 ver

                   mov ax,ds:[si+4]
                   shl ax,1
                   mov di,ax
                   shl ax,1
                   add di,ax        ;di=off to 3 ver

;bx ->1 | bp ->2 | di ->3
                   mov ax,es:[bp+2] ;y2
                   sub ax,es:[bx+2] ;y1
                   cwde
                   mov dx,es:[di+4] ;z3
                   sub dx,es:[bx+4] ;z1
                   movsx edx,dx
                   imul edx
                   push eax         ;eax=(y2-y1)*(z3-z1)
                   mov ax,es:[di+2] ;y3
                   sub ax,es:[bx+2] ;y1
                   cwde
                   mov dx,es:[bp+4] ;z2
                   sub dx,es:[bx+4] ;z1
                   movsx edx,dx
                   imul edx         ;eax=(y3-y1)*(z2-z1)
                   pop ecx
                   sub ecx,eax
                   push ecx         ;(*) (y2-y1)*(z3-z1)-(y3-y1)*(z2-z1) [x]

                   mov ax,es:[bp]   ;x2
                   sub ax,es:[bx]   ;x1
                   cwde
                   mov dx,es:[di+4] ;z3
                   sub dx,es:[bx+4] ;z1
                   movsx edx,dx
                   imul edx
                   push eax         ;eax=(x2-x1)*(z3-z1)
                   mov ax,es:[di]   ;x3
                   sub ax,es:[bx]   ;x1
                   cwde
                   mov dx,es:[bp+4] ;z2
                   sub dx,es:[bx+4] ;z1
                   movsx edx,dx
                   imul edx         ;eax=(x3-x1)*(z2-z1)
                   pop ecx
                   sub ecx,eax
                   push ecx         ;(*) (x2-x1)*(z3-z1)-(x3-x1)*(z2-z1) [y]

                   mov ax,es:[bp+2] ;y2
                   sub ax,es:[bx+2] ;y1
                   cwde
                   mov dx,es:[di]   ;x3
                   sub dx,es:[bx]   ;x1
                   movsx edx,dx
                   imul edx
                   push eax         ;eax=(y2-y1)*(x3-x1)
                   mov ax,es:[di+2] ;y3
                   sub ax,es:[bx+2] ;y1
                   cwde
                   mov dx,es:[bp]   ;x2
                   sub dx,es:[bx]   ;x1
                   movsx edx,dx
                   imul edx         ;eax=(y3-y1)*(x2-x1)
                   pop ecx
                   sub ecx,eax      ;(*) (y2-y1)*(x3-x1)-(y3-y1)*(x2-x1) [z]

                   ;eax-x
                   ;ebx-y
                   ;ecx-z

                   pop ebx
                   pop eax

                   pop di
                   mov fs:[di],ax
                   mov fs:[di+2],bx
                   mov fs:[di+4],cx

                   pop ecx
                   add di,6
                   add si,6
                   dec ecx
                   cmp ecx,0
                   je CreateFend
                   jmp CreateFloop
CreateFend:        ret
;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Sorting                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;sorting points in SegPoints
sort:              mov ax,cs:SegPoints
                   mov ds,ax
                   mov cx,MaxFaces
                   xor bx,bx
                   xor di,di
                   xor si,si
                   mov ax,cs:SegSort
                   mov fs,ax
                   mov ax,cs:SegFaces
                   mov es,ax

CalcSumLoop:       mov fs:[di+2],bx
                   push bx

                   mov ax,es:[si]   ;first vertex
                   shl ax,1
                   mov bx,ax
                   shl ax,1
                   add bx,ax
                   mov dx,ds:[bx+4]   ;z1

                   mov ax,es:[si+2]   ;second vertex
                   shl ax,1
                   mov bx,ax
                   shl ax,1
                   add bx,ax
                   add dx,ds:[bx+4]  ;z2

                   mov ax,es:[si+4]   ;third vertex
                   shl ax,1
                   mov bx,ax
                   shl ax,1
                   add bx,ax
                   add dx,ds:[bx+4]   ;z3

                   add dx,1500
                   mov fs:[di],dx

                   add di,4
                   add si,6
                   pop bx
                   inc bx
                   loop CalcSumLoop

;now it's really (fucking bubble) sorting ....

SortMore:          xor si,si
                   mov cx,MaxFaces
                   dec ecx
                   xor bp,bp

SortLoop:          mov ax,fs:[si]    ;sum1
                   cmp ax,fs:[si+4]  ;sum2
                   jbe SortNoSwap

                   mov eax,fs:[si]
                   mov ebx,fs:[si+4]
                   mov fs:[si],ebx
                   mov fs:[si+4],eax
                   mov bp,1

SortNoSwap:        add si,4
                   loop SortLoop

                   cmp bp,1
                   je SortMore
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Enviroment Mapping                                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;ds-segment with texture
;es-screen segment
Enviroment:        push ds es

                   mov eax,cs:env_y1
                   mov ebx,cs:env_y2
                   mov ecx,cs:env_y3

                   mov edx,eax
                   cmp edx,ebx
                   jl EnvMin1
                   mov edx,ebx
EnvMin1:           cmp edx,ecx
                   jl EnvMin2
                   mov edx,ecx
EnvMin2:           mov cs:Env_MinY,edx
                   mov edi,edx
                   mov ebp,edx

                   mov edx,eax
                   cmp edx,ebx
                   jg EnvMax1
                   mov edx,ebx
EnvMax1:           cmp edx,ecx
                   jg EnvMax2
                   mov edx,ecx
EnvMax2:           mov cs:Env_MaxY,edx

                   ;fill scan
                   push cs
                   pop es
                   shl edi,2
                   add di,offset cs:envScanStart
                   mov eax,16000
                   sub edx,ebp
                   mov ecx,edx
                   inc ecx
                   rep stosd

                   pop es ds

                   ;scan
                   mov si,offset cs:env_x1 ;(1)
                   mov di,offset cs:env_x2 ;(2)
                   call EnvScanLine
                   mov si,offset cs:env_x2 ;(2)
                   mov di,offset cs:env_x3 ;(3)
                   call EnvScanLine
                   mov si,offset cs:env_x3 ;(3)
                   mov di,offset cs:env_x1 ;(1)
                   call EnvScanLine

                   mov esi,cs:env_MinY
                   mov edx,esi
                   shl esi,2
                   add si,offset cs:envScanStart
                   mov ecx,cs:env_maxY
                   sub ecx,cs:env_minY
                   inc ecx
                   shl edx,6
                   mov edi,edx
                   shl edx,2
                   add edi,edx    ;di-off on scren

EnvMainLoop:       push esi edi ecx
                   call DrawLineEnv
                   pop ecx edi esi
                   add edi,320
                   add esi,4
                   loop EnvMainLoop

                   ret

DrawLineEnv:       mov eax,cs:[si]
                   mov ebx,cs:[si+800]
                   shr eax,16
                   shr ebx,16
                   mov cs:[si],eax
                   mov cs:[si+800],ebx

                   cmp eax,ebx
                   jb EnvLineOk

                   xchg eax,ebx
                   mov cs:[si],eax
                   mov cs:[si+800],ebx

                   mov edx,cs:[si+1600]
                   mov ebp,cs:[si+3200]
                   mov cs:[si+1600],ebp
                   mov cs:[si+3200],edx
                   mov edx,cs:[si+2400]
                   mov ebp,cs:[si+4000]
                   mov cs:[si+2400],ebp
                   mov cs:[si+4000],edx

EnvLineOK:         ;eax-x1
                   ;ebx-x2

                   add edi,eax
                   sub ebx,eax
                   cmp ebx,0
                   jne EnvLineAre
                   ret

EnvLineAre:        push edi

                   mov eax,cs:[si+3200]
                   sub eax,cs:[si+1600]
                   cdq
                   idiv ebx
                   mov cs:EnvNXinc,eax    ;store NXinc

                   mov eax,cs:[si+4000]
                   sub eax,cs:[si+2400]
                   cdq
                   idiv ebx
                   mov cs:EnvNYinc,eax    ;store NYinc

                   mov ecx,ebx            ;how pixels

                   mov ebx,cs:[si+1600]
                   mov edx,cs:[si+2400]

                   mov eax,128            ;x center
                   shl eax,16
                   add ebx,eax

                   mov eax,100            ;y center
                   shl eax,16
                   add edx,eax

                   mov ebp,cs:EnvNXinc
                   mov esi,cs:EnvNYinc

                   pop edi

EnvLineLoop:       add ebx,ebp
                   add edx,esi

                   push ebx edx

                   shr ebx,16
                   shr edx,16

                   mov bh,dl

                   mov al,ds:[bx]
                   mov es:[di],al
                   inc di

                   pop edx ebx
                   loop EnvLineLoop
                   ret

EnvScanLine:       mov ebx,cs:[di+4]   ;y2
                   cmp ebx,cs:[si+4]   ;y1
                   jge EdgeOk

                   xchg si,di

EdgeOk:            mov ebx,cs:[di+4]
                   sub ebx,cs:[si+4]   ;ebx=ylen

                   jnz EdgeAre
                   ret

EdgeAre:           mov eax,cs:[di]     ;x2
                   sub eax,cs:[si]     ;x1
                   shl eax,16
                   cdq
                   idiv ebx
                   mov cs:EnvXinc,eax  ;xinc

                   mov eax,cs:[di+8]   ;n2x
                   sub eax,cs:[si+8]   ;n1x
                   shl eax,16
                   cdq
                   idiv ebx
                   mov cs:EnvNXinc,eax

                   mov eax,cs:[di+12]  ;n2y
                   sub eax,cs:[si+12]  ;n1y
                   shl eax,16
                   cdq
                   idiv ebx
                   mov cs:EnvNYinc,eax

                   mov ecx,ebx         ;ecx-max points
                   mov bx,si

                   mov ebp,cs:[bx]     ;x1
                   shl ebp,16
                   mov esi,cs:[bx+8]   ;n1x
                   shl esi,16
                   mov edx,cs:[bx+12]  ;n1y
                   shl edx,16

                   mov edi,cs:[bx+4]
                   shl edi,2
                   add di,offset cs:envScanStart

EdgeLoop:          add ebp,cs:EnvXinc
                   add esi,cs:EnvNXinc
                   add edx,cs:EnvNYinc

                   mov eax,cs:[di]
                   cmp eax,16000
                   jne EdgeRight

EdgeLeft:          mov cs:[di],ebp
                   mov cs:[di+1600],esi
                   mov cs:[di+2400],edx
                   jmp EdgeEnd

EdgeRight:         mov cs:[di+800],ebp
                   mov cs:[di+3200],esi
                   mov cs:[di+4000],edx

EdgeEnd:           add di,4
                   loop EdgeLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Fade                                                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GoFade:            mov ecx,BlendTime
GoFadeLoop:        push ecx
                   call Fade
                   pop ecx
                   loop GoFadeLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Fade Palette (STEP)                                                       ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
fade:              mov cx,256
                   mov si,offset FadeBuffer
                   mov di,offset FadePalette
                   push di
                   push si
StoreFade:         mov eax,cs:[si]
                   mov ebx,cs:[si+4]
                   mov edx,cs:[si+8]
                   shr eax,16
                   shr ebx,16
                   shr edx,16
                   mov cs:[di],al
                   inc di
                   mov cs:[di],bl
                   inc di
                   mov cs:[di],dl
                   inc di
                   add si,24
                   loop StoreFade

                   mov cx,256
                   pop si
FadeAdd:           mov eax,cs:[si+12] ;red add
                   mov ebx,cs:[si+16] ;green add
                   mov edx,cs:[si+20] ;blue add
                   add cs:[si],eax
                   add cs:[si+4],ebx
                   add cs:[si+8],edx

                   add si,24
                   loop FadeAdd

                   pop si
                   call SetPalette
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Fade Palette (SETUP)                                                      ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;cs:si-offset to source palette
;cs:di-offset to destation palette
;ebp-how max blend's

SetFade:           mov ebp,BlendTime
                   mov cs:MaxFade,ebp
                   mov ax,cs
                   mov ds,ax
                   mov es,ax
                   mov ax,offset FadeBuffer
                   mov cs:FadeOffset,ax

                   mov cx,256

FadeLoop:          push ecx

                   mov al,cs:[si]
                   inc si
                   mov ah,cs:[si]
                   inc si
                   mov bl,cs:[si]
                   inc si
                   mov bh,cs:[di]
                   inc di
                   mov cl,cs:[di]
                   inc di
                   mov ch,cs:[di]
                   inc di

                   push si di

                   mov ebp,cs:MaxFade
                   call CalcColor

                   mov si,offset cs:RedStart
                   mov di,cs:FadeOffset
                   mov cx,24 ;4*6
                   cld
                   rep movsb
                   add cs:FadeOffset,24

                   pop di si

                   pop ecx
                   loop FadeLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create Palette                                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;al,ah,bl- first color (r,g,b)
;bh,cl,ch- last color (r,g,b)
;ebp-length
;cs:di- adress of palette
CreatePalette:     push ebp
                   push di

                   call CalcColor

                   mov eax,cs:RedStart
                   mov ebx,cs:GreenStart
                   mov edx,cs:BlueStart

                   pop di
                   pop ecx
CreatePalLoop:     push eax ebx edx
                   shr eax,16
                   shr ebx,16
                   shr edx,16
                   mov cs:[di],al
                   inc di
                   mov cs:[di],bl
                   inc di
                   mov cs:[di],dl
                   inc di
                   pop edx ebx eax
                   add eax,cs:RedAdd
                   add ebx,cs:GreenAdd
                   add edx,cs:BlueAdd
                   loop CreatePalLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Calculate Start and Step Color                                            ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;al,ah,bl- first color (r,g,b)
;bh,cl,ch- last color (r,g,b)
;ebp-length

;out: (cs) RedStart,RedAdd
;          BlueStart,BlueAdd
;          GreenStart,GreenAdd

CalcColor:         mov di,bx
                   mov si,ax
                   movzx eax,al
                   shl eax,16
                   mov cs:RedStart,eax
                   movzx ebx,bh
                   shl ebx,16
                   sub ebx,eax
                   mov eax,ebx
                   cdq
                   idiv ebp
                   mov cs:RedAdd,eax

                   mov ax,si
                   movzx eax,ah
                   shl eax,16
                   mov cs:GreenStart,eax
                   movzx ebx,cl
                   shl ebx,16
                   sub ebx,eax
                   mov eax,ebx
                   cdq
                   idiv ebp
                   mov cs:GreenAdd,eax

                   mov bx,di
                   movzx eax,bl
                   shl eax,16
                   mov cs:BlueStart,eax
                   movzx ebx,ch
                   shl ebx,16
                   sub ebx,eax
                   mov eax,ebx
                   cdq
                   idiv ebp
                   mov cs:BlueAdd,eax
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create and Scroll Texture                                                 ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
writetexture:      push ds

                   push fs
                   push fs
                   pop es
                   pop ds
                   call raster

                   sub di,di
                   mov si,280h                ;second line
                   mov ecx,7e40h
                   shr ecx,1
                   rep movsd                  ;up screen

                   pop ds
                   mov di,0fc80h
                   mov si,280h

mutation:          push cs
                   pop ds
                   mov ax,TextureStart
                   mov cx,TextureRotate
                   add ax,cx
                   rol ax,cl
                   add cx,5678h
                   ror cx,1
                   mov TextureStart,ax
                   mov TextureRotate,cx
                   add ax,TextureRotate
                   dec word ptr ds:TextureRotate

                   sar ax,0ch
                   inc ax
                   sub dx,dx
                   sub bx,bx
                   mov dl,es:[0fec0h][di]
                   mov bl,es:[0fec1h][di]
                   add bx,dx
                   sar bx,1
                   add ax,bx
                   stosb
                   dec si
                   jnz mutation
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Rotate                                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;rotate a points in SegPoints
Rotate:            mov bx,cs:AngleX
                   add bx,AngleStepX
                   cmp bx,360
                   jb NoOverX
                   sub bx,360
NoOverX:           mov cs:AngleX,bx

                   mov bx,cs:AngleZ
                   add bx,AngleStepZ
                   cmp bx,360
                   jb NoOverZ
                   sub bx,360
NoOverZ:           mov cs:AngleZ,bx

                   mov ax,cs:SegPoints
                   mov ds,ax
                   xor bp,bp
                   mov cx,MaxPoints
RotateLoop1:       push ecx
                   call RotateElement
                   pop ecx
                   add bp,6
                   loop RotateLoop1

                   ;now rotate normals
                   mov ax,cs:AngleX
                   push ax
                   mov bx,360
                   sub bx,ax
                   mov cs:AngleX,bx

                   mov ax,cs:AngleZ
                   push ax
                   mov bx,360
                   sub bx,ax
                   mov cs:AngleZ,bx

                   mov ax,cs:SegNormals
                   mov ds,ax
                   xor bp,bp
                   mov cx,MaxPoints
RotateLoop2:       push ecx
                   call RotateElement
                   pop ecx
                   add bp,6
                   loop RotateLoop2

                   pop ax
                   mov cs:AngleX,ax
                   pop ax
                   mov cs:AngleZ,ax

                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Rotate                                                                    ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;Rotate a point in ds:[bp] about x and z axis

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Rotate About X Axis ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

RotateElement:     mov bx,cs:AngleX
                   call getsin           ;esi=sin(@x)
                   mov esi,eax
                   call getcos           ;edi=cos(@x)
                   mov edi,eax

                   mov ax,ds:[bp+2]
                   cwde                  ;eax=y
                   push eax
                   imul edi
                   mov ecx,eax           ;ecx=y*cos(@x)
                   pop eax
                   imul esi
                   mov ebx,eax           ;ebx=y*sin(@x)
                   mov ax,ds:[bp+4]
                   cwde                  ;eax=z
                   push eax
                   imul esi              ;eax=z*sin(@x)
                   sub ecx,eax           ;ecx=y*cos(@x)-z*sin(@x)
                   pop eax
                   imul edi              ;eax=z*cos(@x)
                   add ebx,eax           ;ebx=y*sin(@x)+z*cos(@x)
                   shr ebx,16
                   shr ecx,16
                   mov ds:[bp+4],bx      ;save z
                   mov ds:[bp+2],cx      ;save y

;ùÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Rotate About Z Axis ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄù

                   mov bx,cs:AngleZ
                   call getsin           ;esi=sin(@z)
                   mov esi,eax
                   call getcos           ;edi=cos(@z)
                   mov edi,eax

                   mov ax,ds:[bp]        ;eax=x
                   cwde
                   push eax
                   imul edi
                   mov ecx,eax           ;ecx=x*cos(@z)
                   pop eax
                   imul esi
                   mov ebx,eax           ;ebx=x*sin(@z)
                   mov ax,ds:[bp+2]      ;eax=y
                   cwde
                   push eax
                   imul esi              ;edx=y*sin(@z)
                   sub ecx,eax           ;ecx=x*cos(@z)-y*sin(@z)
                   pop eax
                   imul edi              ;edx=y*cos(@z)
                   add ebx,eax           ;ebx=x*sin(@z)+y*cos(@z)
                   shr ebx,16
                   shr ecx,16
                   mov ds:[bp+2],bx
                   mov ds:[bp],cx
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Perspective                                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;perspective 3d point in SegPoints to 2d points in Seg2d
Perspective:       mov ax,cs:SegPoints
                   mov ds,ax
                   mov ax,cs:Seg2d
                   mov es,ax
                   xor si,si
                   xor di,di
                   mov cx,MaxPoints

PerspLoop:         mov eax,EyeDist
                   mov ebx,eax

                   mov dx,ds:[si+4]
                   movsx edx,dx
                   add ebx,edx
                   xchg eax,ebx
                   shl eax,16
                   cdq
                   idiv ebx
                   mov ebp,eax          ;ebp=d/(z+d)

                   mov ax,ds:[si]
                   cwde
                   imul ebp
                   shr eax,16
                   add ax,CenterX
                   mov es:[di],ax       ;x

                   mov ax,ds:[si+2]
                   cwde
                   imul ebp
                   shr eax,16
                   add ax,CenterY
                   mov es:[di+2],ax     ;y

                   add si,6
                   add di,6
                   loop PerspLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Create Vertex's                                                           ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;cs:si-offset to rotobj data (db r,y)
;es:di-offset to vertex's table (dw x,y,z)

CreateVertexs:     mov cx,MaxLevels   ;e (@)
                   inc cx             ;e

CreateVerYLoop:    push cx
                   mov dl,cs:[si]
                   movsx edx,dl
                   mov ebp,edx   ;ebp=R

                   mov cx,MaxRots
                   xor bx,bx
CreateVerRLoop:    mov al,cs:[si+1]
                   cbw
                   mov es:[di+2],ax
                   call getsin
                   imul ebp
                   shr eax,16
                   mov es:[di],ax     ;x
                   call getcos
                   imul ebp
                   shr eax,16
                   mov es:[di+4],ax   ;z
                   add bx,RotsAdd
                   add di,6
                   loop CreateVerRLoop

                   add si,2
                   pop cx
                   loop CreateVerYLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Wait for Sync                                                             ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
raster:            mov  dx,3dah
waitnotvsyncloop:  in   al,dx
                   and  al,8
                   jnz  WaitNotVSyncLoop
waitvsyncloop:     in   al,dx
                   and  al,8
                   jz   WaitVSyncLoop
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Set Palette                                                               ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;cs:si-first color
setpalette:        mov cx,256
                   xor ax,ax
                   mov dx,3c8h
                   out dx,al

                   call raster

                   mov dx,3c9h
storecolors:       mov al,cs:[si]   ;red
                   out dx,al
                   mov al,cs:[si+1] ;green
                   out dx,al
                   mov al,cs:[si+2] ;blue
                   out dx,al
                   add si,3
                   loop storecolors
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Sinus and Cosinus                                                         ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
getsin:            push bx
                   shl bx,2
                   add bx,offset cs:trg
                   mov eax,cs:[bx]
                   pop bx
                   ret

getcos:            push bx
                   add bx,90
                   shl bx,2
                   add bx,offset trg
                   mov eax,cs:[bx]
                   pop bx
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Sqrt (by F.Becker)                                                        ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
;     in: ecx
;    out: eax (low 8bit - precision)
; modify: ebx,ecx,edx

sqrt:              xor eax,eax
                   mov ebx,40000000h
sqrtLP1:           mov edx,ecx         ;edx = val
                   sub edx,ebx         ;val - bitsqr
                   jl sqrtLP2
                   sub edx,eax         ;val - root
                   jl sqrtLP2
                   mov ecx,edx         ;val >= (root+bitsqr) -> accept subs
                   shr eax,1           ;root >> 1
                   or eax,ebx          ;root | bitsqr
                   shr ebx,2           ;bitsqr>>2
                   jnz sqrtLP1
                   shl eax,8
                   ret

sqrtLP2:           shr eax,1           ;val < (root+bitsqr) -> dont change val
                   shr ebx,2           ;bitsqr>>2
                   jnz sqrtLP1
                   shl eax,8
                   ret

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ 3d Objects                                                                ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

FirstObject:      include bowl.3d
                  include drop.3d
                  include torus.3d
                  include hantle.3d
                  include glass.3d
                  include bottle.3d

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ Datas in Code Segment                                                     ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
symbol:            db 'OZIR/HPZ'

info:              db 'This 4Kb Intro called CRY coded OZIR / HYPNOTIZE$',0

sinus:             include sinus.db               ;compress sinus data

logo:              include logo.db                ;logo data
logosize:          include logosize.db            ;logo lines count

LightTable:        db 5,5,5,5,5,4,4,3,1           ;additional light
                   db 200 dup (0)

trg:               dd 540+2 dup (0)               ;unpacked sin and cos
SegPoints          dw 0                           ;seg to actual points
SegTexture         dw 0                           ;seg to texture
SegFaces           dw 0                           ;seg to faces
SegSort            dw 0                           ;seg to sort buffer
Seg2d              dw 0                           ;seg to points 2d (x,y)
SegFacNor          dw 0                           ;seg to normals to faces
SegNormals         dw 0                           ;seg to normals to vertexs
SegScreen          dw 0                           ;seg to temp screen
SegBack            dw 0                           ;seg with background
SegPointsDD        dw 0                           ;seg to points DD (morf)
SegNormalsDD       dw 0                           ;seg to points add DD (m)
SegPointsAddDD     dw 0                           ;seg to normals DD (morf)
SegNormalsAddDD    dw 0                           ;seg to normals add DD (m)
SegStart           dw 0                           ;seg objects start
AngleX             dw 0                           ;actual x angle
AngleZ             dw 0                           ;actual z angle
TempTexture        dw 0                           ;temporary texture

Timer              dd 0                           ;timer
FadeTimer          dd 0                           ;timer for blend
TimeCheck          dd 0                           ;time point
ObjectCount        dd 0                           ;objects count

TextureStart       dw 0                           ;texture first
TextureIntensiv    dw 0                           ;texture add
TextureRotate      dw 0                           ;texture ror

RedStart           dd 0                           ;red color start
GreenStart         dd 0                           ;green color start
BlueStart          dd 0                           ;blue color start
RedAdd             dd 0                           ;red color add
GreenAdd           dd 0                           ;green color add
BlueAdd            dd 0                           ;blue color add

NormalX            dw 0                           ;normal x vector
NormalY            dw 0                           ;normal y vector
NormalZ            dw 0                           ;normal z vector

FadeOffset         dw 0                           ;fade offset
MaxFade            dd 0                           ;how many fades
FadeBuffer         dd 6*256+2 dup (0)             ;fade buf
FadePalette        db 256 dup (0,0,0)             ;fade act palette

env_x1             dd 0                           ;env x1
env_y1             dd 0                           ;env y1
env_N1x            dd 0                           ;env N1X
env_N1y            dd 0                           ;env N1Y
env_x2             dd 0                           ;env x2
env_y2             dd 0                           ;env y2
env_N2x            dd 0                           ;env N2X
env_N2y            dd 0                           ;env N2Y
env_x3             dd 0                           ;env x3
env_y3             dd 0                           ;env y3
env_N3x            dd 0                           ;env N3X
env_N3y            dd 0                           ;env N3Y

env_MinY           dd 0                           ;env min y
env_MaxY           dd 0                           ;env max y

envXinc            dd 0                           ;env_x add
envNXinc           dd 0                           ;env_NX add
envNYinc           dd 0                           ;env_NY add

envScanStart       dd 200 dup (0)                 ;start x line draw
envScanStop        dd 200 dup (0)                 ;stop x line draw
envScanLeftX       dd 200 dup (0)                 ;LNx
envScanLeftY       dd 200 dup (0)                 ;LNy
envScanRightX      dd 200 dup (0)                 ;PNx
envScanRightY      dd 200 dup (0)                 ;PNy

BlackPal           db 768 dup (0)                 ;black palette
palette1           db 768 dup (0)                 ;user palette
WhitePal           db 768 dup (60)                ;white palette

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ The End                                                                   ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
code               ends
end                start
