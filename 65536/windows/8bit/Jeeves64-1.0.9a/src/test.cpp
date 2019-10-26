/*
  This file is part of Jeeves64, an application framework for 64k
  GNU/Linux and win32 intro development. 
  
  Jeeves64 makes use of fxmp by Spectre of Flare and tinyptc by 
  Gaffer, consult the README for urls. 
  This file is Copyright (c) 2000 Kuno Woudt <warp-tmt@dds.nl>.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/

/*
  errorlevel 0 = success
  errorlevel 1 = tinyptc failed
  errorlevel 2 = fxmp failed      
  errorlevel 5 = anything else, #define DEBUG to get a fairly decent errormsg.
*/

// Disable conversion warning messages in Visual C++
#ifdef _WIN32
#pragma warning( disable: 4244 )
#endif

/* it's probably useful to keep track of filesize increase especially
   when data is added to the project,...
   
                         uncompressed         compressed with upx
"tmp.d/retro_0.jtf.h"    35840  (35974)       2048
"tmp.d/retro_1.jtf.h"     6652   (6534)       1024
"tmp.d/retro_5.jtf.h"    20992  (20707)       1024
"tmp.d/music.xm.h"       12800  (12457)       5632
"tmp.d/tiles.jtf.h"      50048  (50022)       6717   // also includes the palette (tiles.act).

  NOTE: please keep in mind that having an icon also considerably increases
  the filesize (currently 4096 bytes).

*/

#ifndef _WIN32
#define LINUX   // assume linux on non-win32 systems.
#endif

#include <cstring>
#include <cstdio>
#include <cstdlib>

#ifdef _WIN32
#include <wtypes.h>
#include <winbase.h>
#endif

#ifdef LINUX
extern "C" {
#include <unistd.h>
#include <pthread.h>
#include <sys/resource.h>
}
#endif

//____\\ configuration macro's ?
#define MUSIC  // uncomment for release version ;)
#define DEBUG
#undef DEBUG   // uncomment to remove assertions and whatnot.

#ifdef DEBUG
#ifdef _WIN32
#define ERROR        { printf("error occured in %s (%d).\n", __FILE__, __LINE__); exit(5); }
#else
#define ERROR        { printf("error occured in %s (%s, %d).\n", __FILE__, __FUNCTION__, __LINE__); exit(5); }
#endif // !_WIN32
#else
#define ERROR        { exit(5); }
#endif // !DEBUG

//____\\ jeeves64 (tinyptc & fxmp)
extern "C" {
#ifdef _WIN32
#include "tinyptc-win_8bit/tinyptc.h"
#else
#include "tinyptc-x11_8bit/tinyptc.h"
#endif
#include "fxmp/fxmp.h"
#include "fxmp/drv_dsp.h"
}

//____\\ the `effect' header files may perhaps use the WIDTH and HEIGHT params too.
#define BORDER 0
#define PTC_X 0x280
#ifndef __PTC_WINDOWED__
#define PTC_Y 0x1E0
#else
#define PTC_Y 0xD0
#endif  // __PTC_WINDOWED__
#define WIDTH (PTC_X-(0x80+BORDER))
#define HEIGHT 0xD0

#define COL_START     0x60
#define SHADE_ADD     0x50
#define SHADE_START   COL_START + SHADE_ADD

#define COL_FPS    COL_START + 0x43 // 0x00E0C020
#define COL_SHADE  COL_START + 0x44 // 0x00202020
#define COL_TEXT   COL_START + 0x45 // 0x00E0E0E0
#define COL_PLASMA COL_START + 0x41 // 0x00AC0A46

#define RGB_ZON      0x00FFFFA0
#define RGB_PLASMA   0x00FFFFFF
#define RGB_ZESBLOB  0x00AC0A46

#define FILL_COLOUR  0x002060A0
#define FILL_ZON     FILL_COLOUR
#define FILL_BLOB    FILL_COLOUR
#define FILL_PLASMA  FILL_COLOUR
#define FILL_ZESBLOB FILL_COLOUR

//____\\ jeeves64
#include "jeeves64.h"        // Buffers
#include "typeface64.h"      // font writer thingy


//____\\ effects                coder..    desc..
#include "polar.h"           // Warp       polar coordinates
#include "tiles.h"           // Warp       data for console rpg style tile stuff
#include "blob.h"            // Tharsis    blobs.
#include "plasma.h"          // Warp       some experiments with Plasma's and stuff.
#include "zoem.h"            // Warp       feedback zoom.
#include "transition.h"      // Warp       effect transitions.


