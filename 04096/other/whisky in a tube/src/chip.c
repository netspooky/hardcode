#include <stdint.h>

#include "notetable.h"

typedef int16_t sample_t;

#define TEMPO 4100
#if defined(STANDALONE)
#define SONGLEN (44100 * 70)
#endif
#define PATTLEN 16
#define TRACKS 5

#define C  0x01
#define Cs 0x02
#define D  0x03
#define Eb 0x04
#define F  0x05
#define G  0x06
#define Ab 0x07
#define A  0x08
#define B  0x09

#define O0 0x00
//#define O1
#define O2 0x10
#define O3 0x20
#define O4 0x30

#define Q  0x40

#define BD 0x80

const unsigned char pattern[] = {
/////////////// 0
    BD | C, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, F|Q, 
    Eb, Eb|Q, BD|Eb|Q, BD|Eb|Q, Eb|Q, Eb|Q, Eb|Q, G|Q, 

    C | O4 |Q, C | O3 |Q, C | O4 |Q, B | O3|Q, B|O2|Q, B|O3|Q, G|O3|Q, F|O3|Q, 
    G | O3|Q, G | O2|Q, G | O3|Q, B | O3|Q, B|O2|Q, B|O3|Q, C|O4|Q, C|O3|Q, 

    C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, 
   Eb | O3, Eb | O3, Eb | O3, Eb | O3, Eb | O3, Eb | O3, Eb | O3, Eb | O3, 

    G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, 
    G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, 

    5, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 10, 0, 5, 0, 0, 0, 

/////////////// 1
    BD | Ab, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, B|Q, 
    F, F|Q, BD|F|Q, BD|F|Q, F|Q, F|Q, F|Q, Eb|Q, 
    
    Ab | O4|Q, Ab | O3|Q, Ab  | O4|Q, G | O3|Q, G|O2|Q, G|O3|Q, Eb|O3|Q, Eb|O3|Q, 
    Ab | O4|Q, Ab | O3|Q, Ab  | O4|Q, G | O3|Q, G|O2|Q, G|O3|Q, Eb|O3|Q, Eb|O3|Q, 
    
    C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, 
    F | O3, F | O3, F | O3, F | O3, F | O3, F | O3, F | O3, F | O3, 

    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, 
    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, 

    5, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 10, 5, 0, 

/////////////// 2
    BD|Ab, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, 
    B , B |Q, BD|B |Q, BD| B |Q, B |Q, B |Q, B |Q, B |Q, 
    
    Ab | O3|Q, Ab |O2|Q, Ab | O3, Eb| O3, Eb|O2, Ab | O3, B | O3, C | O4, 
    B | O3|Q , B |O2|Q, B | O3, F| O3|Q, F|O3, D| O4, C | O4|Q, B | O3|Q, 

    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, 
    B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, 

    C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, 
    Eb | O3, Eb | O3, Eb | O3, Eb | O3, D | O3, D | O3, D | O3, D | O3, 

    0x40 | 5, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 
    0, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 5, 0x40 | 0, 0x40 | 0, 0x40 | 0, 0x40 | 

/////////////// 3
    BD | B, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, F|Q, 
    Eb, Eb|Q, BD|Eb|Q, BD|Eb|Q, Eb|Q, Eb|Q, Ab|Q, G|Q, 

    G|O4|Q, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 

    0, Q|C|O4, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O4, Q|D|O4, Q|Eb|O4, 0, 

    0, Q|C|O3, 0, 0, Eb|O3, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O3, Q|D|O3, Q|Eb|O3, 0, 

    0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 
    0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 0x40 | 20, 

/////////////// 4
    BD | B, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, F|Q, 
    Eb, Eb|Q, BD|Eb|Q, BD|Eb|Q, F|Q, F|Q, BD| Ab|Q, G|Q, 

    G|O4|Q, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, Ab|O3|Q, Ab|O3|Q, G|O3|Q, G|O3|Q, 

    0, Q|C|O4, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O4, Q|D|O4, Q|Eb|O4, 0, 

    0, Q|C|O3, 0, 0, Eb|O3, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O3, Q|D|O3, Q|Eb|O3, 0, 

    0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 
    0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 0x40 | 15, 

/////////////// 5
    BD | B, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, B|Q, 
    F, F|Q, BD|F|Q, BD|F|Q, Ab|Q, Ab|Q, BD| G|Q, G|Q, 

    G|O4|Q, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, Ab|O3|Q, C|O3|Q, G|O2|Q, D|O3|Q, 

    0, Q|C|O4, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O4, Q|D|O4, Q|Eb|O4, 0, 

    0, Q|C|O3, 0, 0, Eb|O3, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O3, Q|D|O3, Q|Eb|O3, 0, 

    0x80 | 0, 0x80 | 0, 0x80 | 0, 0x80 | 55, 0x80 | 60, 0x80 | 0, 0x80 | 0, 0x80 | 0, 
    0x80 | 0, 0x80 | 0, 0x80 | 0, 0x80 | 60, 0x80 | 0, 0x80 | 0, 0x80 | 0, 0x80 | 0, 

/////////////// 6
    BD | C, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, 
    F, F|Q, BD|F|Q, BD|F|Q, Cs|Q, Cs|Q, BD|Cs|Q, Cs|Q, 

    G|O4|Q, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, F|O3|Q, G|O3|Q, 

    0, Q|C|O4, 0, 0, 0, 0, 0, 0, 
    0, 0, C|O4|Q, C|O4|Q, F|O3, F|O3|Q, Ab|O3|Q, Cs|O4|Q, 

    0, Q|C|O3, 0, 0, Eb|O3, 0, 0, 0, 
    0, 0, F|O3|Q, F|O3|Q, Ab|O3, Cs|O4|Q, Eb|O4|Q, F|O4|Q, 
    
    0, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 

/////////////// 7
    BD | C, C|Q, C|Q, C|Q, C|Q, C|Q, B|Q, Eb|Q, 
    F, F |Q, BD|F |Q, BD|F |Q, F |Q, F |Q, F |Q, G|Q, 

    C | O4|Q, C |O3|Q, C | O4|Q, B| O3|Q, B|O2|Q, B | O3, C | O4 |Q, C | O3, 
    G | O3, G | O3, G | O3, A | O3, A | O3, B | O3, C | O4|Q, D | O3 |Q, 

    C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, 
    F | O3, F  | O3, F  | O3, F  | O3, F  | O3, F  | O3, F  | O3, F  | O3, 
    
    G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, G | O3, 
    A | O3, A | O3, A | O3, A | O3, B | O3, B | O3, B | O3, B | O3, 

    5, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 10, 0, 5, 0, 0, 0, 

/////////////// 8
    BD|Ab, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, G|Q, Ab|Q, 
    B , B |Q, BD|B |Q, BD| B |Q, B |Q, B |Q, D |Q, C |Q, 

    Ab | O3|Q, Ab |O2|Q, Ab | O3, Eb| O3, Eb|O2, Ab | O3, Ab | O3, C | O4, 
    B | O3|Q , B |O2|Q, B | O3, F| O3|Q, F|O3, D| O4, C | O4|Q, B | O3|Q, 

    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Eb | O3, F | O3, Ab | O3, 
    B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, 

    C | O4, C | O4, C | O3|Q, C | O4, C | O3|Q, Ab | O3, B  | O3, C | O4|Q, 
    Eb | O4, Eb | O4, D | O4, C | O4, C | O3|Q, D | O3, D | O3, D | O3, 

    5, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 

/////////////// 9
    0, 0, BD| Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, 
    B , B |Q, BD|B |Q, B |Q, B |Q, B |Q, BD|G |Q, Eb |Q, 
    
    Ab | O3|Q, Ab |O2|Q, Ab | O3, Eb| O3, Eb|O2, Ab | O3, B | O3, C | O4, 
    B | O3|Q , B |O2|Q, B | O3, F| O3|Q, F|O3, D| O4, C | O4|Q, B | O3|Q, 

    Ab | O3, Ab | O3|Q, Ab | O3, Ab | O3, Ab | O3|Q, Ab | O3, Ab | O3, Ab | O3|Q, 
    B | O3, B | O3|Q, B | O3|Q, B | O3, B | O3, G | O3|Q, Eb | O3|Q, B | O3|Q, 

    C | O4, C | O4|Q, C | O4, C | O4, C | O4|Q, C | O4, C | O4, C | O4|Q, 
    Eb | O4, Eb | O4|Q, Eb | O4|Q, D | O4, D | O4|Q, B | O3|Q, G | O3|Q, Eb | O3|Q, 

    0, 0, 10, 0, 30, 0, 0, 0, 
    0, 0, 0, 0, 5, 0, 0, 0, 

/////////////// 10
    0, 0, BD | 0, 0, 0, C|Q, C|Q, 0, 
    Eb, Eb|Q, BD|Eb|Q, BD|Eb|Q, Eb|Q, Eb|Q, Eb|Q, G|Q, 

    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,

    0, 0, C|O3|Q, C|O3|Q, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, B|O3|Q, B|O3|Q, 

    0, 0, G|O3, G|O3|Q, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, F|O3, F|O3|Q, 

    35, 35, 40, 35, 35, 35, 35, 35,
    35, 35, 45, 45, 35, 35, 35, 35,

/////////////// 11
    BD|Ab, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, G|Q, Ab|Q, 
    B , B |Q, BD|B |Q, BD| B |Q, B |Q, BD|B |Q, BD|F |Q, G |Q, 

    Ab | O3|Q, Ab |O2|Q, Ab | O3, Eb| O3, Eb|O2, Ab | O3, Ab | O3, C | O4, 
    B | O3|Q , B |O2|Q, B | O3, F| O3|Q, F|O3, D| O4, C | O4|Q, B | O3|Q, 

    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Eb | O3, F | O3, Ab | O3, 
    B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, 

    C | O4, C | O4, C | O3|Q, C | O4, C | O3|Q, Ab | O3, B  | O3, C | O4|Q, 
    Eb | O4, Eb | O4, D | O4, C | O4, C | O3|Q, D | O3, D | O3, D | O3, 

    5, 0, 0, 0, 0, 0, 0, 0, 
     0,  0,  5,  0,  10,  5,  30,  30, 

/////////////// 12

    BD | B, C|Q, C|Q, C|Q, C|Q, C|Q, C|Q, F|Q, 
    Eb, Eb|Q, BD|Eb|Q, BD|Eb|Q, Eb|Q, Eb|Q, Ab|Q, G|Q, 

    G|O4|Q, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0, 

    0, Q|C|O4, 0, 0, G|O3|Q, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O4, Q|D|O4, Q|Eb|O4, 0, 

    0, Q|C|O3, 0, 0, Eb|O3|Q, 0, 0, 0, 
    0, 0, 0, 0, Q|C|O3, Q|D|O3, Q|Eb|O3, 0, 

    0x80 | 50, 0x80 | 0, 0x80 | 0, 0x80 | 55, 0x80 | 60, 0x80 | 0, 0x80 | 0, 0x80 | 0, 
    0x80 | 0, 0x80 | 0, 0x80 | 0, 0x80 | 55, 0x80 | 60, 0x80 | 0, 0x80 | 0, 0x80 | 0, 

#if 1
/////////////// 5
    BD|Ab, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, Ab|Q, 
    B , B |Q, BD|B |Q, BD| B |Q, B |Q, B |Q, B |Q, B |Q, 
    
    Ab | O3|Q, Ab |O2|Q, Ab | O3, Eb| O3, Eb|O2, Ab | O3, B | O3, C | O4, 
    B | O3|Q , B |O2|Q, B | O3, F| O3|Q, F|O3, D| O4, C | O4|Q, B | O3|Q, 

    Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, Ab | O3, 
    B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, B | O3, 

    C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, C | O3, 
    Eb | O3, Eb | O3, Eb | O3, Eb | O3, D | O3, D | O3, D | O3, D | O3, 

    8, 0, 0, 0, 0, 0, 0, 0, 
    0, 0, 0, 0, 0, 0, 0, 0,
#endif
};

