UNIT GM_EDGFX;

INTERFACE

  USES Graph,Crt;

  PROCEDURE GrafikEin;

IMPLEMENTATION

  VAR Gd,Gm,Modus:Integer;

  {$F+}

  FUNCTION DetectVGA:Integer;
    VAR DD,SM:Integer;
    BEGIN
      DetectGraph(DD,SM);
      IF (DD=VGA) OR (DD=MCGA) THEN DetectVGA:=Modus
                               ELSE DetectVGA:=grError
    END;

  {$F-}

  PROCEDURE GrafikEin;
    VAR ADP:Pointer;
    BEGIN
      Modus:=2;
      DirectVideo := False;
      ADP:=@DetectVGA;
      Gd:=InstallUserDriver('Svga256',ADP);
      Gd:=Detect;
      InitGraph(Gd,Gm,'');
    END;

END.

