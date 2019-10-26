#ifndef LIGHT_H
#define LIGHT_H

#include "poem.h"

class light {

	float pos[4];
	bool enabled;
	float ambient[4];
	float diffuse[4];

public:
	light();
	
	light(float *pos);

	light(float x, float y, float z);

	inline void set_pos(float *pos) {
		for(int i = 0; i < 3; i++)
			this->pos[i] = pos[i];
	}

	inline void set_pos(float x, float y, float z) {
		pos[X] = x;
		pos[Y] = y;
		pos[Z] = z;
	}

	inline void enable(bool e) {
		enabled = e;
	}

	inline bool is_enabled() {
		return enabled;
	}
	
	inline void set_ambient(float amb[4]) {
		for(int i = 0; i < 4; i++)
			this->ambient[i] = amb[i];
	}

	inline void set_diffuse(float diff[4]) {
		for(int i = 0; i < 4; i++)
			this->diffuse[i] = diff[i];
	}

	void show();
	
};

#endif
