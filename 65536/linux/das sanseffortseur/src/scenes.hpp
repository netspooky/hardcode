#ifndef SCENES_H
#define SCENES_H

#include "frameworks.hpp"
#include <GL/gl.h>

#define SCENES_COUNT 9

extern const char* const scenes_src[SCENES_COUNT];
extern const char* const scenes_framework_src[SCENES_COUNT];
extern GLuint* const scenes_programs[SCENES_COUNT];
extern const char* const fs_64kb;
extern GLuint fs_64kb_program;
extern const char* const fs_braincontrol;
extern GLuint fs_braincontrol_program;
extern const char* const fs_julien;
extern GLuint fs_julien_program;
extern const char* const fs_notes_velocity;
extern GLuint fs_notes_velocity_program;
extern const char* const fs_pierre;
extern GLuint fs_pierre_program;
extern const char* const fs_presents;
extern GLuint fs_presents_program;
extern const char* const fs_pyramid_exterior;
extern GLuint fs_pyramid_exterior_program;
extern const char* const fs_pyramid_interior;
extern GLuint fs_pyramid_interior_program;
extern const char* const fs_title;
extern GLuint fs_title_program;
#endif
