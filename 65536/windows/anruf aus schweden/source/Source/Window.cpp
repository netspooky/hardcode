
#include "Window.h"

LRESULT WINAPI msgProc( HWND hwnd, UINT msg, WPARAM wp, LPARAM lp ) {

	switch( msg ) {

		case WM_DESTROY:
			PostQuitMessage( 0 );
			return 0;
		break;

		case WM_KEYDOWN:
			if( wp == VK_ESCAPE )
				PostQuitMessage( 0 );
		break;
	}

	return DefWindowProc( hwnd, msg, wp, lp );
}

Window::Window( int _width, int _height, int _bpp, bool _fullscreen ): 
			width( _width ), height( _height ), bpp( _bpp ), fullscreen( _fullscreen ), hwnd( 0 ), hdc( 0 ) {

	WNDCLASS	wc	= {	CS_HREDRAW | CS_VREDRAW | CS_OWNDC, msgProc, 0, 0, GetModuleHandle( 0 ), 0, 0, 0, 0, "unikwindow" };

	if( !RegisterClass( &wc ) )
		return;

	if( fullscreen ) {

		DEVMODE	screenSettings;
	
		ZeroMemory( &screenSettings, sizeof( screenSettings ) );

		screenSettings.dmSize		= sizeof( screenSettings );
		screenSettings.dmPelsWidth	= width;
		screenSettings.dmPelsHeight	= height;
		screenSettings.dmBitsPerPel	= bpp;
		screenSettings.dmFields		= DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;

		if( ChangeDisplaySettings( &screenSettings, CDS_FULLSCREEN ) != DISP_CHANGE_SUCCESSFUL ) {
			MessageBox( 0, "could not init fullscreen", "", MB_OK );
		}

		ShowCursor( false );
	}

	hwnd = CreateWindow(	"unikwindow", "", 
							WS_POPUP | WS_VISIBLE | WS_CLIPSIBLINGS | WS_CLIPCHILDREN,
							0, 0, width, height, 0, 0, GetModuleHandle( 0 ), 0 );
	
	// gelitten
	if( !hwnd )
		return;

	hdc = GetDC( hwnd );
	if( !hdc )
		return;

	ShowWindow( hwnd, SW_SHOWNORMAL );
	UpdateWindow( hwnd );
	SetFocus( hwnd );
	SetCursor( 0 );
}

Window::~Window() {

	if( hdc )
		ReleaseDC( hwnd, hdc);

	if( hwnd )
		DestroyWindow( hwnd );

	if( fullscreen ) {
		ChangeDisplaySettings( 0, 0 );
		ShowCursor( true );
	}

	UnregisterClass( "unikwindow", GetModuleHandle( 0 ) );
}

bool Window::isActive() {

	MSG	msg;

	while( PeekMessage( &msg, 0, 0, 0, PM_NOREMOVE ) ) {

		if( msg.message == WM_QUIT )
			return false;

		if( !GetMessage( &msg, 0, 0, 0 ) )
			return true;
		else {
			TranslateMessage( &msg );
			DispatchMessage( &msg );
		}
	}

	return true;
}

HWND Window::getHWND() const {
	return hwnd;
}

HDC Window::getHDC() const {
	return hdc;
}

int Window::getWidth() const {
	return width;
}

int Window::getHeight() const {
	return height;
}

int Window::getBPP() const {
	return bpp;
}

bool Window::isFullscreen() const {
	return fullscreen;
}