#include "stdinc.hpp"

#include "Section.hpp"

#include <cmath>

const int maxVertexBufferSize= 10000;
int vertexBufferSize= 100;

Vertex vertexBuffer[maxVertexBufferSize];
Vertex *sortedVertexBuffer[maxVertexBufferSize];

/*
void Section::Rotate( const double x, const double y, const double z )
{
	for( int i= start; i< end; i++ )
	{
		verts[ i ].Rotate( x, y, z );
	}
}

void Section::Translate( const double x, const double y, const double z )
{
	for( int i= start; i< end; i++ )
	{
		verts[ i ].x+= x;
		verts[ i ].y+= y;
		verts[ i ].z+= z;
	}
}

void Section::SetColor( const double r, const double g, const double b, 
	const double a )
{
	for( int i= start; i< end; i++ )
	{
		verts[ i ].r= r;
		verts[ i ].g= g;
		verts[ i ].b= b;
		verts[ i ].a= a;
	}
}


void Section::CopyFrom( Section& otherSection )
{
	for( int i= 0; i< (end-start); i++ )
	{
		verts[ start + i ]= otherSection.verts[ otherSection.start + i ];
	}
}

*/


void Section::Render()
{
	glBegin( type );
		for( int i= start; i<end; i++ )
		{
			glColor4d( verts[ i ].r, verts[ i ].g, verts[ i ].b, verts[ i ].a );
			glVertex3d( verts[ i ].x, verts[ i ].y, verts[ i ].z );
		}
	glEnd();
}

int compFunc( const void *ele1, const void *ele2 )
{
	Vertex 
		*e1= *((Vertex**)ele1), 
		*e2= *((Vertex**)ele2);

	if( e1->viewerDistance > e2->viewerDistance )
	{
		return 1;
	}
	else
	{
		if( e1->viewerDistance < e2->viewerDistance )
			return -1;
		else
			return 0;
	}

}

void Section::RenderAsParticles( const float particleSize )
{
	// sort the buffer..
	{
		for(int i= 0; i< end; i++ )
		{
			sortedVertexBuffer[ i ]= &verts[i];
		}

		qsort( sortedVertexBuffer, end, sizeof( Vertex* ), compFunc );
	}

	for( int i= end-1; i>=start; i-- )
	{
		Vertex* v= sortedVertexBuffer[ i ];
		glPointSize( particleSize*screenRatio*256.0/v->viewerDistance );
//		glPointSize( screenRatio*v->viewerDistance + 2.0 );

		glBegin( GL_POINTS );
			glColor4d( v->r, v->g, v->b, v->a );
			glVertex3d( v->x, v->y, v->z );
		glEnd();
	}
}

void Section::SetViewerDistance( const double vx, const double vy, 
	const double vz )
{
//	float buf[3];

//	glRenderMode( GL_FEEDBACK );
//	glFeedbackBuffer( 3, GL_3D, buf );

//	glBegin( GL_POINTS );
	for( int i= start; i<end; i++ )
	{

		double 
			xd= vx- verts[i].x,
			yd= vy- verts[i].y,
			zd= vz- verts[i].z;

		verts[i].viewerDistance=
			sqrt(  xd*xd + yd*yd + zd*zd );

//		glVertex3f( verts[i].x, verts[i].y, verts[i].z );
//		verts[i].viewerDistance= buf[2];
	}
//	glEnd();
//	glRenderMode( GL_RENDER );
}

/*
void Section::GenLineCube( const int iterations, const double size )
{
	const double hsize= size/2.0;
	const double step= size/double(iterations);

	const int sideVerts= iterations*iterations*2*2;

	end= start + sideVerts*6;
	type= GL_LINES;

	// gen plane

	for( int x= 0; x<iterations; x++ )
	{
		for( int y= 0; y<iterations; y++ )
		{
			int i= start + (x+y*iterations)*4;

			verts[ i ].x= step*x - hsize;
			verts[ i ].y= step*y - hsize;
			verts[ i ].z= hsize;

			i++;
			verts[ i ].x= step*x - hsize;
			verts[ i ].y= step*(y+1) - hsize;
			verts[ i ].z= hsize;

			i++;
			verts[ i ].x= step*x - hsize;
			verts[ i ].y= step*y - hsize;
			verts[ i ].z= hsize;

			i++;
			verts[ i ].x= step*(x+1) - hsize;
			verts[ i ].y= step*y - hsize;
			verts[ i ].z= hsize;
		}
	}
		
//	Translate( 0, 0, 10.0 );

	{
		Section s;
		s.verts= verts;

		s.start= start + sideVerts;
		s.end= s.start + sideVerts;

		s.CopyFrom( *this );
		s.Rotate( 0, M_PI/2.0, 0 );


		s.start+= sideVerts;
		s.end+= sideVerts;
		s.CopyFrom( *this );
		s.Rotate( M_PI/2.0, 0, 0 );


		s.start+= sideVerts;
		s.end+= sideVerts;
		s.CopyFrom( *this );
		s.Rotate( -M_PI/2.0, M_PI/2.0, 0 );


		s.start+= sideVerts;
		s.end+= sideVerts;
		s.CopyFrom( *this );
		s.Rotate( 0, M_PI, M_PI/2.0 );


		s.start+= sideVerts;
		s.end+= sideVerts;
		s.CopyFrom( *this );
		s.Rotate( 0, -M_PI/2.0, 0 );
		s.Rotate( M_PI/2.0, 0, 0 );
	}

}

void Section::Suction( const double strength,
	const double cx, const double cy, const double cz )
{
	for( int i= start; i< end; i++ )
	{
		Vertex& v= verts[ i ];
		double 
			xOff= cx - v.x, 
			yOff= cy - v.y, 
			zOff= cz - v.z;
		double distance= sqrt( xOff*xOff + yOff*yOff + zOff*zOff );

		distance= strength/distance;

//cout << distance << endl;

		xOff*= distance;
		yOff*= distance;
		zOff*= distance;

		v.x+= xOff;
		v.y+= yOff;
		v.z+= zOff;
	}
}

void Section::GenShell( const int iterations, const double size )
{
	start= 0;
	end= 8*3;

	type= GL_TRIANGLES;

	verts= new Vertex[ end ];

	
	// first it..

	verts[ 0 ].x= 0;
	verts[ 0 ].y= size;
	verts[ 0 ].z= 0;
	verts[ 1 ].x= -size;
	verts[ 1 ].y= 0;
	verts[ 1 ].z= 0;
	verts[ 2 ].x= 0;
	verts[ 2 ].y= 0;
	verts[ 2 ].z= size;

	verts[ 0 + 3 ].x= 0;
	verts[ 0 + 3 ].y= size;
	verts[ 0 + 3 ].z= 0;
	verts[ 1 + 3 ].x= 0;
	verts[ 1 + 3 ].y= 0;
	verts[ 1 + 3 ].z=  -size;
	verts[ 2 + 3 ].x= size;
	verts[ 2 + 3 ].y= 0;
	verts[ 2 + 3 ].z= 0;

	SetColor( 0, 0, 1, 1 );
}
*/