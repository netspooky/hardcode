/* File generated with Shader Minifier 1.1.1
 * http://www.ctrl-alt-test.fr
 */

// Shader.glsl
""
 "float c;"
 "float s(vec3 x)"
 "{"
   "return mix(.4,.2,cos(c*200))+cos(x.x*6+cos(5-x.y*7)*3)*cos(x.y*3+cos(x.z*6)*2)*cos(x.z*4+cos(x.x*8)*2);"
 "}"
 "void main()"
 "{"
   "c=gl_Color.x;"
   "vec2 x=(gl_FragCoord.xy/1000-vec2(.5,.35))*75*c;"
   "vec3 v=vec3(0,1,0),a=v.xxx,y=vec3(cos(c*20),0,sin(c*20)),z=cross(v,y),r=cross(z,y),m=z*x.x+r*x.y+y;"
   "float o=.01+smoothstep(.5,1,c)*.05,g,e;"
   "int t=0;"
   "while(t++<100)"
     "e=s(a)*o,g+=e,a+=e*m;"
   "vec3 d=vec3(s(a+v.yxx)-e,s(a+v.xyx)-e,s(a+v.xxy)-e);"
   "gl_FragColor=vec4(g*cos(atan(d.z,d.y))*c*2,g*mix(1,cos(atan(d.x,d.z)),c*.2),g*cos(atan(d.y,d.x))*(c-.5),1);"
 "}"

