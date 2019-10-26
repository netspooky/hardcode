/*
  This file is part of bob, a 32k game for Mekka Symposium 2001.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file copying.txt); if not, write 
  to the Free Software Foundation, Inc., 
  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#define INITGUID

#include "bob_dx7.h"
#include "convert.h"

/*
   ____ globals _____________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/

HWND window_handle;
HDC device_context;
LPDIRECTDRAW ddraw_interface;
LPDIRECTDRAWCLIPPER ddraw_clipper;
LPDIRECTDRAWSURFACE ddraw_surface_primary;
LPDIRECTDRAWSURFACE ddraw_surface_backbuffer;
LPDIRECTINPUT dinput_interface;
LPDIRECTINPUTDEVICE dinput_device;
DDSURFACEDESC ddraw_surfacedesc;
DDPIXELFORMAT ddraw_pixelformat;
DDSCAPS ddraw_surface_caps;

PTC_CONVERTER convert;


int window_bpp;
int window_fullscreen;
int window_width;
int window_height;

char dinput_keyboard_state[0x100];
char palette[0x300];

#ifdef DEBUG

#define ERROR_MAX_SIZE 0x80
char * ERROR_CAPTION = "bob error: ";

#endif


/*
   ____ error _______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
#ifdef DEBUG
void
error(char * e)
{
/*
  LPVOID message_buffer;
  char error_caption[ERROR_MAX_SIZE];

  quit();

  strcpy(error_caption, ERROR_CAPTION);
  strncat(error_caption, e, ERROR_MAX_SIZE - sizeof(ERROR_CAPTION));

  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | 
                FORMAT_MESSAGE_FROM_SYSTEM |     
                FORMAT_MESSAGE_IGNORE_INSERTS,    
                NULL, GetLastError(), 
                MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), 
                (LPTSTR) &message_buffer, 0, NULL);

  MessageBoxA(NULL, (LPCTSTR) message_buffer, error_caption,
              MB_OK | MB_ICONSTOP);

  LocalFree(message_buffer);
*/
  fprintf(stderr, "error: %s.\n", e); 

  exit(1);
}
#endif

