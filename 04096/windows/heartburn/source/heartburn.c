#define _CRT_SECURE_NO_WARNINGS
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "clinkster.h"

#define GL_GLEXT_PROTOTYPES
#ifdef __linux__
# include <GL/gl.h>
# include <GL/glext.h>
# include <SDL/SDL.h>
#else
# include <windows.h>
# include <GL/glcorearb.h>
# include <GL/glext.h>
# include <GL/wglext.h>
# include "gl-win32.h"
#endif


// Compilation parameters
#define FINAL
#define FPS_COUNTER
#define ERROR_CHECK
#define HAS_MUSIC
//#define FULLSCREEN

#ifdef FINAL
//# undef FULLSCREEN
# define HAS_MUSIC
# undef FPS_COUNTER
# undef ERROR_CHECK
# ifdef __linux__
#  define INLINE static inline __attribute__((always_inline))
# else
#  define INLINE static __forceinline
# endif
# ifndef S_WIDTH
#  error "S_WIDTH is not defined"
# endif
# ifndef S_HEIGHT
#  error "S_HEIGHT is not defined"
# endif
#else
# define INLINE
#endif



// Window parameters
#ifdef FULLSCREEN
# ifndef S_WIDTH
#  define S_WIDTH 1366
# endif
# ifndef S_HEIGHT
#  define S_HEIGHT 720
# endif
# define S_FLAGS SDL_FULLSCREEN|SDL_OPENGL
#else
# ifndef S_WIDTH
#  define S_WIDTH 1280
# endif
# ifndef S_HEIGHT
#  define S_HEIGHT 720
# endif
# define S_FLAGS SDL_OPENGL
#endif

// Max shaders log size
#define LOG_SIZE 65536

// FPS counter size
#define COUNTER_FRAMES 20


// Timing stuff
static int timeCurrent;
static int timeOffset = 0;
static float musicPos;

// Line storage
struct line_t
{
	int offset;
	int count;
};

// Vertices and lines
#define FX_MIN_LEN 64
#define FX_MAX_LEN 128
#define FX_LINES 150
#define RDR_FLOATS 11
static float vertices[ RDR_FLOATS * FX_LINES * FX_MAX_LEN ];
static int vbIndex;
static struct line_t lines[ FX_LINES ];


// Temporary vertex, used when constructing the scene
#define VB_INDEX 0
#define VB_LINE_OFFSET_X 1
#define VB_LINE_OFFSET_Y 2
#define VB_LINE_OFFSET_Z 3
#define VB_LINE_OFFSET_T 4
#define VB_POINT_OFFSET_X 5
#define VB_POINT_OFFSET_Y 6
#define VB_POINT_OFFSET_Z 7
#define VB_COLOUR 8
static float vbTemp[ RDR_FLOATS ];

// Uniforms
//	0  ..	5	Untz
//	6		Time (seconds)
//	7		Effect transition time
//	8		Rotation mixer
//	9		Flame effect strength
//	10		Screen size ratio
static float uniforms[ 11 ];


// Random number generator
static unsigned int rngState = 0;
#define RNG_MAX 0xfffffffe
#define RNG_MULT 2147483629
#define RNG_INC 2147483587

// Shader bits
#include "shaders.h"

// Shader assembly
static char const * sources[10];
#ifdef FINAL
# define SHADER(x) (x+1)
# define SET_SHADER(x,y) y
# define CREATE_PROGRAM(x) glCreateProgram()
# define PRG_SEED(x) (x*2+16)
# define PRG_LINES(x) (x*2+17)
# define PRG_RENDER 26
# define PRG_COPY 27
# define PRG_FLAME 28
#else
static GLenum shaders[N_SHADERS];
# define SHADER(x) shaders[x]
# define SET_SHADER(x,y) shaders[x]=y,printf("Shader %d = %d\n" ,x,shaders[x])
# define CREATE_PROGRAM(x) x = glCreateProgram(),printf("Program " #x " = %d\n" ,x)
static GLenum seedPrograms[5];
# define PRG_SEED(x) seedPrograms[x]
static GLenum linePrograms[5];
# define PRG_LINES(x) linePrograms[x]
static GLenum renderProgram;
# define PRG_RENDER renderProgram
static GLenum copyProgram;
# define PRG_COPY copyProgram
static GLenum flameProgram;
# define PRG_FLAME flameProgram
#endif

