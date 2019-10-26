; fhofr - 106b\128b trash-intro for cc2oi5 by wbc \\ b-state 2q.o8.7df
; yeah, compofiller - wait for more c00ler intros on function'15! ;)
; greets to everyone

slow   equ 0   ; change for 1 for slower version 
               ; (if former flies out on your machine)
               ; i.e on my p200mmx fast version works on 70fps
               ; and slow is really sloooooooooooooweeeeeeeeeeeeeerrrrr... %)

format binary
org    100h

start:
    cld
    mov   bh, 0A0h
    mov   es, bx
    
    mov   bh, 80h
    mov   ds, bx      ;buffer1
if slow = 0
    mov   bh, 70h
    mov   fs, bx      ;buffer2
end if
    mov   al, 13h
    int   10h
    
    mov   dx, 3C8h
    xor   ax, ax
    out   dx, al
    inc   dl
    mov   cx, 256
    xor   bx, bx
@palloop:
    mov   al, bl
    shr   al, 2
    out   dx, al
    out   dx, al
    out   dx, al
    inc   bl
    loop  @palloop
    
    ;assume BX = 0, CX = 0 (coincidence? i don't think so ;)
    xor   ax, ax
@clrloop:
    mov   byte [ds:bx], al
if slow   
    mov   byte [es:bx], al
else
    mov   byte [fs:bx], al
end if
    inc   bx
    loop  @clrloop
    
    xor   bp, bp
mainloop:    
    mov   dl, 0DAh
retr2:
    in	  al, dx
    and   al, 8
    jnz   retr2    
retr1:
    in	  al, dx
    and   al, 8
    jz	  retr1
 
if slow = 0
    xor   di, di
    mov   cx, 16000
@fliploop:
    mov   eax, dword [fs:di]
    stosd
    loop  @fliploop
end if
    
    mov   ax, bp
    mov   di, 32160
    mov   byte [ds:di], al
    mov   di, 320
    mov   cx, 64000 - 320*2
    
@pixloop:
    mov   al, [ds:di]
    xor   al, [ds:di-320]
    xor   al, [ds:di+320]
    xor   al, [ds:di-1]
    xor   al, [ds:di+1]
if slow
    stosb
else
    mov   [fs:di], al
    inc   di
end if
    loop  @pixloop

if slow    
    push  es
else
    push  fs
end if    
    push  ds
if slow    
    pop  es
else
    pop  fs
end if 
    pop   ds
    
    inc   bp
    
    mov   ah, 1
    int   16h
    jz	  mainloop
    
    ret

; phew ;) 
    