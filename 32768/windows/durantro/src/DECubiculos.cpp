// -------------------------------------------------------------------------------------
// File:        DECubiculos.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DECubiculos.h"

#include "vectors.h"
#include "DisplayDevice.h"
#include "RenderContext.h"
#include "StdDisplayMaterials.h"
#include "DisplayVertex.h"
#include <d3d8.h>

#define NQUADS   6
#define NVERTS  (3*2*NQUADS)
#define NIDX    (1)
#define SC      30

static TVector3 s_av[] =
{
  TVector3(0, 0, 0), TVector3(0, 0, 1), TVector3(0, 1, 0), TVector3(0, 1, 0), TVector3(0, 0, 1), TVector3(0, 1, 1), 
  TVector3(1, 0, 0), TVector3(1, 1, 0), TVector3(1, 0, 1), TVector3(1, 0, 1), TVector3(1, 1, 0), TVector3(1, 1, 1), 

  TVector3(0, 0, 0), TVector3(1, 0, 0), TVector3(0, 0, 1), TVector3(0, 0, 1), TVector3(1, 0, 0), TVector3(1, 0, 1), 
  TVector3(0, 1, 0), TVector3(0, 1, 1), TVector3(1, 1, 0), TVector3(1, 1, 0), TVector3(0, 1, 1), TVector3(1, 1, 1), 
  
  TVector3(0, 0, 0), TVector3(0, 1, 0), TVector3(1, 0, 0), TVector3(1, 0, 0), TVector3(0, 1, 0), TVector3(1, 1, 0), 
  TVector3(0, 0, 1), TVector3(1, 0, 1), TVector3(0, 1, 1), TVector3(0, 1, 1), TVector3(1, 0, 1), TVector3(1, 1, 1), 
};

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDECubiculos::Init  (CDisplayDevice *pDev)
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
    for (int i = 0; i < NQUADS; i++)
    {
      TVector3 vn(0, 0, 0);
      ((float*)&vn)[i/2] = (i&1)? 1.f : -1.f;

      for (int j = 0; j < 3*2; j++)
        pv[i*3*2+j].Set(s_av[i*3*2+j].x*SC, s_av[i*3*2+j].y*SC, s_av[i*3*2+j].z*SC, vn.x, vn.y, vn.z);
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
void CDECubiculos::End  ()
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
bool  CDECubiculos::Run         (int time)
{
  inherited::Run(time);

  return true;
}

// --------------------------------------------------------------------------
// Function:      Draw
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDECubiculos::Draw        (CRenderContext &rc) const
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

  CStdDisplayMaterial mat(m_pDev, SDMF_COLOR_DIFFUSE | SDMF_BLEND_ALPHA);
  mat.Set(m_pDev);

  m_pDev->SetRS (D3DRS_LIGHTING, TRUE);
//  m_pDev->SetRS (D3DRS_CULLMODE, D3DCULL_NONE);

  static D3DMATERIAL8 d3dMat =
  {
    { .0f, .6f, .6f, .5f },
    { .0f, .3f, .6f, .5f },
    { 1, 1, 1, .5f },
    { 0, 0, 0, 0 },
    4.f
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

  float distancia= 300.f - (300.0f*m_curTime/1700.0f);
  if(distancia<.0f)
    distancia =.0f;

#define NX 22
#define NY 10
  for (int j = NY-1; j >= 0; j--)
    for (int i = 0; i < NX; i++)
    {
      float y = .0007f*(m_curTime + 30*i + 3*j);
      TMatrix3 k;
      k.ZeroTranslation();

      k.SetTranslation(i, 15.f*cosf(5.f*y), j);
      k.SetRotationZ(18.f*y);

      wm.SetRotationXY(12.3f*y, 23.7f*y);
//      wm.SetTranslation(i, 0+8.f*i, j);
      wm.SetTranslation(i*SC-((SC-1)*NX/2), 15.f*cosf(5.f*y)-60, j*SC-((SC-1)*NY/2) - distancia);

      wm = k*wm;
      float f = .2f*(.5f+i);
//      k.SetScale(SC, SC, SC);
//      m_pDev->SetWorldTransform(k*wm);
      m_pDev->SetWorldTransform(wm);
      m_pDev->GetDirect3DDevice()->DrawPrimitive(D3DPT_TRIANGLELIST, 0, NQUADS*2);
    }

  m_pDev->SetRS (D3DRS_LIGHTING, FALSE);
//  m_pDev->SetRS (D3DRS_CULLMODE, D3DCULL_CCW);
}
