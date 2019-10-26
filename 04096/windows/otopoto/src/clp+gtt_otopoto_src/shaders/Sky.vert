// The camera's current position and light's direction
uniform vec3 z,y;
varying vec3 x,v,w;
// The camera's current height
//uniform float camHeight;

// a = The inner (planetary) radius
// fScale = 1 / (fOuterRadius - a)
// c = The u depth (i.e. the altitude at which the atmosphere's average density is found)
// 1 / pow(wavelength, 4) for the red, green, and blue channels
vec3 e=vec3(.0140,.0237,.0491);

float u(float b){b=1.-b;return exp(-.00287+b*(.459+b*(3.83+b*(-6.8+b*5.25))))/4.;}

void main()
{
	// Get the ray from the camera to the vertex, and its length (which is the far point of the ray passing through the atmosphere)
	vec3 k=gl_Vertex.xyz/10000.;
	k.y+=10.; 

	vec3 j=k-z;
	float n=length(j);
	j/=n;

	// Calculate the ray's starting position, then calculate its scattering offset
	vec3 i=j*n*.5,g=z+i*.5,f=vec3(0.);

	for(int l=0;l<2;l++)
	{
		float x=length(g),v=exp(16.*(10.-x));
		f+=exp(-(4.95*u(dot(j,z)/length(z))+v*(u(dot(y,g)/x)-u(dot(j,g)/x)))*(e+.0025)*12.6)*v*n*70.;
		g+=i;
	}

	// Finally, u the Mie and Rayleigh colors and set up the varying variables for the pixel shader
	v=f*.0025;
	w=f*e;
	x=z-k;

	gl_Position=ftransform();
}