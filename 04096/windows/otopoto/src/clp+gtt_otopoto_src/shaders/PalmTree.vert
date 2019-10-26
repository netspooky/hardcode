varying vec3 h,c;

void main()
{
	vec4 e=gl_Vertex;
	
	e.xy+=sin(e.z*.8)*.2;
	
	h=e.xzy;
	c=vec3(.34,.2,.1);	
	gl_Position=gl_ModelViewProjectionMatrix*e;
} 
