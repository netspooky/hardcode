#include "Video.h"
#include "BMFont.h"
#include "LineFont.h"
#include "Timer.h"
#include "RayTracer.h"
#include "World.h"
#include "TextManager.h"
#include "Music.h"
#include "Clouds.h"
#include "Font.h"
#include "Musa.h"
#include "intro1.h"
#include "intro2.h"
#include "intro5.h"
#include "intro6.h"
#include "intro7.h"
#include "intro9.h"
#include "loppu.h"
#include "demotus.h"
#include "demotus2.h"

int main()
{
  Timer timer3(100);

  int i;

  RayTracer *rt;
  Bitmap *bitmap,*kuva;
  Bitmap *tex1,*tex3;
  LineFont *lfont;
  BMFont *font,*fontr,*fontg,*fontb,*sfont;
  TextManager *tm;
  Text *helou[6];
  Clouds *clouds;
  World *worlds[9];
  void *m;

  int halku = 8800;

  videoInit(320,240);

  lfont = new LineFont();
  lfont->load(raw_font);

  font = new BMFont();
  font->getFromLineFont(lfont,2);
  sfont = new BMFont();
  sfont->getFromLineFont(lfont,1.5);

  rt = new RayTracer();
  rt->init(screen->width,screen->height);

  fontr = new BMFont();
  fontr->getFromLineFont(lfont,1.5);
  fontg = new BMFont();
  fontg->getFromLineFont(lfont,1.5);
  fontb = new BMFont();
  fontb->getFromLineFont(lfont,1.5);

  for(i=0; i<255; i++)
  {
    if(fontr->bitmaps[i])
    {
      fontr->bitmaps[i]->filterColors(1,0.2f,0.2f);
      fontg->bitmaps[i]->filterColors(0.2f,1,0.2f);
      fontb->bitmaps[i]->filterColors(0.2f,0.2f,1);
    }
  }

  tex1 = new Bitmap(256,256);
  tex1->generateSin();
  //tex2 = new Bitmap(256,256);
  //tex2->generateFractal();
  tex3 = new Bitmap(256,256);
  tex3->generateNoise();

  //tex4 = new Bitmap(256,256);
  //tex4->generateNoise();
  //tex4->circle(128-32,128,30,20,0xFF80FF);
  //tex4->circle(128+32,128,30,20,0xFF80FF);
  //tex4->smooth();

  clouds = new Clouds();

  for(i=0; i<9; i++)
  {
    worlds[i] = new World();
    worlds[i]->textures.add(tex1);
    worlds[i]->textures.add(tex1);
    worlds[i]->textures.add(tex3);
    worlds[i]->textures.add(tex1);
  }

  worlds[0]->loadBuffer(raw_intro2,raw_intro2_size);
  worlds[1]->loadBuffer(raw_intro1,raw_intro1_size);
  worlds[2]->loadBuffer(raw_intro7,raw_intro7_size);
  worlds[3]->loadBuffer(raw_intro6,raw_intro6_size);
  worlds[4]->loadBuffer(raw_intro5,raw_intro5_size);
  worlds[5]->loadBuffer(raw_demotus,raw_demotus_size);
  worlds[6]->loadBuffer(raw_demotus2,raw_demotus2_size);
  worlds[7]->loadBuffer(raw_intro9,raw_intro9_size);
  worlds[8]->loadBuffer(raw_loppu,raw_loppu_size);

  bitmap = new Bitmap(screen->width,screen->height);

  kuva = new Bitmap(screen->width,screen->height);
  rt->world = worlds[4];
  rt->render(kuva,1);
  fontr->print(*kuva,0,134,114,"Vaahtokarkit");
  fontg->print(*kuva,0,135,114,"Vaahtokarkit");
  fontb->print(*kuva,0,136,114,"Vaahtokarkit");
  sfont->print(*kuva,0,114,144,"Tehnyt Hipo");

  tm = new TextManager();
  tm->texts.init();

  tm->add(120,30,    halku+0,halku+1080,200,font,"Helou");
  helou[0] = tm->add(0,100, halku+20,halku+300,150,sfont,"Itchi");
  helou[1] = tm->add(0,140, halku+120,halku+420,150,sfont,"UT");
  helou[2] = tm->add(0,140, halku+220,halku+520,150,sfont,"Wesgu");
  helou[3] = tm->add(0,120, halku+320,halku+620,150,sfont,"Hiteck");
  helou[4] = tm->add(0,110, halku+420,halku+720,150,sfont,"Ihmemies");
  helou[5] = tm->add(0,90, halku+520,halku+820,150,sfont,"Sanxion");

  tm->add(30,50, 2000,2300,50,fontr,"Katso");
  tm->add(30,70, 2000,2300,50,fontr,"Vilkutetaan");

  tm->add(180,70, 2300,2600,50,fontb,"Piiloon");

  tm->add(20,50, 3300,3600,50,sfont,"Tahdon ruokaa");
  tm->add(70,90, 3650,4000,50,sfont,"Salaatti");
  tm->add(30,70, 4100,4400,50,sfont,"Lisää ruokaa");
  tm->add(40,90, 4250,4550,50,sfont,"Syön sinut kotona");

  tm->add(70,90,  5350,5650,50,fontb,"Hui... Pitää");
  tm->add(70,110, 5350,5650,50,fontb,"pelastaa kaveri");

  bitmap->clear(0);
  font->print(*bitmap,0,60,10,"Jippu...");
  sfont->print(*bitmap,0,40,50,"Ei hw kiihdytystä");
  sfont->print(*bitmap,0,40,75,"Ei polykoneja");
  sfont->print(*bitmap,0,40,100,"Treissausta :)");

  sfont->print(*bitmap,0,10,140,"Sori noita musiikkeja...");

  while(!quitrequest)
  {
    if(keydown==27) break;
    if(timer3.getCounter()>800) break;

    int timppu = timer3.getCounter();
    int *d = &screen->data[0][0];
    float strech = sinf(3.1415f*2*timppu/100)*30.0f;
    for(int y=0; y<screen->height; y++)
    {
      int *s = &bitmap->data[y][0];
      int tsx = (int) (sinf(3.1415f*(y+timppu*0.5f)/screen->height)*strech);
      int tex = screen->width-tsx;
      int txa = (tex-tsx)*256/screen->width;
      int tx = txa * tsx;
      for(int x=0; x<screen->width; x++)
      {
        int xx = tx/256;
        tx+=txa;
        if(xx < 0 || xx >= screen->width) *d++ = 0;
        else *d++ = s[xx];
      }
    }
    videoRefresh();
  }

  musicInit();
  m = musicLoad((char *)raw_musa,raw_musa_size);

  musicPlay(m);

  Timer timer(100),parttimer(100),timer2(100);
  int part = 0, oldpart = 0;

  while(!quitrequest)
  {
    if(keydown == 27) break;
    keydown = 0;

    int pt = parttimer.getCounter();

    switch(part)
    {
      case 0:
        rt->world = worlds[6];
        worlds[6]->time = pt*170.0f/400.0f;
        rt->render(screen,0);

        if(pt>400) part++;
        break;

      case 1:
        rt->world = worlds[5];
        worlds[5]->time = pt/7.0f + 8;
        rt->render(screen,0);

        if(pt>520)  screen->filter(-(pt-520)*255/30);
        if(pt>550) part++;
        break;

      case 2:
        screen->clear(0);
        sfont->print(*screen,0,30,50,"Tuli väärä intro...");
        sfont->print(*screen,0,30,80,"Toinen...");

        if(pt>250) part++;
        break;

      case 4:
        rt->world = worlds[0];
        worlds[0]->time = pt/10.0f;
        rt->render(screen,0);

        if(pt<50) screen->filter(-(50-pt)*255/50);

        if(pt>500)
        {
          screen->blit(*bitmap,0,0);
          timer2.setCounter(0);
          part++;
        }
        break;

      case 5:
        rt->world = worlds[1];
        worlds[1]->time = pt/10.0f;
        rt->render(screen,0);

        if(pt<100) screen->filter(-(255-(pt*255/100)));
        if(pt<200)
        {
          if(timer2.getCounter()>5)
          {
            bitmap->smooth();
            timer2.setCounter(timer2.getCounter()-5);
          }
          bitmap->transparencyBlit(*screen,(pt*255/200),0,0);
        }

        if(pt>2900)
        {
          screen->blit(*bitmap,0,0);
          part++;
        }
        break;
/*
      case 6:
        rt->world = worlds[2];
        worlds[2]->time = pt/10.0f;
        rt->render(screen);

        if(pt>900) part++;
        break;

      case 7:
        rt->world = worlds[3];
        worlds[3]->time = pt/10.0f;
        rt->render(screen);

        if(pt>1500)
        {
          screen->blit(*bitmap,0,0);
          part++;
        }
        break;
*/
      case 8:
/*
        rt->world = worlds[4];
        worlds[4]->time = pt/5.0f;
        rt->render(screen,0);
*/
        kuva->blit(*screen,0,0);
        if(pt<100)
        {
          screen->filter(-(255-(pt*255/100)));
          bitmap->transparencyBlit(*screen,(pt*255/100),0,0);
        }
        if(pt>700) part++;
        break;

      case 9:
        rt->world = worlds[2];
        worlds[2]->time = pt/10.0f;
        rt->render(screen,0);
        if(pt>400) part++;
        break;

      case 10:
        rt->world = worlds[3];
        worlds[3]->time = pt/10.0f;
        rt->render(screen,0);
        if(pt>1200) part++;
        break;

      case 11:
        rt->world = worlds[7];
        worlds[7]->time = pt/20.0f;
        rt->render(screen,0);
        if(pt>800) part++;
        break;

      case 12:
        rt->world = worlds[8];
        worlds[8]->time = pt/10.0f;
        rt->render(screen,0);
        if(pt>1000) part++;
        break;

      case 13:
        clouds->camera.position.x = sinf(3.1415f*2*pt/1000) * 2000;
        clouds->camera.position.y = sinf(3.1415f*2*pt/1100) * 1600;
        clouds->camera.position.z = cosf(3.1415f*2*pt/700) * 2000;
        clouds->draw(*screen);

        if(pt>2000-200) screen->filter(-(255-(2000-pt)*255/200));
        if(pt>2000) part++;
        break;

      case 14: quitrequest = 1; break;

      default: part++;
    }

    if(part!=oldpart)
    {
      parttimer.setCounter(0);
      oldpart = part;
    }
/*
    if(timer.getCounter()>4800 && timer.getCounter()<5800)
    {
//      if(timer.getCounter()>5900) text->transparencyBlit(*screen,(timer.getCounter()-5900)*255/200,70,50);
//      else if(timer.getCounter()<5700) text->transparencyBlit(*screen,255-(timer.getCounter()-5700)*255/200,70,50);
      text->addBlit(*screen,70,50);
    }
*/

    helou[0]->x = 20+(int)((timer.getCounterf()-halku)*0.1f);
    helou[1]->x = 170+(int)((timer.getCounterf()-halku)*0.04f);
    helou[2]->x = 10+(int)((timer.getCounterf()-halku)*0.2f);
    helou[3]->x = 120+(int)((timer.getCounterf()-halku)*0.08f);
    helou[4]->x = 70+(int)((timer.getCounterf()-halku)*0.03f);
    helou[5]->x = 140+(int)((timer.getCounterf()-halku)*0.12f);

    tm->draw(*screen,timer.getCounter());

    //sfont->printFormat(*screen,0,0,"%d",timer.getCounter());

    videoRefresh();
  }

  musicDeinit();

  videoDeinit();

  return 0;
}
