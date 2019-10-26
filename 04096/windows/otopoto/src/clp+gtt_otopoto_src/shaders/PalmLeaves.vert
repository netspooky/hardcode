varying vec3 h,n,l,c;
	
void main()
{
	vec4 e=gl_Vertex.xzyw;

	if(e.z>-.5)
	{
		e.x*=abs(sin(e.y*11.8));
	}
	
	e.z=cos(e.x*8.)*cos(e.y*.45-.5)*.6;
		
	h=e.xyz;
	c=vec3(.34,.5,.1);
	
	n=gl_NormalMatrix*gl_Normal;
	l=gl_LightSource[0].position.xyz;
	
	gl_Position=gl_ModelViewProjectionMatrix*e;
} 
