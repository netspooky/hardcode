#ifndef __POLYGONS_H
#define __POYLGONS_H

typedef void filllinefn();
typedef void shadelinefn();
typedef void texturelinefn();
extern "C"
{
void polygonsetscreen(int=320, int=0, int=320, int=0, int=200);
void fillpolygon(long (*pts)[2], int n, int col, void (*fill)(), unsigned int scrseg);
void shadepolygon(long (*pts)[2], long* cols, int n, void (*shade), unsigned int scrseg);
void texturepolygon(long (*pts)[2], long (*vert)[2], int n, char* bmp, unsigned wid, int col, void (*texture)(), unsigned int scrseg);
void vshadepolygon(long (*pts)[2], long* cols, int n, void (*shade)(), unsigned int scrseg);
void vtexturepolygon(long (*pts)[2], long (*vert)[2], int n, char* bmp, unsigned wid, int col, void (*texture)(), unsigned int scrseg);

//void fillline();
//void filllineor();
//void filllineand();
void xfillline();
void xfillliner();
//void shadeline();
//void shadelinefast();
//void shadelinefastest();
//void xshadeline();
//void xshadelinefast();
//void xshadelinefastest();
void vxshadeline();
void vxshadelined();
void vxshadelineq320();
void vxshadelinedq320();
//void textureline();
//void texturelinex();
//void texturelinefast();
//void texturelinexfast();
//void texturelinefastest();
//void texturelinexfastest();
void xtextureline();
void xtexturelinex();
void xtexturelinefast();
void xtexturelinexfast();
void xtexturelinefastest();
void xtexturelinexfastest();
void vxtextureline();
void vxtexturelinex();
}

#endif
