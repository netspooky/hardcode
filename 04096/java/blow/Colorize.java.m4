BLOW_DEFINE_EFFECT2(colorize,`
int ar=(int)Math.round((1.0+Math.sin((float)fcnt/30))*128);
int ag=(int)Math.round((1.0+Math.sin((float)fcnt/40))*128);
int ab=(int)Math.round((1.0+Math.sin((float)fcnt/60))*128);

for(int i=0;i<width*height;i++){
   int r=((((src[i]&0xFF0000)>>8)*ar))&0xFF0000;
   int g=(((src[i]&0xFF00)*ag)>>8)&0xFF00;
   int b=(((src[i]&0xFF)*ab)>>8)&0xFF;
   dest[i]=r|g|b;
}

')
