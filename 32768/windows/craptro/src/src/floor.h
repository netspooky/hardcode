#include "sys/msys.h"
#include "intro.h"


#include "star.h"
#include "checkerboard.h"

GLuint check_tex;
GLuint star_sprite;

#define NUM_STARS 32
typedef struct  
{
	float x,y,rot,speed;
	int xsize,ysize;
	float rcol,gcol,bcol;

}_star_sprites;
_star_sprites starsprites[NUM_STARS];

#define NUM_OBJ 12
typedef struct  
{
	float x,y,z,rot,speed;
	float rcol,gcol,bcol;
}_floor_obj;
_floor_obj floor_obj[NUM_OBJ];

GLuint starfield_screentexture;
int starfield_shaderobj;
GLuint starfield_shadertexture;
GLuint resolution_uniform;
float resolution[4] = {XRES,YRES,0,0};

const char vert[] = ""
	"varying vec4 vPos;"
	"void main()"
	"{"
	"gl_Position=gl_ModelViewProjectionMatrix*gl_Vertex,gl_TexCoord[0]=gl_MultiTexCoord0,vPos=gl_Position;"
	"}";


const char user_shader_388179211_frag[] = ""
	"uniform sampler2D Image;"
	"vec2 samples[12]={-.326212,-.405805,-.840144,-.07358,-.695914,.457137,-.203345,.620716,.96234,-.194983,.473434,-.480026,.519456,.767022,.185461,-.893124,.507431,.064425,.89642,.412458,-.32194,-.932615,-.791559,-.597705};"
	"void main()"
	"{"
	"vec2 p=gl_TexCoord[0].rg;"
	"vec4 color=texture2D(Image,p);"
	"float BlurFactor=.01;"
	"for(int i=0;i<4;i++)"
	"color+=texture2D(Image,p+BlurFactor*samples[i]);"
	"color/=5;"
	"gl_FragColor=color;"
	"}";

void initshadetex()
{
	unsigned char* texturedata = new unsigned char[4 * XRES * YRES];
	memset(texturedata,0,4*XRES*YRES);
	//texture
	glEnable(GL_TEXTURE_2D);
	glGenTextures(1, &starfield_screentexture);
	glBindTexture(GL_TEXTURE_2D,  starfield_screentexture);
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
	glTexParameterf(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, XRES, YRES, 0, GL_RGBA,
		GL_UNSIGNED_BYTE, texturedata);
	glGetError();
	glBindTexture(GL_TEXTURE_2D,  0);
	delete [] texturedata;
}

int rand_range(int min_n, int max_n)
{
	return rand() % (max_n - min_n + 1) + min_n;
}

float rand_rangef(float a, float b)
{
	return ((b-a)*((float)rand()/RAND_MAX))+a;
}



void floor_init()
{
	check_tex = loadTexGenTexMemory(checkerboard,checkerboard_len,512,512);
	star_sprite = loadDDSTextureMemory(startex,startex_len,false);
	initshadetex();
	initShader(  &starfield_shaderobj, (const char*)vert, (const char*)user_shader_388179211_frag);


	for (int i=0;i<NUM_STARS;i++)
	{
		float tSize=rand()%128;
		starsprites[i].rcol = rand_range(10,160);
		starsprites[i].bcol = rand_range(10,160);
		starsprites[i].gcol = rand_range(10,160);
		starsprites[i].rot = rand_rangef(0.01,0.1);
		starsprites[i].speed = rand_rangef(1.1,8.1);
		starsprites[i].x = rand_range(1,200);
		starsprites[i].y = 480-rand_range(20,200);
		starsprites[i].xsize = tSize;
		starsprites[i].ysize = tSize;
	}

	for (int i=0;i<NUM_OBJ;i++)
	{
		floor_obj[i].rcol = rand_range(10,160);
		floor_obj[i].bcol = rand_range(10,160);
		floor_obj[i].gcol = rand_range(10,160);
		floor_obj[i].rot = rand_rangef(0.01,0.1);
		floor_obj[i].speed = rand_rangef(0.10,0.50);
		floor_obj[i].x = -3+i;
		floor_obj[i].y = rand_rangef(-2.5,-2.0f);
		floor_obj[i].z = rand_rangef(-12.0,0.0f);
	}
}

