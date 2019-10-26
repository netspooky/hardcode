;----------RED-SECTOR-INC.-proudly-presents-a-33-year-old-record-:----------
; 468-byte footprint___ _       "...The original chess game in a bootsector"
;                  /     /         _____ _ _      _____ _ _        ___ _
;     .::.        /     /         /     /  /     /     /  /       /     /
;     ::::       /     / ____  .-/   _ ___/-. .-/   _ ___/-.     /     /__
;      ::       /            \ |    |  .    | |    |  .    |    /        /
;      ::            __ _     \     l  |    | |    l  |    |   /     ___/
;     .::.    /     /   /     /     |  l    |_|    l  |    |__/     / ____
;    .::::.        / __/            `--'           `--'            /      |
;   ::::::::                /                               /             |
;                    ___ __    Cl!   ___ ___ /      ___ _ _             __|
;        ___ _ _    /   __/_ __  _ _/      _/_   _ /_  /  /        ___ /__
;     /_/   /  / / /   / /            _____/ /  / /    __/      _ /   /  /
;  .-/     ___/   /     /______         /      ___\    \___    / /    __/
;  |      /      /     /       |     __/ ___  |    \       |  ___\    \___
;  |     /  ____               |    /       | |   _/       | |    \       |
;  |    /--/    |     ___/     |            | |            | |   _/       |
;  |            |    /  /  ::  | ____/  ::  | |  ::  \_____| |            |
;  |_____/  ::  | __/  /_______|    /_______| |_______\      |  ::  \_____|
;       /_______|     /___ _       /___ _         _ ___\     |_______\
;      /___ _                                                    _ ___\ v.02
; BootChess is the smallest computer implementation of chess on any platform
; Chess in a 512-byte x86 boot sector for Windows / Linux / OS X / DOS / BSD
; Coded by Olivier "Baudsurfer/RSi" Poudade with extra help of Peter "QKumba"
; Ferrie. Logo by Frederic "Cleaner/Break" Cambus. (c)2015 WTFPL v2 license. 
; ****************** To Mr. Oscar Toledo and others : **********************
; YOU MAY REFACTOR THE RESULT OF OUR WORK (THIS FILE) BUT PLEASE CREDIT US !
; **************************************************************************
; "Fasm BootChess.asm" + "partcopy BootChess.bin 0 200 -f0" = PC floppy boot 
;-BootChess.asm-------------------;-----------------------------------------
; gui=0=>no board indexes, x86=1=>boot vs. dos,  p2q=1=>queening vs failsafe
gui equ 0           ; gui=1 x86=1 p2q=1 510b+ OK pad OK gui OK vbr- OK queen
x86 equ 0           ; gui=1 x86=1 p2q=0 498b+ OK pad OK gui OK vbr+ NO queen
p2q equ 0           ; gui=1 x86=0 p2q=1 504b  NO pad OK gui NO vbr- OK queen
_b  equ byte        ; gui=1 x86=0 p2q=0 485b  NO pad OK gui NO vbr+ NO queen
_w  equ word        ; gui=0 x86=1 p2q=1 479b+ OK pad NO gui OK vbr- OK queen
_d  equ dword       ; gui=0 x86=1 p2q=0 481b+ OK pad NO gui OK vbr+ NO queen
_s  equ short       ; gui=0 x86=0 p2q=1 487b  NO pad NO gui NO vbr- OK queen
_f  equ far         ; gui=0 x86=0 p2q=0 468b  NO pad NO gui NO vbr+ NO queen  
    if x86=1                      ; beg of boot vs .com preprocessing
    org 7c00h                     ; std start of bootsector after post
    if p2q=0                      ; beg clear any start ambiguous segment
    jmp _f 0:fix                  ; 7c0:0000 vs. 0:7c000 cs para fix-up
    end if                        ; end clear any start ambiguous segment  
