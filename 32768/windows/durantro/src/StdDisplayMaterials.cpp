//----------------------------------------------------------------------------
//  Nombre:    StdDisplayMaterials.cpp
//
//  Contenido: Materiales basicos para trabajar
//----------------------------------------------------------------------------

#include "Base.h"
#include "StdDisplayMaterials.h"
#include <d3d8.h>

unsigned s_aColorOps[] =
{
  D3DTOP_SELECTARG2,
  D3DTOP_SELECTARG1,
  D3DTOP_MODULATE,
  D3DTOP_MODULATE2X,
};


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CStdDisplayMaterial::Set(CDisplayDevice *pDev) const
{
  unsigned color = (flags & SDMF_COLOR_MASK);

  // Slightly weird way to do things - may cure problems on bad drivers?
  pDev->SetTSS( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
  pDev->SetTSS( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
  pDev->SetTSS( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
  pDev->SetTSS( 0, D3DTSS_ALPHAARG2, D3DTA_DIFFUSE );
  pDev->SetTSS( 0, D3DTSS_COLOROP,   s_aColorOps[color >> SDMF_COLOR_SHIFT]);
  pDev->SetTSS( 0, D3DTSS_ALPHAOP,   s_aColorOps[color >> SDMF_COLOR_SHIFT]);

  pDev->SetTSS( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );
  pDev->SetTSS( 1, D3DTSS_ALPHAOP,   D3DTOP_DISABLE );

  // Blend settings.
  unsigned blend = (flags & SDMF_BLEND_MASK);
  if (blend == SDMF_BLEND_ALPHA)
  {
    pDev->SetRS(D3DRS_ALPHABLENDENABLE,  TRUE);
    pDev->SetRS(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA);
    pDev->SetRS(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
  }
  else if (blend == SDMF_BLEND_ADD)
  {
    pDev->SetRS(D3DRS_ALPHABLENDENABLE,  TRUE);
    pDev->SetRS(D3DRS_SRCBLEND,  D3DBLEND_ONE);
    pDev->SetRS(D3DRS_DESTBLEND, D3DBLEND_ONE);
  }
  else
  {
    pDev->SetRS(D3DRS_ALPHABLENDENABLE,  FALSE);
    pDev->SetRS(D3DRS_SRCBLEND,  D3DBLEND_ONE);
    pDev->SetRS(D3DRS_DESTBLEND, D3DBLEND_ZERO);
  }

  // Alpha test
  if (flags & SDMF_ALPHATEST)
  {
    pDev->SetRS(D3DRS_ALPHATESTENABLE,  TRUE);
    pDev->SetRS(D3DRS_ALPHAFUNC,        D3DCMP_GREATER);
  }
  else
  {
    pDev->SetRS(D3DRS_ALPHATESTENABLE,  FALSE);
    pDev->SetRS(D3DRS_ALPHAFUNC,        D3DCMP_ALWAYS);
  }

  if (flags & SDMF_FLAT)
    pDev->SetRS(D3DRS_SHADEMODE,  D3DSHADE_FLAT);
  else
    pDev->SetRS(D3DRS_SHADEMODE,  D3DSHADE_GOURAUD);
}
