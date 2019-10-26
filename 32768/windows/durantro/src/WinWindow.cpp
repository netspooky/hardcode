// -------------------------------------------------------------------------------------
// File:        WinWindow.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "WinWindow.h"
#include <windows.h>

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

static CWinWindow *s_pInitWindow = NULL;

static const char APP_WND_CLASS_NAME[] = "WinWindow";

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CWinWindow::MessagePump (bool bWait)
{
  bool bRetVal = true;
  MSG  msg;

  // Wait until input has arrived
  if (bWait)
    WaitMessage();

  // Process all pending input until WM_QUIT
  while (bRetVal && PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
    if (msg.message == WM_QUIT)
      bRetVal = false;
  }
  return bRetVal;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
unsigned CWinWindow::WinProc   (unsigned hwnd, unsigned msg, unsigned wParam, unsigned lParam)
{
  // Restore outstanding window creations.
  // NOT reentrant, I don't think you would want it to be anyway.
  if (s_pInitWindow)
  {
    // Assign the window handle to the window pointer so the object is completely initialized
    // and functional during the WM_CREATE & associated creation messages 
    s_pInitWindow->m_hwnd = (unsigned)hwnd;
    ::SetWindowLong((HWND)hwnd, GWL_USERDATA, (unsigned)s_pInitWindow);
    s_pInitWindow = NULL;
  }

  // Retrieve CWinWindow ptr and redirect them the message.
  CWinWindow *pWindow = (CWinWindow *)::GetWindowLong((HWND)hwnd, GWL_USERDATA);
  bool bHandled = false;
  unsigned result = 0;

  if (pWindow && pWindow->m_pHandler)
    bHandled = pWindow->m_pHandler->MsgProc(pWindow, msg, wParam, lParam, result);

  // Handle the window destruction.
  if (pWindow && msg == WM_DESTROY)
  {
    pWindow->m_bDestroying = true;
    pWindow->End();
    ::SetWindowLong((HWND)hwnd, GWL_USERDATA, 0);
  }

  if (!bHandled)
    return ::DefWindowProc((HWND)hwnd, msg, wParam, lParam);
  return result;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CWinWindow::Init    (const char *pszTitle, IMsgHandler *pHandler)
{
  return Init(pszTitle, WS_OVERLAPPEDWINDOW | WS_VISIBLE, pHandler);
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CWinWindow::Init    (const char *pszTitle, unsigned style, IMsgHandler *pHandler)
{
  return Init(pszTitle, style, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, pHandler);
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CWinWindow::Init    (const char *pszTitle, unsigned style, int x, int y, int w, int h, IMsgHandler *pHandler)
{
  End();

  WNDCLASS    wc;

  wc.style         = CS_HREDRAW | CS_VREDRAW;
  wc.lpfnWndProc   = (WNDPROC)WinProc;
  wc.cbClsExtra    = 0;
  wc.cbWndExtra    = 0;
  wc.hInstance     = HINSTANCE(::GetModuleHandle(NULL));
  wc.hIcon         = 0;
  wc.hCursor       = 0;
  wc.hbrBackground = 0;
  wc.lpszMenuName  = 0;
  wc.lpszClassName = APP_WND_CLASS_NAME;
  RegisterClass(&wc);

  m_bDestroying = false;
  m_pHandler = pHandler;

  s_pInitWindow = this;
  ::CreateWindow(APP_WND_CLASS_NAME, pszTitle, style, x, y, w, h, NULL, NULL, wc.hInstance, NULL);
  // m_hwnd will be assigned as part of the window creation message processing within CWinWindow::WinProc
  s_pInitWindow = NULL;

  if (m_hwnd)
  {
    ::ShowWindow((HWND)m_hwnd, SW_SHOW);
    ::UpdateWindow((HWND)m_hwnd);
    return true;
  }
  return false;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CWinWindow::End     ()
{
  // Reentrancy check, sometimes it just happens so we better protect.
  if (IsOk())
  {
    if (!m_bDestroying)
      ::DestroyWindow((HWND)m_hwnd);    // Force a call back to ourselves
    else
    {
      // Actual destruction.
      m_hwnd = 0;
    }
  }
}
