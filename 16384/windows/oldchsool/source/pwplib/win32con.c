#include "config.h"

#ifdef DRIVE_WIN32

#include "pwplib.h"

#include <windows.h>

/******************** vcsa code ********************/

struct{
   HANDLE hstdout;
   COORD  size;

   CHAR_INFO*buf;
}pwp_win32;

/********************************************************/

void pwpwrite(char*z)
{
/*   fprintf(stderr,"%s\n",z); */
}

void win32con_dump_attr()
{
   u8*s=pwplib_buf;
   CHAR_INFO*d=pwp_win32.buf;
   int i=80*50;

   for(;i;i--)
   {
      d->Char.AsciiChar=*s++;
      d->Attributes=*s++;
      d++;
   }

   {
      const COORD bufsize = {80,50};
      const COORD bufcoord = {0,0};
      const SMALL_RECT writerect = { 0,0,79,49 };

      WriteConsoleOutput(pwp_win32.hstdout,pwp_win32.buf,
                         bufsize,bufcoord,&writerect);
   }
}

int win32con_probe()
{
   if(GetStdHandle(STD_OUTPUT_HANDLE) != INVALID_HANDLE_VALUE)
      return 1; else return 0;
}

int win32con_init()
{
   AllocConsole();

   pwp_win32.hstdout = GetStdHandle(STD_OUTPUT_HANDLE);

   { int ret=-1;
     const COORD sz = {80,50};
     const SMALL_RECT area = { 0,0,79,49 };

     ret &= SetConsoleScreenBufferSize(pwp_win32.hstdout,sz);
     ret &= SetConsoleWindowInfo(pwp_win32.hstdout,1,&area);

     if(!ret)
     {
        FreeConsole();
        AllocConsole();

        pwp_win32.hstdout = CreateConsoleScreenBuffer(
            GENERIC_WRITE, FILE_SHARE_WRITE, NULL,
            CONSOLE_TEXTMODE_BUFFER, NULL);

        SetConsoleActiveScreenBuffer(pwp_win32.hstdout);
        SetConsoleScreenBufferSize(pwp_win32.hstdout,sz);
        SetConsoleWindowInfo(pwp_win32.hstdout,1,&area);
     }

     SetConsoleTitle("pwp");
   }

     pwp_win32.buf=malloc(sizeof(CHAR_INFO)*80*50);

     pwplib.videobuf.width  = 80;
     pwplib.videobuf.height = 100;

     pwplib.dump_attr=win32con_dump_attr;

     conv_init(2,0,0);

//   {int i=0;for(;i<20;i++)pwplib.setup[i]=0;}
/*
     tty_init();
     pwplib.setup[SETUP_TRANS] =
     pwplib.setup[SETUP_COLORS] =
     pwplib.setup[SETUP_RASTER] = -1;
     pwplib.setup[SETUP_HALVE]=1;
     conv_init(2,0,0);
*/
     pwplib.dump_attr=win32con_dump_attr;
}

#endif
