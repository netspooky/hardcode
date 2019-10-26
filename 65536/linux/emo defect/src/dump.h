
#ifndef DUMP_H
#define DUMP_H

#include "wavefront.h"

int dump_scene(SCENE *s,char *name);
int load_dump(SCENE *s,char *name);
int get_dump(SCENE *s,unsigned char *data);

#endif
