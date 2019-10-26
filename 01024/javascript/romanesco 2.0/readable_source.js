// 35633 = gl.VERTEX_SHADER
// 35632 = gl.FRAGMENT_SHADER
// 35044 = gl.STATIC_DRAW
// 34962 = gl.ARRAY_BUFFER
// 05120 = gl.BYTE
// 00006 = gl.TRIANGLE_FAN

// Code may look unnecessarily complicated here and there,
// but that's all part of the compression optimization, the more patterns, the better.

P = g.createProgram()

g.shaderSource(A=g.createShader(35633),"attribute vec2 P;void main(){gl_Position=vec4(P,0,1);}")
g.compileShader(A);g.attachShader(P,A)

g.shaderSource(A=g.createShader(35632),"precision mediump float;uniform vec2 R,M;uniform float T; float t=5e-3;void main(){for( float i=0.;i<64.;i++){vec3 p=vec3((2.*gl_FragCoord.xy-R)/R.yy,t-1.),b=vec3(.707,.707,0); float a=T;p.xz*=mat2(cos(a),-sin(a),sin(a),cos(a));for( float i=0.;i<20.;i++){ a=(M/R*6.).x;p.xz*=mat2(cos(a),-sin(a),sin(a),cos(a)); a=(M/R*6.).y;p.xy*=mat2(cos(a),-sin(a),sin(a),cos(a));p-=min(0.,dot(p,b))*b*2.;b=b.zxx;p-=min(0.,dot(p,b))*b*2.;b=b.zxz;p-=min(0.,dot(p,b))*b*2.;b=b.xxy;p=p*1.5-.25;}t+=length(p)/3325.;if(length(p)/3325.<5e-3||t>2.){b=vec3(1);p*=.5;gl_FragColor=vec4(p/length(p)*(t<2.?5./i:i/64.),dot(p,b));break;}}}")

g.compileShader(A);g.attachShader(P,A)
g.linkProgram(P);g.useProgram(P)

g.bindBuffer(A=34962,g.createBuffer())
g.bufferData(A,new Int8Array([-3,1,1,-3,1,1]),35044)

g.enableVertexAttribArray(0)
g.vertexAttribPointer(b=0,2,5120,0,0,0)

g.uniform2f(g.getUniformLocation(P,"R"),a.width*=.8,a.height*=.8)
g.uniform2f(g.getUniformLocation(P,"M"),0,0)

onmousemove=function(e){g.uniform2f(g.getUniformLocation(P,"M"),b=e.pageX,e.pageY)};
(s=function(e){g.uniform1f(g.getUniformLocation(P,"T"),A+=.01);g.drawArrays(6,0,3);requestAnimationFrame(s)})();

f = new AudioContext();
a = f.createScriptProcessor(8192,1,1);
a.connect(f.destination);

a.onaudioprocess = function(e)
{
  q = e.outputBuffer.getChannelData(0);
  
  for(i=8192;i--;)
  {
    q[i] *= .8
    for(j=7;--j;) q[i] += Math.sin(i*(A*50%j)*Math.floor(b/150)*j/326) * Math.sin(i/2606) * Math.sin(A)/j/4;
  }
}