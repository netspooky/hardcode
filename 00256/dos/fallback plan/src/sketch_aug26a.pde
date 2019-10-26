int[] sintab;
void setup() {
  size(320,200); 
  sintab = new int[256];
  for (int i=0; i<256; i++) { 
    sintab[i] = (int)(sin(i/256.0*PI*2)*127);
    //println("sintab[" + i + "] = " + sintab[i]);
      }
}

void draw() {
  background(0);
  loadPixels();
  int m = millis()/40;
  int cx = m * 4;//128*256 + sintab[(int)(m)&0xFF] * 64;
  int cy = 0;//128*256 + sintab[(int)(m+64)&0xFF] * 64;
  
  int direction = 0;//m;
  int fov = 4;
  for (int x=0; x<320; x++) {
    int slice = direction+x/fov;
    int sx = sintab[(slice + 64)&0xFF];
    int sy = sintab[(slice)&0xFF];
    
//    println("x = " + x + ", slice = " + slice + ", sx = " + sx + ", sy = " + sy);
    int px = cx;
    int py = cy;
    int eye = 63;
    int scany = 199;
    for (int step = 0; step < 256; step++) {
      int hght = ((px>>8)^(py>>8))&0x1F;
      int dst = (eye - hght);
      int dst2 = dst * 256;
      int dst3 = dst2 / (step + 2);
      int h = (199-180) - dst3 * -1;
      //if (x == 319) println("hght = " + hght + ", h = " + h + ", step = " + step + ", dst = " + dst + ", dst2 = " + dst2 + ", dst3 = " + dst3);
//      if (h < scany)
//        println("x = " + x + ", step = " + step + ", h = " + h + "");
      while (h < scany)
        pixels[x+(scany--)*320] = color(h,h,(h)&0xFF);
      px += sx;
      py += sy;
    }
  } 

  updatePixels();
} 