const char song[] = {
	10, 10,
	0, 1, 0, 1,
	2, 7, 8, 1,
	3, 4, 3, 6,
	9, 7, 11, 1,
	12, 5, 12, 5,
	12, 5, 12, 5,
};

const unsigned vol[] = {6200, 3000, 2600, 2600};
const unsigned pwm[] = {0x80000000, 0x80000000, 0xc0000000, 0xc0000000};

#if 1
/* gray, flash, hue, count, str */
const float effects[] =
{
  0, 0, 0, 0, 0,

  // p2
  0.2f, 2.1f, 0.0f, 200.0f, 1.0f,
  0.0f, 0.5f, 0.0f, 500.0f, 0.3f, //10

  // part 1
  0.0f, -0.8f, 2.0f, 0.0f, 0.0f,
  0.0f, -0.8f, 2.0f, 30.0f, 1.0f, // 20
  0.0f, -0.8f, 2.0f, 150.0f, 1.0f,

  // iso
  1.0f, 40.0f, 0.0f, 1000.0f, 2.3f, // 30

  // bw
  1.0f, 0.0f, 0.0f, 0.0f, 0.0f,
  1.0f, 0.0f, 0.0f, 200.0f, 0.3f, // 40
  1.0f, 0.0f, 0.0f, 10.0f, 1.2f,

  0.0f, 0.0f, -1.0f, 10.0f, 0.4f, // 50
  0.0f, 0.0f, -1.0f, 900.0f, 0.5f, // 55
  -0.2f, -0.5f, -1.0f, 900.0f, 0.5f, // 60
};
#else
/* gray, flash, hue, count, str, fixed point 1/10 */
const int16_t effects[]
{
  0, 0, 0, 0, 0,

  // p2
  2, 21, 0, 2000, 10,
  0, 5, 0, 5000, 3, // 10

  // part 1
  0, -8, 20, 0, 0,
  0, -8, 20, 300, 10, // 20
  0, -8, 20, 1500, 10,

  // iso
  10, 400, 0, 10000, 23, // 30

  // bw
  10, 0, 0, 0, 0,
  10, 0, 0, 2000, 3, // 40
  10, 0, 0, 100, 12,

  0, 0, -1, 10, 4, // 50
  0, 0, -10, 9000, 5, // 55
  -2, -5, -10, 9000, 5, // 60
};
#endif