fix:push cs                       ; if post int 19h isr bootsrap loader 
    pop ds                        ; left any bda or shadow segment values 
    push cs                       ; then enforce ds=cs=0  
    pop es                        ; then enforce es=ds=cs=0
    mov aX,13h                    ; function set vga mode 320x200x256
    else                          ; else if 16-bit binary assume ah=0
    org 100h                      ; start of com binary program ip
    mov aL,13h                    ; function set vga mode 320x200x256
    end if                        ; end of boot vs .com preprocessing
    int 10h                       ; standard bios video api
    if gui=1                      ; minimalist no coordinate indexes ?
    bf1 equ bf3                   ; chess board at end of sector
    else                          ; else show coordinate indexes
    bf1 equ bf2                   ; chess board at end of sector 
    end if                        ; end conditional precompile 
    brd equ bf1+16                ; chess board at end of sector
    mov di,brd                    ; set physical board index
    mov bp,12                     ; set 6x8+8 empty sqr mid board lines
    call in2                      ; pass#1 black "rnbqkbnr" low-caps
    push word opn                 ; pass#2 hi-caps whites & fall-through
rle:lodsb                         ; al='.'/al=null (fixed length rle)
    mov cl,8                      ; empty sqr mid board line length
    rep stosb                     ; set one empty sqr mid board line
    dec bp                        ; all empty sqr mid brd lines inited ?
    jnz rle                       ; if not repeat init else bp=0 assumed
    mov ah,'A'-'a'                ; fall-through pass#2 white hi-caps
in2:mov si,br0                    ; si points to endrank "rnbqkbnr" str
    if x86=0                      ; if .com binary environment ch=0
    mov cL,8                      ; "rnbqkbnr" endrank str length
    else                          ; assume nothing although tempting 
    mov cX,8                      ; "rnbqkbnr" endrank str length
    end if                        ; end of register ch startup value
in3:lodsb                         ; read physical board str car
    add al,ah                     ; hi-caps rank 1 / low-caps rank 8
    stosb                         ; write physical board str car
    loop in3                      ; all "rnbqkbnr" str car written ?
    mov cl,8                      ; si-;equiv piece vals di-;0x88 brd
    rep movsb                     ; write logical 0x88 board str vals
    retn                          ; return to callers
ge0:mov bx,di                     ; physical board idx (bx=brd)
    mov dh,'1'                    ; beg white move src rank
ge1:mov dl,'h'                    ; beg white move src file
ge2:mov [si],dx                   ; beg white move src str
    mov ch,'1'                    ; beg white move dst rank
ge3:mov cl,'h'                    ; beg white move dst file
ge4:mov [si+2],cx                 ; beg white move dst str
    pusha                         ; save all values
    call idx                      ; passive chess coords to linear indexes
    jbe  mis                      ; white move src color not conforming
    push bx                       ; save white move dst idx
    call ver                      ; white move legal chess ?
    pop bx                        ; restore white move dst idx
    jc mis                        ; white move not legal chess
    mov di,num+3                  ; compare move destination rank in 7dfeh 
    inc si                        ; with move source rank in 7dfch 
    cmpsb                         ; is taxi distance to topmost bettered ? 
    jnc wor                       ; else not getting closer to black king
    cmp _b [di],'?'               ; does any fallback move exist yet ?
    jz lkj                        ; no, then last valid move good enough
wor:mov aL,_b[si+bx+brd-num-'a'+6]; yes, previous valid legal exist so 
    dec aL                        ; only override if it's a capture 
    js mis                        ; no, don't want worse taxi distance  
    mov bx,fs                     ; it's a capture with piece value=al
    cmp bL,aL                     ; but hightest capture value yet ?
    jnc mis                       ; no, less important opponent piece 
max:mov fs,bx                     ; fs=best move yet in taxi half-ply
lkj:dec si                        ; realign source index 
    dec si                        ; to copy dword bst=dword idx 
    movsd                         ; after 4096 tries : move=dword bst
mis:popa                          ; restore all values
    cmp cl,'a'                    ; end white move dst file ?
    loopnz ge4                    ; dec white move else next dst file
    inc ch                        ; inc white move dst rank
    cmp ch,'9'                    ; end white move dst rank ?
    jnz ge3                       ; else next move dst rank