// Vertex shaders setup
static char const* const varyings[3] = { "o1", "o2" , "o3" };
static char const* const gVaryings[3] = { "g1", "g2" , "g3" };
static char attrName[] = {'a' , 'a' , 0 };
static unsigned char seedAttribSizes[]={1,4,4};
static unsigned char renderAttribSizes[]={4,4,3};

// Vertex arrays and transform feedbacks
#ifdef FINAL
static GLuint initJunk[4];
# define VBO_INIT initJunk
# define VBO(i) (i+1)
# define TFO_INIT initJunk
# define TFO(i) (i+1)
#else
static GLuint vertexArrays[4];
# define VBO_INIT vertexArrays
# define VBO(i) vertexArrays[i]
static GLuint transformFeedbacks[3];
# define TFO_INIT transformFeedbacks
# define TFO(i) transformFeedbacks[i]
#endif

// Direction
static int curSeed = 0;
static int transitionStart = 0x4000000;
static int lcPos;


#ifdef __linux__

// Sound output position
static int _sdlout_pos = 0;

void SDLSoundOut( void *unused , Uint8 *stream , int len )
{
	int ns = len / sizeof( struct sample );
	if ( _sdlout_pos + ns >= 3276800 ) {
		ns = 3276800 - _sdlout_pos;
		if ( ns <= 0 ) {
			return;
		}
	}

	memcpy( stream , &( Clinkster_MusicBuffer[ _sdlout_pos ] ) ,
			ns * sizeof( struct sample ) );
	_sdlout_pos += ns;
}

float Clinkster_GetPosition()
{
	extern int c_timeoffset;
	extern int c_ticklength;
	return 4 * ( (float)_sdlout_pos + c_timeoffset ) / (float)( c_ticklength );
}

#endif


unsigned int rnd( unsigned int max )
{
	return (
		rngState = ( rngState * RNG_MULT + RNG_INC )
				% ( RNG_MAX + 1 )
	) % max;
}


float frnd( )
{
	return rnd( 257 ) / 256.f;
}


INLINE void putVertex( )
{
	memcpy( &( vertices[ vbIndex ] ) , vbTemp ,
			RDR_FLOATS * sizeof( float ) );
	vbIndex += RDR_FLOATS;
}


INLINE void generateLine( int vertices )
{
	int i;

	vbTemp[ VB_LINE_OFFSET_X ] = 2.f * frnd( ) - 1.f;
	vbTemp[ VB_LINE_OFFSET_Y ] = 2.f * frnd( ) - 1.f;
	vbTemp[ VB_LINE_OFFSET_Z ] = 2.f * frnd( ) - 1.f;
	vbTemp[ VB_LINE_OFFSET_T ] = 2.f * frnd( ) - 1.f;
	vbTemp[ VB_COLOUR ] = frnd( );

	for ( i = 0 ; i < vertices ; i ++ ) {
		vbTemp[ VB_POINT_OFFSET_X ] = frnd( ) * .1f - .05f;
		vbTemp[ VB_POINT_OFFSET_Y ] = frnd( ) * .1f - .05f;
		vbTemp[ VB_POINT_OFFSET_Z ] = frnd( ) * .1f - .05f;
		vbTemp[ VB_INDEX ] = (float)i;
		putVertex( );
	}
}


INLINE void generateSeeds( )
{
 	int i , vertices , offset;
 	for ( offset = i = 0 ; i < FX_LINES ; i ++ ) {
 		vertices = rnd( FX_MAX_LEN - FX_MIN_LEN ) + FX_MIN_LEN;
 		lines[ i ].offset = offset;
 		offset += ( lines[ i ].count = vertices );
 		generateLine( vertices );
 	}
}


