#include <mmsystem.h>
#include <stdlib.h>
#include <math.h>
// Global declarations
const int SAMPLE_FREQUENCY		= 44100;
const int PLAY_TIME				= 32;
const float MASTER_VOLUME		= 0.0003f;
const float PI					= 3.1415926535f;
const float PI_2				= 2*PI;
HWAVEOUT	g_wo = 0;

// Auxiliary functions
float CutLevel ( float x, float lvl ) {
	if ( x > lvl )
		return lvl;
	if ( x < -lvl )
		return -lvl;
	return x;
}
float Sawtooth ( float x ) {
	return ( 0.5f - ( x - floor ( x / PI_2 ) * PI_2 ) / PI_2 );
}
struct Phoneme {
	char p;
	unsigned char f[3];
	unsigned char w[3];
	struct {
		unsigned char len : 2;
		unsigned char amp : 4;
		unsigned char osc : 1;
		unsigned char plosive : 1;
	} Shape;
};
Phoneme g_phonemes[] = {{ 'o',		12, 15, 0,		10, 10, 0,		{ 3, 6, 0, 0 } },
						{ 'i',		5, 56, 0,		10, 10, 0,		{ 3, 3, 0, 0 } },
						{ 'j',		5, 56, 0,		10, 10, 0,		{ 1, 3, 0, 0 } },
						{ 'u',		5, 14, 0,		10, 10, 0,		{ 3, 3, 0, 0 } },
						{ 'a',		18, 30, 0,		10, 10, 0,		{ 3, 15, 0, 0 } },
						{ 'e',		14, 50, 0,		10, 10, 0,		{ 3, 15, 0, 0 } },
						{ 'E',		20, 40, 0,		10, 10, 0,		{ 3, 12, 0, 0 } },
						{ 'w',		3, 14, 0,		10, 10, 0,		{ 3, 1, 0, 0 } },
						{ 'v',		2, 20, 0,		20, 10, 0,		{ 3, 3, 0, 0 } },

						{ 'T',		2, 20, 0,		40, 1, 0,		{ 3, 5, 0, 0 } },
						{ 'z',		5, 28, 80,		10, 5, 10,		{ 3, 3, 0, 0 } },
						{ 'Z',		4, 30, 60,		50, 1, 5,		{ 3, 5, 0, 0 } },
						{ 'b',		4, 0, 0,		10, 0, 0,		{ 1, 2, 0, 0 } },
						{ 'd',		4, 40, 80,		10, 10, 10,		{ 1, 2, 0, 0 } },
						{ 'm',		4, 20, 0,		10, 10, 0,		{ 3, 2, 0, 0 } },
						{ 'n',		4, 40, 0,		10, 10, 0,		{ 3, 2, 0, 0 } },
						{ 'r',		3, 10, 20,		30, 8, 1,		{ 3, 3, 0, 0 } },
						{ 'l',		8, 20, 0,		10, 10, 0,		{ 3, 5, 0, 0 } },
						{ 'g',		2, 10, 26,		15, 5, 2,		{ 2, 1, 0, 0 } },

						{ 'f',		8, 20, 34,		10, 10, 10,		{ 3, 4, 1, 0 } },
						{ 'h',		22, 26, 32,		30, 10, 30,		{ 1, 10, 1, 0 } },
						{ 's',		80, 110, 0,		80, 40, 0,		{ 3, 5, 1, 0 } },
						{ 'S',		20, 30, 0,		100, 100, 0,	{ 3, 10, 1, 0 } },

						{ 'p',		4, 10, 20,		5, 10, 10,		{ 1, 2, 1, 1 } },
						{ 't',		4, 20, 40,		10, 20, 5,		{ 1, 3, 1, 1 } },
						{ 'k',		20, 80, 0,		10, 10, 0,		{ 1, 3, 1, 1 } } };


// Synthesizes speech and adds it to specified buffer
void SynthSpeech ( float* buf, char* text ) {
	// Loop through all phonemes
	for ( char* l = text; *l; l++ ) {
		// Find phoneme description
		Phoneme* p = g_phonemes;
		float v = 0;
		if ( *l != ' ' ) {
			while ( p->p != *l ) {
				p++;
				// DEBUG ONLY !!! Used to catch wrong phonemes.
				/*if ( p - g_phonemes > sizeof(g_phonemes)/sizeof(Phoneme) ) {
					p = 0;
				}*/
			}
			v = p->Shape.amp;
		}
		// Generate sound
		int sl = p->Shape.len * (SAMPLE_FREQUENCY / 15);
		for ( int f = 0; f < 3; f++ ) {
			char ff = p->f[f];
			float freq = (float)ff*(50.0f/SAMPLE_FREQUENCY);
			if ( !ff )
				continue;
			float buf1Res = 0, buf2Res = 0;
			float q = 1.0f - p->w[f] * (PI * 10.0f / SAMPLE_FREQUENCY);
			float *b = buf;
			float xp = 0;
			for ( int s = 0; s < sl; s++ ) {
				float n = (float)rand()/RAND_MAX-0.5f;
				float x = n;
				if ( !p->Shape.osc ) {
					x = Sawtooth ( s * (120.0f * PI_2 / SAMPLE_FREQUENCY) );
					xp = 0;
				}
				// Apply formant filter
				x = x + 2.0f * cosf ( PI_2 * freq ) * buf1Res * q - buf2Res * q * q;
				buf2Res = buf1Res;
				buf1Res = x;
				x = 0.75f * xp + x * v;
				xp = x;
				// Anticlick function
				x *= CutLevel ( sinf ( PI * s / sl ) * 5, 1 );
				*(b++) += x;
				*(b++) += x;
			}
		}
		// Overlap neighbour phonemes
		buf += ((3*sl/4)<<1);
		if ( p->Shape.plosive )
			buf += (sl&0xfffffe);
	}
}



