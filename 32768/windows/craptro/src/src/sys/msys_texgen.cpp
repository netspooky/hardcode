//****************************************************************
// Texture Generator
// Based on the Texture Generator by Toxic Avenger/Apocalypse Inc
// (c)2002+2003 Hopper/SquoQuo
// Caution: This is a quick hack, some functions are still not
// implemented!!!
// Get the Texture Editor at http://ainc.de and go mad!
//****************************************************************

#include "msys_texgen.h"

#define iterY for (int y=0; y<layerSizeY; y++)
#define iterX for (int x=0; x<layerSizeX; x++)
#define copyTemp memcpy(layers[TEMPL], layers[src], layerSizeX*layerSizeY*sizeof(RGBA))

TextureGenerator *textureGenerator=NULL;


TextureGenerator *getTextureGenerator()
{
	if (textureGenerator==NULL)
		textureGenerator=new TextureGenerator();

	return textureGenerator;
}


void errorExit(char *s)
{
	printf("%s\n", s);
	exit(-1);
}


TextureGenerator::TextureGenerator()
{
	layerSizeX=layerSizeY=-1;
}


TextureGenerator::~TextureGenerator()
{
	if (textureGenerator!=NULL)
		delete textureGenerator;
	textureGenerator=NULL;
	deInitLayers();
}

void TextureGenerator::tex2mem(RGBA **texture, unsigned char *data, int size, int sizeX, int sizeY, bool allocMem)
{
	long v;
	if (allocMem)
		*texture=(RGBA*)calloc(sizeX*sizeY, sizeof(RGBA));

	if ((sizeX!=layerSizeX)||(sizeY!=layerSizeY))
	{
		deInitLayers();
		initLayers(sizeX, sizeY);
	} else {
		for (v=0; v<MAX_LAYERS+1; v++)		// clear all the layer buffers!!!
			memset(layers[v], 0, sizeX*sizeY*sizeof(RGBA));
	}

	memcpy(stuffOnLayers,data,sizeof(Stuff)*5);

	for (v=0; v<MAX_LAYERS; v++)
		if (stuffOnLayers[v].num>0)
			for (int x=0; x<stuffOnLayers[v].num; x++)
				doOneStuff(stuffOnLayers[v].nr[x], stuffOnLayers[v].param[x]);

	memcpy(*texture, layers[MAX_LAYERS-1], sizeX*sizeY*sizeof(RGBA));
	for (v=0; v<sizeX*sizeY; v++)
		(*texture)[v].a=255;
}

void TextureGenerator::tex2mem(RGBA **texture, char *name, int sizeX, int sizeY, bool allocMem)
{
	long v;
	if (allocMem)
		*texture=(RGBA*)calloc(sizeX*sizeY, sizeof(RGBA));

	if ((sizeX!=layerSizeX)||(sizeY!=layerSizeY))
	{
		deInitLayers();
		initLayers(sizeX, sizeY);
	} else {
		for (v=0; v<MAX_LAYERS+1; v++)		// clear all the layer buffers!!!
			memset(layers[v], 0, sizeX*sizeY*sizeof(RGBA));
	}

	FILE *in;
	if ((in=fopen(name, "r"))!=NULL)
	{
		fread(stuffOnLayers, sizeof(Stuff), MAX_LAYERS, in);
		fclose(in);
	} else
		errorExit("Tex file not found");

	for (v=0; v<MAX_LAYERS; v++)
		if (stuffOnLayers[v].num>0)
			for (int x=0; x<stuffOnLayers[v].num; x++)
				doOneStuff(stuffOnLayers[v].nr[x], stuffOnLayers[v].param[x]);

	memcpy(*texture, layers[MAX_LAYERS-1], sizeX*sizeY*sizeof(RGBA));
	for (v=0; v<sizeX*sizeY; v++)
		(*texture)[v].a=255;
}


