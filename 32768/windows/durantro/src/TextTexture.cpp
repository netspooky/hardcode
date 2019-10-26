// -------------------------------------------------------------------------------------
// File:        TextTexture.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "TextTexture.h"
#include "DisplayDevice.h"
#include "RenderContext.h"
#include "DisplayVertex.h"
#include "StdDisplayMaterials.h"
#include <d3d8.h>

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CTextTexture::Init  (CDisplayDevice *pDev)
{
  End();

  m_pTex = NULL;

  m_extentX = 0;
  m_pDev = pDev;
  return RET_OK;
}

// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CTextTexture::End  ()
{
  if (IsOk())
  {
    if (m_pTex)
      m_pTex->Release();
    m_pDev = NULL;
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
int CTextTexture::AddText     (const char *pszText, const char *pszFont, int fontSize, bool bBold, bool bItalic)
{
  if (!IsOk())
    return 0;

  // Code adapted from D3D8's 3DText sample.

  // Create a DC
  HDC     hDC       = ::CreateCompatibleDC( NULL );
  ::SetMapMode( hDC, MM_TEXT );

  // Create a font.  By specifying ANTIALIASED_QUALITY, we might get an
  // antialiased font, but this is not guaranteed.
  INT nHeight    = -MulDiv( fontSize, (INT)(GetDeviceCaps(hDC, LOGPIXELSY)), 72 );
  HFONT hFont    = ::CreateFont( nHeight, 0, 0, 0, bBold? FW_BOLD : FW_NORMAL, bItalic,
                        FALSE, FALSE, DEFAULT_CHARSET, OUT_DEFAULT_PRECIS,
                        CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY,
                        VARIABLE_PITCH, pszFont);
  if (!hFont)
  {
    ::DeleteDC( hDC );
    return 0;
  }

  ::SelectObject( hDC, hFont );

  // Set text properties
  ::SetTextColor( hDC, RGB(255,255,255) );
  ::SetBkColor(   hDC, 0x00000000 );
  ::SetTextAlign( hDC, TA_TOP );

  // Loop through all printable character and output them to the bitmap..
  // Meanwhile, keep track of the corresponding tex coords for each character.
  char str[300];
  SIZE size, maxSize;
  int maxChars = 0;
  int maxTexW = 1;

  int texScaleX = 1;
  int curTexW = 1;
  for (int i = 0; i < sizeof(str)-1 && pszText[i]; i++)
  {
    str[i] = pszText[i];
    str[i+1] = '\0';
    ::GetTextExtentPoint32( hDC, str, i+1, &size );

    while (size.cx > texScaleX*curTexW)
//      if (curTexW < (int)m_pDev->GetMaxTextureW())
      if (curTexW < (int)1024)
        curTexW <<= 1;
      else
        texScaleX <<= 1;
    
    maxChars = i+1;
    maxSize = size;
    maxTexW = curTexW;
    if (maxSize.cy > 256)
      maxSize.cy = 256;
  }

  str[maxChars] = '\0';
  int cy = 128 - maxSize.cy/2;

  // Prepare to create a bitmap
  DWORD*      pBitmapBits;
  BITMAPINFO bmi;
  ZeroMemory( &bmi.bmiHeader,  sizeof(BITMAPINFOHEADER) );
  bmi.bmiHeader.biSize        = sizeof(BITMAPINFOHEADER);
  bmi.bmiHeader.biWidth       =  maxTexW*texScaleX;
  bmi.bmiHeader.biHeight      = -256;
  bmi.bmiHeader.biPlanes      = 1;
  bmi.bmiHeader.biCompression = BI_RGB;
  bmi.bmiHeader.biBitCount    = 32;

  // Create a bitmap for the font
  HBITMAP hbmBitmap = ::CreateDIBSection( hDC, &bmi, DIB_RGB_COLORS,
                                         (VOID**)&pBitmapBits, NULL, 0 );
  ::SelectObject( hDC, hbmBitmap );
  ::ExtTextOut( hDC, 0, cy, ETO_OPAQUE, NULL, str, maxChars, NULL );

  if (size.cx && size.cy && !FAILED(m_pDev->GetDirect3DDevice()->CreateTexture(maxTexW, 256, 1, 0, D3DFMT_A4R4G4B4, D3DPOOL_MANAGED, &m_pTex)))
  {
    // Lock the surface and write the alpha values for the set pixels
    D3DLOCKED_RECT d3dlr;

    if (FAILED(m_pTex->LockRect( 0, &d3dlr, NULL, 0 )))
      maxChars = 0;
    else
    {

      for (int y = 0; y < maxSize.cy; ++y)
      {
        DWORD *pix = pBitmapBits + maxTexW*texScaleX*(cy+y);
        WORD* pDst16 = POINTER_ADD_T(WORD, d3dlr.pBits, d3dlr.Pitch*y);

        for (int x = maxSize.cx; x > 0; x -= texScaleX, pix += texScaleX)
        {
          DWORD bAlpha = *pix & 0x0000f000;
          *pDst16 = WORD(bAlpha | 0x0fff);
//          *pDst16 = WORD(bAlpha | 0x0CCC | (rand() & 0xFFF));
//          int c = rand() & 0xF;
//          c = c | (c << 4) | (c << 8);
//          *pDst16 = WORD(bAlpha | 0xCCC | c);

          pDst16++;
        }
        if (maxSize.cx/texScaleX < maxTexW)
          memset(pDst16, 0, sizeof(WORD)*(maxTexW-maxSize.cx/texScaleX));
      }
      for (; y < 256; ++y)
        memset(POINTER_ADD_T(WORD, d3dlr.pBits, d3dlr.Pitch*y), 0, sizeof(WORD)*maxTexW);

      m_pTex->UnlockRect(0);

      m_extentX = maxSize.cx;
      m_texW    = maxTexW;
      m_extentY = maxSize.cy;
      m_texScaleX = texScaleX;
    }
  }

  // Done updating texture, so clean up used objects
  ::DeleteObject( hbmBitmap );
  ::DeleteDC( hDC );
  ::DeleteObject( hFont );

  return maxChars;
}


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  CTextTexture::Draw        (CRenderContext &rc, TColor c, float x, float y)
{
  if (!IsOk() || m_extentX == 0 || !(c & 0xFF000000))
    return;

  CStdDisplayMaterial mat(rc.GetDevice(), SDMF_COLOR_MODULATE | SDMF_BLEND_ALPHA);
// CStdDisplayMaterial mat(rc.GetDevice(), SDMF_COLOR_DIFFUSE | SDMF_BLEND_ALPHA);

  TTLVertexUV av[4];
  float rhw = 1.f;
  float z = 0.f;
  float w = float(m_extentX*m_texScaleX);
  float h = float(m_extentY);

  // Coordinate fix for FSAA - GeForce's do it wrong or something!?!?
  float aad = rc.GetDevice()->UsingFSAA()? .25f : 0;

  av[0].Set(aad+x,   aad+y,   z, rhw, c, 0, 0);
  av[1].Set(aad+x+w, aad+y,   z, rhw, c, float(m_extentX)/m_texW, 0);
  av[2].Set(aad+x,   aad+y+h, z, rhw, c, 0, float(m_extentY)/256);
  av[3].Set(aad+x+w, aad+y+h, z, rhw, c, float(m_extentX)/m_texW, float(m_extentY)/256);

  mat.Set(rc.GetDevice());
  rc.GetDevice()->SetTexture(0, m_pTex);

  rc.GetDevice()->SetFVFShader(DV_FVF_TLVERTEXUV);
  rc.GetDevice()->GetDirect3DDevice()->DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, av, sizeof(*av));
}
