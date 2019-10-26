//-----------------------------------------------------------------------------------------
//  Nombre:     DisplayVertex.h
//
//  Contenido:  Operaciones de renderizado.
//-----------------------------------------------------------------------------------------

#ifndef _DISPLAY_VERTEX_H_
#define _DISPLAY_VERTEX_H_

extern const unsigned DV_FVF_VERTEX;
extern const unsigned DV_FVF_VERTEXUV;
extern const unsigned DV_FVF_LVERTEX;
extern const unsigned DV_FVF_LVERTEXUV;
extern const unsigned DV_FVF_TLVERTEX;
extern const unsigned DV_FVF_TLVERTEXUV;

struct TVertex
{
  float x, y, z;
  float nx, ny, nz;

  void Set(float _x, float _y, float _z, float _nx, float _ny, float _nz) { x = _x; y = _y; z = _z; nx = _nx; ny = _ny; nz = _nz; }
};

struct TVertexUV
{
  float x, y, z;
  float nx, ny, nz;
  float u, v;

  void Set(float _x, float _y, float _z, float _nx, float _ny, float _nz, float _u, float _v) { x = _x; y = _y; z = _z; nx = _nx; ny = _ny; nz = _nz; u = _u; v = _v; }
};

struct TLVertex
{
  float x, y, z;
  dword c;

  void Set(float _x, float _y, float _z, dword _c) { x = _x; y = _y; z = _z; c = _c; }
};

struct TLVertexUV
{
  float x, y, z;
  dword c;
  float u, v;

  void Set(float _x, float _y, float _z, dword _c, float _u, float _v) { x = _x; y = _y; z = _z; c = _c; u = _u; v = _v; }
};

struct TTLVertex
{
  float x, y, z, rhw;
  dword c;

  void Set(float _x, float _y, float _z, float _rhw, dword _c) { x = _x; y = _y; z = _z; rhw = _rhw; c = _c; }
};

struct TTLVertexUV
{
  float x, y, z, rhw;
  dword c;
  float u, v;

  void Set(float _x, float _y, float _z, float _rhw, dword _c, float _u, float _v) { x = _x; y = _y; z = _z; rhw = _rhw; c = _c; u = _u; v = _v; }
};

#endif //_DISPLAY_VERTEX_H_
