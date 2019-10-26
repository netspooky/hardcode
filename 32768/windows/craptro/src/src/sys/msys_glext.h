//--------------------------------------------------------------------------//
// iq . 2003/2008 . code for 64 kb intros by RGBA                           //
//--------------------------------------------------------------------------//

#ifndef _MSYS_GLEXT_H_
#define _MSYS_GLEXT_H_

#ifdef WINDOWS
#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#endif
#include <GL/gl.h>
#include "glext.h"
#include "wglext.h"
#include <stdio.h>

#define NUMFUNCIONES (3+5+1+0+4+12+1+12+3)

extern void *msys_oglfunc[NUMFUNCIONES];

// multitexture
#define oglActiveTextureARB            ((PFNGLACTIVETEXTUREARBPROC)msys_oglfunc[0])
#define oglClientActiveTextureARB      ((PFNGLCLIENTACTIVETEXTUREARBPROC)msys_oglfunc[1])
#define oglMultiTexCoord4fvARB         ((PFNGLMULTITEXCOORD4FVARBPROC)msys_oglfunc[2])
// programs
#define oglDeleteProgramsARB           ((PFNGLDELETEPROGRAMSARBPROC)msys_oglfunc[3])
#define oglBindProgramARB              ((PFNGLBINDPROGRAMARBPROC)msys_oglfunc[4])
#define oglProgramStringARB            ((PFNGLPROGRAMSTRINGARBPROC)msys_oglfunc[5])
#define oglProgramLocalParameter4fvARB ((PFNGLPROGRAMLOCALPARAMETER4FVARBPROC)msys_oglfunc[6])
#define oglProgramEnvParameter4fvARB   ((PFNGLPROGRAMENVPARAMETER4FVARBPROC)msys_oglfunc[7])
// textures 3d
#define oglTexImage3D                  ((PFNGLTEXIMAGE3DPROC)msys_oglfunc[8])
// vbo-ibo
#define oglBindBufferARB               ((PFNGLBINDBUFFERARBPROC)msys_oglfunc[9])
#define oglBufferDataARB               ((PFNGLBUFFERDATAARBPROC)msys_oglfunc[10])
#define oglBufferSubDataARB            ((PFNGLBUFFERSUBDATAARBPROC)msys_oglfunc[11])
#define oglDeleteBuffersARB            ((PFNGLDELETEBUFFERSARBPROC)msys_oglfunc[12])

// shaders
#define oglCreateProgram	           ((PFNGLCREATEPROGRAMPROC)msys_oglfunc[13])
#define oglCreateShader		           ((PFNGLCREATESHADERPROC)msys_oglfunc[14])
#define oglShaderSource                ((PFNGLSHADERSOURCEPROC)msys_oglfunc[15])
#define oglCompileShader               ((PFNGLCOMPILESHADERPROC)msys_oglfunc[16])
#define oglAttachShader                ((PFNGLATTACHSHADERPROC)msys_oglfunc[17])
#define oglLinkProgram                 ((PFNGLLINKPROGRAMPROC)msys_oglfunc[18])
#define oglUseProgram                  ((PFNGLUSEPROGRAMPROC)msys_oglfunc[19])
#define oglUniform4fv                  ((PFNGLUNIFORM4FVPROC)msys_oglfunc[20])
#define oglUniform1i                   ((PFNGLUNIFORM1IPROC)msys_oglfunc[21])
#define oglGetUniformLocation          ((PFNGLGETUNIFORMLOCATIONARBPROC)msys_oglfunc[22])
#define oglGetObjectParameteriv        ((PFNGLGETOBJECTPARAMETERIVARBPROC)msys_oglfunc[23])
#define oglGetInfoLog                  ((PFNGLGETINFOLOGARBPROC)msys_oglfunc[24])

#define oglLoadTransposeMatrixf        ((PFNGLLOADTRANSPOSEMATRIXFPROC)msys_oglfunc[25])

