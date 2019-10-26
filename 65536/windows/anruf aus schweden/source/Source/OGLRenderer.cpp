
#include "OGLRenderer.h"
#include "Extensions.h"

OGLRenderer::OGLRenderer( Window const& _window ): window( _window ), hrc( 0 ), vertexShader( 0 ), pixelShader( 0 ) {

	initRenderContext();
}

OGLRenderer::~OGLRenderer() {

	for( ShaderList::iterator it=vertexShaders.begin(); it != vertexShaders.end(); ++it )
		it->deleteProgram();
	vertexShaders.clear();

	for( ShaderList::iterator it=pixelShaders.begin(); it != pixelShaders.end(); ++it )
		it->deleteProgram();
	pixelShaders.clear();

	if( hrc ) {
		wglMakeCurrent( 0, 0 );
		wglDeleteContext( hrc );
	}
}

bool OGLRenderer::initRenderContext() {

	static PIXELFORMATDESCRIPTOR pfd = {

				sizeof( PIXELFORMATDESCRIPTOR ),									// size
				1,																	// version
				PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,			// flags
				PFD_TYPE_RGBA,														// pixeltype
				window.getBPP(),													// colorbits
				0,																	// redbits
				0,																	// redshift
				0,																	// greenbits
				0,																	// greenshift
				0,																	// bluebits
				0,																	// blueshift
				0,																	// alphabits
				0,																	// alphashift
				0,																	// accumbits
				0,																	// accumredbits
				0,																	// accumgreenbits
				0,																	// accumbluebits
				0,																	// accumalphabits
				window.getBPP(),													// depthbits
				8,																	// stencilbits
				0,																	// auxbits
				PFD_MAIN_PLANE,														// layertype
				0,																	// reserved
				0,																	// layermask
				0,																	// visiblemask
				0																	// damagemask
	};

	int pixelFormat = ChoosePixelFormat( window.getHDC(), &pfd );
	if( !pixelFormat )
		return false;

	if( !SetPixelFormat( window.getHDC(), pixelFormat, &pfd ) )
		return false;

	hrc = wglCreateContext( window.getHDC() );
	if( !hrc )
		return false;

	if( !wglMakeCurrent( window.getHDC(), hrc ) )
		return false;

	return true;
}

void OGLRenderer::setGLParameters( Vector const& col ) {

	glPolygonMode( GL_FRONT, GL_FILL );

	glCullFace( GL_BACK );
	glEnable( GL_CULL_FACE );

	glDepthMask( true );
	glDepthFunc( GL_LEQUAL );
	glClearDepth( 255.0 );
	glEnable( GL_DEPTH_TEST );

	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
	
	glDisable( GL_NORMALIZE );
	glDisable( GL_BLEND );
	glDisable( GL_TEXTURE_2D );
	glDisable( GL_LIGHTING );
	glLightModeli( GL_LIGHT_MODEL_TWO_SIDE, false );

	glClearColor( col.x, col.y, col.z, 1.0 );
}

void OGLRenderer::flush() {
	glFinish();
	SwapBuffers( window.getHDC() );
}

bool OGLRenderer::addVertexShader( unsigned char const* shaderString, int length ) {

	Shader	shader( shaderString, length, VERTEX );
	if( shader.loadedSuccessfully() ) {
		vertexShaders.push_back( shader );
		return true;
	}

	return false;
}

bool OGLRenderer::addPixelShader( unsigned char const* shaderString, int length ) {

	Shader	shader( shaderString, length, PIXEL );
	if( shader.loadedSuccessfully() ) {
		pixelShaders.push_back( shader );
		return true;
	}

	return false;
}

