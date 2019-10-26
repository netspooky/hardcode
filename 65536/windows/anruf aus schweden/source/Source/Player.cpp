
#include "Player.h"
#include "Import.h"
#include "View.h"
#include "Script.h"

int const	Player::GRAY_DELAY	= 35;

Player::Player( OGLRenderer* renderer ): activeRenderer( renderer ), activeScene( 0 ), activeEvent( 0 ), running( true ), modPlayer() {

	inEffectCounter = 0;
	inEffectTime	= 0.0f;
}

Player::~Player() {

	for( std::vector<Scene>::iterator it = scenes.begin(); it != scenes.end(); ++it )
		it->deleteBuffer();

	glDeleteTextures( static_cast<GLsizei>( overlays.size() ), reinterpret_cast<GLuint*>( &overlays[ 0 ] ) );

	scenes.clear();
	events.clear();
	overlays.clear();
	selection.clear();
}

void Player::init() {

	// init some stuff

	for( int i=0; i<sizeof( script ) / sizeof( Event ); i++ )
		addEvent( script[ i ] );

	selection = scenes[ 1 ].getIndicesDistanceDependent( Vector( -630.0f, -12.0f, 0.0f ) );

	modPlayer.play();
}

void Player::addScene( unsigned char* buffer, View const& view ) {

	Scene	temp;
	Import( buffer, &temp );

	temp.addView( view );
	temp.setActiveView( 0 );
	temp.setActiveCamera( 0 );

	scenes.push_back( temp );
}

void Player::addOverlay( unsigned char* d, int width, int height ) {

	std::vector<unsigned char>		bitwise;

	for( int i=0; i<width * height / 8; i++ )
		bitwise.push_back( d[ i ] );

	// 'decode' texture
	char						bitcnt	= 0;
	std::vector<unsigned char>	data( width * height * 3, 0 );

	for( int j=0; j<width * height; j++ ) {
		
		if( ( ( bitwise[ j / 8 ] >> bitcnt ) & 1 ) ) {

			data[ 3 * j + 0 ] = 0;
			data[ 3 * j + 1 ] = 0;
			data[ 3 * j + 2 ] = 0;

		} else {

			data[ 3 * j + 0 ] = 255;
			data[ 3 * j + 1 ] = 255;
			data[ 3 * j + 2 ] = 255;
		}

		bitcnt = ( bitcnt + 1 ) % 8;
	}

	bitwise.clear();


	// upload texture
	unsigned int	textureID;

	glGenTextures( 1, &textureID );
	glBindTexture( GL_TEXTURE_2D, textureID );
	glTexImage2D( GL_TEXTURE_2D, 0, 3, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, &data[ 0 ] );
	
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );

	overlays.push_back( textureID );
	data.clear();
}

void Player::addEvent( Event const& event ) {
	events.push_back( event );
}

void Player::setActiveScene( int num ) {
	activeScene = &scenes[ num ];
}

void Player::setActiveCamera( int num ) {
	activeScene->setActiveCamera( num );
}

void Player::setActiveShader( int vertex, int pixel ) {
	activeRenderer->setVertexShader( vertex );
	activeRenderer->setPixelShader( pixel );
}

void Player::runScript( float time ) {

	activeEvent = 0;

	for( int i=0; i<static_cast<int>( events.size() ); i++ ) {

		if( ( time >= static_cast<float>( events[ i ].startTime ) ) && ( time < static_cast<float>( events[ i ].endTime ) ) ) {
			activeEvent = &events[ i ];
			break;
		}
	}

	if( activeEvent == 0 )
		return;

	float	effectTime = static_cast<float>( activeEvent->timeOffset ) + ( time - static_cast<float>( activeEvent->startTime ) ) * activeEvent->speed;

	setActiveScene( activeEvent->sceneNum );
	setActiveCamera( activeEvent->cameraNum );
	activeScene->setActiveView( 0 );

	if( activeEvent->special == -1 ) {

		activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
		setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
		activeRenderer->renderScene( activeScene, effectTime );

	} else {

		// bisschen low so aber kein bock jetzt..
		switch( activeEvent->special ) {

			case 0: 
				sceneUndAusfade( effectTime );
				break;

			case 1:
				halloUndGutenAbendText( effectTime );
				break;

			case 2:
				bauAufDasZimmer( effectTime );
				break;

			case 3:
				gruessenErstesMal( effectTime );
				break;

			case 4:
				gruessenZweitesMal( effectTime );
				break;

			case 5:
				gruessenDrittesMal( effectTime );
				break;

			case 6:
				gruessenViertesMal( effectTime );
				break;

			case 7:
				zeigBeide( effectTime );
				break;

			case 8:
				werHatsVerzapft( effectTime );
				break;

			case 9:
				spassIstWoManIhnMacht( effectTime );
				break;

			case 10:
				schlussAusEnde( effectTime );
				break;
		};		
	}
	
	activeRenderer->flush();
}

bool Player::isRunning() {
	return running;
}

Scene* Player::getActiveScene() {
	return activeScene;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void Player::sceneUndAusfade( float time ) {

	float		fadeVal = 1.0f;

	if( time > 163.0f ) {
		fadeVal = 1.0f - ( time - 163.0f ) * 0.24f;
	}

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );

	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE, GL_SRC_ALPHA );

	activeRenderer->renderScreenQuad( activeScene, Vector( 0.0f, 0.0f, 0.0f, fadeVal ), Vector( 1.0f, 1.0f, 1.0f ), Vector( 0.0f, 0.0f, 0.0f ) );

	glDisable( GL_BLEND );
}

