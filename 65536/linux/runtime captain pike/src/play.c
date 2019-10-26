/* 
 * Runtime Captain Pike, a runtime tune by SigFlup(Thea DeSilva) 
 * for release at Block-Party '08
 *
 * For graphics we need an 80x40 vt100 terminal!
 *
 * If we are unable to get playback or the user has given us the "-d" 
 * argument, no graphics will be shown. We'll dump audio to run.dump 
 * and exit. run.dump is raw 22050Hz signed-16bit
 * samples with one channel. 
 *
 * sox -t raw -r 22050 -sw -c 1 run.dump out.wav
 *
 * ought to do the trick to convert it. 
 *
 *
 *
 *
 * User license: Do whatever the fuck you want with this
 *               Just don't hurt any cats or babies.
 *               If you have more then one hundred employees
 *               don't use this in any advertising. Thanks
 *
 */


//#define OPENBSD
#define LITTLE_ENDIAN

#define LINUX

#define DEV

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct {
 int wait, mod, value;
} pos_event;

#include "notes.h"
#include "osc_song.h"
#include "drum_reso_song.h"
#include "drum_song.h"
#include "klang_song.h"
#include "screen_song.h"
int screen1_next;
int screen2_next;
int tick;
#include "amen_delta.h"


unsigned char *amen;

#include <string.h>
#include <sys/ioctl.h>


#include "font.h"


#include "ascii_thea.h"

#ifdef OPENBSD
  #include <sys/audioio.h>
#endif

#ifdef LINUX
  #include <fcntl.h>
  #include <sys/soundcard.h>
#endif


 /* audio */
#define AUDIO_DEV	"/dev/audio"
#define COULD_NOT_GET	"What a fucking shame, I couldn't get proper playback"
#define BUF		512
#define RATE		22050
#define SET_BIT(x,y)	(x|(1<<y))
#define TEST_BIT(x,y)   ((x>>y)&1)

 /* "video" */
#define CWIDTH		80
#define CHEIGHT		40
#define WIDTH		(CWIDTH  * 4)
#define HEIGHT		(CHEIGHT * 4)


#define MAX_STARS	30	
#define STAR_SPEED 	1.002f	

unsigned char *cbuf;
unsigned char *lcbuf;

typedef struct {
 int x, y;
} point_t;

typedef struct {
 float x, y;
} fpoint_t;
point_t *line_buf;

fpoint_t stars[MAX_STARS] = { 0 };

int neighbors[8] = {
 ((CWIDTH*(-1))+(-1)),
 ((CWIDTH*( 0))+(-1)),
 ((CWIDTH*( 1))+(-1)),
 ((CWIDTH*( 1))+( 0)),
 ((CWIDTH*( 1))+( 1)),
 ((CWIDTH*( 0))+( 1)),
 ((CWIDTH*(-1))+( 1)),
 ((CWIDTH*(-1))+( 0)) 
};

#define MAG	x
#define EXT	y
fpoint_t wonka[CWIDTH*CHEIGHT];
fpoint_t wonka2[CWIDTH*CHEIGHT];
fpoint_t vectors[8];
fpoint_t me[8];
fpoint_t force[8];
fpoint_t movement;

float space_monkey;
int draw_timer;

int text_pos = 0;
unsigned char *jbuf;


/* reso and envelope */
int *modulus;

enum {A,D,S,R};

typedef struct {
 float A,D,S,R;
 float value;
 float startlevel;
 int trigger, oldtrig;
 int time;
 int phase;
} env_t;

env_t envelope1;

typedef struct {
 float cutoff, resonance;
 float d1,d2;
 float f,q;
} reso_t;

reso_t reso1, reso2;

float buf[BUF];

float *SND_BUF1, *SND_BUF2, *SND_BUF3;

int	timer; /* global , the timer */

/* drum_song */
int can_drum;
int drum_pos, drum_next;
int drum_mods[0x12];

/* klang song */
int can_klang;
int klang_mods[17];
int klang_next;
int klang_offset;

void err(char *text) {
 printf("%s\n", text);
 exit(-1);
}

FILE *audp;

#define SEQ 			((int)(drum_pos/ 1024)%64)
#define PAT			(int)(drum_pos / 0xffff)
#define MOD(x,y,size,off) 	(x[(SEQ*size)+(((64*size)*y[PAT])+off)])

