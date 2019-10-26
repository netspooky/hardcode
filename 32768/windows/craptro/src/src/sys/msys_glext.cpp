#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>


#include <GL/gl.h>
#include <gl/GLU.h>
#include "glext.h"

#include <string.h>
#include "ddraw.h"
#include "msys_texgen.h"

//--- d a t a ---------------------------------------------------------------
#include "msys_glext.h"

static char *funciones = {
    // multitexture
    "glActiveTextureARB\x0"
    "glClientActiveTextureARB\x0"
    "glMultiTexCoord4fvARB\x0"
    // programs
    "glDeleteProgramsARB\x0"
    "glBindProgramARB\x0"
    "glProgramStringARB\x0"
    "glProgramLocalParameter4fvARB\x0"
	"glProgramEnvParameter4fvARB\x0"
    // textures 3d
    "glTexImage3D\x0"
    // vbo-ibo
    "glBindBufferARB\x0"
    "glBufferDataARB\x0"
    "glBufferSubDataARB\x0"
    "glDeleteBuffersARB\x0"

	// shader
	"glCreateProgram\x0"
	"glCreateShader\x0"
	"glShaderSource\x0"
	"glCompileShader\x0"
	"glAttachShader\x0"
	"glLinkProgram\x0"
	"glUseProgram\x0"
    "glUniform4fv\x0"
    "glUniform1i\x0"
    "glGetUniformLocationARB\x0"
	"glGetObjectParameterivARB\x0"
	"glGetInfoLogARB\x0"

    "glLoadTransposeMatrixf\x0"

    "glBindRenderbufferEXT\x0"
    "glDeleteRenderbuffersEXT\x0"
    "glRenderbufferStorageEXT\x0"
    "glBindFramebufferEXT\x0"
    "glDeleteFramebuffersEXT\x0"
    "glCheckFramebufferStatusEXT\x0"
    "glFramebufferTexture1DEXT\x0"
    "glFramebufferTexture2DEXT\x0"
    "glFramebufferTexture3DEXT\x0"
    "glFramebufferRenderbufferEXT\x0"
    "glGenerateMipmapEXT\x0"
	"glCompressedTexImage2DARB\x0"
	"wglSwapIntervalEXT\x0"
	"glGenFramebuffersEXT\x0"
	 "glGenRenderbuffersEXT\x0"

    };

void *msys_oglfunc[NUMFUNCIONES];

//--- c o d e ---------------------------------------------------------------

int msys_glextInit( void )
{
    char *str = funciones;
    for( int i=0; i<NUMFUNCIONES; i++ )
        {
        msys_oglfunc[i] = wglGetProcAddress( str );
        str += 1+strlen( str );

        if( !msys_oglfunc[i] )
			return( 0 );
        }


    return( 1 );
}

// Sets an orthographic projection. x: 0..width, y: 0..height 
void BeginOrtho2D(float width, float height) 
{ 
	glMatrixMode(GL_PROJECTION); 
	glPushMatrix(); 
	glLoadIdentity(); 
	gluOrtho2D(0, width, 0, height); 
	glMatrixMode(GL_MODELVIEW); 
	glPushMatrix(); 
	glLoadIdentity(); 
} 

// Sets an orthographic projection. x: x1..x2, y: y1..y2 
void BeginOrtho2D(float x1, float y1, float x2, float y2) 
{ 
	glMatrixMode(GL_PROJECTION); 
	glPushMatrix(); 
	glLoadIdentity(); 
	gluOrtho2D(x1, x2, y1, y2); 
	glMatrixMode(GL_MODELVIEW); 
	glPushMatrix(); 
	glLoadIdentity(); 
} 



