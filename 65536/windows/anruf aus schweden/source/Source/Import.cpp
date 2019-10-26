
#include "Import.h"
#include "numbers.h"

#define PLANE_LSEGS_DEFAULT				5
#define PLANE_WSEGS_DEFAULT				5
#define BOX_LSEGS_DEFAULT				5
#define BOX_WSEGS_DEFAULT				5
#define BOX_HSEGS_DEFAULT				8
#define SPHERE_SEGS_DEFAULT				20
#define CYLINDER_SEGS_DEFAULT			7
#define CYLINDER_CAP_SEGS_DEFAULT		7
#define CONE_SEGS_DEFAULT				5
#define CONE_CAP_SEGS_DEFAULT			5
#define TUBE_SEGS_DEFAULT				5
#define TUBE_CAP_SEGS_DEFAULT			5


Import::Import( unsigned char* buffer, Scene* _scene ) : scene( _scene ), sr( buffer ) {

	tempMaterials.reserve( 40 );
	loadScene();
}

Import::~Import() {
	scene = 0;
	tempMaterials.clear();
}

void Import::loadHeader() {

	scene->animation.start		= sr.read<unsigned int>();
	scene->animation.end		= sr.read<unsigned int>();
	scene->animation.fps		= sr.read<unsigned char>();
	scene->animation.delta		= sr.read<unsigned char>();
	scene->animation.frameCount = sr.read<unsigned int>();
}

void Import::loadMeshes() {

	unsigned int	meshCount = sr.read<unsigned int>();

	for( unsigned int i=0; i<meshCount; i++ ) {

		unsigned char objTyp = sr.read<unsigned char>();

		Mesh			mesh;

		if( sr.read<unsigned char>() == 1 ) {				// has material

			assert( tempMaterials.size() > 0 );
			int materialIndex = sr.read<unsigned int>();
			mesh.setMaterial( tempMaterials[ materialIndex ] );

		} else {											// default material

			Material	mat(
				Vector( 1.0f, 0.0f, 1.0f ),
				Vector( 1.0f, 0.0f, 1.0f ),
				Vector( 1.0f, 0.0f, 1.0f ),
				0.0f,
				Vector( 0.0f, 0.0f, 0.0f )
			);

			mesh.setMaterial( mat );
		}

		mesh.setDelta( scene->animation.delta );
		for( int j=0; j<scene->animation.frameCount; j++ ) {

			Matrix trans;
			trans.identity();
			trans.setCol( 3, sr.readVector() );

			Matrix rot( sr.readQuaternion().toMatrix() );

			Vector v( sr.readVector() );
			Matrix scale;
			scale.identity();
			scale.m[0][0] = v.x;
			scale.m[1][1] = v.y;
			scale.m[2][2] = v.z;

			mesh.addFrame( trans * rot * scale );
		}

		if( !sr.read<unsigned char>() ) {	

			if( objTyp == PLANE_OBJ )
				loadPlaneObj( &mesh );
			if( objTyp == BOX_OBJ )
				loadBoxObj( &mesh );
			if( objTyp == SPHERE_OBJ )
				loadSphereObj( &mesh );
			if( objTyp == CYLINDER_OBJ )
				loadCylinderObj( &mesh );
			if( objTyp == CONE_OBJ )
				loadConeObj( &mesh );
			if( objTyp == TUBE_OBJ )
				loadTubeObj( &mesh );

			mesh.calcNormals();

		} else {												// instanz

			unsigned int			instanceNum	= sr.read<unsigned int>();
			vertexList const&		vertices	= scene->getMeshes()[ instanceNum ].getVertices();
			triangleList const&		triangles	= scene->getMeshes()[ instanceNum ].getTriangles();
			
			for( vertexList::const_iterator it = vertices.begin(); it != vertices.end(); ++it )
				mesh.addVertex( *it );
			for( triangleList::const_iterator it = triangles.begin(); it != triangles.end(); ++it )
				mesh.addTriangle( *it );
		}

		scene->addMesh( mesh );
	}
}

void triangulate( Mesh* mesh, int segsx, int segsy, bool normalWrap ) {

	int	ofs		= static_cast<int>( mesh->getVertices().size() ) - ( segsx * segsy );
	int	wrap	= segsx;

	if( normalWrap )
		wrap = ( segsx - 1 );

	for( int j=0; j<segsy - 1; j++ ) {
		int row		= ofs + segsx * j;
		int nextRow = ofs + segsx * ( j + 1 );
		for( int i=0; i<segsx - 1; i++ ) {
			mesh->addTriangle( Triangle( row + i, nextRow + i, nextRow + ( i + 1 ) % wrap ) );
			mesh->addTriangle( Triangle( row + i, nextRow + ( i + 1 ) % wrap, row + ( i + 1 ) % wrap ) );
		}
	}
}

