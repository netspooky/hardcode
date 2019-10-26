////////////////////////////////////////////////////////////////////////////////
// load .lib files
#pragma comment( lib, "opengl32.lib" )											// Search For OpenGL32.lib While Linking
#pragma comment( lib, "glu32.lib" )												// Search For GLu32.lib While Linking
//#pragma comment( lib, "glaux.lib" )												// Search For GLaux.lib While Linking

////////////////////////////////////////////////////////////////////////////////
// disable warining
#pragma warning(disable : 4786)
#pragma warning(disable : 4305)
#pragma warning(disable : 4033)	// OMF to COFF warning
#pragma warning(disable : 4089)	// ADVAPI32.dll warning
////////////////////////////////////////////////////////////////////////////////
// include basis header
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>

#define PI				(3.14159265358979323846f)	// Pi
////////////////////////////////////////////////////////////////////////////////
// include creation header
#include <vector>
#include <algorithm>
using namespace std;
#include "glmain.h"																// for gl
#include "mathorg.h"															// create sin cos table
#include "common.h"																// common
#include "audio.h"																// for audio
#include "light.h"																// lighting
#include "perlin.h"
#include "texture.h"															// texture
#include "camera.h"
#include "matrix.h"																// some matrix functions
#include "algorithm.h"															// concern to algorithm
#include "misc.h"
#include "basicObjects.h"														// basic objects
#include "objects.h"															// some objects functions and classess
#include "scene.h"

//Screen size
extern cSize2f window;

extern cAudio bgm;
extern "C"{
	extern char intromusic;
}

extern cSceneAll sceneall;

