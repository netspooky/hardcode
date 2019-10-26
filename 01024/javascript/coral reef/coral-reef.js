P = g.createProgram()

g.shaderSource(A=g.createShader(35633),"attribute vec2 P;void main(){gl_Position=vec4(P,0,1);}")
g.compileShader(A);g.attachShader(P,A)

g.shaderSource(A=g.createShader(35632),"precision mediump float;uniform float T;void main(){ float t=0.;for( float i=0.;i<32.;i++){vec3 p=vec3(0,1.3,0)+vec3(gl_FragCoord.xy/200.-1.,-2).xzy*t; float c=1.; float a=ceil(T*.3+gl_FragCoord.x/2e3)+T*.1;p.zy*=mat2(cos(a),-sin(a),sin(a),cos(a));a=a/2.;p.xy*=mat2(cos(a),-sin(a),sin(a),cos(a));a=a/2.;p.zx*=mat2(cos(a),-sin(a),sin(a),cos(a));vec3 z=p;for( float i=0.;i<9.;i++){if(dot(z,z)>4.){t+=log(length(z))*length(z)/c/2./2.;break;} float a=acos(z.z/length(z))*5.; float b=atan(z.y,z.x)*5.;c=pow(length(z),5.)*5.*c/length(z)+1.;z=pow(length(z),5.)*vec3(sin(a)*cos(b),sin(a)*sin(b),cos(a))+p;}gl_FragColor=vec4(1.-i/32.-t+p/2.,1);if(log(length(z))*length(z)/c/2.<1e-4||t>1.)break;}}")

g.compileShader(A);g.attachShader(P,A)
g.linkProgram(P);g.useProgram(P)

g.bindBuffer(A=34962,g.createBuffer())
g.bufferData(A,new Int8Array([-3,1,1,-3,1,1]),35044)

a.width=a.height=400;
g.enableVertexAttribArray(z=0)
g.vertexAttribPointer(0,2,5120,0,0,0)

g.uniform2f(g.getUniformLocation(P,"M"),0,0);

setInterval('g.uniform1f(g.getUniformLocation(P,"T"),A+=.01);g.drawArrays(6,0,3)',16);

f = new AudioContext();
w = f.createScriptProcessor(4096,1,1)
w.connect(f.destination)
if(true)w.onaudioprocess=function(e) {
  z++
  q=e.outputBuffer.getChannelData(0)
  for(i=4096;i--;){
  q[i]/=1.5
  for(j=7;--j;)                             
      q[i]+=Math.sin(i/326*(5/2+(48<z%96))*(j+j*(1>z%j)))*Math.sin(z/j)/j/(3+((i>>(z%24))&1)/5)
  }
}