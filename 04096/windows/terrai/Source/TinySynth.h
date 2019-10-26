#include <mmsystem.h>
#include <stdlib.h>
#include <math.h>

// Global declarations
const float TIME_OFFSET			= 0;
const int SAMPLE_FREQUENCY		= 44100;
const int SAMPLE_FREQUENCY_01	= (int)(0.01*SAMPLE_FREQUENCY);
const int BPM					= 130;
const int TEMPLATE_MELODY_LEN	= 47;
const int ROW_COUNT				= 16 * TEMPLATE_MELODY_LEN;
const int PLAY_TIME				= ROW_COUNT * 60 / ( BPM * 4 );
const int ROW_SIZE_SAMPLES		= SAMPLE_FREQUENCY * 60 / ( BPM * 4 );
const float MASTER_VOLUME		= 0.76f;
const float ROW_LEN_SEC			= 60.0f / ( BPM * 4 );
const float PI					= 3.1415926535f;
const float PI_2				= 2*PI;
HWAVEOUT	g_wo;
int			g_patternNo;
int			g_patternRowNo;
struct Instrument { 
	char note;
	char noteEnd;
	unsigned char noteLen;
	char volume;
	char oscType;
	char noteOffset;
	char attackTime;
	char decayTime;
	char sustainTime;
	char filterCutoff;
	char filterCutoffModulation;
	char filterRes;
	char echoDelay;
	char echoRepeats;
	char echoDamping;
	char wrapLevel;
	char hardLevel;
	char compressorLow;
	char compressorHigh;
};

const Instrument g_instruments[] = { { -1,0,3,5,3,0,1,13,33,77,0,62,0,0,0,0,0,0,0 }
, { -2,0,22,8,2,0,17,52,88,-6,10,6,30,3,70,0,0,0,0 }
, { -3,1,10,44,0,0,1,20,80,0,0,0,0,0,0,0,0,72,105 }
, { -4,0,17,15,2,0,26,42,90,4,0,18,5,1,54,0,0,0,0 }
, { -5,0,23,8,3,0,1,12,34,113,0,93,22,1,10,0,0,0,0 }
, { -7,0,33,2,2,0,42,65,65,14,-12,26,11,10,90,0,0,0,0 }
, { -7,0,62,4,1,0,42,70,70,8,-6,83,22,7,95,0,0,0,0 }
 };
const int INSTRUMENT_COUNT = sizeof(g_instruments) / sizeof(Instrument);

const char g_bytePatterns[][16] = { {1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0},
{40,0,35,0,38,0,36,0,42,0,5,0,40,0,5,0},
{40,0,5,0,36,0,5,0,40,0,5,5,40,0,5,0},
{30,0,0,30,0,0,30,0,0,0,20,0,20,0,20,0},
{4,4,0,0,4,4,4,0,4,4,0,0,4,4,4,0},
{4,4,0,0,4,4,0,0,3,0,3,0,3,0,3,0},
{0,0,1,0,1,0,0,0,1,0,1,0,0,0,0,0},
{0,0,1,0,1,0,0,0,1,0,1,0,0,1,0,0},
{5,6,8,10,11,13,15,16,18,20,21,23,25,26,28,30},
{30,29,27,25,24,22,20,19,17,15,14,12,10,9,7,5},
{40,0,38,0,40,0,42,0,5,0,36,0,38,0,40,0},
{40,0,0,40,0,0,42,0,5,0,36,0,38,0,40,0},
{44,44,44,44,44,44,44,44,0,0,0,0,0,0,0,0},
{45,45,45,45,45,45,45,45,0,0,0,0,0,0,0,0},
{47,47,0,0,47,47,47,47,0,0,0,0,0,0,0,0}};

