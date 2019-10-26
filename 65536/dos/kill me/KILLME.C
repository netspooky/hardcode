// #include "pcx.c"
#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <alloc.h>
#include <string.h>
#include "vga13.c"

#pragma inline
struct p{
        int x,y,z;
        } point[150];
word exesize=0;                 // check crc gunceller
word aexesize=19061;            // asil exe boyu
word picturesize=36837;
word fontsize=1024;
word sx,sy,s1,s2,s3,s4,mx,my,col;
unsigned int byt,byt2,byt3;
long lo;
unsigned int s_pic,s_page,yatay;
char far *pic;
char far *page;
char *f;
unsigned char yony,yonx,ok;
FILE *filex,*pict;
FILE *crc;
char tpos,yon,yon2;
char textx[]= {" cOdiNg bY cRoW gFx bY GHOST RIDER! mUSic bY gRAbeD! aND wE aRe liVinG tHe siVas"};
char textx2[]={" tiMe iS 23:36 dATe 30/08/1997 gRoUnD gUmUsHAne"};
unsigned char pal[]={15,7,7,8};
char *text[]={
"               BU iNTRO              ",
"        SiVAS`TAKi MANDA SURUSU      ",
"          iNSAN BOZUNTULARINA        ",
"             ARMAGAN OLSUN           ",
"                  VE                 ",
"           BiZLER HER ZAMAN          ",
"        BU KENDiNi iNSAN SANAN       ",
"             COPLUK YIGINI           ",
"            iNSAN BOZUNTUSU          ",
"             MAGANDALARIN            ",
"          UZERiNDE HER ZAMAN         ",
"               EN TEPEDE             ",
"       HER ZAMAN SAGLAM VE SERT      ",
"             OLARAK DURMAYA          ",
"       !!!! DEVAM EDECEGiZ !!!!      ",
"     !!YYYYYEEEEEEAAAAHHHHHHHH!!     ",
"      thiS iNtrO cOdeD bY cRoW!!     ",
"     i'M rEal nAmE iS eRtAN tiKe     ",
"           biR cOdeR oLarAk          ",
"          VB ve DELPHIcileri         ",
"     lAmErciLerDen dAhA aSagILik     ",
"       gOrdUgUmu sOyLeMeliYiM        ",
"    bUne kUsTahlIk diYeNLeR iCin     ",
"     FFUUUUUCCCCCKK OOOOOFFFFF!      ",
"         GFX BY GHOST RIDER!!        ",
"    ReaL NamE: Artur KATRANCIOGLU    ",
"   \x7f\x7f\x7f\x7f\x7f\x7fR\x7f\x41\x7fV\x7f\x45\x7fN\x7fR\x7fU\x7fL\x7f\x45\x7fZ\x7f\x7f\x7f\x7f\x7f  "
};
word xlat[]={0,5,5,5,6,6,7,7,8,9,10};
word xlat2[]={38,39,40,41,42,42,43,43,44,44,44};
void interrupt far (*oldhandler)();
extern a_init();
extern a_dorow();
void printchar(ch,x,y,seg)
char ch;
word x,y,seg;
{
byte a,b,c;
for (b=0;b<=7;b++)
{
c=f[(ch << 3)+b];               //3 kaydirma 8 ile carpma demek her karakter 8 byt
for (a=0;a<=7;a++)
        {
                asm     {                       // karakter bitlerini birkez donder
                                push ax
                mov al,c
                rol al,1
                mov c,al
                pop ax
                }
        if ( (c&1) == 1)        // birinci birse ekrana yaz
                putpixel(x,y,a+224+b,seg);
        x++;
        }
y++;x-=8;
}}
void makestar(word s)
{
        point[s].x=60-random(mx);
        point[s].y=60-random(my);
        point[s].z=100+random(256);
}
void interrupt keyb()
{
asm{
                in      al,60h
                push    ax
                in      al,61h
                or      al,80h
                out     61h,al
                and     al,7Fh
                out     61h,al
                pop     ax
                mov     al,20h
                out     20h,al
}
}
void checkcrc()
{
s1=0;s2=0;s3=0;
if ((crc=fopen("KILLME.EXE","rb"))==NULL)
        {
        printf("\nexe name must be is KILLME.EXE [exe adi KILLME.EXE olmali]");
        exit(0);
        }
exesize=filelength(fileno(crc));
fseek(crc,0L,SEEK_SET);                 // sonra dene
// while(!feof(crc))
ok=0;
for(sx=0;sx<=(exesize-3);sx++)
           {
           fread(&ok,1,1,crc);
           s1+=ok;
           }
                // bunun nedenini bulamadim ama heralde eksik okunuyor
                // ama bunsuzda calismaz!
fseek(crc,exesize-2,SEEK_SET);                  // sonra dene
fread(&s2,2,1,crc);
        ///     s1=s1-( ( (s2&0xFF00)>>8) + (s2&0x00FF) );
if (s1!=s2)
        {
        printf("EXE file is changed VIRUS warning!![exe degismis virus tehlikesi]");
        fclose(crc);
        exit(0);
        }
printf(".");
fclose(crc);
}