// fbo
#define oglBindRenderbufferEXT         ((PFNGLBINDRENDERBUFFEREXTPROC)msys_oglfunc[26])
#define oglDeleteRenderbuffersEXT      ((PFNGLDELETERENDERBUFFERSEXTPROC)msys_oglfunc[27])
#define oglRenderbufferStorageEXT      ((PFNGLRENDERBUFFERSTORAGEEXTPROC)msys_oglfunc[28])
#define oglBindFramebufferEXT          ((PFNGLBINDFRAMEBUFFEREXTPROC)msys_oglfunc[29])
#define oglDeleteFramebuffersEXT       ((PFNGLDELETEFRAMEBUFFERSEXTPROC)msys_oglfunc[30])
#define oglCheckFramebufferStatusEXT   ((PFNGLCHECKFRAMEBUFFERSTATUSEXTPROC)msys_oglfunc[31])
#define oglFramebufferTexture1DEXT     ((PFNGLFRAMEBUFFERTEXTURE1DEXTPROC)msys_oglfunc[32])
#define oglFramebufferTexture2DEXT     ((PFNGLFRAMEBUFFERTEXTURE2DEXTPROC)msys_oglfunc[33])
#define oglFramebufferTexture3DEXT     ((PFNGLFRAMEBUFFERTEXTURE3DEXTPROC)msys_oglfunc[34])
#define oglFramebufferRenderbufferEXT  ((PFNGLFRAMEBUFFERRENDERBUFFEREXTPROC)msys_oglfunc[35])
#define oglGenerateMipmapEXT           ((PFNGLGENERATEMIPMAPEXTPROC)msys_oglfunc[36])
#define glCompressedTexImage2DARB  ((PFNGLCOMPRESSEDTEXIMAGE2DARBPROC)msys_oglfunc[37])
#define owglswapinterval ((PFNWGLSWAPINTERVALEXTPROC)msys_oglfunc[38])
#define oglGenFramebuffersEXT ((PFNGLGENFRAMEBUFFERSEXTPROC)msys_oglfunc[39])
#define oglGenRenderbuffersEXT ((PFNGLGENRENDERBUFFERSEXTPROC)msys_oglfunc[40])

// init
int msys_glextInit( void );
void initShader( int *pid,const char *vs,const char *fs );
#ifdef _DEBUG
unsigned char *readShaderFile( const char *fileName );
#endif
void Resize(int x, int y);
//backgrounds
void DrawStaticBG();
void DrawShaky();
void DrawRot(float time);
void DrawRotateTile(float rot);
void DrawDistort(float time);
void DrawWaving(float time);
void DrawZooming(float time);

//texture loader functions
GLuint loadDDSTextureMemory(unsigned char* data, int size, bool blur);
GLuint loadDDSTextureFile( const char *filename , bool blur);
GLuint loadTexGenTex(char* tex_filename, int width, int height);
GLuint loadTexGenTexMemory(unsigned char *data,int size, int width, int height);

// Sets an orthographic projection. x: 0..width, y: 0..height 
void BeginOrtho2D(float width, float height);
// Sets an orthographic projection. x: x1..x2, y: y1..y2 
void BeginOrtho2D(float x1, float y1, float x2, float y2) ;
// Sets a perspective projection with a different field-of-view 
void BeginPerspective(float fovy, float xratio) ;
void DrawFullScreenQuad( int iWidth, int iHeight );
// Restore the previous projection 
void EndProjection() ;

class Texture
{
public:
	// Structure to hold a texture image
	struct Image
	{
		int width, height;
		unsigned int format;
		unsigned char *data;
	};

	// Creates a texture from an image (deletes the image afterwards)
	Texture(Image *img, bool allowMipMaps = true)
	{
		glGenTextures(1, &id);
		glBindTexture(GL_TEXTURE_2D, id);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		// Set texture wrap mode to repeat
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
		// Upload the texture
		glTexImage2D(GL_TEXTURE_2D, 0, img->format, img->width, img->height, 0, img->format, GL_UNSIGNED_BYTE, img->data);
		// Free memory
		delete [] img->data;
		delete img;
	}

	// Frees memory
	~Texture()
	{
		glDeleteTextures(1, &id);
	}

	// Binds the texture
	void Bind()
	{
		glBindTexture(GL_TEXTURE_2D, id);
	}

	// Makes the texture clamp properly
	void ClampToEdge()
	{
		glBindTexture(GL_TEXTURE_2D, id);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	}

	// Enable/disable texturing
	static void Enable(bool yes)
	{
		if(yes)
			glEnable(GL_TEXTURE_2D);
		else
			glDisable(GL_TEXTURE_2D);
	}
private:
	// The texture id
	unsigned int id;
};

class Font
{
private:
	float x, y;
	float coords[256][4][2];
	int widths[256];

	int height;

