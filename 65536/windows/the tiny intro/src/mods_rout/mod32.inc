;#########################################################################
;                             Mod 32  Engine  (v1.7)
;                           by Del Nero Jean Francois 
;                               (c)  HxC 2000
;                              www.powerofasm.fr.st
;                          jeanfrancoisdelnero@libero.it
;#########################################################################
;
;INITMOD PROC ;Initialise the Mod player......
; Input : ds:eax=File Name ptr
;         ds:ebx=Sound Buffer ptr
;            ecx=Size Of the Buffer
;            esi=Mod ptr (if eax=0) 
;             dl=bits (8/16)
;             dh=Mono/Stereo(1/2)
;          e(dx)=1 (11025hz)
;               =2 (22050hz)
;               =4 (44100hz)
;
;
; OutPut :   eax=0 > Ok
;            eax=12345678h >Error
;
;CLOSEMODSYS PROC ;Close the Mod Player !
; Input: NONE
; OutPut: NONE
;
;GiveMeSample  Proc  ;Prepare some sample.... 
; Input edi=Sound Buffer ptr
;       ecx=size of the sample 
;
;#########################################################################

.data

pNumTracks       equ     34

pDefTempo        equ     6
pDefBpm          equ     125
pMidCRate        equ     8448
pMixBufSize      equ     4096
SampleRate       equ     44100

StatusMod        dw      0
MemModAlloc      db      0
NumTracks        dw      4
NumInstru        db      31
patternsize      dw      1024

pOrderPos        db      0
pRow             db      0
pBpmSamples      dd      0
pBufPtr          dd      0
pBufLen          dd      0
pBufRep          dd      0
pNote            dd      0

FiltrageM db 1
sizewri dd 0
SampleMode dd 8
StereoMode dd 4
StereoMode8 dd 2
MixageCroise db 1
BufferDWORD dd 80808080h
FileSize         dd 1024*1024


pSinTable       db      0,25,50,74,98,120,142,162,180,197,212,225
                db      236,244,250,254,255,254,250,244,236,225
                db      212,197,180,162,142,120,98,74,50,25,0,0,0,0

pPeriodTable    dw      856,808,762,720,678,640,604,570,538,508,480,453
                dw      428,404,381,360,339,320,302,285,269,254,240,226
                dw      214,202,190,180,170,160,151,143,135,127,120,113
                dw      20 DUP(0)


.data?

hModFile         dd      ?
pCount           dw      ?
hMODMemory2      dd      ?
hMODMemory       dd      ?
pSamplebuffer    dd      ?
pPatternbuffer   dd      ?

pTempo           db      ?
pTempoWait       db      ?
pBpm             db      ?
pBreakRow        db      ?


ModSample      Struc
msName          db      22 dup (?)
msLength        dw      ?
msFinetune      db      ?
msVolume        db      ?
msRepeat        dw      ?
msRepLen        dw      ?
ModSample       EndS


ModHeader       Struc

mhName          db      20 dup (?)
mhSamples       ModSample 31 dup (<>)
mhOrderLen      db      ?
mhReStart       db      ?
mhOrder         db      128 dup (?)
mhSign          dw      ?,?

ModHeader       EndS


ModInfo      Struc   

OrderLen        db      ?
ReStart         db      ?
Order           db      128 dup (?)
Patterns        dd      ?

SampOfs         dd      31 dup (?)
SampLen         dd      31 dup (?)
SampRep         dd      31 dup (?)
SampRepLen      dd      31 dup (?)
SampVol         dd      31 dup (?)

ModInfo      EndS


pTrackInfo       Struc

pSamples         dd      ?
pPosition        dd      ?
pLen             dd      ?
pRepeat          dd      ?
pRepLen          dd      ?
pVolume          db      ?
pError           db      ?
pPeriod          dw      ?
pPitch           dw      ?
pEffect          dw      ?
pPortTo          dw      ?
pPortParm        db      ?
pVibPos          db      ?
pVibParm         db      ?
pOldSampOfs      db      ?
pArp             dw      ?,?,?
pArpIndex        dw      ?
tempde           dd      ?,?,?,? 
pTrackInfo       EndS


Header          ModHeader  <>
ModInf          ModInfo    <>
Tracks          pTrackInfo pNumTracks dup (<>)

tempsaveecx dd ?
tempsavereg1 dd ?
tempsavereg2 dd ?


pPitchTable      dw      857+100 dup (?)
pMixBuffer       dw      (2*pMixBufSize+2000) dup (?)

temp2            dd      610 dup (?)


ErrorInfo dw ?
MixSpeed dw ?

pVolTable        db      26640+100 dup (?)

;=== SUBROUTINES


.code


;--------------------------------------------------------------------------
; StartPlaying: Initializes the Sound System.
;  In:
;   Module Information Resources.
;--------------------------------------------------------------------------
ALIGN 4

StartPlaying    Proc
                pushad


SetModParms:
                xor     eax,eax
                mov     ds:[pOrderPos],al
                mov     ds:[pTempo],pDefTempo
                mov     ds:[pTempoWait],pDefTempo
                mov     ds:[pBpm],pDefBpm
                mov     ds:[pRow],64
                mov     ds:[pBreakRow],al
                xor eax,eax
                mov     ax,ds:[MixSpeed]
                xor     ebx,ebx
                xor     edx,edx
                mov     ebx, (24*pDefBpm) / (60)
                div     ebx

                mov     ds:[pBpmSamples],eax

ClearTracks:    mov     edi,offset Tracks
                mov     ecx, (Size pTrackInfo)
                xor     eax,eax

                cld
                rep stosd ES:[EDI]

                mov     ds:[pBufPtr],eax
                mov     ds:[pBufLen],eax
                ;mov     ds:[pBufRep],eax
                mov     ds:[pNote],eax

MakePitch:      xor eax,eax
                mov     ax,pMidCRate
                mov     bx,428
                mul     bx
                div     DS:[MixSpeed]


                xor     dh,dh
                mov     dl,ah
                mov     ah,al
                xor     al,al
                mov     ecx,857
                xor     bx,bx
                mov     edi,offset pPitchTable
PitchLoop:      push    ax
                push    dx
                cmp     dx,bx

                jae     NoDiv
                div     bx
NoDiv:
                MOV DS:[EDI],AX; stosw
                ADD EDI,2
                pop     dx
                pop     ax
                inc     bx
                loop    PitchLoop
MakeVolume:    
                mov     ecx,16640       ;taille table volume
                mov     ebx,ecx
              ;  shl     ebx,1
VolLoop:        sub     ebx,1
                mov     al,bl
                imul    bh
                mov     ds:[pVolTable+ebx],ah
                loop    VolLoop
                ;finpVolT:
                popad
                ret
StartPlaying    EndP



ALIGN 4


