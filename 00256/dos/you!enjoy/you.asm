;you!enjoy
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: algorika - buri buri

;1. #recyclewithfun
;2. standard palette is a fine thing
;3. [x] letter "j" at beginning of prod name

;#########################################################
;prod uses 10 bytes after the first 5 bytes of the code as
;initial values for movement to provide the same behaviour
;on every system including+providing dosbox compatibility.

;the whole thing was finished a long time ago. but in the
;last weeks i grabbed the code and made some changes over
;time which helped the intro a lot (colors/size of arrows/
;glass bars). well and to save 1b ESC sometimes need a few
;hits ...

;assuming: ax = bx = 0 cx = 255

org 100h
use16

start:   push 0a000h     ;vga
         pop es
         push 07000h     ;string buffah
         pop fs

         mov al,13h      ;320*200*256
         int 10h

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 08000h     ;vscreen
         pop ds

;grab string from 0a000:0000
;after int 10h mem is 0 so only string data <> 0
getdta:
mov al,byte[es:bx]           ;read
cmp al,ch                    ;is it 0 ?
je okok                      ;yes
mov al,54                    ;no, so set string color
okok:                        ;for later use
mov byte[fs:bx+320*92+40],al ;+ set pos for later use
dec bx
jnz getdta


main:

;do ze sophisticated background
shape4:
mov dl,20*11          ;dh always 03h after 1st frame
shape3:               ;and there is chaos at the beginning so don't care
mov ax,320*59-9       ;starting point of pattern
shape2:

mov bx,ax             ;set starting points
add bx,dx             ;to all elements
mov di,bx
mov si,bx

mov cl,10             ;ch = 0 here so save 1b
shape:
mov ch,dl             ;color management
shr ch,4              ;work it down
;add ch,cl
add ch,17             ;to grayscale

cmp byte[cs:start],8;al;8  ;make one shape pop up
jne allright
mov ch,55;42;54;42;9              ;in blue
allright:

mov byte[ds:bx],ch          ;right |
mov byte[ds:bx-18],ch       ;left |
mov byte[ds:di-9+320*19],ch ;left lower \
mov byte[ds:di],ch          ;upper right\
mov byte[ds:si-9+320*19],ch ;right lower /
mov byte[ds:si-18],ch       ;left upper /

xor ch,ch                   ;clean up for loop
add bx,320                  ;draw
sub di,321                  ;draw
sub si,319                  ;draw
loop shape                  ;the whole size/length

inc byte[cs:start]          ;for poppin uppin variation

add ax,320*21+10            ;draw next element below and right
cmp ax,320*130              ;same size as cmp ah,0a0h; 320*128 =0a000h
jna shape2                  ;draw some elements

inc byte[cs:start]          ;for variation over the whole height of pattern
sub dl,20                   ;next pattern stripe will be left from last one
jnz shape3                  ;draw all patterns

;draw arrows + glassbars
mov si,10  ;= 5 elements
elements:
mov dx,319                 ;save 1b below
mov ax,si  ;create speed
shr ax,1   ;but no so fast boi!
;inc ax ;not needed, smallest si = 2
add ax,word[cs:start+si+5] ;add pos to save bytes
cmp ax,320                 ;border?
jna fine                   ;no
sub ax,dx                 ;yes, so rearrange
fine:
mov word[cs:start+si+5],ax ;save new pos
mov bx,ax                  ;for upper part of arrow
mov bp,ax                  ;for lower part of arrow
;mov cl,25                 ;can save 2b below but it destroys the beginning
fine3:
shld di,si,17              ;every element has its own thickness
fine2:
mov ax,si ;different colors
add al,36;60;37;60;38;62;38 ;adjust colors
mov byte[ds:bp+di+320*56-17+320*23],al;42  ;upper part
mov byte[ds:bx+di+320*80+320*16],al;42     ;lower part
dec di
jnz fine2                  ;draw whole size
add bp,321
add bx,dx
;cmp bx,319*25              ;and fixes height
;jna fine3
cmp bh,16h              ;and fixes height
jb fine3
;loop fine3

inc dx ;make dx = 320
glass3:
imul bx,word[cs:start+si+5+2],-1 ;get pos of arrow and neg it
glass2:                          ;and use it for glass bar
;mov di,32;44                        ;width of glass
imul di,si,4
glass:
mov al,byte[ds:bx+di-4]    ;get data
dec ax
mov byte[ds:bx+di],al            ;sophisticated optical routine
dec di
jnz glass                        ;full width
sub bx,dx;320;321
jnc glass2                       ;and full height to top of screen/men

;vsync here to make it smoother under freedos
;but seriously, fuck it.
mov dx,3dah                     ;wait for vsync for constant speed
;vsync1:                        ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

dec si
dec si
jnz elements                    ;draw all elements

;flip
;di = cx = 0 here
flip:
mov al,byte[fs:di] ;grab screen with string for erasing old one
xchg al,byte[ds:di];grab vscreen and set the string
stosb              ;drop + inc di
loop flip

         in al,60h            ;read keyboard buffer
         dec ax               ;ah mostly = 0
         jnz main             ;nothing so go on
breaker: ret                  ;return to sender

;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db 'enjoy!evoke$'