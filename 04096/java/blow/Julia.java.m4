

BLOW_DEFINE_EFFECT1(julia,`
		    double z_r,z_i,c_r,c_i;
		    c_r=0.6+0.5*Math.sin(Math.PI*fcnt/40)+0.4*Math.sin(Math.PI*fcnt/197);
		    c_i=0.6*Math.sin(Math.PI*fcnt/11);
		    for(int y=0;y<height;y+=2){
			for(int x=0;x<width;x+=2){
			    int cnt=0;
			    z_r=((double)x/width)*4-2.3d;
			    z_i=((double)y/height)*4-2d;
			    while(cnt++<5){
				double tt=(z_r+c_r)*(z_r+c_r)-(z_i+c_i)*(z_i+c_i);
				z_i=2*(z_r+c_r)*(z_i+c_i);
				z_r=tt;
				if(z_r*z_r+z_i*z_i>4.0){
				    break;
				}
			    }

			    if(z_r*z_r+z_i*z_i<4.0){
				buf[y*width+x]=0xFFFFFF;
			    }
			}
		    }

')
