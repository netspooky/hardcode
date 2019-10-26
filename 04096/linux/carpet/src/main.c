#include <stdlib.h>
#include <SDL.h>
#include <GL/gl.h>
#include <unistd.h>
#include <math.h>
#include <alsa/asoundlib.h>

#define WIDTH  200
#define HEIGHT 200

GLfloat *vertices;
GLfloat *normals;
GLfloat *colors;
GLuint *indices;
snd_pcm_t *sound;
float *sndbuffer;
snd_pcm_uframes_t frames = 50;

void play(snd_pcm_t *s){
   int c,err;

   c = frames;
   while(c > 0){
      err = snd_pcm_writei(s, sndbuffer, c);
      if(err == -EAGAIN) continue;
      if(err == -EPIPE){
         err = snd_pcm_prepare(s);
/*         if(err < 0)
            printf("hiba %s\n", snd_strerror(err));*/
      }
      else if(err == -ESTRPIPE){
         while( (err = snd_pcm_resume(s)) == -EAGAIN) sleep(1);
         if(err < 0){
            err = snd_pcm_prepare(s);
/*            if(err < 0)
               printf("hiba2 %s\n", snd_strerror(err));*/
         }
         return;
      }
      
      c -= err;
   }

}

void playingcallback(snd_async_handler_t *ahandler){
   snd_pcm_t *h = snd_async_handler_get_pcm(ahandler);
   snd_pcm_sframes_t avail;

   avail = snd_pcm_avail_update(h);

   while( avail >= frames ){
      play(h);
      avail = snd_pcm_avail_update(h);
   }
}

void initsound(){
   int err;
   snd_async_handler_t *ah;

   snd_pcm_open(&sound, "default", SND_PCM_STREAM_PLAYBACK, 0);
   sndbuffer = malloc(sizeof(float) * HEIGHT);
   err = snd_pcm_set_params(sound, SND_PCM_FORMAT_S32_LE, SND_PCM_ACCESS_RW_INTERLEAVED, 1, 44100,1,500000);
   if(err < 0) exit(1);

   snd_async_add_pcm_handler(&ah, sound, playingcallback, NULL);

   for(err = 0; err < 2; err++){
      play(sound);
   }

   snd_pcm_start(sound);
}

void render(){
   int x,y = 0;
   int index, i = 0;

   vertices = malloc(sizeof(GLfloat) * WIDTH * HEIGHT * 3);
   normals  = malloc(sizeof(GLfloat) * WIDTH * HEIGHT * 3);
   colors   = malloc(sizeof(GLfloat) * WIDTH * HEIGHT * 3);
   indices  = malloc(sizeof(GLuint) * (WIDTH-1) * (HEIGHT-1) * 6);/*FIXME I don't know how many indices I need */

   /* Vertices */
   for(x = 0; x < WIDTH; x++)
      for(y = 0; y < HEIGHT; y++){
         index = y * WIDTH * 3 + x * 3;
         vertices[index    ] = -1.0 + (GLfloat)x * 0.01f; /* x choord */
         vertices[index + 1] = -1.0 + (GLfloat)y * 0.01f; /* y choord */
         vertices[index + 2] = 0.0f;              /* z choord */

         /* All the vertices will be green */
         colors[index    ] = 0.0f;
         colors[index + 1] = 1.0f;
         colors[index + 2] = 0.0f;

         normals[index    ] = -1.0 + (GLfloat)x * 0.01f;
         normals[index + 1] = -1.0 + (GLfloat)y * 0.01f;
         normals[index + 2] = 1.0f;

         if((y == HEIGHT - 1) || (x == WIDTH - 1)) continue;

         indices[i++] = y * WIDTH + x;
         indices[i++] = y * WIDTH + x + WIDTH;
         indices[i++] = y * WIDTH + x + 1;

         indices[i++] = y * WIDTH + x + 1;
         indices[i++] = y * WIDTH + x + WIDTH + 1;
         indices[i++] = y * WIDTH + x + WIDTH;

      }
}

void free_mesh(){
   free(vertices);
   free(normals);
   free(colors);
   free(indices);
}

