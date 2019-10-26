#include "stdinc.hpp"

#include "ParticleEffect.hpp"

#include "Section.hpp"

const float particleEjectionRate= 0.001;
const float particleSpeed= 4.4;
const float particleFadeRate= 0.1;
const float particleSlowRate= 0.6;
const float particleGravity= 0.3;

const int maxParticles= 4000;

struct Particle
{
	double dx, dy, dz;
};


Particle particles[ maxParticles ];

Section particlesVert;


void DoParticleEffect( const float frameTime )
{
	static float totalTime= 0;
	static float lastEjection= particleEjectionRate;

	totalTime+= frameTime;

	const float 
		vz= -(80 + totalTime*4.0);


	gluLookAt( 
		0, 0, vz,
		0, 0, 0,
		0, 1.0, 0
		);

	for( int j= 0; j< 3; j++ )
	{
		for( int i= 0; i< maxParticles; i++ )
		{
			float timeSlice= frameTime*2.0;
			Vertex& pv= particlesVert.verts[i];
			
			pv.x+= particles[i].dx;
			pv.y+= particles[i].dy;
			pv.z+= particles[i].dz;
			
			{
				float t= 1.0-(particleSlowRate*timeSlice);
				particles[i].dx*= t;
				particles[i].dy*= t;
				particles[i].dz*= t;
			}
			
			{
				float d= 
					pv.x*pv.x +
					pv.z*pv.z;
				
				float move;
				
				const float flat= 30.0;
				const float flat2= flat*flat;
				
				if( d > flat2 )
					move= (d-flat2 )/flat2;
				else
					move= -(flat2-d)/flat2;
				
				move*= 0.6*timeSlice;
				
				particles[i].dy+= move;
				
			}
			
			{
				float d= 
					sqrt(
					pv.x*pv.x +
					pv.z*pv.z
					);
				float dir;
				
				if( pv.y < 0 )
					dir= 1.0;
				else
					dir= -1.0;
				
				float vm= 0.2*dir*timeSlice;
				
				particles[i].dx+= 
					(pv.x/d)*vm;
				//					particlesVert.verts[i].x*vm;
				particles[i].dz+= 
					(pv.z/d)*vm;
				//					particlesVert.verts[i].z*vm;
			}
			
			{
				float str= 
					sqrt( pv.y*pv.y );
				
				str*= 0.0005;
				
				if( pv.y > 0 )
					particles[i].dy-= str;
				else
					particles[i].dy+= str;
			}
		}
	}

	particlesVert.SetViewerDistance( 0, 0, vz );

//	glEnable( GL_FOG );
	glEnable( GL_DEPTH_TEST );

	float fogColor[]= { 0.5, 0.5, 0.5, 0.5 };

//	glFogf( GL_FOG_START, 0.0 );
//	glFogf( GL_FOG_END, 200.0 );
//	glFogi( GL_FOG_MODE, GL_LINEAR );
//	glFogf( GL_FOG_DENSITY, 0.03 );
//	glFogfv( GL_FOG_COLOR, fogColor );
		particlesVert.RenderAsParticles( 2.0 );

//	glDisable( GL_FOG );
	glDisable( GL_DEPTH_TEST );

}


void InitParticleEffect()
{
	particlesVert.verts= new Vertex[ maxParticles ];

	particlesVert.start= 0;
	particlesVert.end= maxParticles;

	for( int i= 0; i< maxParticles; i++ )
	{
		particlesVert.verts[i].a= 1.0;

		particlesVert.verts[i].x= frand()*100.0 - 50.0;
		particlesVert.verts[i].y= frand()*100.0 - 50.0;
		particlesVert.verts[i].z= frand()*100.0 - 50.0;

		if( particlesVert.verts[i].y > 0 )
		{
			particlesVert.verts[i].r= 0;
			particlesVert.verts[i].g= 0;
			particlesVert.verts[i].b= 0;
		}
		else
		{
			particlesVert.verts[i].r= 1.0;
			particlesVert.verts[i].g= 1.0;
			particlesVert.verts[i].b= 1.0;
		}

	}
}