INLINE void initBuffers( )
{
	int i;

	glGenBuffers( 4 , VBO_INIT );
	glGenTransformFeedbacks( 3 , TFO_INIT );
	for (i = 1; i < 4 ; i++) {
		glBindTransformFeedback( GL_TRANSFORM_FEEDBACK ,
			TFO( i - 1 ) );
		glBindBuffer( GL_ARRAY_BUFFER , VBO( i - 1 ) );
		glBufferData( GL_ARRAY_BUFFER , vbIndex * 64 * sizeof(float) ,
			NULL , GL_STREAM_COPY );
		glBindBufferBase( GL_TRANSFORM_FEEDBACK_BUFFER , 0 ,
			TFO( i - 1 ) );
	} 

	glBindBuffer( GL_ARRAY_BUFFER , VBO( 3 ) );
	glBufferData( GL_ARRAY_BUFFER , vbIndex * sizeof(float) , vertices ,
			GL_STATIC_DRAW );
	vbIndex /= RDR_FLOATS;
}


INLINE void createShaders( )
{
	int i,j,l;

	sources[0] = shaderParts[ SCP_HEADER ];
	for ( i = 0 ; i < N_SHADERS ; i ++ ) {
		SET_SHADER( i , glCreateShader( shaderDefs[i].type ) );
		l = shaderDefs[i].len;
		for ( j = 0 ; j < l ; j ++ ) {
			sources[j+1] = shaderParts[ shaderDefs[i].parts[j] ];
		}
		glShaderSource( SHADER(i) , l+1 , sources , NULL );
		glCompileShader( SHADER(i) );
	}
}


INLINE void makeSeedPrograms( )
{
#ifdef ERROR_CHECK
	char shd_log[ LOG_SIZE ];
	int log_size;
#endif
	int i;

	for ( i = 0 ; i < 5 ; i ++ ) {
		CREATE_PROGRAM( PRG_SEED(i) );
		CREATE_PROGRAM( PRG_LINES(i) );
		glAttachShader( PRG_SEED(i) , SHADER(i) );
		glAttachShader( PRG_LINES(i) , SHADER(i+9) );
		glAttachShader( PRG_LINES(i) , SHADER(14) );
		glTransformFeedbackVaryings( PRG_SEED(i) , 3 , varyings ,
				GL_INTERLEAVED_ATTRIBS ); 
		glLinkProgram( PRG_SEED(i) );
		glLinkProgram( PRG_LINES(i) );

#ifdef ERROR_CHECK
		glGetProgramInfoLog( PRG_SEED(i) , LOG_SIZE - 1 ,
				&log_size , shd_log );
		if ( log_size ) {
			printf( "Program info log (seed %d):\n%s\n\n" , i ,
					shd_log );
			exit(1);
		}

		glGetProgramInfoLog( PRG_LINES(i) , LOG_SIZE - 1 ,
				&log_size , shd_log );
		if ( log_size ) {
			printf( "Program info log (line %d):\n%s\n\n" , i ,
					shd_log );
			exit(1);
		}
#endif
	}

}


INLINE void makeRenderProgram( )
{
#ifdef ERROR_CHECK
	char shd_log[ LOG_SIZE ];
	int log_size;
#endif

	CREATE_PROGRAM( PRG_RENDER );
	glAttachShader( PRG_RENDER , SHADER(6) );
	glAttachShader( PRG_RENDER , SHADER(8) );
	glLinkProgram( PRG_RENDER );

#ifdef ERROR_CHECK
	glGetProgramInfoLog( PRG_RENDER , LOG_SIZE - 1 , &log_size , shd_log );
	if ( log_size ) {
		printf( "Program info log (render):\n%s\n\n" , shd_log );
		exit(1);
	}
#endif
}


