#ifndef __PROJECT_H
#define __PROJECT_H

extern "C" void project(int (*)[2], const vector*, int, long, long);
extern "C" void projectverts(const vector *verts, const short *v, long (*coords)[2], short num, long zoomx, long zoomy);

#endif