//draw fullscreen quad
//useful for postproc
void DrawFullScreenQuad( int iWidth, int iHeight )
{
	glBegin(GL_QUADS);
	// Display the top left point of the 2D image
	glTexCoord2f(0.0f, 1.0f);	glVertex2f(0, 0);
	// Display the bottom left point of the 2D image
	//glTexCoord2f(0.0f, 0.0f);	glVertex2f(0, SCREEN_HEIGHT);
	glTexCoord2f(0.0f, 0.0f);	glVertex2f(0, iHeight);
	// Display the bottom right point of the 2D image
	//glTexCoord2f(1.0f, 0.0f);	glVertex2f(SCREEN_WIDTH, SCREEN_HEIGHT);
	glTexCoord2f(1.0f, 0.0f);	glVertex2f(iWidth, iHeight);
	// Display the top right point of the 2D image
	//glTexCoord2f(1.0f, 1.0f);	glVertex2f(SCREEN_WIDTH, 0);
	glTexCoord2f(1.0f, 1.0f);	glVertex2f(iWidth, 0);
	// Stop drawing 
	glEnd();
}

// Sets a perspective projection with a different field-of-view 
void BeginPerspective(float fovy, float xratio) 
{ 
	glMatrixMode(GL_PROJECTION); 
	glPushMatrix(); 
	glLoadIdentity(); 
	gluPerspective(fovy, xratio, 0.1f, 100.0f); 
	glMatrixMode(GL_MODELVIEW); 
	glPushMatrix(); 
	glLoadIdentity(); 
} 

// Restore the previous projection 
void EndProjection() 
{ 
	glMatrixMode(GL_PROJECTION); 
	glPopMatrix(); 
	glMatrixMode(GL_MODELVIEW); 
	glPopMatrix(); 
} 

void DrawStaticBG() 
{ 
	BeginOrtho2D(1, 1); 
	glDepthMask(GL_FALSE); 

	glBegin(GL_QUADS); 
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f); 
	glTexCoord2f(1.0f, 0.0f); glVertex2f(1.0f, 0.0f); 
	glTexCoord2f(1.0f, 1.0f); glVertex2f(1.0f, 1.0f); 
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.0f); 
	glEnd(); 

	glDepthMask(GL_TRUE); 
	EndProjection(); 
} 

void DrawShaky() 
{ 
	BeginOrtho2D(1, 1); 
	glDepthMask(GL_FALSE); 

	float x = (rand()%10)/100.0f; 
	float y = (rand()%10)/100.0f; 

	glTranslatef(-x, -y, 0); 

	glBegin(GL_QUADS); 
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f); 
	glTexCoord2f(1.0f, 0.0f); glVertex2f(1.2f, 0.0f); 
	glTexCoord2f(1.0f, 1.0f); glVertex2f(1.2f, 1.2f); 
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.2f); 
	glEnd(); 

	glDepthMask(GL_TRUE); 
	EndProjection(); 
} 

// Draws a background with a rotating cube viewed at a
// very high field-of-view
void DrawRot(float time)
{
	BeginPerspective(140, 1.33f);
	glDepthMask(GL_FALSE);

	glRotatef(time*32, 1, 0, 0);
	glRotatef(time*67, 0, 1, 0);

	glBegin(GL_QUADS);
	// Front
	glNormal3f(0, 0, 1);
	glTexCoord2f(0, 0); glVertex3f(-1, -1, -1);
	glTexCoord2f(1, 0); glVertex3f( 1, -1, -1);
	glTexCoord2f(1, 1); glVertex3f( 1,  1, -1);
	glTexCoord2f(0, 1); glVertex3f(-1,  1, -1);

	// Left
	glNormal3f(1, 0, 0);
	glTexCoord2f(0, 0); glVertex3f(-1, -1,  1);
	glTexCoord2f(1, 0); glVertex3f(-1, -1, -1);
	glTexCoord2f(1, 1); glVertex3f(-1,  1, -1);
	glTexCoord2f(0, 1); glVertex3f(-1,  1,  1);

	// Bottom
	glNormal3f(0, 1, 0);
	glTexCoord2f(0, 0); glVertex3f(-1, -1,  1);
	glTexCoord2f(1, 0); glVertex3f( 1, -1,  1);
	glTexCoord2f(1, 1); glVertex3f( 1, -1, -1);
	glTexCoord2f(0, 1); glVertex3f(-1, -1, -1);

	// Back
	glNormal3f(0, 0, -10);
	glTexCoord2f(0, 0); glVertex3f( 1, -1,  1);
	glTexCoord2f(1, 0); glVertex3f(-1, -1,  1);
	glTexCoord2f(1, 1); glVertex3f(-1,  1,  1);
	glTexCoord2f(0, 1); glVertex3f( 1,  1,  1);

	// Right
	glNormal3f(0, -1, 0);
	glTexCoord2f(0, 0); glVertex3f( 1, -1, -1);
	glTexCoord2f(1, 0); glVertex3f( 1, -1,  1);
	glTexCoord2f(1, 1); glVertex3f( 1,  1,  1);
	glTexCoord2f(0, 1); glVertex3f( 1,  1, -1);

	// Top
	glNormal3f(0, -1, 0);
	glTexCoord2f(0, 0); glVertex3f(-1,  1,  1);
	glTexCoord2f(1, 0); glVertex3f( 1,  1,  1);
	glTexCoord2f(1, 1); glVertex3f( 1,  1, -1);
	glTexCoord2f(0, 1); glVertex3f(-1,  1, -1);

	glEnd();

	glDepthMask(GL_TRUE);
	EndProjection();
}