/*
   ____ init ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
init(int width, int height, int fullscreen, char * appname)
{
  RECT rect;
  int x;
  int y;

  /* register window class + create window */
  WNDCLASS window_class = { CS_CLASSDC, window_proc, 0, 0, 
                            GetModuleHandle(NULL), NULL, NULL, NULL, NULL,
                            appname };    

  RegisterClassA(&window_class);

  window_fullscreen = fullscreen;
  window_width = width;
  window_height = height; 

  rect.right = width;
  rect.bottom = height;

  /* center window.& calculate window size */
  if(!window_fullscreen)
    {
      rect.left = 0;
      rect.top = 0;
      AdjustWindowRect(&rect, WS_OVERLAPPEDWINDOW, 0);
      rect.right -= rect.left;
      rect.bottom -= rect.top;

      x = (GetSystemMetrics(SM_CXSCREEN) - rect.right) >> 1;
      y = (GetSystemMetrics(SM_CYSCREEN) - rect.bottom) >> 1;
    }
  else
    {
      x = CW_USEDEFAULT;
      y = 0;
    }

  if(NULL == (window_handle = CreateWindowExA(0, appname, appname, 
      WS_OVERLAPPEDWINDOW, x, y, rect.right, rect.bottom, 
      NULL, NULL, window_class.hInstance, NULL)))
    error("CreateWindow failed.");

  /* FIXME: back to !fullscreen. */
      ShowWindow(window_handle, SW_SHOWNORMAL);
      UpdateWindow(window_handle);
      
  if(window_fullscreen)
    {
      ddraw_surfacedesc.dwSize = sizeof(ddraw_surfacedesc); 
      ddraw_surfacedesc.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT; 
      ddraw_surfacedesc.ddsCaps.dwCaps = 
        DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP | DDSCAPS_COMPLEX;  
      ddraw_surfacedesc.dwBackBufferCount = 1;

      ddraw_surface_caps.dwCaps = DDSCAPS_BACKBUFFER;

      if((DD_OK != DirectDrawCreate(NULL, &ddraw_interface, NULL))
          || (DD_OK != IDirectDraw_SetCooperativeLevel(ddraw_interface, 
            window_handle, DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN))
          || (DD_OK != IDirectDraw_SetDisplayMode(ddraw_interface, 
            width, height, 8))
          || (DD_OK != IDirectDraw_CreateSurface(ddraw_interface, 
            &ddraw_surfacedesc, &ddraw_surface_primary, NULL)) 
          || (DD_OK != IDirectDrawSurface_GetAttachedSurface(
            ddraw_surface_primary, &ddraw_surface_caps, &ddraw_surface_backbuffer)))
        {
          fprintf(stderr, "error: failed to switch to 400x300 8bpp mode.\n");
          window_fullscreen = 0;
        }

        window_bpp = 8;
    }

  if(!window_fullscreen)
    {
      /* primary surface with no back buffers */
      ddraw_surfacedesc.dwSize = sizeof(ddraw_surfacedesc); 
      ddraw_surfacedesc.dwFlags = DDSD_CAPS; 
      ddraw_surfacedesc.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

      if((DD_OK != DirectDrawCreate(NULL, &ddraw_interface, NULL))
          || (DD_OK != IDirectDraw_SetCooperativeLevel(ddraw_interface, 
            window_handle, DDSCL_NORMAL))
          || (DD_OK != IDirectDraw_CreateSurface(ddraw_interface, 
            &ddraw_surfacedesc, &ddraw_surface_primary, NULL)))
        error("failed to init direct draw (part 1)");

      /* secondary surface */
      ddraw_surfacedesc.dwSize = sizeof(ddraw_surfacedesc); 
      ddraw_surfacedesc.dwFlags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH;
      ddraw_surfacedesc.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN;
      ddraw_surfacedesc.dwWidth = width;
      ddraw_surfacedesc.dwHeight = height;

      ddraw_pixelformat.dwSize = sizeof(DDPIXELFORMAT);

      if((DD_OK != IDirectDraw_CreateSurface(ddraw_interface, 
            &ddraw_surfacedesc, &ddraw_surface_backbuffer, NULL))
          || (DD_OK != IDirectDrawSurface_GetPixelFormat(ddraw_surface_primary,
            &ddraw_pixelformat))
          || (DD_OK != IDirectDraw_CreateClipper(ddraw_interface, 0, 
            &ddraw_clipper, 0))
          || (DD_OK != IDirectDrawClipper_SetHWnd(ddraw_clipper, 0, 
            window_handle))
          || (DD_OK != IDirectDrawSurface_SetClipper(ddraw_surface_primary, 
            ddraw_clipper)))
        error("failed to init direct draw (part 2)");  

      if(ddraw_pixelformat.dwFlags & DDPF_RGB)
        {
          /* FIXME: use those tinyptc converters. */
          window_bpp = ddraw_pixelformat.dwRGBBitCount;
          if(!(convert = ptc_request_converter(
              ddraw_pixelformat.dwRGBBitCount,
              ddraw_pixelformat.dwRBitMask,
              ddraw_pixelformat.dwGBitMask,
              ddraw_pixelformat.dwBBitMask)))
            error("no converter available for pixel format");  
        }
      else if(ddraw_pixelformat.dwFlags & DDPF_PALETTEINDEXED8)
        {
          window_bpp = 8;
        }
      else 
        {
          error("pixelformat not recognized.");
        }    
    }

  ShowCursor(FALSE);

  if((DI_OK != DirectInputCreate(window_class.hInstance,
			DIRECTINPUT_VERSION, &dinput_interface, NULL))
		|| (DI_OK != IDirectInput_CreateDevice(dinput_interface, 
			&GUID_SysKeyboard, &dinput_device, NULL))
		|| (DI_OK != IDirectInputDevice_SetDataFormat(dinput_device, 
			&c_dfDIKeyboard))
		|| (DI_OK != IDirectInputDevice_SetCooperativeLevel(dinput_device, 
			window_handle, DISCL_FOREGROUND | DISCL_NONEXCLUSIVE))
		|| (DI_OK != IDirectInputDevice_Acquire(dinput_device))
		|| (DI_OK != IDirectInputDevice_GetDeviceState(dinput_device,
			sizeof(dinput_keyboard_state), (LPVOID) &dinput_keyboard_state)))
		error("failed to init keyboard");
}

