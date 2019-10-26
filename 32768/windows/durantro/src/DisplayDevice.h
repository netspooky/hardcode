// -------------------------------------------------------------------------------------
// File:        DisplayDevice.h 
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DISPLAYDEVICE_H_
#define _DISPLAYDEVICE_H_

#include "DXNames.h"

class CWinWindow;

struct TMatrix3;
struct TProjectionViewport;

class CDisplayDevice;

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

typedef unsigned TColor;

__forceinline TColor MakeColor(int r, int g, int b, int a = 255) { return (a << 24) | (r << 16) | (g << 8) | b; }
__forceinline int    Color_A(TColor c) { return (c >> 24); }
__forceinline int    Color_R(TColor c) { return (c >> 16) & 0xFF; }
__forceinline int    Color_G(TColor c) { return (c >> 8)  & 0xFF; }
__forceinline int    Color_B(TColor c) { return (c     )  & 0xFF; }

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class IDisplayMaterial
{
  public:
    virtual void Set(CDisplayDevice *) const = 0;
};

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDisplayDevice
{
  public:
    enum
    {
      F_WANT_FULLSCREEN   = 0x0001,
      F_WANT_ZBUFFER      = 0x0002,
      F_WANT_STENCIL      = 0x0010,
      F_WANT_WBUFFER      = 0x1000,
      F_WANT_FSAA         = 0x2000,
      F_WANT_NODISCARD    = 0x4000,       // Incompatible with F_WANT_FSAA -> out of memory?
    };

    CDisplayDevice    (): m_pWindow(NULL)     { }
    ~CDisplayDevice   ()                      { End(); }

    TError        Init      (CWinWindow *pWindow);
    void          End       ();
    bool          IsOk      ()                      const { return (m_pWindow != NULL); }

    DXN_Direct3DDevice
                  *GetDirect3DDevice()              const { return m_pDevice; }
    DXN_Direct3D  *GetDirect3D      ()              const { return m_pD3D; }

    TError        SetDisplayMode    (int w, int h, int bpp, bool bFullscreen = true, unsigned wantFlags = F_WANT_ZBUFFER | F_WANT_WBUFFER | F_WANT_FSAA);
    void          Shutdown          ();
    TError        Restore           ();
    bool          UsingZBuffer      ()              const { return (m_mode.flags & F_WANT_ZBUFFER) != 0; }
    bool          UsingStencil      ()              const { return (m_mode.flags & F_WANT_STENCIL) != 0; }
    bool          UsingFSAA         ()              const { return (m_mode.flags & F_WANT_FSAA) != 0; }

    unsigned      GetMaxTextureW    ()              const { return m_maxTextureW; }
    unsigned      GetMaxTextureH    ()              const { return m_maxTextureH; }

    bool          IsAvailable       ()              const { return IsOk() && !(m_flags & F_INRESET); }
    bool          IsDeviceReady     () const;

    TError        BeginFrame        ();
    void          EndFrame          ();
    void          Update            ();
    void          Clear             (bool bColor = true, TColor color = 0, bool bZBuffer = true, float depth = 1.f, bool bStencil = false, int stValue = 0);

    int           GetWidth          ()              const { return m_mode.w; }
    int           GetHeight         ()              const { return m_mode.h; }

    void          Flush             ();

    void          SetViewport       (int x, int y, int w, int h);
    void          SetProjection     (float ivpw, float ivph, float Q, float zn);
    void          SetProjectionViewport
                                    (const TProjectionViewport *vp);

    void          SetWorldTransform (const TMatrix3 &m);
    void          SetViewTransform  (const TMatrix3 &m);

    void          SetTexture        (int stage, DXN_Direct3DTexture *pTex);
    void          SetRS             (unsigned rs, unsigned val)               { ASSERT(rs < MAXRENDERSTATE); if (m_aRenderState[rs] != val) InternalSetRS(rs, val); }
    void          SetTSS            (int stage, unsigned tss, unsigned val)   { ASSERT(stage < MAXTEXTURESTAGES); ASSERT(tss < MAXTEXTURESTAGESTATES); if (m_aTextureStageState[stage][tss] != val) InternalSetTSS(stage, tss, val); }
    void          ResetMaterial     ();
    void          EnableHWTnL       (bool bEnable);
    bool          UsingHWTnL        () const;

    void          SetFVFShader      (unsigned fvf);

  private:
    enum
    {
      F_INRESET       = 0x80000000,

      MAXTEXTURESTAGES      =   4,
      MAXTEXTURESTAGESTATES =  32,
      MAXRENDERSTATE        = 200,
    };

    struct TDisplayMode
    {
      int      w, h, bpp;
      unsigned flags;

      bool IsOk()   const { return bpp != 0; }
      bool IsFS()   const { return (flags & F_WANT_FULLSCREEN) != 0; }
      bool IsDB()   const { return (flags & (F_WANT_ZBUFFER | F_WANT_STENCIL | F_WANT_WBUFFER)) != 0; }
      bool IsFSAA() const { return (flags & F_WANT_FSAA) != 0; }
      bool IsNoDiscard() const { return (flags & F_WANT_NODISCARD) != 0; }
    };

    // ------------------------------------------------------

    unsigned  FindDesktopFormat       () const;
    unsigned  FindBackbufferFormat    (int bpp) const;
    unsigned  FindDepthbufferFormat   (unsigned format, unsigned flags) const;
    unsigned  FindFormatBpp           (unsigned fmt) const;

    void      InternalSetRS           (unsigned rs, unsigned val);
    void      InternalSetTSS          (int stage, unsigned tss, unsigned val);

    // ------------------------------------------------------

    CWinWindow          *m_pWindow;
    DXN_Direct3D        *m_pD3D;
    DXN_Direct3DDevice  *m_pDevice;
    unsigned            m_flags;
    unsigned            m_desktopFormat;

    TDisplayMode        m_mode;
    TDisplayMode        m_newMode;

    // State cache.
    unsigned            m_aRenderState[MAXRENDERSTATE];
    unsigned            m_aTextureStageState[MAXTEXTURESTAGES][MAXTEXTURESTAGESTATES];
    unsigned            m_FVFShader;

    // Caps
    unsigned            m_maxTextureW;
    unsigned            m_maxTextureH;
};

#endif // _DISPLAYDEVICE_H_
