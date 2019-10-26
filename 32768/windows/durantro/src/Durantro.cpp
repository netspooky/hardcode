// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <windows.h>
#include "minifmod.h"
#include "WinWindow.h"
#include "IntroMain.h"

#ifdef DEBUG
#define OUT_ERROR(a) do { printf a; return 1; } while (0) 
#else
#define OUT_ERROR(a) return 1
#endif

// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// MiniFMOD / XM stuff
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
#ifdef VERSIONFINAL
#include "IntroXM.h"

static int s_XMPos;

static unsigned int memopen(char *name)
{
  s_XMPos = 0;
	return INTROXM_LEN;
}

static void memclose(unsigned int handle)
{
}

static int memread(void *buffer, int size, unsigned int handle)
{
	if (s_XMPos + size >= INTROXM_LEN)
		size = INTROXM_LEN - s_XMPos;

  if (size > 0)
  {
  	memcpy(buffer, IntroXM + s_XMPos, size);
	  s_XMPos += size;
  }
	
	return size;
}

static void memseek(unsigned int handle, int pos, signed char mode)
{
	if (mode == SEEK_SET) 
		s_XMPos = pos;
	else if (mode == SEEK_CUR) 
		s_XMPos += pos;
	else if (mode == SEEK_END)
		s_XMPos = INTROXM_LEN + pos;

	if (s_XMPos > INTROXM_LEN)
		s_XMPos = INTROXM_LEN;
}

static int memtell(unsigned int handle)
{
	return s_XMPos;
}
#else

static unsigned int memopen(char *name)
{
  return (unsigned)fopen(name, "rb");
}

static void memclose(unsigned int handle)
{
  fclose((FILE*)handle);
}

static int memread(void *buffer, int size, unsigned int handle)
{
  return fread(buffer, 1, size, (FILE*)handle);
}

static void memseek(unsigned int handle, int pos, signed char mode)
{
  fseek((FILE*)handle, pos, mode);
}

static int memtell(unsigned int handle)
{
  return ftell((FILE*)handle);
}
#endif

// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------
// ----------------------------------------------------------------------------------------



// --------------------------------------------------------------------------
// Simplistic window message handler.
// This one clears the background to black
// --------------------------------------------------------------------------
class CMyHandler : public CWinWindow::IMsgHandler
{
  public:
    virtual bool MsgProc(CWinWindow *pWnd, unsigned msg, unsigned wParam, unsigned lParam, unsigned &result)
    {
      if (msg == WM_ERASEBKGND)
      {
        RECT r;
        ::GetWindowRect ((HWND)pWnd->GetHwnd(), &r);
        HGDIOBJ h = ::GetStockObject(BLACK_BRUSH);
        ::FillRect((HDC)wParam, &r, (HBRUSH)h);
        result = 1;
        return true;
      }
      return false;
    }
};

// --------------------------------------------------------------------------
// WinMain
// --------------------------------------------------------------------------
int WINAPI WinMain(
  HINSTANCE hInstance,      // handle to current instance
  HINSTANCE hPrevInstance,  // handle to previous instance
  LPSTR lpCmdLine,          // command line
  int nCmdShow              // show state
)
{
  CWinWindow Win;
  CMyHandler Handler;

#ifdef _DEBUG
  Win.Init("Durantro", &Handler);
#else
// Amazing, this doesn't work - when the app is set to fullscreen, the window doesn't cover the screen WTF!?!?!?!
//  Win.Init("Durantro", WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, &Handler);
// Amazing, this doesn't work either - when the app is set to fullscreen, the window doesn't go WS_POPUP WTF!?!?!?!
//  Win.Init("Durantro", WS_OVERLAPPEDWINDOW | WS_VISIBLE | WS_MAXIMIZE, &Handler);
//  Win.Init("Durantro", WS_OVERLAPPEDWINDOW | WS_VISIBLE, &Handler);

  Win.Init("Durantro", WS_POPUP | WS_VISIBLE, &Handler);
#endif

#ifdef VERSIONFINAL
#define MUSIC
#endif

#ifdef MUSIC
	FMUSIC_MODULE *mod;
	FSOUND_File_SetCallbacks(memopen, memclose, memread, memseek, memtell);

	if (!FSOUND_Init(44100, 0))
    OUT_ERROR("Error upon initialization\n");
  mod = FMUSIC_LoadSong(lpCmdLine[0]? lpCmdLine : "Intro.xm", NULL);
	if (!mod)
		OUT_ERROR("Error loading song\n");

  DoIntro(Win, mod);

	FMUSIC_FreeSong(mod);
	FSOUND_Close();
#else
  DoIntro(Win, NULL);
#endif

  Win.End();

  return 0;
}