const char g_byteSequences[][TEMPLATE_MELODY_LEN] = { {4,4,4,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,0,1,1,1,1,1,0,0,0,1,1,1,1,1,1,0,1,1,1,0,0,0},
{0,0,0,0,0,2,2,2,3,2,2,2,3,0,11,11,11,12,11,11,11,12,0,2,2,2,3,2,2,2,3,0,11,11,11,12,11,11,11,12,11,11,11,12,0,0,0},
{0,4,4,4,4,0,0,4,4,4,4,4,4,0,0,0,4,4,4,4,4,4,0,0,0,4,0,4,4,4,4,4,0,4,4,4,4,4,4,4,0,4,4,4,0,4,0},
{0,0,0,0,0,0,0,0,0,5,5,5,6,5,0,0,5,6,5,5,5,6,0,0,0,5,6,5,5,5,6,0,0,0,5,6,5,5,5,6,5,5,5,6,5,6,0},
{0,0,0,7,7,0,0,7,8,7,7,7,8,0,0,0,7,8,7,7,7,8,8,0,0,7,8,7,7,7,8,0,0,0,7,8,7,7,7,8,7,7,7,8,8,0,0},
{0,0,0,0,0,9,9,9,10,9,10,9,10,0,9,10,9,10,9,10,9,10,0,9,9,9,10,9,10,9,10,0,9,10,9,10,9,10,9,10,9,10,9,10,0,0,0},
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,13,14,13,14,13,15,0,0,0,13,14,13,14,13,15,13,14,13,15,0,0,0}};


// Some auxiliary functions
float Sign ( float f ) {
	if ( f > 0.0f )
		return 1.0f;
	return -1.0f;
}
float CutLevel ( float x, float lvl ) {
	if ( x > lvl )
		return lvl;
	if ( x < -lvl )
		return -lvl;
	return x;
}
float buf0LPRes = 0, buf1LPRes = 0;
float LowPassResonantFilter ( float x, float f, float q ) {
	float fb = q + q / ( 1.0f - f );
	buf0LPRes = buf0LPRes + f * ( x - buf0LPRes + fb * ( buf0LPRes - buf1LPRes ) );
	buf1LPRes = buf1LPRes + f * ( buf0LPRes - buf1LPRes );
	return buf1LPRes;
}
float Sawtooth ( float x ) {
	return ( ( x - floor ( x / PI_2 ) * PI_2 ) / PI_2 - 0.5f ) * 2;
}
float Square ( float x ) {
	return Sign ( Sawtooth ( x ) );
}
float NoteToFrequency ( char note  ) {
	return PI_2 * 440.0f * powf ( 2.0f, (note-45)/12.0f );
}
char GetFixedOrStreamValue ( char val ) {
	if ( val >= 0 )
		return val;
	val = -val;
	int k = g_byteSequences[val-1][g_patternNo];
	if ( k )
		return g_bytePatterns[k-1][g_patternRowNo];
	return 0;
}

