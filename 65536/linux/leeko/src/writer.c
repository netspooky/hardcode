
#include <math.h>
#include <string.h>
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "palikka.h"
#include "volume.h"
#include "writer.h"

#define CHARS 37
#define YS 9

extern unsigned char fontdata[];

static int off[CHARS];

void writer_init(void)
{
    int x,y,k=-2,i=0;

    for(x=0;x<256;x++)
    {
        for(y=0;y<YS;y++)
        {
            if(fontdata[x+y*256]!=0xff)
            {
                if(fontdata[x+y*256]!=k)
                {
                    k=fontdata[x+y*256];
                    off[i++]=x;
                }
            }
        }
    }
}

void write_string(char *s,int rev,int clr,int mod)
{
    int x,y,dx,n,o,len=strlen(s),
        xs,c,i;
    static char volume[(YS+2)*1000];

    for(n=0,xs=1;n<len;n++)
    {
        c=s[n];
        i=-1;
        if(c>='a' && c<='z')
            i=c-'a';
        if(c>='0' && c<='9')
            i=26+c-'0';
        if(i==-1)
            xs+=3;
        else
            xs+=off[i+1]-off[i]+1;
    }

    memset(volume,0,(xs)*(YS+2));

    o=1+xs;
    for(n=0;n<len;n++)
    {
        c=s[n];
        i=-1;
        if(c>='a' && c<='z')
            i=c-'a';
        if(c>='0' && c<='9')
            i=26+c-'0';

        if(i==-1)
        {
            for(y=0;y<YS;y++)
                for(x=0;x<3;x++)
                    volume[o+y*xs+x]=0;
            o+=3;
        }
        else
        {
            dx=off[i+1]-off[i];

            for(y=0;y<YS;y++)
            {
                for(x=0;x<dx;x++)
                {
                    if(fontdata[off[i]+x+y*256]!=0xff)
                        volume[o+xs*y+x]=1;
                }
            }
            o+=dx+1;
        }
    }

    for(y=o=0;y<YS+2;y++)
    {
        for(x=0;x<xs;x++,o++)
        {
            if(rev)
                volume[o]=1-volume[o];
            if(volume[o])
            {
                if(mod>=WR_SINGLE && mod<=WR_THREE)
                    volume[o]=clr+o%mod;
                if(mod&WR_ROWS)
                    volume[o]=clr+y%(mod&3);
                if(mod&WR_COLS)
                    volume[o]=clr+x%(mod&3);
                if(mod&WR_CHECKER)
                    volume[o]=clr+(x+y)%(mod&3);
            }
        }
    }

    draw_volume(1,4, volume, xs,YS+2,1);
}
