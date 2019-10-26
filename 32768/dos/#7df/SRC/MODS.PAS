{$A-,B-,E-,G+,N-,O-,R-,S-,T-,V-,X+}
     {ç• ‚‡Æ£†‚Ï ìÅúÖí !!!}
Unit Mods;

interface

const
  dvSpeaker   = 0;
  dvDacLPT1   = 1;
  dvDacLPT2   = 2;
  dvDacLPT3   = 3;
  dvDacLPTs   = 4;
  dvDacLPTm   = 5;
  dvSBlaster  = 6;
  dvStereoIn1 = 10;
  dvDSSLPT1   = 11;
  dvDSSLPT2   = 12;
  dvDSSLPT3   = 13;
  dvNoSound   = 255;

const
  lpStopAtEnd = 0;
  lpPlayFirst = 1;
  lpNoBackJmp = 2;
  lpLoopPlay  = 4;

const
  stNoError  = 0;
  stModError = 1;
  stAllrPlay = 2;
  stOutOfMem = 4;

const
  Loop: Integer = lpLoopPlay;
  MixSpeed: Word = 10000;
  Device: Integer = dvNoSound;
  Volume: Integer = 255;
  Playing : boolean = False;

procedure SetVolume(AVolume: Integer);
function PlayMod(FName: String): Integer;
procedure StopMod;

implementation

Uses Memory;

{$L MODS.OBJ}
procedure ModVolume(v1,v2,v3,v4: Integer); far; external;
procedure ModDevice(var Device: Integer); far; external;
procedure ModSetup(var Status: Integer;
  ADevice, AMixSpeed, APro, ALoop: Integer; var FName: String); far; external;
procedure ModStop; far; external;
procedure ModInit; far; external;

function GetBlock(Size: Word): Word; assembler;
asm
        ADD     Size,16
        PUSH    Size
        CALL    MemAllocSeg
        MOV     AX,DX
        OR      AX,AX
        JZ      @@Exit
        MOV     ES,DX
        MOV     DX,Size
        MOV     ES:[0].Word,DX
        INC     AX
@@Exit:
end;

procedure FreeBlock(Segment: Word);
var
  P: ^Word;
begin
  P := Ptr(Segment-1, 0);
  FreeMem(P, P^);
end;

procedure CheckError; assembler;
asm
        OR      AX,AX
        AND     [BP+6].Word,NOT 1
        JNZ     @@1
        MOV     AX,8
        OR      [BP+6].Word,1
@@1:
end;

procedure Int21h; assembler;
asm
        CMP     AH,4Ah
        JA      @@Old
        CMP     AH,48h
        JB      @@Old
        PUSH    BP
        MOV     BP,SP
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI
        PUSH    DS
        PUSH    ES
        MOV     DX,SEG @DATA
        MOV     DS,DX

        CMP     AH,48h
        JNE     @@1
        PUSH    BX              { GetBlock }
        SHL     BX,4
        PUSH    BX
        CALL    GetBlock
        POP     BX
        CALL    CheckError
        JMP     @@Done

@@1:
        CMP     AH,49h          { Mem Free }
        JNE     @@2
        PUSH    AX
        PUSH    BX
        PUSH    ES
        CALL    FreeBlock
        MOV     AX,1
        CALL    CheckError
        POP     BX
        POP     AX
        JMP     @@Done
@@2:                            { Adj Block }
        PUSH    BX
        SHL     BX,4
        PUSH    BX
        PUSH    ES
        CALL    FreeBlock
        CALL    GetBlock
        POP     BX
        CALL    CheckError

@@Done:
        POP     ES
        POP     DS
        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     BP
        IRET
@@Old:
end;

procedure Old21h; assembler;
asm
        DB      0,0,0
end;

procedure Set21h; assembler;
asm
        MOV     AX,3521h
        INT     21h
        PUSH    DS
        PUSH    CS
        POP     DS
        MOV     Old21h.Byte[-1],0EAh
        MOV     Old21h.Word[0],BX
        MOV     Old21h.Word[2],ES
        MOV     AX,2521h
        MOV     DX,OFFSET Int21h
        INT     21h
        POP     DS

end;

procedure Reset21h; assembler;
asm
        PUSH    DS
        LDS     DX,DWORD PTR CS:Old21h
        MOV     AX,2521h
        INT     21h
        POP     DS
end;

procedure SetVolume(AVolume: Integer); assembler;
asm
        MOV     AX,AVolume
        CMP     AX,255
        JLE     @@1
        MOV     AX,255
@@1:    CMP     AX,0
        JGE     @@2
        XOR     AX,AX
@@2:    MOV     Volume,AX
        PUSH    AX
        PUSH    AX
        PUSH    AX
        PUSH    AX
        CALL    ModVolume
end;

function PlayMod(FName: String): Integer; assembler;
var Status: Integer;
asm
        CMP     Device,dvNoSound
        JE      @@Exit
        CALL    Set21h
        LEA     BX,Status
        PUSH    SS
        PUSH    BX
        PUSH    Device
        PUSH    MixSpeed
        PUSH    0
        PUSH    Loop
        PUSH    FName.Word[2]
        PUSH    FName.Word[0]
        CALL    ModSetup
        CALL    Reset21h
        MOV     AX,Status
        MOV     Playing,True
        CMP     AX,0
        JE      @@Exit
        CMP     AX,2
        JE      @@Exit
        MOV     Playing,False
@@Exit:
end;

procedure StopMod; assembler;
asm
        CMP     Playing,False
        JE      @@Exit
        CALL    Set21h
        CALL    ModStop
        CALL    Reset21h
        MOV     Playing,False
@@Exit:
end;

procedure InitMods; assembler;
asm
        PUSH    Volume
        CALL    SetVolume
        CALL    ModInit
end;

begin
  InitMemory;
  InitMods
end.
