#ifndef GLWINDOW_H
#define GLWINDOW_H

typedef struct glwindow_s {
	
	int		resx;
	int		resy;
	int		fullscreen;

	HWND	window_handle;
	HDC		device_handle;
	HGLRC	gl_render_context;

} glwindow;

void	glwindow_create(glwindow* glw, int resx, int resy, int fullscreen, char* title);
void	glwindow_destroy(glwindow* glw);
void	glwindow_swap_buffers(glwindow* glw);
int		glwindow_is_active(glwindow* glw);
int		glwindow_key_pressed();
int		glwindow_get_key();

#endif