float oscillator(int *pattern, unsigned char *sequences) {
 float q;
 signed int dat;
 int fuck;
 if((fuck = (int)(MOD(pattern, sequences, 2, 0) )) == 0)
  return 0.0f;
 dat = (drum_pos % fuck);
 q=(float)dat / (float)(MOD(pattern,sequences,2,0));
 dat = (int)(q*256.0f);
 if(dat<0x7f)
  q = -1.5f;
 else
  q = 1.5;
 return q;
}

void comp_envo(float *buf, env_t *envo) {
 int i;
 for(i=0;i<BUF;i++) {
  if(modulus[i] != 0)
   envo->trigger = 1;
  else
   envo->trigger = 0;
  if (envo->oldtrig != envo->trigger){
   if (envo->trigger==1)
    envo->phase = A;
   else
    envo->phase = R;
   envo->time = 0;
   envo->startlevel = envelope1.value;
  }
  envo->oldtrig = envo->trigger;
  switch (envo->phase){
  case A:
   if (envo->A == 0.0f){
    envo->startlevel = 1.0f;
    envo->phase = D;
    envo->time = 0;
    break;
   }
   envo->value = envo->startlevel+(1.0f-envo->startlevel) *
    ((float)envo->time / (envo->A * RATE));
   if (envo->time > (envo->A*RATE)){
    envo->time = 0;
    envo->phase = D;
    envo->startlevel = 1.0f;
   }
   break;
  case D:
   envo->value=
    envo->startlevel+(envo->S-envo->startlevel) *
    ((float)envo->time / (envo->D * RATE));
   if (envo->time > (envo->D * RATE)){
    envo->time = 0;
    envo->phase = S;
   }
   break;
  case S:
   envo->value = envo->S;
   break;
  case R:
   envo->value = (envo->time<(envo->R*RATE)) ?
   envo->startlevel - envo->startlevel *
    (envo->time / (envo->R * RATE)) : 0.0f;
   break;
  }
  envo->time++;
  buf[i]*=(float)envo->value;
 }
}

void comp_reso(float *buf, reso_t *reso) {
 int i;
 float f, out, hpout;
 for(i=0;i<BUF;i++) {
  f = reso->f * ((float)modulus[i] / 255.0f);
  out = reso->d2 + f * reso->d1;
  hpout = buf[i] - out - (reso->q * reso->d1);
  reso->d1 = f*hpout + reso->d1;
  reso->d2 = out;
  buf[i] = hpout;
 }
}

void fill_note_buf(void) {
 int i;
 float max, q;
 signed int dat;
 for(i=0;i<BUF;i++) {
  if(drum_pos<512)
   SND_BUF3[i] = ((float)drum_pos/2048.0f);
  else
   SND_BUF3[i] = (oscillator(osc_pat, osc_song)/8.0f);
  drum_pos++;
 }
 
 if(drum_pos>512) {
  drum_pos-=BUF;
  for(i=0;i<BUF;i++) {
   modulus[i] = MOD(osc_pat, osc_song,2,0);
   drum_pos++;
  }
  comp_envo(SND_BUF3, &envelope1);
 }

 drum_pos-=BUF;
 for(i=0;i<BUF;i++) {
  modulus[i] = MOD(osc_pat, osc_song, 2, 1);
  drum_pos++;
 }
 comp_reso(SND_BUF3, &reso1);

 drum_pos-=BUF;
 for(i=0;i<BUF;i++) {
  modulus[i] = MOD(drum_reso_pat, drum_reso_song, 1, 0);
  drum_pos++;
 }
 comp_reso(SND_BUF1, &reso2);
}

