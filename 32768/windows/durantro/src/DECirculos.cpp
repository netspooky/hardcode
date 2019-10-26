// -------------------------------------------------------------------------------------
// File:        DECirculos.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DECirculos.h"

#include "vectors.h"
#include "DisplayDevice.h"
#include "RenderContext.h"
#include "StdDisplayMaterials.h"
#include "DisplayVertex.h"
#include <d3d8.h>

#define NSIDES  90
#define NVERTS  (NSIDES*2)
#define NIDX    (NSIDES*2+2)
#define R0      40
#define R1      45

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDECirculos::Init  (CDisplayDevice *pDev)
{
  End();

  if (RET_OK != m_mesh.Init(pDev, DV_FVF_VERTEX, NVERTS, NIDX, sizeof(TVertex)))
    return RET_FAIL;
  inherited::Init(pDev);

  bool bOk = false;

  TVertex *pv = (TVertex *)m_mesh.LockVB();
  word *pi = m_mesh.LockIB();

  if (pv && pi)
  {
    for (int i = 0; i < NSIDES; i++)
    {
      float k = PI*i*2/NSIDES;

      float x0 = R0*cosf(k);
      float x1 = R1*cosf(k);
      float z0 = R0*sinf(k);
      float z1 = R1*sinf(k);

      pv[2*i  ].Set(x0, 0, z0, 0, 1, 0);
      pv[2*i+1].Set(x1, 0, z1, 0, 1, 0);
    }
    for (i = 0; i < NSIDES+1; i++)
    {
      pi[2*i  ] = (2*i  )%NVERTS;
      pi[2*i+1] = (2*i+1)%NVERTS;
    }
    bOk = true;
  }
  m_mesh.UnlockVB();
  m_mesh.UnlockIB();

  if (!bOk)
  {
    End();
    return RET_FAIL;
  }

  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CDECirculos::End  ()
{
  if (IsOk())
  {
    m_mesh.End();
    inherited::End();
  }
}


// --------------------------------------------------------------------------
// Function:      Draw
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool  CDECirculos::Run         (int time)
{
  inherited::Run(time);

  return true;
}

// --------------------------------------------------------------------------
// Function:      Draw
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDECirculos::Draw        (CRenderContext &rc) const
{
  if (!IsOk())
    return;

  TMatrix3 vm;
  TMatrix3 wm;

  vm.SetRotationXY(-0.8f, 0);
  vm.ZeroTranslation();
  TVector3 vPos = TVector3(0, 0, -130) * vm;

  vm.SetLookAt(vPos, TVector3(0, 35, 0), TVector3(0, 1, 0));
  m_pDev->SetViewTransform(vm);

  CStdDisplayMaterial mat(m_pDev, SDMF_COLOR_DIFFUSE);
  mat.Set(m_pDev);

  m_pDev->SetRS (D3DRS_LIGHTING, TRUE);
  m_pDev->SetRS (D3DRS_CULLMODE, D3DCULL_NONE);


  static D3DMATERIAL8 d3dMat =
  {
    { 1.f, 1.f, .0f, 1 },
    { .0f, .1f, .2f, 1 },
    { 1, 1, 1, 1 },
    { 0, 0, 0, 0 },
    .5f
  };
  m_pDev->GetDirect3DDevice()->SetMaterial(&d3dMat);


  static D3DLIGHT8 l =
  {
    D3DLIGHT_POINT,
    { 1, 1, 1, 1 },
    { 1, 1, 1, 1 },
    { 1, 1, 1, 1 },
    { -60, 0, -60},
    { 1, 1, 1},   // bah
    10000.f,
    1.f,
    1, 0, 0,
    0,
    0
  };
  m_pDev->GetDirect3DDevice()->SetLight(0, &l);
  m_pDev->GetDirect3DDevice()->LightEnable(0, TRUE);

  m_mesh.SetDraw(m_pDev);

  for (int i = 0; i < 10; i++)
  {
    float y = .0007f*(m_curTime + 30*i);
    TMatrix3 k;

    k.SetTranslation(0, 0, 0);
    k.SetRotationZ(18.f*y);

    wm.SetRotationXY(12.3f*y, 23.7f*y);
    wm.SetTranslation(0, 0+8.f*i, 0);
    float f = .2f*(.5f+i);

    wm = k*wm;
    k.SetScale(f, 1, f);
    m_pDev->SetWorldTransform(k*wm);
    m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_TRIANGLESTRIP, 0, NVERTS, 0, NVERTS);
  }

  m_pDev->SetRS (D3DRS_LIGHTING, FALSE);
  m_pDev->SetRS (D3DRS_CULLMODE, D3DCULL_CCW);
}
