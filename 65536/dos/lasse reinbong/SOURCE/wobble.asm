;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
model flat,prolog
locals

.data

    dd 0
dhx dd 0
    dd 0
dhy dd 0
    dd 0
dhc dd 0
    dd 0
dvx dd 0
    dd 0
dvy dd 0
    dd 0
dvc dd 0
      dd 0
dvdhx dd 0
      dd 0
dvdhy dd 0
      dd 0
dvdhc dd 0
sebx dd 0
sedx dd 0
sebp dd 0
secx dd 0
sesi dd 0

count dd 0
ycount dd 0
xcount dd 0
source dd 0
sourcemap dd 0
dest dd 0
colormap dd 0

.code

public gtexturewobbler_

gtexturewobbler_ proc
  push ebp

  mov dest,eax
  mov sourcemap,ecx
  mov source,ebx
  mov colormap,edx

  mov ycount,25
@@yloop:

    mov xcount,40
  @@xloop:
      mov esi,sourcemap
      mov eax,[esi+012+0]
      mov ebx,[esi+012+4]
      mov edi,[esi+012+8]
      sub eax,[esi+000+0]
      sub ebx,[esi+000+4]
      sub edi,[esi+000+8]
      sar eax,3+8
      sar ebx,3+8
      sar edi,3+8
      mov dhx,eax
      mov dhy,ebx
      mov dhc,edi

      mov ecx,[esi+492+0]
      mov edx,[esi+492+4]
      mov ebp,[esi+492+8]
      sub ecx,[esi+000+0]
      sub edx,[esi+000+4]
      sub ebp,[esi+000+8]
      sar ecx,3+8
      sar edx,3+8
      sar ebp,3+8
      mov dvx,ecx
      mov dvy,edx
      mov dvc,ebp

      mov ecx,[esi+504+0]
      mov edx,[esi+504+4]
      mov ebp,[esi+504+8]
      sub ecx,[esi+492+0]
      sub edx,[esi+492+4]
      sub ebp,[esi+492+8]
      sar ecx,3+8
      sar edx,3+8
      sar ebp,3+8
      sub ecx,eax
      sub edx,ebx
      sub ebp,edi
      sar ecx,3
      sar edx,3
      sar ebp,3
      mov dvdhx,ecx
      mov dvdhy,edx
      mov dvdhc,ebp

      mov ecx,colormap
      mov ebx,source
      mov edi,dest
      mov bl,[esi+000+0+3]
      mov edx,[esi+000+0-1]
      mov bh,[esi+000+4+3]
      mov eax,[esi+000+4-1]
      mov ch,[esi+000+8+3]
      mov esi,[esi+000+8-1]
      mov ebp,dhy-2
      mov dl,byte ptr dhx+2
      mov dh,byte ptr dhy+2

      mov count,8
      @@block:

        mov sebp,eax
        mov sedx,edx
        mov secx,ecx
        mov sesi,esi
        mov sebx,ebx

        i=0
        rept 4
          mov cl,[ebx]
          mov al,[ecx]
          add edx,dhx-2
          adc bl,dl
          add eax,ebp
          adc bh,dh
          add esi,dhc-2
          adc ch,byte ptr dhc+2

          mov cl,[ebx]
          mov ah,[ecx]
        ife i eq 6
          add edx,dhx-2
          adc bl,dl
          add eax,ebp
          adc bh,dh
          add esi,dhc-2
          adc ch,byte ptr dhc+2
        endif
          mov [edi+i],ax
          i=i+2
        endm

        mov edx,sedx
        mov eax,sebp
        mov ecx,secx
        mov esi,sesi

        add edi,320

        mov ebx,dvdhx-2
        add dhx-2,ebx
        adc dl,byte ptr dvdhx+2
        add ebp,dvdhy-2
        adc dh,byte ptr dvdhy+2
        mov ebx,dvdhc
        add dhc,ebx

        mov ebx,sebx

        add edx,dvx-2
        adc bl,byte ptr dvx+2
        add eax,dvy-2
        adc bh,byte ptr dvy+2
        add esi,dvc-2
        adc ch,byte ptr dvc+2

      dec count
      jnz @@block

      add sourcemap,12
      add dest,8

    dec xcount
    jnz @@xloop

    add sourcemap,12
    add dest,320*8-320

  dec ycount
  jnz @@yloop

  pop ebp

  ret
endp

public wobblemorfer_
wobblemorfer_ proc
local fac1:dword, fac2:dword
  mov fac1,eax
  mov fac2,edx
  mov ecx,41*26*3
  sub esi,edi
  sub ebx,edi
@@lp:
    mov eax,[edi+esi]
    imul eax,fac1
    mov edx,[edi+ebx]
    imul edx,fac2
    add eax,edx
    mov [edi],eax
    add edi,4
  dec ecx
  jnz @@lp
  ret
endp

end
