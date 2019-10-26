/**
 * My first 4k intro. No music, just pure code. Yes, it's slow.
 *
 * Released @ Pouet.net 2008-02-27
 *
 * @author Timo Wirén aka glaze/biomassa^wAMMA <http://users.utu.fi/tmwire>
 * @version 2008-02-27
 * @licence GNU GPL
 */
#include "structs.h"
#include "common.h"
#include "functions.h"

#ifdef XCOMPILE 
int main(int argc, char* argv[]) {
#else
void _start() {
#endif
	SDL_Event event;
	SDL_Surface* screen;
	Uint32* pixbuf;
	int x, y;
	int frameno = 0;
	Uint32 start;

	screen = SDL_SetVideoMode(WIDTH, HEIGHT, 32, SDL_DOUBLEBUF | SDL_HWSURFACE | SDL_FULLSCREEN);
	pixbuf = (Uint32*)screen->pixels;

	SDL_ShowCursor(0);

	viewing_point.z = -120.0f;

	/* Init rays shot from viewing point */
	for (y = 0; y < HEIGHT; ++y) {
		for (x = 0; x < WIDTH; ++x) {
			ray_directions[y * WIDTH + x].x = x - (WIDTH>>1);
 			ray_directions[y * WIDTH + x].y = y - (HEIGHT>>1);
			ray_directions[y * WIDTH + x].z = 512.0f;

			normalize(&ray_directions[y * WIDTH + x]);
		}
	}

	create_wAMMA();
	create_sphereflake(0, -100, -30, 15, 1, AXEL_F, 0);
	create_room();

	lights[0].z = -120;

	start = SDL_GetTicks();

	while (SDL_GetTicks() - start < 14000 && event.type != SDL_KEYDOWN) {
		lights[0].x = cos((frameno*4) * 3.14159f / 180.0f) * 30.0f;
		lights[0].y = sin((frameno*4) * 3.14159f / 180.0f) * 30.0f;

		/* descend the sphereflake */
		if (frameno < 50) {
			for (x = 0; x < SPHERE_FLAKE_COUNT-2; ++x) {
				sphere_flake[x].position.y += 2;
			}
		}
			
		render_scene(sphere_flake, SPHERE_FLAKE_COUNT, pixbuf);
		SDL_Flip(screen);
		SDL_PollEvent(&event);
		++frameno;
	}

	start = SDL_GetTicks();

	while (SDL_GetTicks() - start < 14000 && event.type != SDL_KEYDOWN) {
		lights[0].y = -10.0f;
		lights[0].x=cos((frameno*2) * 3.14159f / 180.0f)*20.0f;
		lights[0].z=sin((frameno*2) * 3.14159f / 180.0f)*20.0f;
		render_scene(room, ROOM_COUNT, pixbuf);

		SDL_Flip(screen);
		SDL_PollEvent(&event);
		++frameno;
	}

	start = SDL_GetTicks();
	lights[0].z = -120;

	while (SDL_GetTicks() - start < 14000 && event.type != SDL_KEYDOWN) {	
		lights[0].x = cos((frameno<<2) * 3.14159f / 180.0f) * 30.0f;
		lights[0].y = sin((frameno<<2) * 3.14159f / 180.0f) * 30.0f;

		render_scene(wAMMA, WAMMA_COUNT, pixbuf);

		SDL_Flip(screen);
		SDL_PollEvent(&event);
		++frameno;
	}

	SDL_Quit();

#ifdef XCOMPILE
	return 0;
#else
	asm ( \
	"movl $1,%eax\n" \
	"xor %ebx,%ebx\n" \
	"int $128\n" \
	);
#endif
}