// Draws a background rotating around its center
void DrawRotateTile(float rot)
{
	BeginOrtho2D(-1, -1, 1, 1);
	glDepthMask(GL_FALSE);

	glRotatef(rot, 0, 0, 1);

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(1.0f, 0.0f);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(1.0f, 1.0f);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.0f);

	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(-1.0f, 0.0f);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(-1.0f, 1.0f);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, 1.0f);

	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(-1.0f, 0.0f);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(-1.0f, -1.0f);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, -1.0f);

	glTexCoord2f(0.0f, 0.0f); glVertex2f(0.0f, 0.0f);
	glTexCoord2f(1.0f, 0.0f); glVertex2f(1.0f, 0.0f);
	glTexCoord2f(1.0f, 1.0f); glVertex2f(1.0f, -1.0f);
	glTexCoord2f(0.0f, 1.0f); glVertex2f(0.0f, -1.0f);
	glEnd();

	glDepthMask(GL_TRUE);
	EndProjection();
}

// Draw a sine distorted background
void DrawDistort(float time)
{
	BeginOrtho2D(-1, -1, 1, 1);
	glScalef(1.2f, 1.2f, 1.0f);

	glDepthMask(GL_FALSE);

	//time *= ;

	float step = 0.05f;
	float kx = 0.04f;
	float ky = 0.03f;

	float ax = 14.3f;
	float bx = 7.2f;
	float cx = 9.12f;
	float dx = 21.7f;

	for(float a = -1; a < 1; a += step)
	{
		glBegin(GL_TRIANGLE_STRIP);
		for(float b = -1; b <= 1.01f; b += step)
		{
			glTexCoord2f(b*0.5f+0.5f, a*0.5f+0.5f);
			glVertex2f(b + sinf(b*dx+time*bx) * kx, a + sinf(a*ax+time*0.7f*cx) * ky);

			glTexCoord2f(b*0.5f+0.5f, (a+step)*0.5f+0.5f);
			glVertex2f(b + sinf(b*dx+time*bx) * kx, a + step + sinf((a+step)*ax+time*0.7f*cx) * ky);
		}
		glEnd();
	}

	glDepthMask(GL_TRUE);
	EndProjection();
}