/*
   ____ quit ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
quit(void)
{
  if(ddraw_interface != NULL) 
    { 
      if(window_fullscreen)
        {
          if(ddraw_surface_primary != NULL)
            {
              IDirectDrawSurface_Release(ddraw_surface_primary);
              ddraw_surface_primary = NULL;         
            }

          IDirectDraw_RestoreDisplayMode(ddraw_interface); 
        }
      else
        {
          // FIXME: ..
        }

      IDirectDraw_Release(ddraw_interface); 
      ddraw_interface = NULL; 
    } 


  if(dinput_interface != NULL) 
    { 
      if(dinput_device != NULL)
        {
	  IDirectInputDevice_Unacquire(dinput_device);
	  IDirectInputDevice_Release(dinput_device);
	  dinput_device = NULL;
	}

      IDirectInput_Release(dinput_interface);
      dinput_interface = NULL;
    }

  DestroyWindow(window_handle);
}


/*
   ____ setpal ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
setpal(char * pal, int pal_size)
{
  LPDIRECTDRAWPALETTE ddraw_palette = NULL;
  PALETTEENTRY ddraw_palentries[0x100]; 
  int i, j;

  if(window_bpp == 8)
    {
      for(i=0; i<pal_size; i++)
      {
        j = (i<<1)+i;
        ddraw_palentries[i].peRed   = pal[j+0];
        ddraw_palentries[i].peGreen = pal[j+1];
        ddraw_palentries[i].peBlue  = pal[j+2];
      }

      if((DD_OK != (IDirectDraw_CreatePalette(ddraw_interface, 
              DDPCAPS_8BIT, ddraw_palentries, &ddraw_palette, NULL)))
            || (DD_OK != (IDirectDrawSurface_SetPalette(ddraw_surface_primary,
              ddraw_palette))))
        error("failed to set palette");
    }
  else
    {
      memcpy(palette, pal, pal_size*3);
    }
}

/*
   ____ chkkey ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
chkkey(int key)
{
  return dinput_keyboard_state[key] & 0x80;
}

/*
   ____ getkey_dvorak _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey_dvorak(void)
{
  int i;

  for(i = 0; i<0x100; i++)
    if(dinput_keyboard_state[i] & 0x80)
      switch(i)
      {
        case DIK_SPACE: return ' ';
        case DIK_0: return '0';
        case DIK_1: return '1';
        case DIK_2: return '2';
        case DIK_3: return '3';
        case DIK_4: return '4';
        case DIK_5: return '5';
        case DIK_6: return '6';
        case DIK_7: return '7';
        case DIK_8: return '8';
        case DIK_9: return '9';
        case DIK_A: return 'a';
        case DIK_N: return 'b';
        case DIK_I: return 'c';
        case DIK_H: return 'd';
        case DIK_D: return 'e';
        case DIK_Y: return 'f';
        case DIK_U: return 'g';
        case DIK_J: return 'h';
        case DIK_G: return 'i';
        case DIK_C: return 'j';
        case DIK_V: return 'k';
        case DIK_P: return 'l';
        case DIK_M: return 'm';
        case DIK_L: return 'n';
        case DIK_S: return 'o';
        case DIK_R: return 'p';
        case DIK_X: return 'q';
        case DIK_O: return 'r';
        case DIK_SEMICOLON: return 's';
        case DIK_K: return 't';
        case DIK_F: return 'u';
        case DIK_PERIOD: return 'v';
        case DIK_COMMA: return 'w';
        case DIK_B: return 'x';
        case DIK_T: return 'y';
        case DIK_SLASH: return 'z';
      }

    return 0;
}

/*
   ____ getkey_qwerty _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey_qwerty(void)
{
  int i;

  for(i = 0; i<0x100; i++)
    if(dinput_keyboard_state[i] & 0x80)
      switch(i)
      {
        case DIK_SPACE: return ' ';
        case DIK_0: return '0';
        case DIK_1: return '1';
        case DIK_2: return '2';
        case DIK_3: return '3';
        case DIK_4: return '4';
        case DIK_5: return '5';
        case DIK_6: return '6';
        case DIK_7: return '7';
        case DIK_8: return '8';
        case DIK_9: return '9';
        case DIK_A: return 'a';
        case DIK_B: return 'b';
        case DIK_C: return 'c';
        case DIK_D: return 'd';
        case DIK_E: return 'e';
        case DIK_F: return 'f';
        case DIK_G: return 'g';
        case DIK_H: return 'h';
        case DIK_I: return 'i';
        case DIK_J: return 'j';
        case DIK_K: return 'k';
        case DIK_L: return 'l';
        case DIK_M: return 'm';
        case DIK_N: return 'n';
        case DIK_O: return 'o';
        case DIK_P: return 'p';
        case DIK_Q: return 'q';
        case DIK_R: return 'r';
        case DIK_S: return 's';
        case DIK_T: return 't';
        case DIK_U: return 'u';
        case DIK_V: return 'v';
        case DIK_W: return 'w';
        case DIK_X: return 'x';
        case DIK_Y: return 'y';
        case DIK_Z: return 'z';
      }

    return 0;
}

/*
   ____ getkey ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey(int map)
{
  if(map == BOB_DVORAK)
    return getkey_dvorak();
  else
    return getkey_qwerty();
}



/*
   ____ flip ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
flip(char * src)
{
  HRESULT result = DDERR_WASSTILLDRAWING;
  /*  MSG message; */
  int y;
  char * dst;
  
  /* process messages */
