{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
ÚÙ         GusPlay v1.5 and UltraDox v1.? interface for B/TPascal!           ³
³           (C) Copyright, 1993 by Bjarni R. Einarsson (Juggler)             ³
³                                                                            ³
³   With added bonuses by Juggler/BTL. :-) Thats me.  OK, here it is, all    ³
³   you Pascal proggin GUS owners: a unit that lets you do your (my) most    ³
³   favorite GUS thingz!  This (cute) little unit plays back 4/6/8 channel   ³
³   .MODs in the background and lets you play up to 12 other samples at a    ³
³   time as well. (GUS initialized with 20 active voices..)                  ³
³                                                                            ³
³   Full source code of course, and all the important stuff is in the .ASM   ³
³   file.  So you should be able to hack this into a C/C++ program without   ³
³   too much trouble, if ya get the urge.                                    ³
³                                                                            ³
³   Thanx go to Robert Adolfsson/Cascada and CyberStrike/Renaissance for     ³
³   writing the important bits of code.                                      ³
³                                                                            ³
³   Now go read the dox. :-)                                                 ³
³                                                                            ³
³   P.S.  The tabs should be set to 4 spaces for all this to look right.    ÚÙ
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

{$F+,A+,G+,S+}
unit GP15 ;

interface
const   GP_RampNoFlags          = $000 ;        (* Ramp Control bits..                  *)
        GP_RampLoopOn       = $008 ;    (*      on=enable               *)
                GP_RampBiDirLoop        = $010 ;        (*              on=enable                               *)
                GP_RampIRQEnable        = $020 ;        (* Not properly supported..     *)

                GP_VocNoFlags           = $000 ;        (* Voice control.       (loopmode)      *)
        GP_VocLoopOn        = $008 ;    (*      on=enable               *)
                GP_VocBiDirLoop         = $010 ;        (*              on=enable                               *)
                GP_VocIs16Bit           = $004 ;        (* Not properly supported..     *)
                GP_VocIRQEnable         = $020 ;        (* Not properly supported..     *)

        GP_FarLeft          = 0 ;       (* Some balance values..        *)
        GP_Middle           = 7 ;
        GP_FarRight         = 15 ;
        GP_MaxVolume        = 64 ;      (* Some voice/mod volume values *)
        GP_MidVolume        = 32 ;
        GP_MinVolume        = 0 ;

                GP_MixMyDefault         = $01 ;         (* Mixer Control values                 *)
                GP_MixNoLineIn          = $01 ;         (*              on=disable                              *)
                GP_MixNoLineOut         = $02 ;         (*              on=disable                              *)
                GP_MixMicInOn           = $04 ;         (*              on=enable                               *)

