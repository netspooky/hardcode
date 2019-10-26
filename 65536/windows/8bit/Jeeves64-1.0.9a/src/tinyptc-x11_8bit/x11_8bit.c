/*
 * 
 * TinyPTC x11 v0.4 ported by Alessandro Gatti (a.gatti@tiscalinet.it)
 * Original Windows version by Glenn Fiedler (ptc@gaffer.org)
 * http://www.gaffer.org/tinyptc
 * 
 */

#include "tinyptc.h"

#ifdef __PTC_ENABLE_CONVERSIONS__
#include "convert.h"
#endif /* __PTC_ENABLE_CONVERSIONS__ */

/* #defines' sanity checks */

#ifdef __PTC_XSHM__
#ifndef __PTC_WINDOWED__
#define __PTC_WINDOWED__
#endif /* !__PTC_WINDOWED__ */
#endif /* __PTC_XSHM__ */

#ifndef __PTC_WINDOWED__
#define __PTC_DGA__
#endif /* !__PTC_WINDOWED__ */

/* Common #defines */

#define __PTC_FUNCTION_KEY__ 0xFF
#define __PTC_ESCAPE_KEY__ 0x1B

/* #includes */

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

#ifdef __PTC_DGA__
#include <X11/extensions/xf86dga.h>
#include <X11/extensions/xf86vmode.h>
#include <unistd.h>
#include <sys/types.h>
#endif /* __PTC_DGA__ */

#ifdef __PTC_XSHM__
#include <sys/ipc.h>
#include <sys/shm.h>
#include <X11/extensions/XShm.h>
#endif /* __PTC_XSHM__ */

static Display *ptc_display;
static int ptc_screen, ptc_screen_width, ptc_screen_height,
  ptc_viewport_width, ptc_viewport_height, ptc_depth;
static Window ptc_root_window;
static Visual *ptc_visual;
static char *ptc_buffer;
static int ptc_pixmap_format_count, ptc_pixmap_counter, ptc_converter_depth;
XPixmapFormatValues *ptc_pixmap_formats;


#ifdef __PTC_WINDOWED__
static Window ptc_window;
static int ptc_x_position, ptc_y_position;
static XSetWindowAttributes ptc_window_attributes;
static XSizeHints ptc_window_sizehints;
static GC ptc_window_gc;
static XImage *ptc_ximage;
#endif /* __PTC_WINDOWED__ */

#ifdef __PTC_XSHM__
static XShmSegmentInfo ptc_shm_segment;
#endif /* __PTC_XSHM__ */

#ifdef __PTC_DGA__
static char *ptc_framebuffer_address;
static int ptc_framebuffer_width, ptc_framebuffer_banksize,
  ptc_framebuffer_memory, ptc_framebuffer_start, ptc_framebuffer_pitch,
  ptc_framebuffer_index, ptc_totalmodes, ptc_dotclock, ptc_modecounter,
  ptc_previousmode_number, ptc_event_base, ptc_error_base, ptc_blitcounter;
static Bool ptc_emulate_fullscreen;
static XF86VidModeModeInfo **ptc_modeinfodata;
static XF86VidModeModeLine ptc_currentmodeline;
#ifdef __PTC_BEST_VIDEOMODE__
static int ptc_best_x_delta, ptc_best_y_delta, ptc_best_videomode,
  ptc_best_delta;
#endif /* __PTC_BEST_VIDEOMODE__ */
#endif /* __PTC_DGA__ */

#ifdef __PTC_ENABLE_CONVERSIONS__
PTC_CONVERTER ptc_convert;
static int ptc_output_pitch, ptc_blitcounter, ptc_source_index,
  ptc_destination_index;
#endif

/* 8bit palette support */
Colormap ptc_colormap;
XColor ptc_xcolors[0x100];
static int true_8bit = 0; // use convert() in non-8bit modes, and don't try setting the palette.
static unsigned char * palette = NULL;

/* Open the screen */

