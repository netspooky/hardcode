//----------------------------------------------------------------------------
//  Nombre:    StdDisplayMaterials.h
//
//  Contenido: Materiales basicos para trabajar
//----------------------------------------------------------------------------

#ifndef _STD_DISPLAY_MATERIALS_H_
#define _STD_DISPLAY_MATERIALS_H_

#include "DisplayDevice.h"

enum
{
  SDMF_BLEND_NONE   = 0x0000,
  SDMF_BLEND_ALPHA  = 0x0001,
  SDMF_BLEND_ADD    = 0x0002,
  SDMF_BLEND_MASK     = 0x000F,

  SDMF_COLOR_DIFFUSE     = 0x0000,      // diffuse
  SDMF_COLOR_TEXTURE     = 0x0010,      // Texture0
  SDMF_COLOR_MODULATE    = 0x0020,      // Texture0 * diffuse
  SDMF_COLOR_MODULATE2X  = 0x0030,      // Texture0 *2 diffuse
  SDMF_COLOR_MASK        = 0x00F0,
  SDMF_COLOR_SHIFT       = 4,

  SDMF_ALPHATEST  = 0x1000,
  SDMF_FLAT       = 0x2000,
};

class CStdDisplayMaterial: public IDisplayMaterial
{
  public:

    CStdDisplayMaterial ()                                            { }
    CStdDisplayMaterial (CDisplayDevice *pDev, unsigned f): flags(f)  { }

            void SetFlags (CDisplayDevice *pDev, unsigned f)          { flags = f; }

    virtual void Set      (CDisplayDevice *) const;

    unsigned  flags;    // SDMF_xxx combo
};



#endif // _STD_DISPLAY_MATERIALS_H_
