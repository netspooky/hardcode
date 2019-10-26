
C=c.getContext`2d`;C.fillStyle="tan";Z="charCodeAt";b=(x,y,w)=>C.strokeRect(x+.5,y+.5,w,w,C.fillRect(x,y,w,w));t=(x,y,t)=>{[...t+""].map((k,z)=>{for(k="⭪⒓犣㢣䧭㧏篋┧篯积寪㭫㢎璗扎⒗筯"[Z](k[Z](i=0)-48);i<15;k>>=1,i++)if(k&1)b(4*z+x+i%3,y+i/3|0,.01)})}
l=(a,B,c,d,z=Math.abs)=>{for(let g,x=z(c-a),y=z(d-B),r=(a<c)*2-1,q=(B<d)*2-1,e=(x>y?x:-y)/2;a!=c||B!=d;a+=g>-x?r+(e-=y)*0:0,B+=g<y?q+(e+=x)*0:0)b(a,B,.05,g=e)}
_=[];[...P="ŀƉŢļĖñĝŃũƏƵǛȁƮɅǷǑƬƭĠņŬƒƸǞȄǏǵȿƦƧƨģŉůƕƻǡȇĴŚſİçĎĦŌŲƘƾǤȊÄÃÂ+yĩŏŵƛǁǧȍÊÉÈ¡{1ĬŒŸƞǄǪȐ"].map(y=>_[y[Z](0)]=1e-9);for(i=0;i<6;i++)_[i]=[[6,3,3],[0,5,5]].map(n=>68+8*n[i%3]*(-1)**~~((i+(n[0]>5))/3))
d=e=>{requestAnimationFrame(d);b(-1,-1,350);for(var i=0;i<36;i++){let{0:x,1:y}=_[I=i/6|0],{0:X,1:Y}=_[i%6];l(x,y,X,Y);b(X-12,Y-12,24);t(X,Y-2,i%6);[...I+":;<=>?@"].map((l,j)=>t(146+24*I,50+8*j,l))}
for(i=6;i<722;i++)if(_[i]){b(A=i%38*8,B=(i/38|0)*8,8);t(A+1,B+2,_[i]|0)}};d(S=6);c.onmousedown=e=>S=~~(e.offsetX/24)+38*~~(e.offsetY/24);c.onmouseup=e=>S=6;c.onmousemove=e=>{_[S]=_[S]?Math.min(99,Math.max(1e-9,~~(_[S]-e.movementY))):0;location.hash=[...P].map(y=>~~_[y[Z](0)]).join(",")}
location.hash.substr(1).split(",").map((x,i)=>_[P[Z](i)]=x?x:1e-9);K="q2w3er5t6y7ui9o0p[=]B\\";T=0;$=Array(22).fill([0,-9]);F=Array(132);c.onkeyup=c.onkeydown=e=>$[z=K.indexOf(e.key[0])]=[+(e.type[3]=="d"),e.repeat?$[z][1]:T];L=(o,x)=>_[P[Z](13*o+x)];D=(G=new AudioContext).createScriptProcessor(2048,0,1);D.connect(G.destination);D.onaudioprocess=e=>{for(i=0;i<2048;i++)
e.outputBuffer.getChannelData(0)[i]=(t=>{for(k=out=0;k<22;k++)
for(q=0,a=L(q,6)/33,N=t-$[k][1];$[k][0]&&q<6;q++)
if(L(q,12)>.1)
out+=L(q,12)/900*(F[k*6+q]=(N<a?1*N/a:Math.max(L(q,8)/99,1-(N-a)*33/L(q,7)))*Math.sin((L(q,9)>2?F.slice(k*6,k*6+6).reduce((x,y,i)=>x+L(q,i)/33*y,0)*L(q,9)/99:0)+(L(q,11)/99+L(q,10))*t*2765*2**((k-9)/12)))
return out;})(T+=1/G.sampleRate);}