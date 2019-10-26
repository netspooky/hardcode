
BLOW_DEFINE_EFFECT1(fade,`
	for(int i=0;i<buf.length;i++){
	    int r=(buf[i]&0xFF0000);
	    int g=(buf[i]&0xFF00);
	    int b=(buf[i]&0xFF);
	    if(r<0x80000){r=0;}else{r-=0x80000;}
	    if(g<0x800){g=0;}else{g-=0x800;}
	    if(b<0x8){b=0;}else{b-=0x8;}
	    buf[i]=r|g|b;
	}
')