;--------------------------------------------------------------------------
; GetSamples:  Returns the next chunk of samples to be played.
;  In:
;    ds:edi  Buffer  - Buffer Address.
;    ecx     Count   - Buffer Size.
;--------------------------------------------------------------------------

GetSamples      Proc ; Buffer:DWord, Count:Word

                pushad
                mov     ebx,ecx

NextChunk:      cmp     ds:[pBufLen],0
                jne     CopyChunk

                push    ebx
                push    edi

MixChunk:     
                mov     edi,offset pMixBuffer
                mov     ecx,ds:[pBpmSamples]
                mov     ds:[pBufPtr],edi

               cmp ds:[SampleMode],16
               jne suite8bits
               shl ecx,1
               suite8bits:
               cmp ds:[StereoMode],4
               jne suitemonom
               shl ecx,1
               suitemonom:
               mov     ds:[pBufLen],ecx

                mov     eax,ds:[BufferDWORD]
 
                 rep stosw es:[edi]

                 mov   ax,DS:[NumTracks]
                 mov   esi,offset Tracks
                 mov   edi,[pBufPtr]
                 mov   ecx,[pBufLen]
                 xor dx,dx
                 boucelddee45r45:
                 push edi

                 cmp ds:[StereoMode],4
                 jne suitemixmono
                 mov dh,dl
                 and dh,011b
                 cmp dh,0
                 je hpgauche
                 cmp dh,3
                 je hpgauche

                 hpdroite:
                 cmp ds:[SampleMode],16
                 jne suitegkjmer
                 inc edi
                 suitegkjmer:
                 inc edi
                 jmp suitehpdroite
                 hpgauche:

                 suitehpdroite:
                 suitemixmono:
                 call  MixTrack
                 jgihjgerhrh:
                 add   esi,Size pTrackInfo
                 pop edi
                 inc dl
                 dec ax
                 jnz boucelddee45r45

                 call    UpdateTracks

                pop     edi
                pop     ebx

CopyChunk:      mov     ecx,[pBufLen]
                cmp     ecx,ebx        ;ebx=taille buffer
                jbe     MoveChunk
                mov     ecx,ebx
MoveChunk:      mov     esi,ds:[pBufPtr]
                add     ds:[pBufPtr],ecx
                sub     ds:[pBufLen],ecx
                sub     ebx,ecx
                cld

                cmp ecx,4
                jb finqsGetSamples

               cmp ds:[StereoMode],4
               jne suitesansmixa25pc

               cmp ds:[MixageCroise],2
               je suitemixamono
               
               cmp ds:[MixageCroise],1
               jne suitesansmixa25pc

               cmp ds:[SampleMode],16
               jne suitemixa25pc8bit
                pushad
                shr ecx,2
                boucle15456:
                mov ax,ds:[esi]
                mov bx,ds:[esi+2]
                sar ax,1
                sar bx,1
                add ds:[esi+2],ax
                add ds:[esi],bx
                add esi,4
                dec ecx
                jnz boucle15456
                popad
               jmp suitesansmixa25pc

               cmp ds:[SampleMode],16
               jne suitemixamono8bit

                suitemixamono:
                pushad
                shr ecx,2
                boucle15456c:
                mov ax,ds:[esi]
                mov bx,ds:[esi+2]
                add ds:[esi+2],ax
                add ds:[esi],bx
                add esi,4
                dec ecx
                jnz boucle15456c
                popad
               jmp suitesansmixa25pc

                suitemixamono8bit:
                pushad
                shr ecx,1
                boucle15456d:
                mov al,ds:[esi]
                mov bl,ds:[esi+1]
                add ds:[esi+1],al
                add ds:[esi],bl
                add esi,2
                dec ecx
                jnz boucle15456d
                popad
               jmp suitesansmixa25pc
                
                suitemixa25pc8bit:
                pushad
                shr ecx,1
                boucle15456b:
                mov al,ds:[esi]
                mov bl,ds:[esi+1]
                sar al,1
                sar bl,1
                add ds:[esi+1],al
                add ds:[esi],bl
                add esi,2
                dec ecx
                jnz boucle15456b
                popad

               suitesansmixa25pc:
                ;copie du sample cree...

                call Filtrage
                finqsGetSamples:


                rep movsb   es:[edi],ds:[esi]

                test    ebx,ebx

                jne     NextChunk
                popad
                ret

GetSamples      EndP


ALIGN 4


;--------------------------------------------------------------------------
; MixTrack:  Mixes one track into a CLEAN buffer.
;  In:
;   ds:esi -  Track Info  Address.
;   ds:edi -  Buffer Address.
;    ecx   -  Buffer Size.
;--------------------------------------------------------------------------
MixTrack        Proc    
                pushad

               cmp ds:[SampleMode],16
               jne suite8bits
               shr ecx,1
               suite8bits:
               cmp ds:[StereoMode],4
               jne suitemonom
               shr ecx,1
               suitemonom:

               cmp ds:[SampleMode],16
               jne suite8bitsmix
               call MixTrack16
               jmp finmix
               suite8bitsmix:
               call MixTrack8

              finmix:
              popad
             ret

MixTrack        EndP

ALIGN 4

MixTrack16      Proc
                pushad
                mov ax,ds:[NumTracks]
                mov ah,al

                cmp     [esi+pTrackInfo.pRepLen],2
                ja      MixLooped
MixNonLooped:   
                mov     edx,[esi+pTrackInfo.pSamples]
                mov     ebx,[esi+pTrackInfo.pPosition]
                mov     ebp,[esi+pTrackInfo.pLen]

                push    edx
                push    esi
                add     ebx,edx     ;ebx=pPosition + pSamples
                add     ebp,edx     ;ecx=pLen + pSamples
                mov     dx,[esi+pTrackInfo.pPitch]
                mov     al,[esi+pTrackInfo.pVolume]

                divi1:
                cmp ah,4
                jna suite1035
                shr al,1
                cmp ah,8
                jna suite1035
                shr al,1
                suite1035:

                mov     ah,[esi+pTrackInfo.pError]
                mov     esi,ebx    ;esi=pPosition + pSamples
                xor     ebx,ebx ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                mov     bh,al      ;bh=[esi+pVolume]
                mov     al,dl      ;al=low [esi+pPitch]
                mov     dl,dh      ;dl=high [esi+pPitch]
                and     edx,0ffh

nlMixSamp:
                cmp     esi,ebp
                jae     nlMixBye
                mov     bl,ds:[esi]        ;bl=
                mov     bl,ds:[pVolTable+ebx] ;bl < volumetab

                push bx
                mov bh,bl
                xor bl,bl
                add     ds:[edi],bx        ;buffer < bl
                pop bx
                ADD EDI,ds:[StereoMode]

                add     ah,al
                adc     esi,edx
                dec     ecx
                jnz     nlMixSamp


nlMixBye:       mov     ebx,esi
                pop     esi
                pop     edx
                sub     ebx,edx
                mov     [esi+pTrackInfo.pPosition],ebx
                mov     [esi+pTrackInfo.pError],ah
                popad
                ret