void TextureGenerator::doOneStuff(long nr, float *param)
{
	switch(nr)
	{
		case R_SUB_PLASMA:	subPlasma((byte)param[0], (long)param[1], (long)param[2], (long)param[3], param[4]>=1.f); break;
		case R_SINE_PLASMA:	sinePlasma((byte)param[0], param[1], param[2], param[3]); break;
		case R_PERLIN_NOISE:	perlinNoise((byte)param[0], (long)param[1], (long)param[2], (long)param[3], (long)param[4], (long)param[5], param[6]>=1.f); break;
		case R_PARTICLE:		particle((byte)param[0], param[1]); break;
		case R_COLOR:			colorLayer((byte)param[0], (byte)param[1], (byte)param[2], (byte)param[3]); break;
		case R_CBOARD:			checkerBoardLayer((byte)param[0], (long)param[1], (long)param[2], (byte)param[3], (byte)param[4], (byte)param[5], (byte)param[6], (byte)param[7], (byte)param[8]); break;
		case R_BLOBS:			blobsLayer((byte)param[0], (long)param[1], (byte)param[2], param[3]>=1.f); break;

		case C_ADD:				addLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_MUL:				mulLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_RAND:			randCombineLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_MAX:				maxCombineLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_MIN:				minCombineLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_XOR:				xorLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_OR:				orLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case C_AND:				andLayers((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;

		case COL_SCALE_RGB:	scaleLayerRGB((byte)param[0], (byte)param[1], param[2], param[3], param[4]); break;
		case COL_SCALE_HSV:	scaleLayerHSV((byte)param[0], (byte)param[1], param[2], param[3], param[4]); break;
		case COL_ADJUST_RGB:	adjustLayerRGB((byte)param[0], (byte)param[1], param[2], param[3], param[4]); break;
		case COL_ADJUST_HSV:	adjustLayerHSV((byte)param[0], (byte)param[1], param[2], param[3], param[4]); break;
		case COL_SINE_RGB:	sineLayerRGB((byte)param[0], (byte)param[1], param[2], param[3], param[4]); break;
		case COL_EQUALIZE:	equalizeRGB((byte)param[0], (byte)param[1]); break;
		case COL_STRETCH:		stretchRGB((byte)param[0], (byte)param[1]); break;

		case F_INVERT:			invertLayer((byte)param[0], (byte)param[1]); break;
		case F_EMBOSS:			embossLayer((byte)param[0], (byte)param[1]); break;
		case F_WOOD:			woodLayer((byte)param[0], (byte)param[1], (byte)param[2]); break;
		case F_BLUR:			blurLayer((byte)param[0], (byte)param[1]); break;
		case F_SHARPEN:		sharpenLayer((byte)param[0], (byte)param[1]); break;
		case F_HEDGE:			edgeHLayer((byte)param[0], (byte)param[1]); break;
		case F_VEDGE:			edgeVLayer((byte)param[0], (byte)param[1]); break;
		case F_MOTION_BLUR:	motionBlur((byte)param[0], (byte)param[1], (byte)param[2]); break;
		case F_MAKE_TILEABLE:makeTileable((byte)param[0], (byte)param[1], (long)param[2]); break;
		case F_MEDIAN:			medianLayer((byte)param[0], (byte)param[1]); break;
		case F_DILATE:			dilateLayer((byte)param[0], (byte)param[1]); break;
		case F_ERODE:			erodeLayer((byte)param[0], (byte)param[1]); break;

		case D_SINE:			sineDistort((byte)param[0], (byte)param[1], param[2], param[3], param[4], param[5]); break;
		case D_TWIRL:			twirlLayer((byte)param[0], (byte)param[1], param[2], param[3]); break;
		case D_MAP:				mapDistort((byte)param[0], (byte)param[1], (byte)param[2], param[3], param[4]); break;
		case D_TILE:			tileLayer((byte)param[0], (byte)param[1]); break;
		case D_NOISE:			noiseDistort((byte)param[0], (byte)param[1], (long)param[2], (byte)param[3]); break;
		case D_MOVE:			moveDistort((byte)param[0], (byte)param[1], (int)param[2], (int)param[3]); break;
		case D_KALEID:			kaleidLayer((byte)param[0], (byte)param[1], (byte)param[2]); break;
		case D_TUNNEL:			tunnelDistort((byte)param[0], (byte)param[1], param[2]); break;
		case D_SCULPTURE:		sculptureLayer((byte)param[0], (byte)param[1]); break;
	}
}


void TextureGenerator::initLayers(int sizeX, int sizeY)
{
	// already initialized
	if ((layerSizeX>0)&&(layerSizeY>0))
		return;

	layers=(RGBA**)calloc(MAX_LAYERS+1, sizeof(RGBA*));
	for (byte i=0; i<MAX_LAYERS+1; i++)
		layers[i]=(RGBA*)calloc(sizeX*sizeY, sizeof(RGBA));
	memset(stuffOnLayers, 0, MAX_LAYERS*sizeof(Stuff));
	layerSizeX=sizeX;
	layerSizeY=sizeY;
	andLayerSizeX=sizeX-1;
	andLayerSizeY=sizeY-1;
}


void TextureGenerator::deInitLayers()
{
	// not initialized, so nothing to deinit
	if ((layerSizeX<0)||(layerSizeY<0))
		return;

	if (layers!=NULL)
	{
		for (byte i=0; i<MAX_LAYERS+1; i++)
			free(layers[i]);
		free(layers);
	}
}


RGBA* TextureGenerator::getLayer(byte l)
{
	return layers[l];
}


long TextureGenerator::myRandom()
{
	seedValue*=0x15a4e35;
	return seedValue>>16;
}


RGBA TextureGenerator::cosineInterpolate(RGBA *v, float x, float y)
{
	float f1, f2, mf1, mf2, g0, g1, g2, g3;
	RGBA color;
	mf1=(1.f-(float)cos(x*PI))*0.5f;
	mf2=(1.f-(float)cos(y*PI))*0.5f;
	f1=1.f-mf1;
	f2=1.f-mf2;
	g0=f1*f2;
	g1=mf1*f2;
	g2=f1*mf2;
	g3=mf1*mf2;

	color.r=(byte)(v[0].r*g0+v[1].r*g1+v[2].r*g2+v[3].r*g3);
	color.g=(byte)(v[0].g*g0+v[1].g*g1+v[2].g*g2+v[3].g*g3);
	color.b=(byte)(v[0].b*g0+v[1].b*g1+v[2].b*g2+v[3].b*g3);

	return color;
}


long TextureGenerator::mySqrtInt(long n)
{
	long root, tryr;

	if (n>=65025)		// 255*255
		return 255;

	root=0;
	for (char i=15; i>=0; i--)
	{
		tryr=root+(1<<i);
		if (n>(tryr<<i))
		{
			n-=tryr<<i;
			root=root|(2<<i);
		}
	}
	return root>>1;
}


void TextureGenerator::hsv2rgb(float h, float s, float v, float *r, float *g, float *b)
{
	float f, p, q, t;
	byte i;

	while (h<0.f) h+=360.f;
	while (h>=360.f) h-=360.f;

	if (s==0.f)
		*r=*g=*b=v;
	else {
		h/=60.f;
		i=(byte)h;
		f=(float)fmodf(h, 1.);
		p=v*(1.f-s);
		q=v*(1.f-(s*f));
		t=v*(1.f-(s*(1.f-f)));
		switch(i)
		{
			case 0:	*r=v; *g=t; *b=p; break;
			case 1:	*r=q; *g=v; *b=p; break;
			case 2:	*r=p; *g=v; *b=t; break;
			case 3:	*r=p; *g=q; *b=v; break;
			case 4:	*r=t; *g=p; *b=v; break;
			case 5:	*r=v; *g=p; *b=q; break;
		}
	}
}


void TextureGenerator::rgb2hsv(float r, float g, float b, float *h, float *s, float *v)
{
	float maxR, maxG, maxB, delta;
	float mx=max(r, max(g, b));
	float mn=min(r, min(g, b));

	*v=mx;
	*s=0.f;

	if (mx!=0.f)
		*s=(mx-mn)/mx;
	if (*s==0.f)
		*h=-1.f;
	else {
		delta=mx-mn;
		maxR=mx-r;
		maxG=mx-g;
		maxB=mx-b;
		if (r==mx)
			*h=(maxB-maxG)/delta;
		else
			if (g==mx)
				*h=2.f+(maxR-maxB)/delta;
			else
				*h=4.f+(maxG-maxR)/delta;
		*h*=60.f;
		while (*h<0.f) *h+=360.f;
		while (*h>=360.f) *h-=360.f;
	}
}


RGBA TextureGenerator::getBilerpPixel(byte l, float x, float y)
{
	RGBA corner[4];
	long xi, yi, xip, xip1;
	long yip, yip1;

	xi=(long)x;
	yi=(long)y;
	xip=xi&andLayerSizeX;
	xip1=(xi+1)&andLayerSizeX;
	yip1=((yi+1)&andLayerSizeY)*layerSizeX;
	yip=(yi&andLayerSizeY)*layerSizeX;

	corner[0]=layers[l][xip+yip];
	corner[1]=layers[l][xip1+yip];
	corner[2]=layers[l][xip+yip1];
	corner[3]=layers[l][xip1+yip1];

	return cosineInterpolate(corner, (float)fmodf(x, 1.), (float)fmodf(y, 1.));
}


void TextureGenerator::subPlasma(byte l, long dist, long seed, long amplitude, bool rgb)
{
	int x, y;
	long offset, offset2;
	RGBA corner[4];
	float oodist;

	if (seed!=0)
		seedValue=seed;

	for (y=0; y<layerSizeY; y+=dist)
		for (x=0; x<layerSizeX; x+=dist)
		{
			offset=y*layerSizeX+x;
			layers[l][offset].r=layers[l][offset].g=layers[l][offset].b=myRandom()&(amplitude-1);
			if (rgb)
			{
				layers[l][offset].g=myRandom()&(amplitude-1);
				layers[l][offset].b=myRandom()&(amplitude-1);
			}
		}

	if (dist<1)
		return;

	oodist=1.f/dist;

	for (y=0; y<layerSizeY; y+=dist)
	{
		offset=y*layerSizeX;
		offset2=((y+dist)&andLayerSizeY)*layerSizeX;
		for (x=0; x<layerSizeX; x+=dist)
		{
			corner[0]=layers[l][x+offset];
			corner[1]=layers[l][((x+dist)&andLayerSizeX)+offset];
			corner[2]=layers[l][x+offset2];
			corner[3]=layers[l][((x+dist)&andLayerSizeX)+offset2];
			for (int b=0; b<dist; b++)
				for (int a=0; a<dist; a++)
					layers[l][x+a+(y+b)*layerSizeX]=cosineInterpolate(corner, oodist*a, oodist*b);
		}
	}
}


void TextureGenerator::sinePlasma(byte l, float dx, float dy, float amplitude)
{
	amplitude/=256.f;
	iterY
		iterX
			layers[l][x+y*layerSizeX].r=layers[l][x+y*layerSizeX].g=layers[l][x+y*layerSizeX].b=(byte)((63.5f*sin(dx*(float)x)+127.f+63.5f*sin(dy*(float)y))*amplitude);
}


void TextureGenerator::perlinNoise(byte l, long dist, long seed, long amplitude, long persistence, long octaves, bool rgb)
{
	int r;

	subPlasma(l, dist, seed, 1, rgb);
	for (int i=0; i<octaves-2; i++)
	{
		amplitude=(amplitude*persistence)>>8;
		if (amplitude<=0) break;
		dist=dist>>1;
		if (dist<=0) break;
		subPlasma(TEMPL, dist, 0, amplitude, rgb);
		for (long v=0; v<layerSizeX*layerSizeY; v++)
		{
			r=layers[l][v].r+layers[TEMPL][v].r;
			if (r>255)
				layers[l][v].r=255;
			else
				layers[l][v].r=r;
			r=layers[l][v].g+layers[TEMPL][v].g;
			if (r>255)
				layers[l][v].g=255;
			else
				layers[l][v].g=r;
			r=layers[l][v].b+layers[TEMPL][v].b;
			if (r>255)
				layers[l][v].b=255;
			else
				layers[l][v].b=r;
		}
	}
}


void TextureGenerator::particle(byte l, float f)
{
	float r, nx, ny;
	long offset;
	f*=180.f;
	iterY
	{
		ny=(float)y/(float)(layerSizeY>>1)-1.f;
		iterX
		{
			offset=y*layerSizeX+x;
			nx=(float)x/(float)(layerSizeX>>1)-1.f;
			r=255.f-f*(float)sqrt(nx*nx+ny*ny);
			if (r<0.f) r=0.f;
			if (r>255.f) r=255.f;
			layers[l][offset].r=layers[l][offset].g=layers[l][offset].b=(byte)r;
		}
	}
}


void TextureGenerator::colorLayer(byte l, byte r, byte g, byte b)
{
	RGBA color;
	color.r=r; color.g=g; color.b=b;
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		layers[l][v]=color;
}


void TextureGenerator::checkerBoardLayer(byte l, long dx, long dy, byte r1, byte g1, byte b1, byte r2, byte g2, byte b2)
{
	RGBA col1, col2;
	col1.r=r1; col1.g=g1; col1.b=b1;
	col2.r=r2; col2.g=g2; col2.b=b2;
	iterY
		iterX
			if (((y/dy)&1)^((x/dx)&1))
				layers[l][y*layerSizeX+x]=col1;
			else
				layers[l][y*layerSizeX+x]=col2;
}


void TextureGenerator::blobsLayer(byte l, long seed, byte amount, bool rgb)
{
	long blobX[16], blobY[16];
	float blobR[16], blobG[16], blobB[16];
	float r, g, b, sd, d, oosize;
	long rx, ry;
	long offset;
	byte v;
	seedValue=seed;

	for (v=0; v<amount; v++)
	{
		blobX[v]=((myRandom()*layerSizeX)>>8)&andLayerSizeX;
		blobY[v]=((myRandom()*layerSizeY)>>8)&andLayerSizeY;
		blobR[v]=((float)(myRandom()&255)/255.f+0.1f)*150.f;
		if (rgb)
		{
			blobG[v]=((float)(myRandom()&255)/255.f+0.1f)*150.f;
			blobB[v]=((float)(myRandom()&255)/255.f+0.1f)*150.f;
		}
	}

	oosize=3.f/(layerSizeX*layerSizeY);
	iterY
		iterX
		{
			offset=y*layerSizeX+x;
			r=g=b=0.f;
			for (v=0; v<amount; v++)
			{
				rx=blobX[v]-x;
				ry=blobY[v]-y;
				d=oosize*(rx*rx+ry*ry);
				sd=d*d;
				d=-0.444444f*sd*d+1.888888f*sd-2.444444f*d+1.f;
				r+=d*blobR[v];
				g+=d*blobG[v];		// needn't be calculated if not rgb, but we do it for memory optimization (spares one if statement)
				b+=d*blobB[v];		// needn't be calculated if not rgb, but we do it for memory optimization (spares one if statement)
			}

			if (r<0.f) r=0.f;
			if (r>255.f) r=255.f;
			layers[l][offset].r=layers[l][offset].g=layers[l][offset].b=(byte)r;
			if (rgb)
			{
				if (g<0.f) g=0.f;
				if (g>255.f) g=255.f;
				layers[l][offset].g=(byte)g;
				if (b<0.f) b=0.f;
				if (b>255.f) b=255.f;
				layers[l][offset].b=(byte)b;
			}
		}
}


void TextureGenerator::scaleLayerRGB(byte src, byte dest, float r, float g, float b)
{
	float tr, tg, tb;

	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		tr=layers[src][v].r*r;
		tg=layers[src][v].g*g;
		tb=layers[src][v].b*b;

		if (tr>=255.f) layers[dest][v].r=255; else if (tr<=0.f) layers[dest][v].r=0; else layers[dest][v].r=(byte)tr;
		if (tg>=255.f) layers[dest][v].g=255; else if (tg<=0.f) layers[dest][v].g=0; else layers[dest][v].g=(byte)tg;
		if (tb>=255.f) layers[dest][v].b=255; else if (tb<=0.f) layers[dest][v].b=0; else layers[dest][v].b=(byte)tb;
	}
}


void TextureGenerator::scaleLayerHSV(byte src, byte dest, float h, float s, float v)
{
	float th, ts, tv, tr, tg, tb;

	for (long k=0; k<layerSizeX*layerSizeY; k++)
	{
		rgb2hsv(layers[src][k].r, layers[src][k].g, layers[src][k].b, &th, &ts, &tv);
		th*=h;
		ts*=s;
		tv*=v;
		if (ts>1.f) ts=1.f; else if (ts<0.f) ts=0.f;
		if (tv>255.f) tv=255.f; else if (tv<0.f) tv=0.f;
		hsv2rgb(th, ts, tv, &tr, &tg, &tb);
		layers[dest][k].r=(byte)tr;
		layers[dest][k].g=(byte)tg;
		layers[dest][k].b=(byte)tb;
	}
}


void TextureGenerator::adjustLayerRGB(byte src, byte dest, float r, float g, float b)
{
	float tr, tg, tb;

	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		tr=layers[src][v].r+r;
		tg=layers[src][v].g+g;
		tb=layers[src][v].b+b;

		if (tr>=255.f) layers[dest][v].r=255; else if (tr<=0.f) layers[dest][v].r=0; else layers[dest][v].r=(byte)tr;
		if (tg>=255.f) layers[dest][v].g=255; else if (tg<=0.f) layers[dest][v].g=0; else layers[dest][v].g=(byte)tg;
		if (tb>=255.f) layers[dest][v].b=255; else if (tb<=0.f) layers[dest][v].b=0; else layers[dest][v].b=(byte)tb;
	}
}


