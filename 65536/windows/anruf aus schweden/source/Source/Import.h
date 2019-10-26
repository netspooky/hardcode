
#ifndef __IMPORT_H__
#define __IMPORT_H__

#include "StreamRead.h"
#include "Scene.h"

class Import {
	public:
		Import( unsigned char* buffer, Scene* _scene );
		~Import();

	private:
		void			loadHeader();
		void			loadMeshes();
		void			loadPlaneObj( Mesh* mesh );
		void			loadBoxObj( Mesh* mesh );
		void			loadSphereObj( Mesh* mesh );
		void			loadCylinderObj( Mesh* mesh );
		void			loadConeObj( Mesh* mesh );
		void			loadTubeObj( Mesh* mesh );
		void			loadCameras();
		void			loadLights();
		void			loadMaterials();
		void			loadScene();

		materialList	tempMaterials;

		Scene*			scene;
		StreamRead		sr;
};

#endif