//____\\ data
#include "tmp.d/music.xm.h"  // hopefully some tiny & cute chiptune by tharsis,...
#include "tmp.d/music.xm_patterns.h" // pattern boundaries.
#include "tmp.d/retro_0.jtf.h" // the large font.
#include "tmp.d/retro_1.jtf.h" // the small font.
#include "tmp.d/retro_5.jtf.h" // the slim font. (dit is het tDR fontje :)

#include "tmp.d/tiles.jtf.h" // console rpg inspired tiles 
#include "tmp.d/tiles.act.h" // palette (0..0xFF)

int ttt;

#ifdef _WIN32
DWORD WINAPI 
pollthread(LPVOID xm)
#else
  void*
pollthread(void * xm)
#endif
{
  while (!fxmp_poll((xm_module *) xm))
    {
/*
#ifdef _WIN32
      Sleep(14);
#endif
*/
    }

  return 0;
}


#define MAX_STRINGSIZE 0x30
#define MSG_SPACING    0x03
class fx_eachframe 
{
private:
  int time;                             // elapsed time (prev. frame)
  int starttime;                        // elapsed time at beginning of intro
  int frames;                           // total frames
  int c;                                // count var within pattern
  int p;                                // current pattern
  int x;                                // msg x position
  int y;                                // msg y position
  int msgwidth;                         // approx. msg length in pixels
  int msgheight;                        // approx. msg height in pixels
  char s[MAX_STRINGSIZE];               // (formatted) msg.
#define MSG_COUNT  0x15
  int start[MSG_COUNT];                 // ``anim'' start for each msg.
  char msg[MSG_COUNT][MAX_STRINGSIZE];  // messages.
public:
  fx_eachframe(void) 
    : time(GetTime()), starttime(GetTime()), frames(0), c(0), p(0), x(20), y(20)
  { 
    // FX: _____init>> Out (font writer smurf).
    char init[MSG_COUNT][0x100] = {
      //             0123456789a
      "                         ",                        // 0x00
      "                         ",                        // 0x01
      "title:      \n8bit.      ",                        // 0x02
      "version:    \n1.0.9a.    ",                        // 0x03
      "copyright:  \n\1362000 bliss.",                    // 0x04    \136 = copyright.
      "party:      \nbizarre 2000.",                      // 0x05
      "compo:      \n512 kilobit.",                       // 0x06
      "file under: \n/incoming/bizarre00/in64.",          // 0x07
      "code:       \nwarp, tharsis.",                     // 0x08
      "design+gfx: \nwarp.      ",                        // 0x09
      "music:      \ntharsis.   ",                        // 0x0A
      "video:      \ntiny ptc by gaffer.",                // 0x0B
      "audio:      \nflare xm player by spectre.",        // 0x0C
      "link:       \nhttp://www.demonic.demon.nl.",       // 0x0D
      "date:       \n2000/10/01.",                        // 0x0E
      "license:    \ngnu general public license.",        // 0x0F
      "duration:   \n84 seconds.",                        // 0x10
#ifdef _WIN32
      "format:     \nwin32/pe.  ",
#else
      "format:     \nlinux/elf. ",
#endif
      "hi!         \nsmoke, avoozl, cavey, zarq.",        // 0x12
      "thank you!  \nscene.org, #demoscene, ojuice.",     // 0x13
      "            \ngame over  "                         // 0x14

      /*
#ifdef __PTC_WINDOWED__
      "window:     \n640 x 208. ",                          
#else
      "window:     \n640 x 480. ",                            
#endif  
      "bitdepth:   \n8.         ",
      "cpu.req.:   \n466mhz     ",     
      "mem.usage:  \n8mb.       ",     
      "            \nthe end    " 
      */
    };

    for(int i=0; i<MSG_COUNT; i++)
      {
        memcpy(msg+i, init+i, MAX_STRINGSIZE); // msg[i] = init[i];
        start[i] = (strchr(msg[i],':')==NULL) ? 0 : strchr(msg[i], ':')-msg[i] + 1;
      }
    //    (*(strchr(msg[0x01], ']')))++; // turn the ']' into a copyright thingy :)
  }
  
  ~fx_eachframe(void) 
  { 
    int endtime = GetTime(); // time in milliseconds
    int frame = (int) (frames / ((endtime-starttime) / 1000.0));

    printf(" 0x%02x (%d) fps.\n", frame, frame);
  }
  
