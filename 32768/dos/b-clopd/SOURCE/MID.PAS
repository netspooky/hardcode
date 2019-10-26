program MID_Beispielprogramm;

uses wavmid;


BEGIN
 initmidi;
 IF ParamCount>0 THEN playmidi(ParamStr(1))
                 ELSE playmidi('z3-dw.mid');
 readln;
 closemidi;
END.