uniform float i,f;
uniform vec2 u;

varying float l;
varying vec2 a;
varying vec3 e;
varying mat3 t;

// frequency, amplitude, phase and direction
struct v{float f,a,p;vec2 d;};

v k=v(1.,1.,.5,vec2(-1., 0.)),r=v(2.,.5,1.3,vec2(-.7,.7));

// Evaluate d
//float v(W w,vec2 p,float t){return w.a*sin(dot(w.d,p)*w.f+t*w.p);}
// Evaluate derivative of d function
float g(v w){return w.f*w.a*cos(dot(w.d,e.xz)*w.f+i*w.p);}

///////// SHADER FUNCTIONS ///////////////
void main()
{
	e=gl_Vertex.xzy;

    k.f=u.y;
    r.a=k.a=u.x;
    r.f=u.y*2.;
    
    // sum waves
    l=g(k)+g(r);
	e.y=l;
	vec2 x=l*k.d;
	
	l=sqrt(dot(e.xz,e.xz))/500.;
	
	if(f>0.)
	{
		e.y=e.y/max(l*7.,1.)-5.;
	}
	
    // pass texture coordinates for fetching the normal map
	a=gl_MultiTexCoord0.xy*2.+mod(i,100.)*vec2(-.005,.001);
	
	gl_Position=gl_ModelViewProjectionMatrix*vec4(e,1.);
	
    // first rows are the tangent and binormal scaled by the bump scale
    t[0]=vec3(1.,x.x,0.);
    t[1]=vec3(0.,x.y,1.);
    t[2]=vec3(-x.x,1.,-x.y);
                                                         
    // compute the eye vector (going from shaded point to eye) in cube space
    e=gl_ModelViewMatrixInverse[3].xyz-e;
}
