//-----------------------------------------------------------------------------------------
//  Nombre:     ProjectionViewport.cpp
//
//  Contenido:  Proyecciones 3D
//-----------------------------------------------------------------------------------------

#include "Base.h"
#include "ProjectionViewport.h"

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void TProjectionViewport::Set(int x, int y, int w, int h,
                              float vpw, float vph,
                              float _zn, float zf)
{
  float dz = 1.f / (zf - _zn);
  float fw = float(w);
  float fh = float(h);
  ivpw = 1.f / vpw;
  ivph = 1.f / vph;
  zn   = _zn;
  vx = x; vy = y; vw = w; vh = h;

  Kx =  zn * fw * ivpw;
  Ky = -zn * fh * ivph;
  Kz = zf * dz;
  offX = float (x) + fw/2;
  offY = float (y) + fh/2;
  ZnKz = zn*Kz;
}
