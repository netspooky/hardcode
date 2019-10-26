// -------------------------------------------------------------------------------------
// File:        WinWindow.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _WINWINDOW_H_
#define _WINWINDOW_H_


class CWinWindow
{
  public:
    class IMsgHandler
    {
      public:
        virtual bool MsgProc(CWinWindow *pWnd, unsigned msg, unsigned wParam, unsigned lParam, unsigned &result) = 0;
    };

      CWinWindow      (): m_hwnd(0)     { }
      ~CWinWindow     ()                { End(); }

    bool      Init    (const char *pszTitle, IMsgHandler *pHandler = 0);
    bool      Init    (const char *pszTitle, unsigned style, IMsgHandler *pHandler = 0);
    bool      Init    (const char *pszTitle, unsigned style, int x, int y, int w, int h, IMsgHandler *pHandler = 0);

    void      End     ();
    bool      IsOk    ()          const { return m_hwnd != 0; }

    IMsgHandler * GetHandler  ()                        const { return m_pHandler; }
    void          SetHandler  (IMsgHandler *pHandler)         { m_pHandler = pHandler; }

    unsigned      GetHwnd     ()                        const { return m_hwnd; }

    static bool   MessagePump (bool bWait);

  protected:
    unsigned      m_hwnd;
    IMsgHandler  *m_pHandler;
    bool          m_bDestroying;

    static unsigned __stdcall WinProc   (unsigned hwnd, unsigned msg, unsigned wParam, unsigned lParam);
};


#endif //_WINWINDOW_H_