  int Draw(iBuffer &b)
  {
    frames++; // for the more accurate average fps at the end.
    int t2 = GetTime(); // time in milliseconds
    int frame = (t2-time);
    time = t2;
        
    // FX: increase some counters and whatnot .... ... .. . .  .   .    .      
    if(fxmp_get_bytes() > patterns[p+1]) 
      {
        if(p<(MSG_COUNT-1)) p++;
        c=0;

        msgwidth = (strchr(msg[p], '\n')==NULL) ? 0 :
          strlen(strchr(msg[p], '\n')) * (retro_5_jtf_data[0]+MSG_SPACING); // font[0] = max char cell width
        msgheight = (retro_5_jtf_data[1]+MSG_SPACING)*2;
        x = (rand() % (WIDTH-msgwidth-8)) + 4;
        y = (rand() % ((HEIGHT>>1)-8))    + 4;

        if(p==(MSG_COUNT-1)) // center ``the end''
          {
            x = (WIDTH-msgwidth)>>1;
            y = (HEIGHT>>1)-retro_5_jtf_data[1] - (retro_5_jtf_data[1]>>1); // font[1] = char cell height
          }
      }

    // FX: fps .... ... .. . .  .   .    .      
#ifdef DEBUG
    memset(s, 0, MAX_STRINGSIZE);
    strcat(s, "0x");
    i2a((1000 / frame), s+2);
    strcat(s, " fps");
    Out(retro_0_jtf_data, &b, WIDTH-0x80, 12, s, 1, COL_SHADE); // fps shade
    Out(retro_0_jtf_data, &b, WIDTH-0x82, 10, s, 1, COL_FPS); // fps
#endif

    // FX: some text (pattern, character count and msg[0..MSG_COUNT]) .... ... .. . .  .   .    .      
#ifdef DEBUG
    memset(s, 0, MAX_STRINGSIZE);
    Outp2x(retro_5_jtf_data, &b, 12, b.y-42, i2a(p, s), 1, COL_TEXT); // pattern
//    Outp2x(retro_5_jtf_data, &b, 12, b.y-62, i2a(c, s), 1, COL_TEXT); // c
    Outp2x(retro_5_jtf_data, &b, 12, b.y-62, i2a(ttt, s), 1, COL_TEXT); // c
#endif

    memset(s, 0, MAX_STRINGSIZE);
    int fgb = fxmp_get_bytes();
    if(p)
      //      if((fgb > patterns[p]) && (fgb < (patterns[p+1]-((patterns[p+1]-patterns[p])>>2))) 
      if((fgb > patterns[p]) && (fgb < (patterns[p+1]-((patterns[p+1]-patterns[p])>>3))) 
         | (p==MSG_COUNT-1))
        {
          c = ((fgb - patterns[p]) >> 0x0C) & 0xFF;
          if(p==MSG_COUNT-1) c = 0xFF;

          if(msgwidth!=0)
            vierkant(b, x-2, y-3, msgwidth+4, msgheight+4, COL_TEXT, SHADE_ADD);

          //          Outp(retro_5_jtf_data, &b, x+2, y+2, strncpy(s, msg[p-2], (c>start[p-2]) ? c : start[p-2]), MSG_SPACING, 0x00202020);
          Outp(retro_5_jtf_data, &b, x,   y,   strncpy(s, msg[p], (c>start[p]) ? c : start[p]), MSG_SPACING, COL_TEXT);
        }

    return frame;
  }
}; // class fx_eachframe


class fx_tiles
{
public:
  fx_tiles(void) { }
  ~fx_tiles(void) { }

  /*
    void Draw(Buffer &b, int c)
    {
    // FX: some more crap text .... ... .. . .  .   .    .      
    Outp(retro_0_jtf_data, &b, PTC_X-330, PTC_Y-40, "Do Not Spread!",      4, 0x00202020);
    Outp(retro_0_jtf_data, &b, PTC_X-332, PTC_Y-42, "Do Not Spread!",      4, 0x00E0C020);
    Outp(retro_1_jtf_data, &b, PTC_X-330, PTC_Y-22, "(internal bliss test release)", 1, 0x00202020);
    Outp(retro_1_jtf_data, &b, PTC_X-332, PTC_Y-24, "(internal bliss test release)", 1, 0x00E0C020);
    }
  */

