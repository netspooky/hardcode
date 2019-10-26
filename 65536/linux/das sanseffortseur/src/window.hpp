
#ifndef WINDOW_HPP
#define WINDOW_HPP

#ifdef __WIN32__
    #include <windows.h>
#endif
#ifdef __linux__
    #include <unistd.h>
    #include <sys/time.h>
    #include <GL/glx.h>
    #include <X11/keysym.h>
#endif
#include <GL/gl.h>
#include <GL/glu.h>

class Win
{
public:
       Win(const char *title, int x, int y, bool f = false);
       bool Event();
       float GetElapsedTime();
       float GetTime();
       void ShowCursor(bool s);
       void Flush();
       ~Win();
       int width,height;
       bool fullscreen;
private:
       #ifdef __linux__
        ::Display *dpy;
        ::Window win;
        GLXContext cx;
        Atom WM_DELETE_WINDOW, _MOTIF_WM_HINTS;
        XEvent event;
        Cursor myHiddenCursor;
        XSizeHints *sh;
       #endif
       #ifdef __WIN32__
        HWND    window_handle;
        HDC     device_handle;
        HGLRC   gl_render_context;
       #endif
};



#endif
