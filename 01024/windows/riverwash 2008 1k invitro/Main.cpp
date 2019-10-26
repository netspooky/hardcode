// Chris Thornborrow (auld)
// riverwash invitro

// /CRINKLER /COMPMODE:SLOW /HASHSIZE:200 /HASHTRIES:50 /ORDERTRIES:2000 
//           /UNSAFEIMPORT /RANGE:opengl32 /TRUNCATEFLOATS:12

#include <windows.h>
#include <GL/gl.h>
#include "glext.h"

#pragma data_seg(".pfd")
HDC hDC;
static PIXELFORMATDESCRIPTOR pfd={
0, // Size Of This Pixel Format Descriptor... BAD coding, nothing new, saves 6 bytes
0, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
};

#pragma data_seg(".glyphs")
GLYPHMETRICSFLOAT agmf[255];
HMIDIOUT device;

#pragma code_seg(".createFont")
__forceinline void create3DFont ()
{

    SelectObject(hDC, CreateFont(0,0, 0,0,0,0,0,0,0,0,0,0,0,"Arial"));    
    wglUseFontOutlines(hDC,             // DC with font
                   0,                  // Starting character index
                   255,                 // Number of characters
                   255,                // Display-list number
                   0,                   // Deviation
                   0,                // Extrusion
                   WGL_FONT_POLYGONS,   // Format
                   agmf);
}

#pragma code_seg(".print")
__forceinline void print (const char *s)
{
     glPushMatrix();
	 glListBase(255);
	 glTranslatef(-0.25f,-0.3,0);
     glCallLists(strlen(s), GL_UNSIGNED_BYTE, s) ;
     glPopMatrix();
}


#define CRITICAL 3000
#define BASESCALE 0.026f

#pragma data_seg(".strings")
#define NTEXTS 12
char *text[NTEXTS]={"+www.riverwash.info", "+2008", "+mayhem", "Riverwash", "+29-31 August",
"Rudy", "Raciborskie", "Poland", "Riverwash","+oldskool","+newskool", "+vodkaskool"};



#pragma code_seg(".main")
void WINAPI WinMainCRTStartup()
{
unsigned int starttime,curtime,ind;
unsigned int col =0x000000FF;

   starttime=ind=0;
   hDC = GetDC( CreateWindow("edit", 0, WS_POPUP|WS_VISIBLE|WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0) );
   SetPixelFormat ( hDC, ChoosePixelFormat ( hDC, &pfd) , &pfd );
   wglMakeCurrent ( hDC, wglCreateContext(hDC) ); 
   ShowCursor(FALSE);
   create3DFont();
   midiOutOpen(&device, MIDI_MAPPER, 0, 0, 0);
   
   do {
	     
	     curtime = GetTickCount()-starttime;
	   
		 glLoadIdentity();
         glRects (1,1,-1,-1);
		 glScalef(curtime,curtime,0);
         if(ind&1) glRotatef(0.1201171875f*curtime,0,0,1);
		 
		 for (int i=0; i<4; i++) {
		     col^=0xFFFFFF00;
             glColor4ubv((GLubyte *)&col);
		     glScalef(BASESCALE,BASESCALE,0);
		     print (text[(ind+i)%NTEXTS]);
		 }
		
		 if (curtime>CRITICAL) {
	         midiOutShortMsg(device,(6<<8)|0x00400091);
			 col^=0xFFFFFF00;
			 ++ind;
			 starttime=GetTickCount();
		 }		 
         SwapBuffers(hDC);
    } while ( !GetAsyncKeyState(VK_ESCAPE) );   
	ExitProcess(0); 
}

