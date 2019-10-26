/*
    The implementation of Syna functions

    - Marq
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "syna.h"

#define KANTTI 0
#define SINI   1
#define SAHA   2
#define KOHINA 3

#define WAVES 4
#define INSTR 30
#define PTLEN 100
#define MAXR 1000
#define BFREQ 262

#define ECHON -4
#define ECHOFF -5
#define STOP -6
#define END -2
#define LOOP -3
#define VOL -7
#define SLIDE -8

static float   *aalto[WAVES],*instr[INSTR],off[INSTR],plus[INSTR],
               *echo[INSTR],pan[INSTR],prev[INSTR],pola[INSTR],vol[INSTR],
               slide[INSTR];
static int  global,slen,update,trak[INSTR][PTLEN],ptn[MAXR][PTLEN],
            ti[INSTR],pi[INSTR],len[INSTR],ekolen;
int         lastrig[INSTR],beat=0,counter;
static char *module,eko[INSTR];

static char *notes[]={
            "c1","C1","d1","D1", "e1","f1","F1","g1", "G1","a1","A1","b1",
            "c2","C2","d2","D2", "e2","f2","F2","g2", "G2","a2","A2","b2",
            "c3","C3","d3","D3", "e3","f3","F3","g3", "G3","a3","A3","b3",
            "c4","C4","d4","D4", "e4","f4","F4","g4", "G4","a4","A4","b4",
            "c5","C5","d5","D5", "e5","f5","F5","g5", "G5","a5","A5","b5",
            "c6","C6","d6","D6", "e6","f6","F6","g6", "G6","a6","A6","b6",
            "echo1","echo0","stop","vol","sld","0"};

static int notei[]={
            0,0,0,0, 0,0,0,0, 0,0,0,0,
            0,0,0,0, 0,0,0,0, 0,0,0,0,
            0,0,0,0, 0,0,0,0, 0,0,0,0,
            0,0,0,0, 0,0,0,0, 0,0,0,0,
            0,0,0,0, 0,0,0,0, 0,0,0,0,
            1047,1109,1175,1245, 1319,1397,1480,1568, 1661,1760,1864,1976,
            ECHON,ECHOFF,STOP,VOL,SLIDE,0};

static void adsr(int a,int d,int s,int r,int mod,int swp,int ins,int wave);
static void cleanshit(char *s);

void syna_init(int freq)
{
    int n,i;

    slen=freq/BFREQ;
    global=freq;
    counter=0;

    /* Generate lower octaves from 6 */
    for(n=4;n>=0;n--)
        for(i=0;i<12;i++)
            notei[n*12+i]=notei[(n+1)*12+i]/2;

    /* Generate the waveforms */
    for(n=0;n<WAVES;n++)
        aalto[n]=malloc(slen*sizeof(float));
    for(n=0;n<slen;n++)
    {
        aalto[KANTTI][n]=(n<slen/2)?-1.0:1.0;
        aalto[SINI][n]  =sin(n*2.0*M_PI/(float)slen);
        aalto[SAHA][n]  =-1.0+fmod(1.0+2.0*n/(float)slen,2.0);
    }

    /* Noise needs to be longer */
    aalto[KOHINA]=malloc(global*sizeof(float));
    for(n=0;n<global;n++)
        aalto[KOHINA][n]=(rand()%2000-1000)/(float)1000.0;

    /* Set starting values */
    for(n=0;n<INSTR;n++)
    {
        off[n]=-1.0;
        plus[n]=0.0;
        trak[n][0]=END;
        ti[n]=-1;
        eko[n]=0;
        pan[n]=(n&1)?0.25:0.75;
        pola[n]=0.0;
        vol[n]=1;
        prev[n]=0;
        slide[n]=0.0;
        lastrig[n]=10000000; /* Very mucho */
    }
}

#ifndef TINY
int syna_load(char *tune)
{
    FILE    *f;
    long    length;

    /* Read the file and call syna_get */
    f=fopen(tune,"rb");
    if(f==NULL)
        return(-1);
    fseek(f,0,SEEK_END);
    length=ftell(f);
    fseek(f,0,SEEK_SET);
    module=malloc(length+1);
    fread(module,1,length,f);
    module[length]=0; /* String ends in zero */
    fclose(f);

    return(syna_get(module));
}
#endif

