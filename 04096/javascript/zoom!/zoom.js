
$=function(el){return document.getElementById(el);}
rnd=function(mx){return Math.round(Math.random()*mx);}
toHex=function(v){var res=Number(v).toString(16);return res.length==1?'0'+res:res;}
run=function(){render();setTimeout(run,50);}
var sinTable=[];c=2*Math.PI/1024;for(i=0;i<1024;i++)sinTable[i]=Math.sin(c*i);var colorTable=[];for(i=0;i<256;i++)colorTable[i]='#'+toHex(i)+toHex(i)+toHex(i);var cells=[];var guidingRow=[];var guidingColumn=[];var table=null;var sizeX=48;var sizeY=24;var cellWidth=100/sizeX;cellHeight=100/sizeY;var i1=i2=i3=offsetX=offsetY=0;var logo=[[0,0,0,191,0,191,191,191,63,0,191,191,191,63,0,0],[0,0,0,191,0,0,0,0,191,0,0,0,0,191,0,0],[63,191,191,191,0,63,191,191,191,0,0,191,191,0,0,0],[191,0,0,191,0,191,0,0,0,0,0,0,0,191,0,0],[191,0,0,191,0,191,0,0,0,0,0,0,0,191,0,0],[63,191,191,191,0,191,191,191,191,0,191,191,191,63,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]];var lw=logo[0].length;var lh=logo.length;createMatrix=function(el){table=el.appendChild(document.createElement('table'));tbody=table.appendChild(document.createElement('tbody'));for(y=0;y<sizeY;y++){row=tbody.appendChild(document.createElement('tr'));cells[y]=[];for(x=0;x<sizeX;x++){cells[y][x]=row.appendChild(document.createElement('td'));cells[y][x].style.background=colorTable[rnd(64)+logo[y%8][x%16]];}}
for(x=0;x<sizeX;x++)guidingRow[x]=cells[0][x];for(y=0;y<sizeY;y++)guidingColumn[y]=cells[y][0];}
render=function(){i1=i1+=8;i2+=6;i3+=4;i1=i1&1023;i2=i2&1023;i3=i3&1023;offsetX+=0.5+sinTable[i1]/3.0;offsetY+=0.2+sinTable[i3]/2.0;while(offsetX>=cellWidth){offsetX-=cellWidth;for(var y=0;y<sizeY;y++){last=cells[y].pop();first=cells[y][0];p=last.parentNode;p.removeChild(last);p.insertBefore(last,first);cells[y].unshift(last);}}
while(offsetX<0){offsetX+=cellWidth;for(var y=0;y<sizeY;y++){first=cells[y].shift();p=first.parentNode;p.removeChild(first);p.appendChild(first);cells[y].push(first);}}
while(offsetY>=cellHeight){row=cells.pop();last=row[0].parentNode;first=cells[0][0].parentNode;b=last.parentNode;b.removeChild(last);b.insertBefore(last,first);cells.unshift(row);offsetY-=cellHeight;}
while(offsetY<0){offsetY+=cellHeight;row=cells.shift();first=row[0].parentNode;b=first.parentNode;b.removeChild(first);b.appendChild(first);cells.push(row);}
wsize=windowSize();size=sinTable[i1]*30+45;twidth=(100+size)/100*wsize.w;theight=(100+size)/100*wsize.h;cwidth=twidth/sizeX;cheight=theight/sizeY;for(last=tmp=x=0;x<sizeX;x++){tmp+=cwidth;guidingRow[x].style.width=Math.floor(tmp-last)+"px";last=Math.floor(tmp);}
table.style.width=last+"px";for(last=tmp=y=0;y<sizeY;y++){tmp+=cheight;guidingColumn[y].style.height=Math.floor(tmp-last)+"px";last=Math.floor(tmp);}
table.style.height=last+"px";table.style.top=-Math.floor(((theight-wsize.h)/2)-offsetY/100*theight)+"px";table.style.left=-Math.floor(((twidth-wsize.w)/2)-offsetX/100*twidth)+"px";}
windowSize=function()
{w=h=0;if(!window.innerWidth)
{if(!(document.documentElement.clientWidth==0))
{w=document.documentElement.clientWidth;h=document.documentElement.clientHeight;}
else
{w=document.body.clientWidth;h=document.body.clientHeight;}}
else
{w=window.innerWidth;h=window.innerHeight;}
return{w:w,h:h};}