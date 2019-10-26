function Cube(x, y, size, change)
{
	this.unit = 1*size;
	this.ua =change;
	this.Theta = 0.1; this.L = 40; this.POV = 500; this.Offset = 100; this.XOffset=100+x; this.YOffset=100+y;
    this.Px  = new Array(-this.L, -this.L,  this.L,  this.L, -this.L, -this.L, this.L,  this.L);     //real x-coord, 8 pts
    this.Py  = new Array(-this.L,  this.L,  this.L, -this.L, -this.L,  this.L, this.L, -this.L);     //real y-coord, 8 pts
    this.Pz  = new Array(-this.L, -this.L, -this.L, -this.L,  this.L,  this.L, this.L,  this.L);     //real z-coord, 8 pts
    this.PPx = new Array(-this.L, -this.L,  this.L,  this.L, -this.L, -this.L, this.L,  this.L);     //projected x-coord, 8 pts
    this.PPy = new Array(-this.L,  this.L,  this.L, -this.L, -this.L,  this.L, this.L, -this.L);     //projected y-coord, 8 pts
	this.Els = new Array(12)
	this.Lines = new Array(12);
    this.XP = new Array(4);
    this.YP = new Array(4);
    this.V1 = new Array(0, 0, 4, 4, 7, 7, 3, 3, 2, 2, 3, 3);   //vertex1
    this.V2 = new Array(3, 2, 0, 1, 4, 5, 7, 6, 6, 5, 0, 4);   //vertex2
    this.V3 = new Array(2, 1, 1, 5, 5, 6, 6, 2, 5, 1, 4, 7);   //vertex3
    this.V4 = new Array(12);                    //Average Z of all 3 vertices 
    this.V5 = new Array(12);                    //DotProduct of Normal and POV
	this.t = null;
}
function cubeLoad(c, color)
{
	for(var i = 0;i<12;i++)
	{
		c.Els[i] = new Array(4);
		c.Lines[i] = new Array(8);
		for(var p=0;p<8;p++)
			{
			c.Els[i][p] = document.createElement("text");
			c.Els[i][p].id = i+""+p;
			c.Els[i][p].innerHTML = "#";
			c.Els[i][p].style['position'] = 'absolute';
			c.Els[i][p].style['left'] = "0px";
			c.Els[i][p].style['top'] = "0px";
			c.Els[i][p].style['color'] = color;
			c.Lines[i][p] = new Array(3);
			for(var z=0;z<5;z++)
			{
				c.Lines[i][p][z] = document.createElement("text");
				c.Lines[i][p][z].id = i+""+p+""+z;
				if(i==1&&p==4)
					c.Lines[i][p][z].innerHTML = "*";
				else if (i==2 && p==5)
					c.Lines[i][p][z].innerHTML = "*";
				else
					c.Lines[i][p][z].innerHTML = "o";
				c.Lines[i][p][z].style['position'] = 'absolute';
				c.Lines[i][p][z].style['color'] = color;
				c.Lines[i][p][z].style['left'] = z+"px";
				c.Lines[i][p][z].style['top'] = p+"px";
				document.body.insertBefore(c.Lines[i][p][z], document.body.lastChild);
			}
			document.body.insertBefore(c.Els[i][p], document.body.lastChild);
		}
	}
}		
function Plot(x, y, element, c)
{
	try{
		element.style['left'] = x*c.unit+"px";
		element.style['top'] = y*c.unit+"px";
	}
	catch(ex)
	{}
}
cubes = new Array();
function cubeinit(x, y, size, color, change)
{
	var c = new Cube(x, y, size, change);
	cubes.push(c);
	cubeLoad(c, color);
	t = setInterval('Pipeline();', 100);
}
//////////NYTT/////////////
function Pipeline()
{
	for (var i in cubes)
    {
		BackFaceCulling(cubes[i]);
		ApplyProjection(cubes[i]);
		DrawCube(cubes[i]);
		RotatePoints(cubes[i]);
		cubes[i].unit+=cubes[i].ua;
		if(cubes[i].unit >=3 || cubes[i].unit<=1)
			cubes[i].ua*=-1;
	}
}/*Theta = 0.015*/

	
function RotatePoints(c) 
    {
    for (wr=0; wr < 8; wr++) 
        {
        oldY = c.Py[wr]; oldZ = c.Pz[wr];
        c.Py[wr] = oldY * Math.cos(c.Theta) - oldZ * Math.sin(c.Theta);  //rotate about X
        c.Pz[wr] = oldY * Math.sin(c.Theta) + oldZ * Math.cos(c.Theta);  //rotate about X

        oldX = c.Px[wr]; oldZ = c.Pz[wr];
        c.Px[wr] = oldZ * Math.sin(c.Theta) + oldX * Math.cos(c.Theta);  //rotate about Y
        c.Pz[wr] = oldZ * Math.cos(c.Theta) - oldX * Math.sin(c.Theta);  //rotate about Y

        oldX = c.Px[wr]; oldY = c.Py[wr];
        c.Px[wr] = oldX * Math.cos(c.Theta) - oldY * Math.sin(c.Theta);  //rotate about Z
        c.Py[wr] = oldX * Math.sin(c.Theta) + oldY * Math.cos(c.Theta);  //rotate about Z
        }
    }
		
