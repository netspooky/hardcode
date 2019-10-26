
void desing_precalc() {
}

int yrand(int size, int seed) { unsigned a, b; a=seed*1507715517+(rando>>3)*0x23f321c7^seed*0xdeadbeef; b=a*231554621^a*876423437; return (b>>16)%size; }
int xrand(int size, int seed) {
  int a=yrand(size, seed-1), b=yrand(size, seed);
  if (a==b) return yrand(size, seed*3); else return b;
}


float zap(float x, float z) { return x<0?0:1./(x+z); }
//
float plok_zap (float phi, int ver) {
  /*
funkkari jonka pitäisi (aina kun on 'päällä' triggeroida jotain
tapahtumaan seuraavissa kohdissa patternia:

4, 14, 36, 46 (ja kaiuten pois 46 alkaa, 50, 54, 56, 60...)

  */
  float brie;
  phi=fmod(phi, 1)*64;
  if(ver==0)
    brie=.1*(zap(phi-4, 1)+zap(phi-14, 1)+zap(phi-36, 1)+zap(phi-46, 1)+zap(phi-50, 1)*0.8+zap(phi-54, 1)*0.6+zap(phi-58, 1)*0.4+zap(phi-62, 1)*0.2);
  else 
    brie=.1*(zap(phi-4, 1)+zap(phi-14, 1)*0.5);
  return brie;
}

float haitsu_strobo (float phi, int ver) {
  float brie;
  phi=fmod(phi, 1)*64;
  if(ver==0)
    brie=3*(1-fmod((phi+2)*0.25, 1))*0.05+0.025*(zap(phi-0, 1)+zap(phi-6, 1)+zap(phi-12, 1)+zap(phi-18, 1)+zap(phi-24, 1)+zap(phi-30, 1)+zap(phi-36, 1)+zap(phi-42, 1)+zap(phi-48, 1)+zap(phi-54, 1)+zap(phi-60, 1));
  else 
    brie=3*(1-fmod((phi+2)*0.25, 1))*0.05+0.025*(zap(phi-0, 1)+zap(phi-6, 1)+zap(phi-12, 1)+zap(phi-18, 1)+zap(phi-24, 1)+zap(phi-30, 1)+zap(phi-36, 1)+zap(phi-42, 1)+zap(phi-48, 1)*0.75+zap(phi-54, 1)*0.5+zap(phi-60, 1)*0.25);
  return brie;
}



