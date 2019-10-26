//------------------------------------------
//No optim by supressing '+' Closure Compiler must do it
e =
 "attribute vec4 p,n;" +
 "uniform mat4 r;" +
 "varying vec3 c,y;" +
 "void main()" +
 "{" +
	"c.x=floor(p.w);"+
	"c=vec3((c.x)+n.w*3.14,c.x,fract(p.w));"+
	"y=cross(n.xyz,vec3(0,1,0));"+
   "gl_Position=r*vec4(p.xyz+(y*sin(c.x)+cross(y, n.xyz)*cos(c.x))*5.*c.z,1.);" +
 "}"

x =
"precision mediump float;"+
 "varying vec3 c;" +
 "void main()" +
 "{" +
   "gl_FragColor=vec4(.2,(cos(c.y*2.)+1.)*.4,0.,1.);" +
 "}"

//--------------------------------------------

top.onload = function s()
{
	l = document;
    c = l.createElement('canvas');
	c.width = l.width;
    c.height = l.height;
	l.body.appendChild(c);
	
	for(k in g = c.getContext('experimental-webgl'))
		top[k[0]+k[6]] = top[k] = g[k].bind && g[k].bind(g);

	//enable(0xB71);
	
	bf(0x8892, cB());
    bD(0x8892,32000,0x88E8);
	
	bf(0x8893, cB());
	bD(0x8893,12000,0x88E8);
	
	//*******************
	
	c = cP();
	
	l = cS(0x8B31);
	sS(l, e);
	ce(l);
	aS(c, l);
	
	//console.log(getShaderInfoLog(l));
	
	l = cS(0x8B30);
	sS(l, x);
	ce(l);
	
	//console.log(getShaderInfoLog(shader));
	
	bt(c, aS(c, l), "p");
	bt(c, 1, "n");
	
	eV(lo(c));
	eV(1);
	
	uniformMatrix4fv(gf(c, "r"), ug(c), [
				0.8, 0,0,0,
				0,  1.4, 0, 0,
				0, 0, -1.1, -1,
				0, 0, -20.7, 0
				]);
				
	//----------------------
	x = 1;
    
    top.setInterval(function()
	{
		co(clear(0x4100),.25,.4,.4);
		
		
		e = [];
		id = [];

		c= Math.min(x, 200);
		a = x - c;
		
		var x0,y0,z0,x1,y1,z1;
		r = 0.006;
		
		x0 = z0 = y0 = 0.1;


		for(i = 0; i < x-1; ++i)
		{
			y1 = y0 + r * (x0 * (28.0 - z0) - y0);
			z1 = z0 + r * (x0 * y0 - 2.7 * z0);
			x1 = x0 + r * 13.0 * (y0 - x0);
			

			if(i >=  a)
			{
				l = i - a;
				b = l/(c);
				
				if(l >  c-15)
					b = (c - l) / 10;
				
				for(j=0; j < 5; ++j)
				{
					e.push(x1, y1, z1-70,  b + j,  x1-x0,y1-y0,z1-z0, x*0.01);
					id.push(j + l*5, j + l*5+ 5,  j*(j<4) + l*5 + (5+(j<4)));
				}
			}
			
			x0 = x1;
			y0 = y1;
			z0 = z1;
		}
				
		x0 = bufferSubData;
		x0(0x8892, 0, new Float32Array(e));
		x0(0x8893, 0, new Uint16Array(id));
		
		
		vA(0, 4, 0x1406, 0, 32, 0);
		vA(1, 4, 0x1406, 1, 32, 16);
		de(0x4, c*30, 0x1403, 0);
		
		x = x+1%10000;
	}, 16);
}