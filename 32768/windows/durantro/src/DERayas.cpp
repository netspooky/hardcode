// -------------------------------------------------------------------------------------
// File:        DERayas.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DERayas.h"

#include "vectors.h"
#include "DisplayDevice.h"
#include "RenderContext.h"
#include "DisplayVertex.h"
#include <d3d8.h>



// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

void CDERayas::FillRayas(TVector3 (*paaRayas)[2])
{
  for (int i = 0; i < MAX_RAYAS; i++)
  {
#define R float((rand() % 100)-50)
    float x0 = R;
    float y0 = R;
    float z0 = R;
    float x1 = R;
    float y1 = R;
    float z1 = R;
#undef R
    paaRayas[i][0] = TVector3(x0, y0, z0);
    paaRayas[i][1] = TVector3(x1, y1, z1);
  }
}

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDERayas::Init  (CDisplayDevice *pDev, int mode)
{
  End();

  if (RET_OK != m_mesh.Init(pDev, DV_FVF_LVERTEX, MAX_RAYAS*2, MAX_RAYAS*2, sizeof(TLVertex)))
    return RET_FAIL;

  word *pi = m_mesh.LockIB();
  if (!pi)
  {
    m_mesh.End();
    return RET_FAIL;
  }
  for (int i = 0; i < 2*MAX_RAYAS; i++)
    pi[i] = i;
  m_mesh.UnlockIB();

  inherited::Init(pDev);

  m_mode = mode;
  m_transitionFactor = 0;
  m_transitionSpeed = .002f;

  m_indiceFlower = 0;
  m_indiceTunel  = 0;
  memset(m_aRayas, 0, sizeof(m_aRayas));
  FillRayas(m_aDestRayas);
  for (i = 0; i < MAX_RAYAS; i++)
    m_aColors[i] = 0xFF404000 | (((rand() << 8) ^ rand()) & 0x7F7F3F);

  //  view matrix setup
  m_ViewMatrix.SetRotationXY(-0.8f, 0);
  m_ViewMatrix.ZeroTranslation();
  TVector3 vPos = TVector3(0, 0, -130) * m_ViewMatrix;
  m_ViewMatrix.SetLookAt(vPos, TVector3(0, 35, 0), TVector3(0, 1, 0));

  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CDERayas::End  ()
{
  if (IsOk())
  {
    m_mesh.End();
    inherited::End();
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  CDERayas::haz_morph()
{
  TLVertex *pv = (TLVertex *)m_mesh.LockVB();
  if (!pv)
    return;

  float x0,y0,z0,x1,y1,z1;
  for (int i = 0; i < MAX_RAYAS; i++)
  {
    float k = (sinf(Min(1.f, m_transitionFactor)*PI-PI/2)+1)/2;
    x0 = pv[i*2+0].x = Lerp(m_aRayas[i][0].x, m_aDestRayas[i][0].x, k);
    y0 = pv[i*2+0].y = Lerp(m_aRayas[i][0].y, m_aDestRayas[i][0].y, k);
    z0 = pv[i*2+0].z = Lerp(m_aRayas[i][0].z, m_aDestRayas[i][0].z, k);
    pv[i*2+0].c = m_aColors[i];
    x1 = pv[i*2+1].x = Lerp(m_aRayas[i][1].x, m_aDestRayas[i][1].x, k);
    y1 = pv[i*2+1].y = Lerp(m_aRayas[i][1].y, m_aDestRayas[i][1].y, k);
    z1 = pv[i*2+1].z = Lerp(m_aRayas[i][1].z, m_aDestRayas[i][1].z, k);
    pv[i*2+1].c = m_aColors[i];

//    m_aRayas[i][0] = TVector3(x0, y0, z0);
//    m_aRayas[i][1] = TVector3(x1, y1, z1);
  }
  m_mesh.UnlockVB();
}
 
// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDERayas::run_tunel (void)
{
  //  selecionamos linea
  m_indiceTunel = m_indiceTunel + int(MAX_RAYAS*m_delta/150);
  
  if(m_indiceTunel>MAX_RAYAS)
    m_indiceTunel = MAX_RAYAS;
  //  lanzamos linea

  //  avanzamos linea
  for(int n=0;n<m_indiceTunel;++n)
  {
    TVector3  vCam(m_ViewMatrix.m[0][2], m_ViewMatrix.m[1][2], m_ViewMatrix.m[2][2]);
    m_aDestRayas[n][0] -= vCam*5;
    m_aDestRayas[n][1] -= vCam*5;
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------

struct TFlowerParms
{
  float speeda;
  int   distv;
  float rad;
  float radr;
  float radz;
  float factz0;
  float factz1;
  float factk;
  float facti;
};


static const TFlowerParms s_FlowerParms[]=
{
///////////////////////////////////////////////////////////////////////////////
//  speeda    distv   rad     radr    radz    factz0  factz1  factk   facti  //
  { .1f      ,200    ,50.f   ,30.f   ,10.f   ,1.7f   ,1.3f   ,.7f    ,.03f  } , 
  { .13f     ,200    ,50.f   ,40.f   ,20.f   ,1.7f   ,1.3f   ,.7f    ,.02f  } ,
  { .93f     ,200    ,50.f   ,20.f   ,5.f    ,1.0f   ,1.0f   ,.7f    ,.02f  } ,
};

#define SPEEDA  (s_FlowerParms[m_indiceFlower].speeda)
#define DISTV   (s_FlowerParms[m_indiceFlower].distv) 
#define RAD     (s_FlowerParms[m_indiceFlower].rad)
#define RADR    (s_FlowerParms[m_indiceFlower].radr)
#define RADZ    (s_FlowerParms[m_indiceFlower].radz)
#define FACTZ0  (s_FlowerParms[m_indiceFlower].factz0)
#define FACTZ1  (s_FlowerParms[m_indiceFlower].factz1)
#define FACTK   (s_FlowerParms[m_indiceFlower].factk)
#define FACTI   (s_FlowerParms[m_indiceFlower].facti)

void CDERayas::run_flower (void)
{
  float k = .01f*m_curTime;
  for (int i = 0; i < MAX_RAYAS; i++)
  {
    float x0, y0, z0, x1, y1, z1;
    float a0 = k + SPEEDA*i;
    float a1 = k + SPEEDA*(i+DISTV);

    float r = RAD*cosf(a0);

    float r0 = r + RADR*sinf(a0);
          z0 = RADZ*cosf(a0*FACTZ0);
    float r1 = r + RADR*sinf(a1);
          z1 = RADZ*cosf(a1*FACTZ1);

    float g = FACTK*k + FACTI*i;
    x0 = r0*cosf(g);
    x1 = r1*cosf(g);
    y0 = r0*sinf(g);
    y1 = r1*sinf(g);
    m_aDestRayas[i][0].x = x0;
    m_aDestRayas[i][0].y = y0;
    m_aDestRayas[i][0].z = z0;
    m_aDestRayas[i][1].x = x1;
    m_aDestRayas[i][1].y = y1;
    m_aDestRayas[i][1].z = z1;
  }
}

// --------------------------------------------------------------------------
// Function:      Run
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool  CDERayas::Run         (int time)
{
  if (!IsOk())
    return false;

  inherited::Run(time);

  bool bChangeEfect = false;
  int fi = int(m_transitionFactor);
  m_transitionFactor += m_transitionSpeed*m_delta;
  switch(m_mode)
  {
  case MODE_FIJO:
    if (m_transitionFactor > 1.3f)
      bChangeEfect = true;
    break;
  case MODE_FLOWER:
    if (m_transitionFactor > 2.f)
      bChangeEfect = true;
    break;
  case MODE_TUNEL:
    if (m_transitionFactor > 1.f)
      bChangeEfect = true;
    break;

  default:
    bChangeEfect = (fi != int(m_transitionFactor));
    break;
  }

  if (bChangeEfect)
  {
    // selecionar mnuevo modo
    int newMode = rand()%MODE_LAST;

    // decidir si transition factor
    if(true)//;newMode!=m_mode)
    {
      memcpy(m_aRayas, m_aDestRayas, sizeof(m_aRayas));
      switch(newMode)
      {
      case MODE_FIJO:
        m_transitionFactor = .0f;
        FillRayas(m_aDestRayas);
        if(m_mode==MODE_FLOWER)
          m_transitionSpeed = .002f;
        else
          m_transitionSpeed = .002f;
        break;
      case MODE_FLOWER:
        m_transitionFactor = 0.f;
        m_indiceFlower++;
        if(m_indiceFlower>=ARRAY_LEN(s_FlowerParms))
          m_indiceFlower = 0;
        if(m_mode==MODE_FLOWER)
          m_transitionSpeed = .002f;
        else
          m_transitionSpeed = .002f;
        break;
      case MODE_TUNEL:
        m_transitionFactor = 0.5f;
        m_indiceTunel = 0;
        m_transitionSpeed = .002f;
        break;
      }
    }
    m_mode = newMode;
  }

  ////////  RUN SUB_EFECTOS
  switch(m_mode)
  {
  case MODE_FIJO:
    break;
  case MODE_FLOWER:
    run_flower();
    break;
  case MODE_TUNEL:
    run_tunel();
    break;
  }

  //// morph de efecto
  haz_morph();

  return true;
}

// --------------------------------------------------------------------------
// Function:      Draw
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDERayas::Draw        (CRenderContext &rc) const
{
  if (!IsOk())
    return;

  TMatrix3 wm;

  m_pDev->SetViewTransform(m_ViewMatrix);

  float y = .0007f*m_curTime;

  CStdDisplayMaterial mat(m_pDev, SDMF_COLOR_DIFFUSE);
  mat.Set(m_pDev);

  // Override vertex colors with the shadow color (all goes to emissive).
  m_pDev->SetRS (D3DRS_LIGHTING, TRUE);

  static D3DMATERIAL8 d3dMat =
  {
    { 0, 0, 0, 1 },
    { 0, 0, 0, 1 },
    { 1, 1, 1, 1 },
    { 8.f/255, 16.f/255, 32.f/255, 1 },
//    { 0, 0, 0, 1 }, // Pure black
    0
  };
  m_pDev->GetDirect3DDevice()->SetMaterial(&d3dMat);
  m_pDev->GetDirect3DDevice()->LightEnable(0, FALSE);

  m_mesh.SetDraw(m_pDev);

  m_pDev->SetRS(D3DRS_ZWRITEENABLE, FALSE);

  wm.SetRotationXY(2.3f*y, y);
  wm.m[0][1] = 0;
  wm.m[1][1] = 0;
  wm.m[2][1] = 0;
  wm.m[1][0] *= 3.1f;
  wm.SetTranslation(0, 0, -40);
  m_pDev->SetWorldTransform(wm);

  switch(m_mode)
  {
    case MODE_FIJO:
    case MODE_FLOWER:
      m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_LINELIST, 0, MAX_RAYAS*2, 0, MAX_RAYAS);
      break;
    case MODE_TUNEL:
      // Solo las lineas girando
      m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_LINELIST, m_indiceTunel*2, (MAX_RAYAS-m_indiceTunel)*2, m_indiceTunel*2, MAX_RAYAS-m_indiceTunel);
      break;
  }
  m_pDev->SetRS(D3DRS_ZWRITEENABLE, TRUE);

  m_pDev->SetRS (D3DRS_LIGHTING, FALSE);

  mat.SetFlags(m_pDev, SDMF_COLOR_DIFFUSE | SDMF_BLEND_ADD);
  mat.Set(m_pDev);
  
  wm.SetTranslation(0, 90, 0);
  int startLast = 0;
  switch(m_mode)
  {
  case MODE_FIJO:
  case MODE_FLOWER:
    break;
  case MODE_TUNEL:
    //  lineas acercandose
    wm.SetRotationXY(0, 0);
    m_pDev->SetWorldTransform(wm);
    m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_LINELIST, 0, m_indiceTunel*2, 0, m_indiceTunel);
    // lineas girando
    startLast = m_indiceTunel;
    break;
  }
  wm.SetRotationXY(2.3f*y, y);
  m_pDev->SetWorldTransform(wm);
  m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_LINELIST, 0, MAX_RAYAS*2, 0, MAX_RAYAS);
  m_pDev->GetDirect3DDevice()->DrawIndexedPrimitive(D3DPT_LINELIST, startLast*2, (MAX_RAYAS-startLast)*2, startLast*2, MAX_RAYAS-startLast);
}
