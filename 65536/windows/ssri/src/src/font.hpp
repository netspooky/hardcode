#ifndef _FONT_HPP_
#define _FONT_HPP_

#include "stuff.hpp"

//void font_write(float xpos, float ypos, const char *string);
void font_write(float xpos, float ypos, const char *string);
void font_write3d(const char *string);
void font_init();
void font_free();

void debugprint(char *string, int line);




#endif
