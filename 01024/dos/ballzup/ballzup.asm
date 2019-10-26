; ---------------------------------------------------------------------------
; ballZup by matja for EFnet #asm compo 5 (1k demo, effect, or game)
; ---------------------------------------------------------------------------
; Remake of vector balls, this time with per-pixel depth buffer.
; Nothing else really special going on, dodgy FPU code stole all my bytes :P
; Assemble with NASM! (NASM forevAH!)
;
; Requirements -
; - DOS 2.0+, 384K of base ram, VGA/MCGA, mad fast chipz ;)
;
; Respectz and Greetz due (reverse MD5 hashed order) -
; wbear,Frenzy,benw,mboy,Scali,DAL9000,mcarp,med,Spec-Chum,katz3h,brain,
; hex86,Mortiis!,CoaXCable,Atomicfoo,MoMsN,Auroran,as,spASM,RedMercry,Kalms,
; vulture,razzi,TNSE,|nsomniac,TommyGun,Parazite,Zhenya,Spansh,sosay,czth,
; attack,Reptile4,sulphur,kawfee,ticker,xor,TasmBoy,nANDy,khaladan,iretd,
; auspex,Jakdaw,ETHry,Ravian,GooRoo,#asm,#coders(both),#ukscene,WIJ,CoolPhat
;
; flames to mat@dimebar.net plzthx
;
; * commented version *
;
; I've put comments on long FPU instruction sequences showing the
; FPU stack state after each instrucion has executed, where the leftmost
; value is st0 (stack top), eg.
;   fld1            ; 1         (st0 = 1)
;   fldpi           ; pi, 1     (st0 = pi, st1 = 1)
;   faddp st1, st0  ; pi+1      (st0 = pi+1)
;   fstp [mem]      ;           (empty)
;
; ---------------------------------------------------------------------------

org 0x100                         

SPHERE_SIZE         equ     64
FRAME_DEPTH_SEG     equ     0x0000
SPHERE_DEPTH_SEG    equ     0x4000

start:
    ; -------------------------------------------------------------
    ; Allocate buffers
    ; 256k depth buffer
    ;  64k sprite depth buffer
    ; -------------------------------------------------------------
    ; All memory is allocated to the program already by DOS, so we
    ; need to release everything except the program segment, and then
    ; allocate the extra memory we need.

    push ds
    pop es
    mov ah, 0x4a    ; resize  
    mov bx, 0x1000  ; to 64k  
    int 0x21
    mov ah, 0x48    ; alloc
    mov bx, 0x6000  ; 384k
    int 0x21
    jnc alloc_ok
    ret
alloc_ok:
    mov [buffers], ax

    ; -------------------------------------------------------------
    ; Set mode 13h and greyscale palette
    ; -------------------------------------------------------------

    mov ax, 0x13
    int 0x10
    xor ax, ax
    mov dx, 0x3c8
    ; <- out dx, al ; this was missing from my original ª_ª thanks Libthium :)
    inc dx
set_palette:
    out dx, al
    out dx, al
    out dx, al
    mov al, ah
    shr al, 2
    inc ah
    jnz set_palette

    ; initialise the fpu.
    ; it's usually in a usable state if our prog has been spawned by dos,
    ; but good practice to get everything we use into a known state.

    finit

    ; we need ds set to cs to get to our variables, by default cs=ds=es but
    ; this isn't guarenteed after we call int's, so set it again
    ; (could use cs: overrides of course, but that costs an extra byte
    ; per instruction that uses it)

    push cs  
    pop ds

    ; -------------------------------------------------------------
    ; Generate sphere depth values
    ; -------------------------------------------------------------
    ; the idea is to loop from -1 to 1, for both x and y (sg_x and sg_y),
    ; and calculate the depth value for every point on the unit sphere
    ; using (1 - sqrt(1 - (x*x + y*y))) * 65536
    ; sg_d is 2/SPHERE_SIZE

    fld1                        
    fchs
    fstp dword [sg_y]               ; sg_y = -1
    mov cx, SPHERE_SIZE             ; y-loop counter

    mov ax, [buffers]               ; get base of allocated memory
    add ax, SPHERE_DEPTH_SEG        ; get segment of sphere depth values
    mov es, ax               
    xor di, di                      ; point to start of segment

