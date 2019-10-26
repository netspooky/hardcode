
;dl = mask, ebx=x(8:8), ecx=y(8:8), esi=noisemap base out:eax=noise (8:16)
;fastnoise proc
fastnoise macro
        lea edi, [costab]
        xor eax, eax
        mov al, cl
        push dword ptr [edi+eax*4]
        xor al, 0ffh
        push dword ptr [edi+eax*4]
        mov al, bl
        push dword ptr [edi+eax*4]
        xor al, 0ffh
        push dword ptr [edi+eax*4] ;stack: !fx fx !fy fy
        mov cl, bh
        mov dh, dl
        and ecx, edx
        xor ebx, ebx
        mov al, [esi+ecx] ;n1
        inc cl
        and ecx, edx
        mov bl, [esi+ecx] ;n2
        mov edi, eax
        mov ebp, esp
       imul edi, dword ptr [ebp]
       imul ebx, dword ptr [ebp+4]
        add edi, ebx ;i1
        inc ch
        and ecx, edx
        mov al, [esi+ecx] ;n4
        xor ebx, ebx
        dec cl
        and ecx, edx
        mov bl, [esi+ecx] ;n3
       imul ebx, dword ptr [ebp]
       imul eax, dword ptr [ebp+4]
        add eax, ebx ;i2
       imul edi, dword ptr [ebp+8]
       imul eax, dword ptr [ebp+12]
        add eax, edi
        add esp, 16
endm

;ebx=x, ecx=y, esi=noisemap base  out:edx=noise
fastperlinnoise proc
        push ebp
        mov ebp, ecx        
        mov edi, 127 ;factor
        mov cl, 1 ;shifter
        mov dl, cl ;mask
        xor eax, eax
        @sumloop:
            pushad
            shl ebp, cl
            shl ebx, cl
            mov ecx, ebp
            push edi
            fastnoise
            pop edi
           imul eax, edi
            sar eax, 7
            add [esp+01ch], eax ;eax on stack
            popad
            inc cl
            add dl, dl
            inc dl
            shr edi, 1
        cmp cl, 7
        jb @sumloop
        sar eax, 17
        mov edx, eax 
        pop ebp
ret
fastperlinnoise endp

;eax=source/dest, edx=underlying
mixadd proc
     add al, dl
     jnc @nooverflow
         mov al, 0ffh
     @nooverflow:
ret
mixadd endp

;eax=source/dest, edx=underlying
mixxor proc
     xor al, 0ffh
     xor dl, 0ffh
    imul eax, edx
     sar eax, 8
ret
mixxor endp

;eax=source/dest, edx=underlying
mixmul proc
     xor al, 0ffh
    imul eax, edx
     sar eax, 8
ret
mixmul endp

;ebx=mixer function, [esi]=color component mul, [edi]=dest, edx=base
mixdown macro
     push edx
     xor eax, eax
     lodsb
    imul eax, edx
     sar eax, 6
     ;xor edx, edx
     mov dl, [edi]
     ;clamp eax!
     cmp ah, 0 ;cmp eax, 255
     jz @noclampeaxup 
         xor eax, eax
         dec al
     @noclampeaxup:
     call ebx
     stosb
     pop edx
endm

;[esi] control data (s8.0, u4:4), edx = pixel
bcadjust proc
      lodsb
      cbw
      cwde
      add edx, eax
      xor eax, eax
      lodsb
      imul edx, eax
      sar edx, 4
      ;clamp
      test edx, edx
      jns @nolow
         xor edx, edx
      @nolow:
      cmp dh, 0
      jz @nohigh
         xor edx, edx
         dec dl
      @nohigh:
ret
bcadjust endp

;esi=texture descriptor, edi=dest
synthtexture proc
   xor ecx, ecx
   @texs_y:
      xor ebx, ebx
      @texs_x:
         push esi
         lodsb
         @layerloop:
            pushad
            xor eax, eax
            lodsb            
            cmp al, 0
            jz @doperlin

            ;flare
            push ecx
            lodsb
            sub ebx, eax
            lodsb
            sub ecx, eax
            push ebx
            fild dword ptr [esp]
            fmul st(0), st(0)
            pop ebx
            push ecx
            fild dword ptr [esp]
            fmul st(0), st(0)
            pop ecx
            faddp st(1), st(0)
            fsqrt
            fchs
            fiadd i_127
            push edx
            fistp dword ptr [esp]
            pop edx
            pop ecx 
            jmp @doneplasma

            @doperlin:
            ;perlin noise
            lodsw
            push edi esi
            lea esi, [noisemap+eax*8]
            call fastperlinnoise ;destroys nearly everything
            pop esi edi

            @doneplasma:
            ;edx = our plasma value
            call bcadjust
            ;load color mixing function
            lodsb
            mov cl, al
            and al, 0111b
            mov ebx, colormixers[eax*4]
            ;solarize it
            and cl, dl
            test cl, cl
            jns @nosol
                xor dl, 0ffh
            @nosol:
            ;color compose with values at esi, and mix down to edi
            mov cl, 3
            @mixdownloop:
            mixdown
            loop @mixdownloop
            popad
            add esi, 9
         dec al
         jnz @layerloop
         ;do final b/c fixup
         xor edx, edx
         push ecx
         mov cl, 3
         @bcadjustloop:
         push esi
         mov dl, [edi]
         call bcadjust
         mov [edi], dl
         inc edi
         pop esi
         loop @bcadjustloop
         pop ecx
         inc edi
         pop esi
      inc bl
      jnz @texs_x
   inc cl
   jnz @texs_y
   ret
synthtexture endp
