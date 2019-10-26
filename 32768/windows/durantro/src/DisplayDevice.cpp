// -------------------------------------------------------------------------------------
// File:        DisplayDevice.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DisplayDevice.h"
#include "WinWindow.h"
#include "ProjectionViewport.h"
#include "vectors.h"

#include <d3d8.h>

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDisplayDevice::Init  (CWinWindow *pWindow)
{
  End();
  m_pD3D    = ::Direct3DCreate8(D3D_SDK_VERSION);
  if (!m_pD3D)
    return RET_FAIL;

  m_flags = 0;
  m_pDevice = NULL;
  ZeroMem(&m_mode, sizeof(m_mode));
  ZeroMem(&m_newMode, sizeof(m_newMode));
  m_desktopFormat = FindDesktopFormat();

  m_pWindow = pWindow;

  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CDisplayDevice::End  ()
{
  if (IsOk())
  {
    Shutdown();
    m_pD3D->Release();
    m_pWindow = NULL;
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
TError CDisplayDevice::SetDisplayMode    (int w, int h, int bpp, bool bFullscreen, unsigned wantFlags)
{
  if (!IsAvailable())
    return RET_FAIL;

  if (bFullscreen)
    wantFlags |= F_WANT_FULLSCREEN;
  else
    wantFlags &= ~F_WANT_FULLSCREEN;

  m_newMode.w = w;
  m_newMode.h = h;
  m_newMode.bpp = bpp;
  m_newMode.flags = wantFlags;

  if (RET_OK != Restore())
    return RET_FAIL;

  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDisplayDevice::Shutdown          ()
{
  if (IsAvailable())
  {
    if (m_pDevice)
      m_pDevice->Release();
    m_pDevice = NULL;
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
TError CDisplayDevice::Restore           ()
{
  if (!IsAvailable())
    return RET_FAIL;

  // If the window is gone, bail out
  if (!m_pWindow->IsOk())
    return RET_FAIL;

  // If the device is not ours to play with, don't even try.
  if (m_pDevice && m_pDevice->TestCooperativeLevel() == D3DERR_DEVICELOST)
    return RET_FAIL;

  // Find out the most up-to-date desktop format in case we're going windowed.
  // Only do so if we're not ok or we're windowed already.
  if (!m_pDevice || !(m_mode.IsFS()))
    m_desktopFormat = FindDesktopFormat();

  m_mode = m_newMode;

  D3DPRESENT_PARAMETERS pp;

  pp.BackBufferWidth  = m_newMode.w;
  pp.BackBufferHeight = m_newMode.h;
  pp.BackBufferFormat = D3DFORMAT(m_newMode.IsFS()? FindBackbufferFormat(m_newMode.bpp) : m_desktopFormat);
  pp.BackBufferCount  = 1;

  pp.SwapEffect       = m_newMode.IsNoDiscard()? D3DSWAPEFFECT_COPY : D3DSWAPEFFECT_DISCARD;

  pp.hDeviceWindow    = 0;
  pp.Windowed         = !m_newMode.IsFS();
  
  pp.EnableAutoDepthStencil = m_newMode.IsDB();
  pp.AutoDepthStencilFormat = D3DFORMAT(m_newMode.IsDB()? FindDepthbufferFormat(pp.BackBufferFormat, m_newMode.flags) : D3DFMT_UNKNOWN);
  
  pp.Flags = 0;
  pp.FullScreen_RefreshRateInHz       = D3DPRESENT_RATE_DEFAULT;
  pp.FullScreen_PresentationInterval  = m_newMode.IsFS()? D3DPRESENT_INTERVAL_ONE : D3DPRESENT_INTERVAL_DEFAULT ;

  bool bMultisample = m_newMode.IsFSAA();
  if (bMultisample)
    bMultisample = SUCCEEDED(m_pD3D->CheckDeviceMultiSampleType(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL,
                             pp.BackBufferFormat, pp.Windowed, D3DMULTISAMPLE_4_SAMPLES));
  if (bMultisample && pp.EnableAutoDepthStencil)
    bMultisample = SUCCEEDED(m_pD3D->CheckDeviceMultiSampleType(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL,
                             pp.AutoDepthStencilFormat, pp.Windowed, D3DMULTISAMPLE_4_SAMPLES));
  if (bMultisample)
    pp.MultiSampleType  = D3DMULTISAMPLE_4_SAMPLES;
  else
  {
    pp.MultiSampleType  = D3DMULTISAMPLE_NONE;
    m_mode.flags &= ~F_WANT_FSAA;
  }

  HRESULT hr;

  // Perform the Display (re)Initializatiom
  m_flags |= F_INRESET;
  if (!m_pDevice)
//    hr = m_pD3D->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, (HWND)m_pWindow->GetHwnd(), D3DCREATE_MIXED_VERTEXPROCESSING, &pp, &m_pDevice);
    hr = m_pD3D->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, (HWND)m_pWindow->GetHwnd(), D3DCREATE_SOFTWARE_VERTEXPROCESSING, &pp, &m_pDevice);
  else
    hr = m_pDevice->Reset(&pp);

  // Reset the window size if success and windowed
  D3DCAPS8 caps;
  if (SUCCEEDED(hr))
    hr = m_pDevice->GetDeviceCaps(&caps);
  if (SUCCEEDED(hr))
  {
    m_maxTextureW = caps.MaxTextureWidth;
    m_maxTextureH = caps.MaxTextureHeight;
    if (m_pWindow->IsOk() && pp.Windowed)
    {
      HWND hwnd = (HWND)m_pWindow->GetHwnd();
      DWORD style = ::GetWindowLong(hwnd, GWL_STYLE);
      RECT r = { 0, 0, m_newMode.w, m_newMode.h };
      ::AdjustWindowRect(&r, style, (::GetMenu(hwnd) != NULL));
      ::SetWindowPos(hwnd, HWND_NOTOPMOST, 0, 0, r.right - r.left, r.bottom - r.top,
                     SWP_DRAWFRAME | SWP_FRAMECHANGED | SWP_NOACTIVATE | SWP_NOCOPYBITS | SWP_NOMOVE | SWP_NOOWNERZORDER | SWP_SHOWWINDOW);

    }
  }
  m_flags &= ~F_INRESET;

  // Maybe we failed.
  if (FAILED(hr))
  {
    GLOG(("ERROR: Restore 0x%08X\n", hr));
    if (m_pDevice)
      m_pDevice->Release();
    m_pDevice = NULL;
    return RET_FAIL;
  }

  // Everything went well, notify the managers we're back up.
  ResetMaterial();

  return RET_OK;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CDisplayDevice::IsDeviceReady     () const
{
  return IsAvailable() && m_pDevice && m_pDevice->TestCooperativeLevel() == D3D_OK;
}

// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
unsigned CDisplayDevice::FindDesktopFormat      () const
{
  D3DDISPLAYMODE dm;
  m_pD3D->GetAdapterDisplayMode(D3DADAPTER_DEFAULT, &dm);
  return dm.Format;
}


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
static struct
{
  D3DFORMAT fmt;
  int       bpp;
}
s_aBBFormats[] =
{
  { D3DFMT_X1R5G5B5,    16 },
  { D3DFMT_R5G6B5,      16 },
  { D3DFMT_X8R8G8B8,    32 },
  { D3DFMT_A8R8G8B8,    32 },
};

unsigned CDisplayDevice::FindBackbufferFormat   (int bpp) const
{
  int bestBpp = 0;
  D3DFORMAT bestFmt = D3DFMT_UNKNOWN;

  for (int i = 0; bestFmt == D3DFMT_UNKNOWN && i < ARRAY_LEN(s_aBBFormats); i++)
  {
    if (s_aBBFormats[i].bpp == bpp
        && !FAILED(m_pD3D->CheckDeviceType(D3DADAPTER_DEFAULT,
                                           D3DDEVTYPE_HAL,
                                           s_aBBFormats[i].fmt, s_aBBFormats[i].fmt,
                                           FALSE)))
    {
      bestFmt = s_aBBFormats[i].fmt;
      bestBpp = s_aBBFormats[i].bpp;
    }
  }
       
  GLOG(("FindBackbufferFormat found format %d\n", bestFmt));
  return bestFmt;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
static struct
{
  D3DFORMAT fmt;
  int       bpp;
  bool      bStencil;
}
s_aDBFormats[] =
{
  { D3DFMT_D15S1,       16, true  },
  { D3DFMT_D16,         16, false },
  { D3DFMT_D16_LOCKABLE,16, false },

  { D3DFMT_D24S8,       32, true  },
  { D3DFMT_D24X4S4,     32, true  },
  { D3DFMT_D32,         32, false },
  { D3DFMT_D24X8,       32, false},
};

unsigned CDisplayDevice::FindDepthbufferFormat  (unsigned backbufferFormat, unsigned flags) const
{
  int bestBpp = 0;
  D3DFORMAT bestFmt = D3DFMT_UNKNOWN;
  int displayBpp = FindFormatBpp(backbufferFormat);

  for (int i = 0; i < ARRAY_LEN(s_aDBFormats); i++)
  {
    // Verify that the depth format exists.
    if (!(flags & F_WANT_STENCIL) || s_aDBFormats[i].bStencil)
    {
      HRESULT hr = m_pD3D->CheckDeviceFormat( D3DADAPTER_DEFAULT,
                                              D3DDEVTYPE_HAL,
                                              (D3DFORMAT)backbufferFormat,
                                              D3DUSAGE_DEPTHSTENCIL,
                                              D3DRTYPE_SURFACE,
                                              s_aDBFormats[i].fmt);

      if (!FAILED(hr))
      {
        // Verify that the depth format is compatible.
        hr = m_pD3D->CheckDepthStencilMatch( D3DADAPTER_DEFAULT,
                                             D3DDEVTYPE_HAL,
                                             (D3DFORMAT)backbufferFormat,
                                             (D3DFORMAT)backbufferFormat,
                                             s_aDBFormats[i].fmt);
        if (!FAILED(hr))
        {
          if (bestBpp != displayBpp && bestBpp != s_aDBFormats[i].bpp)
          {
            bestBpp = s_aDBFormats[i].bpp;
            bestFmt = s_aDBFormats[i].fmt;
          }
        }
      }
    }
  }

  GLOG(("FindDepthbufferFormat found format %d\n", bestFmt));
  return bestFmt;
}

unsigned CDisplayDevice::FindFormatBpp (unsigned fmt) const
{
  for (int i = 0; i < ARRAY_LEN(s_aDBFormats); i++)
    if (s_aDBFormats[i].fmt == (D3DFORMAT)fmt)
      return s_aDBFormats[i].bpp;
  for (i = 0; i < ARRAY_LEN(s_aBBFormats); i++)
    if (s_aBBFormats[i].fmt == (D3DFORMAT)fmt)
      return s_aBBFormats[i].bpp;
    return D3DFMT_UNKNOWN;
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetViewport(int x, int y, int w, int h)
{
  if (IsAvailable() && m_pDevice != NULL)
  {
    // Set up the viewport data parameters
    DXN_D3DVIEWPORT vp;
    vp.X          = x;
    vp.Y          = y;
    vp.Width      = w;
    vp.Height     = h;
    vp.MinZ       = 0.0f;
    vp.MaxZ       = 1.0f;
    m_pDevice->SetViewport(&vp);
  }
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetProjection(float ivpw, float ivph, float Q, float zn)
{
  if (IsAvailable() && m_pDevice != NULL)
  {
    D3DMATRIX m;
    memset(&m, 0, sizeof(m));
    m._11 = ivpw;
    m._22 = ivph;
    m._33 = Q;
    m._43 = -zn*Q;
    m._34 = 1.f;

    m_pDevice->SetTransform(D3DTS_PROJECTION, &m);
  }
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetProjectionViewport(const TProjectionViewport *vp)
{
  SetViewport(vp->vx, vp->vy, vp->vw, vp->vh);
  SetProjection(vp->ivpw, vp->ivph, vp->Kz, vp->zn);
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetWorldTransform (const TMatrix3 &m)
{
  if (IsAvailable() && m_pDevice != NULL)
  {
    TMatrix4 m4;
    m.ToMatrix4(m4);
    m_pDevice->SetTransform(D3DTS_WORLD, (D3DMATRIX*)&m4);
  }
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetViewTransform  (const TMatrix3 &m)
{
  if (IsAvailable() && m_pDevice != NULL)
  {
    TMatrix4 m4;
    m.ToMatrix4(m4);
    m_pDevice->SetTransform(D3DTS_VIEW, (D3DMATRIX*)&m4);
  }
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetTexture        (int stage, DXN_Direct3DTexture *pTex)
{
  if (!IsAvailable() || m_pDevice == NULL || !pTex)
    return;
  m_pDevice->SetTexture(stage, pTex);
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::InternalSetRS           (unsigned rs, unsigned val)
{
  m_pDevice->SetRenderState((D3DRENDERSTATETYPE)rs, val);
  m_aRenderState[rs] = val;
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::InternalSetTSS          (int stage, unsigned tss, unsigned val)
{
  m_pDevice->SetTextureStageState(stage, (D3DTEXTURESTAGESTATETYPE)tss, val);
  m_aTextureStageState[stage][tss] = val;
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::SetFVFShader      (unsigned fvf)
{
  if (fvf != m_FVFShader)
  {
    m_pDevice->SetVertexShader(fvf);
    m_FVFShader = fvf;
  }
}

// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::ResetMaterial ()
{
  if (!IsAvailable() || m_pDevice == NULL)
    return;
  memset(m_aRenderState, -1, sizeof(m_aRenderState));
  memset(m_aTextureStageState, -1, sizeof(m_aTextureStageState));

  // Limpiar stagestates.
  for (int i = 0; i < MAXTEXTURESTAGES; i++)
  {
    InternalSetTSS(i, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
    InternalSetTSS(i, D3DTSS_COLOROP, D3DTOP_DISABLE);
  }
  m_pDevice->SetTextureStageState(MAXTEXTURESTAGES+1, D3DTSS_ALPHAOP, D3DTOP_DISABLE);
  m_pDevice->SetTextureStageState(MAXTEXTURESTAGES+1, D3DTSS_COLOROP, D3DTOP_DISABLE);

  // Estados que no van a cambiar.
  InternalSetTSS(0, D3DTSS_COLORARG2, D3DTA_DIFFUSE);
  InternalSetTSS(0, D3DTSS_ADDRESSU,   D3DTADDRESS_WRAP);
  InternalSetTSS(0, D3DTSS_ADDRESSV,   D3DTADDRESS_WRAP);
  InternalSetTSS(0, D3DTSS_ADDRESSW,   D3DTADDRESS_WRAP);
  InternalSetTSS(0, D3DTSS_ALPHAOP,   D3DTOP_MODULATE);
  InternalSetRS (D3DRS_DITHERENABLE,       TRUE);
  InternalSetRS (D3DRS_ALPHAREF,           0x01);
  InternalSetRS (D3DRS_ALPHAFUNC,          D3DCMP_GREATEREQUAL);
  InternalSetRS (D3DRS_ZFUNC,              D3DCMP_LESSEQUAL);

  // Estados de material que queremos tener por defecto.
  m_pDevice->SetTexture          (0, NULL);
  InternalSetTSS(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
  InternalSetTSS(0, D3DTSS_COLOROP,   D3DTOP_MODULATE);
  InternalSetTSS(0, D3DTSS_MINFILTER, D3DTEXF_LINEAR);
  InternalSetTSS(0, D3DTSS_MAGFILTER, D3DTEXF_LINEAR);
  InternalSetRS (D3DRS_SRCBLEND,           D3DBLEND_SRCALPHA);
  InternalSetRS (D3DRS_DESTBLEND,          D3DBLEND_INVSRCALPHA);
  InternalSetRS (D3DRS_SHADEMODE,          D3DSHADE_GOURAUD);
  InternalSetRS (D3DRS_SPECULARENABLE,     FALSE);
  InternalSetRS (D3DRS_ALPHATESTENABLE,    FALSE);
  InternalSetRS (D3DRS_ALPHABLENDENABLE,   FALSE);
  InternalSetRS (D3DRS_LIGHTING,           FALSE);
  InternalSetRS (D3DRS_SOFTWAREVERTEXPROCESSING, FALSE);

  InternalSetRS (D3DRS_COLORVERTEX , FALSE);
  InternalSetRS (D3DRS_AMBIENT , 0xFF303030);
  InternalSetRS (D3DRS_DIFFUSEMATERIALSOURCE,  D3DMCS_MATERIAL);
  InternalSetRS (D3DRS_SPECULARMATERIALSOURCE, D3DMCS_MATERIAL);
  InternalSetRS (D3DRS_EMISSIVEMATERIALSOURCE, D3DMCS_MATERIAL);
  InternalSetRS (D3DRS_SPECULARMATERIALSOURCE, D3DMCS_MATERIAL);

/* 
  DWORD nPasses = (uint)-1;
  HRESULT hRet = m_pDevice->ValidateDevice(&nPasses);
  if (FAILED(hRet))
    GLOG(("D3D: ValidateDevice() retorna 0x%X (%s) en %d pasos.\n", hRet, DXGetErrorString8(hRet), nPasses));
*/
}

// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::Clear(bool bColor, TColor color, bool bZBuffer, float depth, bool bStencil, int stValue)
{
  if (IsAvailable())
  {
    bZBuffer = bZBuffer || UsingZBuffer();
    bStencil = bStencil || UsingStencil();
    if (bColor || bZBuffer || bStencil)
    {
      unsigned flags = 0;
      if (bColor && (color >> 24) > 0)   flags |= D3DCLEAR_TARGET;
      if (bZBuffer) flags |= D3DCLEAR_ZBUFFER;
      if (bStencil) flags |= D3DCLEAR_STENCIL;
      GetDirect3DDevice()->Clear(0, NULL, flags, color, depth, stValue);
    }
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
TError CDisplayDevice::BeginFrame        ()
{
  if (!IsAvailable() || !m_pDevice)
    return RET_FAIL;

  // If the device is not ours to play with, don't even try.

  if (m_pDevice->TestCooperativeLevel() == D3DERR_DEVICENOTRESET)
    Restore();

  if (!IsDeviceReady())
    return RET_FAIL;

  HRESULT hr = m_pDevice->BeginScene();

  return (hr == D3D_OK)? RET_OK : RET_FAIL;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDisplayDevice::EndFrame          ()
{
  if (IsDeviceReady())
  {
    Flush();
    m_pDevice->EndScene();
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CDisplayDevice::Update            ()
{
  if (IsDeviceReady())
  {
    GLOG(("---- Present ----\n"));
    if (FAILED(m_pDevice->Present(NULL, NULL, NULL, NULL)))
    {
      GLOG(("Present Failed!?!?!\n"));
    }
  }
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::Flush             ()
{
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
bool CDisplayDevice::UsingHWTnL        () const
{
  return !m_aRenderState[D3DRS_SOFTWAREVERTEXPROCESSING];
}

//----------------------------------------------------------------------
//  Retorno:        
//  Parametros:     
//  Uso:            
//----------------------------------------------------------------------
void CDisplayDevice::EnableHWTnL       (bool bEnable)
{
  if (UsingHWTnL() ^ bEnable)
  {
    Flush();
    InternalSetRS(D3DRS_SOFTWAREVERTEXPROCESSING, !bEnable);
  }
}
