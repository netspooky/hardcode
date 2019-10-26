_b equ byte       ;Abductee by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
_w equ word       ;submitted to Function demoparty 2014 in Budapest Hungary
_d equ dword      ;a DOS 256-byte intro for xpsp3 (preferred!) dosbox freedos
_s equ short      ;requires standard midi port 330 and cmd.exe not command.com
_n equ near       ;greets to all assembly coders Bon^2 AstroFra and Raizor1911
  SAFE=0          ;0=std 1=safe Red Sector Nr.1 ircnet/#rsi rsi.untergrund.net
  org 100h        ;@256
  if SAFE         ;safe version overhead
  mov si,100h     ;safe version overhead 
  mov cx,0ffh     ;safe version overhead 
  mov ax,9fffh    ;safe version overhead 
  mov es,ax       ;safe version overhead
  mov di,20cdh    ;safe version overhead
  mov _w[si],3fc4h;safe version overhead
  xor ax,ax       ;safe version overhead
  else            ;safe version overhead
  les di,[bx]     ;=c43fh es=9fffh di=20cdh
  end if          ;safe version overhead
  lodsb           ;si=101h [si]=3fh=set uart mode on
  mov dx,331h     ;dx=midi sound command port
  if not SAFE     ;safe version overhead
  outsb           ;al=3fh=set uart mode on midi status command
  end if          ;safe version overhead
  mov al,13h      ;ah=fun set video mode al=vga video mode 320x200
  int 10h         ;video display vga bios api
  dec dx          ;dx=midi data/status port 330h
  M equ 309a5bcah ;VVXXYYZZ=midi command message
  mov _d[si],M    ;VV=note val XX=chan select
  mov cl,9        ;YY=prog num (choir sndfnt) ZZ=prog change
  if not SAFE     ;safe version overhead
  rep outsb       ;ca 5b 9a 30 .org overlay 31 03 6e b0 93
  end if          ;safe version overhead
  mov bp,140h     ;vga mode 13H screen width
A:fninit          ;frameloop & (re)init fpu stack top
  if SAFE         ;safe version overhead
  xor dx,dx       ;safe version overhead
  else            ;safe version overhead
  cwd             ;dx=0 prevents div 0 triple fault
  end if          ;safe version overhead 
  lea ax,[di-10h] ;spot coord=di vga segment les paragraph fixup
  div bp          ;ax=y dx=x
  mov si,1012h    ;z=@1010h y=@1012h x=@1014h
  call _n F       ;base origin=(100,100)
  xchg ax,dx      ;y=y-100/fov
  fld1            ;z=1 x=x-100/fov
  call _n F       ;x z y
  call _n D       ;ca sa x y z
  fsincos         ;ca sa x y z
  fcos            ;ca sa x y z
  fld st2         ;x ca sa x y z
  fmul st0,st1    ;x*ca ca sa x y z
  fld st4         ;y x*ca ca sa x y z
  fmul st0,st3    ;y*sa x*ca ca sa x y z
  fsubp st1,st0   ;x*ca-y*sa ca sa x y z
  fxch st3        ;x ca sa x*ca-y*sa y z
  fmulp st2,st0   ;ca x*sa x*ca-y*sa y z
  fmulp st3,st0   ;x*sa x*ca-y*sa y*ca z
  faddp st2,st0   ;x*ca-y*sa y*ca+x*sa z
  fxch st2        ;z y*ca+x*sa x*ca-y*sa
  fxch st1        ;y*ca+x*sa z x*ca-y*sa
  mov cl,3        ;cl=repeat loop
B:fild _w[si]     ;z2 y*ca+x*sa z x*ca-y*sa
  lodsw           ;y2 z2 y*ca+x*sa z x*ca-y*sa
  loop B          ;x2 y2 z2 y*ca+x*sa z x*ca-y*sa
  dec cl          ;cl=visibility fostrum=[255,0]
C:mov si,1016h    ;ray z2=@1016h y2=@1018h x2=@101ah
  fist _w[si-2]   ;x2 y2 z2 y*ca+x*sa z x*ca-y*sa ->x=x2
  fadd st,st5     ;x2+x*ca-y*sa y2 z2 y*ca+x*sa z x*ca-y*sa
  fxch st1        ;y2 x2+x*ca-y*sa z2 y*ca+x*sa z x*ca-y*sa
  fist _w[si-4]   ;y2 x2+x*ca-y*sa z2 y*ca+x*sa z x*ca-y*sa ->y=y2
  fadd st,st4     ;y2+z x2+x*ca-y*sa z2 y*ca+x*sa z x*ca-y*sa
  fxch st2        ;z2 x2+x*ca-y*sa y2+z y*ca+x*sa z x*ca-y*sa z x y
  fist _w[si-6]   ;z2 x2+x*ca-y*sa y2+z y*ca+x*sa z x*ca-y*sa ->z=z2
  fadd st,st3     ;z2+y*ca+x*sa x2+x*ca-y*sa y2+z y*ca+x*sa z x*ca-y*sa z+1 x y
  fxch st2        ;y2+z x2+x*ca-y*sa z2+y*ca+x*sa y*ca+x*sa z x*ca-y*sa y x z+1
  fxch st1        ;x2+x*ca-y*sa y2+z z2+y*ca+x*sa y*ca+x*sa z x*ca-y*sa x y z+1
  call _n J       ;get logical map /w [si]=z2
  add bl,al       ;map=z+y+x
  mov _w[bx],si   ;clear logical map index /w si=bytemask 10h,10h
  call _n J       ;get physical map
  xlatb           ;map=z+y+x
  cmp al,10h      ;ray hit ?
  loopz _s C      ;if not advance ray whilde dist<256
  call _n K       ;calculate block texture
  shr cx,5        ;ambient lighting dist=255-cl/32
  shr ax,5        ;grayscale vga sub palette interval
  add ax,cx       ;add ambient lighting to texture val
  add al,0ch      ;align pixel color to interval
  stosb           ;plot pixel value
  test di,di      ;all 65536 frame points processed ?
  jnz A           ;if not then continue this frame
  call _n G       ;else get new lissajous values
  in ax,60h       ;verify if esc key pressed
  if SAFE         ;safe version overhead  
  dec al          ;if al=0 then no key and process next frame
  jnz A           ;else exit with ret by fall-through
  else            ;safe version overhead
  das             ;if al=0 then no key and process next frame
  jp A            ;else exit with ret by fall-through
  end if          ;safe version overhead 
