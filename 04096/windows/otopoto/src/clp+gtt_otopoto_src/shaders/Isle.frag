uniform sampler2D n;
varying vec2 b;

void main()
{
	// (224, 189, 149) -> (0.88, 0.74, 0.58)
	gl_FragColor=vec4(.88,.74,.6,0.)-texture2D(n,b)*.1;
}