cpx:inc bx                        ; inc physical board index
    dec dx                        ; dec white move src file
    cmp dl,'`'                    ; end white move src file ?
    jnz ge2                       ; else next move src file
    inc dh                        ; inc white move src rank
    cmp dh,ch                     ; end white move src rank ? ch=9
    jnz ge1                       ; else next move src rank
    push _d [si+4]                ; get best white move found
    pop _d [si]                   ; set it as final white move
val:mov cl,'.'                    ; valid : empty sqr replaces src piece
    call act                      ; active chess coords to linear indexes
    xor bp,3                      ; player turn and pawn unidir. delta
    jz ge0                        ; white turn to play (case best=0)
bla:mov al,'?'                    ; input str clear pattern
    mov di,si                     ; input str clear pattern (di=num)
    mov cx,8                      ; input str clear pattern
    rep stosb                     ; input str clear pattern (di=brd)
    call key                      ; get user keyboard input
    jbe bla                       ; black move src color not conforming
opn:call ver                      ; di=brd, black move legal chess ?
    jc bla                        ; white move not legal chess
    jmp _s  val                   ; validate black move
ver:call idx                      ; get lin indexes /w implicit passive
    xchg bx,dx                    ; switch bx=dst idx dx=src idx
    mov ah,[si+bx+brd-num-'a'+8]  ; get piece logical 0x88 brd val...
    mov dh,bl                     ; dh=src idx dl=dst idx
    sub dx,"aa"                   ; get move file zero-based indexes
    bsr bx,ax                     ; scan for 1st bit set (si=idx+10)
    movsx bx,[si+bx-10-num+tab]   ; bl=moved piece type idx (bh=0)
    mov cx,_w [si+bx-num+tab]     ; piece type deltas cl=repeats ch=num
    sahf                          ; set piece logical 0x88 brd val  
    jnp sp1                       ; branch if piece not pawn (bit#4!=1)
    jc sp2                        ; branch if pawn prev moved (bit#0=1)
sp1:jns sp3                       ; branch if piece not king (bit#7!=1)
sp2:mov cl,1                      ; override repeat if piece pawn or king
sp3:jnp sp4                       ; branch if piece not pawn (bit#4!=1)
    add bx,bp                     ; pawn player turn unidirection mutex
sp4:inc bx                        ; advance piece type struct field ptr
    and ah,11111100b              ; isolate piece bitmask only 
vl1:push cx                       ; save piece type deltas
    mov al,dh                     ; load start dst idx val
    inc bx                        ; advance piece type struct field ptr
vl2:add al,[si+bx-num+tab]        ; add this piece delta to dst idx val
    xchg aL,bL                    ; base reg=dst idx val and preserved
    mov ch,[si+bx+brd-num+8]      ; read projected dst square val
    xchg aL,bL                    ; base reg=piece type struct field ptr
    cmp al,dl                     ; wanted move found (src+delta(s)=dst) ?
    jnz dif                       ; different than requested move
sam:sahf                          ; get piece logical 0x88 brd val in flgs
    jnp yes                       ; branch if piece is not pawn (bit#2=0)
    test [si+bx-num+tab],1        ; pawn piece delta parity=diag vs. vert
    jz ord                        ; branch if pawn piece moving vert
    test ch,ch                    ; pawn piece vert move=;eating ?
    jz _s bad                     ; illegal chess move is a miss
yes:pop cx                        ; correct entry sp and disregard count
    retn                          ; return to caller(s)
ord:test ch,ch                    ; pawn piece vert move=;no eating ?
    jz yes                        ; no eating=;empty dst sqr else illegal
dif:sahf                          ; store piece nature in flags register
    jnp skp                       ; not pawn piece so skip direction test
    test [si+bx-num+tab],1        ; pawn piece delta parity=diag vs. vert
    jnz bad                       ; diagonal pawn move is illegal
skp:test ch,ch                    ; else skipping over dst square val ?
    jnz bad                       ; projected dst sqr val is not empty
    sahf                          ; get piece logical 0x88 brd val in flgs
    jz x88                        ; branch if piece is queen (bit#6=1)
    jna bad                       ; branch if piece is not knight(bit#4=0)
x88:test al,88h                   ; ch=0 dst out of physical board limits?
    loopz vl2                     ; else cont if delta repeats remain
bad:pop cx                        ; restore piece type deltas
    dec ch                        ; all possible delta nums verified ?
    jnz vl1                       ; if not then cont next delta type
nok:stc                           ; else return /w no match flg set
    retn                          ; return to caller
key:call prt                      ; refresh screen to account input echo
    xor bx,bx                     ; bx=str idx=odd/even/alpha/num mutex
kbd:cbw                           ; fun blocking wait for keystroke (ah=0)
    int 16h                       ; std bios keybd api (ah=scan al=ascii)
esc:dec ah                        ; was esc key pressed to quit ?
    jnz car                       ; else default process key input
xit:if x86=1                      ; if x86 boot context environment
    int 19h                       ; exit through bootstrap to reboot cpu
    else                          ; else if .com 16-bit binary
    int 20h                       ; dos 1+ - terminate program
    end if                        ; end of exit methods (os load or shell)
car:mov [bx+si],al                ; sav ascii val to move string (si=num)
prt:pusha                         ; save game state snapshot
    cwd                           ; curs location dx=(0,0)=(row,column)
    mov ax,1301h                  ; function ega write str write mode 1
    mov bl,7                      ; page 0 grey car attrib matching tty
    mov cl,8                      ; src str lngth (curs updated horiz)
    if gui=1                      ; minimalist no coordinate indexes ?
    mov bp,bf1                    ; es:bp is "abcdefgh" ptr
    else                          ; else show coordinate indexes                     
    mov bp,bf1+16                 ; es:bp is dontcare ptr
    end if                        ; end of conditional precompile
lns:int 10h                       ; standard bios video api
    add bp,16                     ; bp=para step siz separating strings
    if gui=1                      ; minimalist no coordinate indexes ?  
    push ax                       ; save old bios video api func params
    mov ax,0e39h                  ; function teletype outp car=rank '9'
    sub al,dh                     ; decrement right handside rank value
    int 10h                       ; standard bios video api
    pop ax                        ; restore old bios video api fx params
    end if                        ; end of conditional precompile
    if gui=1                      ; minimalist no coordinate indexes ?
    cmp dh,cl                     ; src str total (curs updated vert)
    inc dh                        ; preemptive off-by-one allows 9 verts
    else                          ; else show coordinate indexes  
    inc dh                        ; non-preemptive off-by-one for 8 verts
    cmp dh,cl                     ; src str total (curs updated vert)
    end if                        ; end of conditional precompile 
    jc lns                        ; all 9 brd min row strings printed ?
    mov bp,si                     ; 10th row tail bp=move coords, cl=8
    int 10h                       ; standard bios video api
    popa                          ; restore game state snapshot
    inc bx                        ; test if any more keys ?
    cmp bl,4                      ; frFR format input string
    jc kbd                        ; else continue input 
idx:loop idx                      ; ch=0 passive call load src/dst lin idx
act:mov si,num                    ; reinit si to point to coord input str.
    mov bx,[si]                   ; bx=src coord (pass#1)
    cbw                           ; empty sqr val in logical 0x88 board
    call put                      ; place param passed as fun pass#1
    mov dx,[si+2]                 ; bx=dst idx dx=src idx
    xchg bx,dx                    ; fall-through for second pass
    push word mat                 ; test for checkmate and conforming
put:xchg ax,bx                    ; bx|dx=[num+di]+16*((8-'0')-[num+di+1])
    aad -10h                      ; shl ah,4/sub al,ah/xor ah,ah
    add al,80h                    ; bx|dx=al-640%256-16*ah
    xchg ax,bx                    ; bx|dx=al+128-16*ah
    jcxz sim                      ; active call request or simulation ?
    if p2q=1                      ; standard non-failsafe queening
    cmp _b [si+3],'8'             ; validated dst rank is top-most ?    
    jz qq                         ; if so then promote pawn to queen
    cmp _b [si+3],'1'             ; validated dst rank is bottom-most ?
    jnz prm                       ; if not no pawn queening promotion
qq: sahf                          ; store piece nature in flag register
    jnp prm                       ; no pawn queening promotion  
    xor ah,01000110b              ; transform p to promoted queen
    inc cx                        ; queen promotion p2q or P2Q
    end if                        ; end of conditional queening
prm:xchg ah,[si+bx+brd-num-'a'+8] ; update piece logical 0x88 board val
    xchg cl,[si+bx+brd-num-'a']   ; update piece physical board ascii val
    or ah,1                       ; update piece moved once (bit#0)
sim:retn                          ; return to caller(s)
mat:sahf                          ; catured piece king and mate ?
    js xit                        ; if piece is king then game is over
    call chk                      ; move src color conforming ?
    jnz nok                       ; move src color not conforming
chk:xchg bx,dx                    ; src idx <- dst idx
    mov al,[si+bx+brd-num-'a']    ; pass#1:src idx pass#2:dst idx di=brd
    xor _b [si+len-num],8         ; self-modif 8/26 val=[1;8]/[a(A);z(Z)]
    mov cl,-'a'                   ; assert black piece car interval
    test bp,bp                    ; test whose turn it is to play
    jnz lim                       ; assert white piece car interval
    mov cl,-'A'                   ; al=ascii value cl=-(lower boundery)
lim:xadd al,cl                    ; tmp=al+cl cl=al al=tmp +fall-trough
    db 0d4h                       ; aam <self-modified value>
len:db 12h                        ; ah=al/8 al%=8
    mov al,cl                     ; al=restored ascii value
    test ah,ah                    ; set/clear zf=0 success zf=1 failure
    retn                          ; return to caller(s) nb: destroys ah
tab db p-tab,r-tab,n-tab,b-tab    ; piece type mov offset array
    db q-tab,q-tab                ; note original 1K ZX Chess q=k trick
br0 db "rnbqkbnr",8,16,32,64,128  ; end rank pattern + beg piece values
    db 32,16,8,'p',4,'.',0,'.',0  ; end piece values + beg mid board reps
    db '.',0,'.',0,'P',4          ; ... end mid board reps
p   db 2,3,-10h,-15,-17,10h,15    ; bit#2 pf=04 p[6]=r[0] overlay
r   db 17,4,10h,-1h,-10h          ; bit#3 ??=08 r[5]=n[0] overlay
n   db 1,8,1fh,21h,12h,-0eh,-1fh  ; bit#4 af=16 n[9]=b[0] overlay
    db -21h,-12h                  ; ... end of knight moves list
b   db 0eh,4,-0fh,11h,-11h        ; bit#5 ??=32 b[5]=q[0] overlay
q   db 0fh,8                      ; bit#6 zf=64 k=q except k[0]=1
bf2 db 10h,11h,0fh,1h,-10h        ; queen/king moves list and gui base
    db -11h,-0fh,-1h              ; ... end of queen/king moves list
    if gui=1                      ; minimalist no coordinate indexes ?  
bf3 db "abcdefgh"                 ; gui file index string
    end if                        ; end of conditional queening
num db "e2e4"                     ; hardcoded Ruy Lopez opening
    if x86=1                      ; if x86 boot environment
    if p2q=0                      ; if vbr signature failsafe 
    times 510-($-$$) db 0         ; nul padding if necessary
    org 7df0h                     ; boot signature vbr/mbr standard offset
    sig db 55h,0aah               ; magic number no-endian boot signature
    else                          ; no vbr signature failsafe
    times 512-($-$$) db 0         ; nul padding if necessary
    end if                        ; end of conditional padding
    end if                        ; end of conditional failsafe signature