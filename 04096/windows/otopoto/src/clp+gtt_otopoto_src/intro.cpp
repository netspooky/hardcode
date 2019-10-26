/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#include "defines.h"
#include "port.h"
#include "play.h"
#include "extensions.h"
#include "shaders.h"

//----------------------------------------------------------------------------------
// Intro defines and data
//----------------------------------------------------------------------------------
#define NOISE_ID	1
#define TIME_MULT	0.037598f

#pragma data_seg("data_extensions")
	char extensionStrings[16][21] ={{"glCreateProgram"},
									{"glCreateShader"},
									{"glShaderSource"},

									{"glCompileShader"},
									{"glAttachShader"},

									{"glLinkProgram"},
									{"glUseProgram"},

									{"glUniform1f"},
									{"glUniform2f"},
									{"glUniform3f"},
									{"glGetUniformLocation"}};
#pragma data_seg()

//----------------------------------------------------------------------------------
// Intro unitialized data
//----------------------------------------------------------------------------------
#pragma bss_seg ("data_zero")
	GLUquadricObj		*qobj = 0;
	u32					skyShader=0, oceanShader=0, isleShader=0, palmTree=0, palmLeaves=0;
	float				heightTable[256*256/4] = {0};
	void*				extensions[16];
#pragma bss_seg ()

//----------------------------------------------------------------------------------
// Intro stuff now
//----------------------------------------------------------------------------------

#pragma code_seg ("code_FlatMatrix")
void NAKED FlatMatrix (void)
{
	__asm
	{
		push	esi
		push	edi

		mov		esi, [glMatrixMode]
		mov		edi, [glLoadIdentity]

		push	GL_MODELVIEW
		call	esi
		call	edi

		push	GL_PROJECTION
		call	esi
		call	edi

		pop		edi
		pop		esi
		ret		0
	}
}

#ifdef _DEBUG
void CheckShader (u32 shader)
{
	s32 infologLength = 0, charsWritten  = 0;

	((PFNGLGETSHADERIVPROC)wglGetProcAddress("glGetShaderiv")) (shader, GL_INFO_LOG_LENGTH,&infologLength);

	if (infologLength > 1)
	{
	    s8 *infoLog = (s8 *)malloc(infologLength);
	    ((PFNGLGETSHADERINFOLOGPROC)wglGetProcAddress("glGetShaderInfoLog"))(shader, infologLength, &charsWritten, infoLog);
#ifdef WIN32
		OutputDebugString (infoLog);
#endif
	    free(infoLog);
	}
}

void CheckProgram (u32 program)
{
	s32 infologLength = 0,  charsWritten  = 0;

	((PFNGLGETPROGRAMIVPROC)wglGetProcAddress("glGetProgramiv"))(program, GL_INFO_LOG_LENGTH,&infologLength);

	if (infologLength > 1)
	{
	    s8 *infoLog = (s8 *)malloc(infologLength);
	    ((PFNGLGETPROGRAMINFOLOGPROC)wglGetProcAddress("glGetProgramInfoLog"))(program, infologLength, &charsWritten, infoLog);
#ifdef WIN32
		OutputDebugString (infoLog);
#endif
	    free(infoLog);
	}

}
#else
#define CheckShader(a)
#define CheckProgram(a)
#endif

/*
 * Heavily modified from: http://sizecoding.blogspot.com/2009/01/glsl-shader-creation-geometry-vertex.html
 */
#pragma code_seg ("code_CompileShader")
u32 CompileShader (const char *vs, const char *fs)
{
	GLuint program, shader;

	program = glCreateProgram();

	// Vertex shader
	shader = glCreateShader(GL_VERTEX_SHADER);

	glShaderSource	(shader, 1, &vs, NULL);
	glCompileShader	(shader); 
	glAttachShader	(program, shader);
	CheckShader		(shader);

	// Fragment shader 
	shader = glCreateShader(GL_FRAGMENT_SHADER); 

	glShaderSource	(shader, 1, &fs, NULL);
	glCompileShader	(shader);
	glAttachShader	(program,shader);
	CheckShader		(shader);
 
	glLinkProgram	(program);
	CheckProgram	(program);

	return program;
}

#pragma code_seg ("code_CreateNoiseTex")
void CreateNoiseTex (u8 *buffer)
{
	for (u32 x = 0; x < 256*256; x++)
	{
		buffer[x] = rand()%256;
	}
}

#pragma code_seg ("code_setLighting")
void SetupLighting ()
{
	glLightfv	(GL_LIGHT0, GL_POSITION, &heightTable[16]);
	glEnable	(GL_LIGHT0);
	glEnable	(GL_LIGHTING);
	glEnable	(GL_DEPTH_TEST);
}