MixLooped:
                mov     edx,[esi+pTrackInfo.pSamples]
                mov     ebx,[esi+pTrackInfo.pPosition]
                mov     ebp,[esi+pTrackInfo.pRepLen]
                mov     [pBufRep],ebp
                add     ebp,[esi+pTrackInfo.pRepeat]

                push    edx
                push    esi
                add     ebx,edx ;ebx=pPosition + pSamples
                add     ebp,edx ;ebp=pLen + pSamples
                mov     dx,[esi+pTrackInfo.pPitch]
                mov     al,[esi+pTrackInfo.pVolume]


                divi2:
                cmp ah,4
                jna suite1035d
                shr al,1
                cmp ah,8
                jna suite1035d
                shr al,1
                suite1035d:

                mov     ah,[esi+pTrackInfo.pError]
                mov     esi,ebx ;esi=pPosition + pSamples
                xor     ebx,ebx ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                mov     bh,al       ;bh=[esi+pVolume]
                mov     al,dl       ;al=low [esi+pPitch]

                mov     dl,dh       ;dl=high [esi+pPitch]
                and     edx,0ffh
lpMixSamp:      cmp     esi,ebp
                jb      lpMixNow
                sub     esi,ds:[pBufRep] ;bug>>>>>>>>
lpMixNow:    
                mov     bl,ds:[esi]
                mov     bl,ds:[pVolTable+ebx]

                push bx
                mov bh,bl
                xor bl,bl
                add     ds:[edi],bx        ;buffer < bl
                pop bx

                add edi,ds:[StereoMode]
                add     ah,al
                adc     esi,edx
                dec     ecx
                jnz     lpMixSamp

lpMixBye:       mov     ebx,esi
                pop     esi
                pop     edx
                sub     ebx,edx
                mov     ds:[esi+pTrackInfo.pPosition],ebx
                mov     ds:[esi+pTrackInfo.pError],ah
                popad
                ret

MixTrack16        EndP

ALIGN 4

MixTrack8        Proc    
                pushad


                mov ax,ds:[NumTracks]
                mov ah,al

                cmp     [esi+pTrackInfo.pRepLen],2
                ja      MixLooped
MixNonLooped:   
                mov     edx,[esi+pTrackInfo.pSamples]
                mov     ebx,[esi+pTrackInfo.pPosition]
                mov     ebp,[esi+pTrackInfo.pLen]

                push    edx
                push    esi
                add     ebx,edx     ;ebx=pPosition + pSamples
                add     ebp,edx     ;ecx=pLen + pSamples
                mov     dx,[esi+pTrackInfo.pPitch]
                mov     al,[esi+pTrackInfo.pVolume]

                divi1:
                cmp ah,4
                jna suite1035
                shr al,1
                cmp ah,8
                jna suite1035
                shr al,1
                suite1035:

                mov     ah,[esi+pTrackInfo.pError]
                mov     esi,ebx    ;esi=pPosition + pSamples
                xor     ebx,ebx ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                mov     bh,al      ;bh=[esi+pVolume]
                mov     al,dl      ;al=low [esi+pPitch]
                mov     dl,dh      ;dl=high [esi+pPitch]
                and     edx,0ffh

nlMixSamp:
                cmp     esi,ebp
                jae     nlMixBye
                mov     bl,ds:[esi]        ;bl=
                mov     bl,ds:[pVolTable+ebx] ;bl < volumetab

                add     ds:[edi],bl        ;buffer < bl

                ADD EDI,ds:[StereoMode8]

                add     ah,al
                adc     esi,edx
                dec     ecx
                jnz     nlMixSamp


nlMixBye:       mov     ebx,esi
                pop     esi
                pop     edx
                sub     ebx,edx
                mov     [esi+pTrackInfo.pPosition],ebx
                mov     [esi+pTrackInfo.pError],ah
                popad
                ret

MixLooped:
                mov     edx,[esi+pTrackInfo.pSamples]
                mov     ebx,[esi+pTrackInfo.pPosition]
                mov     ebp,[esi+pTrackInfo.pRepLen]
                mov     [pBufRep],ebp
                add     ebp,[esi+pTrackInfo.pRepeat]

                push    edx
                push    esi
                add     ebx,edx ;ebx=pPosition + pSamples
                add     ebp,edx ;ebp=pLen + pSamples
                mov     dx,[esi+pTrackInfo.pPitch]
                mov     al,[esi+pTrackInfo.pVolume]


                divi2:
                cmp ah,4
                jna suite1035d
                shr al,1
                cmp ah,8
                jna suite1035d
                shr al,1
                suite1035d:

                mov     ah,[esi+pTrackInfo.pError]
                mov     esi,ebx ;esi=pPosition + pSamples
                xor     ebx,ebx ;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                mov     bh,al       ;bh=[esi+pVolume]
                mov     al,dl       ;al=low [esi+pPitch]

                mov     dl,dh       ;dl=high [esi+pPitch]
                and     edx,0ffh
lpMixSamp:      cmp     esi,ebp
                jb      lpMixNow
                sub     esi,ds:[pBufRep]
lpMixNow:    
                mov     bl,ds:[esi]
                mov     bl,ds:[pVolTable+ebx]

                add     ds:[edi],bl        ;buffer < bl
                add     edi,ds:[StereoMode8]

                add     ah,al
                adc     esi,edx
                dec     ecx
                jnz     lpMixSamp

lpMixBye:       mov     ebx,esi
                pop     esi
                pop     edx
                sub     ebx,edx
                mov     ds:[esi+pTrackInfo.pPosition],ebx
                mov     ds:[esi+pTrackInfo.pError],ah
                popad
                ret

MixTrack8        EndP