int
ptc_open (char *title, int width, int height)
{
  int i;

#ifdef __PTC_DGA__
  /* Check for the effective UID of the running process */
  if (geteuid ())
    {
      return 0;
    }
#endif /* __PTC_DGA__ */
  /* Open a display on the current root window */
  ptc_display = XOpenDisplay (NULL);
  if (ptc_display == NULL)
    {
      return 0;
    }
  /* Get the default screen associated with the previously opened display */
  ptc_screen = DefaultScreen (ptc_display);
  /* Get the default visual */
  ptc_visual = DefaultVisual (ptc_display, ptc_screen);
  /* Get screen bitdepth */
  ptc_depth = DefaultDepth (ptc_display, ptc_screen);
  /* Get a pointer to the supported pixmap formats */
  ptc_pixmap_formats =
    XListPixmapFormats (ptc_display, &ptc_pixmap_format_count);
  /* Check if there's one that's suitable */
  for (ptc_pixmap_counter = 0; ptc_pixmap_counter < ptc_pixmap_format_count;
       ptc_pixmap_counter++)
    {
      if (ptc_depth == ptc_pixmap_formats[ptc_pixmap_counter].depth)
        {
          /* Set the right value */
          ptc_converter_depth =
            ptc_pixmap_formats[ptc_pixmap_counter].bits_per_pixel;
        }
    }
  XFree (ptc_pixmap_formats);
#ifdef __PTC_ENABLE_CONVERSIONS__
  /* Check if a converter is avaliable */
  ptc_convert =
    ptc_request_converter (ptc_converter_depth, ptc_visual->red_mask,
                           ptc_visual->green_mask, ptc_visual->blue_mask);

  if (!ptc_convert)
    {
      /* Close the display */
      XCloseDisplay (ptc_display);
      return 0;
    }

  /* Get the actual bytes-per-pixel value */
  switch (ptc_converter_depth)
    {
    case 8:
      ptc_output_pitch = 1;
      break;
    case 15:
      ptc_output_pitch = 2;
      break;
    case 16:
      ptc_output_pitch = 2;
      break;
    case 24:
      ptc_output_pitch = 3;
      break;
    case 32:
      ptc_output_pitch = 4;
      break;
    }
  /* Allocate the temporary buffer */
  ptc_buffer = (char *) malloc (width * height * ptc_output_pitch);
  if (ptc_buffer == NULL)
    {
      XCloseDisplay (ptc_display);
      return 0;
    }

  if(ptc_converter_depth==8) true_8bit=1;
#else
  /* It runs only on a 8bpp display if no conversions were activated */
  if (ptc_converter_depth != 8)
    {
      XCloseDisplay (ptc_display);
      return 0;
    }
  if(ptc_converter_depth==8) true_8bit=1;
#endif /* __PTC_ENABLE_CONVERSIONS__ */
#ifdef __PTC_DGA__
  /* Check for DGA extension avaliability */
  if (!XF86DGAQueryExtension (ptc_display, &ptc_event_base, &ptc_error_base))
    {
      XCloseDisplay (ptc_display);
      return 0;
    }
  /* Get framebuffer parameters */
  XF86DGAGetVideo (ptc_display, ptc_screen, &ptc_framebuffer_address,
                   &ptc_framebuffer_width, &ptc_framebuffer_banksize,
                   &ptc_framebuffer_memory);
  /* Check if the mode is banked */
  if (ptc_framebuffer_banksize < ptc_framebuffer_memory)
    {
      XCloseDisplay (ptc_display);
      return 0;
    }
  /* Check for VidMode extension avaliability */
  if (!XF86VidModeQueryExtension
      (ptc_display, &ptc_event_base, &ptc_error_base))
    {
      XCloseDisplay (ptc_display);
      return 0;
    }
  /* Get all the mode parameters */
  XF86VidModeGetAllModeLines (ptc_display, ptc_screen, &ptc_totalmodes,
                              &ptc_modeinfodata);
  /* Get current mode parameters */
  XF86VidModeGetModeLine (ptc_display, ptc_screen, &ptc_dotclock,
                          &ptc_currentmodeline);
  /* Search for current mode in parameter list */
  for (ptc_modecounter = 0; ptc_modecounter < ptc_totalmodes;
       ptc_modecounter++)
    {
      if (
          (ptc_currentmodeline.hdisplay ==
           ptc_modeinfodata[ptc_modecounter]->hdisplay)
          && (ptc_currentmodeline.vdisplay ==
              ptc_modeinfodata[ptc_modecounter]->vdisplay))
        {
          /* Save the parameters */
          ptc_previousmode_number = ptc_modecounter;
          ptc_screen_width = ptc_currentmodeline.hdisplay;
          ptc_screen_height = ptc_currentmodeline.vdisplay;
          break;
        }
    }
  ptc_emulate_fullscreen = True;
  /* Search for desired mode in parameter list */
  for (ptc_modecounter = 0; ptc_modecounter < ptc_totalmodes;
       ptc_modecounter++)
    {
      if ((ptc_modeinfodata[ptc_modecounter]->hdisplay == width)
          && (ptc_modeinfodata[ptc_modecounter]->vdisplay == height))
        {
          /* Try to switch mode */
          if (!XF86VidModeSwitchToMode
              (ptc_display, ptc_screen, ptc_modeinfodata[ptc_modecounter]))
            {
              XFree (ptc_modeinfodata);
              XCloseDisplay (ptc_display);
              return 0;
            }
          ptc_emulate_fullscreen = False;
          break;
        }
    }
#ifdef __PTC_BEST_VIDEOMODE__
  /* It works for fullscreen emulation only */
  if (ptc_emulate_fullscreen)
    {
      /* Set up loop */
      ptc_best_delta = INT_MAX;
      ptc_best_videomode = 0;
      /* Check for all avaliable modes */
      for (ptc_modecounter = 0; ptc_modecounter < ptc_totalmodes;
           ptc_modecounter++)
        {
          if ((ptc_modeinfodata[ptc_modecounter]->hdisplay >= width)
              && (ptc_modeinfodata[ptc_modecounter]->vdisplay >= height))
            {
              /* If it fits, get delta parameters */
              ptc_best_x_delta =
                ptc_modeinfodata[ptc_modecounter]->hdisplay - width;
              ptc_best_x_delta *= ptc_best_x_delta;
              ptc_best_y_delta =
                ptc_modeinfodata[ptc_modecounter]->vdisplay - height;
              ptc_best_y_delta *= ptc_best_y_delta;
              /* Check if the mode was fitting better than the previous one */
              if (ptc_best_x_delta + ptc_best_y_delta < ptc_best_delta)
                {
                  /* Set up next iteration */
                  ptc_best_delta = ptc_best_x_delta + ptc_best_y_delta;
                  ptc_best_videomode = ptc_modecounter;
                }
            }
        }
      /* Try to switch mode */
      if (!XF86VidModeSwitchToMode
          (ptc_display, ptc_screen, ptc_modeinfodata[ptc_best_videomode]))
        {
          XFree (ptc_modeinfodata);
          XCloseDisplay (ptc_display);
          return 0;
        }
    }
#endif /* __PTC_BEST_VIDEOMODE__ */
  /* Clear event queue */
  XFlush (ptc_display);
  /* Get the root window */
  ptc_root_window = XRootWindow (ptc_display, ptc_screen);
  /* Get exclusive keyboard access */
  XGrabKeyboard (ptc_display, ptc_root_window, False, GrabModeAsync,
                 GrabModeAsync, CurrentTime);
  /* Get exclusive mouse access */
  XGrabPointer (ptc_display, ptc_root_window, True,
                PointerMotionMask | ButtonPressMask | ButtonReleaseMask,
                GrabModeAsync, GrabModeAsync, None, None, CurrentTime);
  /* Leave root mode */
  setuid (getuid ());
  /* Get viewport parameters */
  XF86DGAGetViewPortSize (ptc_display, ptc_screen,
                          (int *) (&ptc_screen_width),
                          (int *) (&ptc_screen_height));
  /* Set fullscreen emulation up */
  if (ptc_emulate_fullscreen)
    {
      /* Get effective framebuffer address */
#ifdef __PTC_ENABLE_CONVERSIONS__
      ptc_framebuffer_start =
        ptc_framebuffer_width * ((ptc_screen_height - height) / 2) *
        ptc_output_pitch +
        ((ptc_screen_width - width) / 2) * ptc_output_pitch;
      fprintf (stderr, "fbwidth %d\n", ptc_framebuffer_width);
#else
      ptc_framebuffer_start =
        ptc_framebuffer_width * ((ptc_screen_height - height) / 2) 
        + ((ptc_screen_width - width) / 2);
      /*
        ptc_framebuffer_start =
        ptc_framebuffer_width * ((ptc_screen_height - height) / 2) *
        sizeof (int) + ((ptc_screen_width - width) / 2) * sizeof (int);
      */
#endif /* __PTC_ENABLE_CONVERSIONS__ */
    }
  else
    {
      /* Ignore offsets */
      ptc_framebuffer_start = 0;
    }
  /* Get the pitch value */
#ifdef __PTC_ENABLE_CONVERSIONS__
  ptc_framebuffer_pitch = ptc_framebuffer_width * ptc_output_pitch;
#else
  ptc_framebuffer_pitch = ptc_framebuffer_width;
#endif /* __PTC_ENABLE_CONVERSIONS__ */
  /* Do a safety fork */
  if (XF86DGAForkApp (ptc_screen))
    {
      /* Exit DGA mode */
      XF86DGADirectVideo (ptc_display, ptc_screen, False);
      /* Switch back to the previous video mode */
      XF86VidModeSwitchToMode (ptc_display, ptc_screen,
                               ptc_modeinfodata[ptc_previousmode_number]);
      /* Free modeinfo data */
      XFree (ptc_modeinfodata);
      /* Leave exclusive keyboard access */
      XUngrabKeyboard (ptc_display, CurrentTime);
      /* Leave exclusive mouse access */
      XUngrabPointer (ptc_display, CurrentTime);
      /* Close the display */
      XCloseDisplay (ptc_display);
      return 0;
    }
  /* Initialize DGA video access */
  XF86DGADirectVideo (ptc_display, ptc_screen,
                      XF86DGADirectGraphics | XF86DGADirectKeyb |
                      XF86DGADirectMouse);
  /* Clear the screen */
#ifdef __PTC_ENABLE_CONVERSIONS__
  memset (ptc_framebuffer_address, 0x00,
          ptc_framebuffer_width * ptc_screen_height * ptc_output_pitch);
#else
  memset (ptc_framebuffer_address, 0x00,
          ptc_framebuffer_width * ptc_screen_height);
#endif /* __PTC_ENABLE_CONVERSIONS__ */
  /* Select the input events that should be reported */
  XSelectInput (ptc_display, DefaultRootWindow (ptc_display),
                KeyPressMask | KeyReleaseMask);
  /* Set the final viewport */
  XF86DGASetViewPort (ptc_display, ptc_screen, 0, 0);
  /* Clear event queue */
  XFlush (ptc_display);
  /* Save the buffer size */
  ptc_viewport_width = width;
  ptc_viewport_height = height;
#endif /* __PTC_DGA__ */
#ifdef __PTC_WINDOWED__
#ifdef __PTC_XSHM__
  /* Check for XShm extension */
  if (!XShmQueryExtension (ptc_display))
    {
      XCloseDisplay (ptc_display);
      return 0;
    }
#endif /* __PTC_XSHM__ */
  /* Get screen dimensions */
  ptc_screen_width = DisplayWidth (ptc_display, ptc_screen);
  ptc_screen_height = DisplayHeight (ptc_display, ptc_screen);
  /* Get the default root window */
  ptc_root_window = DefaultRootWindow (ptc_display);
  /* Initialize window's attribute structure */
  ptc_window_attributes.border_pixel = BlackPixel (ptc_display, ptc_screen);
  ptc_window_attributes.background_pixel =
    BlackPixel (ptc_display, ptc_screen);
  ptc_window_attributes.backing_store = NotUseful;

  /* 8bit */
  if(true_8bit) 
    {
      ptc_colormap = XCreateColormap(ptc_display, ptc_root_window, ptc_visual, AllocAll);
      for(i=0; i<0x100; i++)
        {
          ptc_xcolors[i].flags = DoRed | DoGreen | DoBlue;
          ptc_xcolors[i].pixel = i;
          ptc_xcolors[i].pad = 0;
        }
      ptc_window_attributes.colormap = ptc_colormap;
    }
#ifdef __PTC_CENTER_WINDOW__
  /* Center the window on the screen */
  ptc_x_position = (ptc_screen_width - width) / 2;
  ptc_y_position = (ptc_screen_height - height) / 2;
#else
  /* Dock the window on the top-left corner */
  ptc_x_position = 0;
  ptc_y_position = 0;
#endif /* __PTC_CENTER_WINDOW__ */
  /* Create the window */
  ptc_window =
    XCreateWindow (ptc_display, ptc_root_window, ptc_x_position,
                   ptc_y_position, width, height, 0, ptc_depth, InputOutput,
                   ptc_visual, CWBackPixel | CWBorderPixel | CWBackingStore |
                   CWColormap, &ptc_window_attributes);
                   //                   (true_8bit ? CWColormap : 0), &ptc_window_attributes);
  if(true_8bit) 
    {
      XInstallColormap(ptc_display, ptc_colormap);
      XSetWindowColormap(ptc_display, ptc_root_window, ptc_colormap);
    }

  /* Set the window's name */
  XStoreName (ptc_display, ptc_window, title);
  /* Tell the server to report only keypress-related events */
  XSelectInput (ptc_display, ptc_window, KeyPressMask);
  /* Initialize window's sizehint definition structure */
  ptc_window_sizehints.flags = PPosition | PMinSize | PMaxSize;
  ptc_window_sizehints.x = 0;
  ptc_window_sizehints.y = 0;
  ptc_window_sizehints.min_width = width;
  ptc_window_sizehints.max_width = width;
  ptc_window_sizehints.min_height = height;
  ptc_window_sizehints.max_height = height;
  /* Set the window's sizehint */
  XSetWMNormalHints (ptc_display, ptc_window, &ptc_window_sizehints);
  /* Clear the window */
  XClearWindow (ptc_display, ptc_window);
  /* Put the window on top of the others */
  XMapRaised (ptc_display, ptc_window);
  /* Clear event queue */
  XFlush (ptc_display);
  /* Get the default graphic context */
  ptc_window_gc = DefaultGC (ptc_display, ptc_screen);
#ifdef __PTC_XSHM__
  /* Create an XShmImage */
  ptc_ximage =
    XShmCreateImage (ptc_display, ptc_visual, ptc_depth, ZPixmap, 0,
                     &ptc_shm_segment, width, height);
  /* Get a shared segment */
  ptc_shm_segment.shmid =
    shmget (IPC_PRIVATE, ptc_ximage->bytes_per_line * ptc_ximage->height,
            IPC_CREAT | 0777);
  /* Initialize XShmImage data buffer pointer */
  ptc_ximage->data = shmat (ptc_shm_segment.shmid, 0, 0);
  /* Save buffer address */
  ptc_shm_segment.shmaddr = ptc_ximage->data;
  /* Put the segment in read/write */
  ptc_shm_segment.readOnly = False;
  /* Attach the segment to the display */
  if (!XShmAttach (ptc_display, &ptc_shm_segment))
    {
      /* Destroy the image */
      // FIXME: i get segfaults...      XDestroyImage (ptc_ximage);
      /* Detach the buffer from the segment */
      shmdt (ptc_shm_segment.shmaddr);
      /* Remove the segment */
      shmctl (ptc_shm_segment.shmid, IPC_RMID, 0);
      /* Destroy the window */
      XDestroyWindow (ptc_display, ptc_window);
      /* Close the display */
      XCloseDisplay (ptc_display);
      return 0;
    }
#else
  /* Create an XImage */
  ptc_ximage =
    XCreateImage (ptc_display, CopyFromParent, ptc_depth, ZPixmap, 0, NULL,
                  width, height, 8, width);
    /*
    XCreateImage (ptc_display, CopyFromParent, ptc_depth, ZPixmap, 0, NULL,
                  width, height, 32, width * 2);
    */
#endif /* __PTC_XSHM__ */
  /* Save windowsize values */
  ptc_viewport_width = width;
  ptc_viewport_height = height;
#endif /* __PTC_WINDOWED__ */
  return 1;
}