void Import::loadPlaneObj( Mesh* mesh ) {

	float	length	= sr.read<float>();
	float	width	= sr.read<float>();
	int		lsegs	= PLANE_LSEGS_DEFAULT; //sr.read<unsigned char>();
	int		wsegs	= PLANE_WSEGS_DEFAULT; //sr.read<unsigned char>();

	float	dw		= width / static_cast<float>( wsegs - 1 );
	float	dl		= length / static_cast<float>( lsegs - 1 );

	float l	= -length * 0.5f;
	for( int j=0; j<lsegs; j++ ) {
		float w = -width * 0.5f;
		for( int i=0; i<wsegs; i++ ) {
			mesh->addVertex( Vector( w, -l, 0.0f ) );
			w+=dw;
		}
		l+=dl;
	}

	triangulate( mesh, wsegs, lsegs, false );
}

void Import::loadBoxObj( Mesh* mesh ) {

	float	length	= sr.read<float>();
	float	width	= sr.read<float>();
	float	height	= sr.read<float>();
	int		lsegs	= BOX_LSEGS_DEFAULT; //sr.read<unsigned char>();
	int		wsegs	= BOX_WSEGS_DEFAULT; //sr.read<unsigned char>();
	int		hsegs	= BOX_HSEGS_DEFAULT; //sr.read<unsigned char>();

	float	deltaw	= width / static_cast<float>( wsegs - 1 );
	float	deltal	= length / static_cast<float>( lsegs - 1 );
	float	deltah	= height / static_cast<float>( hsegs - 1 );

	float	invert	= 1.0f;

	if( height < 0.0f )
		invert = -1.0f;

	// vorn
	float h = 0.0f;
	for( int j=0; j<hsegs; j++ ) {
		float w = -width * 0.5f;
		for( int i=0; i<wsegs; i++ ) {
			mesh->addVertex( Vector( invert * -w, -length * 0.5f, h ) );
			w += deltaw;
		}
		h += deltah;
	}

	triangulate( mesh, wsegs, hsegs, false );

	// hinten
	h = 0.0f;
	for( int j=0; j<hsegs; j++ ) {
		float w = -width * 0.5f;
		for( int i=0; i<wsegs; i++ ) {
			mesh->addVertex( Vector( invert * w, length * 0.5f, h ) );
			w += deltaw;
		}
		h += deltah;
	}

	triangulate( mesh, wsegs, hsegs, false );

	// oben
	float l = -length * 0.5f;
	for( int j=0; j<lsegs; j++ ) {
		float w = -width * 0.5f;
		for( int i=0; i<wsegs; i++ ) {
			mesh->addVertex( Vector( invert * w, l, /*-height * 0.5f*/ 0.0f ) );
			w += deltaw;
		}
		l += deltal;
	}

	triangulate( mesh, wsegs, lsegs, false );

	// unten
	l = -length * 0.5f;
	for( int j=0; j<lsegs; j++ ) {
		float w = -width * 0.5f;
		for( int i=0; i<wsegs; i++ ) {
			mesh->addVertex( Vector( invert * -w, l, /*height * 0.5f*/ height ) );
			w += deltaw;
		}
		l += deltal;
	}

	triangulate( mesh, wsegs, lsegs, false );

	// links
	l = -length * 0.5f;
	for( int j=0; j<lsegs; j++ ) {
		h = 0.0f;
		for( int i=0; i<hsegs; i++ ) {
			mesh->addVertex( Vector( invert * -width * 0.5f, -l, h ) );
			h += deltah;
		}
		l += deltal;
	}

	triangulate( mesh, hsegs, lsegs, false );

	// rechts
	l = -length * 0.5f;
	for( int j=0; j<lsegs; j++ ) {
		h = 0.0f;
		for( int i=0; i<hsegs; i++ ) {
			mesh->addVertex( Vector( invert * width * 0.5f, l, h ) );
			h += deltah;
		}
		l += deltal;
	}

	triangulate( mesh, hsegs, lsegs, false );
}

void Import::loadSphereObj( Mesh* mesh ) {

	float	radius	= sr.read<float>();
	int		segs	= SPHERE_SEGS_DEFAULT; //sr.read<unsigned char>();

	float	dradius	= PI / static_cast<float>( segs - 1 );
	float	dalpha	= 2.0f * PI / static_cast<float>( segs - 1 );
	float	r		= 0.0f;

	for( int j=0; j<segs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<segs; i++ ) {
			float rad = radius * static_cast<float>( sin( r ) );
			mesh->addVertex( Vector( rad * cos( a ), rad * sin( a ), radius * cos( r ) ) );
			a += dalpha;
		}
		r += dradius;
	}

	triangulate( mesh, segs, segs, true );
}