Filtrage        Proc
pushad

                cmp ds:[FiltrageM],1
                jne finfiltrage

                cmp ds:[SampleMode],16
                jne Mode8bit

                mov ebp,DS:[StereoMode]
                sub ebp,2

              boucle2emev:
                push esi
                push ecx
                mov edi,DS:[StereoMode]
                shr ecx,2
                mov edx,ecx

                boucle15456:

                push ecx

                cmp ecx,1
                je branchem1
                cmp ecx,edx
                je branchem2

                neg edi
                mov ax,ds:[esi + edi]
                neg edi
                mov bx,ds:[esi]
                mov cx,ds:[esi + edi]

                movsx eax,ax
                movsx ebx,bx
                movsx ecx,cx

                add eax,ecx
                sar eax,1

                add eax,ebx
                sar eax,1

                mov ds:[esi],ax

                branchem:
                add esi,edi
                pop ecx

                dec ecx
                jnz boucle15456

                pop ecx
                pop esi

                cmp ebp,0
                je finfiltrage

                xor ebp,ebp
                add esi,2
                cmp di,4
                je boucle2emev

                finfiltrage:


              popad
             ret

          branchem1:
                neg edi
                mov ax,ds:[esi + edi]
                neg edi
                mov bx,ds:[esi]
                movsx eax,ax
                movsx ebx,bx
                add eax,ebx
                sar eax,1
                mov ds:[esi],ax
         jmp branchem

          branchem2:
                mov ax,ds:[esi + edi]
                mov bx,ds:[esi]
                movsx eax,ax
                movsx ebx,bx
                add eax,ebx
                sar eax,1
                mov ds:[esi],ax
         jmp branchem

               Mode8bit:

                mov ebp,DS:[StereoMode8]
                dec ebp

              boucle2emevb:
                push esi
                push ecx
                mov edi,DS:[StereoMode8]
                shr ecx,2
                mov edx,ecx

                boucle15456b:

                push ecx

                cmp ecx,1
                je branchem1b
                cmp ecx,edx
                je branchem2b

                neg edi
                mov al,ds:[esi + edi]
                neg edi
                mov bl,ds:[esi]
                mov cl,ds:[esi + edi]

                movsx ax,al
                movsx bx,bl
                movsx cx,cl

                add ax,cx
                sar ax,1

                add ax,bx
                sar ax,1

                mov ds:[esi],ax

                branchemb:
                add esi,edi
                pop ecx

                dec ecx
                jnz boucle15456b

                pop ecx
                pop esi

                cmp ebp,0
                je finfiltrage

                xor ebp,ebp
                add esi,2
                cmp di,2
                je boucle2emevb





             jmp  finfiltrage

          branchem1b:
                neg edi
                mov al,ds:[esi + edi]
                neg edi
                mov bl,ds:[esi]
                movsx ax,al
                movsx bx,bl
                add ax,bx
                sar ax,1
                mov ds:[esi],al
         jmp branchemb

          branchem2b:
                mov al,ds:[esi + edi]
                mov bl,ds:[esi]
                movsx ax,al
                movsx bx,bl
                add ax,bx
                sar ax,1
                mov ds:[esi],al
         jmp branchemb


Filtrage        EndP
                        

;--------------------------------------------------------------------------
; UpdateTracks:  Main code to process the next tick to be played.
;--------------------------------------------------------------------------

UpdateTracks    Proc    

                pushad

                dec     ds:[pTempoWait]
                je      GetTracks

BeatTracks:

                mov   edi,offset Tracks
                mov ax,ds:[NumTracks]
                bouclebeat02:
                call  BeatTrack
                add   edi,Size pTrackInfo
                dec ax
                jnz  bouclebeat02
                popad
                ret

GetTracks:      xor ebx,ebx
                mov     al,ds:[pTempo]
                mov     ds:[pTempoWait],al

                mov     esi,ds:[pNote]
                cmp     ds:[pRow],64
                jb      NoPattWrap

                mov     esi,ds:[ModInf.Patterns]
                mov     bl,ds:[pOrderPos]
                cmp     bl,ds:[ModInf.OrderLen]
                jb      NoOrderWrap
                mov     bl,ds:[ModInf.ReStart]
                mov     ds:[pOrderPos],bl
                cmp     bl,ds:[ModInf.OrderLen]
                jae     NoUpdate
NoOrderWrap:
                AND EBX,0ffh
                mov     bl,ds:[ModInf.Order+ebx]
                mov ax,ds:[patternsize]
                mul bx
                mov bx,ax
                ;shl     ebx,10    ;ebx
                mov     esi,ds:[ModInf.Patterns]
                add     esi,ebx
                mov     bl,ds:[pBreakRow]
                mov     ds:[pRow],bl
                AND     EBX,0ffh
                mov     ds:[pBreakRow],bh

                mov     ax,ds:[NumTracks]
                shl     ax,2
                mul     bx
                mov   bx,ax
               ; shl     ebx,4    ;ebx

                add     esi,ebx
                mov     DWord Ptr ds:[pNote],esi
                inc     ds:[pOrderPos]
NoPattWrap:     inc     ds:[pRow]

                
                mov   edi,offset Tracks
                mov ax,ds:[NumTracks]
                boucleGettrack02:
                call  GetTrack
                add   edi,Size pTrackInfo
                dec ax
                jnz  boucleGettrack02
                mov   DWord Ptr ds:[pNote],esi




                popad

                ret
NoUpdate:
xor eax,eax
mov ds:[pOrderPos],al
mov ds:[pRow],al
;mov ds:[pNote],eax
mov     ds:[pBufPtr],eax
mov     ds:[pBufLen],eax
    ;mov     ds:[pBufRep],eax

                xor     eax,eax
                mov     ds:[pOrderPos],al
                mov     ds:[pTempo],pDefTempo
                mov     ds:[pTempoWait],pDefTempo
                mov     ds:[pBpm],pDefBpm
                mov     ds:[pRow],64
                mov     ds:[pBreakRow],al
                xor eax,eax
                mov     ax,ds:[MixSpeed]
                xor     ebx,ebx
                xor     edx,edx
                mov     ebx, (24*pDefBpm) / (60)
                div     ebx
                mov     ds:[pBpmSamples],eax

                mov     edi,offset Tracks
                mov     ecx, (Size pTrackInfo)
                xor     eax,eax

                cld
                rep stosd ES:[EDI]

                mov     ds:[pBufPtr],eax
                mov     ds:[pBufLen],eax
                ;mov     ds:[pBufRep],eax
                mov     ds:[pNote],eax
                    
                popad

                ret


UpdateTracks    EndP



ALIGN 4


;--------------------------------------------------------------------------
; GetTrack:   Get the next Note from a pattern.
;  In:
;    ds:edi -  Track info Address.
;    es:esi -  Pattern Note Address.
; Out:
;    es:esi -  The Next Pattern Note address.
;--------------------------------------------------------------------------

GetTrack        Proc    
             push EAX
             push ebx
             push ecx
             push edx
             push edi

             xor ebx,ebx
             mov ax,ds:[esi]
             add esi,2


             xchg    al,ah
             mov     bl,ah
             and     ah,0Fh
             mov     cx,ax

             mov ax,ds:[esi]
             add esi,2

             xchg    al,ah
             mov     bh,ah
             and     ah,0Fh
             mov     dx,ax
             mov     [edi+pTrackInfo.pEffect],dx
             and     bl,0F0h
             shr     bh,4
             or      bl,bh
             je      SetPeriod

SetSample:
                AND ebx,0ffh
                dec     ebx
                shl     ebx,2

                mov     eax,[ModInf.SampVol+ebx]
                mov     [edi+pTrackInfo.pVolume],al
                mov     eax,[ModInf.SampOfs+ebx]
                mov     [edi+pTrackInfo.pSamples],eax
                mov     eax,[ModInf.SampLen+ebx]
                mov     [edi+pTrackInfo.pLen],eax
                mov     eax,[ModInf.SampRep+ebx]
                mov     [edi+pTrackInfo.pRepeat],eax
                mov     eax,[ModInf.SampRepLen+ebx]
                mov     [edi+pTrackInfo.pRepLen],eax