int 
ptc_setpal(unsigned char * p)
{
  int i;

  palette = p;

  if(true_8bit)
    {
      for(i=0; i<0x100; i++)
        {
          ptc_xcolors[i].flags = DoRed | DoGreen | DoBlue;
          ptc_xcolors[i].pixel = i;
          ptc_xcolors[i].pad = 0;

          ptc_xcolors[i].red   = palette[i*3+0] << 8;
          ptc_xcolors[i].green = palette[i*3+1] << 8;
          ptc_xcolors[i].blue  = palette[i*3+2] << 8;
        }
      XStoreColors(ptc_display, ptc_colormap, ptc_xcolors, 0x100);
    }

  // success
  return 1;
}


/* Update the screen */

int
ptc_update (void *buffer)
{
#ifdef __PTC_WINDOWED__
#ifdef __PTC_XSHM__
  /* Copy buffer data into the XShmImage */
#ifdef __PTC_ENABLE_CONVERSIONS__
  ptc_source_index = 0;
  ptc_destination_index = 0;
  /* Convert the image line by line */
  for (ptc_blitcounter = 0; ptc_blitcounter < ptc_viewport_height;
       ptc_blitcounter++)
    {
      /* Conversion */
      if(true_8bit)
        memcpy((ptc_ximage->data) + ptc_destination_index, buffer + ptc_source_index, ptc_viewport_width);
      else
        ptc_convert (buffer + ptc_source_index,
                     (ptc_ximage->data) + ptc_destination_index,
                     ptc_viewport_width, palette);

      /* Pointers update */
      ptc_source_index += ptc_viewport_width;
      ptc_destination_index += ptc_viewport_width * ptc_output_pitch;
    }
#else
  /* Blit the image */
  memcpy (ptc_ximage->data, buffer,
          ptc_viewport_width * ptc_viewport_height);
#endif /* __PTC_ENABLE_CONVERSIONS__ */
  /* Synchronize the even queue */
  XSync (ptc_display, 0);
  /* Put the buffer on the window */
  XShmPutImage (ptc_display, ptc_window, ptc_window_gc, ptc_ximage, 0, 0, 0,
                0, ptc_viewport_width, ptc_viewport_height, False);
#else
#ifdef __PTC_ENABLE_CONVERSIONS__
  ptc_ximage->data = ptc_buffer;
  ptc_source_index = 0;
  ptc_destination_index = 0;
  /* Convert the image line by line */
  for (ptc_blitcounter = 0; ptc_blitcounter < ptc_viewport_height;
       ptc_blitcounter++)
    {
      /* Conversion */
      if(true_8bit)
        memcpy((ptc_ximage->data) + ptc_destination_index, buffer + ptc_source_index, ptc_viewport_width);
      else
        ptc_convert (buffer + ptc_source_index,
                     (ptc_ximage->data) + ptc_destination_index,
                     ptc_viewport_width, palette);

      /* Pointers update */
      ptc_source_index += ptc_viewport_width;
      ptc_destination_index += ptc_viewport_width * ptc_output_pitch;
    }
#else
  /* Set XImage's data buffer value with the supplied buffer pointer */
  ptc_ximage->data = (char *) buffer;
#endif /* __PTC_ENABLE_CONVERSIONS__ */
  /* Put the buffer on the window */
  XPutImage (ptc_display, ptc_window, ptc_window_gc, ptc_ximage, 0, 0, 0, 0,
             ptc_viewport_width, ptc_viewport_height);
  /* Check for incoming events */
  XFlush (ptc_display);
#endif /* __PTC_XSHM__ */
#endif /* __PTC_WINDOWED__ */
#ifdef __PTC_DGA__
  ptc_framebuffer_index = 0;
#ifdef __PTC_ENABLE_CONVERSIONS__
  ptc_source_index = 0;
  ptc_destination_index = 0;
#endif /* __PTC_ENABLE_CONVERSIONS__ */
  /* Do the blit line by line */
  for (ptc_blitcounter = 0; ptc_blitcounter < ptc_viewport_height;
       ptc_blitcounter++)
    {
#ifdef __PTC_ENABLE_CONVERSIONS__
      /* Conversion */
      if(true_8bit)
        memcpy((ptc_ximage->data) + ptc_destination_index, buffer + ptc_source_index, ptc_viewport_width);
      else
        ptc_convert (buffer + ptc_source_index,
                     (ptc_ximage->data) + ptc_destination_index,
                     ptc_viewport_width, palette);

      /* Pointers update */
      ptc_source_index += ptc_viewport_width;
      ptc_destination_index += ptc_framebuffer_pitch;
#else
      /* Copy the data */
      memcpy (ptc_framebuffer_address + ptc_framebuffer_start +
              ptc_framebuffer_index, buffer,
              ptc_viewport_width);
      buffer += ptc_viewport_width;
      /* Set up offsets */
      ptc_framebuffer_index += ptc_framebuffer_pitch;
#endif /* __PTC_ENABLE_CONVERSIONS__ */
    }
#endif /* __PTC_DGA__ */
  /* Process incoming events */
  if (ptc_process_events ())
    {
      ptc_close ();
      exit (0);
    }
  return 1;
}

