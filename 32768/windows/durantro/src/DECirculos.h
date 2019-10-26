// -------------------------------------------------------------------------------------
// File:        DECirculos.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DECIRCULOS_H_
#define _DECIRCULOS_H_

#include "DemoEffect.h"
#include "BasicMesh.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDECirculos: public CDemoEffect
{
    typedef CDemoEffect inherited;
  public:
    CDECirculos       ()                  { }
    ~CDECirculos      ()                  { End(); }

    TError      Init        (CDisplayDevice *pDev);
    void        End         ();

    bool        Run         (int time);
    void        Draw        (CRenderContext &rc) const;

  private:
    CBasicMesh       m_mesh;
};

#endif // _DECIRCULOS_H_