INLINE void makeCopyProgram( )
{
#ifdef ERROR_CHECK
	char shd_log[ LOG_SIZE ];
	int log_size;
#endif

	CREATE_PROGRAM( PRG_COPY );
	glAttachShader( PRG_COPY , SHADER(5) );
	glTransformFeedbackVaryings( PRG_COPY , 3 , varyings , GL_INTERLEAVED_ATTRIBS ); 
	glLinkProgram( PRG_COPY );

#ifdef ERROR_CHECK
	glGetProgramInfoLog( PRG_COPY , LOG_SIZE - 1 , &log_size , shd_log );
	if ( log_size ) {
		printf( "Program info log (copy):\n%s\n\n" , shd_log );
		exit(1);
	}
#endif
}


INLINE void makeFlameProgram( )
{
#ifdef ERROR_CHECK
	char shd_log[ LOG_SIZE ];
	int log_size;
#endif

	CREATE_PROGRAM( PRG_FLAME );
	glAttachShader( PRG_FLAME , SHADER(5) );
	glAttachShader( PRG_FLAME , SHADER(7) );
	glTransformFeedbackVaryings( PRG_FLAME , 3 , gVaryings , GL_INTERLEAVED_ATTRIBS ); 
	glLinkProgram( PRG_FLAME );

#ifdef ERROR_CHECK
	glGetProgramInfoLog( PRG_FLAME , LOG_SIZE - 1 , &log_size , shd_log );
	if ( log_size ) {
		printf( "Program info log (flame):\n%s\n\n" , shd_log );
		exit(1);
	}
#endif
}


INLINE void initGraphics( )
{
	vbIndex = 0;
	generateSeeds( );
	initBuffers( );

	glEnable( GL_POINT_SPRITE_ARB );
	glEnable( GL_PROGRAM_POINT_SIZE );
	glEnable( GL_BLEND );

	createShaders( );
	makeSeedPrograms( );
	makeRenderProgram( );
	makeCopyProgram( );
	makeFlameProgram( );
}


void selectLayout( int program , unsigned char const* sizes )
{
	int i, offset;
	for (i = offset = 0 ; i < 3 ; i++ ) {
		int a;
		attrName[1] = i + 48;
		a = glGetAttribLocation( program , attrName );
		glEnableVertexAttribArray( a );
		glVertexAttribPointer(
				a , sizes[i] , GL_FLOAT , GL_FALSE ,
				sizeof( float ) * RDR_FLOATS ,
				(void*)(sizeof( float ) * offset ) );
		offset += sizes[i];
	}
}


INLINE void seedParticles( )
{
	glBindBuffer( GL_ARRAY_BUFFER , VBO( 3 ) );
	glUseProgram( PRG_SEED(curSeed) );
	selectLayout( PRG_SEED(curSeed) , seedAttribSizes );
	glUniform1fv( glGetUniformLocation( PRG_SEED(curSeed) , "a" ) ,
		11 , uniforms );
	glBindTransformFeedback( GL_TRANSFORM_FEEDBACK , TFO( 0 ) );
	glBeginTransformFeedback( GL_POINTS );
	glDrawArrays( GL_POINTS , 0 , vbIndex );
	glEndTransformFeedback( );
}


INLINE void updateFlames( )
{
	glBindBuffer( GL_ARRAY_BUFFER , VBO( 2 ) );
	glUseProgram( PRG_FLAME );
	selectLayout( PRG_FLAME , renderAttribSizes );
	glUniform1fv( glGetUniformLocation( PRG_FLAME , "a" ) ,
		11 , uniforms );
	glBindTransformFeedback( GL_TRANSFORM_FEEDBACK , TFO( 1 ) );
	glBeginTransformFeedback( GL_POINTS );
	glDrawTransformFeedback( GL_POINTS , TFO( 2 ) );
	glEndTransformFeedback( );
}


