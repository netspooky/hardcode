#ifndef SHADER_INL
#define SHADER_INL

//------------------------------------------------------------------------------------------
// Hand modified shader minifier output...
//------------------------------------------------------------------------------------------
const char* g_fragmentShader[] = 
{
 "void main()"
 "{"
   "int c=int(gl_FragCoord.r*40.+gl_FragCoord.g*6400.);"
   "c=c<<13^c;"
   "gl_FragData[0]=gl_FragData[1]=vec4(1.-float(c*(c*c*15731+789221)+1376312589&2147483647)/1.07374e+09);"
 "}",
 "void main()"
 "{"
   "vec4 c[8];"
   "ivec2 e=ivec2(gl_FragCoord.rg);"
   "for(int l=0;l<8;++l)"
     "c[l]=texelFetch(g,e,0),e-=r,c[l]+=texelFetch(g,e,0),e-=r;"
   "c[0]+=c[1];"
   "c[2]+=c[3];"
   "c[4]+=c[5];"
   "c[6]+=c[7];"
   "c[0]+=c[2];"
   "c[4]+=c[6];"
   "gl_FragData[0]=c[0]+c[4];"
 "}",
 "void main()"
 "{"
   "int z[10]=int[10](1,2,5,10,20,40,80,160,200,300);"
   "int p=z[r.r];"
   "ivec2 l=ivec2(gl_FragCoord.rg);"
   "ivec4 e=ivec4(min(l+p,ivec2(textureSize2D(g,0)-ivec2(1))),max(l-p,ivec2(0)));"
   "ivec2 d=max(e.rg-e.ba,ivec2(1));"
   "gl_FragData[0]=(texelFetch(g,e.rg,0)-texelFetch(g,e.ra,0)-texelFetch(g,e.bg,0)+texelFetch(g,e.ba,0))/(d.r*d.g);"
 "}",
 "void main()"
 "{"
   "float x[7]=float[7](25,45,65,85,150,125,145);"
   "int z[7]=int[7](4,2,2,2,3,3,3);"
   "int k[7]=int[7](0,2,3,4,5,6,8);"
   "vec2 h=textureSize(m,0),d=gl_FragCoord.rg-h*.5;"
   "float s=65535.;"
   "int p=6;"
   "vec2 f;"
   "for(int u=0;u<7;u++)"
     "{"
       "vec2 c=vec2(0);"
	   "int G=z[u],e=k[u];"
       "for(int x=0;x<G;x++)"
         "{"
           "float n=pi*x*2./G+r.r*.001;"
           "vec2 y=vec2(cos(n),sin(n)),b=vec2(d.r*y.r-d.g*y.g,dot(y,d.gr))/h+.5;"
           "c.r+=texture2DArray(a,vec3(b,e),0).r;"
           "c.g+=texture2DArray(a,vec3(b,e+1),0).r;"
         "}"
       "c/=G;"
       "float b=abs(c.r-c.g);"
       "if(b<s)"
         "s=b,f=c,p=u;"
     "}"
	 "gl_FragData[0]=gl_FragData[1]=vec4(texelFetch(m,ivec2(gl_FragCoord.rg),0).r+(2.*step(f.r,f.g)-1.)*x[p]*r.r*.000005);"
 "}",
 "void main()"
 "{"
   "ivec4 e=ivec4(gl_FragCoord.rgrg)*2+ivec4(ivec2(0),1,1);"
   "e.ba=clamp(e.ba,ivec2(0),r);"
   "vec2 d=texelFetch(g,e.rg,0).rg,l=texelFetch(g,e.bg,0).rg,f=texelFetch(g,e.ra,0).rg,c=texelFetch(g,e.ba,0).rg;"
   "gl_FragData[0]=vec4(min(min(min(d.r,l.r),f.r),c.r),max(max(max(d.g,l.g),f.g),c.g),0.,0.);"
 "}",
 "void main()"
 "{"
   "vec2 e=texelFetch(g,ivec2(0),0).rg;"
   "gl_FragData[0]=gl_FragData[1]=vec4(2.*(texelFetch(m,ivec2(gl_FragCoord.rg),0).r-e.r)/(e.g-e.r)-1.);"
 "}",
 "void main()"
 "{"
   "float c=texelFetch(g,ivec2(gl_FragCoord.rg),0).r;"
   "vec3 f=vec3(.786,.05,.5),e=mix(mix(vec3(.575,.39,.29),f,c),mix(f,vec3(.111,.07,.94),c),c);"
   "gl_FragData[0]=vec4(mix(vec3(1.),clamp(abs(fract(e.r+vec3(3.,2.,1.)/3.)*6.-3.)-1.,0.,1.),e.g)*e.b,1.);"
 "}"
};

#endif // SHADER_INL