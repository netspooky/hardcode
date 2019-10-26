shader_vtx:
db 'varying vec4 p;'
db 'void main(){gl_Position=p=gl_Vertex;p.z=length(p.xy);}'
db 0

shader_frg:
db 'varying vec4 p;'
db 'void main(){'
db 'float '
db 'z=1./length(p.xy),'
db 'a=atan(p.x,p.y)+sin(p.z+z);'
db 'gl_FragColor='
db '2.*abs(.2*sin(p.z*3.+z*3.)+sin(p.z+a*4.)*p.xyxx*sin(vec4(z,a,a,a)))+(z-1.)*.1;'
db '}', 0

