#ifndef _SOUND_HPP_
#define _SOUND_HPP_

/*#include "minifmod/minifmod.h"

extern FMUSIC_MODULE *mod;

typedef struct 
{
	int length;
	int pos;
	unsigned char *data;
} MEMFILE;*/

class Sound
{
	public:

		Sound();
		~Sound();

		bool init();
		void play();
		void release();

	private:
};

#endif