/*
  while (PeekMessage(&message, window_handle, 0, 0, PM_REMOVE))
  {
    TranslateMessage(&message);
    DispatchMessage(&message);
  }
*/

  if(DI_OK != IDirectInputDevice_GetDeviceState(dinput_device,
      sizeof(dinput_keyboard_state), (LPVOID) &dinput_keyboard_state))
    IDirectInputDevice_Acquire(dinput_device); /* better luck next frame? */

  if(DD_OK == IDirectDrawSurface_Lock(ddraw_surface_backbuffer, 
                                      NULL, &ddraw_surfacedesc, 
                                      DDLOCK_WAIT | DDLOCK_SURFACEMEMORYPTR, NULL))
    {
      dst = ddraw_surfacedesc.lpSurface;

      for (y=0; y<window_height; y++)
        {

          if(window_bpp == 8)
            memcpy(dst, src, window_width);
          else
            convert(src, dst, window_width, palette);

          src += window_width;
          dst += ddraw_surfacedesc.lPitch;;
        }
    }

  IDirectDrawSurface_Unlock(ddraw_surface_backbuffer, NULL);

  if(window_fullscreen)
    {
      while((result != DD_OK)
          || ((result == DDERR_SURFACELOST)
          && (DD_OK == IDirectDrawSurface_Restore(ddraw_surface_primary))))
        result = IDirectDrawSurface_Flip(ddraw_surface_primary, NULL, 0); 
    }
  else
    {
      paint_primary();
    }
}

/*
   ____ paint_primary _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void 
paint_primary()
{
    /* modified version of ptc_paint_primary() from tinyptc. */
    RECT source;
    RECT destination;
    POINT point;

    /* setup source rectangle */
    source.left = 0;
    source.top = 0;
    source.right = window_width;
    source.bottom = window_height;

    /* get origin of client area */
    point.x = 0;
    point.y = 0;
    ClientToScreen(window_handle, &point);

    /* get window client area */
    GetClientRect(window_handle, &destination);

    /* offset destination rectangle */
    destination.left += point.x;
    destination.top += point.y;
    destination.right += point.x;
    destination.bottom += point.y;

    /* blt secondary to primary surface */
    /* DDBLT_WAIT ?  DDBLT_ASYNC ?  */
    IDirectDrawSurface_Blt(ddraw_surface_primary,
      &destination, ddraw_surface_backbuffer, &source, DDBLT_ASYNC, 0);
}


/*
   ____ window_proc _________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
LRESULT CALLBACK
window_proc(HWND window_handle, UINT message, 
            WPARAM wparam, LPARAM lparam)
{
  /* FIXME: in asm this whole procedure can be done as either 
  a near jmp to the import table or a far jmp to the address
  for DefWindowProc from the import table, is there anyway to 
  use __asm to get this in MSVC ? */
  return DefWindowProc(window_handle, message, wparam, lparam);
}

/*
  switch(message)
    {        
    case WM_DESTROY:
      PostQuitMessage(0);
      return 0;
    case WM_PAINT:
      //Render();
      ValidateRect(window_handle, NULL);
      return 0;    
    }

*/
    
