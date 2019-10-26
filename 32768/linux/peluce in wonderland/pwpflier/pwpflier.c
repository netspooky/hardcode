#include <stdio.h>
#include <stdlib.h>
#include <time.h>

char protomap[256][256];

int rasterizer[8]={0,32,16,48,8,40,24,56};

#define LIM(a) ((a)<0?0:((a)>255?255:(a)))

void recursive_plasma(int x0,int y0,int x1,int y1,int lev)
{
   if(x1>x0 && y1>y0)
   {
      int a=protomap[x0&255][y0&255],
          b=protomap[x1&255][y0&255],
          c=protomap[x0&255][y1&255],
          d=protomap[x1&255][y1&255],

          xm=(x0+x1)>>1,
          ym=(y0+y1)>>1;

      protomap[xm][y0]=(a+b)>>1;
      protomap[xm][y1]=(c+d)>>1;
      protomap[x0][ym]=(a+c)>>1;
      protomap[x1][ym]=(b+d)>>1;

        // 4:single detail, 8:g00d, 32:mess with great contrast
      { int k=rand()%((abs(x0-x1)<<lev)+1);
        if(k&1)k=0-k;
        protomap[xm][ym]=LIM((a+b+c+d+k)>>2);
      }

      if(x1>x0+1)
      {
         recursive_plasma(x0,y0,xm,ym,lev);
         recursive_plasma(xm,y0,x1,ym,lev);
         recursive_plasma(x0,ym,xm,y1,lev);
         recursive_plasma(xm,ym,x1,y1,lev);
      }
   }
}


void drawflier(char*pic0,char*bg0,int xzoom,int yzoom)
{
   int iy=0,ix;

   char*pic=pic0,
       *bg=bg0;

   while(*pic!='\0')
   {
      char*line=pic;
      int y=yzoom;

      for(;y;y--)
      {
         pic=line;
         while(*pic!='\n')
         {
            int x=xzoom;
            for(;x;x--)
            {
               if(*pic!=' ')
               {
                  putchar(*bg);
                  bg++;
                    if(*bg=='\0')bg=bg0;
               }
                else
               {
                  int k=protomap[iy&255][ix&255]+rasterizer[(iy^(ix<<1))&7];
                  putchar(" ..:;"[(k>>6)%5]);
               }
               ix++;
            }

            pic++;
              if(pic=='\0')pic=pic0;
         }
         iy++;
         ix=0;
         putchar('\n');
      }
      pic++;
   }
}

/********************************************************************/

char*pwpflier0=

   "                               \n"
   "                               \n"
   "                               \n"
   "         ** ********           \n" 
   "         ******** **           \n"
   "             ***               \n"
   "             ***               \n"
   "          *************        \n"
   "          *******************  \n"
   "         **********            \n"
   "         xxxxxx                \n"
   "        *****                  \n"
   "        *****    x             \n"
   "       ********                \n"
   "       ************            \n"
   "       **************          \n"
   "       ****************        \n"
   "        *****                  \n"
   "        *******                \n"
   "        ***********  xx        \n"
   "        ***************        \n"
   "         ************          \n"
   "         **********            \n"
   "           ******              \n"
   "           ******              \n"
   "           ******              \n"
   "                               \n"
   "   ******** **      ** ********\n" 
   "   ******** **      ** ********\n"
   "   **    ** **      ** **    **\n"
   "   **    ** **      ** **    **\n"
   "   ******** **  **  ** ********\n"
   "   ******** **  **  ** ********\n"
   "   **       **  **  ** **      \n"
   "   **       **  **  ** **      \n"
   "   **       ********** **      \n"
   "   **       ********** **      \n"
   "                               \n";

/* 
 *  From Jeesuksen Opetuslapset ry - freely distributable text
 *
 *  http://personal.inet.fi/yhdistys/jeesuksenopetuslapsetry./
 *
 */