void draw(float factor){
  int x, y;
  float value;
  GLfloat bgrnorm[12] = {-2.0, -2.0, -0.9,
                         -2.0,  2.0, -0.9,
                          2.0,  2.0, -0.9,
                          2.0, -2.0, -0.9};
  GLfloat bgrvert[12] = {-2.0, -2.0, -1.9, 
                         -2.0,  2.0, -1.9, 
                          2.0,  2.0, -1.9,
                          2.0, -2.0, -1.9};
  GLfloat bgrcol[12]  = {1.0,1.0,1.0,0.25,0.25,0.25,1.0,1.0,1.0,0.25,0.25,0.25};
  GLuint  bgridx[4]   = {0,1,2,3};

  for(x = 0; x < WIDTH; x++){
     for(y = 0; y < HEIGHT; y++){
         value = cos(sqrt( (x / (WIDTH  / 2.0) - 1.0)*(x / (WIDTH  / 2.0) - 1.0) + 
                           (y / (HEIGHT / 2.0) - 1.0)*(y / (HEIGHT / 2.0) - 1.0) ) * factor);
         sndbuffer[y] = value * 20000;
         vertices[y * WIDTH * 3 + x * 3 + 2] = value;
         normals[y * WIDTH * 3 + x * 3 + 2]  = value + 1.0;
     }
  }
glDisable(GL_TEXTURE_2D);
  glPushMatrix();
    glRotatef(290.0f, 2.0, 1.0, 2.0);
    glNormalPointer(GL_FLOAT, 0, normals);
    glColorPointer(3, GL_FLOAT, 0, colors);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glDrawElements(GL_TRIANGLES, (WIDTH - 1) * (HEIGHT - 1) * 6, GL_UNSIGNED_INT, indices);
  glPopMatrix();

  /* draw the background */
  glNormalPointer(GL_FLOAT, 0, bgrnorm);
  glColorPointer(3,GL_FLOAT, 0, bgrcol);
  glVertexPointer(3, GL_FLOAT, 0, bgrvert);
  glDrawElements(GL_QUADS, 4, GL_UNSIGNED_INT, bgridx);
}

int main(){
   SDL_Event event;
   Uint32 now = 0, start = 0;
   int done = 0;

   GLfloat amblight[] =  {0.2f, 0.2f, 0.2f, 1.0f};
   GLfloat lowlight[] =  {0.25f,0.25f,0.25f,1.0f};
   GLfloat difflight[] = {1.0f, 1.0f, 1.0f, 1.0f};
   GLfloat lightpos[] =  {1.0f, 1.0f, 1.0f, 1.0f};

/* Initialization */
SDL_Init(SDL_INIT_VIDEO);
SDL_SetVideoMode( 1024, 768, 32, SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE | SDL_RESIZABLE | SDL_HWSURFACE | SDL_FULLSCREEN );
SDL_ShowCursor(SDL_DISABLE);
glClearColor(0.0,0.0,0.0,0.0);
glMatrixMode(GL_PROJECTION);
glEnable(GL_DEPTH_TEST);
glEnable(GL_NORMALIZE);
glLoadIdentity();

render();

glEnableClientState(GL_NORMAL_ARRAY);
glEnableClientState(GL_COLOR_ARRAY);
glEnableClientState(GL_VERTEX_ARRAY);

glEnable(GL_LIGHTING);
glLightModelfv(GL_LIGHT_MODEL_AMBIENT, amblight);
glLightfv(GL_LIGHT0, GL_AMBIENT, lowlight);
glLightfv(GL_LIGHT0, GL_DIFFUSE, difflight);
glLightfv(GL_LIGHT0, GL_SPECULAR, difflight);
glLightfv(GL_LIGHT0, GL_POSITION, lightpos);
glEnable(GL_LIGHT0);

glEnable(GL_COLOR_MATERIAL);
glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
glMaterialfv(GL_FRONT, GL_SPECULAR, difflight);
glMateriali(GL_FRONT, GL_SHININESS, 20);

glOrtho(-2.0,2.0,-2.0,2.0,-2.0,2.0);
initsound();

while(!done){
   /* Event handling */
   while( SDL_PollEvent( &event) ){
      switch(event.type){
         case SDL_KEYDOWN:
            if (event.key.keysym.sym == SDLK_ESCAPE) done = 1;
      }
   }
   /* Drawing */
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
   draw(sin((float)now / 2000.0f) * 10.0);
   now = SDL_GetTicks() - start;
   SDL_GL_SwapBuffers();
}

/* Quit */
SDL_ShowCursor(SDL_ENABLE);
free_mesh();
SDL_Quit();
free(sndbuffer);
snd_pcm_close(sound);
return(0);
}