void TextureGenerator::adjustLayerHSV(byte src, byte dest, float h, float s, float v)
{
	float th, ts, tv, tr, tg, tb;

	for (long k=0; k<layerSizeX*layerSizeY; k++)
	{
		rgb2hsv(layers[src][k].r, layers[src][k].g, layers[src][k].b, &th, &ts, &tv);
		th+=h;
		ts+=s;
		tv+=v;
		if (ts>1.f) ts=1.f; else if (ts<0.f) ts=0.f;
		if (tv>255.f) tv=255.f; else if (tv<0.f) tv=0.f;
		hsv2rgb(th, ts, tv, &tr, &tg, &tb);
		layers[dest][k].r=(byte)tr;
		layers[dest][k].g=(byte)tg;
		layers[dest][k].b=(byte)tb;
	}
}


void TextureGenerator::sineLayerRGB(byte src, byte dest, float r, float g, float b)
{
	r*=(float)PI;
	g*=(float)PI;
	b*=(float)PI;
	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=(byte)(127.5f*(sin(r*layers[src][v].r)+1.f));
		layers[dest][v].g=(byte)(127.5f*(sin(g*layers[src][v].g)+1.f));
		layers[dest][v].b=(byte)(127.5f*(sin(b*layers[src][v].b)+1.f));
	}
}