void draw_sprites()
{
	
	for (int i=0;i<NUM_STARS;i++)
	{
		float zPos = 0.0f;
		float  tX=starsprites[i].xsize/2.0f;
		float  tY=starsprites[i].ysize/2.0f;
		BeginOrtho2D(XRES,YRES);
		glEnable(GL_TEXTURE_2D);
		glBindTexture(GL_TEXTURE_2D,star_sprite);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
		//glAlphaFunc(GL_GREATER,0.1f);

		glPushMatrix();  // Save modelview matrix
		starsprites[i].x-=starsprites[i].speed;
		starsprites[i].rot += starsprites[i].speed;
		if(starsprites[i].x < -12) starsprites[i].x = 800;

		glTranslatef(starsprites[i].x,starsprites[i].y,0.0f);  // Position sprite
		glRotatef(starsprites[i].rot,0.0f,0.0f,1.0f);
		glColor4ub(starsprites[i].rcol,starsprites[i].gcol,starsprites[i].bcol,255);

		glBegin(GL_QUADS);                                   // Draw sprite 
		glTexCoord2f(0.0f,0.0f); glVertex3i(-tX, tY,zPos);
		glTexCoord2f(0.0f,1.0f); glVertex3i(-tX,-tY,zPos);
		glTexCoord2f(1.0f,1.0f); glVertex3i( tX,-tY,zPos);
		glTexCoord2f(1.0f,0.0f); glVertex3i( tX, tY,zPos);
		glEnd();

		glPopMatrix();  // Restore modelview matrix
		glBindTexture(GL_TEXTURE_2D,0);
		glDisable(GL_TEXTURE_2D);
		glDisable(GL_BLEND);
		EndProjection();
	}
	glBindTexture(GL_TEXTURE_2D,starfield_screentexture);
	glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, 640, 480);
	glBindTexture( GL_TEXTURE_2D,  0);

}

void render_cube(float x,float y, float z, float rot)
{
	static GLfloat	xrot = 0;				// X Rotation ( NEW )
	static GLfloat	yrot= 0;				// Y Rotation ( NEW )
	static GLfloat	zrot= 0;				// Z Rotation ( NEW )
	glPushMatrix();
	glLoadIdentity();                           // Reset The Current Matrix
	glTranslatef(x,y,z);                      // Move Into The Screen 5 Units
	glScalef(0.4,0.4,0.4);
	glRotatef(xrot,1.0f,0.0f,0.0f);                     // Rotate On The X Axis
	glRotatef(yrot,0.0f,1.0f,0.0f);                     // Rotate On The Y Axis
	glRotatef(zrot,0.0f,0.0f,1.0f);                     // Rotate On The Z Axis
	glEnable(GL_TEXTURE_2D);
	glBindTexture( GL_TEXTURE_2D,  check_tex);

	glBegin(GL_QUADS);
	// Front Face
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);  // Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);  // Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);  // Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);  // Top Left Of The Texture and Quad
	// Back Face
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);  // Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);  // Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);  // Bottom Left Of The Texture and Quad
	// Top Face
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);  // Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  1.0f);  // Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f,  1.0f,  1.0f);  // Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);  // Top Right Of The Texture and Quad
	// Bottom Face
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f, -1.0f, -1.0f);  // Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f, -1.0f, -1.0f);  // Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);  // Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);  // Bottom Right Of The Texture and Quad
	// Right face
	glTexCoord2f(1.0f, 0.0f); glVertex3f( 1.0f, -1.0f, -1.0f);  // Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f( 1.0f,  1.0f, -1.0f);  // Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f( 1.0f,  1.0f,  1.0f);  // Top Left Of The Texture and Quad
	glTexCoord2f(0.0f, 0.0f); glVertex3f( 1.0f, -1.0f,  1.0f);  // Bottom Left Of The Texture and Quad
	// Left Face
	glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f, -1.0f, -1.0f);  // Bottom Left Of The Texture and Quad
	glTexCoord2f(1.0f, 0.0f); glVertex3f(-1.0f, -1.0f,  1.0f);  // Bottom Right Of The Texture and Quad
	glTexCoord2f(1.0f, 1.0f); glVertex3f(-1.0f,  1.0f,  1.0f);  // Top Right Of The Texture and Quad
	glTexCoord2f(0.0f, 1.0f); glVertex3f(-1.0f,  1.0f, -1.0f);  // Top Left Of The Texture and Quad
	glEnd();
	glPopMatrix();
	xrot+=rot;                             // X Axis Rotation
	yrot+=rot;                             // Y Axis Rotation
	zrot+=rot;                             // Z Axis Rotation
}




