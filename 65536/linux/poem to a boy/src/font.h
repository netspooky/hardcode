#ifndef FONT_H
#define FONT_H

#include <GL/gl.h>
#include "poem.h"

class Font {
	// hei!
	GLuint* letters;

	unsigned char *Font::bitmap_to_grayscale(unsigned char*, const int &, const int &);

  public:
	Font( unsigned char *fontdata, const int &x, const int &y);

	~Font();

	inline int get_letters(const char &i) {
		return letters[i];
	}
	
};

#endif