void OGLRenderer::clearColorAndDepthBuffer( View const& v ) {

	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );	// stencil clear only for performance

	// to yield black movie bars..
	// stupid to do it that way but glScissor() bugs on some drivers
	
	glDisable( GL_TEXTURE_2D );
	glDisable( GL_BLEND );

	glViewport( 0, 0, window.getWidth(), v.bottom );
	renderScreenQuad( 0, Vector( 0.0f, 0.0f, 0.0f ), Vector( 1.0f, 1.0f, 1.0f ), Vector( 0.0f, 0.0f, 0.0f ) );

	glViewport( 0, v.top, window.getWidth(), window.getHeight() );
	renderScreenQuad( 0, Vector( 0.0f, 0.0f, 0.0f ), Vector( 1.0f, 1.0f, 1.0f ), Vector( 0.0f, 0.0f, 0.0f ) );
}

void OGLRenderer::setView( View const& view ) {

	glViewport( view.left, view.bottom, view.right - view.left, view.top - view.bottom );
}

void OGLRenderer::setCameraProjection( Camera const& cam, float time ) {

	glMatrixMode( GL_PROJECTION );
	glLoadMatrixf( reinterpret_cast<GLfloat const*>( cam.getProjectionMatrix().transposed().m ) );

	Matrix matrix( cam.getCameraMatrix( time ) );
	vertexShaders[ vertexShader ].specifyEnvParameters( 1, matrix.getCol( 3 ).v );

    glMatrixMode( GL_MODELVIEW );
	glLoadMatrixf( reinterpret_cast<GLfloat const*>( matrix.transposed().m ) );
}

void OGLRenderer::setMaterial( Material const& material ) {

	glMaterialfv( GL_FRONT, GL_AMBIENT, static_cast<GLfloat const*>( material.ambient.v ) );
	glMaterialfv( GL_FRONT, GL_EMISSION, static_cast<GLfloat const*>( material.emissive.v ) );

	glMaterialfv( GL_FRONT, GL_DIFFUSE, static_cast<GLfloat const*>( material.diffuse.v ) );
	glMaterialfv( GL_FRONT, GL_SPECULAR, static_cast<GLfloat const*>( material.specular.v ) );
	glMaterialf( GL_FRONT, GL_SHININESS, material.shininess );
}

void OGLRenderer::setLight( Light const& light, float time ) {

	Vector pos = light.getActualPosition( time );
	vertexShaders[ vertexShader ].specifyEnvParameters( 0, pos.v );

	glLightfv( GL_LIGHT0, GL_DIFFUSE, static_cast<GLfloat const*>( Vector( light.getColor() * light.getIntensity() ).v ) );
	glLightfv( GL_LIGHT0, GL_SPECULAR, static_cast<GLfloat const*>( Vector( 1.0f, 1.0f, 1.0f ).v ) );
}

void OGLRenderer::renderMesh( Mesh const& mesh, float time ) {

	glMatrixMode( GL_MODELVIEW );
	glPushMatrix();

	Matrix const& model = mesh.getActualMatrix( time );

	vertexShaders[ vertexShader ].specifyEnvParameters( 2, model.getRow( 0 ).v );
	vertexShaders[ vertexShader ].specifyEnvParameters( 3, model.getRow( 1 ).v );
	vertexShaders[ vertexShader ].specifyEnvParameters( 4, model.getRow( 2 ).v );
	vertexShaders[ vertexShader ].specifyEnvParameters( 5, model.getRow( 3 ).v );

	glMultMatrixf( reinterpret_cast<GLfloat const*>( model.transposed().m ) );

	//glDrawElements( GL_TRIANGLES, mesh.getTriangleCount() * 3, GL_UNSIGNED_INT, static_cast<char*>( 0 ) + mesh.getIndexOffset() );
	glDrawRangeElements( GL_TRIANGLES, mesh.getFirstIndex(), mesh.getLastIndex(), mesh.getTriangleCount() * 3, GL_UNSIGNED_INT, static_cast<char*>( 0 ) + mesh.getIndexOffset() );

	glPopMatrix();
}

