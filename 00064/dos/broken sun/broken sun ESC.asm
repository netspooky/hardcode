mov fs,ax          ; FS = 0, for FreeDos
mov bh,0xA0        ; safe draw to 0xA000
mov es,bx          ; LES trick does not always work
mov bh,0x80        ; safe setting offscreen segment
mov ds,bx          ; to 0x8000
add al,0x13        ; switch to mode 13h
int 0x10           ; 320 x 200 in 256 colors
clr:               ; clear offscreen
mov [di],cl        ; AH = 0 all the time (black)
inc di             ; next offscreen pixel
jnz clr            ; repeat until done
pxl:               ; plot next pixel
shl al,1           ; color history, initial shift
sbb dx,bx          ; shared IFS subtraction
sar dx,1           ; shared IFS signed divide by 2
rcr ebp,1          ; delayed function branch
jnc brc            ; switch IF by value of t-32
sbb bl,[fs:0x46c]  ; offset by timer value
inc ax             ; color due to branch
brc:               ; both IF synchronous again
adc bx,dx          ; shared IFS addition
imul di,dx,320     ; make physical adress (1)
and al,3           ; reduce to 4 colors
add al,41          ; offset into the broken sun
mov [bx+di],al     ; write current pixel to offscreen
loop pxl           ; iterate 65536
mov di,si          ; align screen and offscreen
blt:               ; copy offscreen to screen
movsb              ; move single pixel
test si,si         ; check if done
jnz blt            ; repeat if not
in al,0x60         ; read key
dec al             ; key = ESC?
jnz clr            ; start again if yes
ret                ; program exit if not