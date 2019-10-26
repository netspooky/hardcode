/*
 *  Real-time soft shadows.  Press 'h' for a help menu.  Drag the
 *  middle mouse button to rotate the scene.
 *
 *  author: Nate Robins
 *  email: ndr@pobox.com
 *  www: http://www.pobox.com/~ndr
 */

/* includes */
#include <math.h>
#include <stdio.h>
#include <GL/glut.h>
#include "trackball.h"
#include "metalib.h"


float R1=0.2;
float R2=0.3;
float R3=0.4;

float xb1,yb1,zb1;
float xb2,yb2,zb2;
float xb3,yb3,zb3;

float spin=0;
#define DSPIN 3.14/90
float dspin=DSPIN;
float zoom=1.0;

char envmap[64*64*3];



float f(float x,float y,float z);
float fr(float x,float y,float z);
float fg(float x,float y,float z);
float fb(float x,float y,float z);

GLboolean texturing = GL_FALSE;		/* draw with texturing? */
GLboolean draw_sample_vectors = GL_FALSE;
GLboolean view_from_light = GL_FALSE;	/* view fromthe light? */
GLboolean jittered = GL_FALSE;		/* jittered sampling? */
GLboolean draw_shadows = GL_TRUE;	/* draw shadows? */
GLboolean frame_rate = GL_FALSE;	/* show frame rate? */


/* functions */

void
normalize(GLfloat* n)
{
  GLfloat l;

  /* normalize */
  l = (GLfloat)sqrt(n[0] * n[0] + n[1] * n[1] + n[2] * n[2]);
  n[0] /= l;
  n[1] /= l;
  n[2] /= l;
}

void
cross(GLfloat* u, GLfloat* v, GLfloat* n)
{
  
  n[0] = u[1] * v[2] - u[2] * v[1];
  n[1] = u[2] * v[0] - u[0] * v[2];
  n[2] = u[0] * v[1] - u[1] * v[0];
}


void
init(void)
{
  int i,j;

  GLuint	Envmap;

  tbInit(GLUT_LEFT_BUTTON);

 
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_COLOR_MATERIAL);

/*  glBlendFunc(GL_ZERO, GL_SRC_ALPHA);*/

  glEnable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  glDepthFunc(GL_LEQUAL);

  glEnable(GL_CULL_FACE);

  glClearStencil(0);

  for(j=0;j<64;j++)	
    {
     for(i=0;i<64;i++)	
      {
	envmap[3*(j*64+i)  ]=5*(i&16) + 5*(j&16);
        envmap[3*(j*64+i)+1]=0;
        envmap[3*(j*64+i)+2]=0;

      }       
    }

  glGenTextures(1, &Envmap);
  glBindTexture(GL_TEXTURE_2D, Envmap);

  // a remplacer 64 et 64 pour la taille de ta texture et env2 la zone memoire de ta texture en RVB (24 bits)
  gluBuild2DMipmaps(GL_TEXTURE_2D, 3, 64, 64, GL_RGB, GL_UNSIGNED_BYTE, (unsigned char*) envmap); 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_NEAREST);
  glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
  glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);


  glEnable(GL_NORMALIZE);
  glEnable(GL_TEXTURE_GEN_S);
  glEnable(GL_TEXTURE_GEN_T);
}

void
reshape(int width, int height)
{
GLfloat  light_pos[4] = { 0.0, 0.0, 0.0, 1.0 };
  tbReshape(width, height);

  glViewport(0, 0, width, height);
  
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  gluPerspective(30.0, (GLfloat)width / (GLfloat)height, 0.5, 30.0);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
  /*
  glTranslatef(0.0, -10.0, -30.0);
  glRotatef(-20.0, 0.0, 1.0, 0.0);
  */
  glLightfv(GL_LIGHT0, GL_POSITION, light_pos);
  glTranslatef(0.0, 0.0, -1.5);
  
}