void OGLRenderer::setupBuffers( Scene* scene ) {

	scene->bindIndexBuffer();
	scene->bindVertexBuffer();

	glEnableClientState( GL_NORMAL_ARRAY );
	glEnableClientState( GL_VERTEX_ARRAY );

	glNormalPointer( GL_FLOAT, 32, reinterpret_cast<char *>( 0 ) + 16 );
	glVertexPointer( 3, GL_FLOAT, 32, reinterpret_cast<char *>( 0 ) );
}

void OGLRenderer::setVertexShader( int num ) {
	vertexShader = num;
}

void OGLRenderer::setPixelShader( int num ) {
	pixelShader = num;
}

void OGLRenderer::bindShader() {

	glEnable( GL_VERTEX_PROGRAM_ARB );
	glEnable( GL_FRAGMENT_PROGRAM_ARB );

	vertexShaders[ vertexShader ].bindShader();
	pixelShaders[ pixelShader ].bindShader();
}

void OGLRenderer::renderScene( Scene* scene, float time ) {

	assert( scene );

	bindShader();
	setupBuffers( scene );

	setView( scene->getActiveView() );
	setCameraProjection( scene->getActiveCamera(), time );

	setLight( *scene->getLights().begin(), time );			// wir haben nur 1 licht :)

	for( meshList::const_iterator it = scene->getMeshes().begin(); it != scene->getMeshes().end(); ++it ) {

		setMaterial( it->getMaterial() );
		renderMesh( *it, time  );
	}

	glDisableClientState( GL_NORMAL_ARRAY );
	glDisableClientState( GL_VERTEX_ARRAY );

	glDisable( GL_FRAGMENT_PROGRAM_ARB );
	glDisable( GL_VERTEX_PROGRAM_ARB );
}

void OGLRenderer::renderSelection( Scene* scene, float time, std::vector<int> const& selection ) {

	assert( scene );

	bindShader();
	setupBuffers( scene );

	setView( scene->getActiveView() );
	setCameraProjection( scene->getActiveCamera(), time );

	setLight( *scene->getLights().begin(), time );			// wir haben nur 1 licht :)

	meshList const& meshes	= scene->getMeshes();
	for( std::vector<int>::const_iterator it = selection.begin(); it != selection.end(); ++it ) {

		setMaterial( meshes[ *it ].getMaterial() );
		renderMesh( meshes[ *it ], time  );
	}

	glDisableClientState( GL_NORMAL_ARRAY );
	glDisableClientState( GL_VERTEX_ARRAY );

	glDisable( GL_FRAGMENT_PROGRAM_ARB );
	glDisable( GL_VERTEX_PROGRAM_ARB );
}

void OGLRenderer::renderScreenQuad( Scene* scene, Vector const& col, Vector const& scale, Vector const& trans ) {

	glDisable( GL_CULL_FACE );
	glDisable( GL_DEPTH_TEST );
	glDepthMask( false );

	if( scene )
		setView( scene->getActiveView() );

	glMatrixMode( GL_PROJECTION );
	glPushMatrix();
	glLoadIdentity();
	glOrtho( -1.0, 1.0, -1.0, 1.0, -1, 1 );

	glMatrixMode( GL_MODELVIEW );
	glPushMatrix();
	glLoadIdentity();

	glTranslatef( trans.x, trans.y, trans.z );
	glScalef( scale.x, scale.y, 1.0f );
	glColor4fv( col.v );

	glBegin( GL_QUADS );

		glTexCoord2f( 0.0f, 1.0f );
		glVertex2f( -1.0f, -1.0f );

		glTexCoord2f( 1.0f, 1.0f );
		glVertex2f( 1.0f, -1.0f );

		glTexCoord2f( 1.0f, 0.0f );
		glVertex2f( 1.0f, 1.0f );

		glTexCoord2f( 0.0f, 0.0f );
		glVertex2f( -1.0f, 1.0f );

	glEnd();

	glPopMatrix();
	glMatrixMode( GL_PROJECTION );
	glPopMatrix();

	glDepthMask( true );
	glEnable( GL_DEPTH_TEST );
	glEnable( GL_CULL_FACE );
}