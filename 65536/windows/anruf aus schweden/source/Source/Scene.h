
#ifndef __SCENE_H_
#define __SCENE_H_

#include "Mesh.h"
#include "Camera.h"
#include "Light.h"
#include "View.h"
#include "Animation.h"
#include "BufferObject.h"

class Scene {
	public:
		Scene();
		~Scene();

		void					deleteBuffer();

		void					addMesh( Mesh const& mesh );
		void					addCamera( Camera const& camera );
		void					addLight( Light const& light );
		void					addView( View const& view );

		void					setActiveCamera( int _activeCamera );
		void					setActiveView( int _activeView );

		meshList const&			getMeshes() const;
		lightList const&		getLights() const;
		Camera const&			getActiveCamera() const;
		View const&				getActiveView() const;

		Light*					getLightByPtr( int num );
		Camera*					getCameraByPtr( int num );

		void					createBuffers();
		void					bindVertexBuffer();
		void					bindIndexBuffer();

		std::vector<int>		getIndicesDistanceDependent( Vector const& center );

		Animation				animation;

	private:
		meshList				meshes;
		cameraList				cameras;
		lightList				lights;
		viewList				views;

		int						activeCamera;
		int						activeView;

		BufferObject			vertexBuffer;
		BufferObject			indexBuffer;
};

typedef std::vector<Scene>	sceneList;

#endif