// Creates large buffer and fills it with samples. Starts playing generated sound.
// Pefroms no error checking and does not dispose resources.
void CreateAndPlaySynth ( ) {
	WAVEFORMATEX wfx = { WAVE_FORMAT_PCM, 1, SAMPLE_FREQUENCY, SAMPLE_FREQUENCY*2, 2, 16, 0 };
	waveOutOpen ( &g_wo, WAVE_MAPPER, &wfx, NULL, 0, CALLBACK_NULL );
	short* finalBuf = new short[(PLAY_TIME+20)*SAMPLE_FREQUENCY]; // We need +20 since some sounds (e.g. echoed) can last for a long time. Hope it's large enough :)
	float* data = new float[(PLAY_TIME+20)*SAMPLE_FREQUENCY];
	ZeroMemory ( data, (PLAY_TIME+20)*SAMPLE_FREQUENCY*sizeof(float) );

	// Loop through all instruments and create sound for each one of them independently
	for ( int i = 0; i < INSTRUMENT_COUNT; i++ ) {
		float *b = data;
		const Instrument* ins = g_instruments + i; 
		int noteLenSamples = ins->noteLen * SAMPLE_FREQUENCY_01;
		int oscType = ins->oscType;
		float attackTime = ins->attackTime * 0.01f;
		float decayTime = ins->decayTime * 0.01f;
		float sustainTime = ins->sustainTime * 0.01f;

		// Loop through all rows for given instrument
		for ( int r = 0; r < ROW_COUNT; r++, b += ROW_SIZE_SAMPLES ) {
			g_patternNo = ( r >> 4 );
			g_patternRowNo = ( r & 0xF );
			char note = GetFixedOrStreamValue ( ins->note );
			if ( !note )
				continue;
			float f = NoteToFrequency ( note );
			float f1 = f;
			if ( ins->noteEnd )
				f1 = NoteToFrequency ( ins->noteEnd );
			float filtF = GetFixedOrStreamValue ( ins->filterCutoff ) * 0.01f;
			float filtQ = ins->filterRes * 0.01f;
			float filtMod = ins->filterCutoffModulation * 0.01f;
			buf0LPRes = buf1LPRes = 0;
			float vol = ins->volume * 0.01f;
			float wrapLevel = ins->wrapLevel * 0.01f;
			float hardLevel = ins->hardLevel * 0.01f;
			float compLow = ins->compressorLow * 0.01f;
			float compHigh = ins->compressorHigh * 0.01f;
			float compDL = compHigh - compLow;
			float *b1 = b;

			// Create one sound sample based on instrument and sequence parameters
			for ( int k = 0; k < noteLenSamples; k++, b1++ ) {
				float t1 = (float) k / noteLenSamples;
				float t = (float) k / SAMPLE_FREQUENCY * ( f + (f1-f)*t1 );
				float y;
				if ( oscType == 0 )
					y = sinf ( t );
				if ( oscType == 1 )
					y = Sawtooth ( t );
				if ( oscType == 2 )
					y = Square ( t );
				if ( oscType == 3 )
					y = (float)rand ( ) / RAND_MAX - 0.5f;
				if ( t1 < attackTime )
					y *= t1 / attackTime;
				else if ( t1 < decayTime )
					y *= 1.0f - 0.3f * ( t1 - attackTime ) / ( decayTime - attackTime );
				else if ( t1 < sustainTime )
					y *= 0.7f;
				else
					y *= 0.7f * ( 1.0f - t1  ) / ( 1.0f - sustainTime );
				if ( filtF )
					y = LowPassResonantFilter ( y, filtF + filtMod * t1, filtQ );
				if ( compHigh ) {
					float v = fabs ( y ) - compLow;
					if ( v > 0.0f ) {
						v = compHigh - compDL / ( 1.0f + 10.0f * v / compDL );
						y = v * Sign ( y );
					}
				}
				*b1 += y * vol;
				if ( ins->echoRepeats ) {
					float c = ins->echoDamping*0.01f;
					for ( int kk = 0; kk < ins->echoRepeats; kk++ ) {
						*(b1+(DWORD)((kk+1)*ins->echoDelay*(0.01f*SAMPLE_FREQUENCY))) += y * vol * c;
						c *= c;
					}
				}
			}
		}
	}

	// Copy just generated sound to audio buffer and play it
	short *s = finalBuf;
	for ( int i = 0; i < PLAY_TIME*SAMPLE_FREQUENCY; i++ )
		*(s++) = (short) ( 32000.0f * (*(data++)) * MASTER_VOLUME );
	WAVEHDR hdr = {0};
	hdr.lpData = (LPSTR) ( finalBuf + (int)(TIME_OFFSET*SAMPLE_FREQUENCY));
	hdr.dwBufferLength  = (PLAY_TIME-TIME_OFFSET)*SAMPLE_FREQUENCY*sizeof(short);
	waveOutPrepareHeader ( g_wo, &hdr, sizeof(hdr) );
	waveOutWrite ( g_wo, &hdr, sizeof(hdr) );
}