void main()
{
printf("initialising...");
s1=0;s2=0;s3=0;
checkcrc();
yon=1;s3=22;yon2=1;s4=0;yonx=0;ok=0;mx=150;my=70;s2=0;tpos=0;
                                              // **********memory allocations
f=malloc(128*8);page=farmalloc(0xffff);pic =farmalloc(0xffff);
if (pic==NULL)                          // eger hafiza page'ye yetmezse pic'e de yetmez de mi...
        {
        printf("ERROR: no memory!! you don't use qemm?\n");
        exit(0);
        }
printf(".");
s_page=FP_SEG(page);            // her seferde fp_seg cagirmaktan hizlidir heralde
s_pic=FP_SEG(pic);
mx=150;my=70;s2=0;tpos=0;
for(s1=0;s1<=149;s1++)
        makestar(s1);
s1=0;s2=0;s3=0;
filex=fopen("KILLME.EXE","rb");  // *********data readings    ** font **
clearscreen(s_page);
fseek(filex,aexesize,SEEK_SET);
/*                                  // prepare filexure palette
for(s1=0;s1<=255;s1++)
        {
        fread(&pl[s1][0],3,1,filex);
//      fread(&pl[s1][0],1,1,filex);
//      fread(&pl[s1][2],1,1,filex);
        }
*/
fread(&pl[0][0],768,1,filex);            // yukardaki kodun yerine bu daha iyi
s3=1;s1=0;
while (s1<=64000)                       // picture decompressing
        {
        fread(&byt2,2,1,filex);
        fread(&ok,1,1,filex);
        asm     {
                push es
                mov ax,s_pic
                mov es,ax
                mov cx,byt2
                mov di,s1
                mov al,ok
                rep stosb
                mov ax,s1
                add ax,byt2
                mov s1,ax
                pop es
                }
/*        for(s2=1;s2<=byt2;s2++)
                {
                poke(s_pic,s1,byt);
                s1++;
                }
*/
//        flip(s_pic,VGA);
        }
fseek(filex,exesize-1026,SEEK_SET);	 // +2 byte crc degeri
fread(f,1024,1,filex);
fclose(filex);
                                        /*pcxoku("intro.pcx");*/
delay(500);
printf("success!\n");
oldhandler = getvect(9);                // initialise keyboard
setvect(9,keyb);
for(s1=0;s1<=63;s1++)
        {
        fadeout();
        waitvbl();
        delay(20);
        }
opengraph();
for(s1=0;s1<=63;s1++)
      fadeout();
flip(s_pic,VGA);
a_init();             // initialise fm chip
while(inportb(0x60)!=1)
{
a_dorow();
if (ok<63)
        {
        ok++;fadein();
        }
if (yony==0)
        {
        my++;if (my>=250) yony=1;
        }
        else
        {
        my--;if (my<=30) yony=0;
        }
if (yonx==0)
        {
        mx++;if (mx>=250) yonx=1;
        }
        else
        {
        mx--;if (mx<=30) yonx=0;
        }
flip(s_pic,s_page);
for(s1=0;s1<=149;s1++)
                {
                sx=(256*point[s1].x)/point[s1].z;
                sy=(256*point[s1].y)/point[s1].z;
                col=255-(point[s1].z/22);
                sx+=mx;sy+=my;
                if ((sx>0)&&(sx<320)&&(sy>0)&&(sy<200))
                        {
                        if (getpixel(sx,sy,s_pic)==0)
                                putpixel(sx,sy,col,s_page);
                        }
                        else
                        {
                        makestar(s1);
                        }
                point[s1].z-=3;
                if (point[s1].z<1)
                        makestar(s1);
                }
yatay=s3;
if (s3<10)
        yatay=xlat[s3];
if (s3>38)
        yatay=xlat2[s3-38];

for(s1=0;s1<=34;s1++)
        printchar(text[tpos][s1],s1*9+yatay-28,15+s4,s_page);
s2++;
if (yon==1)
        { s3++; if (s3>44) yon=0;       }
        else
        { s3--; if (s3<2) yon=1;        };
if (yon2==1)
        { s4++; if (s4>150) yon2=0;     }
        else
        { s4--; if (s4<2) yon2=1;       };
if (s2%199==0)
          tpos++;
if (tpos>=27) tpos=0;
waitvbl();
flip(s_page,VGA);
}
closegraph();
asm mov ah,1
asm mov cx,1000h
asm int 10h
s2=pal[0];
s3=1;
for(s1=1;s1<=strlen(textx);s1++)
        {
        gotoxy(s1,10);
        for (s4=0;s4<=3;s4++)
                {
                a_dorow();
                textattr(pal[s4]);
                if (s1+s4<strlen(textx))
                        cprintf("%c",textx[s1+s4]);
		delay(15);
                }
        }
s2=pal[0];
s3=1;
for(s1=1;s1<=strlen(textx2);s1++)
        {
        gotoxy(s1,11);
        for (s4=0;s4<=3;s4++)
                {
                a_dorow();
                textattr(pal[s4]);
                if (s1+s4<strlen(textx2))
                        cprintf("%c",textx2[s1+s4]);
		delay(15);
		}
	}
asm mov ah,1
asm mov cx,0103h
asm int 10h
setvect(9,oldhandler);
a_init();
farfree(pic);
farfree(page);
free(f);

}
