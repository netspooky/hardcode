/*
 * Derivations
 * by zipola
 * Sequencing functions.
 */

#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>

#include "gfx.h"
#include "seq.h"

struct Event events[EVENTS] =
{
	{1000, 10000, intro},
	{10000, 20000, boids},
	{20000, 30000, greets},
	{30000, 40000, boids2},
};

/*void init_seq()
{
	// Init effect specific things
}*/

/*
 * Goes through the events and plays the relevant ones.
 */
int sequence(int t)
{
	glClearColor(1, 1, 1, 1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// Loop through the events and do them as necessary
	int i = 0;
	for (i = 0; i < EVENTS; i++) {
		if (t > events[i].start && t < events[i].stop) {
			events[i].effect(t);
		}
	}

	SDL_GL_SwapBuffers();

	// End if the demo length is passed.
	if (LENGTH <= t) return 1;
	return 0;
}

/*
 * Main loop which calls sequence until it returns 1.
 * Runs at TICK frames per second.
 * If some key is pressed, the loop is exited.
 */
void sequencer_loop()
{
	int end = 0;
	Uint32 start_time = SDL_GetTicks();
	Uint32 next_time = start_time + TICK;
	SDL_Event e;

	while (!end) {
		Uint32 to_next = 0;
		Uint32 time = SDL_GetTicks();

		if (time < next_time)
			to_next = next_time - time;

		end = sequence(time);
		SDL_Delay(to_next);
		next_time += TICK;

		if (SDL_PollEvent(&e) && e.type == SDL_KEYDOWN)
			end = 1;
	}
}