  void Draw_gras1(iBuffer &b, int c)
  {
    // FX: madam moving about .... ... .. . .  .   .    .      
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_grasveld, 8, 0x0d);
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_gras1, 8, 0x0d);
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_gras2, 8, 0x0d);
  }

  void Anim_gras1(iBuffer &b, int c)
  {
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_koelkast_en_deur, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_koelkast, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_meisje, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_knaapje, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_tekst, c);
  }

  void Draw_gras3a(iBuffer &b, int c)
  {
    // FX: madam moving about .... ... .. . .  .   .    .      
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_grasveld, 8, 0x0d);
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_grasIII_1, 8, 0x0d);
  }

  void Anim_gras3_intro(iBuffer &b, int c)
  {
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_knaap, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_meisje, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_robotter, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_tekst, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_deur1, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_intro_deur2, c);
  }

  void Anim_gras3(iBuffer &b, int c)
  {
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_chase_knaap, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_chase_meisje, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_chase_robotter, c);
  }

  void Draw_gras3b(iBuffer &b, int c)
  {
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_grasIII_2, 8, 0x0d);
  }


  void Draw_voida(iBuffer &b, int c)
  {
    Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_void, 8, 0x0d);
  }

  void Draw_voidb(iBuffer &b, int c)
  {
    if(c&1)
      Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_muren1, 8, 0x0d);
    else
      Tile(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_muren2, 8, 0x0d);
  }

  void Blackout1(iBuffer &b, int c)
  {
    Blackout(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_transition_1, c, 8, 0x0d);
  }

  void Blackout2(iBuffer &b, int c)
  {
    Blackout(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_transition_2, c, 8, 0x0d);
  }

  void Anim_void1(iBuffer &b, int c)
  {
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_bullet1, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_bullet2, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_laser, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_enemy, c);

    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_plane1, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_plane2, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_plane3, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_anim_plane4, c);
  }

  void Anim_void2(iBuffer &b, int c)
  {
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_bullet1_bullet6, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_bullet2, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_bullet3, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_bullet4, c);

    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_enemy1, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_enemy2, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_enemy3_bullet5, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_enemy4, c);

    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_plane1, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_plane2, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_plane3, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_plane4, c);

    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_laser1_laser3, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_laser2_laser5, c);
    Anim(tiles_jtf_data, &b, WIDTH+BORDER, (PTC_Y>>1)-(HEIGHT>>1), tile_ani2_laser4, c);
  }

}; // class fx_tiles

class fx_blob
{
private:
  Blob blob;
  int bx[3];
  int by[3];
public:
  fx_blob(void) 
  { 
    // FX: _____init>> Blobs.
    /*
      bx[0] = by[0] = 100;
      bx[1] = by[1] = 140;
      bx[2] = by[2] = 0;
    */
  }

  ~fx_blob(void) { }

  void Draw(iBuffer &b, double t)
  {
    // FX: blob! .... ... .. . .  .   .    .      
    bx[0] = (int) ((b.x/2.0) + (b.x/5.0) * cos(t/11.0));
    by[0] = (int) ((b.y/2.0) + (b.y/2.2) * sin(t/ 7.0));
    bx[1] = (int) ((b.x/1.8) + (b.x/5.0) * cos(t/13.0));
    by[1] = (int) ((b.y/1.8) + (b.y/2.2) * sin(t/ 9.0));
    bx[2] = (int) ((b.x/2.2) + (b.x/5.0) * cos(t/10.0));
    by[2] = (int) ((b.y/2.2) + (b.y/2.2) * sin(t/ 5.0));
    blob.Draw(b,bx,by,3);
  }

  void Draw2(iBuffer &b, double t)
  {
    // FX: blob! .... ... .. . .  .   .    .      
    bx[0] = (int) ((b.x/2.0) + (b.x/5.0) * cos(t/11.0));
    by[0] = (int) ((b.y/2.0) + (b.y/2.2) * sin(t/ 7.0));
    bx[1] = (int) ((b.x/1.8) + (b.x/5.0) * cos(t/13.0));
    by[1] = (int) ((b.y/1.8) + (b.y/2.2) * sin(t/ 9.0));
    bx[2] = (int) ((b.x/2.2) + (b.x/5.0) * cos(t/10.0));
    by[2] = (int) ((b.y/2.2) + (b.y/2.2) * sin(t/ 5.0));
    blob.Draw2(b,bx,by,3);
  }
}; // fx_blob

class fx_plasma
{
private:
  iBuffer ectobuffer;
  Plasma ecto;
public:
  fx_plasma(int x, int y) 
    : 
    ectobuffer(x, y),
    ecto((x<<3), (y<<3))
  { }

  ~fx_plasma(void) { }

