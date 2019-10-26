// -------------------------------------------------------------------------------------
// File:        TextTexture.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _TEXTTEXTURE_H_
#define _TEXTTEXTURE_H_

#include "DXNames.h"

typedef unsigned TColor;

class CDisplayDevice;
class CRenderContext;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CTextTexture
{
  public:
    CTextTexture       (): m_pDev(NULL)    { }
    ~CTextTexture      ()                  { End(); }

    TError      Init        (CDisplayDevice *pDev);
    void        End         ();
    bool        IsOk        ()                              const { return m_pDev != NULL; }

    int         AddText     (const char *pszText, const char *pszFont, int size, bool bBold = false, bool bItalic = false);

    DXN_Direct3DTexture
               *GetTexture  ()                              const { return m_pTex; }
    int         GetExtent   ()                              const { return m_extentX; }

    void        Draw        (CRenderContext &rc, TColor c, float x, float y);

  private:
    CDisplayDevice        *m_pDev;
    DXN_Direct3DTexture   *m_pTex;
    int                   m_extentX;
    int                   m_texW;
    int                   m_texScaleX;
    int                   m_extentY;
};

#endif // _TEXTTEXTURE_H_
