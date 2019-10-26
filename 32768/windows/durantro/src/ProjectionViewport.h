//-----------------------------------------------------------------------------------------
//  Nombre:     ProjectionViewport.h
//
//  Contenido:  Proyecciones 3D
//-----------------------------------------------------------------------------------------

#ifndef _PROJECTION_VIEWPORT_H_
#define _PROJECTION_VIEWPORT_H_

// ---------------------------------------
// ---------------------------------------

struct TProjectionViewport
{
  float Kx, Ky, Kz;
  float offX, offY;
  float ZnKz;
  int   vx, vy, vw, vh;   // Viewport rect.
  float ivpw, ivph, zn;   // (ivpw, ivph, Kz, zn) are the appropriate parameters for DisplayDevice->SetProjection()

  void  Set     (int x, int y, int w, int h,
                 float vpw = 1.33333333f, float vph = 1.f,
                 float zn = 1.f, float zf = 1025.f);

  float XFormZ    (float z) const       { return Kz - ZnKz/z; /*(z - Zn)*Kz / z;*/ }
  float XFormInvZ (float iz) const      { return Kz - ZnKz*iz; /*(z - Zn)*Kz / z;*/ }

  void  XForm   (float x, float y, float z, float &sx, float &sy, float &sz, float &rhw) const
  {
    float iz = 1.f / z;
    sx = offX + x*Kx*iz;
    sy = offY + y*Ky*iz;
    sz = Kz - ZnKz*iz;
    rhw = iz;
  }

  void  XFormInvZ (float x, float y, float iz, float &sx, float &sy, float &sz, float &rhw) const
  {
    sx = offX + x*Kx*iz;
    sy = offY + y*Ky*iz;
    sz = Kz - ZnKz*iz;
    rhw = iz;
  }

  void  XForm     (float x, float y, float z, float &sx, float &sy) const
  {
    float iz = 1.f / z;
    sx = offX + x*Kx*iz;
    sy = offY + y*Ky*iz;
  }

  void  XFormInvZ (float x, float y, float iz, float &sx, float &sy) const
  {
    sx = offX + x*Kx*iz;
    sy = offY + y*Ky*iz;
  }

  float XFormDeltaX   (float x, float iz) const   { return x*Kx*iz; }
  float XFormDeltaY   (float y, float iz) const   { return y*Ky*iz; }

  float BackXFormZ    (float fz) const { return ZnKz/(Kz - fz); }
  float BackXFormInvZ (float fz) const { return (Kz - fz)/ZnKz; }
};

#endif // _PROJECTION_VIEWPORT_H_