void Import::loadCylinderObj( Mesh* mesh ) {

	float	radius	= sr.read<float>();
	float	height	= sr.read<float>();
	int		sides	= sr.read<unsigned char>();
	int		segs	= CYLINDER_SEGS_DEFAULT; //sr.read<unsigned char>();
	int		capsegs	= CYLINDER_CAP_SEGS_DEFAULT; //sr.read<unsigned char>();

	float	dalpha	= 2.0f * PI / static_cast<float>( sides - 1 );
	float	dheight	= height / static_cast<float>( segs - 1 );
	float	h		= 0.0f;

	float	invert	= 1.0f;

	if( height < 0.0f )
		invert = -1.0f;

	// mantel
	for( int j=0; j<segs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -radius * cos( a ), radius * sin( a ), h ) );
			a += dalpha;
		}
		h += dheight;
	}

	triangulate( mesh, sides, segs, true );

	// deckel1
	float dradius	= radius / static_cast<float>( capsegs - 1 );
	float r			= 0.0f;
	for( int j=0; j<capsegs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -r * cos( a ), -r * sin( a ), height ) );
			a += dalpha;
		}
		r += dradius;
	}

	triangulate( mesh, sides, capsegs, true );

	// deckel2
	r = 0.0f;
	for( int j=0; j<capsegs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -r * cos( a ), r * sin( a ), 0.0f ) );
			a += dalpha;
		}
		r += dradius;
	}

	triangulate( mesh, sides, capsegs, true );
}

void Import::loadConeObj( Mesh* mesh ) {

	float	radius1	= sr.read<float>();
	float	radius2	= sr.read<float>();
	float	height	= sr.read<float>();
	int		sides	= sr.read<unsigned char>();
	int		segs	= CONE_SEGS_DEFAULT; //sr.read<unsigned char>();
	int		capsegs	= CONE_CAP_SEGS_DEFAULT; //sr.read<unsigned char>();

	float	dalpha	= 2.0f * PI / static_cast<float>( sides - 1 );
	float	dheight	= height / static_cast<float>( segs - 1 );
	float	dradius	= ( radius2 - radius1 ) / static_cast<float>( segs - 1 );
	float	h		= 0.0f;
	float	r		= radius1;
	float	invert	= 1.0f;

	if( height < 0.0f )
		invert = -1.0f;

	// mantel
	for( int j=0; j<segs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -r * cos( a ), r * sin( a ), h ) );
			a += dalpha;
		}
		h += dheight;
		r += dradius;
	}

	triangulate( mesh, sides, segs, true );

	if( radius2 > 0.0f ) {

		// deckel1
		dradius	= radius2 / static_cast<float>( capsegs - 1 );
		r		= 0.0f;
		for( int j=0; j<capsegs; j++ ) {
			float a = 0.0f;
			for( int i=0; i<sides; i++ ) {
				mesh->addVertex( Vector( invert * -r * cos( a ), -r * sin( a ), height ) );
				a += dalpha;
			}
			r += dradius;
		}

		triangulate( mesh, sides, capsegs, true );
	}

	if( radius1 > 0.0f ) {

		// deckel2
		dradius	= radius1 / static_cast<float>( capsegs - 1 );
		r = 0.0f;
		for( int j=0; j<capsegs; j++ ) {
			float a = 0.0f;
			for( int i=0; i<sides; i++ ) {
				mesh->addVertex( Vector( invert * -r * cos( a ), r * sin( a ), 0.0f ) );
				a += dalpha;
			}
			r += dradius;
		}

		triangulate( mesh, sides, capsegs, true );
	}
}

