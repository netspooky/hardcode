// -------------------------------------------------------------------------------------
// File:        IntroMain.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include <d3d8.h>

#include "minifmod.h"
#include "WinWindow.h"

#include "vectors.h"
#include "DisplayDevice.h"
#include "RenderContext.h"

#include "DETextWriter.h"
#include "DERayas.h"
#include "DECirculos.h"
#include "DECubiculos.h"

#define MOTIONBLUR

// --------------------------------------------------------------------------
// Simplistic window message handler.
// This is a demo, we only need to capture ESC & cursor display.
// --------------------------------------------------------------------------
class CIntroHandler : public CWinWindow::IMsgHandler
{
    bool    m_bOk;
  public:
    CIntroHandler(): m_bOk(true) { }

    bool          IsOk  ()          const { return m_bOk; } 

    virtual bool MsgProc(CWinWindow *pWnd, unsigned msg, unsigned wParam, unsigned lParam, unsigned &result)
    {
      if (msg == WM_CHAR && wParam == '\033')
        m_bOk = false;
      else if (msg == WM_SETCURSOR)
      {
        ::SetCursor(NULL);
        result = true;
        return true;
      }
      return false;
    }
};


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void DoIntro    (CWinWindow &Win, FMUSIC_MODULE *mod)
{
  CDisplayDevice Dev;

  CLinkedList<CDemoEffect*> m_Lista;

  Dev.Init(&Win);

#ifdef MOTIONBLUR
#define DM_FLAGS (CDisplayDevice::F_WANT_ZBUFFER | CDisplayDevice::F_WANT_WBUFFER | CDisplayDevice::F_WANT_NODISCARD)
#else
#define DM_FLAGS (CDisplayDevice::F_WANT_ZBUFFER | CDisplayDevice::F_WANT_WBUFFER | CDisplayDevice::F_WANT_FSAA)
#endif

  TError ret = RET_OK;
#ifdef _DEBUG
  ret = Dev.SetDisplayMode(640, 480, 32, false, DM_FLAGS);
#else
  if (RET_OK != Dev.SetDisplayMode(640, 480, 32, true, DM_FLAGS))
    ret = Dev.SetDisplayMode(640, 480, 16, true, DM_FLAGS);
#endif

  if (RET_OK != ret)
  {
    Dev.End();
    BaseAlertf("Error, can't initialize the display!\n");
    return;
  }

  CIntroHandler Handler;
  CWinWindow::IMsgHandler *pOldHandler;
  pOldHandler = Win.GetHandler();
  Win.SetHandler(&Handler);
  ::ShowCursor(false);

  if (mod)
    FMUSIC_PlaySong(mod);

  // -----------------------------------------------
  CDERayas *pRayas = NEW(CDERayas);
//  pRayas->Init(&Dev, CDERayas::MODE_FIJO);
  pRayas->Init(&Dev, CDERayas::MODE_FLOWER);
  m_Lista.AddEnd(pRayas);

  CDECirculos *pCirculos = NEW(CDECirculos);
  pCirculos->Init(&Dev);
  m_Lista.AddEnd(pCirculos);

  CDECubiculos *pCubiculos = NEW(CDECubiculos);
  pCubiculos->Init(&Dev);
  m_Lista.AddEnd(pCubiculos);

  CDETextWriter *pWriter = NEW(CDETextWriter);
  pWriter->Init(&Dev);
  m_Lista.AddEnd(pWriter);

  pWriter->Activate();
  pCubiculos->Activate();
  // -----------------------------------------------

  int flash = 0;
  Dev.Clear(true, 0xFF000000);  // Clear both

  DWORD initTime = ::GetTickCount();

  while (Win.MessagePump(false) && Win.IsOk() && Handler.IsOk())
  {
    // Do stuff here
    DWORD time = ::GetTickCount();
    float act = float(time - initTime)/10;

    if (act > 1600 && !pRayas->IsActive())
    {
      flash = 255;
      pRayas->Activate();
    }

/*
    if (act > 4500 && !pCubiculos->IsActive())
    {
      flash = 255;
      pCubiculos->Activate();
    }
*/
    if (act > 4000 && !pCirculos->IsActive())
    {
      flash = 255;
      pCirculos->Activate();
    }

    // Advance the currently running effects
    {
      TLinkedListNode<CDemoEffect*> *pNode = m_Lista.GetHead();
      while (pNode)
      {
        TLinkedListNode<CDemoEffect*> *pNext = pNode->pNext;

        // Time passes...
        if (!pNode->t->IsOk() || (pNode->t->IsActive() && !pNode->t->Run((int)act)))
        {
          DISPOSE(pNode->t);
          m_Lista.Remove(pNode);
        }
        pNode = pNext;
      }
    }

    // Predraw the currently running effects
    {
      TLinkedListNode<CDemoEffect*> *pNode = m_Lista.GetHead();
      while (pNode)
      {
        if (pNode->t->IsActive())
          pNode->t->PreDraw();
        pNode = pNode->pNext;
      }
    }

    // Draw here.
    if (RET_OK == Dev.BeginFrame())
    {
#ifdef MOTIONBLUR
      if(pRayas->IsActive())
        Dev.Clear(false);             // Clear ZBuffer
      else
        Dev.Clear(true, 0xFF102030);  // Clear both
#else
      Dev.Clear(true, 0xFF102030);  // Clear both
#endif
      // Render here
      CRenderContext rc;
      rc.Init(&Dev, 0, 0, Dev.GetWidth(), Dev.GetHeight());

#ifdef MOTIONBLUR
      if(pRayas->IsActive())
      {
        Dev.SetRS(D3DRS_ZWRITEENABLE, FALSE);
        rc.FillRect(0, 0, 640, 480, 0x30102030);
        Dev.SetRS(D3DRS_ZWRITEENABLE, TRUE);
      }
#endif
      // Draw the currently running effects
      {
        TLinkedListNode<CDemoEffect*> *pNode = m_Lista.GetHead();
        while (pNode)
        {
          if (pNode->t->IsActive())
            pNode->t->Draw(rc);
          pNode = pNode->pNext;
        }
      }
      if (flash > 0)
      {
        rc.FillRect(0, 0, 640, 480, 0x00FFFFFF | (flash << 24));
        flash = Max((int)0, flash - 32);
      }
      // We're done with rendering.
      Dev.EndFrame();
    }
    // Update screen.
    Dev.Update();
  }

  m_Lista.DeleteAll();

  Win.SetHandler(pOldHandler);
}
