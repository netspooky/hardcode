
#ifndef __OGL_RENDERER_H__
#define __OGL_RENDERER_H__

#include "Window.h"
#include <gl/gl.h>
#include "Scene.h"
#include "Shader.h"

class OGLRenderer {
	public:
		OGLRenderer( Window const& _window );
		~OGLRenderer();

		void				setGLParameters( Vector const& col );
		void				flush();
		bool				addVertexShader( unsigned char const* shaderString, int length );
		bool				addPixelShader( unsigned char const* shaderString, int length );

		void				clearColorAndDepthBuffer( View const& v );

		void				setView( View const& view );
		void				setCameraProjection( Camera const& cam, float time );
		void				setMaterial( Material const& material );
		void				setLight( Light const& light, float time );
		void				renderMesh( Mesh const& mesh, float time );

		void				setVertexShader( int num );
		void				setPixelShader( int num );

		void				renderScene( Scene* scene, float time );
		void				renderSelection( Scene* scene, float time, std::vector<int> const& selection );
		void				renderScreenQuad( Scene* scene, Vector const& col, Vector const& scale, Vector const& trans );

	private:
		bool				initRenderContext();
		void				setupBuffers( Scene* scene );
		void				bindShader();

		Window const&		window;
		HGLRC				hrc;

		ShaderList			vertexShaders;
		ShaderList			pixelShaders;
		int					vertexShader;
		int					pixelShader;
};

#endif