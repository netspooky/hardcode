#include "stdinc.hpp"

#include "FlareEffect.hpp"

#include "Texture.hpp"

#include "Section.hpp"

const int segs= 1500;

Section particles;






void DoFlareEffect( const float frameTime )
{
	static float totalTime=0;

	const float periodTime= 5.0;
	static int period= 0;

	totalTime+= frameTime;

	period= totalTime/periodTime;

	float
//		vx= sin(totalTime/2.0)*5.0,
//		vy= cos(totalTime/2.0)*5.0,
//		vz= -30;
		vx= sin(totalTime*2.0)*30.0,
		vy= 0.0,
		vz= cos(totalTime*2.0)*30.0;

//	glMatrixMode( GL_MODELVIEW );
// glRotatef( 50.0*totalTime, 0.0, 00, 1.0 );
//	glMatrixMode( GL_PROJECTION );

	gluLookAt( 
		vx, vy, vz,
		0, 0, 0,
		0, 1.0, 0
	);

	for( int i= 0; i< particles.end; i++ )
	{
		float
			mu = i * (2.0*M_PI) / (double)segs;
		float nlongitude, nmeridian;

		switch( period )
		{
		case 0:
			nlongitude= 4.0;
			nmeridian= 3.0;
			break;

		case 1:
			nlongitude= 7.0;
			nmeridian= 4.0;
			break;

		case 2:
		case 3:
			nlongitude= 11.0;
			nmeridian= 6.0;
			break;
		}

		mu*= nmeridian;

		particles.verts[ i ].x = (cos(mu) * (1 + cos(nlongitude*mu/nmeridian) / 2.0))*5.0;
		particles.verts[ i ].y = (sin(mu) * (1 + cos(nlongitude*mu/nmeridian) / 2.0))*5.0;
		particles.verts[ i ].z = (sin(nlongitude*mu/nmeridian) / 2.0)*5.0;
	}

	particles.SetViewerDistance( vx, vy, vz );
//	glEnable( GL_DEPTH_TEST );
	glEnable( GL_BLEND );
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
//	glDisable( GL_POINT_SMOOTH );

	particles.RenderAsParticles( 2.0 );
//	glDisable( GL_DEPTH_TEST );
/*
	glEnable( GL_TEXTURE_2D );
	glGenTextures(1, &flareTexture.name );
	glBindTexture(GL_TEXTURE_2D, flareTexture.name );
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexImage2D( 
		GL_TEXTURE_2D, 
		0, 1, textureWidth, textureHeight, 
		0, GL_LUMINANCE, GL_UNSIGNED_BYTE, flareTexture.data );

	glBegin( GL_QUADS );
		glColor3d( 1.0, 1.0, 1.0 );

		glTexCoord2f( 0, 1.0 );
		glVertex3d( -30.0, -30.0, 0.0 );

		glTexCoord2f( 0, 0 );
		glVertex3d( -30.0, 30.0, 0.0 );

		glTexCoord2f( 1.0, 0 );
		glVertex3d( 30.0, 30.0, 0.0 );

		glTexCoord2f( 1.0, 1.0 );
		glVertex3d( 30.0, -30.0, 0.0 );
	glEnd();

	glDisable( GL_TEXTURE_2D );
*/
}

void InitFlareEffect()
{
	particles.verts= new Vertex[ segs ];
	particles.start= 0;
	particles.end= segs;

	for( int i= 0; i< particles.end; i++ )
	{
		float f= sin((i/(float)segs)*2.0*M_PI*8.0)*0.25 + 0.75;
		particles.verts[ i ].r= f;
		particles.verts[ i ].g= f;
		particles.verts[ i ].b= f;
		particles.verts[ i ].a= 1;
	}
}
