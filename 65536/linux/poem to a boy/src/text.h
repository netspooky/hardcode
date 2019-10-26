#ifndef TEXT_H
#define TEXT_H

#include "poem.h"
#include "font.h"
#include "v.h"

#include <cstring>

class Text {
	Font *font;
	vector pos;
	char *text;

  public:
	
	Text(Font *,const char *);
	
	~Text();

	void draw();
	
	void draw(const int &i);

	void set_pos(const vector &v) {
		memcpy(pos, v, sizeof(vector));
	}

	void move(const float &x, const float &y, const float &z) {
		pos[X] += x;
		pos[Y] += y;
		pos[Z] += z;
	}
	
	void set_aksepos(const int akse, const float &val) {
		pos[akse] = val;
	}

};

#endif
