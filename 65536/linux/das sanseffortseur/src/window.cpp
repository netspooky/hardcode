#include "window.hpp"


#ifdef __WIN32__
//------------------------------------------------------------
// Window
//------------------------------------------------------------
static int key     = 0;
static int key_hit = 0;

LRESULT WINAPI msgProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {

    switch(msg) {
        case WM_DESTROY:
            PostQuitMessage(0);
            return 0;
        break;

        case WM_KEYDOWN:
            if(wp == VK_ESCAPE)
                PostQuitMessage(0);
            else {
                key_hit = 1;
                key     = (int)wp;
            }
        break;

        case WM_KEYUP:
            key_hit = 0;
        break;
    }

    return DefWindowProc(hwnd, msg, wp, lp);
}

Window::Window(const char *title, int x, int y, bool f)
{
    fullscreen = f;
    PIXELFORMATDESCRIPTOR   pfd;
    HINSTANCE               hinst = GetModuleHandle(0);
    int                     pixelFormat;
    WNDCLASS                wc = {  CS_HREDRAW|CS_VREDRAW|CS_OWNDC, msgProc, 0, 0, GetModuleHandle(0), 0, 0, 0, 0, "window" };

    width = x;
    height = y;

    if(!RegisterClass(&wc))
        return;

    RtlZeroMemory(&pfd, sizeof(PIXELFORMATDESCRIPTOR));
    
    pfd.nSize       = sizeof(PIXELFORMATDESCRIPTOR);
    pfd.nVersion    = 1;
    pfd.dwFlags     = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
    pfd.iPixelType  = PFD_TYPE_RGBA;
    pfd.cColorBits  = 32;
    pfd.cDepthBits  = 16;
    pfd.iLayerType  = PFD_MAIN_PLANE;

    if(fullscreen) {

        DEVMODE dmScreenSettings;

        RtlZeroMemory(&dmScreenSettings, sizeof(dmScreenSettings));

        dmScreenSettings.dmSize         = sizeof(dmScreenSettings);
        dmScreenSettings.dmPelsWidth    = x;
        dmScreenSettings.dmPelsHeight   = y;
        dmScreenSettings.dmBitsPerPel   = 32;
        dmScreenSettings.dmFields       = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;

        if(ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN) != DISP_CHANGE_SUCCESSFUL)
            return;
    }

    if(fullscreen)
        window_handle = CreateWindowEx(    WS_EX_TOOLWINDOW, "window", title,
                                           WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE, 
                                           0, 0, x, y, 0, 0, hinst, 0);
    else
        window_handle = CreateWindowEx(    WS_EX_TOOLWINDOW, "window", title,
                                           WS_CAPTION | WS_POPUP | WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_VISIBLE, 
                                           0, 0, x, y, 0, 0, hinst, 0);

    device_handle  = GetDC(window_handle);
    pixelFormat         = ChoosePixelFormat(device_handle, &pfd);

    SetPixelFormat(device_handle, pixelFormat, &pfd);
    gl_render_context = wglCreateContext(device_handle);
    wglMakeCurrent(device_handle, gl_render_context);

    ShowWindow(window_handle, SW_SHOWNORMAL);
    UpdateWindow(window_handle);
    SetFocus(window_handle);
    SetCursor(0);

    glMatrixMode( GL_PROJECTION );
    glLoadIdentity( );
    gluPerspective(70,4.f/3,1,10000);
    glEnable(GL_DEPTH_TEST);

    clock.Reset();
}


//------------------------------------------------------------
// Event
//------------------------------------------------------------
bool Window::Event()
{
    clock.Reset();
    return !( GetAsyncKeyState(VK_ESCAPE)&0x8000 );
}

//------------------------------------------------------------
// ShowCursor
//------------------------------------------------------------
void Window::ShowCursor(bool s)
{
    ::ShowCursor(s);
}


//------------------------------------------------------------
// Flush
//------------------------------------------------------------
void Window::Flush()
{
    SwapBuffers(device_handle);
}

//------------------------------------------------------------
// Destructor
//------------------------------------------------------------
Window::~Window()
{
    if(gl_render_context) {
        wglMakeCurrent(0, 0);
        wglDeleteContext(gl_render_context);
    }

    if(device_handle)
        ReleaseDC(window_handle, device_handle);

    if(window_handle)
        DestroyWindow(window_handle);

    if(fullscreen) {
        ChangeDisplaySettings(0, 0);
        ShowCursor(1);
    }

    UnregisterClass("window", GetModuleHandle(0));
}
#endif





