#pragma code_seg ("code_init4K")
void init4K (void)
{
	qobj = gluNewQuadric ();
	gluQuadricTexture (qobj, GL_TRUE);

	// Create a noise texture and upload it to OpenGL
	CreateNoiseTex		((u8*)heightTable);
	glBindTexture		(GL_TEXTURE_2D, NOISE_ID);
	glTexParameteri		(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	gluBuild2DMipmaps	(GL_TEXTURE_2D, 1, 256, 256, GL_LUMINANCE, GL_UNSIGNED_BYTE, heightTable);

	for (u32 i = 0; i < 16; i++)
	{
		heightTable[i] = (rand()/32768.f);
		extensions[i] = wglGetProcAddress(extensionStrings[i]);
	}

	// Load all used shaders
	skyShader	= CompileShader (SkyVP, SkyFP);
	oceanShader = CompileShader (OceanVP, OceanFP);
	isleShader	= CompileShader (OceanVP, IsleFP);
	palmTree	= CompileShader (PalmTreeVP, PalmFP);
	palmLeaves	= CompileShader (PalmLeavesVP, PalmFP);
}

#pragma code_seg ("code_gluLook")
void gluLook	(float x, float y, float z, float x2, float y2, float z2)
{
	FlatMatrix		();
	gluPerspective	(60.f, 1.6015625f, 1.f, 14976.f); // 16:10
	//gluPerspective	(60.f, 1.3359375f, 1.f, 14976.f); // 4:3
	glMatrixMode	(GL_MODELVIEW);
	gluLookAt		(x, y, z, x2, y2, z2, 0.f, 1.f, 0.f);
}

#pragma code_seg ("code_DrawPalmTree")
void DrawPalmTree (void)
{
	// Draw the palm base
	glUseProgram(palmTree);
	glRotatef	(-90.f, 1.f, 0.f, 0.f);
	glTranslatef(0.f, 0.f, -7.5f);
	gluCylinder (qobj, 0.150390625f, 0.150390625f, 20.f, 16, 24);
	glTranslatef(0.f, -0.2001953125f, 20.f);
	
	// Draw the palm leaves
	glUseProgram(palmLeaves);

	for (u32 i = 0; i < 24; ++i)
	{
		glPushMatrix ();
		glRotatef	(i*35.f, 0.f, 0.f, 1.f);
		glRotatef	(45.f*sinf(i*0.8671875f), 1.f, 0.f, 0.f);
		gluCylinder	(qobj, 0.5f, 0.298828125f, 4.f, 4, 60);
		glPopMatrix ();
	}
}

#pragma code_seg ("code_renderAll")
void renderAll ()
{
	SetupLighting	();

	// Render sky
	glUseProgram	(skyShader);
	glUniform3f		(glGetUniformLocation(skyShader, "y"), 0.f, sinf(current_time*TIME_MULT), cosf(current_time*TIME_MULT));
	glUniform3f		(glGetUniformLocation(skyShader, "z"), 0.f, 9.875f, 0.f);
	gluSphere		(qobj, 9984.f, 32, 32);

	// Render isle
	glUseProgram	(isleShader);
	glUniform2f		(glGetUniformLocation(oceanShader, "u"), 23.75f, 0.006011962890625f);
	glUniform1f		(glGetUniformLocation(oceanShader, "f"), 1);
	gluDisk			(qobj, 0.f, 652.f, 64, 64);

	// Render water
	glEnable		(GL_BLEND);
	glBlendFunc		(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glUseProgram	(oceanShader);
	glUniform1f		(glGetUniformLocation(oceanShader, "i"), current_time);
	glUniform2f		(glGetUniformLocation(oceanShader, "u"), 0.5f, 0.11962890625f);
	gluDisk			(qobj, 0.f, 9984.0f, 256, 256);
	glDisable		(GL_BLEND);

	// Render palm tree
	float* heightTptr = heightTable;

	for (u32 z = 0; z < 4; z++)
	for (u32 x = 0; x < 4; x++, heightTptr++)
	{
		glPushMatrix	();
		glScalef		(*heightTptr*5.f+5.f, *heightTptr*5.f+5.f, *heightTptr*5.f+5.f);
		glRotatef		(*heightTptr*360.f, - 0.10009765625f, 1.f, 0.f);
		glTranslatef	((x-2.f)*8.f, *heightTptr*-2.f, (z-2.f)*+8.f);
		DrawPalmTree	();
		glPopMatrix		();
	}
}

#pragma code_seg ("code_renderIntro")
void renderIntro (void)
{
	glClear	(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// This are the position of the sun / light that is used for illumination
	heightTable[16] = 0.f;
	heightTable[17] = sinf(current_time*TIME_MULT)*1000.f;
	heightTable[18] = cosf(current_time*TIME_MULT)*4992.f;
	heightTable[19] = 0.f;

	// Setup camera, based on time slice
	if (cur_pos < 4 || cur_pos == 255)
	{
		gluLook		(900.f, 250.f+10.f*current_time, 4000.f, 900.f, heightTable[17]+752.000000f, heightTable[18]);
	}
	else if (cur_pos < 8)
	{
		float	t = current_time-6.562500f;
		float	x = 900.f+sinf(t*2.75f)*50.f,
				y = 316.f-(fabsf(sinf(t*2.75f)-t))*10.f;

		gluLook		(x, y, 4000.f-t*644.f, 900.f, heightTable[17]+1752.f, heightTable[18]);
	}
	else if (cur_pos < 16)
	{
		float	t = current_time*-0.10009765625f;
		float	x =  680.f*sinf(t),
				z = -680.f*cosf(t);

		gluLook		(x, 100.f, z, -100.f, 35.f, -3.f);
	}
	else if (cur_pos < 32)
	{
		float	t = current_time*-0.10009765625f;
		float	x =  680.f*sinf( t)+sinf(current_time*2.75f)*+50.f,
				y =  fabsf(sinf(-t)*100.f)-fabsf(sinf(current_time*2.75f)*10.f)+current_time*10.f,
				z = -680.f*cosf( t);

		gluLook		(x, y, z, -100.f, 35.f, -3.f);
	}
	else if (cur_pos < 39)
	{
		float	y =   250.f+10.f*current_time;

		gluLook		(900.f, y, 4000.f, 900.f, y, heightTable[18]);
	}
	else
		APP_EXIT_4K(0);

	// Render the scene
	renderAll	();
}