char*jolry_bg=
   "Ottaisin päälleni vaikka minkälaisia ruttoja, jos saisin Jumalalta "
   "VOIMALLISTEN TEKOJEN ARMOLAHJAN! HENKIEN ULOSAJAMISEN ARMOLAHJAN! "
   "VAIKKA PUOLEKSI VUODEKSI!  ILMAN NIITÄ EN VOI KUN ITKEÄ JA VALVOA "
   "ÖITÄNI! KYLLÄ NE MIELESSÄ ON NUO VUODET JA NE YÖT KUN TUOLLA KÄVELIN "
   "JA NÄIN KERTOMAANI! JA NYT SAAN KUULLA, ETTÄ TÄMÄ TOUHU KASVAA!!! JA "
   "JUURI TÄHÄN AIKAAN!!!! SAATANA on vuositolkulla tietänyt "
   "Hengellisistä asoista enemmän kuin uskovat!   "

   "1990 luvun alussa JUMALALTA tuli profetia: \"Nyt, MINÄ JUMALA, ALAN "
   "KURITTAMAAN SUOMEN KANSAA TOSI MIELESSÄ, SIITÄ SYYSTÄ, ETTÄ SUOMEN "
   "KANSASTA EI LÖYDY HÄNELLE KELPAAVASSA USKOSSA OLEVIA IHMISIÄ, "
   "HÄNELLE RIITTÄVÄÄ MÄÄRÄÄ!   "

   "Kuinka paljon sinun perheessäsi on tuhottu äänitteitä, joilla on ns. "
   "Hevy metalli rokkia? ns. Gospel musiikkia? Joita varhaisnuoret "
   "kuuntelevat, kuin ei mitään pahaa olisi!   "

   "SIINÄ TÄLLÄ MENETELMÄLLÄ MENEVÄT SITTEN 30 luvun Raamattu ja "
   "Herramme JEESUS MUKANA! VALITAN! NÄIN VAKAVISTA ASIOISTA ON KYSE! "
   "MINKÄS MINÄ HEILLE VOIN?! ITKEÄ JA KOITTAA KUINKA KOVIA LYÖNTEJÄ "
   "TÄMÄ NÄPPÄIMISTÖ KESTÄÄ! JA SYÖDÄ PSYKOSOMAATTISIIN SAIRAUKSIINI "
   "PURKKI KAUPALLA PILLEREITÄ! JOITA LÄÄKÄRINI KIELSI SYÖMÄSTÄ! Kun ei "
   "ole varaa niihin lääkkeisiin, joita tarvitsen!   "
 
   "HÄVETKÄÄ! JOS OSAATTE!  RAAMATTU KERTOO, ETTÄ ISRAELIN KANSA "
   "EVANKELIOIDAAN AIVAN MERKILLISELLÄ TAVALLA! MITEN SAMASTA ASIASTA "
   "VOI OLLA KAKSI ERI VERSIOTA! PAINUKAA LUOLIIN JA TUKKIKAA SUUNNE! "
   "SANON MINÄ!  JOS EI TEILLÄ MUUTA PUHUTTAVAA OLE! ON RAAMATUN "
   "LUKUNNEKIN OLLUT AIVAN TURHAA!  KUN ETTE YMMÄRRÄ LUKEMAANNE! VOI "
   "PYHÄ YKSINKERTAISUUS!  Pystyisin kaatamaan joka ainoan väitteenne! "
   "TE TULETTE RAAMATULLA!  JA AIVAN SAMALLA KIRJALLA MINÄ KAADAN "
   "JOKAISEN VALHEELLISEN VÄITTEENNE! MUTTA EN JAKSA! MUTTA VAROITAN "
   "KYLLÄ NÄISTÄ KIRJANOPPINEISTA! ÄLKÄÄ KUUNNELKO HEITÄ! KUUNNELKEE "
   "JEESUSTA! HÄN OPETTAA TEILLE RAAMATUN PERUSTOTUUDET HYVINKIN "
   "NOPEASTI! EIKÄ NYT KYLLÄ PITKIIN KURSSEIHIN AIKAA OLEKKAAN! VAINON "
   "AJAT OVAT LÄHELLÄ!  JA TÄMÄ KANSA EI TIEDÄ MITÄÄN!  ILMIANTAJIA ON "
   "TUHATMÄÄRIN ENEMMÄN;KUIN NIITÄ AITOJA JEESUKSEN SEURAAJIA JOITA "
   "TÄSSÄKIN MAASSA ALETAAN VAINOTA! NÄIN IKÄVÄSTI ON NYT ASIAT! JA "
   "VIELÄ YRITÄTTE SAATANAN JOUKKOJEN KEHOITUKSESTA TULEMAAN ESIIN! SE "
   "ON MIINA JOHON ME EMME NYT TULE! ANTEEKSI VAAN! TAIDAMME JOUTUA "
   "POISTUMAAN AIKAISEMMIN, KUIN OLETINKAAN!  VALMIINA KYLLÄ OLLAAN! EI "
   "SIINÄ MITÄÄN! HUKASSA ON JO PALJON SUOMEN AITOJA USKOVAISIA! "
   "POISTUMME HETI KUN SILTÄ NÄYTTÄÄ! JEESUS ANTAA MERKIN! EMME TARVITSE "
   "KUIN TIEDON YÖLLÄ! SEURAAVANA PÄIVÄNÄ OLEMME JO KATEISSA! NIIN "
   "YKSINKERTAISTA!   "

   "YLEINEN VÄITTÄMÄ; JOKA TAANNOIN VIIMEKSI MINULLEKKIN TAAS POSTIN "
   "KAUTTA HEITETTIIN:\" AITO PROFEETTA EI PUHU MILLOINKAAN "
   "VALHEPROFETIOITA!\" AIVAN VARMASTI JOUTUU PUHUMAAN! ILMESTYKSIÄ "
   "NÄKEVÄ; JOUTUU AIVAN VARMASTI KATSELEMAAN SAATANAN LUOMIA "
   "ILMESTYKSIÄ!!!! SAARNAAJAT JA OPETTAJAT JOUTUVAT AIVAN VARMASTI "
   "NÄIHIN MIINOIHIN! JOUDUMME YLIHENGELLISYYTEEN! JOUDUMME LAN ALLE! "
   "IHAN VARMASTI JA AIVAN KÄYTÄNNÖSSÄ! TÄMÄ TAPAHTUU KOULUTTUKSEN "
   "AIKANA. KAIKKI NÄMÄ! JA SENKIN JÄLKEEN SAATTAA LIPSUA!   "

   "Nyt VELI TEMPAISIKIN SUOMEKSI KOMENNON: JEESUKSEN KRISTUKSEN "
   "NASARETTILAISEN NIMESSÄ! ANNETTIIN PIMEYDEN HENKILLE LÄHTÖKÄSKY! "
   "Mitäs nyt tapahtui?   "

   "AMERIKASTAKIN KUULEMMA AINAKIN YKSI BÄNDI TULEE! Sinne sitten vaan "
   "kuuntelemaan tuota SAATANAN LUOMAA MUSIIKKIA! Englannin sanakirjan "
   "mukaan gospel tarkoittaa suomeksi: evankeliumi! ETTÄ SIIHEN MALLIIN "
   "MEILLÄ PÄIN!  Täytyy teille kertoa ihan tosiasia! JA JÄLLEEN "
   "VALITETTAVASTI HYVIN MONIEN PETTYMYKSEKSI! SANAT OSIN RAAMATUSTA! "
   "SÄVELLYS SAATANAN! TÄHÄN EI OLE ALUSTA ALKAENKAAN YHTYNYT JUMALA! EI "
   "PYHÄ HENKI! EIKÄ TULE MILLOINKAAN YHTYMÄÄN MIHINKÄÄN! MISSÄ SAATANA "
   "TAI HÄNEN JOUKKONSA OVAT MUKANA! NIIISSÄ LIIKKUU PIMEYDEN HENGET JA "
   "TUNTEET! PALJONHAN NIILLÄKIN AIKAAN SAADAAN! Pelottavin aikaan "
   "saannos tuollakin on JUMALAN VIHA!!! Maatamme kohtaan! SINNE NYT "
   "VANHEMMAT: KAKAROITANNE PÄÄSTÄTTE! SUORASTAAN TYRKYTÄTTE! JA "
   "KANNATTE USKOVAISEN NIMEÄ! Jättäkää tuo nimi pois! Ihan totta! "
   "Katsokaas, kun JUMALALLA JA SAATANALLA EI OLE MITÄÄN TEKEMISTÄ "
   "TOISTENSA KANSSA! EI HIUSKARVAN VERTAA! EI OLE MILLOINKAAN OLLUT! "
   "SEN JÄLKEEN KUN SAATANA JA LANGENNEET ENKELIT TAIVAASTA VISKATTIIN! "
   "EIKÄ TULE OLEMAAN! SAATANA ON KAIKEN MUSIIKIN JA KAIKKIEN SOITTIMIEN "
   "ASIANTUNTIJA! SITÄ HÄN OLI JO TAIVAASSA! ENNEN KUIN RYHTYI KAPINAAN "
   "JUMALAN KANSSA! Näin Raamattu meille kertoo! Valtavalle määrälle "
   "teistä, tuo asia on tuttu! Mutta se nyt ikäänkuin ei kuuluisi "
   "teille! ARVATKAAPA: KUULUUKO???   "

   "Erotkaa, rakkaat ystävät, noista VOUHOTTAJISTA, JOTKA EIVÄT MITÄÄN "
   "TIEDÄ!!!  Kasetilla on sanoittus suurista ihmeistä ja Raamatusta! "
   "SÄVELLYS ON SAATANAN!  LAULU ESITYS TÄYSIN TEKNINEN SUORITUS! JA "
   "KAIKEN LISÄKSI SURKEA SELLAINEN! SAMAT ARVOSANAT KIRJASTA! SAATANAN "
   "JOUKKOJEN KÄTYRI! Kuuluisuudestaan huolimatta; RIKU RINNE! AINAKIN "
   "NYT! Jos muutosta tapahtuu? VIE SE TUOLTA PAIKALTA, MISSÄ HÄN NYT "
   "ON: MELKO PITKÄN AIKAA! EN TUOMITSE! MUTTA PALJASTAN! JA VAROITAN!   "

   "ELLEMME PÄÄSE ALKUSEURAKUNNAN KALTAISEEN JUMALAN VOIMAN VAIKUTUKSEN "
   "ALLE? ON TULOSSA ILMESTYSKIRJAN MUKAAN SELLAISTA TAVARAA MYÖS "
   "SUOMEEN! ETTÄ ILMAN TÄTÄ VOIMAA VOIMMEKIN SITTEN SANOA AIVAN "
   "VARMASTI TOISILLEMME HYVÄSTI JA HYVÄÄ YÖTÄ! OHJEET ANTAA JEESUS "
   "ALKUVALMISTELUT VOITTE TEHDÄ ALKUSEURAKUNNAN TAPAAN! KERRAN MEIDÄT "
   "JOKAINEN RIISUTAAN!  ELLET NÄIHIN USKO? Älä vaan sitten käytä "
   "itsestäsi nimitystä uskovainen tai kristitty! VAAN JOS VÄITÄT ettei "
   "nämä kuulu sinulle!  Eikä meille tänä aikana?! SINÄ OLET TÄYSI "
   "PELLE!   "

   "JA NÄMÄKÄÄN EIVÄT VIELÄ OLE TAKUULIPPU TAIVAASEEN! MUTTA, KUN "
   "KUULIAISESTI HERRAA TÄMÄN JÄLKEEN SEURAILEE. Voi joku saada "
   "kerrottua asian lapsilleen sukulaisilleen jne, NIMITTÄIN JOS NÄMÄ "
   "RUKOUKSET TEET AIVAN VILPITTÖMÄSTI !  Tarkoitan tuollaista tietoista "
   "vilppiä. KAIKKI ME NYT MUUTOIN OLLAAN KAIKKEA PAHUUTTA TÄYNNÄ "
   "TIEDÄTKÖ? SIELTÄ....TAIVAASTA KAJAHTAA MAHTAVA VOIMA !   "

   "Ja raha on tuossa osavaltiossa ollut pois käytössä tuon kokeen ajan. "
   "TÄMÄ ON ILMESTYSKIRJASSA KERROTTU PEDON MERKKI! JOLLA TUOTA MERKKIÄ "
   "EI OLE; HÄNELTÄ EI OSTETA MITÄÄN! EIKÄ MYYDÄ MITÄÄN! SEHÄN ON "
   "SELVIÖ! KUN RAHA POISTETAAN KÄYTÖSTÄ.  ON MAHDOTON ostaa tai myydä "
   "ilman tuota pedon merkkiä! Pyrin selittämään tämän hyvin "
   "kansanomaisesti. Ja kun tuo aika tulee. Ei paljon kertomastani voi "
   "tuo menetelmä poiketa! Ja tämä on sitten sellainen MERKKI, jota "
   "YKSIKÄÄN USKOVAINEN EI SAA MISSÄÄN OLOISSA OTTAA! NIMITTÄIN, kun "
   "Antikristus nousee ja vaaditaan tuo pedon merkki on se kovimpia "
   "koettelemuksia uskovaisille! Kansat kumartavat tuota "
   "petoa. Tottelevat häntä. Siis SAATANAN JUTTU!   "

   "Ellet tietoisesti palvele ja seuraa JEESUSTA, silloin tietämättäsi "
   "palvelet ja seuraat SAATANAA! Hän pystyy tämän asian sinulta niin "
   "hämäämään, ettet tiedä mitään! Jeesuksen omana olo ei ole salainen "
   "asia!   "

   "Kun yksikin taloudelliseti hyvin voiva henkilö tekee Jumalan mielen "
   "mukaisen parannuksen. Napsahtaa omaisuudet automaattiseti Jumalan "
   "Valtakunnan työhön!  EIKÄ VAIN SINNE PÄIN! NIINKUIN NYT ON "
   "KAIKENAIKAA NÄHTÄVISSÄ! NÄMÄ SAATANAN VALTAAMAT VÄLINEET EIVÄT KOVIN "
   "KAUAA OLE USKOVAISTEN KÄDEN ULOTTUVILLA! JA SUOMESSA AIDOT JEESUKSEN "
   "SEURAAJAT, JUMALAN PALVELIJAT VOIVAT TEHDÄ NÄIDEN LAITTEIDEN AVULLA "
   "VALTAVIA JUTTUJA, JOITA JUMALA SIUNAA KYLLÄ SUOMESSA ON OLTAVA "
   "KETJUT KUNNOSSA: MITEN JAKO ETEENPÄIN TAPAHTUU! Vaikka Jumala "
   "Henkensä kautta on tehnyt yhtä sun toista Suomessa ilman ihmisiä! "
   "Raamatun mukaan IHMISIÄ KÄYTETÄÄN JUMALAN VALTAKUNNAN TYÖSSÄ HAMAAN "
   "JEESUKSEN TULEMUKSEEN ASTI!!!   "

   "JOS TOIMITTE: LISÄTIETOA TULEE JEESUKSELTA NOPEAAN TAHTIIN! KAIKKI "
   "MUU ON TÄYSIN TURHAA! Puhukoon Istala ja kumppanit mitä tykkää! "
   "Saatanan palveluksessa koko remmi ja TIUKASTI! Ja lisää tulee! "
   "ISTALA KAATUU UUSIEN TUULIEN TULLESSA! Amerikassa jo valmiina! "
   "Levinnyt jo EUROOPPAAN! ENNUSTAN NÄILLE NYKYISILLE SAATANAN "
   "KÄTYREILLE nopeaa uran päättymistä!   "

   "OLISIKOHAN SYYTÄ VIIPYMATTÄ MENNÄ RUKOILLEN NÖYRASTI JEESUKSEN "
   "OPETUKSEN ALLE!  PARANNUKSEN TEON JÄLKEEN! JA SAMAN TIEN ANTAA "
   "ITSENSÄ JUMALALLE OTOLLISEKSI UHRIKSI! Ehtii oppia PYHÄN HENGEN ja "
   "saatanallisten henkien ERON! Ainakin näin räikeissä muodoissa! "
   "Varoitan edelleen! Älkää tutkiko pimeyden henkiä????!   ";

/********************************************************************/

int main(int argc,char**argv)
{
   srand(time(NULL));

   if(argc<3)
   {
      fprintf(stderr,"usage: %s <xzoom> <yzoom> [plasma]\n",argv[0]);
   }
    else
   {
      if(argc==3)
      {
         int i,j;
         for(i=0;i<256;i++)
           for(j=0;j<256;j++)
             protomap[i][j]=0;
      }
       else
      {
         protomap[0][0]=rand()&255;
         protomap[0][255]=rand()&255;
         protomap[255][0]=rand()&255;
         protomap[255][255]=rand()&255;
         recursive_plasma(0,0,255,255,3);
      }
         
      drawflier(pwpflier0,jolry_bg,atoi(argv[1]),atoi(argv[2]));
   }
   return 0;
}

