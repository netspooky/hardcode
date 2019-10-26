
#ifndef __WINDOW_H__
#define __WINDOW_H__

#include <windows.h>

class Window {
	public:
		Window( int _width, int _height, int _bpp, bool _fullscreen );
		~Window();

		bool		isActive();

		HWND		getHWND() const;
		HDC			getHDC() const;
		int			getWidth() const;
		int			getHeight() const;
		int			getBPP() const;
		bool		isFullscreen() const;

	private:
		int			width;
		int			height;
		int			bpp;
		bool		fullscreen;

		HWND		hwnd;
		HDC			hdc;
};

#endif