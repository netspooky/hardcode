;******************************************************************************
; GIRL BASIC 2KB FOR YOUNG GIRLS THAT JUST WAN TO CODE ! PINK POWER !
;                 /\______          /\______          /\________
;             __\\\___    \_    __\\\___    \_    __\\\______   \
;            |      /      /   |      /      /   |     _____/    \_
;            |     /      /____|     /      /____|     \           |
;            |     \____       :      _____/     :      \          |
;            |        /                \                 \         |
;            |       /         .        \        .        \        |
;      __   _|_     /                    \                 \      _|_   __
;   \ \\_\ \\__\  _/           :          \_     :          \_   /__// /_// /
;            |____/_ _         :______ _         :______ _         |
;               \\\____________|  \\\____________|  \\\____________|
;
;    _______      _______      _______      _______      _______      _______
; _\\\__    \___\\\__    \___\\\__    \___\\\_____ \___\\\_____ \___\\\__    \_
;|    /______/|    /      /|    /      /|       /    |       /    |    /      /
;\            |   /      /_|   /      /_|      /     |      /     |   /      /_
;|\_______    :    _____/  :   \_____/  :     /      :     /      :   \____    |
;|      /     .     \      .     \      .    /       .    /       .     /      |
;|     /             \            \         /                          /       |
;|___         :___         :___         :___\        :___         :___/    sns |
;  \\_________: \\_________: \\_________: \\_________: \\_________: \\_________|
;
;                          R E D   S E C T O R   I N C
;
; DOS+WinXP  2Kb GIRL BASIC  by Baudsurfer/rsi 2015 aka olivier.poudade.free.fr
;
; Youtube : https://www.youtube.com/watch?v=bw0A8q6JPZc
;
; Build with : fasm Girlbasic.asm + apack Girlbasic.com
;
; Short history :
; original concept for Homebrew club           ver 0.1 1975 n/a  Denis Allison 
; original version for 8080 Dr Dobb's journal  ver 1.0 1974 1792 Li-Chen Wang
; converted to vasm for 8086 bc=cx de=dx hl=bx ver 1.1 1982 ???? Michael Sullivan  
; support ms-dos interupt i/o                  ver 1.1 1982 ???? Michael Sullivan  
; improve rnd action                           ver 1.1 1982 ???? Michael Sullivan
; support time and date from ms-dos            ver 1.1 1982 1792 Michael Sullivan
; converted to nasm assembler for 80286        ver 1.2 2000 2735 Frank Kotler
; converted to fasm assembler 80486            ver 1.3 2015 2711 Olivier Poudade
; optimized code                               ver 1.4 2015      Olivier Poudade
; rewrote shorter rnd routine on 8253 pic2     
; replaced "how" "what" "sorry"->SYNTAX ERROR
; added highres graphic char gui 80colx60row   
; replaced stop->end ok->READY 
; removed "dsave" "dload" file disk i/o 
; removed "out" "inp" "wait" and "usr" port i/o
; removed optional "let"
; Girl basic 2kb released (for children)
; N.B : this arvhive also contains a smallet than MINOL bare version named 
; Basic1771b : [24/05/1976] "MINOL tiny basic v1.0" by Erik T. Mueller 1.75kb 
; (1792 bytes) MITS Altair 8800 intel 8080 (was not the initial intent though)
;******************************************************************************
base      equ 8191
outcar    equ base    ; db 0 ; resb 1         ;output char storage
currnt    equ base+ 1 ; dw 0 ; resw 1         ;points to current line
stkgos    equ base+ 2 ; dw 0 ; resw 1         ;saves sp in 'gosub'
varnxt    equ base+ 4 ; dw 0 ; resw 1         ;temp storage
stkinp    equ base+ 6 ; dw 0 ; resw 1         ;saves sp in 'input'
lopvar    equ base+ 8 ; dw 0 ; resw 1         ;'for' loop save area
lopinc    equ base+10 ; dw 0 ; resw 1         ;increment
loplmt    equ base+12 ; dw 0 ; resw 1         ;limit
lopln     equ base+14 ; dw 0 ; resw 1         ;line number
loppt     equ base+16 ; dw 0 ; resw 1         ;test pointer
ranpnt    equ base+18 ; dw 0 ; resw 1         ;random number pointer
txtbgn    equ base+20 ; db 2000h dup(0) ; txtbgn resb 2000h
buf_max   equ base+8212 ; db 0; resb 1         ; text area save area ends max chars in buffer
buf_cnt   equ base+8213 ; db 0; resb 1          ; char count
buffer    equ base+8214 ; resb 80h 
varbgn    equ base+8252 ; db 54 dup(0); varbgn resb 54
stklmt    equ base+8306 ; db 400h dup(0) ; stklmt resw 400h       ;top limit for stack
stack_    equ base+9330 ;stack_:                 ;stack starts here
bufend    equ varbgn;bufend:
tab1      equ tab1_
tab2      equ tab2_
tab4      equ tab4_
tab5      equ tab5_
tab6      equ tab6_
tab8      equ tab8_
exec      equ exec_
input     equ input_
lstrom    equ lstrom_
txtend    equ buf_max
bye       equ 0         ;bdos exit address
fcb       equ 5ch       ; bdos equates (for ms-dos)
setdma    equ 26
open      equ 15
readd     equ 20
writed    equ 21
close     equ 16
make      equ 22
bconin    equ 10         ;buffered console input
delete    equ 19
const     equ 11         ;console status
          org 100h         ;standard ms-dos start addr.