/* Process events */

int
ptc_process_events (void)
{
  XEvent ptc_xevent;
  KeySym ptc_keysym;
  /* Check if there are events waiting in the display's queue */
  if (XPending (ptc_display))
    {
      /* Get the next event in queue */
      XNextEvent (ptc_display, &ptc_xevent);
      /* Check if it's a keypress event */
      if (ptc_xevent.type == KeyPress)
        {
          /* Get the keysym */
          ptc_keysym = XLookupKeysym (&ptc_xevent.xkey, 0);
          /* Check if the key pressed was a function one */
          if ((ptc_keysym >> 8) == __PTC_FUNCTION_KEY__)
            {
              /* Check if it was the escape key */
              if ((ptc_keysym & 0xFF) == __PTC_ESCAPE_KEY__)
                {
                  return 1;
                }
            }
        }
    }
  return 0;
}

/* Close the screen */

void
ptc_close (void)
{
#ifdef __PTC_WINDOWED__
#ifdef __PTC_XSHM__
  /* Detach the segment from the display */
  XShmDetach (ptc_display, &ptc_shm_segment);
  /* Destroy the XShmImage */
  // FIXME: i get segfaults...     XDestroyImage (ptc_ximage);
  /* Detach the buffer from the segment */
  shmdt (ptc_shm_segment.shmaddr);
  /* Remove the segment */
  shmctl (ptc_shm_segment.shmid, IPC_RMID, 0);
#else
  /* Restore XImage's buffer pointer */
  ptc_ximage->data = NULL;
  /* Destroy the XImage */
  // FIXME: i get segfaults...     XDestroyImage (ptc_ximage);
#endif /* __PTC_XSHM__ */
  /* Close the window */
  XDestroyWindow (ptc_display, ptc_window);
#endif /* __PTC_WINDOWED__ */
#ifdef __PTC_DGA__
  /* Exit from DGA mode */
  XF86DGADirectVideo (ptc_display, ptc_screen, False);
  /* Switch back to the previous video mode */
  XF86VidModeSwitchToMode (ptc_display, ptc_screen,
                           ptc_modeinfodata[ptc_previousmode_number]);
  /* Free modeinfo data */
  XFree (ptc_modeinfodata);
  /* Leave exclusive keyboard access */
  XUngrabKeyboard (ptc_display, CurrentTime);
  /* Leave exclusive mouse access */
  XUngrabPointer (ptc_display, CurrentTime);
#endif /* __PTC_DGA__ */
  /* Close the display */
  XCloseDisplay (ptc_display);
  /* Deallocate the buffer */
  if (ptc_buffer)
    {
      free (ptc_buffer);
    }
}