	Texture *tex;

public:
	Font(const char *fontname, int fontsize, bool bold, bool italic, void *fontdata, int fontdata_len)
	{
		int x, y;
		int texsize = 512;
		int padding = italic?4:2; // Italic fonts require more padding
		DWORD nFonts;

		// Create a memory device context
		HDC hDC = CreateCompatibleDC(GetDC(0));

		if(!hDC)
			throw("Font failed to create memory DC");

		// And a memory bitmal
		BITMAPINFO bmpi = {0};
		bmpi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
		bmpi.bmiHeader.biWidth = texsize;
		bmpi.bmiHeader.biHeight = texsize;
		bmpi.bmiHeader.biPlanes = 1;
		bmpi.bmiHeader.biBitCount = 32;
		bmpi.bmiHeader.biCompression = BI_RGB;

		// Doing it this way gives me direct access to the bitmap memory
		BYTE *pBits = NULL;
		HBITMAP hBmp = CreateDIBSection(hDC, &bmpi, DIB_RGB_COLORS, (void**)&pBits, NULL, 0);

		if(!hBmp)
		{
			DeleteObject(hDC);
			throw("Font failed to create memory DIB section");
		}

		SelectObject(hDC, hBmp);

		SetBkColor(hDC, RGB(0, 0, 0));
		SetTextColor(hDC, RGB(255, 255, 255));

		HANDLE m_fonthandle = AddFontMemResourceEx(
			fontdata,       	// font resource
			fontdata_len,       	// number of bytes in font resource 
			NULL,          	// Reserved. Must be 0.
			&nFonts      	// number of fonts installed
			);


		// Create the font
		HFONT fnt = CreateFont(fontsize, 0, 0, 0, bold?FW_HEAVY:FW_NORMAL, italic, false, false,
			ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY,
			FF_DONTCARE | DEFAULT_PITCH, fontname);


		if(!fnt)
		{
			DeleteObject(hBmp);
			DeleteObject(hDC);
			throw("Font failed to create truetype");
		}

		SelectObject(hDC, fnt);

		// Get character width information
		if(!GetCharWidth32(hDC, 0, 255, widths))
		{
			if(!GetCharWidth(hDC, 0, 255, widths))
			{
				DeleteObject(hBmp);
				DeleteObject(hDC);
				throw("Font failed to get character widths");
			}
		}

		// Render the characters to the bitmap
		unsigned char c = 0;
		int c_height = (int)(fontsize * 1.333f);
		height = c_height;

		for(y = c_height; (y < texsize) && (c < 256); y += c_height)
			for(x = widths[c]; (x < texsize) && (c < 256); x += widths[c] + padding)
			{
				TextOut(hDC, x-widths[c], y-c_height, (char *)&c, 1);
				c++;
			}

			// Make sure it's done
			GdiFlush();

			// Create a texture image from the bitmap
			Texture::Image *img = new Texture::Image;
			img->width = img->height = texsize;
			img->format = GL_RGBA;
			img->data = new unsigned char [img->width * img->height * 4];
			memcpy(img->data, pBits, img->width * img->height * 4);

			// Create a basic alpha channel
			for(int a = 0; a < img->width * img->height * 4; a += 4)
				img->data[a+3] = img->data[a];

			// Free some memory
			DeleteObject(fnt);
			DeleteObject(hBmp);
			DeleteObject(hDC);

			// Create the texture
			tex = new Texture(img);

			// Create the texture coordinates
			float u1, v1, u2, v2;

			c = 0;
			for(y = c_height; (y < texsize) && (c < 256); y += c_height)
				for(x = widths[c]; (x < texsize) && (c < 256); x += widths[c] + padding)
				{
					u1 = (x-widths[c])/(float)texsize;
					v1 = 1 - (y-c_height)/(float)texsize;
					u2 = x/(float)texsize;
					v2 = 1- y/(float)texsize;

					coords[c][0][0] = u1;
					coords[c][0][1] = v1;

					coords[c][1][0] = u2;
					coords[c][1][1] = v1;

					coords[c][2][0] = u2;
					coords[c][2][1] = v2;

					coords[c][3][0] = u1;
					coords[c][3][1] = v2;

					c++;
				}

				RemoveFontMemResourceEx(m_fonthandle);
	}
	// Creates a font
	Font(const char *fontname, int fontsize, bool bold, bool italic)
	{
		int x, y;
		int texsize = 512;
		int padding = italic?4:2; // Italic fonts require more padding

		// Create a memory device context
		HDC hDC = CreateCompatibleDC(GetDC(0));

		if(!hDC)
			throw("Font failed to create memory DC");

		// And a memory bitmal
		BITMAPINFO bmpi = {0};
		bmpi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
		bmpi.bmiHeader.biWidth = texsize;
		bmpi.bmiHeader.biHeight = texsize;
		bmpi.bmiHeader.biPlanes = 1;
		bmpi.bmiHeader.biBitCount = 32;
		bmpi.bmiHeader.biCompression = BI_RGB;

		// Doing it this way gives me direct access to the bitmap memory
		BYTE *pBits = NULL;
		HBITMAP hBmp = CreateDIBSection(hDC, &bmpi, DIB_RGB_COLORS, (void**)&pBits, NULL, 0);

		if(!hBmp)
		{
			DeleteObject(hDC);
			throw("Font failed to create memory DIB section");
		}

		SelectObject(hDC, hBmp);

		SetBkColor(hDC, RGB(0, 0, 0));
		SetTextColor(hDC, RGB(255, 255, 255));

		// Create the font
		HFONT fnt = CreateFont(fontsize, 0, 0, 0, bold?FW_HEAVY:FW_NORMAL, italic, false, false,
			ANSI_CHARSET, OUT_TT_PRECIS, CLIP_DEFAULT_PRECIS, ANTIALIASED_QUALITY,
			FF_DONTCARE | DEFAULT_PITCH, fontname);


		if(!fnt)
		{
			DeleteObject(hBmp);
			DeleteObject(hDC);
			throw("Font failed to create truetype");
		}

		SelectObject(hDC, fnt);

		// Get character width information
		if(!GetCharWidth32(hDC, 0, 255, widths))
		{
			if(!GetCharWidth(hDC, 0, 255, widths))
			{
				DeleteObject(hBmp);
				DeleteObject(hDC);
				throw("Font failed to get character widths");
			}
		}

		// Render the characters to the bitmap
		unsigned char c = 0;
		int c_height = (int)(fontsize * 1.333f);
		height = c_height;

		for(y = c_height; (y < texsize) && (c < 256); y += c_height)
			for(x = widths[c]; (x < texsize) && (c < 256); x += widths[c] + padding)
			{
				TextOut(hDC, x-widths[c], y-c_height, (char *)&c, 1);
				c++;
			}

			// Make sure it's done
			GdiFlush();

			// Create a texture image from the bitmap
			Texture::Image *img = new Texture::Image;
			img->width = img->height = texsize;
			img->format = GL_RGBA;
			img->data = new unsigned char [img->width * img->height * 4];
			memcpy(img->data, pBits, img->width * img->height * 4);

			// Create a basic alpha channel
			for(int a = 0; a < img->width * img->height * 4; a += 4)
				img->data[a+3] = img->data[a];

			// Free some memory
			DeleteObject(fnt);
			DeleteObject(hBmp);
			DeleteObject(hDC);

			// Create the texture
			tex = new Texture(img);

			// Create the texture coordinates
			float u1, v1, u2, v2;

			c = 0;
			for(y = c_height; (y < texsize) && (c < 256); y += c_height)
				for(x = widths[c]; (x < texsize) && (c < 256); x += widths[c] + padding)
				{
					u1 = (x-widths[c])/(float)texsize;
					v1 = 1 - (y-c_height)/(float)texsize;
					u2 = x/(float)texsize;
					v2 = 1- y/(float)texsize;

					coords[c][0][0] = u1;
					coords[c][0][1] = v1;

					coords[c][1][0] = u2;
					coords[c][1][1] = v1;

					coords[c][2][0] = u2;
					coords[c][2][1] = v2;

					coords[c][3][0] = u1;
					coords[c][3][1] = v2;

					c++;
				}
	}