void floor_do()
{
	float fogcolor[4]= {0.0f,(float)52/255,(float)102/255,1.0f};
	static float floor_move = 0.0;
	floor_move+=0.01;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	
	//nyan bg colour
	glClearColor(0.0f,(float)52/255,(float)102/255,1.0f);
	glLoadIdentity();
	draw_sprites();

	//draw starfield with shader
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glEnable(GL_TEXTURE_2D);
	starfield_shadertexture =  oglGetUniformLocation( starfield_shaderobj, "Image" );
	oglUniform1i(starfield_shaderobj,0);
	glBindTexture(GL_TEXTURE_2D,starfield_screentexture);
	oglUseProgram(  starfield_shaderobj );
	oglUniform4fv(resolution_uniform,1,resolution);
	DrawStaticBG();
	glBindTexture(GL_TEXTURE_2D,0);
	oglUseProgram( NULL );

	glLoadIdentity();

	glEnable(GL_FOG);
	glFogfv(GL_FOG_COLOR,fogcolor); // Set the fog color
	glFogf(GL_FOG_DENSITY,0.25f);  // Thin the fog out a little
	float LightPos[4]={-5.0f,5.0f,10.0f,0.0f};
	float Ambient[4]={0.5f,0.5f,0.5f,1.0f};
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0,GL_POSITION,LightPos);
	glLightfv(GL_LIGHT0,GL_AMBIENT,Ambient);


	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();
	glEnable(GL_TEXTURE_2D);
	glBindTexture( GL_TEXTURE_2D,  check_tex);
	glTranslatef(floor_move,1.0,0.0);
	glBegin(GL_QUADS);
	glTexCoord2f( 0.0f,5.0f); glVertex3f(-20.0f,-1.0f, 20.0f);
	glTexCoord2f( 0.0f, 0.0f); glVertex3f( 20.0f,-1.0f, 20.0f);
	glTexCoord2f(5.0f, 0.0f); glVertex3f( 20.0f,-1.0f,-20.0f);
	glTexCoord2f(5.0f,5.0f); glVertex3f(-20.0f,-1.0f,-20.0f);
	glEnd();
	glMatrixMode(GL_TEXTURE);
	glPopMatrix();

	glDisable(GL_LIGHTING);
	glDisable(GL_LIGHT0);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	
	for (int i=0;i<NUM_OBJ;i++)
	{
		glEnable ( GL_COLOR_MATERIAL );
		glColorMaterial ( GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE );
		GLfloat white[] = { 1.0f, 1.0f, 1.0f, 1.0f };
		glEnable(GL_DEPTH_TEST);
		static float inc = 0.0;
		floor_obj[i].z += floor_obj[i].speed;
		if (floor_obj[i].z > 1) floor_obj[i].z = -50.0;
		glColor4ub(floor_obj[i].rcol,floor_obj[i].gcol,floor_obj[i].bcol,0);
		render_cube(floor_obj[i].x,floor_obj[i].y,floor_obj[i].z,floor_obj[i].speed);
		glDisable(GL_DEPTH_TEST);
		glDisable ( GL_COLOR_MATERIAL );
	}

	
	glDisable(GL_FOG);

	
}