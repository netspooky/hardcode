
/*

		ikea intro // evoke2oo4
		(c)ode markus gnauck
		markus@unik.de / www.unik.de

		nothing fancy about that code.. anyways i'm not responsible if this fucks up your machine!
		use at your own risk! if you have any comments or questions do not hesitate to contact me.. 

*/

#include "Window.h"
#include "OGLRenderer.h"
#include "Extensions.h"
#include "Player.h"

// scenen
#include "../data/start.h"
#include "../data/wozi.h"
#include "../data/eisenb.h"
#include "../data/kizi.h"
#include "../data/park.h"

// shader
#include "../data/ps1.h"		// normal phong
#include "../data/ps2.h"		// gray
#include "../data/ps3.h"		// contrast
#include "../data/vs1.h"		// normal
#include "../data/vs2.h"		// spherical

// overlays
#include "../data/ovl1.h"		// anruf aus schweden
#include "../data/ovl2.h"		// uniklogo
#include "../data/ovl3.h"		// greetings1
#include "../data/ovl4.h"		// greetings2
#include "../data/ovl5.h"		// greetings3
#include "../data/ovl6.h"		// greetings4


int APIENTRY WinMain( HINSTANCE hi, HINSTANCE pi, LPSTR cmd, int show ) {

	Window			win( 1024, 768, 32, true );
	OGLRenderer		renderer( win );

	if( !loadExtensions() )
		return 0;

	int		height	= ( win.getWidth() * 9 / 16 );
	View	view( 0, win.getWidth(), ( win.getHeight() - height ) / 2, ( ( win.getHeight() - height ) / 2 ) + height );

	renderer.addVertexShader( vs1, sizeof( vs1 ) );
	renderer.addVertexShader( vs2, sizeof( vs2 ) );
	
	renderer.addPixelShader( ps1, sizeof( ps1 ) );
	renderer.addPixelShader( ps2, sizeof( ps2 ) );
	renderer.addPixelShader( ps3, sizeof( ps3 ) );

	renderer.setGLParameters( Vector( 1.0f, 1.0f, 1.0f ) );
	renderer.clearColorAndDepthBuffer( view );
	//renderer.flush();

	Player	player( &renderer );

	player.addScene( const_cast<unsigned char*>( &start[ 0 ] ), view );
	player.addScene( const_cast<unsigned char*>( &wozi[ 0 ] ), view );
	player.addScene( const_cast<unsigned char*>( &kizi[ 0 ] ), view );
	player.addScene( const_cast<unsigned char*>( &park[ 0 ] ), view );
	player.addScene( const_cast<unsigned char*>( &eisenb[ 0 ] ), view );

	player.addOverlay( const_cast<unsigned char*>( &ovl1[ 0 ] ), 256, 256 );
	player.addOverlay( const_cast<unsigned char*>( &ovl2[ 0 ] ), 256, 256 );
	player.addOverlay( const_cast<unsigned char*>( &ovl3[ 0 ] ), 64, 256 );
	player.addOverlay( const_cast<unsigned char*>( &ovl4[ 0 ] ), 64, 256 );
	player.addOverlay( const_cast<unsigned char*>( &ovl5[ 0 ] ), 64, 256 );
	player.addOverlay( const_cast<unsigned char*>( &ovl6[ 0 ] ), 64, 256 );

	player.setActiveScene( 2 );
	player.getActiveScene()->addView( View( view.left, view.left + ( view.right - view.left ) / 2 - 3, view.bottom, view.top ) );

	player.setActiveScene( 3 );
	player.getActiveScene()->addView( View( view.right - ( view.right - view.left ) / 2 + 3, view.right, view.bottom, view.top ) );

	player.init();

	DWORD	startTime	= timeGetTime();
	while( win.isActive() && player.isRunning() ) {

		player.runScript( static_cast<float>( timeGetTime() - startTime ) );
		assert( glGetError() == GL_NO_ERROR );
	}

	return 0;
}