void
display(void)
{
  static GLuint i;
  static int start, end;
   float *P,*p1,*p2,*p3,*Norm;
   float *RGB;
   int   *F;
   int   NP,NF;

   static float U[3],V[3],W[3];


 

  if(frame_rate)
    start = glutGet(GLUT_ELAPSED_TIME);

  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

  /* do the trackball rotation. */
  glPushMatrix();

  tbMatrix();

  spin+=dspin;

  xb1=(0.6*cos(spin/3))*cos(spin);
  yb1=(0.6*cos(spin/3))*sin(spin);  
  zb1=(0.6*sin(spin/5));

  xb2=0.4*cos(spin);
  yb2=0.3*sin(spin/3);
  zb2=0.4*sin(spin);

  yb3=0.5*cos(spin*2);
  zb3=-0.3*sin(spin/3);
  xb3=0.5*sin(spin);

/*  meta_objectRGB(&P,&F,&RGB,&NF,&NP,&fr,&fg,&fb,1/(R1*R1));*/
   
 meta_objectNO(&P,&F,&Norm,&NF,&NP,&f,1/(R1*R1));
/*  printf("%d %d\n",NP,NF);*/

  glBegin(GL_TRIANGLES);
  /*glColor3f(0.0, 1.0, 0.0);*/
  for(i=0;i<NF;i++)
    {
     /*glNormal3fv(N + 3*i);*/
     /*  glColor3fv(RGB+3*i);*/

       p1  =P + 3*F[3*i  ];
       p2  =P + 3*F[3*i+1];
       p3  =P + 3*F[3*i+2];

/*
       U[0]=p2[0]-p1[0];
       U[1]=p2[1]-p1[1];
       U[2]=p2[2]-p1[2];

       V[0]=p3[0]-p1[0];
       V[1]=p3[1]-p1[1];
       V[2]=p3[2]-p1[2];

       cross(U, V, W);

       normalize(W);


       glNormal3fv(W);
*/

       /*glColor3fv(RGB + 3*F[3*i ]);*/
       glNormal3fv(Norm + 3*F[3*i ]);
       glVertex3fv(p1);
       /*glColor3fv(RGB + 3*F[3*i+1]);*/
       glNormal3fv(Norm + 3*F[3*i+1]);
       glVertex3fv(p2);
       /*glColor3fv(RGB + 3*F[3*i+2]);*/
       glNormal3fv(Norm + 3*F[3*i+2]);
       glVertex3fv(p3);
    }
  glEnd();



  glPopMatrix();

  glutSwapBuffers();

  glutPostRedisplay();
  
  if (frame_rate) {
    glFinish();				/* make sure rendering is done */
    end = glutGet(GLUT_ELAPSED_TIME);
    fprintf(stderr, " %.1f fps       \r", 
	    1.0 / ((double)(end - start) / 1000.0));
  }
}

void
special(int key, int x, int y)
{
  switch (key) { 
    case GLUT_KEY_UP:
      break;

    case GLUT_KEY_DOWN:
      break;

    case GLUT_KEY_RIGHT:
      break;

    case GLUT_KEY_LEFT:
      break;
 }

  glutPostRedisplay();
}

void
keyboard(char key, int x, int y)
{
  switch (key) {
  case 'h':
    printf("shadow help\n\n");
    printf("f            -  Filled\n");
    printf("w            -  Wireframe\n");
    printf("o            -  Potatoes\n"); 
    printf("j            -  Merguez\n");
    printf("c            -  ragnagna\n");
    printf("S            -  Print stats\n");
    printf("F            -  Show frame rate\n");
    printf("escape or q  -  Quit\n\n");
    break;

  case 'F':
    frame_rate = !frame_rate;
    break;

  case 'S':

    break;

  case 'j':
    jittered = !jittered;
    printf("jittered = %d\n", jittered);
    break;

  case 'o':
    draw_shadows = !draw_shadows;
    break;

  case 's':
    draw_sample_vectors = !draw_sample_vectors;
    break;

  case 'f':
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    break;

  case 'w':
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
    break;

  case 'c':
    if (glIsEnabled(GL_CULL_FACE))
      glDisable(GL_CULL_FACE);
    else
      glEnable(GL_CULL_FACE);      
    break;

  case 'n':
       spin+=DSPIN;
     
    break;

  case 'p':
    if(dspin==0.0) dspin=DSPIN;
    else dspin=0.0;
    break;

  case 'V':
    view_from_light = !view_from_light;
    break;

  case 'r':
    tbInit(GLUT_MIDDLE_BUTTON);
    break;

  case '+':
    zoom+=0.1;
    break;

  case '-':
    zoom-=0.1;
    break;

  case 'L':

    break;

  case 'l':

    break;

  case 'q':
  case 27:
    exit(0);
    break;
  }

  glutPostRedisplay();
}