start:    mov aX,12h ; VIDEO - SET VIDEO MODE ; THIS SETS 80 columns x 60 rows edit mode 
          int 10h ; AL = desired video mode  G  80x30  8x16  640x480  mono      .   A000 VGA,MCGA,ATI EGA,ATI VIP
          mov dx,ks
          mov ax,251ch
          int 21h
          mov ah,0bh ; VIDEO - SET BACKGROUND/BORDER COLOR
          mov bh,00 ; bl=background/border color (border only in text modes)
          mov bl,9h; 1=dark blue; 9=bleu2
          int 10h
          mov ax,1123h ;  Loads ROM BIOS 8x8 character font in graphics mode.
          mov bl,0 ; BL = Number of rows -> DL contains number of rows
          mov dl,60 ; 480/8
          int 10h
;          mov dx,basicpal ;ES:DX -> palette register list (see #00018)
;          mov ax,1002h ; 00h 16 BYTEs   colors for palette registers 00h through 0Fh 10h    BYTE    border color
;          xor bh,bh ; to avoid problems on some adapters
;          int 10h ; SET ALL PALETTE REGISTERS (PCjr,Tandy,EGA,VGA) 
          mov sp,stack_         ;set up stack
          mov dx,msg1         ;get sign-on msg
          call prtstg         ;send it
          mov dx,8
el:       mov cx,100
          sub cx,dx
ee:       mov ah,0ch;01H
          mov al,dl
          shr al,3
          mov bh,0
          int 10h
          loop ee
          inc dx
          cmp dx,48
          jnz el
          mov byte [buf_max],80h         ;init cmd line buffer
rstart:   mov sp,stack_         ;set stack pointer
_st1:     call crlf
          mov dx,ok         ;de->string
          salc ; TODO verify was sub al,al
          call prtstg         ;print prompt
          mov word [currnt],0         ;current line # = 0
_st2:     mov word [lopvar],0
          mov word [stkgos],0
_st3:     mov al,'>';0dbh; '>'         ;prompt ">" now
          call getln         ;read a line
          push di         ;di -> end of line
_st3a:    mov dx,buffer         ;dx -> beginning of line
          call tstnum         ;test if it's a number
          mov ah,0
          call ignblnk
          or bx,bx         ;bx:= value of # or 0 if no # found
          pop cx         ;cx -> end of line
          jnz _st3b
          jmp direct
_st3b:    dec dx
          dec dx
          mov ax,bx         ;get line #
          mov di,dx
          stosw          ;value of line # there
          push cx
          push dx         ;bx,dx -> begin,end
          mov ax,cx
          sub ax,dx
          push ax         ;ax:= # bytes in line
          call fndln         ;find this line in save
          push dx         ;area, dx -> save area
          jnz _st4         ;nz:not found, insert
          push dx         ;z:found, delere it
          call fndnxt         ;find next line-> next line
          pop cx         ;cx -> line to be deleted
          mov bx,[txtunf]         ;bx -> unfilled save area
          call mvup         ;move up to delete
          mov bx,cx         ;txtunf -> unfilled area
          mov [txtunf],bx         ;update
_st4:     pop cx         ;get ready to insert
          mov bx,[txtunf]         ;but first check if
          pop ax         ;ax = # chars in line
          push bx         ;is 3 (line # and cr)
          cmp al,3         ;then do not insert
          jz rstart         ;must clear the stack
          add ax,bx         ; compute new txtunf
          mov bx,ax         ; bx -> new unfilled area
_st4a:    mov dx,txtend         ;check to see if there
          cmp bx,dx         ;is enough space
          jc _st4b         ;sorry, no room for it
          jmp qwhat ; was jmp qsorry
_st4b:    mov [txtunf],bx         ;ok, update txtunf
          pop dx         ;dx -> old unfilled area
          call mvdown
          pop dx         ;dx -> begin, bx -> end
          pop bx
          call mvup         ;move new line to save area
          jmp _st3
tstv:     mov ah,64         ;test variables
          call ignblnk
          jc ret01
tstv1:    jnz tv1         ;not @ array
          call parn         ;@ should be followed
          add bx,bx
          jnc ss1b         ;is index too big?
          jmp qwhat ; was jmp     qhow
ss1b:     push dx         ;will it overwrite
          xchg dx,bx         ;text?
          call size         ;find size of free
          cmp bx,dx         ;and check that
          jnc ss1a         ;iff so, say "sorry"
          jmp awhat ; was jmp     asorry
ss1a:     mov bx,varbgn         ;iff not, get address
          sub bx,dx         ;of @(expr) and put it
          pop dx         ;in hl
ret01:    ret         ;c flag is cleared
tv1:      cmp al,27         ;not @, is it a to z?
          jc ret2         ;iff not, return c flag
          inc dx
tv1a:     mov bx,varbgn         ;compute address of
          mov ah,0         ;clear upper byte
          add ax,ax         ;ax:=ax*2 (word storage)
          add bx,ax         ;bx:=varbgn+2*al
ret2:     ret          ;use carry as error indicator
tstnum:   xor bx,bx; was mov bx,0         ;****tstnum****
          mov ch,bh         ;test iff the text is
          mov ah,0         ;for cmp in ignblnk
          call ignblnk         ;a number.
tn1:      cmp al,'0'         ;iff not, return 0 in
          jc ret2         ;b and hl
          cmp al,':'         ;iff numbers, convert
          jnc ret2         ;to binary in bx and
          mov al,0f0h          ;set al to # of digits
          and al,bh         ;iff bh>255, there is no
          jnz qwhat ; was jnz qhow         ;room for next digit
          inc ch         ;ch counts number of digits
          push cx
          mov ax,bx         ;bx:=10*bx+(new digit)
          mov     cx,10
          push dx         ;save dx
          mul cx
          mov     bx,ax           ;partial result now in bx
          pop dx         ;restore
          mov si,dx
          lodsb                 ;ascii digit in al now
          sub     al,48           ;convert to binary
          mov     ah,0
          add     bx,ax           ;full result now in bx
          pop cx
          lodsb                    ;repeat for more digits
          lahf          ;save flags
          inc dx
          sahf          ;restore flags
          jns tn1         ;quit if no num or overflow
          jmp qwhat
ok:       db 'READY.',0dh
what:     db 'SYNTAX ERROR.',0dh
tab1_     db 'lis','t' OR 80h  ; direct commands
          dw list         ;execution addresses
          db 'edi','t' OR 80h
          dw edit
          db 'e' OR 80h
          dw edit         ;have short form defined also
          db 'ru','n' OR 80h
          dw run
          db 'ne','w' OR 80h
          dw new
          db 'qui','t' OR 80h          ;go back to dos (exit tbasic)
          dw bye
tab2_     db 'nex','t' OR 80h ;direct/statement
          dw next         ;execution addresses
          db 'pok','e' OR 80h
          dw poke
          db 'i','f' OR 80h
          dw iff
          db 'got','o' OR 80h
          dw goto
          db 'gosu','b' OR 80h
          dw gosub
          db 'retur','n' OR 80h
          dw return
          db 're','m' OR 80h
          dw rem
          db 'fo','r' OR 80h
          dw for
          db 'inpu','t' OR 80h
          dw input
          db 'prin','t' OR 80h
          dw print
          db 'en','d' OR 80h
          dw stop
          db 128         ;signals end
          dw deflt         ;last posibility
tab4_     db 'rn','d' OR 80h ;functions
          dw rnd
          db 'pee','k' OR 80h
          dw peek
          db 'ab','s' OR 80h
          dw abs
          db 'siz','e' OR 80h
          dw size
          db 128         ;signals end you can add more functions but remember to move xp40 down
          dw xp40
tab5_     db 't','o' OR 80h ;"to" in "for"
tab5a:    dw fr1
          db 128
          dw qwhat
tab6_     db 'ste','p' OR 80h ;"step" in "for"
tab6a:    dw fr2
          db 128
          dw fr3
tab8_     db '>','=' OR 80h ;relation operators
          dw xp11         ;execution address
          db '#' OR 80h
          dw xp12
          db '>' OR 80h
          dw xp13
          db '=' OR 80h
          dw xp15
          db '<','=' OR 80h
          dw xp14
          db '<' OR 80h
          dw xp16
          db 128
          dw xp17
direct:   mov bx,tab1-1         ;***direct***
exec_:          ;***exec***
ex0:      mov ah,0
          call ignblnk         ;ignore leading blanks
          push dx         ;save pointer
          mov si,dx
ex1:      lodsb          ;get char where dx ->
          inc dx         ;preserve pointer
          cmp al,'.'         ;we declare a match
          jz ex4
          inc bx
          mov ah,[bx]
          and ah,127         ;strip bit 7
          or al, 20h ; lowercase al
          cmp al,ah         ;comparison now easy
          jz ex2  ; no match - check next entry
ex0a:     cmp byte [bx],128         ;byte compare
          jnc ex0b
          inc bx
          jmp ex0a ; at this point have last letter
ex0b:     add bx,3         ;get past execution address
          cmp byte [bx],128         ;found default?
          jz ex3a         ;if so, execute default
          dec bx         ;correct for pre-increment
          pop dx         ;restore pointer
          jmp ex0         ;look some more for a match
ex4:      inc bx
          cmp byte [bx],128
          jc ex4
          jmp ex3
ex3a:     dec si
          jmp ex3         ;correct si for default execution
ex2:      cmp byte [bx],128         ;end of reserved word?
          jc ex1         ;no - check some more at this point need to get execution address
ex3:      inc bx         ;bx -> execution address
          pop ax         ;clear stack
          mov dx,si         ;reset pointer
          jmp word [bx] ; do it
new:      mov word [txtunf],txtbgn
stop:     call endchk         ;****stop(cr)****
          jmp rstart
run:      call endchk         ;****run(cr)****
          mov dx,txtbgn         ;first saved line
runnxl:   xor bx,bx ;         ;****runnxl****
          call fndlnp         ;find whatever line
          jnc runtsl         ;c: passed txtunf, quit
          jmp     rstart
runtsl:   mov [currnt],dx         ;set 'currnt"->line #
          inc dx
          inc dx
runsml:   mov bx,tab2-1         ;find command in table 2
          jmp exec         ;and execute it
goto:     call exp         ;****goto(expr)****
          push dx         ;save for error routine
          call endchk         ;must find a 0dh (cr)
          call fndln         ;find the target line
          jz gt1         ;no such line #
          jmp awhat ; jmp     ahow
gt1:      pop ax
          jmp runtsl         ;go do it
list:     call tstnum         ;test iff there is a #
          call endchk         ;iff no # we get a 0
          call fndln         ;find this or next line
ls1:      jnc ls2         ;c: passed txtunf
          jmp     rstart
ls2:      call prtln         ;print the line
          call fndlnp         ;find next line
          jmp ls1         ;loop back
edit:     call tstnum         ;test if there is a #
          call endchk         ;at end?
          call fndln         ;find spec line or next line
          push dx         ;save line #
          jnc ed2         ;c: passed txtunf
          pop dx         ;throw away line #
ed1:      jmp rstart
ed2:      call prtln         ;print the line
          pop dx         ;get line # back
          mov byte [buffer-1],0         ;clear char count
          mov byte [prtln1+1],4         ;print one less space
          mov di,buffer         ;prepare to move
          call prtln
          dec byte [buffer-1]         ;avoid cr?
          mov byte [prtln1+1],5         ;restore prtln
          jmp _st3         ;prompt and getline only
print:    mov cl,6         ;c:= # of spaces
          mov ah,';'         ;check for ';' in ignblnk
          call ignblnk         ;ignore blanks
          jnz pr2         ;jump if ';' not found
          call crlf         ;give cr,lf and
          jmp runsml         ;continue same line
pr2:      mov ah,0dh
          call ignblnk
          jnz pr0
          call crlf         ;also give crlf and
          jmp runnxl         ;goto next line
pr0:      mov ah,'#'
          call ignblnk
          jnz pr1
          call exp         ;yes, evaluate expr
          mov cl,bl         ;and save it in c
          jmp  pr3         ;look for more to print
pr1:      call qtstg         ;or is it a string?
          jmp pr8         ;iff not, must be expression
pr3:      mov ah,','
          call ignblnk
          jnz pr6
          call fin         ;in the list
          jmp pr0         ;list continues
pr6:      call crlf         ;list ends
          call finish
pr8:      call exp         ;eval the expr
          push cx
          call prtnum         ;print the value
          pop cx
          jmp pr3         ;more to print?
gosub:    call _pusha         ;save the current 'for'
          call exp         ;parameters
          push dx
          call fndln         ;find the target line
          jz gs1         ;not there, say "how?"
          jmp awhat ; jmp     ahow
gs1:      mov bx,[currnt]         ;found it, save old
          push bx         ;'currnt' old 'stkgos'
          mov bx,[stkgos]
          push bx
          xor bx,bx; and load new ones
          mov [lopvar],bx
          add bx,sp
          mov [stkgos],bx
          jmp runtsl         ;then run that line
return:   call endchk         ;there must be a 0dh
          mov bx,[stkgos]         ;old stack pointer
          or bx,bx
          jnz ret1         ;so, we say: "what?"
          jmp     qwhat
ret1:     xchg bx,sp          ;else restore it
          pop word [stkgos]
          pop bx
          mov [currnt],bx         ;and the old 'currnt'
          pop dx         ;old text pointer
          call _popa         ;old "for" parameters
          call finish         ;and we are back home
for:      call _pusha         ;save the old save area
          call setval         ;set the control var.
          dec bx
          mov [lopvar],bx         ;save tgat
          mov bx,tab5-1         ;use 'exec' to look
          jmp exec         ;for the word 'to'
fr1:      call exp         ;evaluate the limit
          mov [loplmt],bx         ;save that
          mov bx,tab6-1         ;used 'exec' to look
          jmp exec         ;for the word 'step'
fr2:      call exp         ;found it, get step
          jmp fr4         ;found it, get step
fr3:      mov bx,1         ;not found, set to one
fr4:      mov [lopinc],bx         ;save that too
fr5:      mov bx,[currnt]         ;save current line #
          mov [lopln],bx
          mov [loppt],dx
          mov cx,10         ;dig into stack to
          mov dx,[lopvar]         ;find 'lopvar'
          mov bx,cx         ;bx:=10 now
          add bx,sp
          jmp fr7a
fr7:      add bx,cx
fr7a:     mov ax,[bx]         ;get that old 'lopvar'
          or ax,ax
          jz fr8         ;0 says no more in it
          cmp ax,dx         ;same as this one?
          jnz fr7
          xchg dx,bx
          xor bx,bx ;the other half?
          add bx,sp
          mov cx,bx
          mov bx,10
          add bx,dx
          call mvdown         ;and purge 10 words
          xchg bx,sp          ;in the stack
fr8:      mov bx,[loppt]         ;job done, restore de
          xchg dx,bx
          call finish         ;and continue
next:     call tstv         ;get addr of var
          jnc nx4         ;no variable, "what?"
          jmp qwhat
nx4:      mov [varnxt],bx         ;yes, save it
nx0:      push dx         ;save text pointer
          xchg dx,bx
          mov bx,[lopvar]         ;get var in 'for'
          mov al,bh
          or al,bl         ;0 say never had one
          jnz nx5         ;so we ask: "what?"
          jmp awhat
nx5:      cmp dx,bx         ;else we check them
          jz nx3         ;ok, they agree
          pop dx         ;no, let's see
          call _popa         ;purge current loop
          mov bx,[varnxt]         ;and pop one level
          jmp nx0         ;go check again
nx3:      mov dl,[bx]         ;come here when agreed
          inc bx
          mov dh,[bx]         ;de = val of var
          mov bx,[lopinc]
          push bx
          add bx,dx
          xchg dx,bx         ;add one step
          mov bx,[lopvar]         ;put it back
          mov [bx],dl
          inc bx
          mov [bx],dh
          mov bx,[loplmt]         ;hl-> limit
          pop ax
          xchg ah,al
          or ax,ax
          jns nx1         ;step > 0
          xchg dx,bx
nx1:      call ckhlde         ;compare with limit
          pop dx         ;restore text pointer
          jc nx2         ;outside limit
          mov bx,[lopln]         ;within limit, go
          mov [currnt],bx         ;back to the saved
          mov bx,[loppt]         ;'currnt' and text
          xchg dx,bx         ;pointer
          call finish         ;pointer
nx2:      call _popa         ;purge this loop
          call finish
rem:      xor bx,bx ;***rem****
          jmp iff1a         ;jump around expr
iff:      call exp         ;****if****
iff1a:    test bx,bx ;was cmp bx,0         ;is the expr = 0? ;jz iff1         ;no, continue ;jmp     runsml
          jnz runsml  
iff1:     call fndskp         ;yes, sikp rest of line
          jc iff2         ;yes, sikp rest of line
          jmp     runtsl
iff2:     jmp rstart         ;yes, sikp rest of line
inperr:   mov sp,[stkinp]
          pop word [currnt] ; risky bx
          pop edx        ;was  ;pop dx  ;pop dx         ;redo input
input_:         ;****input****
ip1:      push dx         ;save in case of error
          call qtstg         ;is next item a string?
          jmp ip2         ;no
          call tstv         ;yes, but followed by a
          jc ip4         ;variable? no.
          jmp ip3         ;yes. input var.
ip2:      push dx         ;save for 'prtstg'
          call tstv         ;must be a var now
          jnc ip2a         ;"what" it is not!
          jmp     qwhat
ip2a:     mov si,dx
          lodsb          ;get ready for 'rtstg'
          mov cl,al
          salc ; TODO verify sub al,al
          mov di,dx
          stosb
          pop dx
          call prtstg         ;print string as prompt
          mov al,cl
          dec dx
          mov di,dx
          stosb
ip3:      push dx
          xchg dx,bx
          mov bx,[currnt]         ;also save 'currnt'
          push bx
          mov bx,ip1
          mov [currnt],bx         ;neg number as flag
          mov [stkinp],sp
          push dx         ;old hl
          mov al,':'         ;print this too
          call getln         ;and get a line
ip3a:     mov dx,buffer         ; points to buffer
          call exp         ;evaluate input
          pop dx         ;ok,get old hl
          xchg dx,bx         ;ok,get old hl
          mov [bx],dx
          pop word [currnt] ; get previous 'currnt' 
          pop dx         ;and get old text pointer
ip4:      pop ax
          mov ah,','
          call ignblnk
          jnz ip5
          jmp ip1         ;yes, more items
ip5:      call finish
deflt:    mov si,dx
          lodsb         ;****deflt****
          cmp al,0dh         ;empty line is ok
          jz lt1         ;else it is 'let'        
let:      call setval         ;****let****
          mov ah,','
          call ignblnk
          jnz lt1
          jmp let         ;item by item
lt1:      call finish         ;until finish
exp:      call expr2
          push bx
expr1:    mov bx,tab8-1         ;lookup rel.op
          jmp exec         ;go do it
xp11:     call xp18
          jc ret4         ;no return hl=0
          mov bl,al         ;yes, return hl=1
          ret
xp12:     call xp18
          jz ret4         ;false, return hl=0
          mov bl,al         ;true, return hl=1
ret4:     ret
xp13:     call xp18         ;rel.op '>'
          jz ret5         ;false
          jc ret5         ;also false, hl=0
          mov bl,al         ;true, hl=1
ret5:     ret
xp14:     call xp18         ;rel op '<='
          mov bl,al         ;set hl=1
          jz ret6         ;rel. true, return
          jc ret6         ;rel. true, return
          mov bl,bh         ;else set hl=0
ret6:     ret
xp15:     call xp18         ;rel op '='
          jnz ret7         ;false, return hl=0
          mov bl,al         ;else set hl=1
ret7:     ret
xp16:     call xp18         ;rel.op '<'
          jnc ret8         ;false, return hl=0
          mov bl,al         ;else set hl=1
ret8:     ret
xp17:     pop bx         ;not rel op
          ret         ;return hl=<eptr2>
xp18:     mov al,cl         ;subroutine for all
          pop bx         ;rel.op's
          pop cx         ;rel.op's
          push bx         ;reverse top of stack
          push cx         ;reverse top of stack
          mov cl,al
          call expr2         ;get 2nd expression
          xchg dx,bx         ;value in de now
          pop ax
          push bx
          mov bx,ax         ;last 3 instr for xthl inst!
          call ckhlde         ;compare 1st with second
          pop dx
          mov bl,0         ;set hl=0, a=1
          mov al,1         ;set hl=0, a=1
          ret
expr2:    mov ah,'-'
          call ignblnk         ;negative sign?
          jnz xp21
          xor bx,bx;mov bx,0         ;yes, fake '0-'
          jmp xp26         ;treat like subtract
xp21:     mov ah,'+'         ;positive sign?
          call ignblnk
xp22:     call expr3         ;1st <expr3>
xp23:     mov ah,'+'
          call ignblnk         ;add?
          jnz xp25         ;note offset whas 21 bytes in 8080 version
          push bx         ;yes, save value
          call expr3         ;get 2nd <expr3>
xp24:     xchg dx,bx         ;2nd in de
          pop ax         ;this + next 2 lines for 8080 xthl inst!!
          push bx
          mov bx,ax         ;bx <-> [sp] now, [sp]->buffer,bx=old expr3
          add bx,dx
          pop dx
          jno xp23         ;check for overflow
xp24a:    jmp qwhat ; was jmp qhow         ;else we have overflow
xp25:     mov ah,'-'
          call ignblnk         ;subtract?
          jnz ret9
xp26:     push bx         ;yes, save 1st <expr3>
          call expr3         ;get 2nd <expr3>
          call chgsgn
          jmp xp24
expr3:    call expr4         ;get 1st <expr4>
xp31:     mov ah,'*'
          call ignblnk         ;multiply?
          jnz xp34
          push bx         ;yes, save 1st
          call expr4         ;and get 2nd <expr4>
          xchg dx,bx         ;2nd in de now
          pop ax         ;subsitute for 8080 xthl
          push bx
          imul ax,dx         ;ax:=ax*dx
          jo awhat         ;see intel book on overflow flag
          mov bx,ax         ;result now in bx
          jmp xp35         ;look for more
xp34:     mov ah,'/'
          call ignblnk         ;divide?
          jnz ret9
          push bx         ;yes, save 1st <expr4>
          call expr4         ;and get second one
          xchg dx,bx         ;put 2nd in de
          pop ax         ;replacement for xthl
          push bx
          mov bx,ax
          or dx,dx
          jz awhat ; jmp ahow
          call divide         ;use subroutine
          mov bx,cx         ;get result
          mov cx,6         ;six spaces
xp35:     pop dx         ;and text pointer
          jmp xp31         ;look for more terms
expr4:    mov bx,tab4-1         ;find fucntion in tab4
          jmp exec         ;and got do it
xp40:     call tstv         ;no, not a function
          jc xp41         ;nor a variable
          mov al,[bx]         ;variable
          lahf
          inc bx
          sahf
          mov bh,[bx]         ;value in hl
          mov bl,al         ;value in hl
ret9:     ret
xp41:     call tstnum         ;or is it a number?
          mov al,ch         ;# of digits
          or al,al
          jnz xp42         ;ok
parn:     mov ah,'('
          call ignblnk         ;no digit, must be
          jnz parn1
          call exp         ;"(expr)"
parn1:    mov ah,')'
          call ignblnk         ;"(expr)"
          jnz qwhat         ;else say: "what?"
xp42:     ret
rnd:      call parn         ;****rnd(expr)****
          or bx,bx
          jns rnd1         ;must be positive
          jnz rnd1         ;and non-zero
          jmp qwhat ; was jmp     qhow
rnd1:     in al,40h             ;read rand from 8253 pic2/pit channel 0
          mov ah,al
          in al,40h             ;read rand from 8253 pic2/pit channel 0
decrease: shr ax,1
          cmp ax,bx
          jnc decrease        
          mov bx,ax
          ret
abs:      call parn         ;****abs(expr)****
          call chksgn         ;check sign
          or ax,bx
          jns ret10         ;ok
          jmp qwhat ; was jmp qhow         ;so say: "how?"
size:     mov bx,[txtunf]         ;****size****
          push dx         ;get the number of free
          xchg dx,bx         ;bytes between 'txtunf'
sizea:    mov bx,varbgn         ;and 'varbgn'
          sub bx,dx
          pop dx
ret10:    ret
poke:     call exp
          push bx
          mov ah,','
          call ignblnk
          jz pok1
          jmp qwhat
pok1:     call exp
          mov al,bl
          pop bx
          mov [bx],al
          mov ah,','
          call ignblnk
          jnz pok2
          jmp poke
pok2:     call finish
peek:     call parn
          mov bl,[bx]
          mov bh,0
          ret
divide:   push dx         ;preserve dx accross call
          push dx
          pop cx
          mov ax,bx
          cwd ; was xor dx,dx before pop cx
          div cx
          mov cx,ax         ;quotient
          mov bx,dx         ;remainder
          pop dx         ;dx restored
          ret
chksgn:   or bx,bx         ;set flags to check sign
          jns ret11         ;iff -, change sign
chgsgn:   not bx         ;****chgsgn****
          inc bx
          neg cx ; xor ch,128
ret11:    ret
ckhlde:   mov al,bh
          xor al,dh         ;same sign?
          jns ck1         ;yes, compare
          xchg dx,bx
ck1:      cmp bx,dx
          ret
setval:   call tstv         ;see it it's a variable
          jc qwhat         ;"what" no variable
          push bx         ;save addr of variable
          mov ah,'='
          call ignblnk
          jnz sv1
          call exp
          mov cx,bx         ;value in cx now
          pop bx         ;get addr
          mov [bx],cl         ;save value
          inc bx
          mov [bx],ch         ;save value
          ret
sv1:      jmp qwhat         ;no '=' sign
fin:      mov ah,';'
          call ignblnk
          jnz fi1
          pop ax
          jmp runsml
fi1:      mov ah,0dh
          call ignblnk
          jnz fi2
          pop ax
          jmp runnxl         ;run next line
fi2:      ret         ;else return to caller
endchk:   mov ah,0dh         ;end with cr?
          call ignblnk
          jz fi2         ;ok, else say "what?"
qwhat:    push dx         ;****qwhat****
awhat:    mov dx,what         ;****awhat****
error:    salc ; ****error****
          call prtstg         ;print 'what?','how?'
          pop dx
          mov si,dx
          lodsb
          push ax         ;save the character
          salc ;and put a zero there
          mov di,dx
          stosb
          mov bx,[currnt]         ;get current line #
          or bx,bx         ;direct command?
          jz err2 
err1:     mov al,[bx]         ;iff negative,
          or al,al
          jns err1a
          jmp inperr         ;redo input
err1a:    call prtln         ;else print the line
          dec dx
          pop ax
          mov di,dx
          stosb         ;restore the char
          mov al,63         ;print a '?'
          call chrout
          salc ;and the rest of the
          call prtstg         ;line
err2:     jmp rstart
getln:    call chrout         ;****getln****
gl1:      mov dx,buffer-2
          push dx
          mov ah,bconin         ;buffered console input
          int 21h         ;call ms-dos
          push si
          mov si,dx
          inc si
          mov dl,byte [si]
          inc dx
          mov byte [strlen],dl
          pop si
          push ax
          mov al,[strlen]
          mov [fs:450h],al
          mov al,20h
          int 29h
          pop ax
ggp:      pop dx
          add dl,[buffer-1]
          add dx,3 ; was ;inc dx ;inc dx ;inc dx
          mov di,dx         ;for consistancy
          push dx
          call crlf         ;need crlf
          pop dx
          ret         ;we've got a line
fndln:    or bx,bx         ;at entry bx -> line # to be found, check sign of bx
          jns fnd1         ;it can't be -
          jmp qwhat ; was jmp qhow         ;error
fnd1:     mov dx,txtbgn
fndlnp:
fl1:      push bx         ;save line #
          mov bx,[txtunf]         ;check iff we passed end
          dec bx
          cmp bx,dx         ;substitute for call 4
          pop bx         ;get line # back
          jc ret13         ;c, nz passed end
          mov si,dx
          lodsw
          cmp ax,bx
          jc fl2
ret13:    ret         ;nc,z:found;nc,nz:not found
fndnxt:   inc dx                         ;****fndnxt****
fl2:      inc dx
fndskp:   mov si,dx
          lodsb         ;****fndskp****
          cmp al,0dh         ;try to find cr
          jnz fl2         ;keep looking
          inc dx
          jmp fl1         ;check iff end of text
prtstg:   mov ch,al         ;****prtstg****
ps1:      mov si,dx
          lodsb         ;get a char
          lahf                    ;preserve flags
          inc dx
          sahf                 ;restore flags
          cmp al,ch         ;same as old a?
          jz ps3         ;yes, return
ps2:      call chrout         ;else, print it
          cmp al,0dh         ;was it a cr?
          jnz ps1         ;no, next
ps3:      ret
qtstg:    mov ah,'"'
          call ignblnk
          jnz qt3
          mov al,34         ;it is a '"'
qt1:      call prtstg         ;print until another
          cmp al,0dh         ;was last one a cr?
          pop bx         ;return address
          jz runnxl ; was jnz qt2 ;was cr, run next line ;jmp     runnxl
qt2:      inc bx         ;fall-through if NZ skips two bytes on return!!!!
          inc bx
          jmp bx         ;jump to address in bx
qt3:      mov ah,39         ;is it a single quote (')?
          call ignblnk
          jnz qt4
          mov al,39         ;yes, do same
          jmp qt1         ;as in ' " '
qt4:      mov ah,'\'
          call ignblnk         ;is it back-slash?('\')
          jnz qt5
          mov al,141         ;yes, 0dh without lf!
          call chrout         ;do it twice
          call chrout         ;to give tty enough time
          pop bx         ;return address
          jmp qt2
qt5:      ret          ;none of the above
prtnum:   push dx         ;on entry bx = binary #,cl = # spaces
          mov dx,10         ;decimal
          push dx         ;save as a flag
          mov ch,dh         ;ch=sign
          dec cl         ;cl=spaces
          call chksgn         ;check sign
          jns pn1         ;no sign
          mov ch,45         ;ch=sign
          dec cl         ;'-' takes space
pn1:      push cx         ;save sign % space
pn2:      call divide         ;divide bx by 10 (in dx)
          or cx,cx         ;cx has quotient
          jz pn3         ;yes, we got all
          pop ax         ;get sign and space count
          push bx         ;save remainder
          dec al          ;dec space count
          push ax         ;save new sign and space count
          mov bx,cx         ;move result to bx
          jmp pn2         ;and divide by 10
pn3:      pop cx         ;we got all digits in
pn4:      dec cl         ;the stack
          mov al,cl         ;look at space count
          or al,al
          js pn5         ;no leading blanks
          mov al,32         ;leading blanks
          call chrout
          jmp pn4
pn5:      mov al,ch         ;print sign
          call chrout         ;maybe, or null
          mov dl,bl         ;last remainder in e
pn6:      mov al,dl         ;check digit in e
          cmp al,10         ;10 is flag for no more
          pop dx
          jz ret14         ;iff so, return
          add al,48         ;else convert to ascii
          call chrout         ;and print the digit
          jmp pn6         ;go back for more
prtln:    mov si,dx
          lodsw
          mov bx,ax
          inc dx
          inc dx         ;move pointer
prtln1:   mov cl,5         ;print 5 digit line #
          call prtnum
          mov al,32         ;followed by a blank
          call chrout
          salc ;and then the text
          call prtstg
ret14:    ret
mvup:     cmp dx,bx         ;***mvup***
          jz ret15         ;de = hl, return
          mov si,dx
          lodsb         ;get one byte
          mov di,cx
          stosb         ;move it
          inc dx
          inc cx
          jmp mvup         ;until done
mvdown:   cmp dx,cx
          jz ret15         ;yes, return
md1:      lahf
          dec dx
          dec bx
          mov si,dx
          lodsb         ;both pointers and
          mov [bx],al         ;then do it
          jmp mvdown         ;loop back
_popa:    pop cx         ;cx = return addr
          pop word [lopvar]         ;else, more to restore
          test word [lopvar],0ffffh
          jz pp1
          pop word [lopinc]         ;else, more to restore
          pop word [loplmt]         ;else, more to restore
          pop word [lopln]         ;else, more to restore
          pop word [loppt]         ;else, more to restore
pp1:      push cx         ;cx = return addr
ret15:    ret
_pusha:   mov bx,stklmt         ;****pusha****
          call chgsgn
          pop cx         ;cx=ret addr
          add bx,sp
          jc pushb         ;yes, sorry for that.
          jmp qwhat ; was jmp     qsorry
pushb:    test word [lopvar],0ffffh
          jz pu1
          push word [loppt]         ;else, more to save
          push word [lopln]         ;else, more to save
          push word [loplmt]         ;else, more to save
          push word [lopinc]         ;else, more to save
pu1:      push word [lopvar]         ;else, more to save
          push cx         ;cx = return addr
          ret
crlf:     mov al,0dh         ;****crlf****
chrout:   push cx         ;save cx on stack
          push dx         ;and dx
          push bx         ;and bx too
          mov [outcar],al    ; pusha  ; stack= cx|dx|bx  
          int 29h
          cmp al,0dh         ;was it a 'cr'?
          jnz done         ;no,done
          mov al,0ah ; add linefeed
          int 29h
done:     mov al,[outcar] ; put char back
idone:    pop bx         ;get h back
          pop dx         ;and d
          pop cx         ;then h
          ret         ;done at last
cout1:    cmp byte al,0      ; is it null?
          jz ret16           ; skip it
          stosb              ; store al (char) in buffer
          inc byte [buffer-1]; increment counter
ret16:    ret                ; done
ignblnk:  mov si,dx          ; ignblnk ; deblanks where dx-> ;  if (dx)=ah then dx:=dx+1
ign1:     lodsb              ; get char in al
          cmp al,32          ; ignore blanks
          jnz ign2           ; in text (where dx ->)
          inc dx
          jmp ign1
ign2:     cmp al,ah          ; is search character found at (dx)?
          jnz _ret           ; no, return, pointer (dx) stays
          lahf               ; save results of comparison
          inc dx             ; inc pointer if character matches
          sahf               ; return result of comparison to flags
_ret:     ret
finish:   pop ax
          call fin           ; check end of command
          jmp qwhat          ; print "what?" iff wrong
msg1      db '                                                                 '
          db '                             COPYLEFT WANG 1974 MUELLER 1976 SULL'
          db 'IVAN 1982 WTFPL POUDADE 2015                                     '
          db '                                                           ******'
          db '***** 2048-BYTE BASIC BY RED SECTOR INC. 2015 ************                                                                                                                      ',0dh
txtunf    dw txtbgn         ;-> unfilled text area
ks:       pusha
          mov al,20h; heart glyph
          test byte [fs:46ch],8h
          jz vbb
          mov al,0dbh ; block glyph
vbb:      int 29h     ; fast putch(al) 
          dec byte [fs:450h]
          popa
          iret
strlen    db 0
basicpal  db 5,4,12,14,10,13,6,15 ; rest 8 bytes unused/dontcare