// Draw a waving background
void DrawWaving(float time)
{
	BeginOrtho2D(-1, -1, 1, 1);
	glScalef(1.2f, 1.2f, 1.0f);

	glDepthMask(GL_FALSE);

	time *= 0.5f;

	float step = 0.05f;
	float k = 0.2f;

	for(float a = -1; a < 1; a += step)
	{
		glBegin(GL_TRIANGLE_STRIP);
		for(float b = -1; b <= 1.01f; b += step)
		{
			glTexCoord2f(b*0.5f+0.5f, a*0.5f+0.5f);
			glVertex2f(b + sinf(a+time) * k * (sqrtf(2) - sqrtf(a*a+b*b)), a + sinf(b+time*0.7f) * k * (sqrtf(2) - sqrtf(a*a+b*b)));

			glTexCoord2f(b*0.5f+0.5f, (a+step)*0.5f+0.5f);
			glVertex2f(b + sinf(a+step+time) * k *  (sqrtf(2) - sqrtf((a+step)*(a+step)+b*b)), a + step + sinf(b+time*0.7f) * k * (sqrtf(2) - sqrtf((a+step)*(a+step)+b*b)));
		}
		glEnd();
	}

	glDepthMask(GL_TRUE);
	EndProjection();
}

// And finally the zooming background
void DrawZooming(float time)
{
	BeginOrtho2D(1, 1);
	glDepthMask(GL_FALSE);

	time *= 0.5f;

	glBegin(GL_QUADS);
	glTexCoord2f(0.0f+time, 0.0f+time); glVertex2f(0.0f, 0.0f);
	glTexCoord2f(1.0f-time, 0.0f+time); glVertex2f(1.0f, 0.0f);
	glTexCoord2f(1.0f-time, 1.0f-time); glVertex2f(1.0f, 1.0f);
	glTexCoord2f(0.0f+time, 1.0f-time); glVertex2f(0.0f, 1.0f);
	glEnd();

	glDepthMask(GL_TRUE);
	EndProjection();
}

void Resize(int x, int y) 
{ 
	// Prevent div by zero 
	y = y ? y : 1; 

	// Resize viewport 
	glViewport(0, 0, x, y); 

	// Recalc perspective 
	glMatrixMode(GL_PROJECTION); 
	glLoadIdentity(); 
	gluPerspective(60.0f, static_cast<float>(x)/static_cast<float>(y), 0.1f, 100.0f); 
	glMatrixMode(GL_MODELVIEW); 
	glLoadIdentity(); 
} 

struct DDS_IMAGE_DATA
{
	GLsizei  width;
	GLsizei  height;
	GLint    components;
	GLenum   format;
	int      numMipMaps;
	GLubyte *pixels;
};


GLuint loadTexGenTexMemory(unsigned char *data,int size, int width, int height)
{
	GLuint texture;
	RGBA *image = (RGBA*)calloc(width*height, sizeof(RGBA));
	TextureGenerator *tg=getTextureGenerator();
	tg->tex2mem(&image, data,size, width, height, true);
	glGenTextures( 1, &texture );
	glBindTexture( GL_TEXTURE_2D, texture );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexImage2D( GL_TEXTURE_2D, 0, 4, width, height, 0,
		GL_RGBA, GL_UNSIGNED_BYTE, image );
	free(image);
	return texture;
}

GLuint loadTexGenTex(char* tex_filename, int width, int height)
{
	GLuint texture;
	RGBA *image = (RGBA*)calloc(width*height, sizeof(RGBA));
	TextureGenerator *tg=getTextureGenerator();
	tg->tex2mem(&image, tex_filename, width, height, true);


	glGenTextures( 1, &texture );
	glBindTexture( GL_TEXTURE_2D, texture );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexImage2D( GL_TEXTURE_2D, 0, 4, width, height, 0,
		GL_RGBA, GL_UNSIGNED_BYTE, image );
	free(image);
	return texture;
}



