#include <dos.h>
#include <conio.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define pi 3.14159265

unsigned char *buf1, *buf2, *swap;
unsigned char texture[64][64];

void copybuf(char *buffer)
{
    unsigned int segm, offs;

    segm=(unsigned long)buffer >> 16;
    offs=(unsigned long)buffer;
    asm
    {
        push ds
        push es
        mov ax,segm
        mov si,offs
        add si,2560
        mov ds,ax
        mov di,0A000h
        mov es,di
        mov di,2560
        mov cx,16000-2560/4
        db 66h
        rep
        movsw
        pop es
        pop ds
    }
}

unsigned int random()
{
    static int a, b, c, d, e;
    a++;
    b+=a;
    c+=b;
    d+=c;
    e+=d;
    return e;
}

char randomb()
{
    unsigned int temp;

    temp=random();
    temp^=(temp >> 8);
    temp^=(temp >> 4);
    temp^=(temp >> 2);
    temp^=(temp >> 1);
    return temp&1;
}

void retrace()
{
    asm
    {
        mov dx,3DAh
    lus1:
        in al,dx
        and al,8
        jz lus1
    lus2:
        in al,dx
        and al,8
        jnz lus2
    }
}

void cleartexture()
{
    int x, y;
    for (y=0; y<64; y++)
        for (x=0; x<64; x++)
            texture[x][y]=0;
}

void setkleuren()
{
    int teller;
    outp(0x3C8, 0);
    for (teller=0; teller<64; teller++)
    {
        outp(0x3C9, teller);
        outp(0x3C9, 0);
        outp(0x3C9, 0);
    }
    for (teller=0; teller<64; teller++)
    {
        outp(0x3C9, 63);
        outp(0x3C9, teller);
        outp(0x3C9, 0);
    }
    for (teller=0; teller<64; teller++)
    {
        outp(0x3C9, 63);
        outp(0x3C9, 63);
        outp(0x3C9, teller);
    }
    for (teller=0; teller<64; teller++)
    {
        outp(0x3C9, teller);
        outp(0x3C9, teller);
        outp(0x3C9, teller);
    }
}

void do_texture()
{
    int x, y;
    static lijn1[64], lijn2[64];
    unsigned int temp;

    for (x=0; x<64; x++)
    {
        if (randomb())
            lijn2[x]=191;
        else
            lijn2[x]=0;
    }
    for (y=0; y<63; y++)
    {
        for (x=0; x<64; x++)
        {
            temp=texture[x][y];
            temp+=texture[(x+1)&63][y+1];
            temp+=texture[(x+63)&63][y+1];
            temp+=texture[x][y+1];
            temp=temp >> 2;
            if (temp!=0) temp--;
            texture[x][y]=temp;
        }
    }
    for (x=0; x<64; x++)
    {
        temp=texture[x][63];
        temp+=lijn1[(x+1)&63];
        temp+=lijn1[(x+63)&63];
        temp+=lijn1[x];
        temp=temp >> 2;
        if (temp!=0) temp--;
        texture[x][63]=temp;
    }
    for (x=0; x<64; x++)
    {
        temp=lijn1[x];
        temp+=lijn2[(x+1)&63];
        temp+=lijn2[(x+63)&63];
        temp+=lijn2[x];
        temp=temp >> 2;
        if (temp!=0) temp--;
        lijn1[x]=temp;
    }
}

void mode(char nummer)
{
    asm
    {
        mov ah,0
        mov al,nummer
        int 10h
    }
}

void main()
{
    unsigned long x, y, tijd;
    int xx, yy;
    float rx, ry, r, d=0, d2=0, zoom, d3=0;
    unsigned int s, c, sxx, syy, cxx, cyy, xoff, yoff;
    unsigned int mempos, xxstep, xystep, yxstep, yystep;
    unsigned int xtexture, ytexture;
    int k;
    int teller;

    buf1=new char[64000];
    buf2=new char[64000];
    mode(0x13);
    cleartexture();
    setkleuren();
    gotoxy(5, 1);
    printf("Next year I'll beat ya all!!!!");
    for (teller=0; teller<2560; teller++)
    {
        if (peekb(0xA000, teller)!=0)
            pokeb(0xA000, teller, 255);
    }
    tijd=time(0)+15;
    while (!kbhit() && tijd>time(0))
    {
        do_texture();
        d+=.01;
        d2+=1;
        d3+=.01;
        xoff=sin(d3*5)*120+160;
        yoff=sin(d3)*120+100;
        mempos=0;
        zoom=sin(d);
        if (zoom<0)
            zoom=-zoom;
        s=cos(d)*1536*zoom;
        c=sin(d+pi)*1536*zoom;
        y=0;
        syy=-yoff*s;
        cyy=-yoff*c;
        for (; y<200; y++, syy+=s, cyy+=c)
        {
            x=0;
            sxx=-xoff*s;
            cxx=-xoff*c;
            for (; x<320; x++, sxx+=s, cxx+=c)
            {
                buf2[mempos]=texture[(cxx-syy)>>10][(sxx+cyy)>>10];
                mempos++;
            }
        }
        retrace();
        copybuf(buf2);
        swap=buf2;
        buf2=buf1;
        buf1=swap;
    }
    while (kbhit())
        getch();
    mode(3);
    printf("Sorry voor de korte-niet-mooie-en-dus-niet-winnende-demo\n");
    printf("maar volgend jaar wordt ie in asm en 4kB en een stuk mooier\n");
    printf("\n\n\n\n.........hoop ik............. ;)\n");
}