SetPeriod:

                test    cx,cx
                je      SetEffect

                mov     ds:[edi+pTrackInfo.pPortTo],cx
                cmp     dh,03h
                je      SetEffect

                mov     ds:[edi+pTrackInfo.pPeriod],cx
                xor     ebx,ebx
                mov     bx,cx
                add     ebx,ebx
                mov     ax,ds:[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pPitch],ax
                mov     [edi+pTrackInfo.pPosition],0

SetEffect:

                test    dx,dx
                je      InitNone
                cmp     dh,00h
                je      InitArpeggio
                cmp     dh,03h
                je      InitTonePort
                cmp     dh,04h
                je      InitVibrato
                cmp     dh,09h
                je      SampleOfs
                cmp     dh,0Bh
                je      PosJump
                cmp     dh,0Ch
                je      SetVolume
                cmp     dh,0Dh
                je      Break
                cmp     dh,0Fh
                je      SetSpeed

InitNone:
             pop edi
             pop edx
             pop ecx
             pop ebx
             pop eax
             ret


InitTonePort:   test    dl,dl
                jne     SetPortParm
                mov     dl,[edi+pTrackInfo.pPortParm]
SetPortParm:    mov     [edi+pTrackInfo.pPortParm],dl
                mov     [edi+pTrackInfo.pEffect],dx
                pop edi
                pop edx
                pop ecx
                pop ebx
                pop eax
                ret
              

InitVibrato:    mov     al,[edi+pTrackInfo.pVibParm]
                mov     ah,al
                and     al,0Fh
                and     ah,0F0h
                test    dl,0Fh
                jne     OkDepth
                or      dl,al
OkDepth:        test    dl,0F0h
                jne     OkRate
                or      dl,ah
OkRate:         mov     [edi+pTrackInfo.pVibParm],dl
                mov     [edi+pTrackInfo.pEffect],dx
                test    cx,cx
                je      OkPos
                mov     [edi+pTrackInfo.pVibPos],0
OkPos:
             pop edi
             pop edx
             pop ecx
             pop ebx
             pop eax
             ret


SampleOfs:      test    dl,dl
                jne     SetSampleOfs
                mov     dl,[edi+pTrackInfo.pOldSampOfs]
SetSampleOfs:   mov     [edi+pTrackInfo.pOldSampOfs],dl
                and   edx,0ffffh
                mov     dh,dl
                xor     dl,dl
                mov     [edi+pTrackInfo.pPosition],edx
                pop edi
                pop edx
                pop ecx
                pop ebx
                pop eax
                ret


PosJump:        mov     [pOrderPos],dl
                mov     [pRow],64
                pop edi
                pop edx
                pop ecx
                pop ebx
                pop eax
                ret


SetVolume:      cmp     dl,64
                jbe     OkVol
                mov     dl,64
OkVol:          mov     [edi+pTrackInfo.pVolume],dl
             pop edi
             pop edx
             pop ecx
             pop ebx
             pop eax
                ret


Break:          mov     dh,dl
                and     dl,0Fh
                shr     dh,4
                add     dh,dh
                add     dl,dh
                shl     dh,2
                add     dl,dh
                mov     [pBreakRow],dl
                mov     [pRow],64
                pop edi
                pop edx
                pop ecx
                pop ebx
                pop eax
                ret


SetSpeed:       test    dl,dl
                je      Skip
                cmp     dl,31
                ja      SetBpm
SetTempo:       mov     [pTempo],dl
                mov     [pTempoWait],dl
             pop edi
             pop edx
             pop ecx
             pop ebx
             pop eax
             ret

SetBpm:         and eax,0ffffh
                mov     [pBpm],dl
                mov     al,103
                mul     dl
                mov     bl,ah
                xor     bh,bh
                mov     ax,[MixSpeed]

                xor     dx,dx
                div     bx

                mov     [pBpmSamples],eax
Skip:
             pop edi
             pop edx
             pop ecx
             pop ebx
             pop eax
             ret


InitArpeggio:   mov     dh,dl
                and     dl,0Fh
                shr     dh,4
                mov     ecx,36
                xor     ebx,ebx
                mov     ax,[edi+pTrackInfo.pPeriod]
ScanPeriod:     cmp     ax,[pPeriodTable+ebx]
                jae     SetArp
                add     ebx,2
                loop    ScanPeriod
SetArp:
                ;>>>>>>>>>>>>>
                add     dx,dx
                add     dh,bl
                add     dl,bl
                mov     bx,[pPeriodTable+ebx]
                and     ebx,0ffffh
                add     ebx,ebx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pArp],ax
                mov     bl,dh
                and     ebx,0ffh
                mov     bx,[pPeriodTable+ebx]
                add     ebx,ebx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pArp+2],ax
                mov     bl,dl
                and     ebx,0ffh
                mov     bx,[pPeriodTable+ebx]
                add     ebx,ebx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pArp+4],ax
                mov     [edi+pTrackInfo.pArpIndex],0
               pop edi
               pop edx
               pop ecx
               pop ebx
               pop eax
               ret

GetTrack        EndP

ALIGN 4

;--------------------------------------------------------------------------
; BeatTrack:  Process the next beat in one track.
;  In:
;    ds:edi -  Track info Address.
;--------------------------------------------------------------------------

BeatTrack       Proc    
              pushad

                mov     dx,[edi+pTrackInfo.pEffect]
                test    dx,dx
                je      None
                cmp     dh,00h
                je      Arpeggio
                cmp     dh,01h
                je      PortUp
                cmp     dh,02h
                je      PortDown
                cmp     dh,03h
                je      TonePort
                cmp     dh,04h
                je      Vibrato
                cmp     dh,05h
                je      PortSlide
                cmp     dh,06h
                je      VibSlide
                cmp     dh,0Ah
                je      VolSlide
None:
popad
ret


Arpeggio:       xor ebx,ebx
                mov     bx,[edi + pTrackInfo.pArpIndex]
                mov     ax,[edi+pTrackInfo.pArp+ebx]  ;<<<<<<<>>>>>>>>>>><<<<<<<<<>>>
                mov     [edi+pTrackInfo.pPitch],ax
                add     bx,2
                cmp     bx,6
                jb      SetArpIndex
                xor     ebx,ebx
SetArpIndex:    mov     [pTrackInfo.pArpIndex + edi],bx
popad
ret


PortUp:         and     edx,0ffh
                xor     ebx,ebx
                mov     bx,[edi+pTrackInfo.pPeriod]
                sub     bx,dx
                cmp     bx,113
                jge     NotSmall
                mov     bx,113
NotSmall:       mov     [edi+pTrackInfo.pPeriod],bx
                add     bx,bx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pPitch],ax