void fill_drum_buf(void) {
 int i,j,drum_pos2,pool;
 int k;
 for(i=0;i<BUF;i++) {
  if(drum_pos >= drum_song[drum_next].wait) { /* in what case do we miss a drum_pos? */ 
   if(drum_song[drum_next].mod == 0xff && drum_song[drum_next].value == 0xff) {
    for(k = 0; k< 30;k++) 
     printf("\33[1B\33[K");
    printf("Copy me, I want to travel\n");
    exit(-1);
  }
  drum_mods[drum_song[drum_next].mod]=drum_song[drum_next].value;
  drum_next++;
 }
 pool = 0;
 drum_pos2 = drum_pos;
 for(j=0;j<16;j++)
  if(drum_mods[j+1] == 1)
   if(TEST_BIT(drum_pos,j) == 1)
    pool = 1;
 for(j = 0;j<16;j++)
  if(drum_mods[j+1] == 1 && pool == 1)
   drum_pos2 = SET_BIT(drum_pos2,j);
 if(drum_mods[17] == 1 && pool == 1) 
  drum_pos2 = 0;
 drum_pos2%=0xffff;
 if(drum_mods[0]!=0)
  SND_BUF1[i]=(float)(amen[drum_pos2]+amen[(drum_pos2+0xffff/drum_mods[0])%0xffff])/2;
 else
  SND_BUF1[i]=(float)(amen[drum_pos2]);
 timer++;
 if(can_drum > 0) 
  drum_pos++;
  SND_BUF1[i]-=128.0f;
  SND_BUF1[i]/=64.0f; 
 }
}

void fill_klang_buf(void) {
 int i, j, q, pos;
 q = 770;
 for(i=0;i<BUF;i++) {
  for(j= 0;j< 8;j++)
   if(klang_mods[j] == 1) {
    q = j;
    break;
   }
   if(q != 770) {
    can_klang++;
   pos = timer%(0xf<<q); 
   if(can_klang == 1)
    klang_offset = timer;
   if(pos == 0) {
    for(j= 8;j<16;j++) 
     if(klang_mods[j] == 1){
      klang_offset+= 1<<(j-8);
      break;
     }
   }
  } else {
   can_klang = 0;
   pos = 0;
   klang_offset = 0;
  }

  SND_BUF2[i] = (float)(amen[(pos+klang_offset)%0xffff]);
  SND_BUF2[i]-=128.0f;
  SND_BUF2[i]/=64.0f;
  timer++;
 }
}


void audio(float *buffer) {
 int j;
 float accum;

 if(timer >= klang_song[klang_next].wait) {
  klang_mods[klang_song[klang_next].mod]=klang_song[klang_next].value;
  klang_next++;
 }
 if(klang_mods[17] == 1)
  can_drum++;

 fill_drum_buf();
 timer-=BUF;
 fill_klang_buf();
 drum_pos-=BUF;
 fill_note_buf();

 for(j=0;j<BUF;j++) {
  accum = SND_BUF1[j] + SND_BUF2[j] + SND_BUF3[j];
  accum*=0.71f; /* normalize */
  buffer[j] = accum;
 }
}

int pos_in;

int bit_in() {
 int ret;
 ret = TEST_BIT(amen_delta[pos_in/8], pos_in%8);
 pos_in++;
 return ret;
}


void line(int x1, int y1, int x2, int y2) {
  int dx = (x1 <= x2) ? x2 - x1 : x1 - x2;
  int dy = (y1 <= y2) ? y2 - y1 : y1 - y2;
  int x  = x1;
  int y  = y1;
  int e  = 0;
  int k;
  int xInc = (x1 <= x2) ? 1 : -1;

  int shift; 
  int jbuf_pos;
  int point_num, i;

  unsigned char *pix;
  if(x1 == x2 && y1 == y2) return;

  point_num =0;

#define POINT(x,y) { \
 if(x>0 && x<WIDTH && y>0 && y<HEIGHT) \
  line_buf[point_num  ].x = x; \
  line_buf[point_num++].y = y; \
} 
  if(x1 == x2)
    xInc = 0;
  int yInc = (y1 <= y2) ? 1 : -1;
  if(y1 == y2)
    yInc = 0;
  if(dy <= dx) {
    for( ; (xInc*x <= xInc*x2) && (yInc*y <= yInc*y2); x += xInc ) {
     POINT(x,y)
      e += dy;
      if( yInc && (2*e + yInc*dy) >= xInc*dx ) {
        y += yInc;
        e -= dx;
      }
    }
  }
  else {
    for( ; (yInc*y <= yInc*y2) && (xInc*x <= xInc*x2); y += yInc ) {
     POINT(x,y)
      e += dx;
      if( xInc && (2*e + xInc*dx) >= yInc*dy ) {
        x += xInc;
        e -= dy;
      }
    }
  }
/* convert line_buf */
 for(i = 0; i<point_num;i++) 
