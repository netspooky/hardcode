#define pwplib_volume 64

#ifndef STANDALONE

#include "pwpdemo.h"

#endif

struct
{
   unsigned char*code,*codeptr;
   int tonextcmd;

   unsigned char seq[3][64];
   int seqptr[3],seqlgt[3];
   unsigned char seqbase[3];
   unsigned char notes[16];

   int tick,tempo;
}player;

static char musicode[] =
{
#include "musa.h"
};

void newnote()
{
   player.tonextcmd--;

   while(player.tonextcmd<=0)
   {
      unsigned int cmd=*player.codeptr++;

#ifdef STANDALONE
      printf("command %d\n",cmd);
#endif

      if(cmd<4) /* SEQn,howmany,noteindices */
      {
         int i=0,lgt;
         player.seqptr[cmd]=0;
         player.seqlgt[cmd]=lgt=(unsigned char)*player.codeptr++;

         for(;i<lgt;i++) player.seq[cmd][i]=*player.codeptr++; 
      }
      if(cmd==4) /* NOTES,howmany,notes */
      {
         int i=0;
         int lgt=*player.codeptr++;

         for(;i<lgt;i++) player.notes[i]=*player.codeptr++;
      }
      if(cmd==5) /* RELOOP */
      {
         player.codeptr=player.code;
      }
      if(cmd==6) /* WAIT,ticks */
      {
         player.tonextcmd=*player.codeptr++;
      }
      if(cmd==7) /* BASES,bases3 */
      {
         int i=0;
         for(;i<3;i++)player.seqbase[i]=*player.codeptr++;
      }
   }

   {int c=0;
    for(;c<3;c++)
    {
       int noteidx=player.seq[c][player.seqptr[c]];
       int note;

       if(noteidx>=128) note=noteidx; else
                        note=player.notes[noteidx]-5+player.seqbase[c];
/*
       printf("%d %d/%d\n",note,player.seqptr[c],player.seqlgt[c]);
*/
       player.seqptr[c]++;
       if(player.seqptr[c]>=player.seqlgt[c]) player.seqptr[c]=0;

       if(note<128) note+=player.seqbase[c];

      if(note==254)
         pwplib_sound_nv(c,0,0);
      else 
      if(note!=255)
         pwplib_sound_nv(c,note<<8,pwplib_volume);
     }
   }
#ifdef STANDALONE
   printf("\n");
#endif
}

void playtick()
{
   if(player.tick==0)
      newnote();

   player.tick++;
   if(player.tick==player.tempo)
     player.tick=0;
}

void initplayer()
{
   player.tonextcmd=0;
   player.code=player.codeptr=musicode;

   player.tick=0;
   player.tempo=4;
#ifndef STANDALONE
   pwplib_setplayer(playtick);
#endif
}

#ifdef STANDALONE

pwplib_sound_nv(int c,int n,int v)
{
   printf("%d %d |",c,n>>8,v);
}

main()
{
   initplayer();
   for(;;) playtick();
}

#endif
