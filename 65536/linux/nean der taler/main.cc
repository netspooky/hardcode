/*
    The wrapper for neandertaler_mainloop.cc. Uses GLUT for opening the
    screen and MikMod + a child process for sound. Rather ugly C++ code,
    since it's mostly ripped from my old C sources.

    -Marq 2001
*/

#include <GL/glut.h>
#include <GL/glu.h>

#ifdef SOUND
#include <mikmod.h>
#endif

#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>

#define WIDTH  640  // Default size for the window
#define HEIGHT 480

#define PTNDURATION 5370 // Approximated pattern duration in ms

int child;  // Child's PID

volatile int    row=0,      // Used by the demo
                pattern=0;
volatile long   currentTime=0;

// The picture datas
unsigned char   font_raw[429*30],
                slider1_raw[64*64],
                slider2_raw[64*64],
                slider3_raw[64*64],
                slider4_raw[64*64],
                slider5_raw[64*64];
                
extern void init();
extern int mainloop();

void piirra(void);  //  Draw callback
void akti(void);    //  Idle callback
void nappi(unsigned char b,int x,int y);    //  Keyboard callback

void updatetimer(void); //  Updates the currentTime, row and pattern
void loadfile(char *name,void *dest); // Simply loads a file

main(int argc,char *argv[])
{
    // First, let's load the pictures
    loadfile("data/font.raw",font_raw);
    loadfile("data/slider1.raw",slider1_raw);
    loadfile("data/slider2.raw",slider2_raw);
    loadfile("data/slider3.raw",slider3_raw);
    loadfile("data/slider4.raw",slider4_raw);
    loadfile("data/slider5.raw",slider5_raw);

#ifdef SOUND
    MODULE  *piisi;

    /*  Load the module and set up sound.
        Partially from some intro by Smoke/ECFH. */

#ifdef BSDENV
    setenv("MM_FRAGSIZE","16",0);    // Smaller latency, smoother demo
#endif

    MikMod_RegisterAllDrivers();
    MikMod_RegisterLoader(&load_xm);
    md_mixfreq=44100;
    MikMod_Init("");
    piisi=Player_Load("data/far_away.xm",12,0);
    Player_SetVolume(100);
    Player_Start(piisi);
#endif

    //  Initialize GLUT
    glutInit(&argc,argv);
    glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA|GLUT_DEPTH);
    glutInitWindowSize(WIDTH,HEIGHT);

// New GLUT (>=3.7) has fullscreen, older ones don't
#ifndef OLDGLUT
    glutCreateWindow("Nean der taler by Macaw & Prat (hit space for fullscreen)");

    if(argc>=2)
        if(!strcmp(argv[1],"-f"))
            glutFullScreen();
#else
    glutCreateWindow("Nean der taler by Macaw & Prat");
#endif

    glutSetCursor(GLUT_CURSOR_NONE);
    glutDisplayFunc(piirra);
    glutIdleFunc(akti);
    glutKeyboardFunc(nappi);

    //  Initialize GL
    glEnable(GL_TEXTURE_2D);
    glViewport(0,0,WIDTH,HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0f,(float)(WIDTH/HEIGHT),0.1f,100.0f);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClearColor(0, 0, 0, 0);

    //  Initialize the demo engine
    init();

#ifdef SOUND
    //  A child process will play the music
    if(!(child=fork()))
    {
        while(1)
            MikMod_Update();
    }
#endif

    //  Here we go! GLUT eventloop
    glutMainLoop();
}

void piirra(void)
{
    //  Update the currentTime, row and pattern variables
    updatetimer();

    //  Call the mainloop and swap screens
    mainloop();
    glutSwapBuffers();
}

void akti(void)
{
    glutPostRedisplay();
}

void nappi(unsigned char b,int x,int y)
{
// GLUT <3.7 doesn't support fullscreen
#ifndef OLDGLUT
    if(b==' ')
        glutFullScreen();
#endif

    if(b==27) // If ESC pressed, kill child (if any) and exit
    {
#ifdef SOUND
        kill(child,SIGTERM);
#endif
        exit(EXIT_SUCCESS);
    }
}

void updatetimer(void)
{
    double  aeka;

    static long    alux=0;

    struct timeval  system_time;
    struct timezone system_timezone;

    // Get the exact timer value
    gettimeofday(&system_time,&system_timezone);
    if(!alux)
        alux=system_time.tv_sec;

    // Convert timer value to milliseconds
    aeka=1000.0*((double)(system_time.tv_sec-alux))+
         ((double)system_time.tv_usec)/1000.0;

    // It seems we need to slow the timer down a bit to retain music sync
    aeka*=0.975;

    // Approximate the row and pattern counters (dirty but works)
    row=long(aeka)%PTNDURATION/(PTNDURATION/64);
    pattern=long(aeka)/PTNDURATION;
    currentTime=long(aeka);
}

void loadfile(char *name,void *dest)
{
    FILE    *f;

    long    len;

    if((f=fopen(name,"rb"))==NULL)
    {
        printf("Data file %s not found\n",name);
        exit(EXIT_FAILURE);
    }

    fseek(f,0,SEEK_END);
    len=ftell(f);
    fseek(f,0,SEEK_SET);
    fread(dest,1,len,f);
    fclose(f);
}

/*  EOS */