void TextureGenerator::equalizeRGB(byte src, byte dest)
{
	long histogramR[256], histogramG[256], histogramB[256];
	float sumR, sumG, sumB, pDiv;
	long v;
	memset(histogramR, 0, sizeof(long)*256);
	memset(histogramG, 0, sizeof(long)*256);
	memset(histogramB, 0, sizeof(long)*256);

	for (v=0; v<layerSizeX*layerSizeY; v++)
	{
		histogramR[layers[src][v].r]++;
		histogramG[layers[src][v].g]++;
		histogramB[layers[src][v].b]++;
	}

	sumR=sumG=sumB=0.f;
	pDiv=255.f/(layerSizeX*layerSizeY);
	for (v=0; v<256; v++)			// v is already defined by for (long v=0; v<layerSizeX*layerSizeY; v++)!!!
	{
		sumR+=histogramR[v]*pDiv;
		histogramR[v]=(long)sumR;
		sumG+=histogramG[v]*pDiv;
		histogramG[v]=(long)sumG;
		sumB+=histogramB[v]*pDiv;
		histogramB[v]=(long)sumB;
	}

	for (v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=(byte)histogramR[layers[src][v].r];
		layers[dest][v].g=(byte)histogramG[layers[src][v].g];
		layers[dest][v].b=(byte)histogramB[layers[src][v].b];
	}
}


void TextureGenerator::stretchRGB(byte src, byte dest)
{
	long histogramR[256], histogramG[256], histogramB[256];
	float sumR, sumG, sumB, pDivR, pDivG, pDivB;
	long minR, minG, minB, maxR, maxG, maxB;
	long v;
	memset(histogramR, 0, sizeof(long)*256);
	memset(histogramG, 0, sizeof(long)*256);
	memset(histogramB, 0, sizeof(long)*256);

	for (v=0; v<layerSizeX*layerSizeY; v++)
	{
		histogramR[layers[src][v].r]++;
		histogramG[layers[src][v].g]++;
		histogramB[layers[src][v].b]++;
	}

	minR=minG=minB=-1;
	maxR=maxG=maxB=0;
	for (v=0; v<256; v++)
	{
		if (histogramR[v]!=0){maxR=v; if(minR==-1)minR=v;}
		if (histogramG[v]!=0){maxG=v; if(minG==-1)minG=v;}
		if (histogramB[v]!=0){maxB=v; if(minB==-1)minB=v;}
	}

	sumR=(float)minR; sumG=(float)minG; sumB=(float)minB;
	pDivR=(maxR-minR)/(float)(layerSizeX*layerSizeY);
	pDivG=(maxG-minG)/(float)(layerSizeX*layerSizeY);
	pDivB=(maxB-minB)/(float)(layerSizeX*layerSizeY);
	for (v=0; v<256; v++)			// v is already defined by for (long v=0; v<layerSizeX*layerSizeY; v++)!!!
	{
		sumR+=histogramR[v]*pDivR;
		histogramR[v]=(long)sumR;
		sumG+=histogramG[v]*pDivG;
		histogramG[v]=(long)sumG;
		sumB+=histogramB[v]*pDivB;
		histogramB[v]=(long)sumB;
	}

	for (v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=(byte)histogramR[layers[src][v].r];
		layers[dest][v].g=(byte)histogramG[layers[src][v].g];
		layers[dest][v].b=(byte)histogramB[layers[src][v].b];
	}
}


