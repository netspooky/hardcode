/*
 * Derivations
 * by zipola
 * Sound functions.
 */

#include <SDL/SDL.h>
#include <math.h>
#include <stdint.h>

#include "snd.h"

#define SOUND_SIZE 3200000
#define FS 44100

static uint16_t sound[SOUND_SIZE];
int sound_position = 0;

/*
 * Fill the sound.
 */
void generate_sound()
{
	int t = 0;
	for (t = 0; t < SOUND_SIZE; t++) {
		if (t < 10*FS) {
			uint16_t A = 16000;
			float f[] = { 440, 442, 550 };
			const int SINES = 3;
			float sum = 0;
			int i = 0;
			for (i = 0; i < SINES; i++) {
				sum = sum + 0.5 * (1 + sin(PI * f[i]/FS * t));
			}
			sound[t] = A * 1.0/SINES * sum;
		}
		if (t > 10*FS && t < 20*FS) {
			uint16_t A = 16000;
			float f[] = { 20, 25, 330, 690, 2200, 5700 };
			const int SINES = 6;
			float sum = 0;
			int i = 0;
			for (i = 0; i < SINES; i++) {
				sum = sum + 0.5 * (1 + sin(PI * f[i]/FS * t));
			}
			sound[t] = A * 1.0/SINES * sum;
		}
		if (t > 20*FS && t < 30*FS) {
			uint16_t A = 16000;
			float f[] = { 440, 439 };
			const int SINES = 2;
			float sum = 0;
			int i = 0;
			for (i = 0; i < SINES; i++) {
				sum = sum + 0.5 * (1 + sin(PI * f[i]/FS * t));
			}
			sound[t] = A * 1.0/SINES * sum;
		}
		if (t > 30*FS && t < 40*FS) {
			uint16_t A = 16000;
			float fd = 0.1;
			float f[] = { 40-fd, 41-fd, 50-fd, 10000-fd };
			const int SINES = 4;
			float sum = 0;
			int i = 0;
			for (i = 0; i < SINES; i++) {
				sum = sum + 0.5 * (1 + sin(PI * f[i]/FS * t));
			}
			sound[t] = A * 1.0/SINES * sum;
		}
		if (t > 40*FS && t < 45*FS) {
			uint16_t A = 16000;
			float f[] = { 440, 440.2 };
			const int SINES = 2;
			float sum = 0;
			int i = 0;
			for (i = 0; i < SINES; i++) {
				sum = sum + 0.5 * (1 + sin(PI * f[i]/FS * t));
			}
			sound[t] = A * 1.0/SINES * sum;
		}
	}
}

/*
 * Fills the audio buffer (stream of length len) with 
 * meaningful data when asked.
 */
void audio_callback(void* userdata, Uint8* stream, int len)
{
	int16_t *str = (int16_t*)stream;
	int i = 0;
	for (i = 0; i < len/2; i++) {
		str[i] = sound[sound_position++];
	}
}

/*
 * Asks for 44100 mono channel, starts to play.
 * 1024*1000/44100 = ms
 */
void init_snd()
{
	SDL_AudioSpec desired;
	SDL_AudioSpec obtained;
	desired.freq = FS;
	desired.format = AUDIO_S16SYS;
	desired.channels = 1;
	desired.samples = 4096;
	desired.callback = audio_callback;
	desired.userdata = NULL;

	generate_sound();

	SDL_OpenAudio(&desired, &obtained);

	SDL_PauseAudio(0);
}

