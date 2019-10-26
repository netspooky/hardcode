format binary
org 100h

    mov    ah, 2
    xor    bx, bx
    xor    dl, dl
    mov    dh, 10
    int    10h

    mov    bl, 0FFh
start:
    mov    ah, 9
    mov    dx, text
    int    21h

@loop:    
    mov   dx, 3DAh
retr2:
    in	  al, dx
    and   al, 8
    jnz   retr2    
retr1:
    in	  al, dx
    and   al, 8
    jz	  retr1
    
    mov    dl, 0C8h
    xor    ax, ax
    out    dx, al
    inc    dl
    mov    al, bl
    out    dx, al
    out    dx, al
    out    dx, al
    neg    bl

    hlt
    
    mov    ah, 1
    int    16h
    jz     @loop
    
    ret
    
text:
file "CALLNOW!.inc"