void TextureGenerator::invertLayer(byte src, byte dest)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		((long**)layers)[dest][v]=~((long**)layers)[src][v];
}


void TextureGenerator::matrixLayer(byte src, byte dest, bool abs, float matrix[3][3])
{
	float r, g, b;
	long offset;

	copyTemp;

	iterY
		iterX
		{
			r=g=b=0.f;
			for (char my=0; my<3; my++)
				for (char mx=0; mx<3; mx++)
				{
					offset=((x-1+mx)&andLayerSizeX)+((y-1+my)&andLayerSizeY)*layerSizeX;
					r+=matrix[mx][my]*layers[TEMPL][offset].r;
					g+=matrix[mx][my]*layers[TEMPL][offset].g;
					b+=matrix[mx][my]*layers[TEMPL][offset].b;
				}
			if (abs)
			{
				r=(float)fabs(r);
				g=(float)fabs(g);
				b=(float)fabs(b);
			}

			if (r<0.f) r=0.f; else if (r>255.f) r=255.f;
			if (g<0.f) g=0.f; else if (g>255.f) g=255.f;
			if (b<0.f) b=0.f; else if (b>255.f) b=255.f;

			layers[dest][x+y*layerSizeX].r=(byte)r;
			layers[dest][x+y*layerSizeX].g=(byte)g;
			layers[dest][x+y*layerSizeX].b=(byte)b;
		}
}


void TextureGenerator::embossLayer(byte src, byte dest)
{
	float r1, g1, b1, r2, g2, b2;
	long offset, offsetxm1, offsetxp1, offsetym1, offsetyp1;

	copyTemp;

	iterY
	{
		offsetym1=((y-1)&andLayerSizeY)*layerSizeX;
		offset=y*layerSizeX;
		offsetyp1=((y+1)&andLayerSizeY)*layerSizeX;
		iterX
		{
			offsetxm1=(x-1)&andLayerSizeX;
			offsetxp1=(x+1)&andLayerSizeX;
			r1=128.f
				-layers[TEMPL][offsetxm1+offsetym1].r
				-layers[TEMPL][offsetxm1+offset].r
				-layers[TEMPL][offsetxm1+offsetyp1].r
				+layers[TEMPL][offsetxp1+offsetym1].r
				+layers[TEMPL][offsetxp1+offset].r
				+layers[TEMPL][offsetxp1+offsetyp1].r;
			g1=128.f
				-layers[TEMPL][offsetxm1+offsetym1].g
				-layers[TEMPL][offsetxm1+offset].g
				-layers[TEMPL][offsetxm1+offsetyp1].g
				+layers[TEMPL][offsetxp1+offsetym1].g
				+layers[TEMPL][offsetxp1+offset].g
				+layers[TEMPL][offsetxp1+offsetyp1].g;
			b1=128.f
				-layers[TEMPL][offsetxm1+offsetym1].b
				-layers[TEMPL][offsetxm1+offset].b
				-layers[TEMPL][offsetxm1+offsetyp1].b
				+layers[TEMPL][offsetxp1+offsetym1].b
				+layers[TEMPL][offsetxp1+offset].b
				+layers[TEMPL][offsetxp1+offsetyp1].b;
			r2=128.f
				-layers[TEMPL][offsetym1+offsetxm1].r
				-layers[TEMPL][offsetym1+x].r
				-layers[TEMPL][offsetym1+offsetxp1].r
				+layers[TEMPL][offsetyp1+offsetxm1].r
				+layers[TEMPL][offsetyp1+x].r
				+layers[TEMPL][offsetyp1+offsetxp1].r;
			g2=128.f
				-layers[TEMPL][offsetym1+offsetxm1].g
				-layers[TEMPL][offsetym1+x].g
				-layers[TEMPL][offsetym1+offsetxp1].g
				+layers[TEMPL][offsetyp1+offsetxm1].g
				+layers[TEMPL][offsetyp1+x].g
				+layers[TEMPL][offsetyp1+offsetxp1].g;
			b2=128.f
				-layers[TEMPL][offsetym1+offsetxm1].b
				-layers[TEMPL][offsetym1+x].b
				-layers[TEMPL][offsetym1+offsetxp1].b
				+layers[TEMPL][offsetyp1+offsetxm1].b
				+layers[TEMPL][offsetyp1+x].b
				+layers[TEMPL][offsetyp1+offsetxp1].b;
			r1=(float)mySqrtInt((long)(r1*r1+r2*r2));
			g1=(float)mySqrtInt((long)(g1*g1+g2*g2));
			b1=(float)mySqrtInt((long)(b1*b1+b2*b2));
			if (r1>255) r1=255;
			if (g1>255) g1=255;
			if (b1>255) b1=255;
			layers[dest][x+offset].r=(byte)r1;
			layers[dest][x+offset].g=(byte)g1;
			layers[dest][x+offset].b=(byte)b1;
		}
	}
}


void TextureGenerator::woodLayer(byte src, byte dest, byte b)
{
	byte bm8=8-b;
	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=(layers[src][v].r<<b)|(layers[src][v].r>>bm8);
		layers[dest][v].g=(layers[src][v].g<<b)|(layers[src][v].g>>bm8);
		layers[dest][v].b=(layers[src][v].b<<b)|(layers[src][v].b>>bm8);
	}
}


void TextureGenerator::blurLayer(byte src, byte dest)
{
	float matrix[3][3];
	matrix[0][0]=0.0625f; matrix[1][0]=0.125f; matrix[2][0]=0.0625f;
	matrix[0][1]=0.125f; matrix[1][1]=0.25f; matrix[2][1]=0.125f;
	matrix[0][2]=0.0625f; matrix[1][2]=0.125f; matrix[2][2]=0.0625f;
	matrixLayer(src, dest, false, matrix);
}


