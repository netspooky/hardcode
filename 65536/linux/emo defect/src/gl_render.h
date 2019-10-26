
#ifndef GL_RENDER_H
#define GL_RENDER_H

#define RENDER_NORMAL 1
#define RENDER_CARTOON 2
#define RENDER_WIRE 4
#define RENDER_NOLIGHTS 4096 // Don't use GL materials / lights

#include "wavefront.h"

void render_scene(SCENE *s,int type);
void render_object(SCENE *s,OBJ *o,int type);

#endif
