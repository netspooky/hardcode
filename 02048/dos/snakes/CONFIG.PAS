uses crt,strings;

const
        KLit = 100;
var
	KolorGlowki:		char;
	KolorGlowki2:		char;
	KolorGracza:		char;
	KolorGracza2:		char;
	KolorRamek:		char;
	KolorTla:		char;
	KierunekGracza:		char;
	KierunekGracza2:	char;
	Speed:			char;
        TrybGry:                char;
	f:			text;

        c:                      char;
        b:                      byte;
        Kupa:                   string;


procedure Pisz(s: string;k:byte);
var
d:word;
begin
    Kupa:=s;
    d:=length(s);
    asm
       push ds
       mov ax,seg Kupa
       mov ds,ax

       lea si,Kupa
       inc si

       mov cx,d
@Wypisuj:
       mov ah,0eh
       mov al,byte ptr ds:[si]
       mov bl,k
       int 10h
       inc si
       loop @Wypisuj
       pop ds
    end;
end;


procedure PiszLn(s: string;k:byte);
var
d:word;
begin
    Kupa:=s;
    d:=length(s);
    asm
       push ds
       mov ax,seg Kupa
       mov ds,ax

       lea si,Kupa
       inc si

       mov cx,d
@Wypisuj:
       mov ah,0eh
       mov al,byte ptr ds:[si]
       mov bl,k
       int 10h
       inc si
       loop @Wypisuj

       mov ah,0eh
       mov al,13
       mov bl,k
       int 10h

       mov ah,0eh
       mov al,10
       mov bl,k
       int 10h
       pop ds
    end;
end;

label Menu,SieMa;
begin

assign(f,'CONFIG.JAH');
reset(f);
read(f,KolorGlowki);
read(f,KolorGlowki2);
read(f,KolorGracza);
read(f,KolorGracza2);
read(f,KolorRamek);
read(f,KolorTla);
read(f,KierunekGracza);
read(f,KierunekGracza2);
read(f,Speed);
read(f,TrybGry);
close(f);

Menu:
asm
    mov ax,13h
    int 10h

end;
{clrscr;}
piszln('Wybierz opcje:',KLit);
piszln('1. Kolor glowki gracza prawego',ord(KolorGlowki));
piszln('2. Kolor glowki gracza lewego',ord(KolorGlowki2));
piszln('3. Kolor gracza prawego',ord(KolorGracza));
piszln('4. Kolor gracza lewego',ord(KolorGracza2));
piszln('5. Kolor tla',ord(KolorTla));
piszln('6. Szybkosc gry',KLit);
piszln('7. Kolor ramek',ord(KolorRamek));
piszln('8. Tryb gry',Klit);

piszln('q. Wyjscie',KLit);

c:=readkey;

if c='q' then goto SieMa;
if c='Q' then goto SieMa;


piszln(' ',Klit);
piszln(' ',Klit);

if c='1' then begin
   piszln('Podaj kolor glowki gracza prawego: ',KLit);
   readln(b);
   KolorGlowki:=chr(b);
end;

if c='2' then begin
   piszln('Podaj kolor glowki gracza lewego: ',Klit);
   readln(b);
   KolorGlowki2:=chr(b);
end;

if c='3' then begin
   piszln('Podaj kolor gracza prawego: ',Klit);
   readln(b);
   KolorGracza:=chr(b);
end;

if c='4' then begin
   piszln('Podaj kolor gracza lewego: ',Klit);
   readln(b);
   KolorGracza2:=chr(b);
end;

if c='5' then begin
   piszln('Podaj kolor tla: ',KLit);
   readln(b);
   KolorTla:=chr(b);
end;

if c='6' then begin
   piszln('Podaj szybkosc gry w skali 1 do 9',Klit);
   piszln('1 - najszybsza, 9 - najwolniejsza: ',Klit);
   readln(b);
   Speed:=chr(b);
end;

if c='7' then begin
   piszln('Podaj kolor ramek: ',Klit);
   readln(b);
   KolorRamek:=chr(b);
end;

if c='8' then begin
   piszln('Wybierz tryb gry:',Klit);
   piszln('1. Dwoch graczy bez kreski',Klit);
   piszln('2. Jeden gracz bez kreski',Klit);
   piszln('3. Dwoch graczy z kreska',Klit);
   readln(b);
   dec(b);
   TrybGry:=chr(b);
end;

goto Menu;

SieMa:

assign(f,'CONFIG.JAH');
rewrite(f);

write(f,KolorGlowki);
write(f,KolorGlowki2);
write(f,KolorGracza);
write(f,KolorGracza2);
write(f,KolorRamek);
write(f,KolorTla);
write(f,KierunekGracza);
write(f,KierunekGracza2);
write(f,Speed);
write(f,TrybGry);

close(f);
asm
mov ax,3
int 10h
end;
end.