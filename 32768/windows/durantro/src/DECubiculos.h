// -------------------------------------------------------------------------------------
// File:        DECubiculos.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DECUBICULOS_H_
#define _DECUBICULOS_H_

#include "DemoEffect.h"
#include "BasicMesh.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDECubiculos: public CDemoEffect
{
    typedef CDemoEffect inherited;
  public:
    CDECubiculos       ()                  { }
    ~CDECubiculos      ()                  { End(); }

    TError      Init        (CDisplayDevice *pDev);
    void        End         ();

    bool        Run         (int time);
    void        Draw        (CRenderContext &rc) const;

  private:
    CBasicMesh       m_mesh;
};

#endif // _DECUBICULOS_H_