D:fild _w[fs:46ch];load angle time=bios bda rtc lo word
  if SAFE         ;safe version overhead
E:fidiv _w[_115]  ;time/fov=angle f=@12ch in com=7300h=115d
  else            ;safe version overhead 
E:fidiv _w[12ch]  ;time/fov=angle f=@12ch in com=7300h=115d
  end if          ;safe version overhead 
  retn            ;return to caller or to shell
F:sub ax,64h      ;translate to arbitrary basis (100,100)
  mov _w[si],ax   ;ax=y or ax=x
  fild _w[si]     ;load y then x coordinates
  lodsw           ;si+=2 advance to abscisse
  jmp _s E        ;divide by field of view fidiv word [f]/retn
G:call _n D       ;lissajous x=a*st y=b*sn*t+k z=a*ct /w n=5/2 & k=pi/2
  fsincos         ;ct st t z(t)=a*ct /w t=ang
  call _n H       ;st t -> z2=a*ct+f si=z2 si+2=y2 si+4=z2
  call _n D       ;t st t n=@1e4h in com=00002040h=2.5f
  if SAFE         ;safe version overhead 
  fmul _d[_2.5]   ;n*t st t y(t)=b*sn*t+k /w n=5/2 and k=pi/2
  else            ;safe version overhead
  fmul _d[1e4h]   ;n*t st t y(t)=b*sn*t+k /w n=5/2 and k=pi/2
  end if          ;safe version overhead
  fcos            ;sn*t+pi/2 st t f(sn*t+k)=f(cn*t) /w k=pi/2
  if SAFE         ;safe version overhead
  fimul _w[_24]   ;b*sn*t+pi/2 st t scale2map b=@34h in psp=1800h=24d
  else            ;safe version overhead
  fimul _w[34h]   ;b*sn*t+pi/2 st t scale2map b=@34h in psp=1800h=24d
  end if          ;safe version overhead 
  call _n I       ;st t -> y2=b*sn*t+pi/2+f fcang from prev fsincos
H:if SAFE         ;safe version overhead 
  fimul _w[_94]   ;a*st t scale to h mapSiz a=@16fh in com=5e00h=94d
I:fiadd _w[_94]   ;a*st+f t
  else            ;safe version overhead 
  fimul _w[16fh]  ;a*st t scale to h mapSiz a=@16fh in com=5e00h=94d
I:fiadd _w[16fh]  ;a*st+f t
  end if          ;safe version overhead
  fistp _w[si]    ;t -> x2=a*st+f z2->y2->x2
  lodsw           ;si+=2
  retn            ;implicit "call H" z(t)=a*ct) /w si=z2
J:lodsw           ;map ax=[si] si+=2 assume bx=map off>512>org+progsize
  shld bx,ax,0ch  ;z/=16 z*=16^0 map=z (ie. shr ax,4)
  lodsw           ;ax=[si+2] si+=4
  aam 10h         ;y/=16 y*=16^2 (ie. shl ax,4)
  mov bh,ah       ;map=z+y
  lodsb           ;ax=[si+4] si=si+6 x=int(x/16) x*=16^1
  and al,0f0h     ;x=int(x/16) x*=16^1
  mov si,1010h    ;[si]=z ; z=@1010h /w 10h=block presence bitmask
  retn            ;(x/u)*s^1+(y/u)*(s^2)+(z/u)*(s^0) /w Unit=mapSiz=16
K:call _n L       ;call texture generation for 1st axis coord
  call _n L       ;call texture generation for 2nd axis coord
  db 20h,40h,90h  ;dword [$-2]=2.5f=3d lissajous curve /w n=5/2
L:and _b[si],0fh  ;get val(tex)%blocksize=local block coord
  fild _w[si]     ;texture gen x*ca+y*ca+z*ca
  if SAFE         ;safe version overhead
  fimul _w[_94]   ;scale up 1st:si=z 2nd:si=y 3rd:si=x
  else            ;safe version overhead
  fimul _w[16fh]  ;scale up 1st:si=z 2nd:si=y 3rd:si=x
  end if          ;safe version overhead 
  fsin            ;circular based texture design
  if SAFE         ;safe version overhead 
  fimul _w[_94]   ;rescale up /w auto-centering constant
  else            ;safe version overhead
  fimul _w[16fh]  ;rescale up /w auto-centering constant
  end if          ;safe version overhead
  fsubp st1,st0   ;accumulate shade of grey-lighting
  fabs            ;assert max Sigma|f(x)+f(y)+f(z)|
  fist _w[si]     ;store last retrievable Sigma
  lodsw           ;in accumulator (last ax=|f(x)+f(y)+f(z)|)
  retn            ;return to caller
if SAFE           ;safe version overhead
_24  dw 24        ;safe version overhead 
_94  dw 94        ;safe version overhead 
_115 dw 115       ;safe version overhead
_2.5 dd 2.5       ;safe version overhead
end if