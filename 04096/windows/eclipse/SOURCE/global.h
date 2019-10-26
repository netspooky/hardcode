// Globals
#define PI		  3.1415926535897932384626433832795f
#define MAX_SHORT 32767

// Visuals
#define BLUR_NICE	1
#define BLUR_DISCO	2
#define BLUR_NEW	4

#define SCREEN_X 1024
#define SCREEN_Y 768

#define PERSPECTIVE true
#define ORTHOGONAL	false

unsigned int BlurTexture;

struct vec
{
		float x; 
		float y;
		float z;
};

// Interaction

bool end = false;

float	clearcolor;
float	clearalpha;

bool color;

bool onChange = false;
bool bass	  = true;

int SongTime = 0;
int SongPos  = 0;
int SeqPos   = 0;

float runtime = 0;
float cam	  = 0;

float alfa;

// Sound
WAVEHDR	 waveHdr;
HWAVEOUT waveOutHandle;

enum
{
	SONGLENGTH = 28,	// Number of Patterns which will be played
	PATTERNLENGTH = 32,	// Length of a Pattern
	CHANNELS = 3,		// Number of Channels used (could be seen as Instruments)
	PATTERNS = 5,		// Number of Different Patterns

	TEMPO = 3800		// Playing Speed
};

#define MIXRATE		44100
#define BUFFERSIZE	4096
#define BUFFERS		3

short SampleBuffer[BUFFERSIZE * 2 * BUFFERS * 2];

enum
{ x = 0 }; // Empty Sample

char Patterns[PATTERNS][PATTERNLENGTH] = 
{
// #1
{    x,   x,   x,   x,
	26,   x,  26,   x,
	36,   x,   x,   x,
	26,   x,  36,  36,
	 x,   x,  26,   x,
	36,   x,   x,   x,
	 x,   x,   x,   x,
	26,   x,  26,  26,	},

	// #2 && #3 together seem better
{   38,   x,   x,   x,
	44,   x,   x,   x,
	38,   x,   x,   x,
	38,   x,  50,  44,
	38,   x,   x,   x,
	50,   x,   x,   x,
	38,   x,   x,   x,
	44,   x,  50,   x,	},

	 // #3
{   38,   x,   x,   x,
	 x,   x,   x,   x,
	 x,   x,   x,   x,
	44,   x,   x,   x,
	50,   x,   x,   x,
	 x,   x,   x,   x,
	44,   x,   x,   x,
	 x,   x,   x,   x,	},

	 // #4
{   80,   x,  80,   x,
	 x,   x,   x,   x,
	 x,   x,   x,   x,
	 x,   x,   x,   x,
	80,   x,  80,   x,
	 x,   x,   x,   x,
	 x,   x,   x,   x,
	 x,   x,   x,   x,	},

	// #5 Init for #3
{    x,   x,   x,   x,
	 x,   x,   x,   x,
	38,   x,   x,   x,
	 x,   x,  50,   x,
	38,   x,   x,   x,
	 x,   x,   x,   x,
	38,   x,   x,   x,
	44,   x,  50,   x,	},

};

char Sequence[CHANNELS][SONGLENGTH] =
{
	{ x,x,x,3,3,3,x,1,1,2,3,2,3,1,1,1,3,3,2,3,2,3,x,x,x,x,x,x },
	{ 3,3,1,4,1,1,x,1,1,1,1,1,1,3,1,3,4,1,4,1,4,1,1,2,2,x,x,x },
	{ x,5,3,2,3,2,3,2,3,2,3,2,3,2,3,3,3,2,3,2,3,2,2,3,2,3,2,x },
};

struct Channel
{
	int Volume;
	int InTime; // The Time it switches between In/Out FX
	
	float ModIn;  // Liniar
	float ModOut; // Liniar

	float VolumeOut;

	float FX1_ModA; // FX0_A - (xx) / FX0_B);
	float FX1_ModB; // FX0_A - (xx) / FX0_B);

	int	  SampleTime;
	float Frequency;
	float SampleVol;
	bool  RapidDown;
};

Channel Channels[CHANNELS] =
{
	{ // Laserbeam / Beat
		20000,
		1000,

		-0.006f,
		+0.003f,

		-1.25f,

		0.75f,
		2.4f,

		100000, 100000

	},
	{ // Laserbeam / Beat
		20000,
		1000,

		-0.006f,
		+0.003f,

		-1.25f,

		0.75f,
		2.4f,

		100000, 100000
	},
	{ // Melody
		20000,
		1000,

		0.0f,
		0.0f,

		-0.75f,


		1.75f,
		32.0f,

		100000, 100000
	}
};

// Misc

inline LRESULT CALLBACK WndProc(HWND	hWnd,
								UINT	uMsg,
								WPARAM	wParam,
								LPARAM	lParam)
{
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}

  extern "C" int _fltused;
  int _fltused;

  extern "C" { 
    __declspec(naked) void _ftol() {
        __asm    {
            fistp    DWORD PTR [esp-12]
            mov		 eax, DWORD PTR [esp-12]
            mov		 ecx, DWORD PTR [esp-8]

            ret
        }
    }
}
  
float sin(float v)
{
 __asm fld v;
 __asm fsin;
 __asm fstp v;
 return v;
}

float cos(float v)
{
 __asm fld v;
 __asm fcos;
 __asm fstp v;
 return v;
}

inline float sqrt(float v)
{
 __asm finit;
 __asm fld v;
 __asm fsqrt;
 __asm fstp v;
 return v;
}

inline float pow2(float X)
{
	float ret = X;

	for(int i = 0; i < 1; i++)
	{
		ret *= X;
	}

	return ret;
}

inline float abs(float X)
{
	if(X < 0.0f)
		return -X;

	return X;
}