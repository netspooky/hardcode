#include "everything.h"
//#include "another/glpng.h"

////////////////////////////////////////////////////////////////////////////////
// texture class
cTexture::cTexture()
{
	cnt=0;
}

cTexture::~cTexture()
{
}



void
cTexture::generate(int num)
{
	width=256;
	height=256;
	depth=256;
	bgTex.resize(width*height);
	
	// for sphere background
	{
/*	int x, y;
	float tw, th;
	float stp[2];
	float r=1.0;
	tw=1.0/(float)(width);
	th=1.0/(float)(height);
	stp[0]=360/(float)(width-1);
	stp[1]=180/(float)(height-1);
	for(y=0; y<width; y++){
		for(x=0; x<height; x++){
			// compute sphere vertices
			double tmpx = sin(stp[1]*y*PI)*r*sin(stp[0]*x*PI);
			double tmpy = cos(stp[1]*y*PI)*r;
			double tmpz = sin(stp[1]*y*PI)*r*cos(stp[0]*x*PI);
			
			double val=perlin.PerlinNoise3D(tmpx, tmpy, tmpz, 1.8, 2.0, 10);
			
			bgTex[x*width+y].r = 0.5+float(val);
			bgTex[x*width+y].g = 0.5+float(val);
			bgTex[x*width+y].b = 0.5+float(val);
			bgTex[x*width+y].a = 0.5+float(val);
		}
	}
*/	

	int x, y;
	for(y=0; y<height; y++){
		for(x=0; x<width; x++){
			double val=perlin.PerlinNoise2D(double(x)/double(width), double(y)/double(height), 1.3, 1.7, 30);
			float tmp=0.5 + float(val*0.5);
			bgTex[x*width+y] = cColor4f(tmp, tmp, tmp, tmp);
		}
	}
	glGenTextures(1, &txt0);
	glBindTexture(GL_TEXTURE_2D, txt0);
	load(bgTex.begin(), "bgImg", txt0);
	}
	
	// for laser
	{
	laserTex.resize(width*height);
	int x, y;
	float inc=1/float(height*0.5)*1.4;
	for(y=0; y<int(height*0.5); y++){
		for(x=0; x<width; x++){
			float val=inc*float(y);
			laserTex[y*width+x] = cColor4f(val, val, val, val);
			laserTex[(height*width)-(y*width+x)-1] = cColor4f(val, val, val, val);
		}
	}
	glGenTextures(1, &txt1);
	glBindTexture(GL_TEXTURE_2D, txt1);
	load(laserTex.begin(), "laser", txt1);
	}
}

int
cTexture::findId(char* name)
{
	int i, stock, res;
	stock=title.size();
	if(stock>0){
		for(i=0; i<textureId.size(); i++){
			res=title[i].compare(name);
			if(!res){
				return i;
			}
		}
	}
	return -1;
}

// texture data load to memory.
void
cTexture::load(cColor4f* dt, char* name, int texNum)
{
	title.push_back(name);

//	unsigned int target;
//	pngInfo info;
//	target = pngBind(filePath, PNG_NOMIPMAPS, PNG_ALPHA, &info, GL_CLAMP, GL_NEAREST, GL_NEAREST);
	textureId.push_back(texNum);
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_FLOAT, &(dt[0].r));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
}

void
cTexture::normalOn(char* name)
{
	int id=findId(name);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, textureId[id]);
}

void
cTexture::normalOff(void)
{
	glDisable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, 0);
}

void
cTexture::environmentOn(char* name)
{
	int id=findId(name);
	glEnable(GL_TEXTURE_2D);
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	glEnable(GL_TEXTURE_GEN_S);
	glEnable(GL_TEXTURE_GEN_T);
	glBindTexture(GL_TEXTURE_2D, textureId[id]);
}

void
cTexture::environmentOff(void)
{
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_TEXTURE_GEN_S);
	glDisable(GL_TEXTURE_GEN_T);
}

