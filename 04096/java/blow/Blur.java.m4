BLOW_DEFINE_EFFECT2(blur,`
	int i=width+1;
	for(int y=height-2;y>0;y--){
	    for(int x=width-2;x>0;x--){
		int rb=(src[i-width]&0xFF00FF);
		rb+=(src[i+width]&0xFF00FF);
		rb+=(src[i-1]&0xFF00FF);
		rb+=(src[i+1]&0xFF00FF);
		rb/=4;
		rb&=0xFF00FF;
		int g=(src[i-width]&0xFF00);
		g+=(src[i+width]&0xFF00);
		g+=(src[i-1]&0xFF00);
		g+=(src[i+1]&0xFF00);
		g/=4;
		g&=0x00FF00;
		dest[i++]=rb|g;
	    }
	    i+=2;
	}
')