type    GP_Var_Types = (MainVolume, PlayingPattern, RealPPattern,
                                                PatternRow, RealRow, ChanOn, NumChans, ProtSampNum,
                                                ProtMainVolume, NextVoice) ;

                GP_Array_Typ = array[GP_Var_Types] of word ;
                GP_LArr32        = array[0..31] of longint ;
                GP_WArr32        = array[0..31] of word ;
                GP_LArr64        = array[0..63] of longint ;
                GP_WArr64        = array[0..63] of word ;

                GP_Data          = record                                               (* All this stuff is    *)
                                                        BasePort        : ^Word ;       (* in the assembler     *)
                                                        ErrorCode       : ^Word ;                       (* file! These  *)
                                                        Vars            : ^GP_Array_Typ ;       (* are merely   *)
                                                        Timer,                                  (* pointers! *)
                                                        GUSMem,                                 (* GetVariables must be *)
                                                        GUSMemProt      : ^Longint ;    (* called before        *)
                                                        SampChans       : ^Word ;               (* using this stuff.*)
                                                        GusVolTable : ^GP_WArr64 ;      (* I've got it set  *)
                                                        MSOffset        : ^GP_LArr32 ;  (* up to do this        *)
                                                        MSLen,                                          (* automatically. *)
                                                        MSVol,
                                                        MSRep,
                                                        MSRepLen        : ^GP_WArr32 ;
                                                        PSOffset        : ^GP_LArr64 ;
                                                        PSLen,
                                                        PSVol,
                                                        PSRep,
                                                        PSRepLen        : ^GP_WArr64 ;
                                           end ;

const   GP_MixerVal  : word = GP_MixMyDefault ; (* Mixer settings, on reset.*)
                GP_PlayOK        : boolean = false ;            (* Is a module in memory?       *)
                GP_Playing       : boolean = false ;            (* Is a module being played?*)
var     GP                       : GP_Data ;                            (* Pointers to data.            *)
        SampleMemBuf:word;


(* GUS reset (init) routine.  Call this first and last in your program. *)
procedure GP_ResetGUS ;

(* Module stuff..
(*
(* LoadModule   - allocs memory and dumps into GUS DRAM,
(* KillModule   - frees up all .MOD memory..
(* SlideModVolTo- Just to save time.. (when coding, time = change*0.01 secs)
(* Start/StopPlaying - do just that.  Neither resets the playback postition.
(* ResetPlaying - Resets playback position to beginning of song.
(*)
procedure GP_LoadModule(s,o1,o2:word);
procedure GP_KillModule ;
procedure GP_SlideModVolTo      (NewVolume : word) ;
procedure GP_StartPlaying ;
procedure GP_StopPlaying ;
procedure GP_ResetPlaying ;

(* Protected samples.  Load these before you load your modules!
(*
(* ProtSampAdd  - dumps whatever DATA is the first element of into GUS DRAM
(*                                and sets up tables containing info about the sample
(*                                (length, loops and so on).  Returns the sample's handle.
(*                                Rep and RepLen are OFFSETs, not calculated GUS addresses.
(* ProtSampPlay - plays a sample previously loaded by PSAdd.
(* ProtSampPop  - pops the most recently loaded sample off the sample stack.
(*)
function  GP_ProtSampAdd        (var Data; DLen,Vol,Rep,RepLen : word;
                                                         Signed : boolean) : word;
procedure GP_ProtSampPlay       (Handle,Freq,Balance,LoopMode : word) ;
procedure GP_ProtSampPop ;

(* Low level stuff.
(*
(* Copied (almost) straight from Ultradox 1.? by Renaissance.
(*)
function  GP_Peek                       (MemPos : longint) : byte ;
procedure GP_Poke                       (MemPos : longint; PokeByte : word) ;
procedure GP_SetFreq            (Voice, Freq : word) ;
procedure GP_SetBalance         (Voice, Balance : word) ;
procedure GP_SetLogVolume       (Voice, LogVolume : word) ;
procedure GP_SetLoopMode        (Voice, LoopMode : word) ;
procedure GP_StopVoice          (Voice : word) ;
procedure GP_StartVoice         (Voice, LoopMode : word;
                                                         StartP, BeginP, EndP : longint);
function  GP_ReadPos            (Voice : word) : longint ;
procedure GP_SetMixer           (MixValue : word) ;
procedure GP_DumpSampleToDRAM
                                                        (var Data; DLen : word; GusMemPos : longint;
                                                         XORval : byte) ;
procedure GP_DumpDRAMToMemory
                                                        (GusMemPos : longint; DLen : word; var Data) ;


implementation
{$F+}
{uses dos ;}
const GP_DEBUG = FALSE ;        (* Toggles irritating messages on/off :*)

{$L pasgplay.obj}

(* GUSPlay v1.5 code *)
procedure Init ;                                external ;
procedure InitDevice ;                  external ;
procedure ClearMem ;                    external ;
procedure StartPlaying ;                external ;
procedure StopPlaying ;                 external ;
(* Renaissance code *)
procedure U_Peek ;                              external ;
procedure U_Poke ;                              external ;
procedure U_SetFreq ;                   external ;
procedure U_SetBalance ;                external ;
procedure U_SetVolume ;                 external ;
procedure U_SetLoopMode ;               external ;
procedure U_StopVoice ;                 external ;
procedure U_StartVoice(voice,loopmode : word; startp,beginp,endp : longint) ;
                                                                external ;
procedure U_ReadPos ;                   external ;
procedure U_ChangeInOut ;               external ;
procedure U_DumpSampleToDRAM ;  external ;
procedure U_DumpDRAMToMemory ;  external ;
(* My code!  Hmm.. not very much of it, is there?  :*)
procedure GetVariables  (var ProgData : GP_Data) ;                                      external;
function  LoadModule(nseg, pofs, sofs,bseg:word) : word ;                            external;
function  ProtSampAdd   (var data; dlen,vol,rep,replen : word;
                                                                                XORval : byte) : word;          external;
procedure ProtSampPlay  (snum,freq,balance,loopmode : word) ;           external;
procedure ProtSampPop ;                                                                                         external;


procedure GP_ResetGUS ;
 begin
        if (GP_Playing) then GP_KillModule ;
        InitDevice ;
        GP_SetMixer(GP_MixerVal) ;
 end ;

procedure GP_KillModule ;
 begin
        if (GP_Playing) then StopPlaying;
        if (GP_PlayOK) then ClearMem;
        GP_Playing := false;
        GP_PlayOK := false;
 end ;

procedure GP_LoadModule(s,o1,o2:word);
var sn,on : word ;
 begin
        GP_KillModule ;
        GP_PlayOK := False ;

        GP_PlayOK := (LoadModule(s,o1,o2,SampleMemBuf) = 0);
 end ;

procedure GP_SlideModVolTo(newvolume : word) ;
var     i : integer ;
        j : longint ;
 begin
        if      (newvolume > 64) then newvolume := 64 ;
        if      (newvolume = GP.Vars^[MainVolume]) or
                (not GP_Playing) then exit
        ;
        if      (newvolume > GP.Vars^[MainVolume]) then
                for i := GP.Vars^[MainVolume]+1 to newvolume do begin
                        j := GP.Timer^ ;
                        repeat until (GP.Timer^ >= j+10) ;
                        GP.Vars^[MainVolume] := i ;
                end ;
        if      (newvolume < GP.Vars^[MainVolume]) then
                for i := GP.Vars^[MainVolume]+1 downto newvolume do begin
                        j := GP.Timer^ ;
                        repeat until (GP.Timer^ >= j+10) ;
                        GP.Vars^[MainVolume] := i ;
                end ;
 end ;

procedure GP_StartPlaying ;
 begin
        if (not GP_PlayOK) or (GP_Playing) then exit ;
        StartPlaying ;
        GP_Playing := true ;
 end ;

procedure GP_StopPlaying ;
 begin
        if (GP_Playing) then StopPlaying ;
        GP_Playing := false ;
 end ;

procedure GP_ResetPlaying ;
 begin
        if (GP_Playing) then StopPlaying ;
        Init ;
        if (GP_Playing) then StartPlaying ;
 end ;

function  GP_ProtSampAdd
        (var data; dlen,vol,rep,replen : word; Signed : boolean) : word ;
 begin
        if Signed then
                        GP_ProtSampAdd := ProtSampAdd(data, dlen,vol,rep,replen, $00)
        else    GP_ProtSampAdd := ProtSampAdd(data, dlen,vol,rep,replen, $80) ;
 end ;

procedure GP_ProtSampPlay(handle,freq,Balance,LoopMode : word) ;
 begin
        ProtSampPlay(handle, freq, Balance, LoopMode) ;
 end ;

procedure GP_ProtSampPop ;
 begin
        ProtSampPop ;
 end ;

function GP_Peek(mempos : longint) : byte ;
var retv : byte ;
 begin
        asm
                mov             cx,Word Ptr [mempos]
                mov             bx,Word Ptr [mempos+2]
                call    U_Peek
                mov             retv, ah
        end ;
        GP_Peek := retv ;
 end ;

procedure GP_Poke(mempos : longint; pokebyte : word) ; assembler ;
 asm
        mov             cx,Word Ptr [mempos]
        mov             bx,Word Ptr [mempos+2]
        mov             ax,pokebyte
        call    U_Poke
 end ;

procedure GP_SetFreq(voice, freq : word) ; assembler ;
 asm
        mov             bx,voice
        mov             ax,freq
        call    U_SetFreq
 end ;

procedure GP_SetBalance(voice, balance : word) ; assembler ;
 asm
        mov             ax,voice
        mov             bx,balance
        call    U_SetBalance
 end ;

procedure GP_SetLogVolume(voice, logVolume : word) ; assembler ;
 asm
        mov             ax,voice
        mov             bx,logVolume
        call    U_SetVolume
 end ;

procedure GP_SetLoopMode(voice, loopMode : word) ; assembler ;
 asm
        mov             ax,voice
        mov             bx,loopMode
        call    U_SetLoopMode
 end ;

procedure GP_StopVoice(voice : word) ; assembler ;
 asm
        mov             ax,voice
        call    U_StopVoice
 end ;

procedure GP_StartVoice(voice,loopmode : word; startP,beginP,endP : longint);
 begin
        U_StartVoice(voice,loopmode, startP,beginP,endP) ;
 end ;

function  GP_ReadPos(voice : word) : longint ;
var retv : longint ;
 begin
        asm
                mov             ax,voice
                call    U_ReadPos
                mov     Word Ptr [retv  ], ax
                mov             Word Ptr [retv+2], dx
        end ;
        GP_ReadPos := retv ;
 end ;

procedure GP_SetMixer(mixValue : word) ; assembler ;
 asm
        mov             ax, mixValue
        mov     GP_MixerVal, ax
    call    U_ChangeInOut
 end ;

procedure GP_DumpSampleToDRAM
        (var data; dlen : word; gusMemPos : longint; xorval : byte) ; assembler;
 asm
        les             bx,data
        mov             ax,Word Ptr [gusMemPos]
        mov     di,ax
        mov             ax,Word Ptr [gusMemPos+2]
        mov             si,ax
        mov             cx,dlen
        mov             ah,xorval
        call    U_DumpSampleToDRAM
 end ;

procedure GP_DumpDRAMToMemory
                (gusMemPos : longint; dlen : word; var data) ; assembler ;
 asm
        les             bx,data
        mov             ax,Word Ptr [gusMemPos]
        mov     di,ax
        mov             ax,Word Ptr [gusMemPos+2]
        mov             si,ax
        mov             cx,dlen
        call    U_DumpDRAMToMemory
 end ;

const
 EnvString:string[8]='ULTRASND';

procedure CheckULTRASND ;
var
        a,x : integer ;
 begin
  { This code is needed instead of standard GetEnv function }
   asm
    mov a,0
    mov ax,PrefixSeg
    mov es,ax
    mov ax,es:[2ch]
    mov es,ax
    xor di,di
@01:cmp byte ptr es:[di],0
    je @finish
    mov si,offset EnvString+1
    mov cx,8
    repe cmpsb
    or cx,cx
    jnz @02
    mov ax,es:[di+2]
    mov a,ax
@02:mov al,es:[di]
    inc di
    or al,al
    jnz @02
    jmp @01
@finish:
   end;
  if a<>0 then begin
                a :=a and $ff-ord('0');
                GP.BasePort^ := $200+(a*$10);
        end ;
 end ;

begin
    GetVariables(GP) ;          (* VERY IMPORTANT!!!        *)
        CheckULTRASND ;                         (* Not nearly as important :*)
end.