INLINE void copyParticles( )
{
	glBindBuffer( GL_ARRAY_BUFFER , VBO( 0 ) );
	glUseProgram( PRG_COPY );
	selectLayout( PRG_COPY , renderAttribSizes );
	glBindTransformFeedback( GL_TRANSFORM_FEEDBACK , TFO( 2 ) );
	glBeginTransformFeedback( GL_POINTS );
	glDrawTransformFeedback( GL_POINTS , TFO( 0 ) );
	glBindBuffer( GL_ARRAY_BUFFER , VBO( 1 ) );
	selectLayout( PRG_COPY , renderAttribSizes );
	glDrawTransformFeedback( GL_POINTS , TFO( 1 ) );
	glEndTransformFeedback( );
}


INLINE void drawParticles( )
{
	glClear( GL_COLOR_BUFFER_BIT );
	glBindBuffer( GL_ARRAY_BUFFER , VBO( 2 ) );
	glUseProgram( PRG_RENDER );
	selectLayout( PRG_RENDER , renderAttribSizes );
	glUniform1fv( glGetUniformLocation( PRG_RENDER , "a" ) ,
		11 , uniforms );
	glDrawTransformFeedback( GL_POINTS , TFO( 2 ) );
}


INLINE void drawLines( )
{
	int i;
 	glBindBuffer( GL_ARRAY_BUFFER , VBO( 3 ) );
	glUseProgram( PRG_LINES(curSeed) );
	selectLayout( PRG_LINES(curSeed) , seedAttribSizes );
	glUniform1fv( glGetUniformLocation( PRG_LINES(curSeed) , "a" ) ,
		11 , uniforms );
	for ( i = 0; i < FX_LINES ; i ++ ) {
 		glDrawArrays( GL_LINE_STRIP , lines[i].offset ,
 				lines[i].count );
 	}
}


INLINE void display( )
{
	if ( musicPos < 32 ) {
		lcPos = 64;
	} else if ( musicPos < 580 && musicPos > lcPos ) {
		if ( lcPos % 128 ) {
			transitionStart = timeOffset;
		} else {
			curSeed ++;
			transitionStart = 0x4000000;
		}
		lcPos += 64;
	}

	uniforms[8] = ( musicPos - 528.f ) / 160.f;
	uniforms[9] = musicPos * .0675f / 64.f;
	if ( musicPos < 288 ) {
		uniforms[9] = .15f - uniforms[9];
	} else if ( musicPos < 416 ) {
		uniforms[9] = uniforms[9] - .28875f;
	} else {
		uniforms[9] = .58875f - uniforms[9]; 
	}

	uniforms[6] = timeOffset / 1000.f;
	uniforms[7] = ( timeOffset - transitionStart ) / 3310.f;
	uniforms[10] = S_WIDTH/(float)S_HEIGHT;

	glEnable( GL_RASTERIZER_DISCARD );
	seedParticles( );
	updateFlames( );
	copyParticles( );
	glDisable( GL_RASTERIZER_DISCARD );

	glBlendFunc( GL_SRC_ALPHA , GL_ONE );
	drawParticles( );
	glBlendFunc( GL_SRC_ALPHA , GL_ONE_MINUS_SRC_ALPHA );
	drawLines( );
}


#ifdef __linux__