int syna_get(void *tune)
{
    int     n=0,i,j,tmp,a,d,s,r,mod,sweep,
            wave,patt,track,note;
    char    *rows[MAXR],*key,*tnp;

    module=tune;
#ifndef TINY
    cleanshit(module);  /* You better have a clean module in intros... */
#endif

    /* Extract rows */
    for(n=0;n<MAXR;n++)
    {
        rows[n]=strtok((n)?NULL:module,"\n");
        if(rows[n]==NULL)
            break;
    }

    /* Extract data from rows */
    for(i=0;i<n;i++)
    {
        if(rows[i][0]=='#')
            continue;

        if(key=strtok(rows[i],":"))
        {
            if(!strcmp(key,"bpm"))
            {
                tmp=atoi(strtok(NULL,":"))*10/25;
                update=6*global/tmp;
                ekolen=update*3;
            }
            if(key[0]=='i')
            {
                /* Get instrument number and wave form */
                tmp=atoi(&key[1]);
                echo[tmp]=malloc(ekolen*sizeof(float));
                tnp=strtok(NULL,",");
                if(!strcmp(tnp,"kantti"))
                    wave=0;
                if(!strcmp(tnp,"sini"))
                    wave=1;
                if(!strcmp(tnp,"saha"))
                    wave=2;
                if(!strcmp(tnp,"kohina"))
                    wave=3;
                
                /* Get ADSR */
                a=atoi(strtok(NULL,","));
                d=atoi(strtok(NULL,","));
                s=atoi(strtok(NULL,","));
                r=atoi(strtok(NULL,","));
                len[tmp]=a+d+s+r+1;
                instr[tmp]=malloc(len[tmp]*sizeof(float));

                mod=atoi(strtok(NULL,","));
                if(tnp=strtok(NULL,","))
                    sweep=atoi(tnp);
                else
                    sweep=0;
                if(tnp=strtok(NULL,","))
                    pan[tmp]=(float)atoi(tnp)/100.0;
                if(tnp=strtok(NULL,","))
                    pola[tmp]=(float)atoi(tnp)/100.0;

                adsr(a,d,s,r,mod,sweep,tmp,wave);
            }

            if(key[0]=='p') /* Handle pattern */
            {
                patt=atoi(&key[1]);
                j=0;
                while(1)
                {
                    tnp=strtok(NULL,",");
                    if(tnp!=NULL)
                    {
                        note=0;
                        for(tmp=0;notes[tmp][0]!='0';tmp++)
                            if(!strcmp(notes[tmp],tnp))
                                note=notei[tmp];
                        ptn[patt][j]=note;
                        if(note==VOL || note==SLIDE)
                        {
                            j++;
                            ptn[patt][j]=atoi(strtok(NULL,","));
                        }

                        j++;
                    }
                    else
                    {
                        ptn[patt][j]=END;
                        break;
                    }
                }
            }

            if(key[0]=='t') /* Handle track */
            {
                track=atoi(&key[1]);
                j=0;
                while(1)
                {
                    tnp=strtok(NULL,",");
                    if(tnp!=NULL)
                    {
                        if(!strcmp(tnp,"loop"))
                            trak[track][j]=LOOP;
                        else
                        {
                            patt=atoi(&tnp[1]);
                            trak[track][j]=patt;
                        }
                        j++;
                    }
                    else
                    {
                        trak[track][j]=END;
                        break;
                    }
                }
            }
        }
    }

    return(0);
}

