#ifndef SEQUENCES_H
#define SEQUENCES_H

#include "cameras.hpp"
#include "scenes.hpp"

#define SEQUENCES_COUNT 33
#define FRAMERATE 60

extern const unsigned short seq_start_frame[SEQUENCES_COUNT];
extern const GLuint* seq_shader[SEQUENCES_COUNT];
extern const unsigned short seq_start_cam_keyframe[SEQUENCES_COUNT];
extern const unsigned short seq_cam_keyframe_count[SEQUENCES_COUNT];
#endif