#define SET_JBUF(x,y) \
 jbuf[((((x/4) + ((y/4)*CWIDTH)))*2)+((y%4)/2)] = \
  SET_BIT(jbuf[((((x/4) + ((y/4)*CWIDTH)))*2)+(y%4)/2 ], (((y%2)^1) * 4) + (3-(x%4)));
  if(line_buf[i].x > 0 && line_buf[i].x < WIDTH &&
     line_buf[i].y > 0 && line_buf[i].y < HEIGHT) {
   SET_JBUF( (line_buf[i].x), (line_buf[i].y) )
 }
}

int current_screen; 
int current_screen2;

int bA, bB;
int dA, dB;
float scroll_bounce;

float cam_pitch, cam_yaw;

typedef struct {
 float x, y, z;
} vert_t;

typedef struct {
 int a,b,c;
} tri_t;

tri_t *tris;
int num_tris;
vert_t *verts, *rot_verts;
int num_verts;

void rotate(void) {
 int zoom;
 float yaw_cos, yaw_sin;
 float pitch_cos, pitch_sin;
 int i;
 float temp;
 yaw_cos = cos(cam_yaw);
 yaw_sin = sin(cam_yaw);
 pitch_cos=cos(cam_pitch);
 pitch_sin=sin(cam_pitch);
 if(current_screen == 2) 
  zoom = 200;
 else
  zoom = 50 + (current_screen2 * 10);
 for(i=0;i<num_verts;i++) {
  rot_verts[i].x = yaw_cos * verts[i].x + yaw_sin * verts[i].z;
  rot_verts[i].z = yaw_cos * verts[i].z - yaw_sin * verts[i].x;
      temp = pitch_cos*rot_verts[i].z + pitch_sin*verts[i].y;
  rot_verts[i].y = pitch_cos*verts[i].y - pitch_sin*rot_verts[i].z;
  rot_verts[i].z = temp;

  rot_verts[i].x/=(rot_verts[i].z - 7.0f);
  rot_verts[i].y/=(rot_verts[i].z - 7.0f);
  rot_verts[i].x*=(zoom*1.5f);
  rot_verts[i].y*=zoom;
  rot_verts[i].z-=30.0f;
  rot_verts[i].x+=(WIDTH/2);
  rot_verts[i].y+=(HEIGHT/2);
 }
}



void draw_tris(void) {
 int i;
 float z_normal;
 /* triangle z normal = 
  *  b.x - a.x * c.y - b.y * c.x - b.x * b.y - a.y  */

 for(i=0;i<num_tris;i++) {
  z_normal = 
     (((rot_verts[tris[i].b].x-rot_verts[tris[i].a].x) *
       (rot_verts[tris[i].c].y-rot_verts[tris[i].b].y)) -
      ((rot_verts[tris[i].c].x-rot_verts[tris[i].b].x) *
       (rot_verts[tris[i].b].y-rot_verts[tris[i].a].y)));
  if(current_screen == 3) z_normal*=-1.0f;
  if(z_normal<0) {
   line( 
     (int)rot_verts[tris[i].a].x, (int)rot_verts[tris[i].a].y,
     (int)rot_verts[tris[i].b].x, (int)rot_verts[tris[i].b].y);
   if(current_screen != 19) {
    line( 
      (int)rot_verts[tris[i].b].x, (int)rot_verts[tris[i].b].y,
      (int)rot_verts[tris[i].c].x, (int)rot_verts[tris[i].c].y);
    line( 
      (int)rot_verts[tris[i].c].x, (int)rot_verts[tris[i].c].y,
      (int)rot_verts[tris[i].a].x, (int)rot_verts[tris[i].a].y);\
   }
  }
 }
}

#define NEW_BOUNCE 3000000000.0f

#include "fuck_ball.h"

char match(int k) {
 int i, q;
 int A,B;
 int level, m_level;
 char m_char; 
 A = jbuf[(k*2)];
 B = jbuf[(k*2)+1];
 if((A+B) == 0) {
  m_char = ' ';
  goto match_done;
 }
 m_level = 0;

 for(i = 0;i<95;i++) {
  level = 0;
  for(q = 0;q < 8;q++) {
   if( ((A>>q)&1)==((font_data[i*2  ]>>q)&1) )
    level++;
   if( ((B>>q)&1)==((font_data[(i*2)+1]>>q)&1) ) 
    level++;
  }
  if(level > m_level) {
   m_level = level;
   m_char = i+32;
  }
 }
   
 match_done:
  return m_char;
}

