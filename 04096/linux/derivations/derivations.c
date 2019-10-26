/*
 * Derivations
 * by zipola
 */

#include <SDL/SDL.h>
#include <stdlib.h>

#include "gfx.h"
#include "seq.h"
#include "snd.h"

/*
 * Initializes graphics, sound and sequencer.
 * Runs the sequencer loop until and quits.
 */
int _start()
{
	SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER);

	srand(1);
	init_gfx();
	//init_seq();
	init_snd();
	sequencer_loop();

	SDL_Quit();

	asm("movl $1,%eax\n"
	"xor %ebx,%ebx\n"
	"int $128\n");
}

