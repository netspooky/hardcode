
function degreeToRadian(degree){
	var i = 3.14;
	i = degree / 180 * i;
	return i;
}

function Line(p0, p1, col, c)
{
	var delta_x = p1.x - p0.x;
	var delta_y = p1.y - p0.y;
	if (delta_x <0)
	{
		Line(p1,p0, col, c);
		return;
	}
	   /* 0 <= Slope <= 1 */
	   if ((0 <= delta_y) && (delta_y <= delta_x))
	   {
	   draw_line_shallow(p0, p1, delta_x, delta_y, 1, col, c);
	   return;
	   }
	   /* -1 <= Slope < 0 */
		if ((-delta_y <= delta_x) && (delta_y < 0))
		{
			draw_line_shallow(p0, p1, delta_x, -delta_y, -1, col, c);
			return;
		}
		/* 1 < Slope (or vertical) */
		if (delta_y > delta_x)
		{
			draw_line_steep(p0, p1, delta_x, delta_y, 1, col, c);
			return;
		}
		/* Slope < -1 (or vertical) */
		if (-delta_y > delta_x)
		{ /* Note p0.y > p1.y, so draw in reverse order */
			draw_line_steep(p1, p0, delta_x, -delta_y, -1, col, c);
			return;
		}
}
/* Draws a line where |slope|<=1 using Bresenham’s algorithm by  * incrementing along the X coordinate  */
function draw_line_shallow(p0, p1, delta_x, delta_y, dir, col, c)
{
	var x, y;
    var eps = 0;
	y = p0.y;
	var i=0;
	var xa = parseInt(delta_x*0.2);
	for (x = p0.x; x <= p1.x; x++)
	{
		eps +=  delta_y;
		if(x%xa==0)
		{
			Plot(x, y, col[i], c);
			i++;
		}
		if ((eps+eps) >= delta_x)
		{
			y += dir;
			eps -= delta_x;
		}
	}
	//Plot(p1.x, p1.y, col);	
	return;
}
/* Draws a line where |slope|>1 (or vertical) using Bresenham’s   * algorithm by incrementing along the Y coordinate.  */
function draw_line_steep(p0, p1, delta_x, delta_y, dir, col, c)
{
	var x, y;
	var eps = 0;
	x = p0.x;
	var i=0;
	var ya = parseInt(delta_y*0.2);
	for (y = p0.y; y <= p1.y; y++)
	{
		eps += delta_x;
		if(y%ya==0)
		{
			Plot(x, y, col[i], c);
			i++;
		}
		if ((eps+eps) >= delta_y)
		{
			x += dir;
			eps -= delta_y;
		}
	}

	//Plot(p1.x, p1.y, col);
	return; 
}
