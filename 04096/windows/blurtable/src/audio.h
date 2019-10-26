#ifndef AUDIO_H
#define AUDIO_H


#define PATSET(p, o) (p |= (1<<o))
#define PATISSET(p, o) (p & (1<<o))

typedef struct wavdata {

	unsigned int	riffid;
	int				riffsize;
	unsigned int	waveid;
	unsigned int	chunkid;
	int				chunksize;
	unsigned short	format;
	unsigned short	channels;
	int				samplerate;
	int				bytespersec;
	unsigned short	blockalign;
	unsigned short	bitspersample;
	unsigned int	dataid;
	int				datasize;
	short			data;

} wavdata_t;

void	InitMusic();

#endif
