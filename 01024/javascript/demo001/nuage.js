h=[],s=0,kp=0,g=Math.abs
function _(){return parseInt(g(Math.random()*600))}function d(z,y,x,j){i=w("b",1);w(w(z[y],2),4,i);w(i,4,x)
return i}function w(z,y,x){return y<1?n.getElementsByTagName(z):y<2?n.createElement(z):y<3?n.createTextNode(z):y<4?x.childNodes[z]:x.appendChild(z)}function p(){for(j in h){i=h[j];with(i){
if(s){i.t+=t<d?1:-1;i.h+=h<f?1:-1;s||i.C++>2^9&&(i.C=_())
t==d&&(i.d=_());h==f&&(i.f=_())}k=s?e:f;k.style.color="#"+C;k.style.top=g(t)%600+"px";k.style.left=g(h)%800+"px"
}}q.className=(s=!s)||"f";}addEventListener("load",function(){n=document
q=w("body",0)[0]
q.innerHTML="<p class=a></p><p class=b></p>";a=w(0,3,q);b=w(1,3,q)
$=n.documentElement.innerHTML.replace(/[^a-z]/gi," ").split(" ")
$$={}
for(c in $)if($[c].length>2&&!$$[c]){h.push({
t:_(),d:_(),C:_(),h:_(),f:_(),e:d($,c,a),f:d($,c,b)});$$[$[c]++]=1}
f=w("style",1)
w(w("body *{position:absolute;display:block;}body{width:800px;height:600px;}.b,.f .a{display:none;}.f .b{display:block;}",2),4,f);
w(f,4,w("head",0)[0])
setInterval(p,9)
},0)