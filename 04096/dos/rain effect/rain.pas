{Rain Effect by Raphius / Anubis                }
{(!) 1997 WWW : Http://users.skynet.be/henrraph }

{If you use this code greetz me ! Sorry for the }
{comments, french... !                          }
{                                               }
{Note : Very special no ;) Not me who writted   }
{       all ! Hummmm I think you can change a   }
{       lot of things in this code ;)           }
{                                               }
{Happy coding folks !                           }

Program Pluie;

Uses Crt;

Const
 vga = $a000; {Notre segment VGA}

Var
 j : Integer;

{Cette procedure vous met en mode 320*200*256}
Procedure SetMCGA; Assembler;
Asm
 mov ax,13h
 int 10h
End;

{Cette procedure vous remet en mode 80*25 -> Mode Texte}
Procedure SetTEXT; Assembler;
Asm
 mov ax,03h
 int 10h
End;

{Attend le retour de Balayage !!}
Procedure WaitRetrace; Assembler;
Asm
 mov dx,3dah
@l1:
 in al,dx
 test al,8
 jnz @l1
@l2:
 in al,dx
 test al,8
 jz @l2
End;

{Ceci effectue la rotation de la palette}
Procedure Rotationpalette;
Var
 i : Word;
Begin
 inc(j);
 port[968] := 35;
 i := 200;
 waitretrace; {Attend le retour de Balayage !!}
 while i>1 do
  {Notre palette :)}
  begin
    port[969]:=1-((i-j) and 160);
    port[969]:=200;
    port[969]:=1-((i+j) and 30);
    dec(i);
    end;
end;

{Comme son nom l'indique on cree la pluie !}
Procedure Creepluie;
Var
 x,y,i,j:word;
begin
  j:=1;
  Randomize; {Initialise notre table des Randoms !}
  for x:=0 to 320 do {Axe X = 320 Horizontal}
  Begin
    i:=random(15);
   for y:=0 to 200 do {Axe Y = 200 Vertical}
    Begin
      if i>64 then i:= 1; {Si i = 64 -> i = 1}
      mem[vga:x+320*y]:=i+35; {Place sur l'ecran au segment $a000 = vga}
      inc(i,j);
    end;
    j:=random(5)+1;
  end;
end;


{*-Programme Principal-*}
Begin
 SetMCGA;         {Actionne le mode graphique}
 Creepluie;       {Cree la simulation de pluie}
 Repeat           {R‚p‚ter}
  RotationPalette;{Effectue la rotation de la palette}
 Until Keypressed;{Jusqu'a ce qu'une touche soit press‚e}
 SetTEXT;         {Reviens en mode Texte}
End.


