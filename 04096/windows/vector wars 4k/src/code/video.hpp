#ifndef video_hpp
#define video_hpp

void Video_Init();
void Video_BeginScene();
void Video_EndScene();

extern LPDIRECT3DDEVICE9	g_pD3DDevice;
extern LPD3DXMATRIXSTACK	g_pMatrixStack;
extern LPD3DXFONT			g_pFontText;

extern RECT					g_desktopRect;

#endif // #ifndef video_hpp