void TextureGenerator::edgeHLayer(byte src, byte dest)
{
	float matrix[3][3];
	matrix[0][0]=2.f; matrix[1][0]=4.f; matrix[2][0]=2.f;
	matrix[0][1]=0.f; matrix[1][1]=0.f; matrix[2][1]=0.f;
	matrix[0][2]=-2.f; matrix[1][2]=-4.f; matrix[2][2]=-2.f;
	matrixLayer(src, dest, true, matrix);
}


void TextureGenerator::edgeVLayer(byte src, byte dest)
{
	float matrix[3][3];
	matrix[0][0]=2.f; matrix[1][0]=0.f; matrix[2][0]=-2.f;
	matrix[0][1]=4.f; matrix[1][1]=0.f; matrix[2][1]=-4.f;
	matrix[0][2]=2.f; matrix[1][2]=0.f; matrix[2][2]=-2.f;
	matrixLayer(src, dest, true, matrix);
}


void TextureGenerator::sharpenLayer(byte src, byte dest)
{
	float matrix[3][3];
	matrix[0][0]=-0.125f; matrix[1][0]=-0.25f; matrix[2][0]=-0.125f;
	matrix[0][1]=-0.25f; matrix[1][1]=2.5f; matrix[2][1]=-0.25f;
	matrix[0][2]=-0.125f; matrix[1][2]=-0.25f; matrix[2][2]=-0.125f;
	matrixLayer(src, dest, false, matrix);
}


void TextureGenerator::motionBlur(byte src, byte dest, byte s)
{
	long sq, ts, r, g, b, offset, offset2;

	copyTemp;
	sq=(s+1)*(s+1);
	iterY
	{
		offset=y*layerSizeX;
		iterX
		{
			r=g=b=0;
			for (int t=-s; t<=s; t++)
			{
				offset2=offset+((x+t)&andLayerSizeX);
				ts=(s+1-abs(t));
				r+=layers[TEMPL][offset2].r*ts;
				g+=layers[TEMPL][offset2].g*ts;
				b+=layers[TEMPL][offset2].b*ts;
			}
			layers[dest][offset+x].r=(byte)(r/sq);
			layers[dest][offset+x].g=(byte)(g/sq);
			layers[dest][offset+x].b=(byte)(b/sq);
		}
	}
}


void TextureGenerator::makeTileable(byte src, byte dest, long s)
{
	long offset, offset2, sx, sy;
	float sq, sr, sd, srm;

	copyTemp;
	s=layerSizeX/2-s;
	sq=(float)(s*s);
	sd=(layerSizeX/2)*(layerSizeY/2)-sq;
	if (sd!=0.f)
		sd=0.75f/sd;
	else
		sd=75000.f;
	iterY
	{
		offset=y*layerSizeX;
		offset2=(layerSizeY-1-y)*layerSizeX;
		sy=y-layerSizeY/2;
		sy*=sy;
		iterX
		{
			sx=x-layerSizeX/2;
			sr=sx*sx+sy-sq;
			if (sr>0.f)
			{
				sr*=sd;
				if (sr>0.75f)
				{
					sr=0.25f;
					srm=0.25f;
				} else {
					srm=1.f-sr;
					sr/=3.f;
				}
				layers[dest][offset+x].r=(byte)(layers[TEMPL][offset+x].r*srm+(layers[TEMPL][offset+layerSizeX-1-x].r+layers[TEMPL][offset2+layerSizeX-1-x].r+layers[TEMPL][offset2+x].r)*sr);
				layers[dest][offset+x].g=(byte)(layers[TEMPL][offset+x].g*srm+(layers[TEMPL][offset+layerSizeX-1-x].g+layers[TEMPL][offset2+layerSizeX-1-x].g+layers[TEMPL][offset2+x].g)*sr);
				layers[dest][offset+x].b=(byte)(layers[TEMPL][offset+x].b*srm+(layers[TEMPL][offset+layerSizeX-1-x].b+layers[TEMPL][offset2+layerSizeX-1-x].b+layers[TEMPL][offset2+x].b)*sr);
			}
		}
	}
}


byte TextureGenerator::median(byte *v)
{
	byte a[5];
	int i, j, last;
	memset(a, 0, 5);
	for (i=0; i<9; i++)
	{
		last=4;
		for (j=4; j>=0; j--)
			if (a[j]<=v[i])
				last=j;
		for (j=3; j>=last; j--)
			a[j+1]=a[j];
		a[last]=v[i];
	}
	return a[4];
}


void TextureGenerator::medianLayer(byte src, byte dest)
{
	long offset[9];
	byte colors[9];
	byte i;

	copyTemp;

	iterY
		iterX
		{
			for (i=0; i<9; i++)
				offset[i]=((x-1+(i%3))&andLayerSizeX)+((y-1+(i/3))&andLayerSizeY)*layerSizeX;
			for (i=0; i<9; i++)
				colors[i]=layers[TEMPL][offset[i]].r;
			layers[dest][offset[4]].r=median(colors);
			for (i=0; i<9; i++)
				colors[i]=layers[TEMPL][offset[i]].g;
			layers[dest][offset[4]].g=median(colors);
			for (i=0; i<9; i++)
				colors[i]=layers[TEMPL][offset[i]].b;
			layers[dest][offset[4]].b=median(colors);
		}
}


