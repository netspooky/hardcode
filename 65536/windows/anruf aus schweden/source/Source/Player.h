
#ifndef __PLAYER_H__
#define __PLAYER_H__

#include "OGLRenderer.h"
#include "Script.h"
#include "ModPlayer.h"

class Player {
	public:
		Player( OGLRenderer* renderer );
		~Player();

		void						init();

		void						addScene( unsigned char* buffer, View const& view );
		void						addOverlay( unsigned char* d, int width, int height );
		void						addEvent( Event const& event );

		void						setActiveScene( int num );
		void						setActiveCamera( int num );
		void						setActiveShader( int vertex, int pixel );
	
		void						runScript( float time );
		bool						isRunning();

		Scene*						getActiveScene();


	private:
		void						sceneUndAusfade( float time );
		void						halloUndGutenAbendText( float time );
		void						bauAufDasZimmer( float time );
		void						gruessenErstesMal( float time );
		void						gruessenZweitesMal( float time );
		void						gruessenDrittesMal( float time );
		void						gruessenViertesMal( float time );
		void						zeigBeide( float time );
		void						werHatsVerzapft( float time );
		void						spassIstWoManIhnMacht( float time );
		void						schlussAusEnde( float time );

		OGLRenderer*				activeRenderer;
		Scene*						activeScene;
		Event*						activeEvent;

		std::vector<Scene>			scenes;
		std::vector<Event>			events;
		std::vector<int>			overlays;
		std::vector<int>			selection;

		bool						running;

		float						inEffectTime;
		int							inEffectCounter;

		ModPlayer					modPlayer;

		static int const			GRAY_DELAY;
};

#endif