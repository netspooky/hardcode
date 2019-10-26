shader_vtx:
db 'varying vec4 p;'
db 'void main(){'
db 'p=gl_Position=gl_Vertex;p.w=length(p.xy);'
db '}', 0

shader_frg:
db 'varying vec4 p;'
db 'void main(){'
db 'gl_FragColor=p*sin(p.w);'
db '}', 0
