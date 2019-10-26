#include "scene_manager.h"

void ScnMng::nu_scene(TScene *scene,long time,long finish_time)
{
	scene->run(time);
}
