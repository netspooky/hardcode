#include "demo.h"
#include "gl.h"

#include "GL/gl.h"

#include "window.h"
#include "light.h"

#include "font.h"
#include "fontdata.h"

#include "minifmod.h"
#include "module.h"

#include <unistd.h>
#include <cstdlib>

#include <SDL/SDL.h>

#include "scroller.h"
#include "heart.h"

#include <sys/ioctl.h>
#include <linux/soundcard.h> // SNDblablaIOCTL

int demo::time;

FMUSIC_MODULE *demo::module;

light *demo::l;

Font *demo::fnt;

bool demo::done;

//texture *demo::hamstertex;

void demo::init() {
	fnt = new Font(fontdata_8x16, 8, 8);

	scroller_init();
	heart_init();

//	hamstertex = new texture(HAMSTER_DATA, HAMSTER_LEN, true, GL_RGB);
	
	l = new light(0.0, 0.0, 2.0);

	usleep(1000);
	
	time = 0;
	FMUSIC_MODULE *hei = ::fmod_init();
}

void demo::doframe() {

	time = get_time();

	#define END1 5000
	#define END2 6000

	if( time < END1 ) {
		w->setclearcolor(0.9, 0.2, 0.87);
	} else {
		w->setclearcolor(1.0, 1.0, 1.0);
	}

	gl::predraw();

	l->show();

	if( time < END1 ) {
		scroller_draw();
	} else if ( time < END2) {
		heart_draw();
	} else {
		done = true;
	}

	
	gl::draw();
	gl::postdraw();
	
}

void demo::quit() {
	delete w;
	exit(0);
}

void demo::run() {
	done = false;
	Uint8* keys;
	SDL_Event event;

	while(!demo::done) {
		doframe();

		while(SDL_PollEvent(&event)) {
			switch(event.type) {
				case SDL_QUIT:
					done = true;
					break;
			}
		}

		keys = SDL_GetKeyState(NULL);

		if(keys[SDLK_ESCAPE]) done = true;
		if(keys[SDLK_t]) {
			dprint("tid: " << demo::time << std::endl);
		}

	}
	quit();
}

int demo::get_time() {
	unsigned long delay = 0;
	ioctl(::FSOUND_FileDSP, SNDCTL_DSP_GETODELAY, &delay);
	return (int)( ( (float)(::written - delay) / (44100 * 4)) * 100 );
}