void TextureGenerator::erodeLayer(byte src, byte dest)
{
	long offset, offsetym1, offsetyp1, offsetxm1, offsetxp1;
	byte r, g, b;

	copyTemp;
	iterY
	{
		offset=y*layerSizeX;
		offsetym1=((y-1)&andLayerSizeY)*layerSizeX;
		offsetyp1=((y+1)&andLayerSizeY)*layerSizeX;
		iterX
		{
			offsetxm1=(x-1)&andLayerSizeX;
			offsetxp1=(x+1)&andLayerSizeX;

			r=	min(layers[TEMPL][offsetym1+offsetxm1].r,
				min(layers[TEMPL][offsetym1+x].r,
				min(layers[TEMPL][offsetym1+offsetxp1].r,
				min(layers[TEMPL][offset+offsetxm1].r,
				min(layers[TEMPL][offset+x].r,
				min(layers[TEMPL][offset+offsetxp1].r,
				min(layers[TEMPL][offsetyp1+offsetxm1].r,
				min(layers[TEMPL][offsetyp1+x].r,
				layers[TEMPL][offsetyp1+offsetxp1].r))))))));
			g=	min(layers[TEMPL][offsetym1+offsetxm1].g,
				min(layers[TEMPL][offsetym1+x].g,
				min(layers[TEMPL][offsetym1+offsetxp1].g,
				min(layers[TEMPL][offset+offsetxm1].g,
				min(layers[TEMPL][offset+x].g,
				min(layers[TEMPL][offset+offsetxp1].g,
				min(layers[TEMPL][offsetyp1+offsetxm1].g,
				min(layers[TEMPL][offsetyp1+x].g,
				layers[TEMPL][offsetyp1+offsetxp1].g))))))));
			b=	min(layers[TEMPL][offsetym1+offsetxm1].b,
				min(layers[TEMPL][offsetym1+x].b,
				min(layers[TEMPL][offsetym1+offsetxp1].b,
				min(layers[TEMPL][offset+offsetxm1].b,
				min(layers[TEMPL][offset+x].b,
				min(layers[TEMPL][offset+offsetxp1].b,
				min(layers[TEMPL][offsetyp1+offsetxm1].b,
				min(layers[TEMPL][offsetyp1+x].b,
				layers[TEMPL][offsetyp1+offsetxp1].b))))))));
			layers[dest][offset+x].r=r;
			layers[dest][offset+x].g=g;
			layers[dest][offset+x].b=b;
		}
	}
}


void TextureGenerator::dilateLayer(byte src, byte dest)
{
	long offset, offsetym1, offsetyp1, offsetxm1, offsetxp1;
	byte r, g, b;

	copyTemp;
	iterY
	{
		offset=y*layerSizeX;
		offsetym1=((y-1)&andLayerSizeY)*layerSizeX;
		offsetyp1=((y+1)&andLayerSizeY)*layerSizeX;
		iterX
		{
			offsetxm1=(x-1)&andLayerSizeX;
			offsetxp1=(x+1)&andLayerSizeX;

			r=	max(layers[TEMPL][offsetym1+offsetxm1].r,
				max(layers[TEMPL][offsetym1+x].r,
				max(layers[TEMPL][offsetym1+offsetxp1].r,
				max(layers[TEMPL][offset+offsetxm1].r,
				max(layers[TEMPL][offset+x].r,
				max(layers[TEMPL][offset+offsetxp1].r,
				max(layers[TEMPL][offsetyp1+offsetxm1].r,
				max(layers[TEMPL][offsetyp1+x].r,
				layers[TEMPL][offsetyp1+offsetxp1].r))))))));
			g=	max(layers[TEMPL][offsetym1+offsetxm1].g,
				max(layers[TEMPL][offsetym1+x].g,
				max(layers[TEMPL][offsetym1+offsetxp1].g,
				max(layers[TEMPL][offset+offsetxm1].g,
				max(layers[TEMPL][offset+x].g,
				max(layers[TEMPL][offset+offsetxp1].g,
				max(layers[TEMPL][offsetyp1+offsetxm1].g,
				max(layers[TEMPL][offsetyp1+x].g,
				layers[TEMPL][offsetyp1+offsetxp1].g))))))));
			b=	max(layers[TEMPL][offsetym1+offsetxm1].b,
				max(layers[TEMPL][offsetym1+x].b,
				max(layers[TEMPL][offsetym1+offsetxp1].b,
				max(layers[TEMPL][offset+offsetxm1].b,
				max(layers[TEMPL][offset+x].b,
				max(layers[TEMPL][offset+offsetxp1].b,
				max(layers[TEMPL][offsetyp1+offsetxm1].b,
				max(layers[TEMPL][offsetyp1+x].b,
				layers[TEMPL][offsetyp1+offsetxp1].b))))))));
			layers[dest][offset+x].r=r;
			layers[dest][offset+x].g=g;
			layers[dest][offset+x].b=b;
		}
	}
}


void TextureGenerator::sineDistort(byte src, byte dest, float dx, float depthX, float dy, float depthY)
{
	copyTemp;
	iterY
		iterX
			layers[dest][x+y*layerSizeX]=getBilerpPixel(TEMPL, (float)sin(dx*y)*depthX+x, (float)sin(dy*x)*depthY+y);
}


void TextureGenerator::twirlLayer(byte src, byte dest, float rot, float scale)
{
	float ooscale, a, b, d, winkel, cw, sw, na, nb;
	long ina, inb, inbp, inap1, inbp1;
	RGBA corner[4];

	copyTemp;

	ooscale=1.f/(scale*(float)sqrt(2.f*layerSizeX*layerSizeY));
	iterY
	{
		b=(float)(y-layerSizeY/2);
		iterX
		{
			a=(float)(x-layerSizeX/2);
			d=-(float)sqrt(a*a+b*b)+layerSizeX/2;
			if (d<=0.f)
			{
				na=(float)(ina=x);
				nb=(float)(inb=y);
			} else {
				winkel=rot*d*d*ooscale;
				cw=(float)cos(winkel);
				sw=(float)sin(winkel);
				na=a*cw-b*sw+layerSizeX/2;
				nb=a*sw+b*cw+layerSizeY/2;
				ina=(long)na;
				inb=(long)nb;
			}
			inbp=(inb&andLayerSizeY)*layerSizeX;
			inbp1=((inb+1)&andLayerSizeY)*layerSizeX;
			inap1=(ina+1)&andLayerSizeX;
			corner[0]=layers[TEMPL][(ina&andLayerSizeX)+inbp];
			corner[1]=layers[TEMPL][inap1+inbp];
			corner[2]=layers[TEMPL][(ina&andLayerSizeX)+inbp1];
			corner[3]=layers[TEMPL][inap1+inbp1];
			layers[dest][x+y*layerSizeX]=cosineInterpolate(corner, na-ina, nb-inb);
		}
	}
}