void Import::loadTubeObj( Mesh* mesh ) {

	float	radius1	= sr.read<float>();
	float	radius2	= sr.read<float>();
	float	height	= sr.read<float>();
	int		sides	= sr.read<unsigned char>();
	int		segs	= TUBE_SEGS_DEFAULT; //sr.read<unsigned char>();
	int		capsegs	= TUBE_CAP_SEGS_DEFAULT; //sr.read<unsigned char>();

	float	dalpha	= 2.0f * PI / static_cast<float>( sides - 1 );
	float	dheight	= height / static_cast<float>( segs - 1 );
	float	h		= 0.0f;

	float	invert	= 1.0f;

	if( height < 0.0f )
		invert = -1.0f;

	if( radius1 < radius2 ) {
		float tmp = radius1;
		radius1 = radius2;
		radius2 = tmp;
	}

	// mantel, outer
	for( int j=0; j<segs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -radius1 * cos( a ), radius1 * sin( a ), h ) );
			a += dalpha;
		}
		h += dheight;
	}

	triangulate( mesh, sides, segs, true );

	if( radius2 > 0.0f ) {

		// mantel, inner
		h = 0.0f;
		for( int j=0; j<segs; j++ ) {
			float a = 0.0f;
			for( int i=0; i<sides; i++ ) {
				mesh->addVertex( Vector( invert * -radius2 * cos( a ), -radius2 * sin( a ), h ) );
				a += dalpha;
			}
			h += dheight;
		}

		triangulate( mesh, sides, segs, true );
	}

	// deckel1
	float dradius	= ( radius1 - radius2 ) / static_cast<float>( capsegs - 1 );
	float r			= radius2;
	for( int j=0; j<capsegs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -r * cos( a ), -r * sin( a ), height ) );
			a += dalpha;
		}
		r += dradius;
	}

	triangulate( mesh, sides, capsegs, true );

	// deckel2
	dradius	= ( radius1 - radius2 ) / static_cast<float>( capsegs - 1 );
	r		= radius2;
	for( int j=0; j<capsegs; j++ ) {
		float a = 0.0f;
		for( int i=0; i<sides; i++ ) {
			mesh->addVertex( Vector( invert * -r * cos( a ), r * sin( a ), 0.0f ) );
			a += dalpha;
		}
		r += dradius;
	}

	triangulate( mesh, sides, capsegs, true );
}

void Import::loadCameras() {

	unsigned int cameraCount = sr.read<unsigned int>();

	for( unsigned int i=0; i<cameraCount; i++ ) {

		/*
		Camera cam( sr.read<float>() );

		// mehrere frames
		cam.setDelta( scene->animation.delta );
		for( int j=0; j<scene->animation.frameCount; j++ ) {

			Vector eye( sr.readVector() );
			Vector tgt( sr.readVector() );
			cam.addFrame( eye, tgt, Vector( 0.0f, 0.0f, 1.0f ) );
		}
		*/

		///// nur zwei frames pro camera !!
		Camera cam( sr.read<float>(), static_cast<float>( scene->animation.end - scene->animation.start ), Vector( 0.0f, 0.0f, 1.0f ) );

		cam.addEye( sr.readVector() );
		cam.addTarget( sr.readVector() );

		cam.addEye( sr.readVector() );
		cam.addTarget( sr.readVector() );

		scene->addCamera( cam );
	}
}

void Import::loadLights() {

	unsigned int lightCount	= sr.read<unsigned int>();

	for( unsigned int i=0; i<lightCount; i++ ) {

		Light light;
		light.setColor( sr.readVector() );
		light.setIntensity( sr.read<float>() );

		light.setDelta( scene->animation.delta );

		for( int j=0; j<scene->animation.frameCount; j++ ) {

			Vector pos( sr.readVector() );
			light.addFrame( pos );
		}

		scene->addLight( light );
	}
}

void Import::loadMaterials() {

	unsigned int materialCount = sr.read<unsigned int>();

	for( unsigned int i=0; i<materialCount; i++ ) {

		Vector	ambient				= sr.readVector() * 0.1f;
		Vector	diffuse				= sr.readVector();
		Vector	specular			= sr.readVector() * 2.0f;
		float	shininess			= sr.read<float>() * 128.0f * 4.0f;
		float	selfIllum			= sr.read<float>();
		Vector	selfIllumCol		= sr.readVector();
		bool	selfIllumColOn		= sr.read<unsigned char>() == 1 ? true : false;

		shininess = shininess > 128.0f ? 128.0f : shininess;

		Vector emissive;
		if( selfIllumColOn )
			emissive = selfIllumCol;
		else
			emissive = selfIllum * Vector( 1.0f, 1.0f, 1.0f );

		Material mat( ambient, diffuse, specular, shininess, emissive );
		tempMaterials.push_back( mat );
	}
}

void Import::loadScene() {

	unsigned int chunk = 0;

	do {
		chunk = sr.read<unsigned int>();

		if( chunk == HEADER_CHUNK )
			loadHeader();
		else if( chunk == MATERIAL_CHUNK )
			loadMaterials();
		else if( chunk == MESH_CHUNK )
			loadMeshes();
		else if( chunk == CAMERA_CHUNK )
			loadCameras();
		else if( chunk == LIGHT_CHUNK )
			loadLights();
		else
			assert( chunk == END_DELIMITER );

	} while( chunk != END_DELIMITER );

	scene->setActiveCamera( 0 );
	scene->createBuffers();
}