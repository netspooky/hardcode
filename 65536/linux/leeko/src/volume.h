/*
    Renders volumes of lego bricks
*/

#ifndef VOLUME_H
#define VOLUME_H

/* The global colors as defines and indices to lclr */
#define YELLOWI 1
#define YELLOW  1.0,1.0,0.0
#define REDI    2
#define RED     1.0,0.1,0.0
#define WHITEI  3
#define WHITE   1.0,1.0,1.0
#define BLUEI   4
#define BLUE    0.05,0.05,0.9
#define GREENI  5
#define GREEN   0.3,0.7,0.2
#define BLACKI  6
#define BLACK   0,0,0

extern GLfloat lclr[][3];

/* Centered (0,1), detail level, data, dimensions */
void draw_volume(int center,int steps,char *blks,int xs,int ys,int zs);

#endif
