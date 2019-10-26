// This adds 70 bytes to file size, it is added with Hex editor after PNG packing
// It creates correctly sized and positioned canvas element that is required for webgl context
//<canvas id=F width=1280 height=720 style=position:fixed;top:0;left:0;>

// Optionally this could be used, but it usually takes more than 70 even thought its compressed
// unlike the HTML version above, which is simply added to final file as plain text
//c=document.createElement("canvas");
//document.body.appendChild(c);
//s=c.style;s.position="fixed";s.left=s.top=0;c.width=1280;c.height=720;

// Get webgl context and shorten all its function names with clever regex, this way we never have to
// full names of the functions which are pretty long
for(k in g=F.getContext("experimental-webgl"))
	g[k.match(/^..|[A-V]/g).join("")]=g[k];

// Save some space by not having to write g. in front of every webgl command
with(g){
	// Compile shaders
	for(a=crP(t=r=2);t;coS(s),atS(a,s))
		shS(s=crS(35634-t),
		
		// Fragment shader which does all the work and draws the scene
		// Since this is unreadable, I suggest you look at f1k.c instead which is the same thing,
		// but before going through Shader Minifier
		--t?"precision highp float;uniform float F;void main(){vec3 v=vec3(0);float i,f,s=.7<sin(F*"
		+".2)?F:gl_FragCoord.r*gl_FragCoord.g;for(int r=0;r<100;r++){vec3 g,n,c=vec3(1),d=vec3(0,.7"
		+",.1),b=normalize(gl_FragCoord.rbg/1440.-vec3(.44,-.2,.25)-d);for(int m=0;m<4;m++){vec3 k="
		+"vec3(0,10.25,0);i=100.;for(int e=0;e<8;e++){vec3 o=vec3(.2*cos(F),.2*sin(F),.34-F*.004),a"
		+"=k;f=.005;if(e<7)a=vec3(0,.7,.1).ggb,o=vec3(.12*cos(F*.7+3.),.12*sin(F*.7+3.),sin(F*.12)*"
		+".12);if(e<6)a=vec3(1),o=vec3(.12*cos(F*.7),.12*sin(F*.7),-sin(F*.12)*.12),f=.012;if(e<5)a"
		+"=vec3(0,.7,.1).ggg,o=k=-k.brg,f=100.;if(e==1)a=vec3(0,.7,.1).bgg;if(e==4)a=vec3(0,.7,.1)."
		+"gbg;float t,l=dot(b,o-d),C=l*l-dot(o-d,o-d)+f;if(0.<C)if(.0001<(t=l-sqrt(C)))if(t<i)i=t,n"
		+"=a,g=o;}if(i==100.)break;if(n==k){v+=12.*c;break;}d+=b*i;c*=n;g=normalize(d-g);b=n==vec3("
		+"1)?reflect(b,g):sign(dot(k=normalize(vec3(fract(sin(s+=.7)*s)-.5,fract(sin(s+=.7)*s)-.5,f"
		+"ract(sin(s+=.7)*s)-.5)),g))*k;}}gl_FragColor=vec4(.02*v*sign(166.-F),1);}"
		
		// Vertex shader, sadly we can't live without it
		:"attribute vec4 a;void main(){gl_Position=a;}");
				
	// Setup triangle on which the shader is applied
	veAP(enVAA(biB(34962,crB())),
		2,
		5126,
		liP(a),
		usP(a),
		buD(34962,new Float32Array([1,1,1,-3,-3,1]),35044)
	);

	// Main loop, hard coded to 10 FPS with 100 interval
	setInterval(
		// The shader only takes 1 parameter, time, as input
		// We have to use full function name "uniform1f" because there are too many collsions for
		// this function name in our renamer regex, however we use the word "uniform" in our GLSL
		// shader declaration and combine this with compression and using full name for this
		// particular function is actually cheap sizewise
		'g.drA(4,g.uniform1f(g.geUL(a,"F"),r+=.2),3)',
		100)
};