  void Draw(iBuffer &b, float t, int flags = ZES_NOFLAG)
  {
    ecto.Draw(ectobuffer, t, COL_START);

    //#define ECTO_CRAPSIZE 0x22
    // FX: plasma en crap_circles .... ... .. . .  .   .    .      
    /*
      for(int y=0; y<ectobuffer.y; y++)
      for(int x=0; x<ectobuffer.x; x++)
      crap_circle(b, x*ECTO_CRAPSIZE+(ECTO_CRAPSIZE>>1), y*ECTO_CRAPSIZE+(ECTO_CRAPSIZE>>1), 
      (ectobuffer.data[y*ectobuffer.x+x] & 0x0000FF)>>4, 
      0x00E08000, 0x00E0C020);
    */

    // FX: plasma en zeshoeken .... ... .. . .  .   .    .      
    zeshoekbehang(b, ectobuffer, flags, COL_START);
#ifdef DEBUG
    b.box(b.x-(ectobuffer.x<<1), b.y-(ectobuffer.y<<1), ectobuffer.x, ectobuffer.y) = ectobuffer;
#endif
  }
}; // class fx_plasma


#ifdef DEBUG
void
show_pal(iBuffer &b)
{
  int max = (0x200>b.x) ? 0x100 : 0x200;

  for(int y=0; y<8; y++)
    for(int x=0; x<max; x++)
      b.data[y*b.x+x] = (0x200>b.x) ? x : (x>>1);
}
#endif DEBUG

int
update_pal(pel colour, pel fill)
{
  int i;

  for(i=0; i<0x40; i++)
    {
      int r = (GETRED  (colour) * (i<<2)) / 0x100;
      int g = (GETGREEN(colour) * (i<<2)) / 0x100;
      int b = (GETBLUE (colour) * (i<<2)) / 0x100;

      tiles_act_data[(i+COL_START)*3+0] = r;
      tiles_act_data[(i+COL_START)*3+1] = g;
      tiles_act_data[(i+COL_START)*3+2] = b;
    }

  for(i=0; i<SHADE_ADD; i++)
    {
      unsigned char r = tiles_act_data[(i+COL_START)*3+0];
      unsigned char g = tiles_act_data[(i+COL_START)*3+1];
      unsigned char b = tiles_act_data[(i+COL_START)*3+2];

      tiles_act_data[(i+COL_START+SHADE_ADD)*3+0] = (r>>1) + (GETRED  (fill) >> 1);
      tiles_act_data[(i+COL_START+SHADE_ADD)*3+1] = (g>>1) + (GETGREEN(fill) >> 1);
      tiles_act_data[(i+COL_START+SHADE_ADD)*3+2] = (b>>1) + (GETBLUE (fill) >> 1);
    }

  if(!ptc_setpal((unsigned char *)tiles_act_data)) return 0;
  
  return 1;
}

int main(void)
{
  int loop = (getenv("BLISS")==NULL) ? 1 : 0;
  xm_module *xm;

  ttt = loop;

  iBuffer pixel1(WIDTH, HEIGHT);
  iBuffer pixel2(WIDTH, HEIGHT);
  iBuffer video(PTC_X, PTC_Y);

  srand(GetTime());

  // FX: _____init>> Open video window display or some such
  if(!ptc_open(_JEEVES64_p_, PTC_X, PTC_Y)) return 1;

  for(int pcsb=0; pcsb<6; pcsb++)
    {
      tiles_act_data[(COL_START+0x40+pcsb)*3+0] = tiles_act_data[(COL_START-6+pcsb)*3+0];
      tiles_act_data[(COL_START+0x40+pcsb)*3+1] = tiles_act_data[(COL_START-6+pcsb)*3+1];
      tiles_act_data[(COL_START+0x40+pcsb)*3+2] = tiles_act_data[(COL_START-6+pcsb)*3+2];
    }

  if(!ptc_setpal((unsigned char *)tiles_act_data)) return 1;

  // FX: _____init>> xm player
  if (fxmp_init (&dsp, 0)!=0) return 2; 
  xm = xm_load (music_xm_data, MUSIC_XM_SIZE);
  if (xm == 0) return 2;
  fxmp_load_patches (xm);

  // FX: _____init>> effect classes.
#define ANIM_SPEED   7                   // (tile counter >> ANIM_SPEED)
#define ECTO_SPEED   0.02f
#define ECTO_PELSIZE 0x20 // please change ``ecto((x<<3), (y<<3))'' in fx_plasma accordingly.
  Arctica           antarctica(WIDTH, HEIGHT, WIDTH, HEIGHT);
  fx_eachframe      j_eachframe;
  fx_tiles          j_tiles;
  fx_blob           j_blob;
  fx_plasma         j_plasma((WIDTH/ECTO_PELSIZE), ((HEIGHT<<1)/ECTO_PELSIZE)+1);
  Zzzoem            zoom(WIDTH, HEIGHT);

  // FX: _____init>> scheduling & threading.
  // if a super user is running this program, this call should succeed and
  // get us lots of cpu time,... 
  // otherwise nothing happens.
#ifdef LINUX
  setpriority (PRIO_PROCESS, 0, PRIO_MIN);
#endif

  // a little sleep time to give X11/Win32 a chance to switch vidmode or create a window.
#ifdef _WIN32
  Sleep(200);
#else
  sleep(1);
#endif

  //  video.fill(23);
  video.fill(COL_START);

#ifdef MUSIC
  fxmp_play ((xm_module *) xm);

  // Create a new thread so fxmp can happily keep playing whatever we do.
#ifdef _WIN32
  DWORD threadid;
  HANDLE threadhandle = CreateThread(NULL, 0, &pollthread, xm, 0, &threadid);
  if(threadhandle==NULL) ERROR

                           SetThreadPriority(threadhandle,       THREAD_PRIORITY_HIGHEST);
  SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_ABOVE_NORMAL);