void syna_play(short *dest,int length)
{
    int n,i,note;
    float  left,right,smp;

    for(n=0;n<length;n++,counter++)
    {
        /* New row */
        if(counter%update==0)
        {
            beat=counter/update/16;
            for(i=1;trak[i][0]!=END;i++)
            {
                lastrig[i]++;
                if(ti[i]==END)
                    continue;
                pi[i]++;
                if(ti[i]==-1 || ptn[trak[i][ti[i]]][pi[i]]==END)
                {
                    ti[i]++;
                    if(trak[i][ti[i]]==LOOP)
                        ti[i]=0;
                    if(trak[i][ti[i]]==END)
                        ti[i]=END;
                    pi[i]=0;
                }
                if(ti[i]!=END)
                {
                    if(note=ptn[trak[i][ti[i]]][pi[i]])
                    {
                        switch(note)
                        {
                            case STOP  : off[i]=-1.0; break;
                            case ECHON : eko[i]=1; break;
                            case ECHOFF: eko[i]=0; break;
                            case VOL   : pi[i]++;
                                         vol[i]=ptn[trak[i][ti[i]]][pi[i]]/100.0;
                                         break;
                            case SLIDE : pi[i]++;
                                         slide[i]=ptn[trak[i][ti[i]]][pi[i]]/100000.0;
                                         break;
                            default    : plus[i]=note;
                                         plus[i]/=(float)BFREQ;
                                         off[i]=0.0;
                                         lastrig[i]=0;
                        }
                    }
                }
            }
        }

        /* Sum the instruments */
        left=right=0.0;
        for(i=1;trak[i][0]!=END;i++)
        {
            smp=echo[i][(counter+1)%ekolen];

            echo[i][counter%ekolen]=echo[i][(counter+1)%ekolen]*0.6;
            if(off[i]>=0.0)
            {
                smp+=instr[i][(int)off[i]];

                if(eko[i])
                    echo[i][counter%ekolen]=smp*0.2;

                off[i]+=plus[i];
                plus[i]+=slide[i];
                if(off[i]>=len[i] || off[i]<0.0)
                    off[i]=-1.0;
            }

            if(pola[i])
                smp=smp*(1-pola[i])+prev[i]*pola[i];
            prev[i]=smp;

            smp*=vol[i];
            left+=(1-pan[i])*smp;
            right+=pan[i]*smp;
        }

        if(left<-3.0)
            left=-3.0;
        if(left>3.0)
            left=3.0;
        dest[n*2+1]=(short)(left*10922.0);

        if(right<-3.0)
            right=-3.0;
        if(right>3.0)
            right=3.0;
        dest[n*2]=(short)(right*10922.0);
    }
}

/* Make ADSR to instruments */
static void adsr(int a,int d,int s,int r,int mod,int swp,int ins,int wave)
{
    int n,modulo=slen,id=0;
    float  i=0,vol=0.0,dv,oh=0.0,op,ip=1,sweep;

    if(!a) a=1;
    if(!r) r=1;

    if(wave==KOHINA)
        modulo=global;

    if(mod) /* We modulate! */
        op=mod/100.0*2.0*M_PI/(float)slen;
    else
        op=0;

    sweep=(float)swp/1000.0/(float)slen;

    dv=1.0/(float)a;
    for(n=0;n<a;n++,i+=ip,ip+=sweep,vol+=dv,oh+=op)
        instr[ins][id++]=vol*aalto[wave][((int)i)%modulo]*((mod)?sin(oh):1.0);
    for(n=0;n<d;n++,i+=ip,ip+=sweep,vol-=dv,oh+=op)
        instr[ins][id++]=vol*aalto[wave][((int)i)%modulo]*((mod)?sin(oh):1.0);
    for(n=0;n<s;n++,i+=ip,ip+=sweep,oh+=op)
        instr[ins][id++]=vol*aalto[wave][((int)i)%modulo]*((mod)?sin(oh):1.0);
    dv=vol/(float)r;
    for(n=0;n<r;n++,i+=ip,ip+=sweep,vol-=dv,oh+=op)
        instr[ins][id++]=vol*aalto[wave][((int)i)%modulo]*((mod)?sin(oh):1.0);
}

/* Fix the fscking Windoze/DOS newlines */
#ifndef TINY
void cleanshit(char *s)
{
    char    *d=strdup(s);

    for(;*d;d++)
        if(*d!='\r' && *d!=' ')
            *s++=*d;
    *s=0;
}
#endif