void desing(unsigned char *buf, int pitch, int xs, int ys, float phi) {
  float bri=0; float kont=1;

//  phi-=1.0/16.0;


  //tähän fade-in 1 patternia
  if (phi<1) {
    bri=(1-fmod(phi*16, 1))*0.025;
    kont=phi*(1.0/4.0);
    
  //'hengailua' 3 patternia
  } else if (phi<4) {
    bri=(1-fmod(phi*16, 1))*0.025;
    if (phi>2) {
      bri=-(plok_zap(phi, 0)*2);
    } 
    kont=phi*(1.0/4.0);


  //seuraava pätkä on 2 patternia vaikka biisissä vain yksi (pit. 128 rowia)
  //tähän väliin synkkejä enmmänkin

  // tähän patterniin ainakin seuraavat synkit: joku fade-in koko pituudelta (t 3...5)
  // toinen fade-in riviltä 80 riville 128 (exponentiaalinen)
  // joku synkki 16 rivin välein koko ajalle

  } else if (phi<6) {
    if (phi<4.5) {
      float phii=(phi-4.0)*2;
      bri=(1/phii)*0.1+(1-fmod(phi*4, 1))*0.075;
      kont=1.25-(((phi-4)*(phi-4))*2);
    } else {
      bri=(1-fmod(phi*4, 1))*0.075;
      kont=1-((phi-4)*0.5);
    }

  //ja taas 64 row mittasia patterneja

  //4 patternia samaa (melodia ensimmäistä kertaa mukana)
  } else if (phi<10) {
    if (phi<6.5) {
      float phii=(phi-6.0)*2;
      bri=(1/phii)*0.1+(1-fmod(phi*16, 1))*0.025;
      kont=1.25-(((phi-6)*(phi-6))*2);
    } else if (phi>=8.9375&&phi<9) {
      float phii=(phi-8.9375)*16;
      bri=0.5-phii*0.5;
      kont=1.5+phii;    
    } else if (phi>=9&&phi<9.25) {
      float phii=(phi-9.0)*4;

      bri=((1/phii)*0.05+(1-fmod(phi*16, 1))*0.025)-0.05;
  
      kont=2-phii*0.5;
    } else {
      bri=(1-fmod(phi*16, 1))*0.025;
      kont=1;
    }



  //ja taas 4 patternia samaa (melodia luuppaa tokan kerran
  } else if (phi<14) {
    if (phi<10.5) {
      float phii=(phi-10.0)*2;
      bri=(1/phii)*0.1+(1-fmod(phi*16, 1))*0.025;
      kont=1.25-(((phi-10)*(phi-10))*2);
    } else if (phi>=12.9375&&phi<13) {
      float phii=(phi-12.9375)*16;
      bri=0.5-phii*0.5;
      kont=1.5+phii;    
    } else if (phi>=13&&phi<13.25) {
      float phii=(phi-13.0)*4;
      bri=((1/phii)*0.05+(1-fmod(phi*16, 1))*0.025)-0.05;
      kont=2-phii*0.5;
    } else {
      bri=(1-fmod(phi*16, 1))*0.025;
      kont=1;
    }

  //suvantoa 3 patternia
  } else if (phi<17) {
    bri=-(plok_zap(phi, 0)*0.75);


  //tähän muuten samaa kuin ylläolevaaan mutta 'jotain' feidaa sisään viimeiset 16 riviä
  } else if (phi<18) {
    bri=-(plok_zap(phi, 0)*0.75);
    if(phi>17.75) {
      kont=1+(((phi-17.75)*(phi-17.75))*8);
    } else {
      kont=1; 
    }


  //3 patternia b-melodiaa perusmatskuilla
  } else if (phi<21) {
//    bri=-(plok_zap(phi, 0)*2);
      if(phi<18.5) {
        float phii=(phi-18.0)*2;
        bri=(1/phii)*0.1;
        kont=1.25-(((phi-18)*(phi-18))*2);
      } else if(phi>20.75) {
          kont=1+(((phi-20.75)*(phi-20.75))*2);
          bri=0+(phi-20.75)*(phi-20.75);
      } else {
        kont=1;
      }

  //jotain massiivista tapahtuu 1 patterni (feidaten pois patternin alusta)
  //plok_zap funkkari tähän silleen että se skulaan vaan riville 14 asti...
  } else if (phi<22) {
    if (phi<21.5) {
      float phii=(phi-21.0)*2;
      bri=((1/phii)*0.1)-0.1;
      kont=1.25-(((phi-21.0)*(phi-21.0))*2);
    } else {
      bri=0;
      kont=1;
    }


  //perusmelodiointia 3 patternia
  } else if (phi<25) {
    bri=-(plok_zap(phi, 0)*2);
    if (phi<22.5) {
      float phii=(phi-22.0)*2;
      bri=((1/phii)*0.1+(1-fmod(phi*16, 1))*0.025)-0.1;
      kont=1.25-(((phi-22)*(phi-22))*2);
    } else if (phi>=24.9375&&phi<13) {
      float phii=(phi-24.9375)*16;
      bri=0.5-phii*0.5;
      kont=1.5+phii;    
    }

  //perusmelodiointi feidailee vähän pois 1 patternia
  } else if (phi<26) {
    bri=-(plok_zap(phi, 1)*2);
    if (phi>=25&&phi<25.25) {
      float phii=(phi-25.0)*4;
      bri=(1/phii)*0.05+(1-fmod(phi*16, 1))*0.025;
      kont=2-phii*0.5;
    } else {
      bri=(1-fmod(phi*16, 1))*0.025;
      kont=1;
    }


  //vähän fadetusta lisää
  } else if (phi<28) {
    kont=1+(1-fmod(phi*8,1))*0.15;


  //haitsu lähtee pois
  } else if (phi<29) {
    kont=1+(1-fmod(phi*8,1))*0.15;

  //bassari lähtee pois (vain 'bowow, bowow, bowow' saundi jäljellä)
  } else if (phi<29.9325) {  
    bri=bri-(phi-29);
    kont=1+(1-fmod(phi*8,1))*0.15;
    
    

  } else {
    stopnow++;
    //30's patterni on vika. sen lopussa loputaan
  }

  //haitsustrobo
  if (phi<4.0||(phi>6&&phi<26)) {
    if (phi>17&&phi<18) {
//      kont=1;
//      bri=bri+haitsu_strobo(phi,1);
      kont=kont+haitsu_strobo(phi,1);
    } else {
//      bri=bri+haitsu_strobo(phi,0);
      kont=kont+haitsu_strobo(phi,0);
    }
  }





  switch (xrand(6, phi)) {
    case 0: rend(buf, pitch, xs, ys, tsot, 5); break;
    case 5: rend(buf, pitch, xs, ys, tsot, 5); break;
    case 1: getframe(buf, pitch, mov, xs, ys, phi*16384*2); break;
    case 2: duunaa_sumu(buf, pitch, xs, ys, phi*(256+phi)); break;
    case 3: duunaa_sumu(buf, pitch, xs, ys, phi*(386+phi*1.5)); break;
    case 4: {
      unsigned char *buf2=malloc(pitch*ys), *d=buf, *s=buf2;
      if (xrand(2, phi)==0)
        duunaa_sumu(buf, pitch, xs, ys, phi*1.5*(512-phi*2.5));
      else
        getframe(buf, pitch, mov, xs, ys, phi*16384*2); 
      duunaa_sumu(buf2, pitch, xs, ys, phi*(512-phi*2.5));
      for (; d<buf+ys*pitch; s+=4, d+=4) d[0]=d[0]*s[0]>>8,d[1]=d[1]*s[1]>>8,d[2]=d[2]*s[2]>>8,d[3]=d[3]*s[3]>>8;
      free(buf2);
    } break;
/*
    case 1: rend(buf, pitch, xs, 224, tsot, 5); foofoo(buf, pitch, xs, ys, 128+128*sin(phi)); break;
    case 2: getframe(buf, pitch, mov, xs, ys, phi*16384*2); foofoo(buf, pitch, xs, ys, 128+128*sin(phi*1.2)); break;
    case 3: duunaa_sumu(buf, pitch, xs, ys, phi*256); foofoo(buf, pitch, xs, ys, 128+128*sin(phi*0.8)); break;
*/
/*
    case 3: rend(buf, pitch, xs, 224, tsot, 5); foofoo(buf, pitch, xs, ys, xrand(16, phi*4)*16+8); break;
    case 4: getframe(buf, pitch, mov, xs, ys, phi*16384*2); foofoo(buf, pitch, xs, ys, xrand(16, phi*4)*16+8); break;
    case 5: duunaa_sumu(buf, pitch, xs, ys, phi*256); foofoo(buf, pitch, xs, ys, xrand(16, phi*4)*16+8); break;
*/
  }
  switch (xrand(3, phi)) {
    case 0: glaah(buf, pitch, xs, ys, 10); break;
    case 1: foofoo(buf, pitch, xs, ys, 128+128*sin(1-fmod(phi*0.325,1)) ); break;
    case 2: foofoo(buf, pitch, xs, ys, 32+32*sin(phi*0.5) );break;
  }
  if(xrand(10,phi)<2) {
    duunaa_kirkkovene(buf, buf, pitch, xs, ys, -kont, bri+1, .1, 0, 0);
  } else {
    duunaa_kirkkovene(buf, buf, pitch, xs, ys, kont, bri, .1, 0, 0);
  }
//  duunaa_kirkkovene(buf, buf, pitch, xs, ys, kont*sin(1-fmod(phi*4,1)), bri*sin(1-fmod(phi*4,1)), .1, 0, 0);
//  duunaa_kirkkovene(buf, buf, pitch, xs, ys, kont, bri, .1, 0, 0);
//  foofoo(buf, pitch, xs, ys, 128+128*sin(1-fmod(phi*0.25,1)) );
//  glaah(buf, pitch, xs, ys, 128+128*sin(1-fmod(phi*0.25,1)) );
  
  duunaa_kirkkovene(buf, buf, pitch, xs, ys, 1, 0, 7, 0, 0);

}