	// Free memory
	~Font()
	{
		delete tex;
	}

	// Prints text at the current position
	void Print(const char *fmt, ...)
	{
		va_list ap;

		unsigned char buffer[256];

		// Allow formatted output
		va_start(ap, fmt);
		vsprintf((char*)buffer, fmt, ap);
		va_end(ap);

		int l = strlen((char*)buffer);

		tex->Bind();

		// Draw the text
		glBegin(GL_QUADS);
		for(int a = 0; a < l; a++)
		{
			unsigned char c = buffer[a];

			glTexCoord2fv(coords[c][0]); glVertex2f(x, y + height);
			glTexCoord2fv(coords[c][1]); glVertex2f(x + widths[c], y + height);
			glTexCoord2fv(coords[c][2]); glVertex2f(x + widths[c], y);
			glTexCoord2fv(coords[c][3]); glVertex2f(x, y);

			x += widths[c];
		}
		glEnd();
	}

	// Prints text at a specified position
	void Print(float x1, float y1, const char *fmt, ...)
	{
		va_list ap;

		x = x1;
		y = y1;

		unsigned char buffer[256];

		// Allow formatted output
		va_start(ap, fmt);
		vsprintf((char*)buffer, fmt, ap);
		va_end(ap);

		int l = strlen((char*)buffer);

		tex->Bind();

		// Draw the text
		glBegin(GL_QUADS);
		for(int a = 0; a < l; a++)
		{
			unsigned char c = buffer[a];

			glTexCoord2fv(coords[c][0]); glVertex2f(x, y + height);
			glTexCoord2fv(coords[c][1]); glVertex2f(x + widths[c], y + height);
			glTexCoord2fv(coords[c][2]); glVertex2f(x + widths[c], y);
			glTexCoord2fv(coords[c][3]); glVertex2f(x, y);

			x += widths[c];
		}
		glEnd();
	}


};


#endif