#else
  int retcode;
  pthread_t fxmpthread;
  retcode = pthread_create(&fxmpthread, NULL, pollthread, xm);
  if (retcode != 0) ERROR

                      // the priority of fxmpthread is either 0 or -20 (if a super user
                      // is running this), to make sure it gets as much CPU time as possible
                      // without slowing this thread to a crawl - the priority of
                      // this thread is reniced with two `notches'.
                      setpriority (PRIO_PROCESS, 0, getpriority (PRIO_PROCESS, 0) + 2);
#endif // !_WIN32
#endif // MUSIC

  int frametime = 0;                    // last frame took <frametime> ms.
  int tile_c = 0;                       // count var within pattern
  int c = 0;                            // count var within pattern
  int c2 = 0;                           // count var within pattern
  int t2 = 0;
  double t = 0;                         // count var within pattern

  // length of pattern 2 in milliseconds.
  int totalpatterntime = ((patterns[2]-patterns[1])  / ((44100*2*2)/1000));

  if(!update_pal(RGB_ZON, FILL_ZON)) return 1;

  // first pattern.
  // also acts as a template for other patterns.

#define SKIP  // skip all effects (until the #undef).
#undef SKIP  // don't skip the rest of the effects.


#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x01])) 
#endif
    {
      pixel1.fill(COL_START);
      pixel2.fill(COL_START);

      c += frametime; 
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if(c>totalpatterntime) c=totalpatterntime;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      //      j_tiles.Draw(video, c>>5);  // approx. +1 at 30fps (i hope).
      //      Zon(pixel1, t, 0x00FFFFA0, (float)c / (float)totalpatterntime);
      //      Zon(pixel1, 200, 0x00FFFFA0, 0.9);
      //      zongradient(pixel2, 0x00FFFFA0);
      //      j_plasma.Draw(pixel2);
      //      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_RESIZE);
      //      j_voxel.Draw(pixel2);
      //      antarctica.DrawR(pixel1, pixel2, t, 0);
      //      antarctica.TwirlR(pixel1, pixel2, t, 0, (float)c / (float)totalpatterntime);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      //      tr_circle(pixel1, (c * 0x100)/totalpatterntime);
      //      tr_h_cheapstretch(pixel1, (c * WIDTH)/totalpatterntime);
      //      tr_v_cheapstretch(pixel1, blabla++);
      //      tr_h_random(pixel1, pixel2, c);
      //      zoom.Draw(pixel1, t);
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      //      j_tiles.Draw_gras1(video, tile_c>>ANIM_SPEED);  
      //      j_tiles.Anim_gras1(video, tile_c>>ANIM_SPEED); 
    }

  c = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x03])) 
#endif
    {
      pixel2.fill(COL_START);

      c += frametime;
      t += (double)frametime * 0.01;

      if(c>(totalpatterntime<<1)) c=(totalpatterntime<<1);

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      Zon(pixel2, t, 0x40, (float)(c>>1) / (float)totalpatterntime);
      antarctica.Draw(pixel1, pixel2, t, 0);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;
    }

  tile_c = 0;
  c2 = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x05])) 