GLuint loadDDSTextureMemory(unsigned char* data, int size, bool blur)
{
	GLuint texture;
	DDS_IMAGE_DATA *pDDSImageData;
	DDSURFACEDESC2 ddsd;
	char filecode[4] = {0};
	int factor;
	int bufferSize;
	unsigned char* dataptr = data;
	memcpy(filecode,dataptr,4);
	dataptr+=4;
	if( strncmp( filecode, "DDS ", 4 ) != 0 )
	{
		char str[255];
		sprintf( str, "%s","The file doesn't appear to be a valid .dds file!");
		MessageBox( NULL, str, "ERROR", MB_OK|MB_ICONEXCLAMATION );
		return NULL;
	}
	memcpy( &ddsd,dataptr, sizeof(ddsd));
	dataptr+=sizeof(ddsd);

	pDDSImageData = (DDS_IMAGE_DATA*) malloc(sizeof(DDS_IMAGE_DATA));
	memset( pDDSImageData, 0, sizeof(DDS_IMAGE_DATA) );
	switch( ddsd.ddpfPixelFormat.dwFourCC )
	{
	case FOURCC_DXT1:
		// DXT1's compression ratio is 8:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
		factor = 2;
		break;

	case FOURCC_DXT3:
		// DXT3's compression ratio is 4:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
		factor = 4;
		break;

	case FOURCC_DXT5:
		// DXT5's compression ratio is 4:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
		factor = 4;
		break;
	default:
		char str[255];
		sprintf( str, "%s","The file doesn't appear to be compressed using DXT1, DXT3, or DXT5!");
		MessageBox( NULL, str, "ERROR", MB_OK|MB_ICONEXCLAMATION );
		return NULL;
	}
	//
	// How big will the buffer need to be to load all of the pixel data 
	// including mip-maps?
	//

	if( ddsd.dwLinearSize == 0 )
	{
		MessageBox( NULL, "dwLinearSize is 0!","ERROR",
			MB_OK|MB_ICONEXCLAMATION);
	}

	if( ddsd.dwMipMapCount > 1 )
		bufferSize = ddsd.dwLinearSize * factor;
	else
		bufferSize = ddsd.dwLinearSize;

	pDDSImageData->pixels = (unsigned char*)malloc(bufferSize * sizeof(unsigned char));
	memcpy(pDDSImageData->pixels,dataptr,bufferSize);

	pDDSImageData->width      = ddsd.dwWidth;
	pDDSImageData->height     = ddsd.dwHeight;
	pDDSImageData->numMipMaps = ddsd.dwMipMapCount;

	if( ddsd.ddpfPixelFormat.dwFourCC == FOURCC_DXT1 )
		pDDSImageData->components = 3;
	else
		pDDSImageData->components = 4;


	if( pDDSImageData != NULL )
	{
		int nHeight     = pDDSImageData->height;
		int nWidth      = pDDSImageData->width;
		int nNumMipMaps = pDDSImageData->numMipMaps;

		int nBlockSize;

		if( pDDSImageData->format == GL_COMPRESSED_RGBA_S3TC_DXT1_EXT )
			nBlockSize = 8;
		else
			nBlockSize = 16;

		glGenTextures( 1, &texture );
		glBindTexture( GL_TEXTURE_2D, texture);

		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, blur?GL_LINEAR:GL_NEAREST  );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, blur?GL_LINEAR:GL_NEAREST );

		int nSize;
		int nOffset = 0;

		if (nNumMipMaps == 0)
		{
			if( nWidth  == 0 ) nWidth  = 1;
			if( nHeight == 0 ) nHeight = 1;
			nSize = ((nWidth+3)/4) * ((nHeight+3)/4) * nBlockSize;
			glCompressedTexImage2DARB( GL_TEXTURE_2D,
				0,
				pDDSImageData->format,
				nWidth,
				nHeight,
				0,
				nSize,
				pDDSImageData->pixels + nOffset );

			nOffset += nSize;
		}
		else
		{
			for( int i = 0; i < nNumMipMaps; ++i )
			{
				if( nWidth  == 0 ) nWidth  = 1;
				if( nHeight == 0 ) nHeight = 1;
				nSize = ((nWidth+3)/4) * ((nHeight+3)/4) * nBlockSize;
				glCompressedTexImage2DARB( GL_TEXTURE_2D,
					i,
					pDDSImageData->format,
					nWidth,
					nHeight,
					0,
					nSize,
					pDDSImageData->pixels + nOffset );

				nOffset += nSize;

				// Half the image size for the next mip-map level...
				nWidth  = (nWidth  / 2);
				nHeight = (nHeight / 2);
			}
		}


	}
	if( pDDSImageData != NULL )
	{
		if( pDDSImageData->pixels != NULL )
			free( pDDSImageData->pixels );

		free( pDDSImageData );
	}
	return texture;
}

