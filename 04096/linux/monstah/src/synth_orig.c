#include <math.h>
#include <stdlib.h>
//#include "macros.h"

#define CHANNELS  3
#define PATTERNS  64
#define PLAYLISTS 128

#define SAMPLING_FREQ 8000

#define SAMPLE_LEN 512

#define OCTAVES 8

enum {
  I_NOISE  = 1,
  I_SQUARE = 2,
  I_SINE   = 3,
  SAMPLES
};

static int music_not_playing;

static unsigned char samples[SAMPLES][SAMPLE_LEN];

static unsigned int notefreqs[OCTAVES*13];

#ifndef playlist_count /* this is defined as a macro in intro */
static int playlist_count;
#endif
static int playlist[PLAYLISTS][CHANNELS];
static int *playlist_ptr = &playlist[0][0];

#ifndef pattern_size /* this is defined as a macro in intro */
static int pattern_size;
#define MAX_PATTERN_SIZE 512
#else
#define MAX_PATTERN_SIZE pattern_size
#endif

static int channel_row;
static int channel_pattern[CHANNELS];

static struct {
  unsigned int type;
  int arg1;
  int arg2;
  int dummy;
} tab[PATTERNS][MAX_PATTERN_SIZE];

static struct channel_struct {
  unsigned int instr;
  int freq;
  int vol;

  int freq_inc;
  int vol_inc;

  unsigned int pos;
} channels[CHANNELS];

static int t;

//#include "pow2.c"

static void music_prepare() {
  int i;

  for(i=0; i<OCTAVES*12; i++) {
#if 1
    notefreqs[i] = (unsigned int) (440 * 65536 * powf(2.0f, (-51 + i) / 12.0f));
#else
    notefreqs[i] = (unsigned int) (440 * 65536 * ((-51 + i) / 12.0f));
#endif
  }
  //notefreqs[0] = 0;

  for(i=0; i<SAMPLE_LEN; i++) {
    samples[I_NOISE][i] = rand();

    samples[I_SQUARE][i] =
      ((unsigned int) i & (SAMPLE_LEN / 2)) * 2 * 255 / SAMPLE_LEN;

    float f = 3.14159265f*2*i/SAMPLE_LEN;
    float c = cosf(f);
    samples[I_SINE][i] = 127 - ftoi(c * 127);

#if 0
    samples[I_SINE2][i] =
      127 - ftoi(c * 87 + cosf(f*2) * 30 + cosf(f*4) * 10);
#endif
  }

//  for(i=0; i<CHANNELS; i++)
//    channel_pattern[i] = playlist[0][i];
}

#ifdef USE_STDOUT_AUDIO
/* Seems like putchar() takes less space */
static inline void write_byte_to_stdout(unsigned char c) {
  __asm__ __volatile__ (
      "int $0x80"
      :
      : "a"(4), "b"(1), "c"(&c), "d"(1)
      );
}
#endif

#ifdef USE_STDOUT_AUDIO
static NORETURN void music_fill_forever() {
#else
static void music_fill(void *userdata, Uint8 *stream, int len) {
#endif
  do {
    unsigned int i;
    unsigned char c = 0;

    struct channel_struct *ch = &channels[0];

    for(i=0; i<CHANNELS; i++, ch++) {
    /* Get commands */

#if 1
      if((t % TEMPO) == 0) {
        unsigned int pat = channel_pattern[i];
        int notefreq = notefreqs[tab[pat][channel_row].arg1];
        int vol = tab[pat][channel_row].arg2 * 65536;
        unsigned int t = tab[pat][channel_row].type;

        ch->freq_inc = 0;
        ch->vol_inc = 0;

        /* TODO */
        if(channel_row >= pattern_size)
          break;

        if(t == 0) {
          ch->freq_inc =
            (notefreq - channels[i].freq) / TEMPO;

          ch->vol_inc =
            (vol - channels[i].vol) / TEMPO;
        }
        else {
          ch->instr = t;
          ch->vol = vol;

          if(t == 1) {
            ch->freq = SAMPLING_FREQ*65536/SAMPLE_LEN;

            ch->vol_inc = -ch->vol *
              tab[pat][channel_row].arg1 / (20 * TEMPO);
          }
          else {
            ch->freq = notefreq;
          }

          ch->pos = 0;
        }

        /* TODO */
        if(i == CHANNELS-1)
          channel_row++;
      }
#endif

      /* Mix channels & generate music */

      unsigned int p = (ch->pos + ch->freq/SAMPLING_FREQ*SAMPLE_LEN) &
          (65536*SAMPLE_LEN-1);
      ch->pos = p;
      p >>= 16; // 65536;

      /* Effects (very shocking indeed!) */

      ch->freq += ch->freq_inc;
      ch->vol += ch->vol_inc;

      /* And the instrument... */

      if(ch->instr && ch->vol > 0) {
        c += samples[ch->instr][p] * ((unsigned int) ch->vol / 65536) / 256;
      }
    }
    if(i != CHANNELS) {
    /* If patterns have ended, get next patterns from playlist */
//      playlist_cur++;
      if(playlist_ptr >= &playlist[playlist_count][0]) {
#ifdef WIN32
        music_not_playing = 1;
        break;
#else
#ifdef DEBUG
        exit(0);
#else
        __asm__ __volatile__ ("cli");
#endif
      }

      for(i=0; i<CHANNELS; i++) {
        channel_pattern[i] = *playlist_ptr++;
        //playlist[playlist_cur][i];
      }
      channel_row = 0;

      continue;
    }
#endif

    /* Increase timer */

    t++;

    /* Write */

#ifdef USE_STDOUT_AUDIO
    putchar(c);
//    write_byte_to_stdout(c);
  } while(1);
#else
    *stream++ = c;
  } while(len--);
#endif
}
