// -------------------------------------------------------------------------------------
// File:        DemoEffect.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DEMOEFFECT_H_
#define _DEMOEFFECT_H_

class CDisplayDevice;
class CRenderContext;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDemoEffect
{
  public:
            CDemoEffect       (): m_pDev(NULL)    { }
    virtual ~CDemoEffect      ()                  { End(); }

            TError      Init        (CDisplayDevice *pDev);
    virtual void        End         ()                                    { m_pDev = NULL; }
            bool        IsOk        ()                              const { return m_pDev != NULL; }

            bool        IsActive    ()                              const { return m_bActive; }
            void        Activate    (bool bActive = true)                 { m_bActive = bActive; }
    virtual bool        Run         (int time);
    virtual void        PreDraw     ()                         { }
    virtual void        Draw        (CRenderContext &rc) const { }

  protected:
    CDisplayDevice        *m_pDev;
    int                   m_curTime;
    bool                  m_bActive;

    int                   m_delta;    // Calculado por CDemoEffect::Run()
};

#endif // _DEMOEFFECT_H_
