#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>
#include <fcntl.h>
#include <io.h>
#include <ctype.h>
#include <alloc.h>
#include <dir.h>
#include <process.h>

extern char FUCKYOU[64768];
extern char FONT[33588];

unsigned int *fontoff;

#define MAXFLAKES   3000
#define SPEEDFACTOR 4
#define SHIFTFACTOR 3

int SCREENTOP=130;
int SCREENSTART=10;

#undef outportb
#undef outp
#undef inp
#undef inportb

int killflakes=0;

typedef struct {
    int speed;
    int xloc;
    int yloc;
    int plotted;
} flake;

flake *snow[MAXFLAKES];
char *grfaddr;

int poss[100];
int nposs;
int wh=1;

char blank[320];

void coolcls(void);

#define prerow(firstrow) outport(0x3d4,0x08); outport(0x3d5,firstrow)

void vsync(void)
{
    asm mov dx,0x3da;
l1:
    asm in al,dx;
    asm test al,8;
    asm jz l1;
l2:
    asm in al,dx;
    asm test al,8;
    asm jnz l2;
}

void setoff(char offsetus)
{
    vsync();
    asm MOV DX, 0x3d4;
    asm MOV AL,0x13;
    asm MOV AH, offsetus;
    asm OUT DX,AX;
}

void maxscan(int value)
{
        register ptemp;

        _BX = (char) value;
        asm MOV AL,9;
        asm MOV AH, BL;
        asm MOV ptemp, AX;
        outport(0x3d4,ptemp);
}

void vsync_start(void)
{
    asm mov dx,0x3da;
l1:
    asm in al,dx;
    asm test al,8;
    asm jz l1;
}

void vsync_end(void)
{
    asm mov dx,0x3da;
l2:
    asm in al,dx;
    asm test al,8;
    asm jnz l2;
}

void startoff(int offsetus)
{
    _BX = offsetus;

    asm mov al, 0xc;
    asm mov ah, bh;
    asm mov dx, 0x3d4
    asm out dx, ax
    asm mov al,0xd;
    asm mov ah,bl;
    asm out dx, ax
}

void presetrowscan(char s)
{
        char tmp;

        outportb(0x3d4, 8);
        tmp=inportb(0x3d5);
        outportb(0x3d5, (tmp & 0xE0) | (s & 0x0F));
}
 
void setscanstart(int i)
{
        vsync_end();
        startoff((i / 16)*80);
        vsync_start();
        presetrowscan(i);
}

void setsplitscan(int s)
{
   unsigned int i;

   if(wh) i=s; else i=(2*25*16-s);
   setscanstart(i);
   if(wh==1) wh=0; else wh=1;
}

void init_split(void)
{
        int vel=1, i, n=1, fd;

        i=(25*16);
   
        do {
                poss[n]=i;
                i-=(vel / 5);
                vel++;
                n++;
        } while( i > 0);
        
        nposs=(n-1);
}

void splitin(char *buf)
{
        int i, x;
 
        init_split();
        movedata(FP_SEG(buf), FP_OFF(buf), 0xb800,4000,4000);
        startoff(2000);
        for(x=0;x<4000;x++) pokeb(0xb800,x,0);
        for(x=8000;x<12000;x++) pokeb(0xb800,x,0);
        
        for(i=1;i<nposs;i++) setsplitscan(poss[i]);
}  

void splitout(char *buf)
{
        int i, x;

        init_split();
        movedata(FP_SEG(buf), FP_OFF(buf), 0xb800,4000,4000);
        for(x=0;x<4000;x++) pokeb(0xb800,x,0);
        for(x=8000;x<12000;x++) pokeb(0xb800,x,0);
        for(i=nposs;i>0;i--) setsplitscan(poss[i]);

        movedata(FP_SEG(buf), FP_OFF(buf), 0xb800,0,4000);
        startoff(0); prerow(0);
        for(x=4000;x<8000;x++) pokeb(0xb800,x,0);
}        

void changecolor(int kulr, int r)
{
    outp(0x3c8,(char)kulr);
    outp(0x3c9,(char)r);
    outp(0x3c9,(char)r);
    outp(0x3c9,(char)r);
}

