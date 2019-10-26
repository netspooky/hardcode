// BUNCHBOX, Brad Smith 9/18/2009

#include <GL/gl.h>
#include <GL/glu.h>

#include "sound.h"
#include "madlib.h"
#include "song.h"

#include "math.h"
#include "font.h"
#include "geometry.h"

#define DEBUG_WIREFRAME 0

// scroll text
const char DEMO_MSG[] =
  "Bunchbox: a 4k intro by Brad Smith, 9/18/2009."
  "          "
  "Made possible by the Crinkler @crinkler.net,"
  " and thanks to:"
  " BluFlame @blu-flame.org for the Valleyball source"
  " and Leonard @leonard.oxg.free.fr for ST-Sound and other inspiration."
  "          "
  "Full source is available at switch.to/unleaded."
  " Thanks for watching!";

const int DEMO_MSG_LEN = sizeof(DEMO_MSG)-1;

// current frame of music playback (each frame is 512 samples long)
static uint32 frame;

// constantly increasing angles for animation
float angle_x = 0.0f;
float angle_y = 0.0f;

// scrolling message printed on a corkscrew
void corkscrew_msg( float dt, float snare )
{
	const float SCALE = 8.0f;
	glScalef( SCALE, SCALE, SCALE );

	const float LEFT = -20.0f;
	const float RIGHT = 20.0f;
	const float SPAN = RIGHT - LEFT;

	const float PIECES = 30.0f;
	const float PIECE = SPAN / PIECES;

	const float SCREW1 = 0.2f;
	const float SCREW2 = 0.31f;

	const float SCROLL = 6.0f;

	// scroll the text
	static float shift = 0.0f;
	static int msg_off = -int(PIECES);
	shift += dt * SCROLL;
	while ( shift > 1.0f )
	{
		++msg_off;
		if (msg_off > DEMO_MSG_LEN ) msg_off = -int(PIECES);
		shift -= 1.0f;
	}

	// draw the corkscrew
	glBegin(GL_QUADS);
	for ( float f=0; f < PIECES; f+=1.0f )
	{
		int i = int(f) + msg_off;
		if ( i < 0 || i >= DEMO_MSG_LEN ) continue;

		const float s = f - shift;
		const float q = (angle_x + s) * SCREW1 + (fsin(angle_y + s) * SCREW2);

		const float x = LEFT + (s * PIECE);
		const float y = fsin( q ) * snare;
		const float z = fcos( q ) * snare;

		glColor3f(1.5f - (1.5f * f / PIECES), 1.0f, 0.0f);
		draw_char(DEMO_MSG[i],vec3(x,y,z));
	}
	glEnd();
}

// recursively drawn "random" cube
void magic_cube( int level, uint32 param, vec3 pos, vec3 dim )
{
	if ( level == 0 ) geom_box(pos-dim,pos+dim);
	if ( level <= 0 ) return;

	for ( uint32 i=0; i < 8; ++i )
	{
		vec3 tdim;
		for ( uint32 v = 0; v < 3; ++v )
		{
			// use the three bits of 0 to 8 to divide the cube into 8 pieces
			tdim.v[v] = dim.v[v] * ((0 == (i & (1<<v))) ? 0.5f : -0.5f);
		}

		int tlevel = level;
		// if a bit in i is set, skip a level before subdividing
		if ( 0 == (param & (1<<i)) )
		{
			tdim = tdim * 0.5f;
			--tlevel;
		}

		magic_cube( tlevel-1, param, pos + tdim, tdim );
	}
}

void music_box( float dt, const Madlib::Sync * sync )
{
	const float kick = sync[CHANNEL_KICK ].vol;
	const uint32 cube = sync[CHANNEL_BASS].note;

	// spin the box
	glRotatef(angle_x,1,0,0);
	glRotatef(angle_y,0,1,0);

	// draw the box
	glBegin(GL_QUADS);
	glColor3f(0.2f,0.2f,1.0f);
	magic_cube(3,cube,vec3(0,0,0),vec3(16,16,16) * (1.0f + kick));
	glEnd();
}

int main4k(const char * cmdline)
{
	// create window
	setup_window();

	// setup other stuff
	setup_font();
	play_song(); // sets up Madlib and calls Sound::sound_open

	// main loop
	while ( true )
	{
		// get frame time and music sync data
		static uint32 last_frame = 0;
		Madlib::Sync sync[Madlib::NUM_CHANNELS];
		Madlib::get_sync( &frame, sync );

		// calculate frame time
		float dt = float(((frame-last_frame)*Madlib::FRAME_LEN))/float(Madlib::SAMPLERATE);
		last_frame = frame;

		// projection:
		// aprox 100 units wide across the origin
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(60.0f,float(WIDTH)/float(HEIGHT),50.0f,1000.0f);
		glTranslatef(0.0f,0.0f,-100.0f);

		// switch to model view
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();

#if DEBUG_WIREFRAME
		static bool wireframe = false;
		//glFrontFace(GL_CCW);
		//glCullFace(GL_BACK);
		//glEnable(GL_CULL_FACE);
		//glPolygonMode(GL_FRONT,GL_LINE); // wireframe front
		if ( wireframe )
		{
			glPolygonMode(GL_FRONT_AND_BACK,GL_LINE); // wireframe
		}
#endif

		// setup some stuff
		glEnable(GL_NORMALIZE);
		glEnable(GL_DEPTH_TEST);

		// clear the back buffer
		glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
		glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );

		// setup directional light
		glEnable(GL_LIGHTING);
		glEnable(GL_LIGHT0);
		//const vec3 lposv = vec3(0.5f,0.2f,1.0f).nrm();
		float lpos[4] = { 0.913f, 0.365f, 0.183f, 0.0f };
		float lcol[4] = { 1.0f, 1.0f, 1.0f, 1.0f };
		glLightfv(GL_LIGHT0,GL_POSITION,lpos);
		glLightfv(GL_LIGHT0,GL_DIFFUSE,lcol);
		glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,lcol);
		//const float AMB = 1.0f - lposv.z;
		//float ambient[4] = { AMB, AMB, AMB, 1.0f };
		float ambient[4] = { 0.817f, 0.817f, 0.817f, 0.0f };
		glLightModelfv( GL_LIGHT_MODEL_AMBIENT, ambient );
		glEnable(GL_COLOR_MATERIAL);
		glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
		//glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,1);

		angle_x += dt * 20.0f;
		angle_y += dt * 11.0f;
		// NOTE: these will eventually lose accuracy, but that's not important for this demo

		// draw music box
		glPushMatrix();
		music_box(dt,sync);
		glPopMatrix();

		// draw corkscrew message
		const float snare = sync[CHANNEL_SNARE].vol;
		corkscrew_msg(dt, 3.0f + 4.0f * snare );

		// swap the buffers
		glFinish();
		paint();

		// quit if escape is pressed
		if ( GetAsyncKeyState(VK_ESCAPE) )
		{
			break;
		}

#if DEBUG_WIREFRAME
		static bool space_state = false;
		if ( GetAsyncKeyState(VK_SPACE) )
		{
			if ( !space_state )
			{
				wireframe = !wireframe;
			}
			space_state = true;
		}
		else
		{
			space_state = false;
		}
#endif
	}

	// shutdown
	Sound::sound_close();
	ExitProcess(0);
	return 0;
}

// end of file
