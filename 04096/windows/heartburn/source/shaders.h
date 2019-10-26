static char const* const shaderParts[] = {
	// Version header
	"#version 150\n"
	,
	// Particle output
	"out vec4 o1,o2;"
	"out vec3 o3;"
	,
	// Hash function
	"float w(float e)"
	"{"
		"return fract(sin(e*12.9898)*43758.5453);"
	"}"
	,
	// Rotation function
	"mat2 f(float e)"
	"{"
		"return mat2(cos(e),-sin(e),sin(e),cos(e));"
	"}"
	,

	// Seeding vertex shader header
	"uniform float a[12];"
	"in float a0;"
	"in vec4 a1,a2;"
	"vec3 g(float e,vec3 d){" ,
	// Seeding shader - second position function
	";}vec3 h(float e,vec3 d){" ,
	// Seeding shader - generator and start of main()
	";}"
	"vec3 i(float e,vec3 d)"
	"{"
		"vec3 v=mix(g(e,d),h(e,d),clamp(a[7],0.,1.));"
		"v.zy*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/3.31);"
		"return v;"
	"}"
	"void main()"
	"{"
		"float e=a[6]+a1.w*200.+a0*.0125;"
	,
	// Seeding shader - end of main()
		"vec3 d=a1.xyz+a2.xyz;"
		"o1=vec4(o3=i(e,d),1.),"
		"o3-=i(e-.01,d),"
		"e=(1.+a2.a)*64.,"
		"o2=vec4("
			"pow("
				"vec3("
					"pow(a0/e,.25),"
					".5*a0/e,"
					".5*pow(a0/e-.5,2.)"
				"),"
				"vec3(1./(1.+a[3]))"
			"),"
			".5+a[2]/2."
		"),"
		"o3=vec3("
			"o3.x+w(gl_VertexID+e),"
			"o3.y+.2,"
			"o3.z+w(gl_VertexID+a[6])"
		")*.06;"
	"}"
	,

	// Trajectory functions
	//		0/ circular thingy
	"return vec3((4.+a[0])*cos(e),(4.+a[1])*sin(e),"
		"2.*sin(e)*cos(e*.7))+d*.5"
	,
	//		1/ ribbon
	"e*=.25;return vec3(cos(4.*e)-pow(cos(3.*e),3.),"
		"sin(7.*e)-pow(sin(e),3.),"
		"cos(2.*e)-pow(sin(2.*e),3.)"
		")*vec3(2.+a[1],2.,3.+a[0])+d*.3"
	,
	//		2/ messy flower-like
	"e*=.125;return vec3(cos(e*6.5)*sin(e),"
		"cos(e*26.)*cos(e),"
		".5*(cos(e*.5)+a[0]*sin(e*7.)*cos(e))"
		")*(5.+a[2])+d*.2*(a[1]+1)"
	,
	//		3/ flower-like
	"e*=.125;return vec3(cos(e*13.)*sin(e),cos(e*13.)*cos(e),"
		".5*(cos(e*.5)+a[0]*sin(e*7.)*cos(e)))"
		"*(5.+a[2])+d*.2*(a[1]+1)"
	,
	//		4/ flower
	"e=e*.125+a[5];vec3 s=vec3("
		"cos(e*13.)*sin(e),cos(e*13.)*cos(e),cos(e*13.)*sin(e*13.));"
		"return s*(5.+a[2])+d*.2*mix(s,vec3(1.),a[0])*(a[1]+1.)"
	,
	//		5/ heart
	"return vec3(4.*pow(sin(e),3.),"
		"3.25*cos(e)-1.25*cos(2.*e)-.5*cos(3.*e)-.25*cos(4.*e),"
		"4.*sin(e*.25))+d*vec3(a[0],a[1],a[4])"
	,


	// Passthrough shader for particles
	"in vec4 a0,a1;"
	"in vec3 a2;"
	"void main()"
	"{"
		"o1=a0,"
		"o2=a1,"
		"o3=a2;"
	"}"
	,

	// Flame shader
	"uniform float a[12];"
	"layout(points)in;"
	"layout(points,max_vertices=1)out;"
	"in vec4 o1[1],o2[1];"
	"in vec3 o3[1];"
	"out vec4 g1,g2;"
	"out vec3 g3;"
	"void main()"
	"{"
		"float l=clamp(a[9],.015,.15);"
		"if(o2[0].w>l){"
			"g1=o1[0]+vec4(o3[0],0.),"
			"g2=o2[0]-vec4(0.,0.,0.,l),"
			"g3=mix(o3[0],vec3(w(o1[0].x+a[6])*.2,.5+w(o1[0].y+a[6])*.2,w(o1[0].z+a[6])*.2),.02);"
			"EmitVertex();"
		"}"
	"}"
	,

	// Rendering vertex shader
	"uniform float a[12];"
	"in vec4 a0,a1;"
	"out vec4 d,e;"
	"void main()"
	"{"
		"e=a0,"
		"e.xz*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/1.65),"
		"e.z-=40.,"
		"gl_Position=e*mat4("
			"4.828427/a[10],0.,0.,0.,"
			"0.,4.828427,0.,0.,"
			"0.,0.,-1.0078125,-1.00390625,"
			"0.,0.,-1.,0."
		"),"
		"d=a1,"
		"gl_PointSize=64.*(1.5-d.a*d.a)/(length(e)-30.);"
	"}"
	,
	// Rendering fragment shader
	"in vec4 d,e;"
	"out vec4 c;"
	"void main()"
	"{"
		"float a=length(gl_PointCoord-vec2(.5));"
		"if(a>.5)"
			"discard;"
		"c=vec4(d.xyz*d.a,mix((.5-a),2.*a*a,clamp(.5-(e.z+40.)/2.,0.,1.)))*d.a;"
	"}"
	,

	// Main part of the line FS (rest comes from seeding shader)
		"o1=vec4(i(e,a1.xyz),1.),"
		"o1.xz*=f(mix(a[6],62.2,clamp(a[8],0.,1.))/1.65),"
		"o1.z-=40.,"
		"gl_Position=o1*mat4("
			"4.828427/a[10],0.,0.,0.,"
			"0.,4.828427,0.,0.,"
			"0.,0.,-1.0078125,-1.00390625,"
			"0.,0.,-1.,0."
		"),"
		"e=.25*a2.a+(clamp(a[9],.015,.15)-.015)*5.55,"
		"o2=vec4(e,e,e,pow(a0/128.,2.)*(o1.z+45.)*.1);"
	"}"
	,
	// Line fragment shader
	"in vec4 o2;"
	"out vec4 c;"
	"void main()"
	"{"
		"c=o2;"
	"}"
};