void makesnow(void)
{
    int x, y=0;

    for(x=0;x<MAXFLAKES;x++) snow[x]=(flake *)calloc(1, sizeof(flake));

    randomize();

    for(x=0;x<MAXFLAKES;x++) {
        delay(1);
        snow[x]->speed = ((rand() % SPEEDFACTOR) + 1);
        snow[x]->xloc = (rand() % 320);
        snow[x]->yloc = (rand() % 200);
        snow[x]->plotted = 1;
    }

    for(x=1;x<SPEEDFACTOR+1;x++) {
        y+=(60 / SPEEDFACTOR);
        changecolor((250+x),y);
    }
}

char _fastcall getpixel(register int x, register int y)
{
    return( peekb( 0xa000, ( x + (y * 320) ) ) );
}

void _fastcall putpixel(register int x, register int y, char color)
{
    pokeb( 0xa000, ( x + (y * 320) ), color);
}

void _fastcall blankline(int line)
{
    movedata(FP_SEG(blank), FP_OFF(blank), 0xa000, line*320, 320);
}

void _fastcall drawline(int line)
{
    movedata(FP_SEG(FUCKYOU), FP_OFF(FUCKYOU)+(line*320), 0xa000, line*320, 320);
}

void _fastcall makenewflake(register int x)
{
    snow[x]->speed = ((rand() % SPEEDFACTOR) + 1);
    snow[x]->xloc = (rand() % 320);
    snow[x]->yloc = (rand() % 200);
    snow[x]->plotted = 1;
}

void _fastcall top_clearflake(register int flakeno)
{
    register int offset;

    offset = ( snow[flakeno]->xloc + (snow[flakeno]->yloc*320) );

    grfaddr[offset]=0;
}

void _fastcall top_showflake(register int x)
{
    register int offset;

    if(killflakes) return;

    offset = ( snow[x]->xloc + (snow[x]->yloc*320) );

    grfaddr[offset]=FUCKYOU[offset];
}

void _fastcall bottom_showflake(register int x)
{
    register int offset;

    if(killflakes) return;

    offset = snow[x]->xloc + (snow[x]->yloc * 320);

    if( grfaddr[offset] ) {
        snow[x]->plotted=0;
        return;
    }

    grfaddr[offset]=(250+snow[x]->speed);
    snow[x]->plotted=1;
}

void _fastcall bottom_clearflake(register int x)
{
    register int offset;

    if(!snow[x]->plotted) return;

    offset = snow[x]->xloc + (snow[x]->yloc * 320);

    if(snow[x]->yloc > SCREENSTART) grfaddr[offset]=FUCKYOU[offset];
        else grfaddr[offset]=0;
}

void _fastcall doflakes(void)
{
    register int x;

    for(x=0;x<MAXFLAKES;x++) {
        if(snow[x]->yloc < SCREENTOP && snow[x]->yloc > SCREENSTART) top_clearflake(x);
            else bottom_clearflake(x);

        snow[x]->xloc+=snow[x]->speed;
        snow[x]->yloc+=snow[x]->speed;

        if(snow[x]->yloc > 199 || snow[x]->xloc>319) makenewflake(x);

        if(snow[x]->yloc < SCREENTOP && snow[x]->yloc > SCREENSTART) top_showflake(x);
            else bottom_showflake(x);
    }
}

void showsnow(void)
{
    register int x, tempval;

    asm cli;

    while(inp(0x60) >= 0x80)  {
        vsync_start();
        doflakes();
    }

    for(x=SCREENTOP;x<200;x++) {
        vsync();
        blankline(x);
        SCREENTOP++;
        doflakes();
    }

    for(x=0;x<200;x++) {
        vsync();
        blankline(x);
        SCREENSTART++;
        doflakes();
    }

    asm sti;
}

void slopal(char *pal)
{
    register int x;

    outportb(0x3c8, 0);
    for(x=0;x<768;x++) outportb(0x3c9, pal[x]);
}

void fade_in(char *_pal)
{
        register int x, y;
        char pal[768];

        for(x=0;x<768;x++) pal[x]=0;

        for(x=0;x<64;x++) {
            for(y=0;y<768;y++) if(pal[y] < _pal[y]) pal[y]++;
            vsync_start();
            slopal(pal);
        }
}

void no_pal(void)
{
        register int x;
        char pal[768];

        for(x=0;x<768;x++) pal[x]=0;
        slopal(pal);
}

