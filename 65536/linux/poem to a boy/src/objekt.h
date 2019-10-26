#ifndef OBJEKT_H
#define OBJEKT_H

#include "fyll.h"
#include "m.h"
#include "v.h"

#include <cstring>

vertex *gen_hamster();

class Objekt {
  // Associations
  // Attributes
  private:
	vertex* vertices;
	vector* vertexnormals;
	vector* facenormals;
	vector*** faces;
	vector pos;
	matrix rot;
	int vcount;
	int fcount;

  // Operations
  public:
	Objekt (const vertex* vertexdata, const int vertices );
	~Objekt();
	void setpos ( const vector &nypos ) {
		memcpy(pos, nypos, sizeof(vector));
	}
	const vector &getpos (  ) {
		return pos;
	}
	void draw (  );
	void move (const vector &incpos );
	void move ( float, float, float);
	void rotate ( float degrees, float, float, float);
};

#endif
