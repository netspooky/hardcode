; Amaze                         : 128-byte intro with castle wolfenstein raycasting (fasm 1.70.03/WinXP 5.1.2600)
; credit                        : olivier.poudade.free.fr 2013 aka baudsurfer
; credit                        : inspired by Justin Frankel^Nullsoft's 256-byte intro gaycast (www.1014.org/code)
; greets                        : Adok, Frag, lordKelvin, Pirx, Rudi, sensenstahl, y0bi
; shouts                        : dark bit factory forum users (www.dbfinteractive.com) 
BONUSFLOOR=1                   ; set this flag to 1 to draw floor (adds extra 10 bytes)
         org 100h               ; start binary at psp+256
	 fldz                   ; fpu in : undefined / fpu out : (st0=0)
         fldz                   ; fpu in : (st0=0) / fpu out : (st0=0.0) (st1=0.0)
         lds ax,[bx]            ; ds=ff9fh=a000h-16 ax=20cdh bx=assumed 0
frame:   fiadd word [cs:7]      ; advance value from previous frave / psp+7h=1dfeh
	 fld st0                ; fpu in : (st0=0.0) (st1=0.0) / fpu out : (st0=st1) (st1=0.0) (st2=0.0)
	 fld1                   ; fpu in : (st0=st1) (st1=0.0) (st2=0.0) / fpu out : (st0=1.0) (st1=st2) (st2=0.0) (st3=0.0)
	 mov bp,320             ; set bp to SCREEN_W
	 faddp st3,st0          ; fpu in : (st0=1.0) (st1=st2) (st2=0.0) (st3=0.0) / fpu out : (st0=st1) (st1=0.0) (st2=0.0) / popped st0+st3 
	 mov ax,13h             ; vga chaine mode 320x256x8 / best effort to plug it closest to plotting
	 int 10h                ; vga video bios api also used as clear screen function / best effort to plug it closest to plotting
xloop:   mov byte [si+3],3bh    ; was mov word [si+2],3b44h / 3b44h=15172b from /was fadd dword [cs:ADJ_VA] with ADJ_VA dd 994352038
	 fadd dword [si]        ; st0=viewing angle adjust	
         fld st0                ; fpu in : (st0=st1) (st1=0.0) (st2=0.0) / fpu out : (st0=st1) (st1=st2) (st2=0.0) (st3=0.0)  
         fsincos                ; fpu in : (st0=st1) (st1=st2) (st2=0.0) (st3=0.0) / fpu out : (cos(st0=st1)) (sin(st0=st1)) (st2=st3) (st3=0.0) (st4=0.0)
         mov cx,07e0h           ; 07e0h=2016b=32*63 size of maze
         mov dx,cx              ; dx=saved 32*63 cst for later use 
         fld st4                ; st4=st0
         fld st5                ; st5=st0
raycast: fadd st0,st3           ; fpu in : st0 st1 st2 st3 st0 st0 / fpu out: st0+st3 st1 st2 st3 st4 st5
         fist dword [si]        ; [si] = st0+st3 / si isa previous lower column ender-don't care
         fxch                   ; in : st0+st3 st1 st2 st3 st4 st5 out: st1 st0+st3 st2 st3 st4 st5
         fadd st0,st2           ; in : st1 st0+st3 st2 st3 st4 st5 out: st1+st2 st0+st3 st2 st3 st4
         mov bx,[si]            ; mov bh,[si+1]
         fist dword [si]        ; si=st1+st2
         fxch                   ; in : st1+st2 st0+st3 st2 st3 st4  out: st0+st3 st1+st2 st2 st3 st4
         mov bl,[si+1]          ; lsbyte of maze position
         test byte [gs:bx],4    ; test if map wall flag present as arbitrary bitflag in 1kb bios ivt space
         jnz rayhit             ; if so bail out casting loop
         loop raycast           ; else continue raycast           
rayhit:  sub dx,cx              ; dx now holds column height for floor (200-100-lower wall height)
	 mov cx,4               ; disregard scratchpad top 16 bytes of fpu stack 
fpupop16:fstp st0               ; disregard scratchpad top 16 bytes of fpu stack
         loop fpupop16          ; disregard scratchpad top 16 bytes of fpu stack 
         xchg cx,dx             ; after : dx=0, cx=divisor
         mov ah,3bh             ; discreet scale / ah=3bh=>ax=3a98h=15000b 
         div cx                 ; cx=distance / ax=result, dx=remainder
         xchg ax,cx             ; ax=distance, cx=result (wall height/2)
         lea di,[bp+32015]      ; middle of *this column (width*height/2) with ff9fh fixup / di=[32335;32015]
         mov si,di              ; src and dst index are same middle of *this column at start
         mov dx,100             ; dx=max height of wall/2
         cmp cx,dx              ; clipping test 
	 jc texture             ; no clipping needed 
	 mov cl,99              ; clipping
texture: if BONUSFLOOR          ; bonus floor
         sub dx,cx              ; dx=(max column height-wall height)/2
         end if                 ; bonus floor 
yloop:   mov ax,cx              ; xor texture : get height as distance
         xor ax,si              ; xor texture : perform unique number xor texture
         aaa                    ; normalize pixel color palette index to [0,15] 
         adc al,16              ; shift pixel color palette index to vga gray gradient [16,31]
         mov [di],al            ; plot upper vertical pixel
         sub di,320             ; get next upper vertical pixel
floor:   mov [si],al            ; plot lower vertical pixel
         add si,320             ; get next lower vertical pixel
         if BONUSFLOOR          ; bonus floor
         jcxz floor2            ; re-use for floor below (skip loop if cx=0)
         end if                 ; bonus floor 
         loop yloop             ; repeat until all pixels of *this column wall processed
         if BONUSFLOOR          ; bonus floor
         mov al,23              ; discreet uniform grey color value
floor2:  dec dx                 ; decrement *this column floor index
         jnz floor              ; repeat until all pixels of *this column floor processed
         end if                 ; bonus floor 
         dec bp                 ; decrement screen column index
         jnz xloop              ; repeat until all columns [319,0] of this screen processed 
         fstp st0               ; disregard scratchpad top 4 bytes of fpu stack
         jmp frame              ; process next frame / sorry no space left for esc key exit test
