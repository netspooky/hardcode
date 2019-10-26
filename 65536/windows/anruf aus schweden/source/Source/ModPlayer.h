
#ifndef __MODPLAYER_H__
#define __MODPLAYER_H__

#include "fmod/minifmod.h"

class ModPlayer {
	public:
		ModPlayer();
		~ModPlayer();

		void				play();
		void				stop();

	private:
		FMUSIC_MODULE		*mod;
};

#endif