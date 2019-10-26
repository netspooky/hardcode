/*
 *  PWPlib: Lossy filtering
 *
 *  Need to improve this stuff to give visible results.
 *
 */

#include "config.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "pwplib.h"

void conv_losestuff_old(u8*d,int lgtnew,int flags) /* flags&1 == fillgaps */
{
   static int lgt=0;
   static u8 *prev=NULL;

   if(lgt!=lgtnew)
   {
      if(prev!=NULL)
         free(prev);

      lgt=lgtnew;

      if(lgt)prev=malloc(lgt*sizeof(u8)*2);

      {int i=0;
       for(;i<lgt;i++)
       {
          prev[i*2+0]=d[i];
          prev[i*2+1]=4;
       }
      }
   }

   {u8*s=prev,*dd=d;
    int i=lgt-1;
    for(;i>0;i--)
    {
       if(*s!=*d)
       {
          int cnt=0;
          int smallgap=0;

          while((*s!=*d) || (smallgap>0))
          {
             if(*s==*d)
             {
                smallgap--;
             }
              else
             {
                smallgap=2;
             }

             cnt++;
             s+=2;
             d++;
             i--;
             if(i<=0)break;
          }
          
          /*fprintf(stderr,"%d\n",cnt);*/

          switch((int)cnt)
          {
             case(0):
             case(1):
                if(s[-1]<2)
                   d[-1]=s[-2];
                break;

             case(2):
                if(s[-1]+s[-3]<4)
                {
                   d[-1]=s[-2];
                   d[-2]=s[-4];
                }
                break;
             case(3):
                if(s[-1]+s[-3]+s[-5]<5)
                {
                   d[-1]=s[-2];
                   d[-2]=s[-4];
                   d[-3]=s[-6];
                }

             default:
                if(flags&1)
                {int j=(cnt-2);
                 u8*dd=d-cnt,*ss=s-cnt*2;

                for(;j;j--)
                {
                   if(dd[-1]==ss[-2] && dd[-3]==ss[-6] &&
                      dd[-2]!=ss[-4] && ss[-3]<(ss[-1]+ss[-5]+1))
                      dd[-2]=ss[-4];
                      ss[-3]++;
                   dd++;
                   ss+=2;
                }
                }break;
          }
       }
        else
       {
          if(s[1]<8)s[1]++;
          s+=2;
          d++;
       }
    }
   
   {int i=lgt;s=prev;
    for(;i>0;i--)
    {
       if(*s!=*dd) s[1]=0;
       s[0]=*dd++;
       s+=2;
    }
   }
   }
}

void conv_losestuff(u8*d,int lgtnew,int flags)
{
   static int lgt=0;
   static u8 *prev=NULL;

   /* +0:    currently viewed stuff
      +lgt:  previous frame
      +2lgt: new frame
      +3lgt: dynamic level 0..7  -- later
   */

   if(lgt!=lgtnew)
   {
      if(prev!=NULL)
         free(prev);

      lgt=lgtnew;

      if(lgt)prev=malloc(lgt*sizeof(u8)*4);

      memcpy(prev+0*lgt,d,lgt);
      memcpy(prev+2*lgt,d,lgt);
   }

   memcpy(prev+1*lgt,prev+2*lgt,lgt);
   memcpy(prev+2*lgt,d,lgt);

   /* */

   {int i=0,justwrote=-1;
    for(;i<lgt;i++)
    {
       u8*a=&prev[i],*b=&prev[i+lgt],*c=&prev[i+lgt*2];
       
       if(*a!=*b)
       {
          if(justwrote==*b)
          {
             *a=*b;
          }
           else
          {
             if(justwrote>=0 && i) a[-1]=*c;
             *a=*c;
          }
          justwrote=*d=*a;
       }
       else justwrote=-1;
       d++;
    }
   }
}
