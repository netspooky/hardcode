// -------------------------------------------------------------------------------------
// File:        BasicMesh.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _BASICMESH_H_
#define _BASICMESH_H_

#include "DXNames.h"

class CDisplayDevice;
class CRenderContext;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CBasicMesh
{
  public:
    CBasicMesh       (): m_pVBuffer(NULL)   { }
    ~CBasicMesh      ()                     { End(); }

    TError      Init        (CDisplayDevice *pDev, unsigned fvf, int nVerts, int nIdx, int stride);
    void        End         ();
    bool        IsOk        ()                              const { return (m_pVBuffer != NULL); }


    void       *LockVB      (int start = 0, int len = -1);
    void        UnlockVB    ();
    word       *LockIB      (int start = 0, int len = -1);
    void        UnlockIB    ();

    int         GetNVerts   ()                              const { return m_nVerts; }
    int         GetNIdx     ()                              const { return m_nIdx; }
    int         GetFVF      ()                              const { return m_fvf; }
    int         GetStride   ()                              const { return m_stride; }

    void        SetDraw     (CDisplayDevice *pDev, int starti = 0) const;

  private:
    DXN_D3DVertexBuffer     *m_pVBuffer;
    DXN_D3DIndexBuffer      *m_pIBuffer;

    int       m_nVerts;
    int       m_nIdx;
    unsigned  m_fvf;
    int       m_stride;
};

#endif // _BASICMESH_H_
