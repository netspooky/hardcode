UNIT MainDefs;
INTERFACE
USES Dos;
CONST
{      ShowInfo:Boolean=False;
      ShowBack:Boolean=True;}
      MusicOn:Boolean=True;
      JoyOn:Boolean=True;

      JOYSTICKPORT = $201;
      JoyButt1 = $10;
      JoyButt2 = $20;
      JoyButt3 = $40;
      JoYX = $01;
      JoYY = $02;

      JActP=12;
      JUActP=15;

      FixGen=256;
      FixGrenz=2147483000 DIV FixGen;
      FixBit=8;
      MaxPlSpr=5;
      MaxLX=600;
      MaxLY=100;
      LevSprs=41;
      ObjSprs=30;
      SlideA=2*FixGen;
      RocketAcc=FixGen*50 DIV 100;

      WinkSprGen=36;
      XDont=50*FixGen;
      YDont=50*FixGen;

      StandardLeben=2;
      EnemyRange=200;

      BlockKulanz=2;
      Gen=16384; {14 Bit}
      GBit=14;
      SGen=64;
      SGBit=6;
      FpS:LongInt=1200{80};
      FpSDiv:LongInt=15{13};
      Sprs=4;
      MaxPa=500;
      MaxParticles:Word=MaxPa;
      PartAcc=90;
      Ver:ARRAY[1..6,1..2]OF LongInt=((1,-20),(13,-4),(9,-4),(3,22),(0,20),(0,0)); {Normal}

      MaxSp=4*FixGen;
      MaxUpSp=12*FixGen;
      MaxDownSp=20*FixGen;

      MaxRef=FixGen*3 DIV 10{0.3};
      ObjRef=1*FixGen;
      MaxAcc=FixGen DIV 10{0.1};

      MaxRan={0.05}FixGen*5 DIV 100;

      MaxBre=FixGen*95 DIV 100{F0.95};
      MaxKBre={0.97}FixGen*97 DIV 100;
      MaxKHBre={0.985}FixGen*985 DIV 1000;
      TurnSp=0.5;
      TurnBre=0.95;
      Range={500}200;
      MaxGLoss=3000;

      MaxPlayers=10;

      EnemyTypes=4;

      BloodRan=1;
      FireBloodRan=10;
      FireFireRan=30;
      FireFireFireRan=50;

      KFallSpeed=FixGen DIV 10 {0.1};
      FallSpeed=FixGen*17 DIV 100 {0.17};

      PartFall=SGen DIV 50;
      JumpSpeed=8*FixGen;

      PlJumpMax=10;
      PlJumpSpeed=5*FixGen;


      AkCnter=15;
      MaxParts=100;
      WalkGrenz=FixGen*50 DIV 100{F0.5};
      WSpeed=7;

      Motions=10;

      MinMotionSpeed=10;
      MaxMotionSpeed=100;
      MotionSpeedStep=1;

      ChangeDirAb=(SGen*3 DIV 2)*(SGen*3 DIV 2);