char text(int k) {
 int x;
 int x_index, y_index, index;
 char m_char;
  x = (k%CWIDTH);
  x_index =  (x+(int)scroll_bounce)&7;
  index =    (x+(int)scroll_bounce)>>3;
  y_index =  (k/CWIDTH)-32;
  m_char=
  alphabet[screen1_messages[screen1_current_message][index%11]-'@']
          [(y_index*ALPHA_WIDTH)+x_index];
 return m_char;
}

int bio_back_x;
int bio_back_y;

int mountain_front = 0;

void draw_screen(void) {
 int i, k, q;
 int x, y;
 int A,B;
 int r;
 float normal;
 unsigned char *pix;

 draw_timer++;

 if(draw_timer>=screen1_song[screen1_next].wait) {
  current_screen = screen1_song[screen1_next].value;
  current_screen2 = 0;
  if(current_screen == 4)
   mountain_front++;
  tick = 1;
  screen1_next++;
 } 
 if(draw_timer>=screen2_song[screen2_next].wait) {
  current_screen2 = screen2_song[screen2_next].value;
  tick = 1;
  screen2_next++;
 } 


#define BLANK	bzero(jbuf, CWIDTH*CHEIGHT*2);
#define PROLOG	for(k=0;k<CWIDTH*CHEIGHT;k++)

 switch(current_screen) {
  case 0:
   if(current_screen2==0) { 
    PROLOG 
     cbuf[k] = ' ';
    break;
   }
   if(current_screen2==1)
    PROLOG
     cbuf[k] = screen0_0[k];
   else
    PROLOG
     cbuf[k] = screen0_1[k];
   break;
  case 1:
   BLANK
   if(tick == 1) {
    screen1_current_message++;
    screen1_current_message&=3;
    scroll_bounce = NEW_BOUNCE;
    tick = 0;
   }
   line(0, bA-40, WIDTH, bB-40);
   line(0, bA-30, WIDTH, bB-30);
   line(0, bA, WIDTH, bB);
   line(0, bA+20, WIDTH, bB+20);
   line(0, bA+30, WIDTH, bB+30);
   line(0, bA+35, WIDTH, bB+35);

   if(bA>(HEIGHT/2))
    dA--;
   else
    dA++;
   bA+=dA;
   if(bB>(HEIGHT/2))
    dB--;
   else
    dB++;
   bB+=dB;
   PROLOG {
    if(k<(32*CWIDTH)){
     if(thea[k] != ' ') {
      if(thea[k] == 'q')
       cbuf[k]= ' ';
      else
       cbuf[k] = thea[k];
     } else
      cbuf[k] = match(k);
    } else
     if( ((k/CWIDTH)>31) &&
         ((k/CWIDTH)< (31+ALPHA_HEIGHT)) ) {
       if((cbuf[k]=text(k))=='@')
        cbuf[k]=match(k);
     } else
      cbuf[k] = match(k);
    }
   scroll_bounce/=1.3f;
   break;
  case 2:
   BLANK
   cam_pitch+=0.04f;
   cam_yaw+=0.08f;
   scroll_bounce/=1.3f; 
   tris =  fuckball_tris; 
   verts = fuckball_verts;
  
   num_verts = 42;
   num_tris = 80;

   rotate();
   draw_tris();
   PROLOG {
    if(k<(18*CWIDTH) && k>(13*CWIDTH)) {
     if(just_eyes[k-(13*CWIDTH)]!=' ') {
      if(just_eyes[k-(13*CWIDTH)]=='q')
       cbuf[k] = ' ';
      else
       cbuf[k] = just_eyes[k-(13*CWIDTH)];
     } else
      cbuf[k] = match(k);
    } else
     if( ((k/CWIDTH)>31) &&
        ((k/CWIDTH)< (31+ALPHA_HEIGHT)) ) {
      if((cbuf[k]=text(k))=='@')
       cbuf[k]=match(k);
     } else
      cbuf[k] = match(k);
    }
   scroll_bounce/=1.3f;
   break;
  case 3:
   BLANK
   cam_pitch+0.04f;
   cam_yaw+=0.09f;
   tris = fuckball_tris;
   verts =fuckball_verts;
   num_verts = 42;
   num_tris = 80;
   rotate();
   draw_tris();
   PROLOG
    cbuf[k]=match(k);
   break; 
  case 4:
   BLANK
   r = random()%MAX_STARS;
   for(i = 0; i<MAX_STARS;i+=2) {
    if( (i == r) ||
      (i+1 == r)){
     stars[i].x =  (float)((random()%WIDTH) -(2/WIDTH));
     stars[i].y =  (float)((random()%HEIGHT)-(2/HEIGHT));
     stars[i+1].x =(float)((random()%WIDTH) -(2/WIDTH));
     stars[i+1].y =(float)((random()%HEIGHT)-(2/HEIGHT));
    }
    stars[i].x*=  STAR_SPEED;
    stars[i].y*=  STAR_SPEED;
    stars[i+1].x*=STAR_SPEED;
    stars[i+1].y*=STAR_SPEED;
    line(((int)stars[i].x+(WIDTH/2))%WIDTH, ((int)stars[i].y+(HEIGHT/2))%HEIGHT,
         ((int)stars[i+1].x+(WIDTH/2))%WIDTH, ((int)stars[i+1].y+(HEIGHT/2))%HEIGHT);
   }
   PROLOG
    if(k>(25*CWIDTH)  && (mountain_front == 4 || mountain_front == 5)) {
     cbuf[k] = mountains[k - (25*CWIDTH)];
     if(cbuf[k] =='q')
      cbuf[k]=match(k);
    } else
     cbuf[k] = match(k);
    
   break;
  case 5:
   for(y=1;y<(CHEIGHT-1);y++) 
    for(x=1;x<(CWIDTH-1);x++) {
     movement.x = 0.0f;
     movement.y = 0.0f;
#define SMALL	0.09999f;
     for(i=0;i<8;i++) {
      if((i&1) == 0)
       normal = 5.656854;
      else
       normal = 4.0f;
      vectors[i].x = wonka[(x+(CWIDTH*y)+neighbors[i])].x - wonka[x+(CWIDTH*y)].x;
      vectors[i].y = wonka[(x+(CWIDTH*y)+neighbors[i])].y - wonka[x+(CWIDTH*y)].y;
      me[i].MAG = sqrt( (vectors[i].x*vectors[i].x)+(vectors[i].y*vectors[i].y));
      me[i].EXT = (me[i].MAG - normal)/normal;
      vectors[i].x*=(1.0f/me[i].MAG);
      vectors[i].y*=(1.0f/me[i].MAG);
      force[i].x = (vectors[i].x * me[i].MAG)*SMALL;
      force[i].y = (vectors[i].y * me[i].MAG)*SMALL;
      movement.x+=force[i].x;
      movement.y+=force[i].y;
     }
     wonka2[x+(CWIDTH*y)].x = wonka[x+(CWIDTH*y)].x + movement.x;
     wonka2[x+(CWIDTH*y)].y = wonka[x+(CWIDTH*y)].y + movement.y;
    }
   // HERE just memcpy this fuzz
   for(y=1;y<(CHEIGHT-1);y++)
    for(x=1;x<(CWIDTH-1);x++) {
     wonka[x+(CWIDTH*y)].x = wonka2[x+(CWIDTH*y)].x;
     wonka[x+(CWIDTH*y)].y = wonka2[x+(CWIDTH*y)].y;
    }

#define MONKEY_SPEED	0.04f
   if(current_screen2 == 1) { 
    wonka[40+(20*80)].x = (float)(random()%2000)-1000.0f;
    wonka[40+(20*80)].y = (float)(random()%2000)-1000.0f;
    space_monkey+=MONKEY_SPEED;
    if(space_monkey> 4.3f) space_monkey = 4.3f;
   } else
    space_monkey-=MONKEY_SPEED;
   if(space_monkey<0.0f) space_monkey = 0.0f;

   PROLOG {
    if(k<(22*CWIDTH) && k>(16*CWIDTH) && (outer_fucking_space[k-(16*CWIDTH)
                                          +(CWIDTH*(6*(int)space_monkey))]!='q')) {
     cbuf[k] = outer_fucking_space[k-(16*CWIDTH)+
                                          +(CWIDTH*(6*(int)space_monkey))]; 
    } else {
     i = (int)(wonka[k].x/4.0f)+(CWIDTH*(int)(wonka[k].y/4.0));
     if(i > 0 && i < CWIDTH*CHEIGHT)
      cbuf[k]=random_text[i];
     else
      cbuf[k] = ' ';
    }
   }
   break;
  case 6: 
  if((draw_timer%10) == 0)
   bio_back_x++;
  if((draw_timer%5) == 0)
   bio_back_y++;

  if((draw_timer%1) == 0) 
   text_pos++;
/*   for(;;) {
    if(bio_bio[text_pos]==' ')
     text_pos++;
    else
     break;
   } */

   PROLOG {
    if(k<(26*CWIDTH)) {
     if((cbuf[k]=bio[k])=='q') {
      y = (k/CWIDTH)+bio_back_y;
      cbuf[k] =bio_back[ ((k+bio_back_x)%16)+  ((y%8)*16) ];
     }
    } else 
     if((k-(26*CWIDTH)) < text_pos)
      cbuf[k] = bio_bio[k-(26*CWIDTH)];
     else
      cbuf[k] = ' ';
    
   }
   break;

 }


 for(y=0;y<CHEIGHT;y++) {
  A = B = 0;
  for(i = 0;i<CWIDTH;i++) {
   A+= cbuf[ (y*CWIDTH) +i];
   B+=lcbuf[ (y*CWIDTH) +i];
  }
//  if(A==B)
//   printf("\33[1B"); 
//  else {
   for(x=0;x<CWIDTH;x++) {
    putchar(cbuf[ x+(y*CWIDTH)]);
    lcbuf[x+(y*CWIDTH)] = cbuf[x+(y*CWIDTH)];
   }
   putchar('\n');
//  }
 }

 printf("\33[40A");
 fflush(stdout);
}