GLuint loadDDSTextureFile( const char *filename, bool blur )
{
	GLuint texture = 0;
	DDS_IMAGE_DATA *pDDSImageData = NULL;
	DDSURFACEDESC2 ddsd;
	char filecode[4] = {0};
	FILE *pFile = NULL;
	int factor = 0;
	int bufferSize = 0;
	int nSize = 0;
	int nOffset = 0;
	// Open the file
	ZeroMemory(&ddsd,sizeof(DDSURFACEDESC2));
	pFile = fopen( filename, "rb" );
	if( pFile == NULL )
	{
		char str[255];
		sprintf( str, "loadDDSTextureFile couldn't find, or failed to load \"%s\"", filename );
		MessageBox( NULL, str, "ERROR", MB_OK|MB_ICONEXCLAMATION );
		return NULL;
	}
	// Verify the file is a true .dds file
	fread( filecode, 1, 4, pFile );

	if( strncmp( filecode, "DDS ", 4 ) != 0 )
	{
		char str[255];
		sprintf( str, "The file \"%s\" doesn't appear to be a valid .dds file!", filename );
		MessageBox( NULL, str, "ERROR", MB_OK|MB_ICONEXCLAMATION );
		fclose( pFile );
		return NULL;
	}
	// Get the surface descriptor
	fread( &ddsd, sizeof(ddsd), 1, pFile );
	pDDSImageData = (DDS_IMAGE_DATA*) malloc(sizeof(DDS_IMAGE_DATA));
	memset( pDDSImageData, 0, sizeof(DDS_IMAGE_DATA) );
	switch( ddsd.ddpfPixelFormat.dwFourCC )
	{
	case FOURCC_DXT1:
		// DXT1's compression ratio is 8:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT1_EXT;
		factor = 2;
		break;

	case FOURCC_DXT3:
		// DXT3's compression ratio is 4:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT3_EXT;
		factor = 4;
		break;

	case FOURCC_DXT5:
		// DXT5's compression ratio is 4:1
		pDDSImageData->format = GL_COMPRESSED_RGBA_S3TC_DXT5_EXT;
		factor = 4;
		break;

	default:
		char str[255];
		sprintf( str, "The file \"%s\" doesn't appear to be compressed "
			"using DXT1, DXT3, or DXT5!", filename );
		MessageBox( NULL, str, "ERROR", MB_OK|MB_ICONEXCLAMATION );
		return NULL;
	}

	//
	// How big will the buffer need to be to load all of the pixel data 
	// including mip-maps?
	//

	if( ddsd.dwLinearSize == 0 )
	{
		MessageBox( NULL, "dwLinearSize is 0!","ERROR",
			MB_OK|MB_ICONEXCLAMATION);
	}

	if( ddsd.dwMipMapCount > 1 )
		bufferSize = ddsd.dwLinearSize * factor;
	else
		bufferSize = ddsd.dwLinearSize;

	pDDSImageData->pixels = (unsigned char*)malloc(bufferSize * sizeof(unsigned char));

	fread( pDDSImageData->pixels, 1, bufferSize, pFile );

	// Close the file
	fclose( pFile );

	pDDSImageData->width      = ddsd.dwWidth;
	pDDSImageData->height     = ddsd.dwHeight;
	pDDSImageData->numMipMaps = ddsd.dwMipMapCount;

	if( ddsd.ddpfPixelFormat.dwFourCC == FOURCC_DXT1 )
		pDDSImageData->components = 3;
	else
		pDDSImageData->components = 4;


	if( pDDSImageData != NULL )
	{
		int nHeight     = pDDSImageData->height;
		int nWidth      = pDDSImageData->width;
		int nNumMipMaps = pDDSImageData->numMipMaps;

		int nBlockSize;

		if( pDDSImageData->format == GL_COMPRESSED_RGBA_S3TC_DXT1_EXT )
			nBlockSize = 8;
		else
			nBlockSize = 16;

		glGenTextures( 1, &texture );
		glBindTexture( GL_TEXTURE_2D, texture);

		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, blur?GL_LINEAR:GL_NEAREST  );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,blur?GL_LINEAR:GL_NEAREST  );

		if (nNumMipMaps == 0)
		{
			if( nWidth  == 0 ) nWidth  = 1;
			if( nHeight == 0 ) nHeight = 1;
			nSize = ((nWidth+3)/4) * ((nHeight+3)/4) * nBlockSize;
			glCompressedTexImage2DARB( GL_TEXTURE_2D,
				0,
				pDDSImageData->format,
				nWidth,
				nHeight,
				0,
				nSize,
				pDDSImageData->pixels + nOffset );

			nOffset += nSize;
		}
		else
		{
			for( int i = 0; i < nNumMipMaps; ++i )
			{
				if( nWidth  == 0 ) nWidth  = 1;
				if( nHeight == 0 ) nHeight = 1;
				nSize = ((nWidth+3)/4) * ((nHeight+3)/4) * nBlockSize;
				glCompressedTexImage2DARB( GL_TEXTURE_2D,
					i,
					pDDSImageData->format,
					nWidth,
					nHeight,
					0,
					nSize,
					pDDSImageData->pixels + nOffset );

				nOffset += nSize;

				// Half the image size for the next mip-map level...
				nWidth  = (nWidth  / 2);
				nHeight = (nHeight / 2);
			}
		}
	}
	if( pDDSImageData != NULL )
	{
		if( pDDSImageData->pixels != NULL )
			free( pDDSImageData->pixels );

		free( pDDSImageData );
	}
	return texture;
}

