// -------------------------------------------------------------------------------------
// File:        DERayas.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DERAYAS_H_
#define _DERAYAS_H_

#include "DemoEffect.h"
#include "BasicMesh.h"
#include "vectors.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDERayas: public CDemoEffect
{
    typedef CDemoEffect inherited;
  public:
    enum
    {
      MODE_FIJO,
      MODE_TUNEL,
      MODE_FLOWER,
      MODE_LAST
    };

    CDERayas       ()                  { }
    ~CDERayas      ()                  { End(); }

    TError      Init        (CDisplayDevice *pDev, int mode);
    void        End         ();

    bool        Run         (int time);
    void        Draw        (CRenderContext &rc) const;

  private:

    void    haz_morph();
    void    run_flower();
    void    run_tunel();

    void    FillRayas (TVector3 (*paaRayas)[2]);

    enum  { MAX_RAYAS = 800 };

    CBasicMesh    m_mesh;

    int           m_mode;
    float         m_transitionFactor;
    float         m_transitionSpeed;

    TVector3      m_aRayas[MAX_RAYAS][2];
    unsigned      m_aColors[MAX_RAYAS];

    TVector3      m_aDestRayas[MAX_RAYAS][2];

    int           m_indiceFlower;
    int           m_indiceTunel;
    TMatrix3      m_ViewMatrix;

};

#endif // _DERAYAS_H_