void Player::halloUndGutenAbendText( float time ) {

	glClearColor( 0.0, 0.0, 0.0, 1.0 );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
	glClearColor( 1.0, 1.0, 1.0, 1.0 );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 0 ] );

	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f, 1.0f ), Vector( 0.8f, 1.45f, 0.8f ), Vector( 0.0f + time * 0.002f, 0.0f, 0.0f ) );

	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE, GL_SRC_ALPHA );

	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f, 0.1f ), Vector( 1.3f, 1.85f, 1.3f ), Vector( 0.0f + time * 0.007f, 0.0f, 0.0f ) );

	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
}

void Player::bauAufDasZimmer( float time ) {

	static bool second	= false;
	int const	selSize	= static_cast<int>( selection.size() - 1 );

	if( ( activeEvent->startTime == 25240 ) && !second ) {

		second = true;
		inEffectTime = 0.0f;
	}

	if( ( time - inEffectTime ) > 0.262f ) {

		if( inEffectCounter < selSize )
			inEffectCounter = ( inEffectCounter + 1 );

		inEffectTime = time;
	}

	int	delay = ( inEffectCounter > GRAY_DELAY ) ? GRAY_DELAY : inEffectCounter;
	delay = ( ( inEffectCounter + GRAY_DELAY ) > selSize ) ? ( selSize - inEffectCounter ) : delay;

	std::vector<int>	sel1( selection.begin(), selection.begin() + inEffectCounter - delay );
	
	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );

	activeRenderer->setVertexShader( 1 );
	activeRenderer->setPixelShader( 0 );
	activeRenderer->renderSelection( activeScene, time, sel1 );

	sel1.clear();

	if( inEffectCounter < selSize ) {

		std::vector<int>	sel2( selection.begin() + inEffectCounter - delay, selection.begin() + inEffectCounter );

		activeRenderer->setPixelShader( 1 );
		activeRenderer->renderSelection( activeScene, time, sel2 );

		sel2.clear();
	}
}

void Player::gruessenErstesMal( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 2 ] );
	
	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR );

	activeRenderer->renderScreenQuad( activeScene, Vector( 0.3f, 0.4f, 0.4f, 1.0f ), Vector( -0.11f, -1.0f, 0.35f ), Vector( 0.75f, 0.0f, 0.0f ) );
	
	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
}

void Player::gruessenZweitesMal( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 3 ] );
	
	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR );

	activeRenderer->renderScreenQuad( activeScene, Vector( 0.4f, 0.3f, 0.3f, 1.0f ), Vector( 0.11f, 1.0f, 0.35f ), Vector( -0.75f, 0.0f, 0.0f ) );
	
	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
}

void Player::gruessenDrittesMal( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 4 ] );
	
	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR );

	activeRenderer->renderScreenQuad( activeScene, Vector( 0.3f, 0.4f, 0.3f, 1.0f ), Vector( -0.11f, -1.0f, 0.35f ), Vector( 0.75f, 0.0f, 0.0f ) );
	
	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
}

void Player::gruessenViertesMal( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 5 ] );
	
	glEnable( GL_BLEND );
	glBlendFunc( GL_ONE_MINUS_SRC_COLOR, GL_SRC_COLOR );

	activeRenderer->renderScreenQuad( activeScene, Vector( 0.4f, 0.4f, 0.3f, 1.0f ), Vector( 0.11f, 1.0f, 0.35f ), Vector( -0.75f, 0.0f, 0.0f ) );
	
	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
}

void Player::zeigBeide( float time ) {

	// clear
	glClearColor( 0.0, 0.0, 0.0, 1.0 );
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
	glClearColor( 1.0, 1.0, 1.0, 1.0 );

	// scene 1
	activeScene->setActiveView( 1 );
	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f ), Vector( 1.0f, 1.0f, 1.0f ), Vector( 0.0f, 0.0f, 0.0f ) );
	activeRenderer->setVertexShader( 0 );
	activeRenderer->setPixelShader( 0 );
	activeScene->getCameraByPtr( activeEvent->cameraNum )->setProjection( 8.0f / 9.0f, 0.1f, 5000.0f );
	activeRenderer->renderScene( activeScene, time );

	// scene 2
	setActiveScene( activeEvent->sceneNum + 1 );
	setActiveCamera( 0 );
	activeScene->setActiveView( 1 );
	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f ), Vector( 1.0f, 1.0f, 1.0f ), Vector( 0.0f, 0.0f, 0.0f ) );
	activeRenderer->setVertexShader( 0 );
	activeRenderer->setPixelShader( 0 );
	activeScene->getCameraByPtr( 0 )->setProjection( 8.0f / 9.0f, 0.1f, 5000.0f );
	activeRenderer->renderScene( activeScene, time );
}

void Player::werHatsVerzapft( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 1 ] );

	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f, 1.0f ), Vector( 0.35f, 0.6f, 0.35f ), Vector( 0.0f, 0.0f, 0.0f ) );

	glDisable( GL_TEXTURE_2D );
}

void Player::spassIstWoManIhnMacht( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );

	glEnable( GL_TEXTURE_2D );
	glBindTexture( GL_TEXTURE_2D, overlays[ 1 ] );

	activeRenderer->renderScreenQuad( activeScene, Vector( 1.0f, 1.0f, 1.0f, 1.0f ), Vector( 0.35f, 0.6f, 0.35f ), Vector( 0.0f, 0.0f, 0.0f ) );

	glDisable( GL_TEXTURE_2D );

	setActiveShader( activeEvent->vertexShader, activeEvent->pixelShader );
	activeRenderer->renderScene( activeScene, time );
}

void Player::schlussAusEnde( float time ) {

	activeRenderer->clearColorAndDepthBuffer( activeScene->getActiveView() );
	running = false;

	modPlayer.stop();
}