sg_l1:
    fld1
    fchs             
    fstp dword [sg_x]               ; sg_x = -1
    push cx
    mov cx, SPHERE_SIZE             ; x-loop counter

sg_l2:
    fld1                            ; 1           
    fld1                            ; 1, 1
    fld dword [sg_x]                ; x, 1, 1
    fmul st0, st0                   ; x*x, 1, 1
    fld dword [sg_y]                ; y, x*x, 1, 1
    fmul st0, st0                   ; y*y, x*x, 1, 1
    faddp st1,st0                   ; x*x+y*y, 1, 1
    fsubp st1,st0                   ; 1-x*x+y*y, 1
    fsqrt                           ; sqrt(1-x*x+y*y), 1
    fsubp st1,st0                   ; 1-sqrt(1-x*x+y*y)
    fmul dword [FPU_CONST_65535]    ; (1-sqrt(1-x*x+y*y))*65535
    fistp dword [es:di]             ; store as 32bit int
    add di, 4

    fld dword [sg_x]                ; sg_x = sg_x + sg_d 
    fadd dword [sg_d]
    fstp dword [sg_x]

    dec cx                          
    jnz sg_l2                       ; continue x-loop?

    pop cx
    fld dword [sg_y]                ; sg_y = sg_y + sg_d 
    fadd dword [sg_d]
    fstp dword [sg_y]

    dec cx                          
    jnz sg_l1                       ; continue y-loop?


main:
    ; -------------------------------------------------------------
    ; Main loop
    ; -------------------------------------------------------------
    ; start of a new frame...

    push cs                         
    pop ds

    call clear_depth_buffer

    ; initialise random seed, so random number function generates the same
    ; sequence for every frame

    mov dword [rand_seed], 0

    ; copy main_t to main_tt
    ; main_tt is the temporary time value that we will use to draw
    ; the sprites, it will go from main_t to main_tt + 2pi

    push cs
    pop ds
    mov eax, dword [main_t]
    mov dword [main_tt], eax

    ; -------------------------------------------------------------
    ; Update rotation values
    ; -------------------------------------------------------------

    fld dword [FPU_CONST_M0P5]
    fstp dword [main_ra]
    fld dword [main_t]
    fmul dword [FPU_CONST_1P4]
    fstp dword [main_rb]
    fld dword [main_t]
    fmul dword [FPU_CONST_1P2]
    fstp dword [main_rc]

    ; -------------------------------------------------------------
    ; Calculate and draw sprites
    ; -------------------------------------------------------------

    mov cx, 628                     ; 628 sprites, 1 every 0.01 radians
sprite_loop:
    push cx                         ; save loop counter for later

    ; -------------------------------------------------------------
    ; Generate 2 sets of x/y/z/scale values for current main_tt value
    ; -------------------------------------------------------------

    fld dword [main_tt]             ; push time value
    mov bx, main_x2                 ; point to vars to store x/y/z/scale
    call knot_func_0                ; calculate position
    fld dword [main_tt]             ; push time value
    mov si, bx                      ; save pointer for blend function later
    mov bx, main_x                  ; point to vars to store x/y/z/scale
    call knot_func_1                ; calculate position

    ; now interpolate between the 2 positions at bx and si, store to bx

    fld dword [main_t]              ; main_t
    fsin                            ; sin(main_t)
    fmul dword [FPU_CONST_0P5]      ; sin(main_t)*0.5
    fadd dword [FPU_CONST_0P5]      ; sin(main_t)*0.5+0.5

    ; blend = sin(main_t)*0.5+0.5
    ; doing this in a loop for each component saves some bytes ... 

    fld1                            ; 1, blend
    fsub st0, st1                   ; 1-blend, blend
    mov bp, 4
