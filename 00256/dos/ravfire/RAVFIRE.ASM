;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ #coders 256 byte Fire compo - held May 1996                               บ
;บ RAVFIRE by Andrew Nicolle (aka raven/tektonic)                            บ
;บ                                                                           บ
;บ ฐฑฒ CONTACT ฒฑฐ                                                           บ
;บ Email: 9405934s@lux.levels.unisa.edu.au (valid till Nov '97)              บ
;บ                                                                           บ
;บ ฐฑฒ DISCLAIMER ฒฑฐ                                                        บ
;บ I am not responsible for any damage to anything resulting from the use or บ
;บ misuse of this program. I've tested it on as many pc's as possible and    บ
;บ there have been no problems.                                              บ
;บ                                                                           บ
;บ ฐฑฒ INFO ฒฑฐ                                                              บ
;บ Unoptimized blow-torch effect and plain fire were coded in Dec 1995       บ
;บ Updated, Optimized(?), and Squished into 255 bytes for the Fire Compo.    บ
;บ                                                                           บ
;บ Uses 320x200 mode to do the routine. Frame counter and other extras       บ
;บ are not included, and instructions are optimized for size. The transition บ
;บ between the blow-torches and normal fire may be either to slow or quick   บ
;บ on computers faster or slower than a DX2/66. I didn't have the room to putบ
;บ in timing code to rectify this.                                           บ
;บ                                                                           บ
;บ A 286 processor or higher is required to run the demo. Not that you'd wantบ
;บ to see this running on a heap of crap like that...                        บ
;บ I would recommend at least a 486DX2/66 (gets about 30fps)                 บ
;บ                                                                           บ
;บ By all means, sift through the code and learn how it works (if you don't  บ
;บ already know...). If you use the blow-torch idea (or the triangular fire!)บ 
;บ or any of this code in a demo, mention me in the credits or greets.       บ
;บ Also any mail saying how c00l this stuff is would be appreciated.         บ
;บ                                                                           บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

.MODEL TINY
.286
Ideal

; Size of each frame
X_DOTS=320                             ; number of columns to average
Y_DOTS=204                             ; number of rows to average
Y_DISPLAYED=200                        ; number of rows to display
X_TORCH=50                             ; width of torch
T_GAP=20                               ; size of gap between torches
TWIDTH=(X_TORCH+T_GAP)                 ; total width of torch

; Number of frames for each fire effect
FX_FR=175

; Increment to increase width of fire
INCR=2*X_DOTS/FX_FR

CODESEG
ORG 100h

START: mov     ax,0013h
       int     10h

       ; set palette (coded through much trial and error)
       mov     dx,3c8h
       xor     al,al
       out     dx,al
       inc     dx
       xor     cx,cx

@@PalLoop:

       ; set red component
       mov     ax,cx
       shr     ax,1                    ; red = cx / 2
       cmp     al,63
       jle     @@SetRed
       mov     al,63                   ; make sure red < 64

@@SetRed:

       out     dx,al

       ; set green component
       xor     al,al
       cmp     cx,50
       jle     @@SetGreen
       mov     ax,cx
       sub     al,50
       shr     ax,1                    ; green = (cx - 50) / 2
       cmp     al,63
       jle     @@SetGreen
       mov     al,63                   ; make sure green < 64

@@SetGreen:

       out     dx,al

       ; set blue component
       xor     al,al
       out     dx,al
       inc     cx
       or      cl,cl                   ; see if past 255 colours
       jne     @@PalLoop

       mov     ax,cs
       add     ax,4096                 ; Get next segment in memory
       mov     ds,ax                   ; Store segment in ds

       mov     es,ax
       xor     di,di
       mov     cx,X_DOTS*Y_DOTS/2
       xor     ax,ax
       rep     stosw                   ; Clear the buffer

       mov     ah,0A0h
       mov     es,ax                   ; Point es to video memory
       mov     bp,FX_FR                ; bp is effect counter

@@FireLoop:

       ; offset of seed pixels in buffer
       mov     si,(X_DOTS*Y_DOTS)-(2*X_DOTS)
       or      bp,bp
       jle     @@NoTorch

       ; only seed a few points to get torch effect
       mov     cx,X_TORCH
       add     si,T_GAP                ; add gap between screen and torch
       jmp     @@BaseLoop

@@NoTorch:

       ; seed different lengths of pixels for triangular effect
       mov     cx,[cs:firelen]         ; read width of 'normal' fire
       mov     dx,X_DOTS
       add     [cs:firelen],INCR       ; increment width of 'normal' fire
       cmp     cx,dx
       jl      @@maxwidth
       mov     cx,X_DOTS-1

@@maxwidth:

       sub     dx,cx
       shr     dx,1
       add     si,dx                   ; si = centred value of fire

       ; set up the base of the flames

@@BaseLoop:

       ; generate pseudo-random number
       ; bx holds the random number seed, which initially could be anything
       mov     ax,bx
       mov     dx,8703h
       mul     dx
       inc     ax
       mov     bx,ax
       mov     [si],dl

       ; check for torches to be seeded
       or      bp,bp
       jle     @@NoTorch2
       mov     [si+TWIDTH],dl
       mov     [si+TWIDTH*2],dl
       mov     [si+TWIDTH*3],dl

@@NoTorch2:

       inc     si
       loop    @@BaseLoop

       mov     cx,X_DOTS*(Y_DOTS-2)
       xor     si,si

       ; average the pixels

@@Average:

       xor     ax,ax
       mov     al,[si+X_DOTS-1]
       add     al,[si+X_DOTS]
       adc     ah,0
       add     al,[si+X_DOTS+1]
       adc     ah,0
       add     al,[si+2*X_DOTS]
       adc     ah,0
       dec     ax                      ; subtract decay rate from total
       jns     @@Not_signed            ; ensure overflowed value set to 0
       xor     ax,ax

@@Not_signed:

       shr     ax,2                    ; find average pixel value
       mov     [si],al
       inc     si
       loop    @@Average

       dec     bp                      ; decrement effect counter
       jz      @@ClrSeeds              ; clear seed pixels when effects change

       cmp     bp,-2*FX_FR
       jge     @@SkipClr
       mov     [cs:firelen],1          ; reset width of 'normal' fire
       mov     bp,FX_FR

@@ClrSeeds:

       ; Clear seed pixels from previous effect
       ; At this point, si = (X_DOTS*Y_DOTS)-(2*X_DOTS) (where we want it!)
       xor     ax,ax
       mov     cx,X_DOTS

@@ClearSeed:
       mov     [si],ax
       inc     si
       inc     si                      ; 2x inc si shorter than add si,2
       loop    @@ClearSeed

@@SkipClr:

       xor     si,si                   ; return to start of frame buffer
       xor     di,di
       mov     cx,X_DOTS*Y_DISPLAYED/2
       rep     movsw                   ; dump data to screen

       mov     ah,1
       int     16h                     ; check for keypress
       jnz     @@TxtMode
       jmp     @@FireLoop              ; prepare next frame

@@TxtMode:

       mov     ax,3
       int     10h                     ; return to text mode

       mov     ax,4c00h
       int     21h                     ; exit program

       ; initial width of 'normal' fire
       firelen dw 1

END START