#ifdef __linux__
//------------------------------------------------------------
// Window
//------------------------------------------------------------
Win::Win(const char *title, int x, int y, bool f)
{
    width = x;
    height = y;
    fullscreen = f;
    XVisualInfo *vi;
    int indexed = 1, rgb_bits = 1;
    int alpha_bits = 0, depth_bits = 0, stencil_bits = 0;
    XSetWindowAttributes swa;


    dpy = XOpenDisplay(0);

    int glx_error_base=0,glx_event_base=0;
    glXQueryExtension(dpy, &glx_error_base, &glx_event_base);

    int attrListDbl[] = {GLX_RGBA, GLX_DOUBLEBUFFER, GLX_RED_SIZE, 4, GLX_GREEN_SIZE, 4, GLX_BLUE_SIZE, 4, GLX_DEPTH_SIZE, 16, None};
    vi = glXChooseVisual(dpy, DefaultScreen(dpy), attrListDbl);

    cx = glXCreateContext(dpy, vi, 0, GL_TRUE);



    swa.colormap = XCreateColormap(dpy, RootWindow(dpy, vi->screen),
                                   vi->visual, AllocNone);
    swa.event_mask = ExposureMask | KeyPressMask | ButtonPressMask | StructureNotifyMask;

    sh = XAllocSizeHints();


    if (fullscreen)
    {
        width = DisplayWidth(dpy, vi->screen);
        height = DisplayHeight(dpy, vi->screen);

        sh->flags = USPosition | PMinSize;
        sh->x = 0;
        sh->y = 0;
        //if (width < 0) width = -width;
        //if (height < 0) height = -height;
        sh->min_width = width;
        sh->min_height = height;

        win = XCreateWindow(dpy, RootWindow(dpy, vi->screen),
                            0, 0, width, height,
                            0,vi->depth,InputOutput,vi->visual,
                            CWColormap|CWEventMask, &swa);

        _MOTIF_WM_HINTS = XInternAtom(dpy, "_MOTIF_WM_HINTS", False);
        { long hints[] = { 2, 0, 0, 0 };
        XChangeProperty(dpy, win, _MOTIF_WM_HINTS, _MOTIF_WM_HINTS, 32,
                        PropModeReplace, (unsigned char*)&hints, 4); }
    }
    else
    {

        //if (width > 0 || height > 0)
        sh->flags = PMinSize ;
        //if (width < 0) width = -width;
        //if (height < 0) height = -height;
        sh->min_width = width;
        sh->min_height = height;
        win = XCreateWindow(dpy, RootWindow(dpy, vi->screen),
                            0, 0, width, height,
                            0,vi->depth,InputOutput,vi->visual,
                            CWColormap|CWEventMask, &swa);

        XSetStandardProperties(dpy,win, title, title, 0,0,0,0);

    }

    XSetWMNormalHints(dpy, win, sh);
    XFree(sh);

    WM_DELETE_WINDOW = XInternAtom(dpy, "WM_DELETE_WINDOW", False);
    XSetWMProtocols(dpy, win, &WM_DELETE_WINDOW, 1);

    XMapWindow(dpy, win);
    { XEvent ev;
    while (XNextEvent(dpy, &ev), (ev.type != MapNotify) ||
                                 (ev.xmap.window != win)) ; }

    glXMakeCurrent(dpy, win, cx);

    XMapWindow(dpy, win);
    //Hide Cursor
    // Create the cursor's pixmap (1x1 pixels)
    Pixmap CursorPixmap = XCreatePixmap(dpy, win, 1, 1, 1);
    GC GraphicsContext = XCreateGC(dpy, CursorPixmap, 0, NULL);
    XDrawPoint(dpy, CursorPixmap, GraphicsContext, 0, 0);
    XFreeGC(dpy, GraphicsContext);

    // Create the cursor, using the pixmap as both the shape and the mask of the cursor
    XColor Color;
    Color.flags = DoRed | DoGreen | DoBlue;
    Color.red = Color.blue = Color.green = 0;
    myHiddenCursor = XCreatePixmapCursor(dpy, CursorPixmap, CursorPixmap, &Color, &Color, 0, 0);

    // We don't need the pixmap any longer, free it
    XFreePixmap(dpy, CursorPixmap);

    //glMatrixMode( GL_PROJECTION );
    //glLoadIdentity( );
    //gluPerspective(70,4.f/3,1,10000);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);



}

//------------------------------------------------------------
// Event
//------------------------------------------------------------
bool Win::Event()
{
    //clock.Reset();
    while(XPending(dpy) > 0)
    {
        XNextEvent(dpy, &event);
        switch(event.type)
        {
            case ConfigureNotify:
            {
                if ((event.xconfigure.width != width) &&
                    (event.xconfigure.height != height))
                {
                    width = event.xconfigure.width;
                    height = event.xconfigure.height;

                    glViewport (0, 0, width, height);
                   /* glMatrixMode (GL_PROJECTION);
                    glLoadIdentity ();
                    gluPerspective (70, GLWin.width/(GLdouble)GLWin.height, 0.1, 5000.0);
                    glMatrixMode (GL_MODELVIEW);
                    glLoadIdentity ();*/
                }
            }
            case Expose:
                if (event.xexpose.count != 0)
                    break;
                break;
            case KeyPress:
                switch(XLookupKeysym(&event.xkey,0))
                {
                case XK_Escape:
                    return false;
                    break;
                }
                break;
            case KeyRelease:
                break;
            case ClientMessage:
                if (*XGetAtomName(dpy, event.xclient.message_type) == *"WM_PROTOCOLS")
                {
                    return false;
                }
                break;
            default:
                break;
        }
    }
    return true;
}

//------------------------------------------------------------
// ShowCursor
//------------------------------------------------------------
void Win::ShowCursor(bool s)
{
    XDefineCursor(dpy, win, s ? None : myHiddenCursor);
}



//------------------------------------------------------------
// Flush
//------------------------------------------------------------
void Win::Flush()
{
    glXSwapBuffers(dpy,win);
}

//------------------------------------------------------------
// Destructor
//------------------------------------------------------------
Win::~Win()
{
    if (!dpy) return;

    XDestroyWindow(dpy, win);
    XCloseDisplay(dpy);
}
#endif










