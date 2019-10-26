uniform vec3 y;
varying vec3 x,v,w;

void main()
{
	float u=dot(y,x)/length(x);
	gl_FragColor.rgb=1.-exp(-2.*(w+.010067*(1.+u*u)/pow(1.98+1.98*u,1.5)*v));
}