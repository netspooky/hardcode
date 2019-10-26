UNIT _Font;
INTERFACE
USES Crt,MainDefs;
TYPE
     VideoType = (vtEGA, vtVGA, vtOlder);
CONST
      CurrentFontBank : Byte = 0;     { current font bank we programming }
      VidType  : VideoType = vtVGA;   { video adapter in use }
      BankIncrement   = 16384;        { size of font bank in bytes }
TYPE
     CharBitmap = array[0..31] of Byte; { character Bitmap array }
     CharBit=ARRAY[0..16*8-1]OF Byte;
     tFont=ARRAY[0..255]OF CharBit;

VAR Font:^tFont;

PROCEDURE BufText(VAR Scrp:TScreen;X,Y:LongInt;ST:STRING);
PROCEDURE LoadFont;

IMPLEMENTATION

PROCEDURE BufText(VAR Scrp:TScreen;X,Y:LongInt;ST:STRING);
VAR I,K,M,WX,WY:LongInt;
    Nyx:Boolean;

PROCEDURE DrawAt(X,Y,N:LongInt);
VAR I,K,M,W,WW:LongInt;
BEGIN
  FOR K:=0 TO 15 DO BEGIN
    W:=(K+Y)*320+X;
    WW:=K*8;
    FOR I:=0 TO 7 DO BEGIN
      IF Font^[N][WW+I]<>0 THEN
        Scrp[W+I]:=Font^[N][WW+I];
    eND;
  END;
END;

BEGIN
  FOR I:=1 TO Length(ST) DO
    DrawAt(X+(I-1)*8,Y,Ord(St[I]));
END;

procedure getCharBitmap( C : Word; var Bitmap );FORWARD;
procedure setCharBitmap( C : Word; var Bitmap );FORWARD;

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
        mov     cl,CurrentFontBank
        sub     ch,ch
        cmp     VidType,vtEGA
        jz      @@100
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

procedure setCharBitmap; assembler;
{ writes character bitmap to VRAM. Does not change character if it is used for
  mouse pointer }
asm
        mov     di,C
        shl     di,5
        mov     cl,CurrentFontBank
        sub     ch,ch
        cmp     VidType,vtEGA
        jz      @@100
        cmp     cl,4
        jb      @@100
        add     di,8192
@@100:
        jcxz    @@copy
@@lp:
        add     di,BankIncrement
        loop    @@lp
@@copy:
        mov     cl,16
        push    SegA000
        pop     es
        push    ds
        lds     si,Bitmap
        cld
        call    MoveChar
        pop     ds
@@skip:
end;


PROCEDURE LoadFont;
VAR I,K,M,Bi,By:LongInt;
    PalNoir:PAL_ARRAY;
    Temp:CharBitmap;
    F:FILE;

BEGIN
  FillChar(Temp,32,0);
FOR M:=0 TO 255 DO BEGIN
  GetCharBitmap(M,Temp);
  Bi:=7;
  By:=0;
  FOR K:=0 TO 15 DO
    FOR I:=0 TO 7 DO BEGIN
      IF (Temp[By] AND (1 SHL Bi))<>0
        THEN Font^[M][K*8+I]:=15
        ELSE Font^[M][K*8+I]:=0;
      Dec(Bi);
      IF Bi=-1 THEN BEGIN
        Bi:=7;
        Inc(By);
      END;
    END;
END;
{  SmoothFont;}
END;
BEGIN
  New(Font);
  VidType:=vtVGA;
  CurrentFontBank:=0;
END.