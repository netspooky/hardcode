void setup() {
  size(320,240);
}

void draw() {
  float t = millis() / 1000.0;
  loadPixels();
  float cx = sin(t * 0.9) * 0.5;
  float cy = cos(t * 0.5 + 1.3) * 0.5;
  for (int y=0; y<240; y++) {
    for (int x=0; x<320; x++) {
      float px = x / 320.0 * 4.0 - 2.0;
      float py = y / 240.0 * 4.0 - 2.0;
      int i = 0;
      for (; i<32; i++) {
        float tx = cx + px * px - py * py;
        float ty = cy + py * px + px * py;
        px = tx;
        py = ty;
        if (px*px+py*py > 100) break;
      }
      int angle = (x-160) * (y-120) + millis() * 10;
      int c = (( i * 8 ) & 0xFF) ^ (( i * 8 + angle / 64 ) &0xFF);
      pixels[x + y * 320] = color(c,0,0);
    }
  }
  updatePixels();
}