#ifdef _DEBUG
#include <sys/stat.h>
unsigned char *readShaderFile( const char *fileName )
{
	FILE *file = fopen( fileName, "r" );

	if( file == NULL )
	{
		MessageBox( NULL, "Cannot open shader file!", "ERROR",
			MB_OK | MB_ICONEXCLAMATION );
		return 0;
	}

	struct _stat fileStats;

	if( _stat( fileName, &fileStats ) != 0 )
	{
		MessageBox( NULL, "Cannot get file stats for shader file!", "ERROR",
			MB_OK | MB_ICONEXCLAMATION );
		return 0;
	}

	unsigned char *buffer = new unsigned char[fileStats.st_size];

	int bytes = fread( buffer, 1, fileStats.st_size, file );

	buffer[bytes] = 0;

	fclose( file );

	return buffer;
}
#endif

void initShader( int *pid, const char *vs, const char *fs )
{
	pid[0] = oglCreateProgram();                           
	const int vsId = oglCreateShader( GL_VERTEX_SHADER ); 
	const int fsId = oglCreateShader( GL_FRAGMENT_SHADER );
	oglShaderSource( vsId, 1, &vs, 0 );
	oglShaderSource( fsId, 1, &fs, 0 );
	oglCompileShader( vsId );
	oglCompileShader( fsId );
	oglAttachShader( pid[0], fsId );
	oglAttachShader( pid[0], vsId );
	oglLinkProgram( pid[0] );

#ifdef DEBUG
	int		result;
	char    info[1536];
	oglGetObjectParameteriv( vsId,   GL_OBJECT_COMPILE_STATUS_ARB, &result ); oglGetInfoLog( vsId,   1024, NULL, (char *)info ); if( !result ) DebugBreak();
	oglGetObjectParameteriv( fsId,   GL_OBJECT_COMPILE_STATUS_ARB, &result ); oglGetInfoLog( fsId,   1024, NULL, (char *)info ); if( !result ) DebugBreak();
	oglGetObjectParameteriv( pid[0], GL_OBJECT_LINK_STATUS_ARB,    &result ); oglGetInfoLog( pid[0], 1024, NULL, (char*)info ); if( !result ) DebugBreak();
#endif
}