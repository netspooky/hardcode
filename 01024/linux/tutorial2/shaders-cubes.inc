shader_vtx:
db 'varying vec4 p,v;'
db 'void main()'
db '{'
db 'gl_Position=gl_Vertex;'
db 'p=vec4(mat3(cos(length(gl_Vertex.xy)),0.,sin(length(gl_Vertex.xy)),0.,1.,0.,-sin(length(gl_Vertex.xy)),0.,cos(length(gl_Vertex.xy)))*vec3(gl_Vertex.xy*.1,-.9),length(gl_Vertex.xy));'
db 'v=vec4(mat3(cos(length(gl_Vertex.xy)),0.,sin(length(gl_Vertex.xy)),0.,1.,0.,-sin(length(gl_Vertex.xy)),0.,cos(length(gl_Vertex.xy)))*vec3(gl_Vertex.xy*.1,.1),length(gl_Vertex.xy));'
db '}'
db 0

shader_frg:
db 'varying vec4 p,v;'
;db 'float mx(vec3 a){return max(a.x,max(a.y,a.z));}'
db 'float mn(vec3 a){return min(a.x,min(a.y,a.z));}'

db 'float F(vec3 a){return min(mn(vec3(1.)-abs(a)),-mn(abs(mod(a+vec3(.1),vec3(.4))-vec3(.2))-.15));}'
;db 'float F(vec3 a){return min(mn(vec3(1.)-abs(a)),length(mod(a,vec3(.4))-vec3(.2))-.06);}'

db 'vec3 n(vec3 a){'
db 'vec3 e=vec3(.0001,.0,.0);'
db 'return normalize(vec3(F(a)-F(a+e.xyy),F(a)-F(a+e.yxy),F(a)-F(a+e.yyx)));'
db '}'

db 'vec4 tr(vec3 E,vec3 D){'
db 'D=normalize(D);'
db 'float L=.01;'
db 'int i=0;'
db 'for(i;i<512;++i){'
db 'float d=F(E+D*L);'
db 'if(d<.0001)break;'
db 'L+=d;'
db '}'
;db 'return vec2(L,float(i)/512.);'
db 'return vec4(E+D*L,float(i)/512.);'
db '}'

db 'float I(vec3 a){'
db 'vec3 l=vec3(sin(p.w*1.3),cos(p.w*4.2),sin(p.w*3.2))*.9,la=l-a;'
db 'return length(tr(a,la).xyz-a)*dot(n(a),-normalize(la))/dot(la,la)+.01;'
;db 'return tr(a,-lv).x*F(a+lv)/dot(lv,lv)+.01;'
db '}'

db 'void main(){'
db 'vec4 t=tr(p.xyz,v.xyz);'
db 'gl_FragColor=I(t.xyz)*(abs(t)+vec4(t.w*5.));'
;db 'vec2 t=tr(p.xyz,v.xyz);'
;db 'vec3 q=p.xyz+normalize(v.xyz)*t.x;'
;db 'gl_FragColor=I(q)+vec4(t.y);'
db '}'
db 0