{      C_Abstand=SGen*0.5;{}
      C_ActAbstand=SGen*SGen*{1.5}2;
      C_Abstand=SGen*0.8;{}
      C_StepInRan=4;
      C_StepOutRan=2;
      C_JumpRan=200;
      C_DuckRan=50;
      C_LeftRan=5;
      C_RightRan=5;

      P_MoveRan=10;

      K_L=75;
      K_R=77;
      K_U=72;
      K_D=80;

{      K_P=29;
      K_K=56;}
      K_P=16;
      K_K=17;

      ScrX1=140;
      ScrX2=320-140;
      ScrY1=80;
      ScrY2=200-80;

      MaxSprX=50;
      MaxSprY=50;

      GLOff:ARRAY[1..6]OF LongInt=(270,0,0,90,90,270);
      _NoSpecialH_=0;

      StandardStanH=28+3;
      StandardStanH2=StandardStanH+7;
      StandardJumpH=30;

      MaxObjekte=500;

      _Unlimited=-1;

      BurnParts=25;
      BurnStop=BurnParts-10;
      BurnStart=10;
      BurnIm=BurnParts-BurnStart;

      HReactRange=270*FixGen;
      VReactRange=250*FixGen;
      HOutReactRange=350*FixGen;
      VOutReactRange=350*FixGen;

      Weapons=3;
      FadeMul=10;

      SFXPoch=FixGen DIV 2;
      FixHalf=FixGen DIV 2;

TYPE
     tSprDat=ARRAY[0..MaxSprX*MaxSprY-1]OF Byte;
     tSprite=RECORD
               XSize,YSize:Word;{0}
               XMid,YMid:LongInt; {4}
               Dat:^tSprDat; {12}
             END;
     tObjekt=RECORD
               XX,YY:LongInt;{0}
               XS,YS:LongInt;{8}
               Typ:Byte;     {16}
               Par:ARRAY[1..5]OF LongInt;{17}
               Spr:^tSprite;
             END;
     tPlayerSpr=ARRAY[1..Sprs,1..2]OF ^tSprite;
     tPlayer=RECORD
               Gl:ARRAY[0..6]OF RECORD
                                  XS,YS:LongInt;
                                  XX,YY:LongInt;
                                  NoBlockFlag:Boolean;
                                END;
               WW,WS,Streck:Real;
               Wink:LongInt;
               Ak:ShortInt;
               AkCnt:LongInt;
               Dead:Boolean;
               NoDirC:Boolean;
               Weapon:Byte;
               HasWeap:ARRAY[1..Weapons]OF LongInt;
               FromObj:Word;
               Leben:ShortInt;
               Reload:Byte;
               Energy,Power,StartEn:LongInt;
               Dir:Byte;
               Spr:tPlayerSpr;
             END;
     tGlPos=ARRAY[0..6,1..2] OF LongInt;
     tMotionPart=RECORD
                   Gl:tGlPos;
                   Rot:LongInt;
                   StandH:LongInt;
                 END;
     tMotionPartArray=ARRAY[1..MaxParts]OF tMotionPart;
     tMotion=RECORD
               Len,Speed:LongInt;
               Dat:^tMotionPartArray;
             END;
     tParticle=RECORD X, {0}
                      Y, {4}
                      XSp,{8}
                      YSp,{12}
                      Live:LongInt;{16}
                      _R,{20}
                      _G,{22}
                      _B:Word;{24}
               END; {ASMFEST}
     tPartArr=ARRAY[0..MaxPa]OF tParticle;

     tLev=ARRAY[0..MaxLX*MaxLY-1]OF Byte;
     tLevel=RECORD
              LXS,LYS:LongInt;
              LevD:^tLev;
            END;

     tRGBTab=ARRAY[0..31,0..31,0..31]OF Byte;
     tCMix=ARRAY[0..63,0..255]OF Byte;
     tMuster=ARRAY[0..399]OF Byte;
     TScreen=Array[0..64004] OF Byte;
     tScreenFull=ARRAY[0..65534]OF Byte;
     pal_array = array [0..255, 0..2] of byte;

CONST StandardMotion:tGlPos=((0,0),(1,-20),(13,-4),(9,-4),(3,22),(0,20),(0,0)); {Normal}
      EnemyDefault:ARRAY[1..EnemyTypes]OF ARRAY[1..2] OF LongInt=((10000,600),
                                                                  (15000,700),
                                                                  (17000,800),
                                                                  (110000{},1150)
                                                                 );
      {1 = Energy ; 2=Power}
      WeaponDefault:ARRAY[0..Weapons]OF ARRAY[1..2]OF Word=((0,0),(0,10),(5,500),(10,1000));
      SammelAnz:ARRAY[1..Weapons]OF Word=(1000,100,20);
      {1 = Reload ; 2=Power}
      {W1 = Flame ; W2 = Minigun ; W3 = BallGun}
      StandardEnergy=100000;
      StPlayerPower=500;
      MediEnergy=30000;
      StFirePower=1;

      PlDeadCnt=350;
      PlDeadFreeze=60;
      PlDeadFade=250;
      PlDeadFadeEnd=130;

      IntroEnd=100000;

      _tObjSize=sizeOf(tObjekt);
      _tPartSize=sizeOf(tParticle);
      _tParticleSize:Word=sizeOf(tParticle);
      _tSpriteSize=sizeOf(tSprite);

VAR TempSpr:^tSprite;
    I,K,M:LongInt;
    PlSpr:ARRAY[1..MaxPlSpr]OF tPlayerSpr;
    Rand:Integer;
    AktLevel:Word;
    TempPointer:Pointer;
    RGBTab:^tRGBTab;
    Particle:^tPartArr;
    DaTemp:tSprite;
    Lev:tLevel;
    JumpA:Word;
    Pl:ARRAY[1..MaxPlayers]OF tPlayer;
    Palette:PAL_ARRAY;
    BCol:ARRAY[0..255]OF Byte;
    Sinus:ARRAY[0..359+320]OF LongInt;
    BSpr:ARRAY[0..BurnParts]OF tSprite;
    AMotion:ARRAY[0..Motions]OF tMotion;
    LSpr:ARRAY[1..LevSprs]OF tSprite;
    CoolPal:ARRAY[0..2,0..255]OF BytE;
    PutOnScreen,InTimer:Boolean;
    MemPoi:Pointer;
    WinCnt:Integer;
    MemInd:LongInt;
    Players:LongInt;
    PlDead:LongInt;
    BPos:LongInt;
    CMix:^tCMix;
    Objekte:Word;
    Objekt:ARRAY[0..MaxObjekte]OF ^tObjekt;
    ObjSpr:ARRAY[1..ObjSprs]OF tSprite;
    WeapSpr:ARRAY[1..ObjSprs,1..2]OF tSprite;
    PlStX,PlStY,OrigTick,Tick,Scro:LongInt;
    CSource,CDest,Scrp,Screen:^tScreenFull;
    BTab:ARRAY[0..63]OF Byte;
    Hint,BackLayer:^tScreenFull;
    JMinX,JMaxX,JMidX,JMinY,JMaxY,JMidY:Word;
    MusTick:Real;
    TempInit:Boolean;
    WinX,WinY:Integer;
    WolX,WolY:Byte;
    DBool:Boolean;
    IArg1,IArg2,IArg3,IArg4,IArg5:Integer;
    WArg1,WArg2,WArg3,WArg4,WArg5:Word;
    WolCnt:Word;
    LArg1:LongInt;
    Particles:Word;
    MixCol:Byte;

    J_L,J_R,J_U,J_PU,J_D,J_P,J_PP,J_K,J_PK,J_C,J_W,J_PW:Boolean;
    J_UC:Word;
    Cha:byte;
    FadeOn:Boolean;
    NextLevel,DeadLev:Integer;
    FadeSpeed,FadePos:LongInt;
    Intro:LongInt;

PROCEDURE LoadMem(Addr:Pointer;Size:LongInt);
PROCEDURE InitMemLoad(Addr:Pointer);
FUNCTION AktMemPoi:Pointer;

CONST KeySaveL=20;
VAR Key,KeyPre:ARRAY[0..127]OF Boolean;
    LastKey:Byte;
    OldInt:Pointer;
    Keypressed_:Boolean;

PROCEDURE InitKeyBoard;
PROCEDURE DoneKeyBoard;
FUNCTION KeyPr(B:LongInt):Boolean;

VAR OldInt8:Pointer;
    L:LongInt;

PROCEDURE InstallTimer(Proc:Pointer;FpS:Real);
PROCEDURE RestoreTimer;

CONST
      BankIncrement   = 16384;        { size of font bank in bytes }
TYPE
     CharBitmap = array[0..31] of Byte; { character Bitmap array }
     CharBit=ARRAY[0..16*8-1]OF Byte;
     tFont=ARRAY[0..255]OF CharBit;

VAR Font:^tFont;
    TempChar:CharBitmap;

PROCEDURE BufText(X,Y:LongInt;ST:STRING);
PROCEDURE LoadFont;

{TYPE TFrameRate=RECORD
                  OldSec,NewSec:Word;
                  FCnt:Word;
                END;
VAR Frame:TFrameRate;
    Frames,HighestF:LongInt;
    H,HS:Word;

PROCEDURE FrameRate;}

IMPLEMENTATION

{PROCEDURE FrameRate;
BEGIN
  WITH Frame DO BEGIN
    OldSec:=NewSec;
    GetTime(H,H,NewSec,HS);
    IF OldSec=NewSec THEN Inc(FCnt) ELSE BEGIN
      Frames:=FCnt;
      IF FCnt>HighestF THEN HighestF:=FCnt;
      FCnt:=0;
    END;
  END;
END;}


PROCEDURE KeyInt;INTERRUPT;
VAR Taste:Byte;
    I:LongInt;
BEGIN
  Taste:=Port[$60];
  IF Taste>127 THEN BEGIN
    Key[Taste-128]:=False;
  END ELSE BEGIN
    IF (Taste<>42)AND(Key[Taste]=False)THEN BEGIN
{      FOR I:=KeySaveL DOWNTO 2 DO KeySave[I]:=KeySave[I-1];
      KeySave[1]:=Taste;}
      LastKey:=Taste;
      KeyPressed_:=True;
    END;
    Key[Taste]:=True;
    KeyPre[Taste]:=True;
  END;
  Port[$20]:=$20;
END;

{PROCEDURE GetIntVec(Nr:Word;VAR TheInt:Pointer);
BEGIN
ASM
  push ds
  cli
  mov ax,Nr
  mov ah,$35
  int $21
  mov di,offset TempPointer
  mov [di],bx
  mov [di+2],es
  sti
  pop ds
END;
  TheInt:=TempPointer;
END;

PROCEDURE SetIntVec(Nr:Word;TheInt:Pointer);
BEGIN
  TempPointer:=TheInt;
ASM
  push ds
  cli
  mov ax,Nr
  mov ah,$25
  mov si,offset TempPointer
  mov dx,word ptr [si]
  mov ds,word ptr [si+2]
  int $21
  sti
  pop ds
END;
END;}

PROCEDURE InitKeyBoard;
BEGIN
  FillChar(Key,SizeOf(KeY),False);
  FillChar(KeyPre,SizeOf(KeY),False);
  GetIntVec(09,OldInt);
  SetIntVec(09,@KeyInt);
END;
PROCEDURE DoneKeyBoard;
BEGIN
  SetIntVec(09,OldInt);
END;

FUNCTION KeyPr(B:LongInt):Boolean;
BEGIN
  IF KeyPre[B] THEN BEGIN
    KeyPr:=True;
    KeyPre[B]:=False;
  END ELSE KeyPr:=False;
END;
PROCEDURE InstallTimer(Proc:Pointer;FpS:Real);
BEGIN
  ASM cli END;
  IF FpS<>0 THEN L := Round(1193180/FpS) ELSE L:=0;
  Port[$43] := $36;
  Port[$40] := Lo(L);
  Port[$40] := Hi(L);
  GetIntVec(8,OldInt8);
  SetIntVec(8,Proc);
  ASM sti END;
END;

PROCEDURE RestoreTimer;
BEGIN
  ASM cli END;
  Port[$43] := $36;
  Port[$40] := 0;
  Port[$40] := 0;
  SetIntVec(8,OldInt8);
  ASM sti END;
END;

PROCEDURE BufText(X,Y:LongInt;ST:STRING);
VAR I,K,M,WX,WY:LongInt;
    Nyx:Boolean;

PROCEDURE DrawAt(X,Y,N:LongInt);
VAR I,K,M,W,WW:Word;
BEGIN
  FOR K:=0 TO 15 DO BEGIN
    W:=(K+Y)*320+X;
    WW:=K*8;
    FOR I:=0 TO 7 DO BEGIN
      IF Font^[N][WW+I]<>0 THEN
        Scrp^[W+I]:=Font^[N][WW+I];
    eND;
  END;
END;

BEGIN
  FOR I:=1 TO Length(ST) DO
    DrawAt(X+(I-1)*8,Y,Ord(St[I]));
END;

procedure getCharBitmap( C : Word; var Bitmap );FORWARD;

procedure SetupRWMode; near; assembler;
{ set up character generator character map read/write mode }
asm
        push    ax
        push    dx
        mov     dx,3C4h
        mov     ax,0402h
        out     dx,ax
        mov     ax,0704h
        out     dx,ax
        mov     dl,0CEh
        mov     ax,0005h
        out     dx,ax
        mov     ax,0406h
        out     dx,ax
        mov     ax,0204h
        out     dx,ax
        pop     dx
        pop     ax
end;

procedure CloseRWMode; near; assembler;
{ reset video memory to normal text mode operation }
asm
        push    ax
        push    dx
        mov     dx,3C4h
        mov     ax,0302h
        out     dx,ax
        mov     ax,0304h
        out     dx,ax
        mov     dl,0CEh
        mov     ax,1005h
        out     dx,ax
        mov     ax,0E06h
        out     dx,ax
        mov     ax,0004h
        out     dx,ax
        pop     dx
        pop     ax
end;

procedure MoveChar; near; assembler;
{ copy cx words to/from video memory }
asm
        call    SetupRWMode
        rep     movsw
        call    CloseRWMode
end;

procedure getCharBitmap; assembler;
{ read character bitmap from VRAM. Does not read character if it is used for
  mouse pointer }
asm
        mov     si,C
        shl     si,5
        xor     cx,cx
        cmp     cl,4
        jb      @@100
        add     si,8192
@@100:
        jcxz    @@copy
@@lp:
        add     si,BankIncrement
        loop    @@lp
@@copy:
        mov     cl,16
        push    ds
        push    SegA000
        pop     ds
        les     di,Bitmap
        cld
        call    MoveChar
        pop     ds
end;

PROCEDURE SmoothFont;ASSEMBLER;
VAR I,K:Integer;
  ASM
    les di,Font
    mov si,di
    mov I,0
    mov K,0
    mov cx,256*8*16
@RepLoop:
    push cx

    mov al,es:[di]
    cmp al,0
    jne @NextPlease

    mov dx,-1
   @YLoop:
    push dx
    add dx,K
    cmp dx,0
    jl @NextY
    cmp dx,16
    jnl @NextY

      shl dx,3

      mov bx,-1
    @XLoop:
      push bx
      add bx,I
      cmp bx,0
      jl @DoNotSet
      cmp bx,8
      jnl @DoNotSet

      add bx,dx
      cmp byte ptr es:[si+bx],15
      jne @DoNotSet
      mov byte ptr es:[di],8
    @DoNotSet:

      pop bx
      inc bx
      cmp bx,2
      jne @XLoop
   @NextY:
    pop dx
    inc dx
    cmp dx,2
    jne @YLoop


  @NextPlease:
    inc di

    inc I
    cmp I,8
    jne @NoNext
    mov I,0
    inc K
    cmp K,16
    jne @NoNext
    mov K,0
    add si,16*8
  @NoNext:

    pop cx
    loop @RepLoop

  END;{}


PROCEDURE LoadFont;ASSEMBLER;
VAR
    M:Word;

  ASM
  mov [M],0
  @MLoop:

    push M
    push ds
    push offset tempchar
    call getcharbitmap

    les di,Font
    mov ax,M
    mov bx,16*8
    imul bx
    add di,ax

    xor bx,bx

    mov dx,7

    xor si,si
   @IKLoop:
      mov al,byte ptr ds:[tempchar+bx]
      mov cx,dx
      @ShLoop:
        or cx,cx
        jz @ShEnd
        shr al,1
        dec cx
        jmp @ShLoop
      @ShEnd:

      and al,1
      cmp al,1
      jne @SetNull
      mov byte ptr es:[di],15
      jmp @SetEnd
@SetNull:
      mov byte ptr es:[di],0
@SetEnd:
      inc di

      or dx,dx
      jnz @NoBitChng
      inc bx
      mov dx,8
@NoBitChng:
      dec dx

      inc si
      cmp si,128
    jl @IKLoop
    inc [M]
    cmp M,256
  jl @MLoop
  call SmoothFont;
  END;

PROCEDURE LoadMem(Addr:Pointer;Size:LongInt);
BEGIN
  Move(tScreen(MemPoi^)[MemInd],Addr^,Size);
  Inc(MemInd,Size);
END;

PROCEDURE InitMemLoad(Addr:Pointer);
BEGIN
  MemPoi:=Addr;
  MemInd:=0;
END;

FUNCTION AktMemPoi:Pointer;
BEGIN
  AktMemPoi:=@(tScreen(MemPoi^)[MemInd]);
END;

BEGIN
  KeyPressed_:=False;
{  FillChar(KeySave,SizeOf(KeySave),0);}
{  Frames:=0;
  HighestF:=0;}
  New(Font);
END.