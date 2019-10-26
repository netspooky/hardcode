#include "intro.h"
    
void print(int x, int y, char *msg, int color)
{
    while(*msg) {
        putchar(x, y, *msg, color);
        msg++;
        x+=8;
    }
}

void render(const int frame)
{
    int x, y;
    int time, time2;
    int par_s;
    int par_t;
    int cx1, cy1, cz1, cx2, cy2, cz2;
    int temp, color;

        if (frame < 128) {
            
            if (frame < 64)
                color = frame;
            else
                color = 127 - frame;
            clear_buffer();
            print(64, 96, "an intro by orbitaldecay", color);
        
        } else if (frame < 256) {

            make_noise();
            print(132, 96, "AZIMUTH", 63);
        
        } else {
            
            time = (frame - 256) % 1280;
            
            time2 = time << 3;
            checker_floor(time);
                
            par_t = 0;
            do {
                par_s = 0;
                do {
                    if (time >= 960) {
                
                        cx1 = cos(par_s, sin(time2 + (par_t<<1), 10) + 30);
                        cy1 = sin(par_s, sin(time2 + (par_t<<1), 10) + 30);
                        cz1 = par_t - 128;

                        cx2 = cos(par_s, 20) + cos(par_t + time, 40);
                        cy2 = sin(par_s, 20) + sin(par_t + time, 40);
                        cz2 = par_t - 128;
                        
                    } else if (time >= 640) {
                
                        cx1 = cos(par_s, 60 + cos(par_t, 30));
                        cy1 = sin(par_s, 60 + cos(par_t, 30));
                        cz1 = sin(par_t, 30);

                        cx2 = cos(par_s, sin(time2 + (par_t<<1), 10) + 30);
                        cy2 = sin(par_s, sin(time2 + (par_t<<1), 10) + 30);
                        cz2 = par_t - 128;
                        
                    } else if (time >= 320) {
                            
                        cx1 = cos(par_s + time, cos(par_t, 80));
                        cy1 = sin(par_s + time, cos(par_t, 80));
                        cz1 = sin(par_t, 80);
            
                        cx2 = cos(par_s, 60 + cos(par_t, 30));
                        cy2 = sin(par_s, 60 + cos(par_t, 30));
                        cz2 = sin(par_t, 30);
                            
                    } else {
                
                        cx1 = cos(par_s, 20) + cos(par_t + time, 40);
                        cy1 = sin(par_s, 20) + sin(par_t + time, 40);
                        cz1 = par_t - 128;
                            
                        cx2 = cos(par_s + time, cos(par_t, 80));
                        cy2 = sin(par_s + time, cos(par_t, 80));
                        cz2 = sin(par_t, 80);
                    }

                    temp = time % 320;
                    if (temp > 256) {
                        
                        temp -= 256;
                        cx1 = ((64 - temp) * cx1 + temp * cx2) >> 6;
                        cy1 = ((64 - temp) * cy1 + temp * cy2) >> 6;
                        cz1 = ((64 - temp) * cz1 + temp * cz2) >> 6;
                    
                    }                        
                    
                    x = cos(time, cx1) + sin(time, cz1) + 160;
                    y = cy1 + 100;
                    star(x + y * 320);
                    
                    par_s += 16;
                } while (par_s < 256);

                par_t += 16;
            } while (par_t < 256);
        }
    
}