#endif
    {
      pixel2.fill(COL_START);

      c += frametime;
      c2 += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if(c>(totalpatterntime<<1)) c=(totalpatterntime<<1);

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      Zon(pixel2, t, 0x40, (float)(c>>1) / (float)totalpatterntime);
      antarctica.Draw(pixel1, pixel2, t, 0);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  //  (c>>8) is about 7fps (i hope).
      j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  //  (c>>8) is about 7fps (i hope).
      j_tiles.Blackout1(video, (c2 * 0x55)/totalpatterntime); // (0x55 = 0x100/3)
    }

  c2 = 0;

  tile_c = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x06])) 
#endif
    {
      pixel2.fill(COL_START);

      c += frametime;
      c2 += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if(c>(totalpatterntime<<1)) c=(totalpatterntime<<1);
      if((tile_c>>ANIM_SPEED)>0x20) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      Zon(pixel2, t, 0x40, (float)(c>>1) / (float)totalpatterntime);
      antarctica.Draw(pixel1, pixel2, t, 0);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  //  (c>>8) is about 7fps (i hope).
      j_tiles.Anim_void1(video, tile_c>>ANIM_SPEED); 
      j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  //  (c>>8) is about 7fps (i hope).
    }

  c2 = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x07]))
#endif
    {
      pixel2.fill(COL_START);

      c2 += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if((tile_c>>ANIM_SPEED)>0x20) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      Zon(pixel2, t, 0x40, (float)(c>>1) / (float)totalpatterntime);
      antarctica.Draw(pixel1, pixel2, t, 0);

      pixel2.fill(COL_START);
      j_blob.Draw2(pixel2, t);

      t2 = (c2 * 0x100)/totalpatterntime;
      tr_circle(pixel1, pixel2, ((t2>0xff) ? 0xff : t2), 
                (WIDTH>>2), (HEIGHT>>1), 0x18, COL_START);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_void1(video, tile_c>>ANIM_SPEED); 
      j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  
    }
  
  c2 = 0;
  c = 33;

  if(!update_pal(RGB_ZON, FILL_BLOB)) return 1;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x08]))
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if((tile_c>>ANIM_SPEED)>0x20) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_blob.Draw2(pixel1, t);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      //      zoom.Draw(pixel1, t);
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_void1(video, tile_c>>ANIM_SPEED); 
      j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  
    }

  c2 = 0;
  tile_c = 0;
  int done = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x0A]))
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      c2 += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_blob.Draw2(pixel1, t);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); // frametime = milliseconds. (which is 33 @30fps).
      //      zoom.Draw(pixel1, t);
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      if(!done)
        {
          int black = 0xff - (c2 * 0x100)/totalpatterntime;
          if(black<0x03) { done = 1; c2 = 0; }

          j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  
          j_tiles.Anim_void1(video, tile_c>>ANIM_SPEED); 
          j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  
          j_tiles.Blackout2(video, black);
        }
      else
        {
          if((tile_c>>ANIM_SPEED)>1) tile_c = 0;

          j_tiles.Draw_gras1(video, tile_c>>ANIM_SPEED);  
          j_tiles.Anim_gras1(video, tile_c>>ANIM_SPEED); 
          j_tiles.Blackout1(video, (c2 * 0x100)/totalpatterntime);
        }
    }

  if(!update_pal(RGB_PLASMA, FILL_PLASMA)) return 1;

  tile_c = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x0C]))
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if((tile_c>>ANIM_SPEED)>72) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_RESIZE);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_gras1(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_gras1(video, tile_c>>ANIM_SPEED); 
    }

  zoom.reset(COL_START+0x40);

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x0D])) 
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if((tile_c>>ANIM_SPEED)>72) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_RESIZE);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      zoom.Draw(pixel1, t, COL_START);
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_gras1(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_gras1(video, tile_c>>ANIM_SPEED); 
    }

  done = 0;
  c2 = 0;

  if(!update_pal(RGB_ZESBLOB, FILL_ZESBLOB)) return 1;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x0E])) 