int main( int argc , char ** argv )
{
	SDL_SetVideoMode( S_WIDTH , S_HEIGHT , 0 , S_FLAGS );

#ifdef HAS_MUSIC
	Clinkster_GenerateMusic();
	SDL_AudioSpec fmt;
	fmt.freq = 44100;
	fmt.format = AUDIO_S16;
	fmt.channels = 2;
	fmt.samples = 512;
	fmt.callback = SDLSoundOut;
	fmt.userdata = NULL;
	SDL_OpenAudio(&fmt, NULL);
#endif
	initGraphics( );
	SDL_ShowCursor( 0 );

	timeCurrent = SDL_GetTicks( ) , timeOffset = 0;
#ifdef FPS_COUNTER
	int fps_index = 0 , fps_accum = 0;
	int fps_counter[ COUNTER_FRAMES ];
	int n_frames = 1;
	memset( fps_counter , 0 , sizeof( fps_counter ) );
#endif

#ifdef HAS_MUSIC
	SDL_PauseAudio( 0 );
#endif
	SDL_Event event;
	do {
		int d = SDL_GetTicks( ) - timeCurrent;

#ifdef HAS_MUSIC
		musicPos = Clinkster_GetPosition();
#else
		musicPos = timeOffset * .0096666f;
#endif
		if ( timeOffset > 75000 ) {
			break;
		}

		timeCurrent += d;
		timeOffset += d;

#ifdef FPS_COUNTER
		fps_accum -= fps_counter[ fps_index ];
		fps_accum += ( fps_counter[ fps_index ] = d );
		fps_index = ( fps_index + 1 ) % COUNTER_FRAMES;

		char buffer[25];
		sprintf( buffer , "FPS: %f\r" ,
				1000. / ( fps_accum / (float)n_frames ) );
		write( 1 , buffer , strlen( buffer ) );
		if ( n_frames < COUNTER_FRAMES ) {
			n_frames ++;
		}
#endif

		int i;
		for ( i = 0 ; i < 6 && musicPos <= Clinkster_MusicLength ;
				i ++ ) {
#ifdef HAS_MUSIC
			float t;
			t = ( 8.f - Clinkster_GetInstrumentTrigger( i ,
						musicPos ) )
				* .125f;
			if ( t > 0 ) {
				uniforms[i] = t;
			}
#else
			uniforms[i] = 0;
#endif
		}

		display( );

		SDL_GL_SwapBuffers();
		SDL_PollEvent( &event );
	} while ( event.type != SDL_KEYUP || event.key.keysym.sym != 27 );

	SDL_Quit( );
	return 0;
}

#else

static DEVMODE fullscreen =
{
	// dmDeviceName (PIXELFORMATDESCRIPTOR)		[32 bytes]
	{
		0, 0,			// nSize	[2 bytes]
		0, 0,			// nVersion	[2 bytes]

		/*
			* PFD_DRAW_TO_WINDOW			[[ 0x04 ]]
			* PFD_SUPPORT_OPENGL			[[ 0x20 ]]
			* PFD_DOUBLEBUFFER			[[ 0x01 ]]
			*
			* [[ 0x00000025 ]] { 37, 0, 0, 0 } 	[le]
			*/

		37, 0, 0, 0,	// dwFlags		[4 bytes]

		PFD_TYPE_RGBA,	// iPixelType		[1 byte]

		0,		// cColorBits		[1 byte]
		0,		// cRedBits		[1 byte]
		0,		// cRedShift		[1 byte]
		0,		// cGreenBits		[1 byte]
		0,		// cGreenShift		[1 byte]
		0,		// cBlueBits		[1 byte]
		0,		// cBlueShift		[1 byte]
		0,		// cAlphaBits		[1 byte]
		0,		// cAlphaShift		[1 byte]
		0,		// cAccumBits		[1 byte]
		0,		// cAccumRedBits	[1 byte]
		0,		// cAccumGreenBits	[1 byte]
		0,		// cAccumBlueBits	[1 byte]
		0,		// cAccumAlphaBits	[1 byte]
		0,		// cDepthBits		[1 byte]
		0,		// cStencilBits		[1 byte]
		0,		// cAuxBuffers		[1 byte]
		0,		// iLayerType		[1 byte]
		0,		// bReserved		[1 byte]

		0, 0, 0, 0	// dwLayerMask		[4 bytes]
	},

	0,			// dmSpecVersion	[2 bytes]
	0,			// dmDriverVersion	[2 bytes]

	sizeof(DEVMODE),	// dmSize		[2 bytes]

	0,			// dmDriverExtra	[2 bytes]

	DM_PELSWIDTH |		// [ >> ]
	DM_PELSHEIGHT,		// dmFields		[4 bytes]

	{
		{
			0,	// dmOrientation	[2 bytes]
			0,	// dmPaperSize		[2 bytes]
			0,	// dmPaperLength	[2 bytes]
			0,	// dmPaperWidth		[2 bytes]
			0,	// dmScale		[2 bytes]
			0,	// dmCopies		[2 bytes]
			0,	// dmDefaultSource	[2 bytes]
			0,	// dmPrintQuality	[2 bytes]
		}
	},

	0,			// dmColor		[2 bytes]
	0,			// dmDuplex		[2 bytes]
	0,			// dmYResolution	[2 bytes]
	0,			// dmTTOption		[2 bytes]
	0,			// dmCollate		[2 bytes]

	{
		0		// dmFormName		[32 bytes]
	},

	0,			// dmLogPixels		[2 bytes]
	0,			// dmBitsPerPel		[4 bytes]
	S_WIDTH,		// dmPelsWidth		[4 bytes]
	S_HEIGHT,		// dmPelsHeight		[4 bytes]

	{
		0		// dmDisplayFlags	[4 bytes]
	},

	0,			// dmDisplayFrequency	[4 bytes]

	#if(WINVER >= 0x0400)
		0,		// dmICMMethod		[4 bytes]
		0,		// dmICMIntent		[4 bytes]
		0,		// dmMediaType		[4 bytes]
		0,		// dmDitherType		[4 bytes]
		0,		// dmReserved1		[4 bytes]
		0,		// dmReserved2		[4 bytes]

		#if((WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400))
			0,	// dmPanningWidth	[4 bytes]
			0,	// dmPanningHeight	[4 bytes]
		#endif // (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
	#endif // WINVER >= 0x0400
};


