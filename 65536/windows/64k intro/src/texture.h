////////////////////////////////////////////////////////////////////////////////
// pngload.cpp
#include <vector>
using namespace std;

//#include "another/glpng.h"
////////////////////////////////////////////////////////////////////////////////
// texture
class cTexture{
public:
	int width, height, depth;
	
	// manage texture
	vector < unsigned int > textureId;
	vector < string > title;
	
	int cnt;
	GLuint txt0, txt1;
	
	cPerlin perlin;
	vector < cColor4f > bgTex;
	vector < cColor4f > laserTex;
	
public:
	cTexture();
	~cTexture();
	void generate(int num);
	
	
	int findId(char* name);
	void load(cColor4f* dt, char* name, int texNum);
	void normalOn(char* name);
	void normalOff(void);
	void environmentOn(char* name);
	void environmentOff(void);
};
