#include <windows.h>
#include <gl\gl.h>
#include <gl\glu.h>


#include "tool.h"
#include "audio.h"
#include "scene.h"
#include "define.h"

GLuint glow;
float end=95;
float mov;
static float last_time,current_time,elapsed_time;
GLfloat position[] = { 0, 10, 0, 1 };
GLfloat color[4] = {1,1,1,1};
extern float startscene;

void RenderScene();
void RenderGlow( int nbPass, float precision, float alpha );
void Cube(float size);


//-----------------------------------------------------------------------------
// InitScene
//-----------------------------------------------------------------------------
void InitScene()
{
    //InitGL
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(70,4/3.0f,0.1,2000.0);
    glMatrixMode(GL_MODELVIEW);
	glEnable(GL_DEPTH_TEST);
	glFogi(GL_FOG_MODE,GL_LINEAR);
	glFogf(GL_FOG_START,0);
	glFogf(GL_FOG_END,95);
	glEnable(GL_FOG);
    glClearColor(1,1,1,1);
    glFogfv(GL_FOG_COLOR, color);


    //Glow
	glGenTextures(1, &glow);
    glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, glow);
	/*unsigned int* data;
        // On alloue de la place pour notre texture de 512x512
	data = (unsigned int*)new GLuint[((512 * 512)* 4 * sizeof(unsigned int))];
        // On nettoie les données en les remplissant de 0
	ZeroMemory(data,((512 * 512)* 4 * sizeof(unsigned int)));*/
        // On effectue la première passe
	//glTexImage2D(GL_TEXTURE_2D, 0, 4, 512, 512, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
 
	//delete [] data;
	glDisable(GL_TEXTURE_2D);

}








//-----------------------------------------------------------------------------
// DrawScene
//-----------------------------------------------------------------------------
void DrawScene()
{
    //----------------------------------------------------
    //Update
    mov+=0.0003*elapsed_time;
    current_time = (float)GetTickCount();
    elapsed_time = current_time - last_time;
    last_time = current_time;

    glViewport(0,0,512,512);
    RenderScene();
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, glow);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
    glDisable(GL_TEXTURE_2D);
    
    glViewport(0,0,RESX,RESY);
    RenderScene();

    if(GetTickCount()-startscene<12000)
        RenderGlow(10,400,0.4);
    else
        RenderGlow(20,200,0.8);
    glFlush();
}








//-----------------------------------------------------------------------------
// RenderToTexture
//-----------------------------------------------------------------------------
void RenderScene()
{

    //----------------------------------------------------
    //Render
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

    //Camera
    if(GetTickCount()-startscene<12000)
        gluLookAt( -25+mov*5,-5-cos(mov)*5,-45,       -25+mov*5,0,0,    0,1,0);
    else
        gluLookAt(cos(mov)*20, 6+sin(mov)*10 ,sin(mov*1.5)*50,       cos(sin(-mov))*20,sin(cos(mov))*20,sin(sin(mov))*20, 0,1,0);


    glLightfv(GL_LIGHT0, GL_POSITION, position);

    glPushMatrix();
    glTranslatef(-50,-50,-50);
    for(int x=0; x<10; x++)
    {
        for(int y=0; y<10; y++)
        {
            for(int z=0; z<10; z++)
            {
                glPushMatrix();
                glTranslatef(x*10,y*10,z*10);
                Cube(1+cos(mov*x*y*z/30)/2.0f);
                glPopMatrix();
            }
        }
    }
    glPopMatrix();
}







//-----------------------------------------------------------------------------
// RenderGlow
//-----------------------------------------------------------------------------
void RenderGlow( int nbPass,float precision,float alpha )
{
   
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho( 0, 512 , 0, 512, -1, 1 );
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();
 
	glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, glow);
 
	glBegin(GL_QUADS);
        for (int i=0; i<nbPass; i++)
        {
	        glColor4f(1., 1., 1., alpha/(float)i);

            glTexCoord2f(0+((float)i/precision),0+((float)i/precision));
	        glVertex2d(0,0);
 
            glTexCoord2f(0+((float)i/precision),1-((float)i/precision));
	        glVertex2d(0,512);
 
            glTexCoord2f(1-((float)i/precision),1-((float)i/precision));
	        glVertex2d(512,512);
 
            glTexCoord2f(1-((float)i/precision),0+((float)i/precision));
	        glVertex2d(512,0);
        }
	glEnd();


	

	glMatrixMode( GL_PROJECTION );
	glPopMatrix();
	glMatrixMode( GL_MODELVIEW );
	glPopMatrix();
    glEnable(GL_LIGHTING);
	glEnable(GL_DEPTH_TEST);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);

    if(GetTickCount()-startscene>END_TIME-1500 && end>1)
    {
        glFogf(GL_FOG_END,end);
        end-=0.09*elapsed_time;
    }
    else
    {
        glColor4f(1,1,1,1);
    }
}









//-----------------------------------------------------------------------------
// Cube
//-----------------------------------------------------------------------------
void Cube(float size)
{
glBegin(GL_QUADS);
    glNormal3f( 0.0f, 1.0f,0.0f);
    glVertex3f(size,size,size);
    glVertex3f(size,size,-size);
    glVertex3f(-size,size,-size);
    glVertex3f(-size,size,size);

    glNormal3f( 1.0f, 0.0f,0.0f);
    glVertex3f(size,-size,size);
    glVertex3f(size,-size,-size);
    glVertex3f(size,size,-size);
    glVertex3f(size,size,size);

    glNormal3f( 0.0f,-1.0f,0.0f);
    glVertex3f(-size,-size,size);
    glVertex3f(-size,-size,-size);
    glVertex3f(size,-size,-size);
    glVertex3f(size,-size,size);

    glNormal3f( -1.0f, 0.0f,0.0f);
    glVertex3f(-size,size,size);
    glVertex3f(-size,size,-size);
    glVertex3f(-size,-size,-size);
    glVertex3f(-size,-size,size);

    glNormal3f( 0.0f, 0.0f,-1.0f);
    glVertex3f(size,size,-size);
    glVertex3f(size,-size,-size);
    glVertex3f(-size,-size,-size);
    glVertex3f(-size,size,-size);

    glNormal3f( 0.0f, 0.0f,1.0f);
    glVertex3f(size,-size,size);
    glVertex3f(size,size,size);
    glVertex3f(-size,size,size);
    glVertex3f(-size,-size,size);

    glEnd();
}


