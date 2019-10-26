//-----------------------------------------------------------------------------------------
//  Nombre:     DisplayVertex.cpp
//
//  Contenido:  Operaciones de renderizado.
//-----------------------------------------------------------------------------------------

#include "Base.h"
#include "DisplayVertex.h"
#include <d3d8.h>

const unsigned DV_FVF_VERTEX      = D3DFVF_XYZ | D3DFVF_NORMAL;
const unsigned DV_FVF_VERTEXUV    = D3DFVF_XYZ | D3DFVF_NORMAL | D3DFVF_TEX1;
const unsigned DV_FVF_LVERTEX     = D3DFVF_XYZ | D3DFVF_DIFFUSE;
const unsigned DV_FVF_LVERTEXUV   = D3DFVF_XYZ | D3DFVF_DIFFUSE | D3DFVF_TEX1;
const unsigned DV_FVF_TLVERTEX    = D3DFVF_XYZRHW | D3DFVF_DIFFUSE;
const unsigned DV_FVF_TLVERTEXUV  = D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1;
