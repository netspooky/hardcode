// BUNCHBOX, Brad Smith 9/18/2009

#include "geometry.h"
#include "GL/gl.h"

static const bool box_faces[3][6] = {
	// up           right
	{ 0, 1, 0,      0, 0, 1 },
	{ 0, 0, 1,      1, 0, 0 },
	{ 1, 0, 0,      0, 1, 0 } };

// draw an axis aligned box
void geom_box( const vec3 & min_, const vec3 & max_ )
{
	const vec3 min = min_;
	const vec3 max = max_;
	//vminmax( &min, &max );
	// cutting out minmax causes normal inversion if backwards,
	// but saves 37 bytes and looks cool on the music_box

	const vec3 diff = max - min;
	for ( int i=0; i < 3; ++i )
	{
		vec3 up;
		vec3 right;

		for ( int j=0; j < 3; ++j )
		{
			up.v[j]    = box_faces[i][j  ] ? diff.v[j] : 0.0f;
			right.v[j] = box_faces[i][j+3] ? diff.v[j] : 0.0f;
		}
		const vec3 nrm = right.crs( up );
		const vec3 up_right = up + right;

		glNormal3fv( nrm.v );
		glVertex3fv( min.v );
		glVertex3fv( (min+right).v );
		glVertex3fv( (min+up_right).v );
		glVertex3fv( (min+up).v );

		glNormal3fv( nrm.neg().v );
		glVertex3fv( max.v );
		glVertex3fv( (max-up).v );
		glVertex3fv( (max-up_right).v );
		glVertex3fv( (max-right).v );
	}
}

// end of file
