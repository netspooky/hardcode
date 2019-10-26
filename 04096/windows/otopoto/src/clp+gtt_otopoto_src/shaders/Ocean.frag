uniform sampler2D h;

varying float l;
varying vec2 a;
varying mat3 t;
varying vec3 e;

// Get normal from heightmap by calculating a local average (texture must be 256x256!)
vec3 g(vec2 v)
{return normalize(vec3(texture2D(h,v+vec2(.0039,0.)).r-
						texture2D(h,v-vec2(.0039,0.)).r,
						texture2D(h,v+vec2(0.,.0039)).r-
						texture2D(h,v-vec2(0.,.0039)).r,1.));}
						
void main()
{
	// calculate if we are facing to get fresnel
    float f=1.-max(dot(normalize(e),normalize(t*(g(a)+g(a*2.)+g(a*4.)))),0.);
	gl_FragColor=vec4(.5*mix(vec3(0.,0.,.1),vec3(0.,.5,.5),f)+.1+.9*pow(f,16.),pow(l,3.));
}