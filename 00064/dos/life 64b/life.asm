;; Life 64B
;; Whizart 26 September 2013

org 100h

push 0b800h                    ; set ds and es to start of video memory
pop ds
push ds
pop es

start:                         ; copy from working place to video memory
    xor di, di                 ; actual page has 4000B, but 4096 is ok for
    mov ch, 8                  ; optimization; thus: b800:1000 -> b800:0000
    rep movsw                  ; si = 4096 from below

%ifdef scroll
    %ifdef gliders
        mov ax, 800h           ; birth of the gliders; has > 64B :(
    %endif

    stosw                      ; for pseudo scrolling and creation of new life
%endif

xor si, si                     ; si = 0; note: di = 4096 from above
mov ch, 8                      ; process for (2048 instead of) 2000 characters

nextgen:                       ; calculating new generation of cells
    lea bx, [si-320]
    mov ax, 3
    cwd                        ; dx = 0
    
    line:
        add bx, 160
        add dx, [bx-2]         ; add 1000h for each living neighbor
        add	dx, [bx]
        add	dx, [bx+2]
        dec ax
        jnz line               ; ax == 0 below

    cmp dh, 20h                ; 10h per neighbor
    jle cellout
    sub dx, [si]               ; take into account whether cell is alive
    cmp dh, 40h
    jge cellout
    mov ah, 10h                ; background blue, foreground black, char 00

cellout:
    stosw
    lodsw                      ; for si += 2 in 1B
    loop nextgen


in al, 60h

%ifdef scroll
    dec ax                     ; enough change for ah == 00 in this version
%else
    dec al
%endif

jnz start
ret
