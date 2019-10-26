#define SAMPLE_RATE 22050
#define MAX_SAMPLES SAMPLE_RATE*2*60*2
#define MAX_PATTERNS 72
#define MAX_INSTRUMENTS 6
#define BPM 160

#define TARGET_BUFFER1			0x00
#define TARGET_BUFFER2			0x01
#define TARGET_BUFFER_MASK		0x01

#define NOTE_PATTERN_TYPE_BIT	0x02

const int 	SAMPLES_PER_PATTERN		= SAMPLE_RATE*4*60/BPM;
const int	SAMPLES_PER_TICK		= SAMPLE_RATE*4*60/(BPM*16);
const float SQRT_12_2				= 1.059463094f;
const float SQRT_12_2_INV			= 1.0f/1.059463094f;

struct Instrument
{
	DWORD	waveDataOffset;  // file offset to raw data
	DWORD	length;  // number of samples in sound
	char	flags; // bit7 : pattern type, bit6: use delay, bit0-3 target buffer	
	BYTE	lastVal; // for percussion last tick, for other instruments last note
	BYTE	volume; // volume
	float	playPos; // last buffer position	
	void*	patterns; // pattern array
	char*	patternSeq;	// pattern index array
};

struct NotePattern
{
	BYTE	tick[16];
};

/////////////////////////////////////////////////////////////
// patterns
/////////////////////////////////////////////////////////////

#pragma data_seg(".mucpat")
// basedrum
WORD BaseDrumPatterns[3] =
{
	0x0000,
	0x0481,
	0x4481
};

// snaredrum
WORD SnareDrumPatterns[2] =
{
	0x0000,
	0x1010
};

// hihat
WORD HihatPatterns[2] =
{
	0x0000,
	0x5555
};

// base
NotePattern BasePatterns[6] =
{
	{   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0 },
	{   0, 129, 129,   0, 129, 129,   0, 129, 129,   0, 129, 129,   0, 129, 129,   0 },	
	{   0, 133, 133,   0, 133, 133,   0, 133, 133,   0, 133, 133,   0, 133, 133,   0 },
	{   0, 133, 133,   0, 133, 133,   0, 133, 133,   0, 133, 133,   0, 136, 136,   0 },	
	{   0, 126, 126,   0, 126, 126,   0, 126, 126,   0, 126, 126,   0, 126, 126,   0 },	
	{   0, 126, 126,   0, 126, 126,   0, 126, 126,   0, 126, 126,   0, 128, 128,   0 },	
};

// synth
NotePattern SynthPatterns[3] =
{
	{  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92,  92 },
	{  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96,  96 },
	{  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89,  89 },
};

// lead
NotePattern LeadPatterns[6] =
{
	{   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0 },
	{ 142,   0, 139,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 137,   0 },
	{ 142,   0, 139,   0,   0,   0,   0, 147,   0,   0,   0,   0,   0,   0, 137,   0 },
	{ 142,   0, 139,   0,   0,   0,   0, 146,   0,   0,   0,   0,   0,   0, 137,   0 },
	{ 142,   0, 139,   0,   0,   0,   0, 142,   0,   0,   0,   0,   0,   0, 137,   0 },
	{ 142,   0, 139,   0,   0,   0,   0, 144,   0,   0,   0,   0,   0,   0, 137,   0 },
};

/////////////////////////////////////////////////////////////
// pattern sequences
/////////////////////////////////////////////////////////////

#pragma data_seg(".mucseq")
char BaseDrumPatternSeq[MAX_PATTERNS] = 
{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2,
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 1, 2, 
	1, 1, 1, 2, 1, 1, 1, 2, 
	0, 0, 0, 0, 0, 0, 0, 0, 
};

char SnareDrumPatternSeq[MAX_PATTERNS] = 
{
	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
};

char HihatPatternSeq[MAX_PATTERNS] = 
{
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 1, 1, 1, 1, 1, 1,	1, 1, 1, 1, 1, 1, 1, 1,
	1, 1, 1, 1, 1, 1, 1, 1, 
	0, 0, 0, 0, 0, 0, 0, 0, 
};

char BasePatternSeq[MAX_PATTERNS] = 
{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 1, 2, 3, 1, 1, 4, 5, 1, 1, 2, 3, 1, 1, 4, 5, 
	1, 1, 2, 3, 1, 1, 4, 5, 
	0, 0, 0, 0, 0, 0, 0, 0, 
};

char SynthPatternSeq[MAX_PATTERNS] = 
{
	0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 
	0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 
	0, 0, 1, 1, 0, 0, 2, 2, 
	0, 0, 1, 1, 0, 0, 2, 2, 0, 0, 1, 1, 0, 0, 2, 2, 
	0, 0, 1, 1, 0, 0, 2, 2, 
	0, 0, 1, 1, 0, 0, 2, 2
};

char LeadPatternSeq[MAX_PATTERNS] = 
{
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 
	2, 2, 3, 3, 4, 4, 5, 5, 2, 2, 3, 3, 4, 4, 5, 5, 
	2, 2, 3, 3, 4, 4, 5, 5, 
	2, 2, 3, 3, 4, 4, 5, 5
};


/////////////////////////////////////////////////////////////
// instruments
/////////////////////////////////////////////////////////////

#pragma data_seg(".mucins")
Instrument IntroInstruments[MAX_INSTRUMENTS] =
{
	// basedrum
	{
		0x26b3d0,
		4930/2,
		TARGET_BUFFER1,
		0xff, 
		0xff, 
		0, 
		BaseDrumPatterns,
		BaseDrumPatternSeq
	},
	// snare
	{
		0x3254be,
		5916/2,
		TARGET_BUFFER1,
		0xff, 
		0x6f, 
		0, 
		SnareDrumPatterns,
		SnareDrumPatternSeq
	},
	// hihat
	{
		0x17fc54,
		2334/2,
		TARGET_BUFFER1,
		0xff, 
		0xff, 
		0, 
		HihatPatterns,
		HihatPatternSeq
	},
	// base
	{
		0x1bf89c,
		14342/2,
		TARGET_BUFFER1 | NOTE_PATTERN_TYPE_BIT,
		0xff, 
		0x5f, 
		0, 
		BasePatterns,
		BasePatternSeq
	},
	// synth
	{
		0x29e30e,
		28776/2,
		TARGET_BUFFER2 | NOTE_PATTERN_TYPE_BIT,
		0xff, 
		0x7f, 
		0, 
		SynthPatterns,
		SynthPatternSeq
	},
	// lead
	{
		0x1b1bf6,
		8720/2,
		TARGET_BUFFER2 | NOTE_PATTERN_TYPE_BIT,
		0xff, 
		0x7f, 
		0, 
		LeadPatterns,
		LeadPatternSeq
	}
};