blend_loop:
    fld dword [bx]                  ; x1, 1-blend, blend
    fmul st0, st1                   ; x1*(1-blend), 1-blend, blend
    fld dword [si]                  ; x2, x1*(1-blend), 1-blend, blend
    fmul st0, st3                   ; x2*blend, x1*(1-blend), 1-blend, blend
    faddp st1, st0                  ; x2*blend+x1*(1-blend), 1-blend, blend
    fstp dword [bx]                 ; 1-blend, blend
    add bx, 4
    add si, 4
    dec bp
    jnz blend_loop
    fstp st0                        ; remove 1-blend
    fstp st0                        ; remove blend

    ; -------------------------------------------------------------
    ; Rotate x/y/z arround y, x, then z
    ; -------------------------------------------------------------
    ; Using a generic rotate function saves some bytes

    mov si, main_x
    mov di, main_z
    fld dword [main_rb]
    call rotate
    mov si, main_y
    mov di, main_z
    fld dword [main_ra]
    call rotate
    mov si, main_x
    mov di, main_y
    fld dword [main_rc]
    call rotate
    fld dword [main_z]
    fld st0

    ; -------------------------------------------------------------
    ; View transform follows ...
    ; Various magic numbers to get everything to fit on screen
    ; -------------------------------------------------------------

    ; add an offset to the z, basically gives the effect of a camera
    ; in the -z direction
    ; main_biasedz = main_z + 10

    fadd dword [FPU_CONST_10]
    fstp dword [main_biasedz]

    ; sprite_size = (5 / main_biasedz) * main_scale;

    fld dword [FPU_CONST_5]
    fdiv dword [main_biasedz]
    fmul dword [main_scale]
    fstp dword [main_sprite_size]

    ; calculate screen coordinates of sprite
    ; screen_x = ((x/biasedz)*screen_scale + SCREEN_WIDTH/2) - (SPHERE_SIZE/2)

    fld dword [main_x]
    fdiv dword [main_biasedz]
    fmul dword [main_screen_scale]
    fadd dword [SCREEN_WIDTH_OVER_2]
    fld dword [main_sprite_size]
    fimul word [SPHERE_SIZE_W]
    fmul dword [FPU_CONST_0P5]
    fsubp st1, st0
    fistp dword [main_screen_x]

    ; screen_y = ((x/biasedz)*screen_scale + SCREEN_WIDTH/2) - (SPHERE_SIZE/2)

    fld dword [main_y]
    fdiv dword [main_biasedz]
    fmul dword [main_screen_scale]
    fadd dword [SCREEN_HEIGHT_OVER_2]
    fld dword [main_sprite_size]
    fimul word [SPHERE_SIZE_W]
    fmul dword [FPU_CONST_0P5]
    fsubp st1, st0
    fistp dword [main_screen_y]

    ; calculate arguments to pass to put_sprite_depth_scale function ...
    ; first is psds_offset, which is the pixel offset in the depth buffer
    ; where the top-left of the sprite should be written
    ; psds_offset = main_screen_x + main_screen_y * 320

    mov eax, dword [main_screen_y]
    imul ax, 320
    add eax, dword [main_screen_x]
    mov [psds_offset], ax

    mov eax, [main_sprite_size]
    mov [psds_scale], eax

    ; z value still in st0, multiply by 65535 so we can store it as an
    ; integer in the depth buffer.
    ; (65535 is only chosen because we already have that float constant
    ; in memory, and it gives enough depth precision)    

    fmul dword [FPU_CONST_65535]
    fistp dword [psds_depth]

    ; args setup, write the sprite to the depth buffer

    call put_sprite_depth_scale

    ; function has changed ds, make it point back to program vars so
    ; we can access the vars without a cs: override

    push cs
    pop ds

    ; increment main_tt by 0.01 for the next sprite calc

    fld dword [main_tt]
    fadd dword [FPU_CONST_0P01]
    fstp dword [main_tt]

    ; restore loop counter from stack, decrement, and check if we need
    ; to continue.  jz/jmp is used instead of a single jnz because
    ; the label (sprite_loop) is out of range (128 bytes)
    
    pop cx                          
    dec cx
    jz  sprite_loop_skip
    jmp sprite_loop
