static inline void DrawLine (line2D *line, unsigned int *vram)
{              
    vertex *p1 = &screen_points[line->p1];
    vertex *p2 = &screen_points[line->p2];
                                              
    int dx = p2->x - p1->x;
    int dy = p2->y - p1->y;
                                         
    if (dx==0 && dy==0) return;

    int vx = 1, vy = WIDTH;
    int remainder = 0;

    if (dx<0)
    {
        dx = -dx;
        vx = -vx;
    }
    if (dy<0)
    {
        dy = -dy;
        vy = -vy;
    }

    if (dy>dx)
        remainder = dy;
                                                         
    vram += p1->y*WIDTH + p1->x;
                                                          
    int ix = dx+1;
    int iy = dy+1;
    do
    {
    	while (remainder<=dx)
    	{
    		*vram = c;
    		vram+=vx;
    		remainder += dy;
    		ix--;
    		if (ix==0) return;
    	}
    	*vram = c;
    	vram+=vy;
    	remainder-=dx;
    	iy--;
    }while(iy!=0);
}
