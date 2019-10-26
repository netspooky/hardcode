#include "stdinc.hpp"

#include "StarEffect.hpp"




static const float subSystemOffset = 0.8;
static const float subSystemSize= 0.2;

void RenderStar( float angle, float size, float x, float y )
{
	const float mid= 0.55;
	const float midSize= mid*size;

	glBegin( GL_TRIANGLE_FAN );

	glColor3f( 1, 1, 1 );
	glVertex2f( x, y );
	glColor3f( 0, 0, 0 );


	for( int i= 0; i<6; i++ )
	{
		float 
			t1= 2.0*M_PI*(i*0.2) + angle,
			t2= t1+ 2.0*M_PI*0.1;

		glVertex2f( 
			x+size*mid*sin( t1 + angle ), 
			y+size*mid*cos( t1 + angle ) );
		glVertex2f( 
			x+size*sin( t2 + angle ), 
			y+size*cos( t2 + angle ) );
	}


	glEnd();

}

void RenderStarSystem( float angle, float size, float x, float y )
{

	if( size > 0.2 )
	{
		RenderStar( angle, size, x, y );

		for( int i= 0; i< 5; i++ )
		{
			float t= (i*0.2 + 0.1)*M_PI*2.0;
			float 
				newX= x + sin( t )*subSystemOffset*size,
				newY= y + cos( t )*subSystemOffset*size,
				newSize= size*subSystemSize,
				newAngle= angle;

			RenderStarSystem( newAngle, newSize, newX, newY );
		}
	}
}


void DoStarEffect( const float frameTime )
{


	static int phase= 0;
	static int followingPath= 1;
	static float period= 1.0;
	static float totalTime= period;

	totalTime+= frameTime;

	static float 
		xDelta= 0, 
		yDelta= 0, 
		sizeDelta= 20;

	gluLookAt(
		0, 0, -100,
		0, 0, 0,
		0, 1, 0 );

	static float 
		x= 0,
		y= 0,
		size= 20;

	if( totalTime>=period )
	{
		size= 40.0;
		x= 0;
		y= 0;

		followingPath= rand()%5;

		float t= (followingPath*0.2 + 0.1)*2.0*M_PI;
		float 
			targetSize= 1.0/subSystemSize * size,
			targetX= sin( t )*targetSize*subSystemOffset,
			targetY= cos( t )*targetSize*subSystemOffset;


		sizeDelta= (targetSize - size)/period;
		xDelta= (x - targetX)/period;
		yDelta= (y - targetY)/period;

		totalTime-= period;
	}


	x+= frameTime*xDelta;
	y+= frameTime*yDelta;
	
	size+= sizeDelta*frameTime;

	RenderStarSystem( totalTime*3.0, size, x, y );
}


void InitStarEffect()
{
	// blah
}
