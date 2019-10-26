#ifndef _WIN32_HPP_
#define _WIN32_HPP_

class Window
{
	public:
		Window();
		~Window();

		bool create(bool bflag);
		void shut();

//		HDC getDC();

	private:

/*		HWND hwnd;
		HDC hdc;
		HGLRC hrc;
		PIXELFORMATDESCRIPTOR p;
		int pixelformat;

		DEVMODE screenSettings;
		HINSTANCE hInstance;*/
};

#endif
