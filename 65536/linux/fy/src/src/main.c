/* 
 * 'Fy', a 64k intro written at Remedy 2005
 *
 *  By the Introx team.
 *
 * PS: I don't have any time left(11:30!) to read music from self,
 *     usch still has tons of bugs and fredd isn't here! //gammy 
*/

#include "main.h"
#define TEXT "     HELLO THERE REMEDY FOLKS!     INTROX IS AGAIN PROUD TO INTRODUCE A BRAND NEW BOBTRO CALLED   FY   AND WE ARE THE FIRST TO EVER MAKE ONE!    ER, WELL, AT LEAST AT REMEDY 2005....    HRM WE NEED SOME SPICE!#     AHH THIS IS RATHER CUTE, DON'T YOU THINK?     A BIT TRICKY TO READ PERHAPS, BUT THAT ISN'T OUR PROBLEM NOW IS IT?  HRMMMM...#     HOW ABOUT THIS?     EVEN MORE ANNOYING TO READ, I PRESUME..#     AH LOOK, SCALED DOWN A BIT...    FUCK THIS, BACK TO NORMAL!!###  ALRIGHT, HOPE THIS DEMO DOESN'T GET PLACED IN THE NORMAL COMPO...####    IT ISN'T EVEN 64 KILOBYTES, DAMNIT!  CREDITS...#    CODE: GAMKILLER, FREDD    MUSIC: POISONOUS REPTILE##    SHOUTOUTS GO TO ALL THE GREAT PEOPLE AT REMEDY 2005, AND UH.. YEAH, ALL YOU PEOPLE! WE LOVE YOU ALL!#####  TIME FOR AN ABRUPT HALT...."
#define FONT "                 ##  ##      ##  # #                                                                              ##             ### #   #   ######   #   # ### #  # ## #  #     ## #### ##              ## ##      ####                ##  ##     #  #  #  #   #########  ##### ##   #   #  ### ## #  #  #  #######   #  #######  #####   #   ######   ############### #  #########   #  #  #  #####  ##############  # ###   # ##          ##  ##      ## ###  #  #### #      ####    ####      # ####  #     ####   # ### #  #####  ######  # ## #  ######  #### # # #  ##########   #   ####### #  ##  #### #####   ### #########   ##  #   #####   # #######  ##########  ##### ##  ## ####  ##   ##  # #### ##### ### # ###   #   #   #####  ######  ##  ### ## ###  ##  ######  ##  ##########  ######   #####  ## ########### ##### # ## ######  ###### #### ##  ##  ## #  ##  ##  ######  ##  # ##  ## #  ##  ######  ##  # ##  ## #  ##  # ##  ##  ## ####  ####  ####"
char bob[256] = {65,65,65,113,5,25,66,117,66,22,73,126,65,65,65,65,65,65,37,127,61,45,14,81,58,16,15,117,4,113,65,65,65,113,119,112,16,81,110,115,115,27,81,10,59,5,65,65,65,30,94,99,85,92,114,27,114,3,6,36,-125,56,111,65,108,12,25,101,35,63,86,105,114,33,85,-124,75,25,104,108,109,22,12,10,106,79,94,82,38,100,83,80,45,66,41,109,76,22,39,93,21,62,65,123,122,-124,50,26,88,67,124,51,52,78,57,39,4,50,65,98,106,63,99,90,32,43,98,52,74,26,97,121,43,119,87,-127,14,1,17,89,43,9,71,52,91,71,28,9,19,57,32,88,88,88,103,69,96,28,84,0,11,84,125,54,116,72,70,12,19,41,77,34,20,13,68,127,5,91,125,60,54,48,44,23,-126,49,118,53,64,116,55,126,-124,73,80,7,-128,60,64,44,49,49,-128,60,20,102,127,65,65,18,91,68,28,60,46,48,47,120,120,7,84,24,83,65,65,65,90,51,107,70,31,86,33,86,8,2,29,40,65,65,65,65,65,35,95,84,42,42,42,42,84,85,35,65,65,65};
char bobpalette[768] = {182,139,10,181,168,65,202,165,36,244,235,173,117,100,12,55,47,14,234,223,140,164,162,154,182,165,79,182,153,36,238,220,71,142,103,10,206,182,13,145,145,145,240,227,86,237,216,50,239,221,85,98,87,26,19,16,8,234,196,4,182,182,181,166,140,33,199,171,19,230,229,228,167,126,34,164,142,11,126,119,86,244,236,152,148,142,124,156,125,36,36,32,14,180,165,89,230,204,9,197,190,142,182,175,157,6,6,4,121,110,54,5,4,3,228,215,106,234,207,6,21,19,12,195,158,14,205,171,37,231,197,6,224,224,224,238,218,69,222,222,222,218,218,218,216,216,216,214,214,214,29,29,29,168,136,10,203,158,8,204,204,204,200,200,200,217,163,15,23,20,13,233,200,4,241,227,111,182,159,20,186,186,186,234,206,28,105,101,80,30,27,13,180,180,180,1,1,1,226,196,20,232,204,6,201,163,22,233,194,7,188,170,62,152,133,73,166,149,90,152,119,10,213,166,7,73,64,15,169,139,10,194,177,107,133,114,47,48,44,13,175,157,45,241,228,113,178,167,71,15,13,7,175,145,45,80,73,41,180,172,106,115,102,29,236,211,12,171,144,31,28,24,13,190,146,10,222,210,114,236,213,35,14,13,9,78,70,32,201,166,27,196,163,32,124,109,34,10,9,8,48,47,32,87,79,14,160,130,46,233,201,15,202,174,11,232,220,133,207,193,72,228,178,20,14,12,5,100,83,10,246,236,173,3,3,4,227,198,22,1,1,2,245,237,162,244,236,151,153,152,151,233,203,21,217,217,217,113,98,19,215,215,215,233,201,1,185,172,63,94,86,20,199,162,17,174,173,171,47,34,10,134,105,16,185,185,185,230,215,67,188,184,178,4,4,4,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};  
SDL_Surface *screen;
FMUSIC_MODULE *tune;