sprite_loop_skip:

    ; increment main_t by 0.01 for the next frame
    ; (this is bad form, we should read a realtime counter and calculate
    ; main_t from that so that the effect runs in the same time
    ; regardless of machine speed, but, no space to fit that :(

    fld dword [main_t]
    fadd dword [FPU_CONST_0P01]
    fstp dword [main_t]

    ; copy our work to the screen

    call display_depth_buffer

    ; check if any keys are pressed, if so, exit loop
    ; we use 2 jumps here instead of a single jz because the
    ; main: label is out of range of a conditional jump (128 bytes)

    mov ah, 1                       
    int 0x16
    jnz main_skip                 
    jmp main                   
main_skip:

    ; switch back to textmode

    mov ax, 3
    int 0x10

exit:
    ; exit to dos

    mov ax, 0x4c00
    int 0x21
    ret                     ; paranoid


; -----------------------------------------------------------------
; Generic rotation function
; -----------------------------------------------------------------
; On entry -
; st0 = angle (r)
;   [si] = x
;   [di] = y
; on exit -
;   [si] = x*cos(r) + y*-sin(r)
;   [di] = x*sin(r) + y*cos(r)

rotate:
    fsincos                 ; cos(r), sin(r)
    fld st1                 ; sin(r), cos(r), sin(r)
    fchs                    ; -sin(r), cos(r), sin(r)
    fmul dword [di]         ; y*-sin(r), cos(r), sin(r)
    fld st1                 ; cos(r), y*-sin(r), cos(r), sin(r)
    fmul dword [si]         ; x*cos(r), y*-sin(r), cos(r), sin(r)
    faddp st1, st0          ; x*cos(r)+y*-sin(r), cos(r), sin(r)
    fld dword [si]          ; x, x*cos(r)+y*-sin(r), cos(r), sin(r)
    fxch st1                ; x*cos(r)+y*-sin(r), x, cos(r), sin(r)
    fstp dword [si]         ; x, cos(r), sin(r)
    fmulp st2, st0          ; cos(r), x*sin(r)
    fmul dword [di]         ; y*cos(r), x*sin(r)
    faddp st1, st0          ; y*cos(r)+x*sin(r)
    fstp dword [di]                                  
    ret

; -----------------------------------------------------------------
; Random balls generation function
; -----------------------------------------------------------------
; On entry -
;   bx = address of x/y/z/scale to fill
;   st0 = time value
; *must pop value from fpu stack before return*
; x = sin(t+frand())
; y = cos(t+frand())
; z = cos(t+frand())
; scale = 0.4;

knot_func_0:
    call get_rand
    fadd st0, st1
    fsin
    fstp dword [bx]

    call get_rand
    fadd st0, st1
    fsin
    fstp dword [bx+4]

    call get_rand
    faddp st1, st0
    fsin
    fstp dword [bx+8]

    fld dword [FPU_CONST_0P4]
    fstp dword [bx+12]

    ret



; -----------------------------------------------------------------
; generate random floating point number from 0 to 2pi
; -----------------------------------------------------------------
 
get_rand:
    ; first generate a random 32bit number ...

    mov eax, [rand_seed]
    imul eax, eax, 0x343fd
    add eax, 0x269ec3
    mov [rand_seed], eax

    ; convert low-order word to 0-2pi, return in st0

    fild word [rand_seed]
    fdiv dword [FPU_CONST_65535]
    fldpi
    fadd st0, st0
    fmulp st1, st0
    ret


; -----------------------------------------------------------------
; Function to generate a toroidal helix
; -----------------------------------------------------------------
; On entry -
;   bx = address of x/y/z/scale to fill
;   st0 = time value
; *must pop value from fpu stack before return*
;
; x = ((3+sin(16*t))*cos(t))*0.4
; y = (cos(16*t))*0.4
; z = ((3+sin(16*t))*sin(t))*0.4
; scale = 0.4

knot_func_1:
                                    ; t
    fld dword [FPU_CONST_0P4]       ; 0.4, t
    fld dword [FPU_CONST_16]        ; 16, 0.4, t
    fmul st0, st2                   ; 16*t, 0.4, t
    fsincos                         ; cos(16*t), sin(16*t), 0.4, t
    fxch st1                        ; sin(16*t), cos(16*t), 0.4, t
    fadd dword [FPU_CONST_3]        ; 3+sin(16*t), cos(16*t), 0.4, t
    fmul st0, st2                   ; (3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fld st3                         ; t, (3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fsincos                         ; cos(t), sin(t), (3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fmul st0, st2                   ; cos(t)*(3+sin(16*t))*0.4, sin(t), (3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fstp dword [bx]                 ; sin(t), (3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fmulp st1, st0                  ; sin(t)*(3+sin(16*t))*0.4, cos(16*t), 0.4, t
    fstp dword [bx+8]               ; cos(16*t), 0.4, t
    fmul st0, st1                   ; 0.4*cos(16*t), 0.4, t
    fstp dword [bx+4]               ; 0.4, t
    fstp st1                        ; 0.4
    fstp dword [bx+12]
    ret


; -----------------------------------------------------------------
; Draw scaled sprite to depth-buffer
; -----------------------------------------------------------------
; On entry -
; [psds_offset] = depth buffer pixel offset (16bit)
; [psds_scale] = scale (32bit float, 1.0 = original size)

put_sprite_depth_scale:

    push cs
    pop ds

    fld1                            ; 1
    fdiv dword [psds_scale]         ; 1/psds_scale
    fst dword [psds_ooscale]        ; psds_ooscale = 1/psds_scale
    fmul dword [FPU_CONST_65535]    ; (1/psds_scale)*65535
    fistp dword [psds_idx]          ; psds_idx = (1/psds_scale)*65535
    fild word [psds_ssize]          ; psds_ssize
    fmul dword [psds_scale]         ; psds_ssize*psds_scale
    fistp word [psds_newsize]       ; psds_newsize = psds_ssize*psds_scale
    fldz                            ; 0
    fstp dword [psds_yoscale]       ; psds_yoscale = 0

    mov ax, word [buffers]
    add ax, SPHERE_DEPTH_SEG
    mov es, ax                      ; es = sphere depth values

    ; Problem here is the that the depth buffer we write to is 256k,
    ; and the depth values we are going to write can span segments,
    ; we want to avoid code to check for that (for speed and size), so
    ; make a segment:offset pair where we can start writing by
    ; working out the linear address and then converting to seg:ofs.
    ; This limits the biggest sprite we can draw to 51 pixels high. 

    movzx edx, word [buffers]
    shl edx, 4
    movzx eax, word [psds_offset]
    shl eax, 2
    add edx, eax
    mov di, dx
    and di, 0xf
    shr edx, 4              
    mov gs, dx                      ; gs:di = depth buffer write start 

    xor cx, cx
    
psds_l1:
    push cx

    fld dword [psds_yoscale]
    fistp dword [temp_32]
    mov eax, [temp_32]
    mul dword [psds_ssize]

    shl eax, 2
    mov bx, ax

    xor eax, eax
    mov cx, [psds_newsize]
    push di
psds_l2:
    push eax
    shr eax, 16
    shl eax, 2
    mov si, ax
    cmp dword [es:bx+si], 0x80000000
    je psds_skip
    mov edx, [es:bx+si]
    add edx, [psds_depth]
    cmp edx, [gs:di]
    jg psds_skip
    mov [gs:di], edx
psds_skip:
    pop eax
    add eax, [psds_idx]
    add di, 4
    dec cx
    jnz psds_l2

    pop di
    add di, 1280

    fld dword [psds_yoscale]
    fadd dword [psds_ooscale]
    fstp dword [psds_yoscale]

    pop cx
    inc cx
    cmp cx, [psds_newsize]

    jnz psds_l1

    ret


; -----------------------------------------------------------------
; Display depth buffer to screen
; -----------------------------------------------------------------
; For every value in depth buffer -
;   screen = depth * -0.00078 + 128

display_depth_buffer:
    mov cx, 4                       ; depth buffer spans 4 segments
    xor di, di                      ; point to beginning of vga segment
    mov ax, [buffers]
    push word 0xa000
    pop es
ddb_l1:
    xor si, si                      ; point to beginning of depth segment
    push cx
    push ax
    mov gs, ax
    mov cx, 0x4000                  ; 0x4000 depth dwords to read
ddb_l2:
    fild dword [gs:si]              ; depth
    fmul dword [FPU_CONST_M0P00078] ; depth * -0.00078
    fadd dword [FPU_CONST_128]      ; depth * -0.00078 + 128
    fistp dword [temp_32]           ; store
    mov eax, [temp_32]
    mov [es:di], al
    add si, 4
    inc di
    dec cx
    jnz ddb_l2
    pop ax
    pop cx
    add ax, 0x1000
    dec cx
    jnz ddb_l1
    ret


; -----------------------------------------------------------------
; Clear depth buffer
; -----------------------------------------------------------------
; Write large (far) z values to depth buffer so that small (closer)
; values can be written to it for the next frame

clear_depth_buffer:
    mov dx, [cs:buffers]
    mov es, dx
    mov cx, 4                   
    mov eax, 400000         ; conveniently makes a nice dark grey
cdb_l1:
    push cx
    mov cx, 0x4000
    xor di, di
    rep stosd
    add dx, 0x1000
    mov es, dx
    pop cx
    dec cx
    jnz cdb_l1
    ret


; -----------------------------------------------------------------
; Initialised vars and consts
; -----------------------------------------------------------------
; Constants we use ...
; Remembering to keep manual note of their sizes and format cause
; NASM won't automatically do that ;(

FPU_CONST_M0P5          dd -0.5
FPU_CONST_1P2           dd 1.2
FPU_CONST_1P4           dd 1.4
FPU_CONST_5             dd 5.0
FPU_CONST_10            dd 10.0
FPU_CONST_0P5           dd 0.5
FPU_CONST_65535         dd 65535.0
FPU_CONST_0P01          dd 0.01
FPU_CONST_0P4           dd 0.4
FPU_CONST_3             dd 3.0
FPU_CONST_16            dd 16.0
FPU_CONST_M0P00078      dd -0.00078
FPU_CONST_128           dd 128.0
SCREEN_WIDTH_OVER_2     dd 160.0
SCREEN_HEIGHT_OVER_2    dd 100.0
sg_d                    dd 0.03125
psds_ssize              dw SPHERE_SIZE
main_screen_scale       dd 500.0
SPHERE_SIZE_W           dw 64

; main time var, starts at 0

main_t                  dd 0.0


; -----------------------------------------------------------------
; Unintialised variables
; -----------------------------------------------------------------
; Temporary vars, arguments to funcs, args returned from funcs, etc.
; The .com doesn't contain these values, so we can't guarentee their
; values.  That's no problem because we already write to these before
; they are read back.

segment .bss

buffers             resw 1

temp_16             resw 1
temp_32             resd 1

sg_x                resd 1
sg_y                resd 1

main_x              resd 1
main_y              resd 1
main_z              resd 1
main_scale          resd 1
main_biasedz        resd 1
main_tt             resd 1

main_x2             resd 1
main_y2             resd 1
main_z2             resd 1
main_scale2         resd 1

main_ra             resd 1
main_rb             resd 1
main_rc             resd 1
main_nx             resd 1
main_ny             resd 1
main_nz             resd 1

main_screen_x       resd 1
main_screen_y       resd 1
main_sprite_size    resd 1
main_dboffset       resd 1

psds_newsize        resw 1
psds_idx            resd 1
psds_offset         resw 1
psds_yoscale        resd 1
psds_ooscale        resd 1
psds_depth          resd 1
psds_scale          resd 1

rand_seed           resd 1

; ---------------------------------------------------------------------------

