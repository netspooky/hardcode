#include "video.h"

HRESULT DDSurfaceClear(DWORD dwColor,LPDIRECTDRAWSURFACE7 pdds,RECT *rect){
    if(NULL == pdds)
        return E_POINTER;

    // Erase the background
    DDBLTFX ddbltfx;
    ZeroMemory(&ddbltfx, sizeof(ddbltfx));
    ddbltfx.dwSize      = sizeof(ddbltfx);
    ddbltfx.dwFillColor = dwColor;

    return pdds->Blt(rect, NULL, NULL, DDBLT_COLORFILL, &ddbltfx);
}

void FullScreenCenter(RECT *rect){
  if (FullScreen){
    if (ResizeToFullScreen){
      rect->top=0;
      rect->left=0;
      rect->right=DEMO_WIDTH;
      rect->bottom=DEMO_HEIGHT;
    }
    else {
      rect->left=(DEMO_WIDTH-DEMO_BB_WIDTH)/2;
      rect->top=(DEMO_HEIGHT-DEMO_BB_HEIGHT)/2;
      rect->right=rect->left+DEMO_BB_WIDTH;
      rect->bottom=rect->top+DEMO_BB_HEIGHT;
    }
  }
  else{
    rect->top=0;
    rect->left=0;
    rect->right=DEMO_BB_WIDTH;
    rect->bottom=DEMO_BB_HEIGHT;
  }
}

//VideoDevice
VideoDevice::VideoDevice() {
    v_pDD                = NULL;
    v_pddsFrontBuffer    = NULL;
    v_pddsBackBuffer     = NULL;
    this->width = this->height = 0;
    this->v_hWnd = NULL;
    this->v_bWindowed = 0;
}

VideoDevice::~VideoDevice() {
    DestroyObjects();
}

HRESULT VideoDevice::DestroyObjects() {
    SAFE_RELEASE(v_pddsBackBuffer);
    SAFE_RELEASE(v_pddsFrontBuffer);

    if(v_pDD)
        v_pDD->SetCooperativeLevel(v_hWnd, DDSCL_NORMAL);

    SAFE_RELEASE(v_pDD);
    ChangeDisplaySettings(NULL,0);
    return S_OK;
}

HRESULT VideoDevice::CreateFullScreen(HWND hWnd, DWORD dwWidth, DWORD dwHeight,
                                      DWORD dwBbWidth, DWORD dwBbHeight, DWORD dwBPP)
{
    HRESULT hr;

    // Cleanup anything from a previous call
    DestroyObjects();

    // DDraw stuff begins here
    if(FAILED(hr=DirectDrawCreateEx(NULL,(VOID**)&v_pDD,IID_IDirectDraw7,NULL)))
        return E_FAIL;

    // Set cooperative level
    hr = v_pDD->SetCooperativeLevel(hWnd,DDSCL_EXCLUSIVE|DDSCL_FULLSCREEN);
    if(FAILED(hr))
        return E_FAIL;

    // Set the display mode
    if(FAILED(v_pDD->SetDisplayMode(dwWidth,dwHeight,dwBPP,0,0)))
        return E_FAIL;

    DDSURFACEDESC2 ddsd;
    ZeroMemory( &ddsd, sizeof( ddsd ) );
    ddsd.dwSize         = sizeof( ddsd );
    ddsd.dwFlags        = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
    ddsd.ddsCaps.dwCaps    = DDSCAPS_COMPLEX|DDSCAPS_FLIP|DDSCAPS_PRIMARYSURFACE|DDSCAPS_SYSTEMMEMORY;
    ddsd.dwBackBufferCount = 1;

    DWORD a;
    //DDERR_GENERIC
    if(FAILED(a=v_pDD->CreateSurface(&ddsd, &v_pddsFrontBuffer, NULL)))
        return E_FAIL;
    
    DDSCAPS2 ddscaps;
    ZeroMemory(&ddscaps, sizeof(ddscaps));
    ddscaps.dwCaps = DDSCAPS_BACKBUFFER;
    v_pddsFrontBuffer->GetAttachedSurface(&ddscaps, &v_pddsBackBuffer);

    v_hWnd        = hWnd;
    v_bWindowed   = FALSE;
    v_bCenter     = TRUE;
	  x_ofset      = (dwWidth - dwBbWidth)>>1;
	  y_ofset      = (dwHeight - dwBbHeight)>>1;
    v_rcSrc.left  = v_rcSrc.top = 0;
    v_rcSrc.right = dwBbWidth;
    v_rcSrc.bottom = dwBbHeight;
    this->width    = dwBbWidth;
    this->height   = dwBbHeight;
    UpdateBounds();

    FullScreenCenter(&rect);
    return S_OK;
}