void usleep(unsigned long usec);

void init(void){
  SDL_Init(SDL_INIT_VIDEO);
  atexit(SDL_Quit);
  screen = SDL_SetVideoMode(320, 200, 8, SDL_HWSURFACE|SDL_DOUBLEBUF|SDL_HWPALETTE|SDL_FULLSCREEN);
  if(!screen){
    printf("failed to allocate memory for video!\n");
    exit(1);
  }
  SDL_ShowCursor(SDL_DISABLE);
}

void transplot(SDL_Surface * surface, int x, int y, Uint32 pixel)
{
  if (pixel != 65) {
    Uint8 *p = (Uint8 *) surface->pixels + y * surface->pitch + x;
    *p = pixel;
  }
}

void scale(SDL_Surface * out, short x0, short y0,short x1, short y1){

  float xstep;
  float ystep;

  float xratio;
  float yratio;

  short xdiff;
  short ydiff;

  short xcount;
  short ycount;

  int color;

  ydiff = y1 - y0;
  xdiff = x1 - x0;

  xratio = (float) 16 / xdiff;
  yratio = (float) 16 / ydiff;

  if(x0 >= 0 && x1 < 320){ /* Assumes largest bob is 16px wide */
  /* Needs optimisation(!) */
  for (ystep = 0, ycount = y0; ycount < (ydiff + y0);ystep += yratio, ycount++) {
    for (xstep = 0, xcount = x0; xcount < (xdiff + x0);xstep += xratio, xcount++) {
      color = bob[(int)xstep + (16 * (int)ystep)];
      if (color != 65)
        transplot(out, xcount, ycount, color);
    }
  }
  }
}


void bobblit(SDL_Surface *surface, int x1, int y1, short clip){
  int x;
  int y;
  int c;
  int count;
  Uint8 *buf;

  count = 0;
  for(y = y1; y < (y1+16); y++){
    for(x = x1; x < (x1+16); x++){
      c = bob[count++];
      buf = (Uint8 *)surface->pixels + x + ((y << 8) + (y << 6));
      *buf = c; 
    }
  }

}
      