int main(int argc, char **argv) {
 int i, k,j, data, sign;
 int x,y;
 int walker;
 int dump;
 FILE *dump_file;
 unsigned char *hard_buf;


 amen = (unsigned char *)malloc( 0xffff );

 pos_in = 8;

 /* expand amen */
 walker = amen_delta[0];
 amen[0] = walker;
 for(i=1;i<0xffff;i++) {
  sign = bit_in();

  data = bit_in();
  data|= bit_in()<<1;
  data|= bit_in()<<2;
  data|= bit_in()<<3;
  data|= bit_in()<<4;

  if(sign == 0)
   walker += data;
  else
   walker -= data;
  amen[i] = walker;
 }

 if(argc >1 ) 
  if(strcmp(argv[1],"-d")==0){
   dump = 1;
   printf("I'm just going to dump this to run.dump\n");
   if(!(dump_file = fopen("run.dump", "wb")))
    err("Could not open dump file");
   goto just_dump;
  } 

#ifdef OPENBSD
 audio_info_t req, get;
#endif

#ifdef LINUX
 int format, channels, rate;
#endif

 if(!(audp=fopen(AUDIO_DEV,"w")))
  err("could not open audio device, sorry");

#ifdef OPENBSD
 AUDIO_INITINFO(&req);
 req.mode = AUMODE_PLAY;
 req.play.sample_rate = RATE;
 req.play.channels = 1;
 req.play.precision = 16;
 req.play.encoding = AUDIO_ENCODING_SLINEAR;
 if(!ioctl(fileno(audp), AUDIO_SETINFO, &req))
  err(COULD_NOT_GET);
 ioctl(fileno(audp), AUDIO_GETINFO, &get);
  if(req.play.sample_rate != get.play.sample_rate ||
    req.play.channels !=    get.play.channels    ||
    req.play.precision !=   get.play.precision   ||
    req.play.encoding  !=   get.play.encoding) {
   printf(COULD_NOT_GET 
     "\nSo instead I'm dumping audio to run.dump. Read readme.txt\n");
   dump = 1;
   if(!(dump_file = fopen("run.dump", "wb")))
    err("Could not open dump file");
  }
  goto just_dump;

#endif

#ifdef LINUX
  format = AFMT_S16_LE;
  rate = RATE / 2;
  channels = 1;
  if( ioctl(fileno(audp),SNDCTL_DSP_SETFMT, &format)  == -1 ||
      ioctl(fileno(audp),SNDCTL_DSP_SPEED, &rate)     == -1 ||
      ioctl(fileno(audp),SNDCTL_DSP_STEREO, &channels)== -1 )
   err(COULD_NOT_GET);
  else 
   if(format  != AFMT_S16_LE ||
      rate    != RATE  /2      ||
      channels!= 1) {
    printf(COULD_NOT_GET 
      "\nSo instead I'm dumping audio to run.dump. Read readme.txt\n");
    dump = 1;
    if(!(dump_file = fopen("run.dump", "wb")))
     err("Could not open dump file");
    goto just_dump;
   }  
  
#endif


 cbuf = (unsigned char *)malloc(CWIDTH * CHEIGHT);
 bzero(cbuf, CWIDTH * CHEIGHT);
 lcbuf = (unsigned char *)malloc(CWIDTH *CHEIGHT);
 memset(lcbuf, 0xff, CWIDTH*CHEIGHT);
 line_buf = (point_t *)malloc(WIDTH * HEIGHT *2);
 jbuf = (unsigned char *)malloc(CWIDTH * CHEIGHT * 2);

 bA = 20;
 dA =0;
 bB = 30;
 dB = 0;

 screen1_current_message = -1;
// scroll_bounce = NEW_BOUNCE;
 current_screen = 0;
 current_screen2 = 0;
 space_monkey = 0.0f;
 draw_timer = 0;

 rot_verts = (vert_t *)malloc(sizeof(vert_t) * 0xfff);
 cam_pitch = 0.0f;
 cam_yaw = 0.0f;

 for(y=0;y<CHEIGHT;y++) 
  for(x=0;x<CWIDTH;x++) {
    wonka[x+(CWIDTH*y)].x = x*4;
    wonka[x+(CWIDTH*y)].y = y*4;
   wonka2[x+(CWIDTH*y)].x = x*4;
   wonka2[x+(CWIDTH*y)].y = y*4;
  }

 for(i=0;i<MAX_STARS;i++ ) {
  stars[i].x = (random()%WIDTH)-(WIDTH/2);
  stars[i].y = (random()%HEIGHT)-(HEIGHT/2);
 }


just_dump:


 timer = 0;

 can_drum =0;
 drum_pos = 0;
 drum_next = 0;
 bzero(drum_mods, sizeof(int) * 0x12);


 screen1_next = 0;
 screen2_next = 0;
 tick = 0;
 klang_next = 0;
 bzero(klang_mods,17);

 SND_BUF1 = (float *)malloc(BUF*sizeof(float)*3);
 SND_BUF2 = (float *)SND_BUF1+BUF;
 SND_BUF3 = (float *)SND_BUF2+BUF;

 modulus = (int *)malloc(sizeof(int)*BUF);
 hard_buf = (unsigned char *)malloc( 2 * BUF);

 envelope1.A = 0.90f;
 envelope1.D = 0.01f;
 envelope1.S = 1.00f;
 envelope1.R = 0.01f;
 envelope1.oldtrig = 0;
 envelope1.trigger = 0;
 envelope1.value = 0.0f;
 envelope1.startlevel = 0.07f;
 envelope1.phase = R;

 reso1.cutoff = 0.30f;
 reso1.resonance = 0.07f;
 reso1.d1 = 0.0f;
 reso1.d2 = 0.0f;
 reso1.f = reso1.cutoff;
 reso1.q = reso1.resonance;

 memcpy(&reso2, &reso1, sizeof(reso_t));

 for(;;) {
  audio(buf);
  for(i=0;i<2*BUF;) {
   data = buf[i/2]*20000;
   if(dump == 1) {
#ifdef LITTLE_ENDIAN
    hard_buf[i++] =  data&0xff;
    hard_buf[i++] = (data&0xff00) >> 8;
#else
    hard_buf[i++] = (data&0xff00) >> 8;
    hard_buf[i++] =  data&0xff;
#endif
   } else {
    hard_buf[i++] =  data&0xff;
    hard_buf[i++] = (data&0xff00)>>8;
   }
  }
  fwrite(hard_buf, 2, BUF, (dump == 1 ? dump_file : audp));
  if(dump != 1)
   draw_screen();
 } 
}

