#include <stdio.h>
#include <string.h>
#include <midasdll.h>
#include "windemo.h"

MIDASmodule module;
MIDASmodulePlayHandle playHandle;

unsigned        mpos;
unsigned        position;               /* Current position */
unsigned        pattern;                /* Current pattern number */
unsigned        row;                    /* Current row number */
int             syncInfo;               /* Music synchronization info */

volatile unsigned frameCount;

int quit_demo=0;

int randglob=1;

int rand();
#pragma aux rand  = "push edx" \
             "lea eax,randglob" \
             "imul edx,[eax],0x41c64e6d" \
             "add edx,0x3039" \
             "mov [eax],edx" \
             "mov eax,edx" \
		     "shr eax,10"\
		     "and eax,0x7fff" \
		     "pop edx" \
		     parm[] modify [eax];

void UpdateInfo(void)
{
 static MIDASplayStatus info;
 int         error;

 MIDASgetPlayStatus(playHandle, &info);

 /* Store interesting information in easy-to-access variables: */

 position = info.position;
 pattern = info.pattern;
 row = info.row;
 syncInfo = info.syncInfo;
}

int xmpGetPos()
{ int gg;
   gg=position*256+row;
   return(gg);
}


//screen variables
int lfb;      //linearframebuffer enabled
unsigned int vdscr[64000];

typedef union {
  unsigned short col;
  struct {
   unsigned short b:5;
   unsigned short g:5;
   unsigned short r:5;
   unsigned short d:1;
  } part;
} realcol;


typedef struct {
    float x,y,z;
} vector;

typedef struct{
  char r;
  char g;
  char b;
} tcol;

void updatescreen(void *vscr)
{ int i;
     VideoFrame(vscr);     //Copy vscr to screen.
     quit_demo=os_stuff(); //Update message-query.
     timerpoll();          //Get timerinfo. (set to 70 times/sec.)
}

int frm=10;
int b;

void Demopart1(){
    frameCount=0;

    while ( !quit_demo ){
      mpos=xmpGetPos();
      updatescreen(vdscr);

      if(frm>320*10) frm=10; else;

      b=0;
      while(b<200){
        vdscr[320*50+frm+b]=b;
        b++;
      }
  //      frm+=1;

      while (frameCount>0) {  //Follow the speed of the timer, not the computer.
        UpdateInfo();
        frm+=1;
        frameCount--;
      }
    }
}

void DemoMain()
{
    MIDASstartup();
    Mso();              //This MIDASsetOption has been moved to windemo because
                        //it needs a windowsspecific handler.
    MIDASsetOption(MIDAS_OPTION_DSOUND_MODE, MIDAS_DSOUND_DISABLED);
    MIDASsetOption(MIDAS_OPTION_MIXRATE, 22000);
    MIDASsetOption(MIDAS_OPTION_MIXING_MODE, MIDAS_MIX_HIGH_QUALITY);
    MIDASsetOption(MIDAS_OPTION_OUTPUTMODE, MIDAS_MODE_16BIT_STEREO);
    MIDASinit();

    VideoOpen(320,200,32);  //Open a screen. (only supports 320x200x32bit in this release :))

    module = MIDASloadModule("wintnens.xm");

    quit_demo=os_stuff();   //Call this once in a while to process messagequery.

    playHandle = MIDASplayModule(module, TRUE);
    MIDASstartBackgroundPlay(0); // Play module

    Demopart1();    // Do some stuff onscreen.


    MIDASstopModule(playHandle);
    MIDASfreeModule(module);
    MIDASclose();

    VideoClose();   // Shutdown video.
}  