#endif
    {
      pixel1.fill(COL_START);
      pixel2.fill(COL_START);

      c += frametime;
      c2 += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      //      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_NOFLAG);
      j_plasma.Draw(pixel2, (frametime*ECTO_SPEED), ZES_NOFLAG);
      j_blob.Draw(pixel2, t);
      antarctica.DrawR(pixel1, pixel2, t, 0);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      if(!done)
        {
          if((tile_c>>ANIM_SPEED)>72) tile_c = 0;

          int black = 0xff - (c2 * 0x100)/totalpatterntime;
          if(black<0x03) { done = 1; c2 = 0; }

          j_tiles.Draw_gras1(video, tile_c>>ANIM_SPEED);  
          j_tiles.Anim_gras1(video, tile_c>>ANIM_SPEED); 
          j_tiles.Blackout1(video, black);
        }
      else
        {
          j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  
          j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  
        }
    }

  tile_c = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x11])) 
#endif
    {
      pixel1.fill(COL_START);
      pixel2.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if((tile_c>>ANIM_SPEED)>41) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      //      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_NOFLAG);
      j_plasma.Draw(pixel2, (frametime*ECTO_SPEED), ZES_NOFLAG);
      j_blob.Draw(pixel2, t);
      antarctica.DrawR(pixel1, pixel2, t, 0);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_voida(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_void2(video, tile_c>>ANIM_SPEED);  
      j_tiles.Draw_voidb(video, tile_c>>ANIM_SPEED);  
    }

  if(!update_pal(RGB_PLASMA, FILL_PLASMA)) return 1;

  tile_c = 0;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00]))
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x12])) 
      //  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x01])) 
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_NOFLAG);
      //      j_plasma.Draw(pixel2, (frametime*ECTO_SPEED), ZES_NOFLAG);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_gras3a(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_gras3_intro(video, tile_c>>ANIM_SPEED); 
      j_tiles.Draw_gras3b(video, tile_c>>ANIM_SPEED);  
    }

  int intro = 1;

#ifdef SKIP
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x00])) 
#else
  while(ptc_update(video.data) && (fxmp_get_bytes() < patterns[0x13])) 
#endif
    {
      pixel1.fill(COL_START);

      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      if(intro)
        {
          if((tile_c>>ANIM_SPEED)>33) { tile_c = 0; intro = 0; }
        }
      else
        if((tile_c>>ANIM_SPEED)>51) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      j_plasma.Draw(pixel1, (frametime*ECTO_SPEED), ZES_NOFLAG);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      zoom.Draw(pixel1, t, COL_START);
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_gras3a(video, tile_c>>ANIM_SPEED);  

      if(intro)
        j_tiles.Anim_gras3_intro(video, tile_c>>ANIM_SPEED); 
      else
        j_tiles.Anim_gras3 (video, tile_c>>ANIM_SPEED); 

      j_tiles.Draw_gras3b(video, tile_c>>ANIM_SPEED);  
    }

  c=0;

  if(!update_pal(RGB_ZON, FILL_ZON)) return 1;

/*
  while(ptc_update(video.data) 
        && ((fxmp_get_bytes() < (patterns[0x15]+patterns[0x01])) || (argc==1)))
*/
  while(ptc_update(video.data) 
        && ((fxmp_get_bytes() < (patterns[0x15]+patterns[0x01])) || (loop)))
    {
      pixel1.fill(COL_START);
      pixel2.fill(COL_START);
      
      c += frametime;
      tile_c += frametime;
      t += (double)frametime * 0.01;

      double c2 = (totalpatterntime-(float)c/3.0) / (float)totalpatterntime;
      double c3 = 0.5*sin(t/8);

      if((tile_c>>ANIM_SPEED)>51) tile_c = 0;

      // FX: effects for this pattern .... ... .. . .  .   .    .      
      Zon(pixel2, t, 0x40, c2);
      antarctica.TwirlR(pixel1, pixel2, t, 0, c3);

      // FX: center `pixel' on `video' .... ... .. . .  .   .    .      
      frametime = j_eachframe.Draw(pixel1); 
      video.box(0, (PTC_Y>>1)-(HEIGHT>>1), WIDTH, HEIGHT) = pixel1;

      // FX: tile animation .... ... .. . .  .   .    .      
      j_tiles.Draw_gras3a(video, tile_c>>ANIM_SPEED);  
      j_tiles.Anim_gras3 (video, tile_c>>ANIM_SPEED); 
      j_tiles.Draw_gras3b(video, tile_c>>ANIM_SPEED);  
    }

#ifdef MUSIC
#ifdef _WIN32
  TerminateThread(threadhandle, 0);
#else
  pthread_cancel(fxmpthread);
#endif // (not) _WIN32
#endif // MUSIC
  
  fxmp_deinit ();
  ptc_close(); // ptc_close segfaults in X11, and doesn't seem neccesary.

  return 0;
}
