
BLOW_DEFINE_EFFECT1(bloobs,`
	int b1x=width/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/80)*width/3));
	int b1y=height/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/100)*height/3));

	int b2x=width/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/50+1)*width/3));
	int b2y=height/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/70)*height/3));

	int b3x=width/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/130+1)*width/3));
	int b3y=height/2+ ((int)Math.round(Math.sin(Math.PI*fcnt/100+2)*height/3));

	for(int y=0;y<height;y++){
	    for(int x=0;x<width;x++){
		float d1=(b1x-x)*(b1x-x)+(b1y-y)*(b1y-y);
		float d2=(b2x-x)*(b2x-x)+(b2y-y)*(b2y-y);
		float d3=(b3x-x)*(b3x-x)+(b3y-y)*(b3y-y);
		
		if(d1*d1*d2*d2*d3*d3<(float)1e21){
		    buf[y*width+x]=0xFFFFFF;
		}
	    }
	}
')

