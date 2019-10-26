//-----------------------------------------------------------------------------------------
//  Nombre:     RenderContext.h
//
//  Contenido:  Operaciones de renderizado.
//-----------------------------------------------------------------------------------------

#ifndef _RENDER_CONTEXT_H_
#define _RENDER_CONTEXT_H_

#include "ProjectionViewport.h"
#include "StdDisplayMaterials.h"

class CDisplayDevice;
class IDisplayMaterial;
struct TVector3;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CRenderContext
{
  public:
    CRenderContext  (): m_pDev(NULL)    { }
    ~CRenderContext ()                  { End(); }

    void  Init      (CDisplayDevice *pDev,
                     int x, int y, int w, int h,
                     float vpw = 1.33333333f, float vph = 1.f,
                     float zn = 1.f, float zf = 1025.f);

    void  End       ()                                { m_pDev = NULL; }
    bool  IsOk      ()            const { return m_pDev != NULL; }

    uint  GetWidth  () const    { return m_width;  }
    uint  GetHeight () const    { return m_height; }
    float GetZNear  () const    { return m_zNear;  }
    float GetZFar   () const    { return m_zFar;   }

    CDisplayDevice            *GetDevice    ()        { return m_pDev; }
    const TProjectionViewport &GetViewport  () const  { return m_vp; }

    void  Clear     (bool bColor = true, TColor color = 0, bool bZBuffer = true, float depth = 1.f, bool bStencil = false, int stValue = 0);

    // Quick & dirty primitives for getting stuff up and running.
    void  FillRect  (float x, float y, float w, float h, TColor c, const IDisplayMaterial *pMat = NULL, float iz = 1.f);
    void  DrawLine2D(float x0, float y0, float x1, float y1, TColor c, const IDisplayMaterial *pMat = NULL, float iz = 1.f);
    void  DrawLine3D(const TVector3 &v0, const TVector3 &v1, TColor c, const IDisplayMaterial *pMat = NULL);

  private:

    bool        SetupSimpleMaterial       (TColor c, const IDisplayMaterial *pMat);

    // ------------------

    CDisplayDevice     *m_pDev;
    TProjectionViewport m_vp;
    uint                m_x;
    uint                m_y;
    uint                m_width;
    uint                m_height;
    float               m_viewportWidth;
    float               m_viewportHeight;
    float               m_zNear;
    float               m_zFar;

    CStdDisplayMaterial m_SolidRGB;
    CStdDisplayMaterial m_BlendRGB;
};

#endif // _RENDER_CONTEXT_H_