// Synthesizes speech and adds it to specified buffer (a little bit more complex synth)
void SynthSpeechComplex ( float* buf, char* text, char* len, char* amp, bool whisper, float f0 ) {
	// DEBUG ONLY!!! Used to catch string length mismatch.
	/*if ( strlen ( text ) != strlen ( len ) || strlen ( text ) != strlen ( amp ) ) {
		int tl = strlen ( text );
		int ll = strlen ( len );
		int al = strlen ( amp );
		f0 = f0;
	}*/
	// Loop through all phonemes
	for ( char* l = text, *ln = len, *am = amp; *l; l++, ln++, am++ ) {
		// Find phoneme description
		Phoneme* p = g_phonemes;
		float v = 0;
		if ( *l != ' ' ) {
			while ( p->p != *l ) {
				p++;
				// DEBUG ONLY !!! Used to catch wrong phonemes.
				/*if ( p - g_phonemes > sizeof(g_phonemes)/sizeof(Phoneme) ) {
					p = 0;
				}*/
			}
			v = p->Shape.amp;
		}
		// Generate sound
		int sl = (int) ( p->Shape.len * (SAMPLE_FREQUENCY / 15) * (*ln/32.0f) );
		for ( int f = 0; f < 3; f++ ) {
			char ff = p->f[f];
			float freq = (float)ff*(50.0f/SAMPLE_FREQUENCY);
			if ( !ff )
				continue;
			float buf1Res = 0, buf2Res = 0;
			float q = 1.0f - p->w[f] * (PI * 10.0f / SAMPLE_FREQUENCY);
			float *b = buf;
			float xp = 0;
			for ( int s = 0; s < sl; s++ ) {
				float n = (float)rand()/RAND_MAX-0.5f;
				float x = n;
				if ( !p->Shape.osc && !whisper ) {
					x = Sawtooth ( s * (f0 * PI_2 / SAMPLE_FREQUENCY) );
					xp = 0;
				}
				x *= *am/32.0f;
				// Apply formant filter
				x = x + 2.0f * cosf ( PI_2 * freq ) * buf1Res * q - buf2Res * q * q;
				buf2Res = buf1Res;
				buf1Res = x;
				x = 0.75f * xp + x * v;
				xp = x;
				// Anticlick function
				x *= CutLevel ( sinf ( PI * s / sl ) * 5, 1 );
				*(b++) += x;
				*(b++) += x;
			}
		}
		// Overlap neighbour phonemes
		buf += ((3*sl/4)<<1);
		if ( p->Shape.plosive )
			buf += (sl&0xfffffe);
	}
}



// Creates large buffer and fills it with samples. Starts playing generated sound.
// Performs no error checking and does not dispose resources.
WAVEFORMATEX wfx = { WAVE_FORMAT_PCM, 2, SAMPLE_FREQUENCY, SAMPLE_FREQUENCY*4, 4, 16, 0 };
short finalBuf[PLAY_TIME*SAMPLE_FREQUENCY*2] = {0};
float data[PLAY_TIME*SAMPLE_FREQUENCY*2] = {0};
WAVEHDR hdr = {(LPSTR)finalBuf,PLAY_TIME*SAMPLE_FREQUENCY*sizeof(short)*2};
void CreateAndPlaySynth ( ) {
	waveOutOpen ( &g_wo, WAVE_MAPPER, &wfx, NULL, 0, CALLBACK_NULL );
	//SynthSpeech ( data, "o i j u a e E w v T z Z b d m n r l g" );
	//SynthSpeech ( data, "f h s S" );
	//SynthSpeech ( data, "p t k" );

	// Generate speech
	SynthSpeech ( data, "stap  put daun jo wEpn ju hEv twenti sekondz tu komplaj     start distrakSn sikuens" );
	SynthSpeechComplex ( data + 14*SAMPLE_FREQUENCY*2,	
							"welkam  tu saund test", 
							" \x25        \x10          ", 
							" \x30          \x30        ", 
							false, 
							220 );
	SynthSpeechComplex ( data + 20*SAMPLE_FREQUENCY*2,	
							"ridej ij omu ir jviioumeZ", 
							"                         ", 
							"                         ", 
							false, 
							20 );
	SynthSpeechComplex ( data + 26*SAMPLE_FREQUENCY*2,	
							"tis iz E wispE", 
							"22222222222222", 
							"              ", 
							true, 
							0 );

	// Copy just generated sound to audio buffer and play it
	short *s = finalBuf;
	float *dt = data;
	for ( int i = 0; i < 2*PLAY_TIME*SAMPLE_FREQUENCY; i++ )
		*(s++) = (short) ( 32700.0f * CutLevel ( (*(dt++)) * MASTER_VOLUME, 1 ) );
	waveOutPrepareHeader ( g_wo, &hdr, sizeof(hdr) );
	waveOutWrite ( g_wo, &hdr, sizeof(hdr) );
}