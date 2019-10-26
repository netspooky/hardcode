#include "incs.h"

int checklooser(SDL_Rect* ball, int* uc, int* cc)
{ 

        if ((ball->x) <= PAD_LEFT) { /* did user miss the ball? */               
                ball->x = (int)(WINDOW_WIDTH/2);
                ball->y = (int)(WINDOW_HEIGHT/2);                
                (*cc)++;
        } 
        if ((ball->x) >= (WINDOW_WIDTH-BALL_WIDTH)) { /* did cpu miss the ball? */               
                ball->x = (int)(WINDOW_WIDTH/2);
                ball->y = (int)(WINDOW_HEIGHT/2);                
                (*uc)++;
        } 
        return 0;
        
}

int bounce(SDL_Rect* ball,SDL_Rect* pad1,SDL_Rect* pad2, int* xdir, int* ydir)
{
        /* check if someone wanna bounce the ball. */
        
        if ( ((ball->x)<=(PAD_LEFT+PAD_WIDTH)) && ( ((ball->y) >= (pad1->y)) && ((ball->y) <= (pad1->y)+PAD_HEIGHT))) {
                *xdir = BALL_MOVEXP; /* user bounced! */                
        } else if (((ball->x) >= PAD_RIGHT-BALL_WIDTH) && ( ((ball->y) >= (pad2->y)) && ((ball->y)-BALL_HEIGHT <= (pad2->y)+PAD_HEIGHT))) {        
                *xdir = BALL_MOVEXM; /* cpu bounced! */                
        } 
        
        ball->x = (ball->x) + *xdir;
        ball->y = (ball->y) + *ydir;

        if (ball->y<=0) {
                *ydir = BALL_MOVEYP;
        } else if (ball->y>=(WINDOW_HEIGHT-BALL_HEIGHT)) {
                *ydir = BALL_MOVEYM;
        }       
        return 0;
}

int main(int argc, char *argv[])
{
    SDL_Surface *screen;
    SDL_Surface *bmpn;
    int cpu_score = 0;
    SDL_Rect ball_rect = {320,240,BALL_WIDTH,BALL_HEIGHT};
    int ball_xdir = 1; /* set to -1 to change dir. */
    int ball_ydir = 1; /* set to -1 to change dir. */
    int mouse_x,mouse_y;
    SDL_Rect cpu_rect = {PAD_RIGHT, 320, PAD_WIDTH, PAD_HEIGHT};

    int usr_score = 0;    
    SDL_Rect usr_rect = {PAD_LEFT, 320, PAD_WIDTH, PAD_HEIGHT};    
    
    int run=1;
    SDL_Event event;
    char score_str[100];
    int ftimer = 1;
    int Ticks = 0;
    
    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_NOPARACHUTE);
    screen = SDL_SetVideoMode(WINDOW_WIDTH,WINDOW_HEIGHT,WINDOW_BPP,SDL_HWSURFACE|SDL_DOUBLEBUF);
    SDL_WM_SetCaption("asm compo 11 - late night silly pong. (Created by Saida)",NULL);
    Uint32 padcolor = SDL_MapRGB(screen->format,255,255,255);
    Uint32 ballcolor = SDL_MapRGB(screen->format,255,255,0);
    
    while(run)
	{
		if(SDL_PollEvent(&event)) {	
          if(event.key.state == SDL_PRESSED) { 
            switch(event.key.keysym.sym) {
                        case SDLK_ESCAPE: run = 0; break; 
                        default: break;
            }                        
          }
        }
        
        SDL_PumpEvents();
        SDL_GetMouseState(NULL, &mouse_y);
        if ( (mouse_y>0) && (mouse_y<WINDOW_HEIGHT-PAD_HEIGHT)) {
                usr_rect.y = mouse_y;
        }
        
        ball_rect.x = ball_rect.x + ball_xdir;
        ball_rect.y = (ball_rect.y + ball_ydir) + (int)( 2*sin(ftimer*(3.1415/180))) + (int)( 3*sin(ball_rect.x*(3.1415/180)));
        
        /* studsa */        
        bounce(&ball_rect,&usr_rect,&cpu_rect, &ball_xdir, &ball_ydir);        
        /* kolla om vi har looser */
        checklooser(&ball_rect,&usr_score,&cpu_score);


        /* move computers pad */
        if ((cpu_rect.y < ball_rect.y-15) && cpu_rect.y<WINDOW_HEIGHT-PAD_HEIGHT) {
                cpu_rect.y++;
                cpu_rect.y++;
        } else if (cpu_rect.y>0){
                cpu_rect.y--;
                cpu_rect.y--;                
        }        
        
        SDL_FillRect(screen,NULL,0);                
        SDL_FillRect(screen,&usr_rect,padcolor);
        SDL_FillRect(screen,&cpu_rect,padcolor);        
        SDL_FillRect(screen,&ball_rect,ballcolor);

        sprintf(score_str, "%d - %d",usr_score,cpu_score); 
        DrawString(screen,300,10,score_str);

        SDL_Flip(screen);		
        
        ftimer++;
        ball_rect.w = BALL_WIDTH;
        ball_rect.h = BALL_HEIGHT;    
     

       	while (SDL_GetTicks() <= Ticks + 10) {
       	        SDL_Delay(1);
       	}
       	Ticks = SDL_GetTicks();
       	
	}
    return 0;
}

