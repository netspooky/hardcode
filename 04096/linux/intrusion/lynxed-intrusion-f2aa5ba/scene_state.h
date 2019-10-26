#ifndef SCENE_STATE_H
#define SCENE_STATE_H

#include "vector.h"

struct scene_state
{
    vector3 position;
    matrix3 orientation;
    float box_scale;
    float box_radius;
    float sphere_radius;
} packed;

#endif

