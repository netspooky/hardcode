//-----------------------------------------------------------------------------------------
//  Nombre:     RenderContext.cpp
//
//  Contenido:  Operaciones de renderizado.
//-----------------------------------------------------------------------------------------

#include "Base.h"
#include "RenderContext.h"
#include "DisplayDevice.h"
#include "StdDisplayMaterials.h"
#include "Vectors.h"
#include "DisplayVertex.h"

#include <d3d8.h>

//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
__forceinline bool CRenderContext::SetupSimpleMaterial(TColor c, const IDisplayMaterial *pMat)
{
  if (pMat)
  {
    pMat->Set(m_pDev);
  }
  else
  {
    int a = Color_A(c);
    if (a == 0)
      return false;
    const CStdDisplayMaterial *pStdMat = (a != 255)? &m_BlendRGB : &m_SolidRGB;
    pStdMat->Set(m_pDev);
  }
  return true;
}

//----------------------------------------------------------------------
//----------------------------------------------------------------------
//----------------------------------------------------------------------


//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CRenderContext::Init   (CDisplayDevice *pDev,
                             int x, int y, int w, int h,
                             float vpw, float vph,
                             float zn, float zf)
{
  m_pDev = pDev;
  m_x = x;
  m_y = y;
  m_width   = w;
  m_height  = h;
  m_viewportWidth   = vpw;
  m_viewportHeight  = vph;
  m_zNear = zn;
  m_zFar  = zf;
  m_vp.Set(x, y, w, h, vpw, vph, zn, zf);
  m_pDev->SetProjectionViewport(&m_vp);

  m_SolidRGB.SetFlags(pDev, SDMF_BLEND_NONE);
  m_BlendRGB.SetFlags(pDev, SDMF_BLEND_ALPHA);
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CRenderContext::FillRect(float x, float y, float w, float h, TColor c, const IDisplayMaterial *pMat, float iz)
{
  ASSERT(IsOk());
//  ASSERT(m_pDev->IsActive());

  if (!SetupSimpleMaterial(c, pMat))
    return;

  TTLVertex av[4];
  float rhw = iz;
  float z = m_vp.XFormInvZ(iz);

  av[0].Set(x,   y,   z, rhw, c);
  av[1].Set(x+w, y,   z, rhw, c);
  av[2].Set(x,   y+h, z, rhw, c);
  av[3].Set(x+w, y+h, z, rhw, c);

  m_pDev->SetFVFShader(DV_FVF_TLVERTEX);
  m_pDev->GetDirect3DDevice()->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, av, sizeof(*av));
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CRenderContext::DrawLine2D(float x0, float y0, float x1, float y1, TColor c, const IDisplayMaterial *pMat, float iz)
{
  ASSERT(IsOk());
//  ASSERT(m_pDev->IsActive());

  if (!SetupSimpleMaterial(c, pMat))
    return;

  TTLVertex av[2];

  float rhw = iz;
  float z = m_vp.XFormInvZ(iz);
  
  av[0].Set(x0, y0, z, rhw, c);
  av[1].Set(x1, y1, z, rhw, c);

  m_pDev->SetFVFShader(DV_FVF_TLVERTEX);
  m_pDev->GetDirect3DDevice()->DrawPrimitiveUP(D3DPT_LINELIST, 1, av, sizeof(*av));
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CRenderContext::DrawLine3D(const TVector3 &v0, const TVector3 &v1, TColor c, const IDisplayMaterial *pMat)
{
  ASSERT(IsOk());
//  ASSERT(m_pDev->IsActive());

  if (!SetupSimpleMaterial(c, pMat))
    return;

  TLVertex av[2];
  
  av[0].Set(v0.x, v0.y, v0.z, c);
  av[1].Set(v1.x, v1.y, v1.z, c);
  
  m_pDev->SetFVFShader(DV_FVF_LVERTEX);
  m_pDev->GetDirect3DDevice()->DrawPrimitiveUP(D3DPT_LINELIST, 1, av, sizeof(*av));
//  m_pDev->GetLBatch()->Unlock();
}