static void *const pPointer = &fullscreen;


int WinMainCRTStartup()
{
	HDC hContext;
#ifdef FPS_COUNTER
	int fps_index = 0 , fps_accum = 0;
	int fps_counter[ COUNTER_FRAMES ];
	int n_frames = 1;
	memset( fps_counter , 0 , sizeof( fps_counter ) );
#endif

	ChangeDisplaySettings( pPointer , CDS_FULLSCREEN );
	hContext = GetDC( CreateWindow( "edit" , NULL ,
		WS_POPUP | WS_VISIBLE | WS_MAXIMIZE ,
		0 , 0 , 0 , 0 , 
		NULL , NULL , NULL , NULL ) );
	SetPixelFormat( hContext ,
		ChoosePixelFormat( hContext , pPointer ),
		pPointer );
	wglMakeCurrent( hContext , wglCreateContext( hContext ) );

	initGraphics( );
#ifdef HAS_MUSIC
	Clinkster_GenerateMusic();
#endif
	ShowCursor( 0 );
	timeCurrent = timeGetTime();
#ifdef HAS_MUSIC
	Clinkster_StartMusic();
#endif

	do {
		int d = timeGetTime( ) - timeCurrent;
		int i;

#ifdef HAS_MUSIC
		musicPos = Clinkster_GetPosition();
#else
		musicPos = timeOffset * .0096666f;
#endif
		if ( timeOffset > 75000 ) {
			break;
		}

#ifdef FPS_COUNTER
		fps_accum -= fps_counter[ fps_index ];
		fps_accum += ( fps_counter[ fps_index ] = d );
		fps_index = ( fps_index + 1 ) % COUNTER_FRAMES;

		printf( "FPS: %f / pos: %f    \r" ,
				1000.f / ( fps_accum / (float)n_frames ) ,
				musicPos );
		fflush(stdout);
		if ( n_frames < COUNTER_FRAMES ) {
			n_frames ++;
		}
#endif

		timeCurrent += d;
		timeOffset += d;

		for ( i = 0 ; i < 6 && musicPos <= Clinkster_MusicLength ; i ++ ) {
#ifdef HAS_MUSIC
			float t;
			t = ( 8.f - Clinkster_GetInstrumentTrigger( i , musicPos ) )
				* .125f;
			if ( t > 0 ) {
				uniforms[i] = t;
			}
#else
			uniforms[i] = 0;
#endif
		}

		display( );
		SwapBuffers( hContext );
	} while ( !GetAsyncKeyState( VK_ESCAPE ) );
	ExitProcess(0);
	return 0;
}

#endif