void fadein(char temps[])
{
        int xxx, y;
        char fuck[128];
        int colorama[] = { LIGHTCYAN, LIGHTBLUE, BLUE, LIGHTBLUE, CYAN, LIGHTCYAN,
                           WHITE, LIGHTGRAY };

        _setcursortype(_NOCURSOR);

        strcpy(fuck," ");
        strcat(fuck, temps);
        strcat(fuck,"        ");

        for(xxx=1;xxx<strlen(fuck);xxx++) {
                textcolor(colorama[0]);
                gotoxy(xxx,wherey());
                putch(fuck[xxx]);
                for(y=0;y<8;y++) {
                if(xxx>y) {
                        textcolor(colorama[y]);
                        gotoxy(xxx-y,wherey());
                        putch(fuck[xxx-y]);
                        }
                }
                delay(45);
        }
        if(wherey() > 24) {
            gotoxy(1,1); delline();
            gotoxy(1,25);
        } else gotoxy(1,wherey()+1);
}

void putletter(char ltr, int xval, int yval)
{
    unsigned int letteroff;
    char xsize, ysize;
    register unsigned int x, y, offset, fntoff;

    letteroff = fontoff[ltr];
    ltr=FONT[letteroff];
    xsize=FONT[letteroff+1];
    ysize=FONT[letteroff+2];
    letteroff+=3;

    for(x=0;x<(unsigned int)xsize;x++) {
        for(y=0;y<(unsigned int)ysize;y++) {
            offset = ( (xval + x) + ( (y + yval) * 320 ) );
            fntoff = ( ( y + ( x * ysize ) ) + letteroff );
            grfaddr[ offset ] = FONT[ fntoff ];
        }
    }
}

void putstring(char *thing)
{
    int x;
    static int off, yoff;

    for(x=0;x<strlen(thing);x++) {
        if(yoff > 160) {
            off = 0;
            yoff = 0;
            coolcls();
        }
        if(thing[x] == '\n') {
            off = 0;
            yoff += 35;
            continue;
        }
        if(off > 280) {
            off = 0;
            yoff += 35;
        }
        putletter(thing[x], off, yoff);
        off+=FONT[fontoff[thing[x]]+1];
        off+=2;
        delay(50);
    }
}

void coolcls(void)
{
    int x;

    delay(150);

    for(x=0;x<200;x++) {
        vsync_start();
        if( x % 2) movedata(FP_SEG(blank), FP_OFF(blank), 0xa000, (x*320), 320);
    }
    for(x=200;x>-1;x--) {
        vsync_start();
        if(!( x % 2)) movedata(FP_SEG(blank), FP_OFF(blank), 0xa000, (x*320), 320);
    }
}

void main(void)
{
    register unsigned int x;
    int oldx, oldy;
    char *buf;

    grfaddr=MK_FP(0xa000,0);
    fontoff=MK_FP(FP_SEG(FONT), FP_OFF(FONT)+773);
    buf = calloc(1, 4000);
    oldx=wherex(); oldy=wherey();

    movedata(0xb800,0,FP_SEG(buf),FP_OFF(buf), 4000);
    splitin(buf);

    textmode(19);
    no_pal();
    movedata(FP_SEG(FUCKYOU), FP_OFF(FUCKYOU)+3200, 0xa000, 3200, 64000-3200);
    fade_in(FUCKYOU+64000);
    makesnow();
    for(x=0;x<48000;x++) pokeb(0xa000,x,0);
    showsnow();

    coolcls();
    slopal(FONT+5);
    putstring("lithium\npresents a\nsmall\nintro...");
    delay(1000);
    putstring("coded all\nby poor\nnatas...\ncalled\nsnowtro\n");
    putstring("greets to:\npatch of\navalanche\ncall our\n");
    putstring("bbs at\n715-832-8325\nphantom bbs\n");
    putstring("this demo\nuses the\nlithium\nadvanced\nflake\nprocessing\nunit");
    putstring("\nour diskmag\nalt one issue\nfifteen\nis coming\nout soon...");
    delay(2000);
    coolcls();

    textmode(3);

    splitout(buf);
    gotoxy(oldx, oldy);
    fadein("by natas of lithium.");
    fadein("hanson4@nes.nersc.gov");
}