#if defined(SIZETEST)
#include <stdlib.h>
#define frand(x) (x *  rand());
#elif defined(STANDALONE)
#include <stdlib.h>
float frand(float op)
{
	uint16_t ret = static_cast<uint16_t>(rand() & 0xFFFF);
	return static_cast<float>(*(reinterpret_cast<int16_t*>(&ret))) / 32768.0f * op;
}
#endif

#if defined(STANDALONE)
unsigned int g_audio_position = 0;
float g_uniform_array[4];
unsigned g_mover_queue;
float g_mover_strength;
int g_mode_control;
#endif
int x = 1;

void render(sample_t *buf, unsigned int len) {
  const unsigned fadestart = 44100 * 65 * 2;
	static int f = 0;
	for (unsigned i = 0; i < len; i++) {
		int sample = 0;

		for (unsigned c = 0; c < 4; c++) {

			unsigned subtick = g_audio_position / TEMPO;
			unsigned tick = subtick / 4;
			unsigned spos = tick / PATTLEN;
			unsigned ppos = (tick % PATTLEN) + c * PATTLEN;
			if (c + (subtick & 0x01) >= 3) ppos += PATTLEN;

			unsigned s = (unsigned)song[spos];
			unsigned d = pattern[ppos + (s & 0x3f) * (PATTLEN * TRACKS)];
			unsigned note = notetable[d & 0x0f];
			static const char shifts[] = {0, 2, 3, 4};
			unsigned shift = (unsigned)(shifts[(d >> 4) & 0x03]);

			static float bd = 0.0f;
			unsigned add = (g_audio_position * note << shift) + (unsigned)bd;
			unsigned v = vol[c];
			if ((d & Q) && (subtick & 0x02)) {
				v >>= 3;
			}

			if (c == 3) {
				g_mode_control = (uint8_t)(d >> 6);
				d &= 0x3f;
				if (g_audio_position > fadestart) {
				  ++f;
				  g_uniform_array[2] -= 0.000013f;
				} else if (d) {
				  g_uniform_array[1] = effects[d];
				  g_uniform_array[2] = effects[d+1];
				  g_uniform_array[3] = effects[d+2];
				}
				if (!(g_audio_position % (TEMPO * 4))) {
				  g_mover_queue += (unsigned)effects[d+3];
				  g_mover_strength = effects[d+4];
				}
				continue;
			}
			
			if (c > 0) {
				sample += ((g_audio_position * (note + 10000 + (1500 * (i & 0x01))) << shift) & pwm[c] ? 1 : -1) * v;
			} else {
				if (tick % 8 == 4) {
					bd = -10000;
				}
				
				if ((g_audio_position % (TEMPO*4)) == 0) {
					if (d & BD) {
						bd = 8000;
					}
				}

				if (bd > 500) {
 					sample += ((int)bd & 0x100) << 5;
					bd *= 0.9997f;
				}
				if (bd < -200) {
					static unsigned sd = 0;
 					if (!(g_audio_position & 0x15)) {
						sd = (((int)(frand(0.0006f) * bd)) *
						      ((g_audio_position & 0x400)));
					}
					sample += sd;
					bd *= 0.999965f;
				}
			}
			sample += (add & pwm[c] ? 1 : -1) * v;
		}
		sample = (sample * 44100) / (44100 + f);

		*(buf++) = (sample_t)sample;
		++g_audio_position;
	}
}