#define SCP_HEADER		0

#define SCP_PART_OUT		1
#define SCP_HASH_FN		2
#define SCP_ROT_FN		3

#define SCP_SEED_HEADER		4
#define SCP_SEED_CFN2_HD	5
#define SCP_SEED_GEN		6
#define SCP_SEED_MAIN		7
#define SCP_SEED_FN_0		8
#define SCP_SEED_FN_1		9
#define SCP_SEED_FN_2		10
#define SCP_SEED_FN_3		11
#define SCP_SEED_FN_4		12
#define SCP_SEED_FN_5		13

#define SCP_COPY		14
#define SCP_FLAME		15

#define SCP_RENDER_VS		16
#define SCP_RENDER_FS		17

#define	SCP_LINE_MAIN		18
#define	SCP_LINE_FS		19


struct shader_t
{
	GLenum type;
	int len;
	unsigned char const parts[9];
};

static struct shader_t const shaderDefs[] = {
	// Seeding shaders
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_0 , SCP_SEED_CFN2_HD , SCP_SEED_FN_1 ,
		SCP_SEED_GEN , SCP_SEED_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_1 , SCP_SEED_CFN2_HD , SCP_SEED_FN_2 ,
		SCP_SEED_GEN , SCP_SEED_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_2 , SCP_SEED_CFN2_HD , SCP_SEED_FN_3 ,
		SCP_SEED_GEN , SCP_SEED_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_3 , SCP_SEED_CFN2_HD , SCP_SEED_FN_4 ,
		SCP_SEED_GEN , SCP_SEED_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_4 , SCP_SEED_CFN2_HD , SCP_SEED_FN_5 ,
		SCP_SEED_GEN , SCP_SEED_MAIN
	} } ,

	// Copy shader
	{ GL_VERTEX_SHADER , 2 , {
		SCP_PART_OUT , SCP_COPY , 0 , 0 , 0 , 0 , 0 , 0 , 0
	} } ,

	// Rendering vertex shader
	{ GL_VERTEX_SHADER , 2 , {
		SCP_ROT_FN , SCP_RENDER_VS , 0 , 0 , 0 , 0 , 0 , 0 , 0
	} } ,

	// Flame shader
	{ GL_GEOMETRY_SHADER , 2 , {
		SCP_HASH_FN , SCP_FLAME , 0 , 0 , 0 , 0 , 0 , 0 , 0
	} } ,

	// Rendering fragment shader
	{ GL_FRAGMENT_SHADER , 1 , {
		SCP_RENDER_FS , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
	} } ,

	// Line vertex shaders
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_0 , SCP_SEED_CFN2_HD , SCP_SEED_FN_1 ,
		SCP_SEED_GEN , SCP_LINE_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_1 , SCP_SEED_CFN2_HD , SCP_SEED_FN_2 ,
		SCP_SEED_GEN , SCP_LINE_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_2 , SCP_SEED_CFN2_HD , SCP_SEED_FN_3 ,
		SCP_SEED_GEN , SCP_LINE_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_3 , SCP_SEED_CFN2_HD , SCP_SEED_FN_4 ,
		SCP_SEED_GEN , SCP_LINE_MAIN
	} } ,
	{ GL_VERTEX_SHADER , 9 , {
		SCP_PART_OUT , SCP_HASH_FN , SCP_ROT_FN , SCP_SEED_HEADER ,
		SCP_SEED_FN_4 , SCP_SEED_CFN2_HD , SCP_SEED_FN_5 ,
		SCP_SEED_GEN , SCP_LINE_MAIN
	} } ,

	// Line fragment shaders
	{ GL_FRAGMENT_SHADER , 1 , {
		SCP_LINE_FS , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0
	} } ,
};

#define N_SHADERS (sizeof(shaderDefs) / sizeof(struct shader_t))