popad
ret


               
PortDown:       xor     ebx,ebx
                and     edx,0ffh
                mov     bx,[edi+pTrackInfo.pPeriod]
                add     bx,dx
                cmp     bx,856
                jle     NotBig
                mov     bx,856
NotBig:         mov     [edi+pTrackInfo.pPeriod],bx
                add     bx,bx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pPitch],ax
popad
ret


popad
ret
TonePort:      ;

                xor     ebx,ebx
                xor     eax,eax
                and     edx,0ffh
                mov     ax,[edi+pTrackInfo.pPortTo]
                mov     bx,[edi+pTrackInfo.pPeriod]
                cmp     bx,ax
                je      NoPort
                jg      PortToUp
PortToDown:     add     bx,dx
                cmp     bx,ax
                jle     SetPort
FixPort:        mov     bx,ax
                jmp     SetPort
PortToUp:       sub     bx,dx
                cmp     bx,ax
                jl      FixPort
SetPort:        mov     [edi+pTrackInfo.pPeriod],bx
                add     ebx,ebx
                mov     ax,[pPitchTable+ebx] ;>>>>>>>>>>>
                mov     [edi+pTrackInfo.pPitch],ax
NoPort:
popad
ret


Vibrato:        xor ebx,ebx
                mov     dh,dl
                and     dl,0Fh
                shr     dh,4
                shl     dh,2
                add     [edi+pTrackInfo.pVibPos],dh
                mov     dh,[edi+pTrackInfo.pVibPos]
                mov     bl,dh
                shr     bl,2
                and     ebx,1Fh
                mov     al,[pSinTable+ebx]
                mul     dl
                rol     ax,1
                xchg    al,ah
                and     ah,1
                test    dh,dh
                jns     VibUp
                neg     ax
VibUp:          xor ebx,ebx
                add     ax,[edi+pTrackInfo.pPeriod]
                mov     bx,ax
                cmp     bx,113
                jge     NoLoVib
                mov     bx,113
NoLoVib:        cmp     bx,856
                jle     NoHiVib
                mov     bx,856
NoHiVib:        add     bx,bx
                mov     ax,[pPitchTable+ebx]
                mov     [edi+pTrackInfo.pPitch],ax
popad
ret


PortSlide:      call    VolSlideproc
                mov     dl,[edi+pTrackInfo.pPortParm]
                jmp     TonePort


VibSlide:       call    VolSlideproc
                mov     dl,[edi+pTrackInfo.pVibParm]
                jmp     Vibrato


VolSlide:       call    VolSlideproc
                popad
                ret



VolSlideproc:   mov     dh,dl
                and     dl,0Fh
                shr     dh,4
                mov     al,[edi+pTrackInfo.pVolume]
                sub     al,dl
                jge     NoLoVol
                xor     al,al
NoLoVol:        add     al,dh
                cmp     al,64
                jbe     NoHiVol
                mov     al,64
NoHiVol:        mov     [edi+pTrackInfo.pVolume],al
                ret

BeatTrack       EndP

GiveMeSample    Proc ;edi=pointeur buffer ecx=taille
  
                pushad
                cmp ds:[StatusMod],0
                je fingetsample
                call    GetSamples
                fingetsample:
                popad
                ret     

GiveMeSample    EndP


LoadMModule      Proc
                pushad
                mov ds:[NumInstru],31

                call    ClearModInfo


    ;        invoke CreateFile,ADDR szFileName,\
    ;                          GENERIC_READ ,\
    ;                          FILE_SHARE_WRITE,\
    ;                          NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
    ;                          NULL
    ;                          mov hModFile,eax
    ;                    CMP EAX,0
    ;                    JE Failed


ReadHeader:

invoke ReadFile,hModFile,ADDR Header,Size ModHeader,ADDR sizewri,NULL
       
CheckMK:        cmp     ds:[Header.mhSign],'.K.M'
                jne     CheckFLT4
                 mov ds:[NumTracks],4
                jmp      IsModFile
                                           
CheckFLT4:      cmp     ds:[Header.mhSign],'TLF4'
                jne     Check8CHNflt
                 mov ds:[NumTracks],4
                jmp      IsModFile


Check8CHNflt:   cmp     ds:[Header.mhSign],'TLF8'
                jne     Check6CHN
                 mov ds:[NumTracks],8
                jmp      IsModFile

Check6CHN:
                cmp     ds:[Header.mhSign],'NHC6'
                jne     Check8CHN
                 mov ds:[NumTracks],6
                jmp      IsModFile

Check8CHN:
                cmp     ds:[Header.mhSign],'NHC8'
                jne     Check10CHN
                 mov ds:[NumTracks],8
                jmp      IsModFile

Check10CHN:
                cmp     ds:[Header.mhSign],'HC01'
                jne     Check12CHN
                 mov ds:[NumTracks],10
                jmp      IsModFile


Check12CHN:
                cmp     ds:[Header.mhSign],'HC21'
                jne     Check14CHN
                 mov ds:[NumTracks],12
                jmp      IsModFile
Check14CHN:
                cmp     ds:[Header.mhSign],'HC41'
                jne     Check16CHN
                 mov ds:[NumTracks],14
                jmp      IsModFile


Check16CHN:
                cmp     ds:[Header.mhSign],'HC61'
                jne     Check24CHN
                 mov ds:[NumTracks],16
                jmp      IsModFile
                
Check24CHN:
                cmp     ds:[Header.mhSign],'HC42'
                jne     Check32CHN
                 mov ds:[NumTracks],24
                jmp      IsModFile

Check32CHN:
                cmp     ds:[Header.mhSign],'HC23'
                jne     Is15Inst
                 mov ds:[NumTracks],32
                jmp      IsModFile


                
Is15Inst:
                mov ds:[NumInstru],15
                mov ds:[NumTracks],4
                mov     esi,(Offset Header.mhSamples) + 15*(Size ModSample)
                mov     edi,(Offset Header.mhOrderLen)
                cld
                mov     ecx,130 / 4
               cld

               rep movsd  es:[edi],ds:[esi]

               mov     edi,(Offset Header.mhSamples) + 15*(Size ModSample)
               xor     eax,eax
               mov     ecx, 16*(Size ModSample)

                boucle7778:
                mov ds:[edi],al
                inc edi
                dec ecx
                jnz boucle7778

SeekPatterns:
        invoke CloseHandle,hModFile

            invoke CreateFile,ADDR szFileName,\
                              GENERIC_READ ,\
                              FILE_SHARE_WRITE,\
                              NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                              NULL
                              mov hModFile,eax
                        CMP EAX,0
                        JE Failed

invoke ReadFile,hModFile,ADDR temp2,600,ADDR sizewri,NULL


           ;     mov     ax,4200h
           ;     mov     bx,ds:[FileHandle]
           ;     mov     ecx,0
           ;     mov     edx,600
           ;     int     21h
           ;     jc      Failed

