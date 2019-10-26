#ifndef _Material_h_
#define _Material_h_

typedef struct
{
  float ambr,ambg,ambb;
  float difr,difg,difb;
  float specular;
  float reflect,shiness;
  class Bitmap *texture;
  int textureid;
  class NormalMap *bumpmap;
  int bumpid;
  float mindot; // Pienin mahollinen specularin dotti
} Material;

#endif