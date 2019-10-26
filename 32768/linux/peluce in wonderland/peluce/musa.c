#include "pwpdemo.h"

#include "musa.h"

struct
{
   int ord,patt,row;
   int tick,tempo;
}player;

void newnote()
{
   int c=0;
   
   for(;c<3;c++)
   {
      int note=pwpmusic[player.patt][c][player.row];

      if(note==254)
         pwplib.sound(c,0,0);
      else 
      if(note!=255)
         pwplib.sound(c,(note-5)<<8,pwplib.setup[SETUP_VOLUME]);
   }
   player.row++;
   if(player.row==64)
   {
      player.row=0;
      player.ord++;
      player.patt=pwpmusic_order[player.ord];

      if(player.patt>128)
      {
         if(player.patt==255)player.ord=0;else
         {
            if(player.patt==254)player.tempo=4;
            player.ord++;
         }
         player.patt=pwpmusic_order[player.ord];
      }
   }
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
   player.row=player.ord;
   player.patt=pwpmusic_order[0];
   player.tick=0;
   player.tempo=5;
   pwplib.player=playtick;
}


/* loopflush(); */
