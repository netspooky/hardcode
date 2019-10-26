
int sintabsize = 2048;
int sintab[] = new int[sintabsize];

void setup() {
  size(320,240);

  for (int i=0; i<sintabsize; i++) 
    sintab[i] = (int)(sin( i * PI * 2.0 / sintabsize ) * 127.0); 
}

void draw()
{
  int m = millis();
  int eye_x = 20000;//(sintab[(millis() / 32 + sintabsize/4) % sintabsize] - 127) * 128;
  int eye_y = 20000;//(sintab[(millis() / 32)  % sintabsize] - 127) * 128;
  int eye_z = m * 32;

  loadPixels();

  int f = m / 10;

  for (int y=0; y<height; y++) 
  {
    for (int x=0; x<width; x++) 
    {
      int stepsize = 512; // grid size

      int dx = (x-160) * stepsize /  160;
      int dy = (y-120) * stepsize / -120;
      int dz = stepsize;

      int ray_direction_x = ((dx * sintab[(f+sintabsize/4) % sintabsize]) - (dz * sintab[(f) % sintabsize])) / 127;
      int ray_direction_y = dy;
      int ray_direction_z = ((dz * sintab[(f+sintabsize/4) % sintabsize]) + (dx * sintab[(f) % sintabsize])) / 127;

      int ray_position_x = eye_x;
      int ray_position_y = eye_y;
      int ray_position_z = eye_z;

      int i = 0;
      int shift = 0;
      for (int step=0; step<128; step++) 
      {
        int cx = (ray_position_x >> 8) & 0xFF;  
        int cy = (ray_position_y >> 8) & 0xFF;  
        int cz = (ray_position_z >> 8) & 0xFF;  

        i += cx ^ ((cy ^ cz) + shift);

        ray_position_x += ray_direction_x;
        ray_position_y += ray_direction_y;
        ray_position_z += ray_direction_z;
      }
      i = i >> 7;
      int d = 1;
      if ( y < 32 )  d = (8 - (y / 4)); 
      if ( y > 208 ) d = ((y - 204) / 4); 
      pixels[ y * 320 + x ] = color(i / d);
    }
  }

  updatePixels();
}

