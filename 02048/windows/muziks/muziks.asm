        EXTERN __imp__midiOutOpen@20
        %define midiOutOpen [__imp__midiOutOpen@20]
        EXTERN __imp__midiOutClose@4
        %define midiOutClose [__imp__midiOutClose@4]
        EXTERN __imp__midiOutShortMsg@8
        %define midiOutShortMsg [__imp__midiOutShortMsg@8]
        EXTERN __imp__GetTickCount@0
        %define GetTickCount [__imp__GetTickCount@0]
        EXTERN __imp__Sleep@4
        %define Sleep [__imp__Sleep@4]
        EXTERN __imp__SetThreadPriority@8
        %define SetThreadPriority [__imp__SetThreadPriority@8]
        EXTERN __imp___beginthread
        %define _beginthread [__imp___beginthread]

        segment .bss USE32

hMidi:  resd 1
tsdiv:  resw 1
tracks: resw 1
ptrs:   resd 256
eptrs:  resd 256
cpos:   resd 256
timers: resd 256
rcmds:  resb 256
buff:   resb 256
mdata:  resd 64
fpubuf: resb 108
gdret:  resd 1
gdst:   resd 1
gdch:   resd 1
gdfade: resd 1
dtime:  resd 1
tune:   resd 1
playing:resb 1

        segment .data USE32

bpm:    dd 7A120h
ddiv:   dw 1000

        segment .code USE32 

        GLOBAL _mGetData@12
_mGetData@12:
        pop dword [gdret]
        pop dword [gdst]
        pop dword [gdch]
        pop dword [gdfade]
        push dword [gdret]
        pusha
        call GetTickCount
        mov edi,[gdst]
        mov esi,mdata
        mov ebx,[gdch]
        dec ebx
        shl ebx,4
        add esi,ebx
        mov ecx,2
        rep movsd
        fsave [fpubuf]
        fild dword [gdfade]
        fidiv dword [esi]
        mov ebx,eax
        lodsd
        lodsd
        sub ebx,eax
        mov [gdfade],ebx
        fidivr dword [gdfade]
        fisubr dword [esi-8]
        fistp dword [gdfade]
        frstor [fpubuf]
        mov eax,[gdfade]
        cmp eax,0
        jns gdskip
        xor eax,eax
gdskip: stosd
        popa
        ret

        GLOBAL _mPlay@4
_mPlay@4:
        pop dword [gdret]
        pop dword [tune]
        push dword [gdret]
        pusha
        xor eax,eax
        push eax
        push eax
        push eax
        dec eax
        push eax
        push hMidi
        call midiOutOpen
        mov esi,[tune]
        add esi,byte 10
        lodsw
        xchg ah,al
        mov [tracks],ax
        movzx ecx,ax
        lodsw
        xchg ah,al
        mov [tsdiv],ax
        mov edi,ptrs
        mov ebx,eptrs
tloop:  lodsd
        lodsd
        bswap eax
        xchg eax,esi
        stosd
        add eax,esi
        xchg ebx,edi
        stosd
        xchg ebx,edi
        xchg eax,esi
        loop tloop
        mov esi,ptrs
        mov edi,cpos
        mov ecx,256
        rep movsd
        call GetTickCount
        mov edi,timers
        mov ecx,256
        rep stosd
        mov edi,mdata
        mov ecx,64
        xor eax,eax
        rep stosd
        mov byte [playing],1
        push eax
        push eax
        push _play
        call _beginthread
        add esp,12
        push dword 15
        push eax
        call SetThreadPriority
        popa
        ret

        GLOBAL _mStop@0
_mStop@0:
        mov byte [playing],0
        ret

_play:
cont:   movzx ecx,word [tracks]
        xor edx,edx
        dec edx
tsl2:   mov esi,[cpos+4*ecx-4]
        cmp [eptrs+4*ecx-4],esi
        jbe cont2
        xor ebx,ebx
        xor eax,eax
tsl:    shl ebx,7
        or ebx,eax
        lodsb
        btr eax,7
        jc tsl
        shl ebx,7
        or ebx,eax
        mov [dtime],ebx
        fild dword [bpm]
        fidiv word [tsdiv]
        fimul dword [dtime]
        fidiv word [ddiv]
        fistp dword [dtime]
        mov ebx,[timers+4*ecx-4]
        add ebx,dword [dtime]
        cmp edx,ebx
        jc cont2
        mov edx,ebx
        mov edi,ecx
cont2:  loop tsl2
        cmp edx,0FFFFFFFFh
        jne skip
        mov esi,ptrs
        mov edi,cpos
        mov ecx,256
        rep movsd
        call GetTickCount
        mov edi,timers
        mov ecx,256
        rep stosd
        jmp cont
skip:   dec edi
        push edx
        push edi
        call GetTickCount
        pop edi
        pop edx
        mov ebx,edx
        sub edx,eax
        jbe cont3
        push dword 1
        call Sleep
        cmp byte [playing],0
        jne _play
        push hMidi
        call midiOutClose       
        ret
cont3:  mov [timers+4*edi],ebx
        mov esi,[cpos+4*edi]
        xor eax,eax
tss:    lodsb
        bt eax,7
        jc tss
        lodsb
        bt eax,7
        jc norun
        dec esi
        mov al,[rcmds+edi]
norun:  mov [rcmds+edi],al
        mov bl,al
        and bl,0F0h
        cmp bl,0F0h
        je near syscmd
        cmp bl,0C0h
        je skip2
        cmp bl,0D0h
        je skip2
        shl eax,8
        lodsb
skip2:  shl eax,8
        lodsb
        cmp bl,90h
        jne nobeat
        push eax
        shl eax,8
        bswap eax
        mov ebx,eax
        mov ecx,0Fh
        and ebx,ecx
        mov edx,ebx
        shl edx,4
        inc ebx
        mov [mdata+edx],ebx
        mov ebx,eax
        shr ebx,8
        mov cl,0FFh
        and ebx,ecx
        mov [mdata+edx+4],ebx
        mov ebx,eax
        shr ebx,16
        and ebx,ecx
        mov [mdata+edx+8],ebx
        mov ebx,[timers+4*edi]
        mov [mdata+edx+12],ebx
        pop eax
nobeat: shl eax,8
        bswap eax
        cmp al,0
        jne send
        shr eax,8
send:   mov [cpos+4*edi],esi
        push eax
        push dword [hMidi]
        call midiOutShortMsg
        jmp cont
syscmd: cmp al,0FFh
        je sysc
        cmp al,0F0h
        je sysc
        mov [cpos+4*edi],esi
        jmp cont
sysc:   push edi
        mov edi,buff
        stosb
        cmp al,0F0h
        jne sysc2
        lodsb
        mov ecx,eax
        rep movsb
        jmp sysc3
sysc2:  movsb
        lodsb
        mov ecx,eax
        stosb
        rep movsb
sysc3:  pop edi
        mov [cpos+4*edi],esi
        mov esi,buff
        cmp byte [esi+1],51h
        jne sysc4
        mov eax,[esi+2]
        and eax,0FFFFFF00h
        bswap eax
        mov [bpm],eax
sysc4:  jmp cont