function BackFaceCulling(c) 
    {
    for (wb=0; wb < 12 ; wb++) 
        {
        // Cross Product
        CPX1 = c.Px[c.V2[wb]] - c.Px[c.V1[wb]];
        CPY1 = c.Py[c.V2[wb]] - c.Py[c.V1[wb]];
        CPZ1 = c.Pz[c.V2[wb]] - c.Pz[c.V1[wb]];
        CPX2 = c.Px[c.V3[wb]] - c.Px[c.V1[wb]];
        CPY2 = c.Py[c.V3[wb]] - c.Py[c.V1[wb]];
        CPZ2 = c.Pz[c.V3[wb]] - c.Pz[c.V1[wb]];
        DPX = CPY1 * CPZ2 - CPY2 * CPZ1;
        DPY = CPX2 * CPZ1 - CPX1 * CPZ2;
        DPZ = CPX1 * CPY2 - CPX2 * CPY1;
        // DotProduct uses POV vector 0,0,POV  as x1,y1,z1
        c.V5[wb] = 0 * DPX + 0 * DPY + c.POV * DPZ;
        }
    }
function ApplyProjection(c) 
    {
       for (wp=0; wp < 8 ; wp++) {
          c.PPx[wp] = c.Px[wp];
          c.PPy[wp] = c.Py[wp];
       }
    }
	
	function DrawCube(c) 
    {

	var co = 0;
		var sx=0;
		var sy=0;
		if(c.V5[1]<=0 && (c.Lines[1][4][0].innerHTML=="*" || c.Lines[1][4][0].innerHTML=="o"))
			for(var i=0;i<5;i++)
				c.Lines[1][4][i].innerHTML=c.Lines[2][5][i].innerHTML="";
		else if(c.V5[1]>0 && c.Lines[1][4][0].innerHTML=="")
			for(var i=0;i<5;i++)
			{
				c.Lines[1][4][i].innerHTML="*";
				c.Lines[2][5][i].innerHTML="*";
			}
		for (wd=0; wd < 12; wd++) 
        {
	        c.XP[0]=c.PPx[c.V1[wd]]+c.XOffset;c.XP[1]=c.PPx[c.V2[wd]]+c.XOffset;c.XP[2]=c.PPx[c.V3[wd]]+c.XOffset;
	        c.YP[0]=c.PPy[c.V1[wd]]+c.YOffset;c.YP[1]=c.PPy[c.V2[wd]]+c.YOffset;c.YP[2]=c.PPy[c.V3[wd]]+c.YOffset;
	        c.XP[0]=Math.floor(c.XP[0]);
	        c.XP[1]=Math.floor(c.XP[1]);
	        c.XP[2]=Math.floor(c.XP[2]);
	        c.YP[0]=Math.floor(c.YP[0]);
	        c.YP[1]=Math.floor(c.YP[1]);
	        c.YP[2]=Math.floor(c.YP[2]);
	        c.XP[3]=c.XP[0]; c.YP[3]=c.YP[0];
	        if (c.V5[wd]>0)
	        {
				if(wd%2==0)
				{
					Line(new point(c.XP[0], c.YP[0]), new point(c.XP[1], c.YP[1]), c.Lines[co][0], c);
					Line(new point(c.XP[1], c.YP[1]), new point(c.XP[2], c.YP[2]), c.Lines[co][1], c);
				}
				else
				{
					Line(new point(c.XP[1], c.YP[1]), new point(c.XP[2], c.YP[2]), c.Lines[co][2], c);
					Line(new point(c.XP[2], c.YP[2]), new point(c.XP[3], c.YP[3]), c.Lines[co][3], c);
				}
				co++;
				if(wd<2)
				{
					if(wd%2==0)
					{
						Line(new point(c.XP[2], c.YP[2]), new point(c.XP[3], c.YP[3]), c.Lines[co][4], c);
						sx = c.XP[1];
						sy = c.YP[1];
					}
					else
					{
						Line(new point(sx, sy), new point(c.XP[2], c.YP[2]), c.Lines[co][5], c);					
					}
				}
				
				
				for(var i= 0;i<4;i++)
				{
					c.Els[wd][i].style['left'] = c.XP[i]*c.unit+"px";
					c.Els[wd][i].style['top'] = c.YP[i]*c.unit+"px";
					c.Els[wd][i].innerHTML="o";
				}
				
			}
			else
			{
				for(var i= 0;i<4;i++)
				{
					c.Els[wd][i].innerHTML="";
				}
			}			
        }
    }   