void TextureGenerator::tileLayer(byte src, byte dest)
{
	long offset, offset2, offset3;

	copyTemp;

	iterY
	{
		offset=y*layerSizeX;
		offset2=((y*2)&andLayerSizeY)*layerSizeX;
		iterX
		{
			offset3=((x*2)&andLayerSizeX)+offset2;
			layers[dest][x+offset].r=(layers[TEMPL][offset3].r+layers[TEMPL][offset3+1].r+layers[TEMPL][offset3+layerSizeX].r+layers[TEMPL][offset3+layerSizeX+1].r)>>2;
			layers[dest][x+offset].g=(layers[TEMPL][offset3].g+layers[TEMPL][offset3+1].g+layers[TEMPL][offset3+layerSizeX].g+layers[TEMPL][offset3+layerSizeX+1].g)>>2;
			layers[dest][x+offset].b=(layers[TEMPL][offset3].b+layers[TEMPL][offset3+1].b+layers[TEMPL][offset3+layerSizeX].b+layers[TEMPL][offset3+layerSizeX+1].b)>>2;
		}
	}
}


void TextureGenerator::noiseDistort(byte src, byte dest, long seed, byte radius)
{
	long dx, dy;
	copyTemp;
	seedValue=seed;
	radius=16-radius;
	iterY
		iterX
		{
			dx=(myRandom()-32767)>>radius;
			dy=(myRandom()-32767)>>radius;
			layers[dest][x+y*layerSizeX]=layers[TEMPL][((x+dx)&andLayerSizeX)+((y+dy)&andLayerSizeY)*layerSizeX];
		}
}


void TextureGenerator::moveDistort(byte src, byte dest, int dx, int dy)
{
	copyTemp;
	iterY
		iterX
			layers[dest][x+y*layerSizeX]=layers[TEMPL][((x+dx)&andLayerSizeX)+((y+dy)&andLayerSizeY)*layerSizeX];
}


void TextureGenerator::kaleidLayer(byte src, byte dest, byte corner)
{
	errorExit("kaleidLayer NOT IMPLEMENTED YET!");
}


void TextureGenerator::tunnelDistort(byte src, byte dest, float f)
{
	long ina, inb, inap1, inbp, inbp1;
	float a, b, na, nb;
	RGBA corner[4];
	float arct, lsd2p;

	copyTemp;
	lsd2p=layerSizeX/(2.f*(float)PI);
	iterY
	{
		b=-0.5f*layerSizeY+y;
		iterX
		{
			a=-0.5f*layerSizeX+x;
			if (a!=0.f)
			{
				a=1.f/a;
				arct=(float)atan(b*a);
				if (a>0.f)
					na=lsd2p*arct+layerSizeX/2;
				else
					na=lsd2p*arct;
				nb=(float)fabs(cos(arct)*f*a);
				ina=(int)na;
				inb=(int)nb;
				inap1=(ina+1)&andLayerSizeX;
				inbp=(inb&andLayerSizeY)*layerSizeX;
				inbp1=((inb+1)&andLayerSizeY)*layerSizeX;
				corner[0]=layers[TEMPL][(ina&andLayerSizeX)+inbp];
				corner[1]=layers[TEMPL][inap1+inbp];
				corner[2]=layers[TEMPL][(ina&andLayerSizeX)+inbp1];
				corner[3]=layers[TEMPL][inap1+inbp1];
			}
			layers[dest][x+y*layerSizeX]=cosineInterpolate(corner, na-ina, nb-inb);
		}
	}
}


void TextureGenerator::sculptureLayer(byte src, byte dest)
{
	errorExit("sculptureLayer NOT IMPLEMENTED YET!");
}


void TextureGenerator::mapDistort(byte src, byte dist, byte dest, float xd, float yd)
{
	long offset;
	byte v;

	copyTemp;

	iterY
		iterX
		{
			offset=y*layerSizeX+x;
			v=max(layers[dist][offset].r, max(layers[dist][offset].g, layers[dist][offset].b));
			layers[dest][offset]=getBilerpPixel(TEMPL, xd*v+x, yd*v+y);
		}
}


void TextureGenerator::addLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	float r, g, b;

	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		r=layers[src1][v].r*perc1+layers[src2][v].r*perc2;
		g=layers[src1][v].g*perc1+layers[src2][v].g*perc2;
		b=layers[src1][v].b*perc1+layers[src2][v].b*perc2;
		if (r>255.f) r=255.f; else if (r<0.f) r=0.f;
		if (g>255.f) g=255.f; else if (g<0.f) g=0.f;
		if (b>255.f) b=255.f; else if (b<0.f) b=0.f;
		layers[dest][v].r=(byte)r;
		layers[dest][v].g=(byte)g;
		layers[dest][v].b=(byte)b;
	}
}


void TextureGenerator::mulLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	float r, g, b, perc;

	perc=perc1*perc2/255.f;
	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		r=layers[src1][v].r*layers[src2][v].r*perc;
		g=layers[src1][v].g*layers[src2][v].g*perc;
		b=layers[src1][v].b*layers[src2][v].b*perc;
		if (r>255.f) r=255.f; else if (r<0.f) r=0.f;
		if (g>255.f) g=255.f; else if (g<0.f) g=0.f;
		if (b>255.f) b=255.f; else if (b<0.f) b=0.f;
		layers[dest][v].r=(byte)r;
		layers[dest][v].g=(byte)g;
		layers[dest][v].b=(byte)b;
	}
}


void TextureGenerator::xorLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		((unsigned long**)layers)[dest][v]=((unsigned long**)layers)[src1][v] ^ ((unsigned long**)layers)[src2][v];
}


void TextureGenerator::andLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		((unsigned long**)layers)[dest][v]=((unsigned long**)layers)[src1][v] & ((unsigned long**)layers)[src2][v];
}


void TextureGenerator::orLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		((unsigned long**)layers)[dest][v]=((unsigned long**)layers)[src1][v] | ((unsigned long**)layers)[src2][v];
}


void TextureGenerator::randCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
		((unsigned long**)layers)[dest][v]=myRandom()&1?((unsigned long**)layers)[src1][v]:((unsigned long**)layers)[src2][v];
}


void TextureGenerator::maxCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=max(layers[src1][v].r, layers[src2][v].r);
		layers[dest][v].g=max(layers[src1][v].g, layers[src2][v].g);
		layers[dest][v].b=max(layers[src1][v].b, layers[src2][v].b);
	}
}


void TextureGenerator::minCombineLayers(byte src1, byte src2, byte dest, float perc1, float perc2)
{
	for (long v=0; v<layerSizeX*layerSizeY; v++)
	{
		layers[dest][v].r=min(layers[src1][v].r, layers[src2][v].r);
		layers[dest][v].g=min(layers[src1][v].g, layers[src2][v].g);
		layers[dest][v].b=min(layers[src1][v].b, layers[src2][v].b);
	}
}