HRESULT VideoDevice::CreateWindowed(HWND hWnd, DWORD dwWidth, DWORD dwHeight, DWORD dwBPP) {
    HRESULT hr;

    // Cleanup anything from a previous call
    DestroyObjects();

    DEVMODE   dm;
    memset(&dm,0,sizeof(dm));		// Makes Sure Memory's Cleared
		dm.dmSize=sizeof(dm);
    dm.dmBitsPerPel = dwBPP;
    dm.dmFields = DM_BITSPERPEL;
    if(ChangeDisplaySettings(&dm,CDS_RESET)!=DISP_CHANGE_SUCCESSFUL) {
      return E_FAIL;
    }

    // DDraw stuff begins here
    if(FAILED(hr=DirectDrawCreateEx(NULL,(VOID**)&v_pDD,IID_IDirectDraw7,NULL)))
        return E_FAIL;

    // Set cooperative level
    hr = v_pDD->SetCooperativeLevel(hWnd, DDSCL_NORMAL);
    if(FAILED(hr))
        return E_FAIL;

    RECT  rcWork;
    RECT  rc;
//    DWORD dwStyle;

    // If we are still a WS_POPUP window we should convert to a normal app
    // window so we look like a windows app.
    //dwStyle  = GetWindowLong(hWnd,GWL_STYLE);
    //dwStyle &= ~WS_POPUP;
    //dwStyle |= WS_OVERLAPPED|WS_CAPTION|WS_THICKFRAME|WS_MINIMIZEBOX|WS_MAXIMIZEBOX;
    //SetWindowLong(hWnd, GWL_STYLE, dwStyle);

    SetRect(&rc, 0, 0, dwWidth, dwHeight);

    AdjustWindowRectEx(&rc, GetWindowLong(hWnd,GWL_STYLE), GetMenu(hWnd) != NULL,
                        GetWindowLong(hWnd,GWL_EXSTYLE));

    SetWindowPos(hWnd, NULL, 0, 0, rc.right-rc.left, rc.bottom-rc.top,
                  SWP_NOMOVE | SWP_NOZORDER | SWP_NOACTIVATE);


    SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                 SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE);

    //  Make sure our window does not hang outside of the work area
    SystemParametersInfo(SPI_GETWORKAREA, 0, &rcWork, 0);
    GetWindowRect(hWnd, &rc);
    if(rc.left < rcWork.left) rc.left = rcWork.left;
    if(rc.top  < rcWork.top)  rc.top  = rcWork.top;
    SetWindowPos(hWnd, NULL, rc.left, rc.top, 0, 0,
                  SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);

    LPDIRECTDRAWCLIPPER pcClipper;
    
    // Create the primary surface
    DDSURFACEDESC2 ddsd;
    ZeroMemory( &ddsd, sizeof( ddsd ) );
    ddsd.dwSize         = sizeof( ddsd );
    ddsd.dwFlags        = DDSD_CAPS;
    ddsd.ddsCaps.dwCaps    = DDSCAPS_PRIMARYSURFACE|DDSCAPS_SYSTEMMEMORY;