IsModFile:

                mov     al,ds:[Header.mhOrderLen]
                mov     ds:[ModInf.OrderLen],al

                mov     al,ds:[Header.mhReStart]
                cmp     al,ds:[Header.mhOrderLen]
                jb      SetReStart
                mov     al,7Fh
SetReStart:     mov     ds:[ModInf.ReStart],al

                mov     ecx,128
                xor     eax,eax
                xor     ebx,ebx
CopyOrder:
                mov     ah,ds:[Header.mhOrder+ebx]
                mov     ds:[ModInf.Order+ebx],ah
                cmp     ah,al
                jb      NextOrder
                mov     al,ah
NextOrder:
                inc     ebx
                loop    CopyOrder


AllocPatterns:  xor     ebx,ebx
                mov     bl,al
                inc     ebx
                mov eax,ds:[pPatternbuffer]
                mov     dWord Ptr ds:[ModInf.Patterns],eax

ReadPatterns:   
                xor eax,eax
                mov     ecx,ebx
                mov     ax,ds:[NumTracks]
                shl     ax,8   ;ax=octet pas patterns
                mov     ds:[patternsize],ax

                mul     cx      ;ax=octet pas patterns*NbPatterns
                xor ecx,ecx
                mov ecx,eax
                mov     edx,[ModInf.Patterns]

PUSHAD
invoke ReadFile,hModFile,edx,ecx,ADDR sizewri,NULL
POPAD

                mov  esi,offset Header.mhSamples
                xor  edi,edi
CopySamples:    xor  eax,eax

                mov     ax,ds:[esi+ModSample.msLength]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampLen+edi],eax  ;taille sample

                mov     al,ds:[esi+ModSample.msVolume]
                and eax,0ffh
                mov     ds:[ModInf.SampVol+edi],eax ;volume (0-64)

                xor eax,eax
                mov     ax,ds:[esi+ModSample.msRepeat]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampRep+edi],eax ;point de repetition

                xor eax,eax
                mov     ax,ds:[esi+ModSample.msRepLen]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampRepLen+edi],eax  ;taille repete

                add     esi,Size ModSample
                add     edi,4
                cmp     edi,4*31
                jb      CopySamples

                xor     esi,esi
                mov     edi,ds:[pSamplebuffer] ;buffer des samples
AllocSamples:   mov     ebx,ds:[ModInf.SampLen+esi]
                shr     ebx,4
                je      NextSample
                inc     ebx
                mov     ds:[ModInf.SampOfs+esi],edi
ReadSample:     push    esi

                mov     ecx,ds:[ModInf.SampLen+esi]
                add     edi,ecx
                push    edi
                mov     edx,ds:[ModInf.SampOfs+esi]
                invoke ReadFile,hModFile,edx,ecx,ADDR sizewri,NULL
                pop     edi
                pop     esi

NextSample:     add     esi,4
                cmp     esi,2*2*31
                jb      AllocSamples


CloseFile:
              invoke CloseHandle,hModFile

                popad
                xor eax,eax
                ret

Failed:

                popad
                mov eax,12344321h
                ret

LoadMModule      EndP


LoadMemModule      Proc
                   pushad
                mov ds:[NumInstru],31

                call    ClearModInfo

MOV DS:[tempsavereg1],esi
DReadHeader:

 mov ecx,Size ModHeader
 mov edi,offset Header
 cld
 rep movsb 
mov ds:[tempsavereg2],esi 

DCheckMK:       cmp     ds:[Header.mhSign],'.K.M'
                jne     DCheckFLT4
                mov ds:[NumTracks],4
                jmp      DIsModFile
                                           
DCheckFLT4:     cmp     ds:[Header.mhSign],'4FLT'
                jne     DCheck6CHN
                mov ds:[NumTracks],4
                jmp      DIsModFile


DCheck6CHN:
                cmp     ds:[Header.mhSign],'NHC6'
                jne     DCheck8CHN
                 mov ds:[NumTracks],6
                jmp      DIsModFile

DCheck8CHN:
                cmp     ds:[Header.mhSign],'NHC8'
                jne     DCheck10CHN
                 mov ds:[NumTracks],8
                jmp      DIsModFile

DCheck10CHN:
                cmp     ds:[Header.mhSign],'HC01'
                jne     DCheck12CHN
                 mov ds:[NumTracks],10
                jmp      DIsModFile


DCheck12CHN:
                cmp     ds:[Header.mhSign],'HC21'
                jne     DCheck16CHN
                 mov ds:[NumTracks],12
                jmp      DIsModFile

DCheck16CHN:
                cmp     ds:[Header.mhSign],'HC61'
                jne     DCheck24CHN
                 mov ds:[NumTracks],16
                jmp      DIsModFile
                
DCheck24CHN:
                cmp     ds:[Header.mhSign],'HC42'
                jne     DCheck32CHN
                 mov ds:[NumTracks],24
                jmp      DIsModFile

DCheck32CHN:
                cmp     ds:[Header.mhSign],'HC23'
                jne     DIs15Inst
                 mov ds:[NumTracks],32
                jmp      DIsModFile


DIs15Inst:
                mov ds:[NumInstru],15
                mov ds:[NumTracks],4
                mov     esi,(Offset Header.mhSamples) + 15*(Size ModSample)
                mov     edi,(Offset Header.mhOrderLen)
                cld
                mov     ecx,130 / 4
               cld

               rep movsd  es:[edi],ds:[esi]

               mov     edi,(Offset Header.mhSamples) + 15*(Size ModSample)
               xor     eax,eax
               mov     ecx, 16*(Size ModSample)

                Dboucle7778:
                mov ds:[edi],al
                inc edi
                dec ecx
                jnz Dboucle7778

DSeekPatterns:
MOV esi,DS:[tempsavereg1]
add esi,600
mov ds:[tempsavereg2],esi 


DIsModFile:
                mov     al,ds:[Header.mhOrderLen]
                mov     ds:[ModInf.OrderLen],al

                mov     al,ds:[Header.mhReStart]
                cmp     al,ds:[Header.mhOrderLen]
                jb      DSetReStart
                mov     al,7Fh
DSetReStart:     mov     ds:[ModInf.ReStart],al

                mov     ecx,128
                xor     eax,eax
                xor     ebx,ebx
DCopyOrder:
                mov     ah,ds:[Header.mhOrder+ebx]
                mov     ds:[ModInf.Order+ebx],ah
                cmp     ah,al
                jb      DNextOrder
                mov     al,ah
DNextOrder:
                inc     ebx
                loop    DCopyOrder


DAllocPatterns:  xor     ebx,ebx
                mov     bl,al
                inc     ebx
                mov eax,ds:[pPatternbuffer]
                mov     dWord Ptr ds:[ModInf.Patterns],eax

DReadPatterns:   
                mov     ecx,ebx
                shl     ecx,10          ;ecx =nbpat * 1024
                mov     edx,[ModInf.Patterns]

