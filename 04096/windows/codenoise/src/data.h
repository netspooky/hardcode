#define NUMSAMPLES 44100*8
#define SAMPLESIZE NUMSAMPLES*2
#define	PLAYFREQ   44100
#define NUMLOOPS   12

// Standard .wav header
typedef struct {
	char			riff_head[4];
	unsigned int	riff_size;
	char			wave_head[4];
	char			fmt_head[4];
	unsigned int	fmt_size;
	unsigned short	format;
	unsigned short	chans;
	unsigned int	samplerate;
	unsigned int	bytespersec;
	unsigned short	bytespersamp;
	unsigned short	bitspersamp;
	char			data_head[4];
	unsigned int	data_size;
	short	int		datawave[NUMSAMPLES*NUMLOOPS];
} PLAYERWAVE;

typedef struct {
	char			riff_head[4];
	unsigned int	riff_size;
	char			wave_head[4];
	char			fmt_head[4];
	unsigned int	fmt_size;
	unsigned short	format;
	unsigned short	chans;
	unsigned int	samplerate;
	unsigned int	bytespersec;
	unsigned short	bytespersamp;
	unsigned short	bitspersamp;
	char			data_head[4];
	unsigned int	data_size;
} PLAYHEADER;
