void setup () {
  size (320,200);
}

void draw() {
  background (0);
  loadPixels();

  int n = 512;
  int s = 10;
  float rot = millis()/1000.0;

  float innerradius = 0.3;
  float outerradius = 1;
  int loop1 = 11;
  int loop2 = 3;
  for (int i=0; i<n; i++) {
    float t = i / (float)n * 3.14 * 2 * loop2;

    float ph = loop1 * t / loop2;
    float q = (outerradius + innerradius * cos(ph));
    float tz = innerradius * sin(ph);
    float tx = q * cos(t);
    float ty = q * sin(t);

    float qx = tx;
    float qy = ty*cos(rot) + tz*sin(rot);
    float qz = tz*cos(rot) - ty*sin(rot);

    int cx = (int)(160 + 6400 * qx / (qz + 100));
    int cy = (int)(100 + 6400 * qy / (qz + 100));
    int cz = (int)(qz * -50 + 100);

    for (int x=0; x<s; x++) 
      for (int y=0; y<s; y++) 
        if (red(pixels[cx+x+(cy+y)*320]) < cz)
          pixels[cx+x+(cy+y)*320] = color(cz,cz,cz);
  }  
  updatePixels();
}