//    ddsd.ddsCaps.dwCaps = /*DDSCAPS_FLIP|DDSCAPS_FRONTBUFFER|*/DDSCAPS_PRIMARYSURFACE;

    DWORD a;
    //DDERR_GENERIC
    if(FAILED(a=v_pDD->CreateSurface(&ddsd, &v_pddsFrontBuffer, NULL)))
        return E_FAIL;
    
    // Create the backbuffer surface
    ddsd.dwFlags        = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
    ddsd.ddsCaps.dwCaps = DDSCAPS_SYSTEMMEMORY;
    ddsd.dwWidth        = dwWidth;
    ddsd.dwHeight       = dwHeight;

    if(FAILED(hr = v_pDD->CreateSurface(&ddsd, &v_pddsBackBuffer, NULL)))
        return E_FAIL;


    if(FAILED(hr = v_pDD->CreateClipper(0, &pcClipper, NULL)))
        return E_FAIL;

    if(FAILED(hr = pcClipper->SetHWnd(0, hWnd))) {
        pcClipper->Release();
        return E_FAIL;
    }

    if(FAILED(hr = v_pddsFrontBuffer->SetClipper(pcClipper))) {
        pcClipper->Release();
        return E_FAIL;
    }

    // Done with clipper
    pcClipper->Release();
//    CalcBPPs(v_pddsBackBuffer);
    
    v_hWnd      = hWnd;
    v_bWindowed = TRUE;
    v_bCenter   = TRUE;
	  x_ofset    = 0;
	  y_ofset    = 0;
    
    v_rcSrc.left  = v_rcSrc.top = 0;
    v_rcSrc.right = dwWidth;
    v_rcSrc.bottom = dwHeight;
    this->width    = dwWidth;
    this->height   = dwHeight;
    UpdateBounds();
    FullScreenCenter(&rect);

    return S_OK;
}

HRESULT VideoDevice::UpdateBounds() {
#ifdef _DEBUG
  if(!Exist())
    return E_FAIL;
#endif
  if(v_bWindowed) {
    GetClientRect(v_hWnd, &v_rcWindow );
    ClientToScreen(v_hWnd, (POINT*)&v_rcWindow );
    ClientToScreen(v_hWnd, (POINT*)&v_rcWindow+1 );
  }
  else {
    SetRect(&v_rcWindow, 0, 0, GetSystemMetrics(SM_CXSCREEN),
            GetSystemMetrics(SM_CYSCREEN));
  }

  return S_OK;
}

/*HRESULT VideoDevice::InitClipper()
{
    LPDIRECTDRAWCLIPPER pClipper;
    HRESULT hr;

    // Create a clipper when using GDI to draw on the primary surface 
    if(FAILED(hr = v_pDD->CreateClipper(0, &pClipper, NULL)))
        return hr;

    pClipper->SetHWnd(0, v_hWnd);

    if(FAILED(hr = v_pddsFrontBuffer->SetClipper(pClipper)))
        return hr;

    // We can release the clipper now since g_pDDSPrimary 
    // now maintains a ref count on the clipper
    SAFE_RELEASE(pClipper);

    return S_OK;
}*/

/*HRESULT VideoDevice::Clear(DWORD dwColor) {
    if(NULL == v_pddsBackBuffer)
        return E_POINTER;

    // Erase the background
    DDBLTFX ddbltfx;
    ZeroMemory(&ddbltfx, sizeof(ddbltfx));
    ddbltfx.dwSize      = sizeof(ddbltfx);
    ddbltfx.dwFillColor = dwColor;

    return v_pddsBackBuffer->Blt(NULL, NULL, NULL, DDBLT_COLORFILL, &ddbltfx);
}*/

HRESULT VideoDevice::Show(DWORD dwWait) {
  if(v_pddsBackBuffer == NULL)
    return E_POINTER;

  if(this->v_bWindowed) {
    do {}
    while (this->v_pDD->WaitForVerticalBlank(DDWAITVB_BLOCKEND,NULL)==DDERR_WASSTILLDRAWING);
    DWORD a=v_pddsFrontBuffer->Blt(&v_rcWindow, v_pddsBackBuffer,&v_rcSrc, dwWait,NULL);
    return a;
  }
  else {
    return this->v_pddsFrontBuffer->Flip(NULL,0);
  }
}

BOOL VideoDevice::Exist() {

    if((v_pDD == NULL)||(v_pddsFrontBuffer==NULL)||(v_pddsBackBuffer==NULL))
        return FALSE;
    return TRUE;
}