void
mouse(int button, int state, int x, int y)
{
  tbMouse(button, state, x, y);
}

void
motion(int x, int y)
{
  tbMotion(x, y);
}

float f(float x,float y,float z)
{

  float r,a;
  float r1,r2;
  /*static float R1=0.5;
    static float R2=0.7;*/
  float  alpha;

  alpha=R2*R2/(R1*R1);

  r=0;
  /*a=0.035;
  if(x>-1 && x<=0 && y>-1 && y<=0 && z>-1 && z<=0) {r=1;}*/
  r =(x-2.3)*(x-2.3)+y*y+z*z;
  r+=(x+2.3)*(x+2.3)+y*y+z*z;

  r1=(x-xb1)*(x-xb1) + (y-yb1)*(y-yb1) + (z-zb1)*(z-zb1);
  /*r1=r1*r1;*/

  /*r2=(x-(0.5))*(x-(0.5)) + y*y + z*z;*/
  r2=(x-xb2)*(x-xb2) + (y-yb2)*(y-yb2) + (z-zb2)*(z-zb2);
  /*r2=r2*r2;*/

  if(r1==0.0) r1=99999;
  else r1=1/r1;

  if(r2==0.0) r2=99999;
  else r2=1/r2;
  
  r= r1 + alpha*r2;
  
  return(r);
}


float fr(float x,float y,float z)
{
  float r;
 
 
  r=(x-xb1)*(x-xb1) + (y-yb1)*(y-yb1) + (z-zb1)*(z-zb1);
  
 
  if(r==0.0) r=99999;
  else r=1/r;

  return(r);
}



float fg(float x,float y,float z)
{

  float r;
  float  alpha;

  alpha=R2*R2/(R1*R1);

 
  r=(x-xb2)*(x-xb2) + (y-yb2)*(y-yb2) + (z-zb2)*(z-zb2);
 
 
  if(r==0.0) r=99999;
  else r=1/r;
 
  r=alpha*r;
 
  return(r);
}

float fb(float x,float y,float z)
{

  float r;
  float  alpha;

  alpha=R3*R3/(R1*R1);

 
  r=(x-xb3)*(x-xb3) + (y-yb3)*(y-yb3) + (z-zb3)*(z-zb3);
 
 
  if(r==0.0) r=99999;
  else r=1/r;
 
  r=alpha*r;
 
  return(r);
}








int
main(int argc, char** argv)
{
  int buffer = GLUT_DOUBLE;

  glutInit(&argc, argv);

  while (--argc) {
    if (strcmp("-sb", argv[argc]) == 0) {
      buffer = GLUT_SINGLE;
    } else {
      printf("%s [-sb]\n", argv[0]);
      printf("  -sb   single buffered\n");
      exit(0);
    }
  }

  glutInitWindowSize(512, 512);
  glutInitDisplayMode(GLUT_RGB | buffer | GLUT_DEPTH | GLUT_STENCIL | GLUT_MULTISAMPLE);
  glutCreateWindow("Shadow");
  
  glutReshapeFunc(reshape);
  glutDisplayFunc(display);
  glutKeyboardFunc(keyboard);
  glutSpecialFunc(special);
  glutMouseFunc(mouse);
  glutMotionFunc(motion);
  
  init();

  /*init_metalib(5,3000,8000);*/
  /*init_metalibRGB(5,4000,10000);*/

  init_metalibNO(5,4000,10000);

  /*glShadeModel(GL_SMOOTH);*/
  glutMainLoop();
  return 0;
}
