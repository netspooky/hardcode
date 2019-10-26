#include "TWindow.h"
#include "ScnBlobs.h"
#include "scene_manager.h"
#include "mofas.h"


int main(int argc,char **argv)
{
	ScnBlobs *blobs = new ScnBlobs();
	ScnMng *mng = new ScnMng();
	SDL_Event e;
	TWindow *window = new TWindow();
	window->InitWindow("kk",640,480,16,true);
	while(!SDL_PollEvent (&e) || e.type!=2)
	{
		glClear(GL_DEPTH_BUFFER_BIT|GL_COLOR_BUFFER_BIT);
		mng->nu_scene(blobs,SDL_GetTicks(),12323);
		if (SDL_GetTicks() > 30000)
		{
			SDL_Quit();
			delete blobs;
			delete mng;
			delete window;
			Mofas();
		}
		SDL_GL_SwapBuffers();
	}
	SDL_Quit();
	delete blobs;
	delete mng;
	delete window;
}
