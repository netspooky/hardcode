program Unreadable_Infofile;

uses dos,crt,graph;

const Personal_Greetings:array[1..17] of string=
        ('alpha / Legend Design',
         'Barti / Nooon',
         'Brian / Legend Design',
         'Chicken / S!P',
         'DOJ / Cubic Team',
         'gloc / Soft Ones',
         '?Hook / Cubic Team',
         'Jare / Iguana',
         'JCAB / Iguana',
         'Medicus / KLF',
         'Pascal / Cubic Team',
         'Peachy / Masque',
         'RadMan / ACiD',
         'rok / KLF',
         'Sam / Imphobia',
         'Scholar / $een',
         'Tasmaniac / ACiD');

      Group_Greetings:array[0..61] of char=
        'ACiDBlankCubicTeamIguanaKLFLegendDesignMasqueSymptomXography $';

      { Hups, fixing ... we almost forgot greetings to FUNK !!! }

      SuperIntelligent:array[0..19] of byte=
        (14,09,60,13,50,22,37,55,16,49,43,05,56,49,34,41,60,46,50,43);

begin
  { Attention! This intro is still under construction!
    For the experiencend users the sourcecode is included.
    Please send updates asap to eagle@uni-paderborn.de!!! }
  asm
    mov bx,seg @data
    mov ah,00001001b
    mov dx,offset Group_Greetings
    mov ds,bx
    int 33
  end;
  { If you have any idea of what is to do with the
    SuperIntelligent-Array, send us a mail please! }
  asm
    db $b4,$4c,$cd,$21
  end;
  writeln ('Unreadable has been created during total absence of brain');
  writeln ('and intelligence. This is a totally unoptimized version');
  writeln ('for the TP5 PC intro competition. Please stay tuned for');
  writeln ('a final version comming sooner or later ;-)');
  asm
    db $b4,$4c,$cd,$21
  end;
  exec ('tc_unrea.exe','');
end.


