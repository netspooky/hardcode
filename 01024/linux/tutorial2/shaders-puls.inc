shader_vtx:
db 'varying vec4 p,v;'
db 'void main()'
db '{'
db 'gl_Position=gl_Vertex;'
db 'p=vec4(mat3(cos(length(gl_Vertex.xy)),0.,sin(length(gl_Vertex.xy)),0.,1.,0.,-sin(length(gl_Vertex.xy)),0.,cos(length(gl_Vertex.xy)))*vec3(gl_Vertex.xy*.1,-2.9),length(gl_Vertex.xy));'
db 'v=vec4(mat3(cos(length(gl_Vertex.xy)),0.,sin(length(gl_Vertex.xy)),0.,1.,0.,-sin(length(gl_Vertex.xy)),0.,cos(length(gl_Vertex.xy)))*vec3(gl_Vertex.xy*.1,.1),length(gl_Vertex.xy));'
db 'p.xyz=mat3(cos(length(gl_Vertex.xy)),sin(length(gl_Vertex.xy)),0.,-sin(length(gl_Vertex.xy)),cos(length(gl_Vertex.xy)),0.,0.,0.,1.)*p.xyz;'
db 'v.xyz=mat3(cos(length(gl_Vertex.xy)),sin(length(gl_Vertex.xy)),0.,-sin(length(gl_Vertex.xy)),cos(length(gl_Vertex.xy)),0.,0.,0.,1.)*v.xyz;'
db '}'
db 0

shader_frg:
db 'varying vec4 p,v;'

db 'float F(vec3 a){'
db 'return length(mod(a,vec3(.15))-vec3(.075))-.03*sin(-p.w*16.+2.*length(a));'
db '}'


db 'vec3 n(vec3 a){'
db 'vec3 e=vec3(.0001,.0,.0);'
db 'return normalize(vec3(F(a)-F(a+e.xyy),F(a)-F(a+e.yxy),F(a)-F(a+e.yyx)));'
db '}'

db 'vec3 T(vec3 E,vec3 D){'
db 'D=normalize(D);'
db 'float L=.01,d=.01;'
db 'for(int i=0;i<100&&d>.001;++i){'
db 'd=F(E+D*L);'
db 'L+=d;'
db '}'
db 'return E+D*L;'
db '}'

db 'float I(vec3 a,vec3 l){'
;db 'return clamp(length(T(a,l-a)-a),0.,length(l-a))*dot(n(a),normalize(a-l))/dot(l-a,l-a);'
db 'return dot(n(a),normalize(a-l))/length(l-a);'
db '}'

db 'void main(){'
db 'vec3 t=T(p.xyz,v.xyz);'
db 'gl_FragColor=vec4('
db 'I(t,vec3(sin(p.w*1.3),cos(p.w*4.2),sin(p.w*3.2))*.8)*vec3(.9,.6,.2)+'
db 'I(t,vec3(sin(p.w*3.2),sin(p.w*4.2),sin(p.w*1.3))*.8)*vec3(.0,.3,.5),1.);'
db '}'
db 0