PUSHAD
mov esi,ds:[tempsavereg2] 
 mov edi,edx
 cld
 rep movsb 
mov ds:[tempsavereg2],esi 
POPAD

                mov  esi,offset Header.mhSamples
                xor  edi,edi
DCopySamples:   xor  eax,eax

                mov     ax,ds:[esi+ModSample.msLength]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampLen+edi],eax  ;taille sample

                mov     al,ds:[esi+ModSample.msVolume]
                and eax,0ffh
                mov     ds:[ModInf.SampVol+edi],eax ;volume (0-64)

                xor eax,eax
                mov     ax,ds:[esi+ModSample.msRepeat]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampRep+edi],eax ;point de repetition

                xor eax,eax
                mov     ax,ds:[esi+ModSample.msRepLen]
                xchg    al,ah
                shl     eax,1
                mov     ds:[ModInf.SampRepLen+edi],eax  ;taille repete

                add     esi,Size ModSample
                add     edi,4
                cmp     edi,2*2*31
                jb      DCopySamples

                xor     esi,esi
                mov     edi,ds:[pSamplebuffer] ;buffer des samples
DAllocSamples:   mov     ebx,ds:[ModInf.SampLen+esi]
                shr     ebx,4
                je      DNextSample
                inc     ebx
                mov     ds:[ModInf.SampOfs+esi],edi
DReadSample:     push    esi

                mov     ecx,ds:[ModInf.SampLen+esi]
                add     edi,ecx
                push    edi
                mov     edi,ds:[ModInf.SampOfs+esi]

                mov esi,ds:[tempsavereg2] 
                cld
                rep movsb 
                mov ds:[tempsavereg2],esi 


                pop     edi
                pop     esi

DNextSample:    add     esi,4
                cmp     esi,2*2*31
                jb      DAllocSamples


DCloseFile:

                popad
                xor eax,eax
                ret

DFailed:

                popad
                mov eax,12344321h
                ret

LoadMemModule      EndP


ALIGN 4

FreeModule      Proc
                pushad
                call    ClearModInfo
                popad
                ret
FreeModule      EndP
ALIGN 4

ClearModInfo    Proc    
                pushad

                mov     edi,offset ModInf
                mov     ecx,Size  ModInfo
                xor     ax,ax
boucle44:
                mov ds:[edi],al
                inc edi
                dec ecx
                jnz boucle44

                mov     edi,offset Tracks
                mov     ecx,Size  Tracks
                xor     ax,ax
bouclef44:
                mov ds:[edi],al
                inc edi
                dec ecx
                jnz bouclef44



                xor eax,eax
                mov ds:[pOrderPos],al
                mov ds:[pRow],al
                mov ds:[pBpmSamples],eax
                mov ds:[pBufPtr],eax
                mov ds:[pBufLen],eax
                mov ds:[pBufRep],eax
                mov ds:[pNote],eax
popad
ret
ClearModInfo    EndP
 
ALIGN 4

INITMOD PROC  ;eax=pointeur fichier ebx=pointeur buffer ecx=taille buf
                PUSHAD                ;esi=offset data (si eax=0) ; Output Mode: dl=bits(8/16)
                push eax              ;              dh=Mono/Stero(1/2)
                mov edi,ebx           ;               e(dx)=1(1025hz)
                                      ;                     2(2050hz)
                                       ;                     4(4100hz)

                push ebx
                xor ebx,ebx
                mov bl,dl
                mov ds:[SampleMode],ebx
                push dx
                mov dl,2
                cmp dh,2
                jne monomode
                shl dl,1
                monomode:
                mov bl,dl
                mov ds:[StereoMode],ebx
                shr ebx,1
                mov ds:[StereoMode8],ebx
                pop dx
                mov eax,80808080h
                cmp dl,16
                jne s8bitsmode
                mov eax,00800080h
s8bitsmode:
                mov ds:[BufferDWORD],eax
                shr edx,16
                cmp dl,4
                jne suite1sp
                mov     ds:[MixSpeed],44100
suite1sp:
                cmp dl,2
                jne suite2sp
                mov     ds:[MixSpeed],22050
suite2sp:
                cmp dl,1
                jne suite3sp
                mov     ds:[MixSpeed],11025
suite3sp:

                pop ebx

                shr ecx,2
                ;mov eax,80808080h
boucle454:
                mov ds:[edi],eax
                add edi,4
                dec ecx
                jnz boucle454
                pop eax

                PUSH EAX
                cmp DS:[StatusMod],0 ;1ere Initialisation?
                je  OkModUnAlloc
                call CLOSEMODSYS
OkModUnAlloc:

                pop eax
                push eax
                cmp eax,0
                je jkhkhmghrgh


                invoke CreateFile,EAX,\
                      GENERIC_READ ,\
                      FILE_SHARE_WRITE,\
                      NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\
                      NULL
                      mov hModFile,eax
                      CMP EAX,0
                      JE Erreurfinb

                invoke GetFileSize,hModFile,Addr FileSize 
                cmp eax,0ffffffffh
                JE Erreurfinb
                mov ds:[FileSize],eax

                ;cmp ds:[FileSize],0
                ;JE Erreurfinb

jkhkhmghrgh:
                push esi
                cmp ds:[MemModAlloc],0
                jne dejaalloc
                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,FileSize
                mov  hMODMemory,eax
                invoke GlobalLock,hMODMemory
                mov  ds:[pSamplebuffer],eax
                invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT,FileSize
                mov  hMODMemory2,eax
                invoke GlobalLock,hMODMemory2
                mov  ds:[pPatternbuffer],eax
                mov ds:[MemModAlloc],70h
dejaalloc:
                pop esi
                ; mov DS:[StatusMod],0
                pop eax
                cmp eax,0
                je directmem

                call    LoadMModule ;Load the MODule...
                cmp EAX,0
                jne     Erreurfin
                jmp nondirectmem
directmem:
                call    LoadMemModule ;Prepare le MODule...
nondirectmem:
                mov DS:[StatusMod],70h
 
                ; mov     ds:[MixSpeed],SampleRate  

                call    StartPlaying

                POPAD
                XOR EAX,EAX
                RET

Erreurfin:
                mov ds:[StatusMod],0
                POPAD
                MOV EAX,12344321h
                RET
Erreurfinb:
                mov ds:[StatusMod],0

                POP EAX
                POPAD
                MOV EAX,12344321h
                RET
INITMOD ENDP


CLOSEMODSYS PROC
                PUSHAD
                cmp ds:[StatusMod],0
                je finCLOSEMODSYS
                mov byte ptr ds:[MemModAlloc],0
                mov DS:[StatusMod],0
                invoke GlobalUnlock,pSamplebuffer
                invoke GlobalFree,hMODMemory
                invoke GlobalUnlock,pPatternbuffer
                invoke GlobalFree,hMODMemory2
finCLOSEMODSYS:
                POPAD
                RET
CLOSEMODSYS ENDP