int main(int argc, char **argv){
  SDL_Event event;
  SDL_Color palette[256];

  short busy;
  float k,kf;
  char tmp[65][16];
  struct fontEx{
    int data[16];
  } font[65];
  int i;
  int bobmap[64][4];
  int letter;
  int xoffset;
  int lettercount;
  int letters;
  int pixel;
  int test;
  int pal;
  int palb;
  int palcount;
  int routinecount;
  int x, y;

  short enabledelay;
  unsigned int usecs;
  
  for(letter = 0; letter < 65; letter++){
    bzero(tmp[letter], 16);
    strncpy(tmp[letter], &FONT[letter * 16], 16);
  }

  for(letter = 0; letter < 65; letter++){
    for(x = 0; x < 16; x++){
      if(tmp[letter][x] == '#'){
        font[letter].data[x] = 1;
      }else{
        font[letter].data[x] = 0;
      }
    }
  }

    
  enabledelay = 1;
  
  if(argc < 2){
    printf("If this is too slow, add 0 as an argument(%s 0)\n", argv[0]);
    printf("If this is too fast, add a microsecond value as an argument(eg %s 500)\n", argv[0]);
    usecs = 250;
    sleep(3);
  }else{
    usecs = atoi(argv[1]);
    if(usecs == 0){
      printf("Delay disabled.\n");
      enabledelay = 0;
    }else{
      printf("Delay set to %dms.\n", usecs);
    }
  }
  
  init();
  
  pal = 0;
  palb = 2;
  k = 0;
  kf = 0.025;
  i = 0;
  xoffset = 0;
  busy = 1;
  lettercount = 0;
  letters = 4;
  pixel = 16;
  test = 0;
  routinecount = 0;

  for(i = 0; i < 256; i++){
    palette[i].r = bobpalette[(i*3)+0];
    palette[i].g = bobpalette[(i*3)+1];
    palette[i].b = bobpalette[(i*3)+2];
  }

  
  for(i = 155; i < 256; i++){
    palette[i].r = pal/3;
    palette[i].g = pal/2;
    palette[i].b = pal;
    pal+=palb;
    if(pal > 100)
      palb = -palb;

  }
  SDL_SetPalette(screen, SDL_LOGPAL | SDL_PHYSPAL, palette, 0, 256);

  
  if(initsound() == 1){
    printf("Bailing out.\n");
    exit(1);
  }


  FMUSIC_PlaySong(tune);
  
  while(busy){
    
    while(SDL_PollEvent(&event)){
      if(event.type == SDL_KEYDOWN){
	if(event.key.keysym.sym == SDLK_ESCAPE)
	  busy = 0;
      }
    }

    for(i = 0; i < 100; i++)
      memset(&screen->pixels[i*640], 155+i, 640); 
    
    /* Flush buffer */
    for(x = 0; x < 64; x++)
      for(y = 0; y < 4; y++)
	bobmap[x][y] = 0;
    
    /* Store coordinates */
    letter = TEXT[lettercount % strlen(TEXT)] - 32;
    
    for(x = xoffset; x < 4; x++)
      for(y = 0; y < 4; y++)
	bobmap[x-xoffset][y] = font[letter].data[x + (y * 4)];
    for(i = 1; i < letters; i++){
      letter = TEXT[(i + lettercount) % strlen(TEXT)] - 32;
      for(x = 0; x < 4; x++)
	for(y = 0; y < 4; y++)
	  bobmap[(i*5)+(x-xoffset)][y] = font[letter].data[x + (y * 4)];
    }
    letter = TEXT[(i + lettercount) % strlen(TEXT)] - 32;
    for(x = 0; x < xoffset; x++)
      for(y = 0; y < 4; y++)
	bobmap[(i*5)+(x-xoffset)][y] = font[letter].data[x + (y * 4)];
     
    scale(screen, 10+(k/2), 10+(k/2), 30-(k/2), 30-(k/2));

    switch(routinecount){

    case 0:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen, 
		  (x * 16) + pixel, 
		  64 + y * 16, 
		  (16 + x * 16) + pixel, 
		  80 + y * 16
		  );
	}
      }
      break;
    case 1:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen, 
		  (x * 16) + pixel, 
		  64 + y * 16 - (x*3), 
		  (16 + x * 16) + pixel, 
		  80 + y * 16 - (x*2) + 6*sin(x)
		  );
	}
      }
      break;
      
    case 2:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen,
		  (x * 16) + pixel,
		  64 + y * 16,
		  (16 + x * 16) + pixel,
		  80 + y * 16 + k
		 );
	}
      }
      break;
		  
    case 3:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen,
		  60 + (x * 10),
		  40 + y * 10,
		  60 + (10 + x * 10),
		  10 + (4 * 10) + y * 10
		 );
	}
      }
      break;
      
    case 4:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen, 
		  (x * 16) + pixel, 
		  64 + y * 16 - x , 
		  (16 + x * 16) + pixel, 
		  80 + y * 16 + x 
		  );
	}
      }
      break;
    case 5:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen, 
		  (x * 16) + pixel, 
		  64 + y * 16, 
		  (16 + x * 16) + pixel, 
		  80 + y * 16 -  6* sin(x)
		  );
	}
      }
      break;
      /* Cheapo sine, unused 
    case 4:
      for(y = 0; y < 4; y++){
	for(x = 0; x < 20; x++){
	  if(bobmap[x][y] == 1)
	    scale(screen, 
		  (x * 16) + pixel, 
		  64 + (y+(2*sin(x/4))) * 16, 
		  (16 + x * 16) + (pixel/2), 
		  80 + (y+(2*sin(x/4))) * 16
		  );
	test++;
	if(test > 100)
	  test = 0;
	}
      }
      break; */ 
    }
    
    
    k += kf;
    if(k >= 1|| k <= -10)
      kf = -kf;

    pixel--;
    if(pixel == 0){
      pixel = 16;
      xoffset++;
      if(xoffset > 4){
	xoffset = 0;
	lettercount++;
	if(TEXT[lettercount] - 32 == 3){
	  routinecount++;
	  if(routinecount > 5)
	    routinecount = 0;
	}
	if(lettercount == (strlen(TEXT))){
	  lettercount = 0;
	  busy = 0;
	}
      }
    }

    SDL_Flip(screen);
    
    palcount++;
    
    if(palcount == 10){
      palcount = 0;
    
      palette[154].r = palette[154].b;
      for(i = 155; i < 256; i++)
	palette[i-1].b = palette[i].b;
      palette[254].b = palette[154].r;
   
    
      SDL_SetPalette(screen, SDL_LOGPAL | SDL_PHYSPAL, palette, 0, 256);
    }

    if(enabledelay)
      usleep(usecs);

  }
    
  FMUSIC_StopSong(tune);
  FSOUND_Close();
  return 0;
}
