#ifndef __TEXTURE_GENERATOR
#define __TEXTURE_GENERATOR

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <windows.h>

#define PI 3.1415926535897932384626433832795

#define MAX_LAYERS 5
#define TEMPL 5
#define MAX_TEXTURE_SIZE 1024
#define MAX_STUFF 100
#define MAX_PARAM 10
#define DO_NOTHING 0xffff
typedef enum {	R_SUB_PLASMA=0, R_SINE_PLASMA, R_PERLIN_NOISE, R_PARTICLE, R_COLOR, R_CBOARD, R_BLOBS,
					C_ADD=10, C_MUL, C_RAND, C_MIN, C_MAX, C_XOR, C_OR, C_AND,
					COL_SCALE_RGB=20, COL_SCALE_HSV, COL_ADJUST_RGB, COL_ADJUST_HSV, COL_SINE_RGB, COL_EQUALIZE, COL_STRETCH,
					F_INVERT=30, F_EMBOSS, F_WOOD, F_BLUR, F_SHARPEN, F_HEDGE, F_VEDGE, F_MOTION_BLUR, F_MAKE_TILEABLE, F_MEDIAN,
					D_SINE=40, D_TWIRL, D_MAP, D_TILE, D_NOISE, D_MOVE, D_KALEID, D_TUNNEL, D_SCULPTURE,
					F_ERODE=50, F_DILATE};

struct Stuff
{
	long num;
	long nr[MAX_STUFF];
	float param[MAX_STUFF][MAX_PARAM];
};

#ifndef byte
typedef unsigned char byte;
#endif
struct RGBA
{
	byte r;
	byte g;
	byte b;
	byte a;
};

class TextureGenerator
{
public:
	TextureGenerator();
	~TextureGenerator();

	// Managing stuff
	void tex2mem(RGBA **texture, char *name, int sizeX, int sizeY, bool allocMem);
	void tex2mem(RGBA **texture, unsigned char *data, int size, int sizeX, int sizeY, bool allocMem);
	void doOneStuff(long nr, float *param);
	RGBA* getLayer(byte l);

	// Init/Deinit
	void initLayers(int sizeX, int sizeY);	// needn't be called, because is already done when tex2mem is called
	void deInitLayers();


private:
	// Render
	void subPlasma(byte l, long dist, long seed, long amplitude, bool rgb);
	void sinePlasma(byte l, float dx, float dy, float amplitude);
	void perlinNoise(byte l, long dist, long seed, long amplitude, long persistence, long octaves, bool rgb);
	void particle(byte l, float f);
	void colorLayer(byte l, byte r, byte g, byte b);
	void checkerBoardLayer(byte l, long dx, long dy, byte r1, byte g1, byte b1, byte r2, byte g2, byte b2);
	void blobsLayer(byte l, long seed, byte amount, bool rgb);

	// Color
	void scaleLayerRGB(byte src, byte dest, float r, float g, float b);
	void scaleLayerHSV(byte src, byte dest, float h, float s, float v);
	void adjustLayerRGB(byte src, byte dest, float r, float g, float b);
	void adjustLayerHSV(byte src, byte dest, float h, float s, float v);
	void sineLayerRGB(byte src, byte dest, float r, float g, float b);
	void equalizeRGB(byte src, byte dest);
	void stretchRGB(byte src, byte dest);

	// Filter
	void invertLayer(byte src, byte dest);
	void embossLayer(byte src, byte dest);
	void woodLayer(byte src, byte dest, byte b);
	void blurLayer(byte src, byte dest);
	void edgeHLayer(byte src, byte dest);
	void edgeVLayer(byte src, byte dest);
	void sharpenLayer(byte src, byte dest);
	void motionBlur(byte src, byte dest, byte s);
	void makeTileable(byte src, byte dest, long s);
	void medianLayer(byte src, byte dest);
	void erodeLayer(byte src, byte dest);
	void dilateLayer(byte src, byte dest);

	// Distort
	void sineDistort(byte src, byte dest, float dx, float depthX, float dy, float depthY);
	void twirlLayer(byte src, byte dest, float rot, float scale);
	void tileLayer(byte src, byte dest);
	void noiseDistort(byte src, byte dest, long seed, byte radius);
	void moveDistort(byte src, byte dest, int dx, int dy);
	void kaleidLayer(byte src, byte dest, byte corner);
	void tunnelDistort(byte src, byte dest, float f);
	void sculptureLayer(byte src, byte dest);

	// Combine
	void mapDistort(byte src, byte dist, byte dest, float xd, float yd);
	void addLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void mulLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void xorLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void andLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void orLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void randCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void maxCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2);
	void minCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2);

	// Helper
	long myRandom();
	RGBA cosineInterpolate(RGBA *v, float x, float y);
	long mySqrtInt(long n);
	void hsv2rgb(float h, float s, float v, float *r, float *g, float *b);
	void rgb2hsv(float r, float g, float b, float *h, float *s, float *v);
	RGBA getBilerpPixel(byte l, float x, float y);
	void matrixLayer(byte src, byte dest, bool abs, float matrix[3][3]);
	byte median(byte *v);

	Stuff stuffOnLayers[MAX_LAYERS];
	RGBA **layers;
	long layerSizeX, layerSizeY, andLayerSizeX, andLayerSizeY;
	long seedValue;
};

TextureGenerator *getTextureGenerator();

#endif