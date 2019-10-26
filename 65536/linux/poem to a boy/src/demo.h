#ifndef DEMO_H
#define DEMO_H

#include "poem.h"

#include "minifmod.h"

#include "light.h"

#include "font.h"

#include "texture.h"

namespace demo {

	void doframe();

	extern long int frame;

	extern FMUSIC_MODULE *module;

	extern int time;

	extern light *l;

	extern Font *fnt;

	void quit();

	void init();

	void run();

	int get_time();

	extern bool done;
}
#endif
