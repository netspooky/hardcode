#define DRIVE_VIDEO
#define DRIVE_AUDIO

#define DRIVE_GB

#ifdef UNIX
#define __POSIX__
#define DRIVE_UNIX
#define DRIVE_TTY
#define DRIVE_TTY_ANSI
#define DRIVE_TTY_DEC
#undef  DRIVE_TTY_VT200
#define HAVE_TTYSTUFF
#endif
