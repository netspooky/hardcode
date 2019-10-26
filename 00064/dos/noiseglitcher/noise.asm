; noiseglitcher 58b by Artem Vasilev | wormsbiysk | WBC ^ LSA
; for Chaos Constructions 2014 PC 256 bytes intro compo
; needs Covox on LPT1 for some noise from speakers
; best sound under DOSBox (on real DOS you can hear only single tone)

format binary
org    100h

start:
    mov   bh, 0A0h
    mov   es, bx
    
    mov   al, 13h
    int   10h

    mov   ch, 1
    xor   ax, ax
    mov   dx, 3C8h
    out   dx, al
    inc   dx

@palloop:
    out   dx, al
    out   dx, al
    out   dx, al
    inc   al
    loop  @palloop

scrloop:
    mov   dl, 78h
    xor   di, bx
@loop:
    stosb
    add   di, 320
    out   dx, al
    inc   ax
    loop  @loop

;   wait for retrace
    mov   dl, 0DAh
retr1:
    in	  al, dx
    and   al, 8
    jz	  retr1
retr2:
    in	  al, dx
    and   al, 8
    jnz   retr2

    inc   bx
    dec   cx

    mov   ah, 1
    int   16h
    jz	  scrloop

    ret