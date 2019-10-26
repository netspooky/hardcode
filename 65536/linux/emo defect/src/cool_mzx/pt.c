/* ------------------------------------------------------------------ PT.C ---

written by yzi/fit 1996-1998



---- värsiön inhö: 10.02.1998 ------------------------------------------------
        + muutin kaikki "char":it "unsigned char":eiksi
        
---- värsiön inhö: 08.02.1998 ------------------------------------------------
        + nyt ei dumppaa corea. char *pt_modid="XXXX" -tyyppinen määrittely
          ei käy, jos aikoo muuttaa pt_modid:tä joskus... (
        
---- version info: ??.05.1997 ------------------------------------------------
        + 0.141 korjattu EAx ja EBx -bugi

ÄÄÄÄ version info: 12.05.1997 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        + 0.14 kaikki komennot implementoitu, paitsi E0x ja EFx

ÄÄÄÄ version info: 07-09.05.1997 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        + 0.13 tehtiinkin jotain sen eteen (the codering at Hervanta)
        + laitteistoriippumaton
        + pt_play kirjoitettiin kokonaan uudestaan
        + Amiga-tyylinen rakenne, ei turhia statusmuuttujia

ÄÄÄÄ version info: 29.04.1997 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        + 0.12 yritys muuttaa pt.c riippumattomaksi käytettävästä äänikortista
        - vielä typerä rakenne playerissä

ÄÄÄÄ version info: 05.06.1996 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        + 0.10 muutin (melkein) kaikki muuttujat inteiksi... tone portamento
               toimii nyt! (ainakin compulsi.mod) eiks tää oo ihan hyvä?
     * cOoL neW feAturEz
       - panorointi: kanavilla on oletuspanorointi, paitsi jos
         käytetään komentoa 8: SET PANNING. Oletuspanorointia voi
         muuttaa komennolla E8: SET DEFAULT PANNING.

ÄÄÄÄ version info: ??.05.1996 ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        + 0.02 kaikki on uutta

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

*/

#include "sd_main.h"

#define pt_maxchannels 32
#define pt_periodmin 27
#define pt_periodmax 3628

// Nuottien numerot alkavat 0:sta (C-1) ja loppuvat (NO_NOTE-1):een
#define NO_NOTE 84

// ---------------- PERIOD TABLE -------------------------------

unsigned short tuning[16][NO_NOTE+1] =
       {
       {3424,3232,3048,2880,2712,2560,2416,2280,2152,2032,1920,1812,
	1712,1616,1524,1440,1356,1280,1208,1140,1076,1016,960,906,
	856,808,762,720,678,640,604,570,538,508,480,453,
	428,404,381,360,339,320,302,285,269,254,240,226,
	214,202,190,180,170,160,151,143,135,127,120,113,
	107,101,95,90,85,80,75,71,67,63,60,56,
	53,50,47,45,42,40,37,35,33,31,30,28,28},

	       // tuning 1

       {3400,3209,3029,2859,2698,2547,2404,2269,2141,2021,1908,1801,
	1700,1604,1514,1429,1349,1273,1202,1134,1070,1010,954,900,
	850,802,757,715,674,637,601,567,535,505,477,450,
	425,401,379,357,337,318,300,284,268,253,239,225,
	213,201,189,179,169,159,150,142,134,126,119,113,
	106,100,94,89,84,79,75,70,66,63,59,56,
	53,50,47,44,42,39,37,35,33,31,29,28,28},

	       // tuning 2

       {3376,3186,3007,2838,2679,2529,2387,2253,2126,2007,1894,1788,
	1688,1593,1503,1419,1339,1264,1193,1126,1063,1003,947,894,
	844,796,752,709,670,632,597,563,532,502,474,447,
	422,398,376,355,335,316,298,282,266,251,237,224,
	211,199,188,177,167,158,149,141,133,125,118,112,
	106,100,94,88,83,79,74,70,66,62,59,55,
	53,50,47,44,41,39,37,35,33,31,29,28,28},

	       // tuning 3

       {3352,3164,2986,2818,2660,2511,2370,2237,2111,1993,1881,1775,
	1676,1582,1493,1409,1330,1255,1185,1118,1055,996,940,887,
	838,791,746,704,665,628,592,559,528,498,470,444,
	419,395,373,352,332,314,296,280,264,249,235,222,
	209,198,187,176,166,157,148,140,132,125,118,111,
	105,99,93,88,83,78,74,70,66,62,59,55,
	52,49,46,44,41,39,37,34,32,31,29,27,27},

	       // tuning 4

       {3328,3141,2964,2798,2641,2493,2353,2221,2096,1978,1867,1762,
	1664,1570,1482,1399,1320,1246,1176,1110,1048,989,933,881,
	832,785,741,699,660,623,588,555,524,495,467,441,
	416,392,370,350,330,312,294,278,262,247,233,220,
	208,196,185,175,165,156,147,139,131,124,117,110,
	104,98,92,87,82,78,73,69,65,62,58,55,
	52,49,46,43,41,39,36,34,32,31,29,27,27},

	       // tuning 5

       {3304,3118,2943,2278,2622,2475,2336,2205,2081,1964,1854,1750,
	1652,1559,1471,1389,1311,1237,1168,1102,1040,982,927,875,
	826,779,736,694,655,619,584,551,520,491,463,437,
	413,390,368,347,328,309,292,276,260,245,232,219,
	206,195,184,174,164,155,146,138,130,123,116,109,
	103,97,92,87,82,77,73,69,65,61,58,54,
	51,48,46,43,41,38,36,34,32,30,29,27,27},

	       // tuning 6

       {3280,3096,2922,2758,2603,2457,2319,2189,2066,1950,1840,1737,
	1640,1548,1461,1379,1301,1228,1159,1094,1033,975,920,868,
	820,774,730,689,651,614,580,547,516,487,460,434,
	410,387,365,345,325,307,290,274,258,244,230,217,
	205,193,183,172,163,154,145,137,129,122,115,109,
	102,96,91,86,81,77,72,68,64,61,57,54,
	51,48,45,43,40,38,36,34,32,30,28,27,27},

	       // tuning 7

       {3256,3073,2900,2737,2584,2439,2302,2173,2051,1936,1827,1724,
	1628,1536,1450,1368,1292,1219,1151,1086,1025,968,913,862,
	814,768,725,684,646,610,575,543,513,484,457,431,
	407,384,363,342,323,305,288,272,256,242,228,216,
	204,192,181,171,161,152,144,136,128,121,114,108,
	102,96,90,85,80,76,72,68,64,60,57,54,
	51,48,45,42,40,38,36,34,32,30,28,27,27},

	       // tuning -8

       {3628,3424,3232,3050,2879,2717,2565,2421,2285,2157,2036,1921,
	1814,1712,1616,1525,1439,1358,1282,1210,1142,1078,1018,960,
	907,856,808,762,720,678,640,604,570,538,508,480,
	453,428,404,381,360,339,320,302,285,269,254,240,
	226,214,202,190,180,170,160,151,143,135,127,120,
	113,106,100,95,90,85,80,75,71,67,63,60,
	56,53,50,47,44,42,40,37,35,33,31,30,30},

	       // tuning -7

       {3600,3398,3207,3027,2857,2696,2545,2402,2267,2140,2020,1907,
	1800,1699,1603,1513,1428,1348,1272,1201,1133,1070,1010,953,
	900,850,802,757,715,675,636,601,567,535,505,477,
	450,425,401,379,357,337,318,300,284,268,253,238,
	225,212,200,189,179,169,159,150,142,134,126,119,
	112,106,100,94,89,84,79,75,71,67,63,59,
	56,53,50,47,44,42,39,37,35,33,31,30,30},

	       // tuning -6

       {3576,3375,3185,3007,2838,2678,2528,2386,2252,2126,2006,1894,
	1788,1687,1592,1503,1409,1339,1264,1193,1126,1063,1003,947,
	894,844,796,752,709,670,632,597,563,532,502,474,
	447,422,398,376,355,335,316,298,282,266,251,237,
	223,211,199,188,177,167,158,149,141,133,125,118,
	111,105,99,93,88,83,78,74,70,66,62,59,
	56,52,49,46,44,41,39,37,35,33,31,29,29},

	       // tuning -5

       {3548,3348,3160,2983,2816,2657,2508,2368,2235,2109,1191,1879,
	1774,1674,1580,1491,1408,1328,1254,1184,1117,1054,995,939,
	887,838,791,746,704,665,628,592,559,528,498,470,
	444,419,395,373,352,332,314,296,280,264,249,235,
	222,209,198,187,176,166,157,148,140,132,125,118,
	111,104,98,93,88,83,78,74,69,66,62,58,
	56,52,49,46,44,41,39,37,34,33,31,29,29},

	       // tuning -4

       {3524,3326,3139,2963,2797,2640,2491,2351,2219,2095,1977,1866,
	1762,1663,1569,1481,1398,1320,1245,1175,1109,1047,988,933,
	881,832,785,741,699,660,623,588,555,524,494,467,
	441,416,392,370,350,330,312,294,278,262,247,233,
	220,208,196,185,175,165,156,147,139,131,123,117,
	110,104,98,92,87,82,77,73,69,65,61,58,
	55,52,49,46,43,41,38,36,34,32,30,29,29},

	       // tuning -3

       {3500,3303,3118,2943,2777,2622,2474,2335,2204,2081,1964,1854,
	1750,1651,1559,1471,1388,1311,1237,1167,1102,1040,982,927,
	875,826,779,736,694,655,619,584,551,520,491,463,
	437,413,390,368,347,328,309,292,276,260,245,232,
	219,206,195,184,174,164,155,146,138,130,123,116,
	109,103,97,92,87,82,77,73,69,65,61,58,
	55,51,48,46,43,41,38,36,34,32,30,29,29},

	       // tuning -2

       {3472,3277,3093,2919,2755,2601,2455,2317,2187,2064,1948,1839,
	1736,1638,1546,1459,1377,1300,1227,1158,1093,1032,974,919,
	868,820,774,730,689,651,614,580,547,516,487,460,
	434,410,387,365,345,325,307,290,274,258,244,230,
	217,205,193,183,172,163,154,145,137,129,122,115,
	108,102,96,92,86,82,77,72,68,64,61,57,
	54,51,48,46,43,40,38,36,34,32,30,28,28},

	       // tuning -1

       {3448,3254,3071,2899,2736,2583,2438,2031,2172,2050,1935,1826,
	1724,1627,1535,1449,1368,1291,1219,1150,1086,1025,967,913,
	862,814,768,725,684,646,610,575,543,513,484,457,
	431,407,384,363,342,323,305,288,272,256,242,228,
	216,203,192,181,171,161,152,144,136,128,121,114,
	108,102,96,91,85,81,76,72,68,64,60,57,
	54,51,48,45,42,40,38,36,34,32,30,28,28}

       };  // end-of-periods

// ------------ VIBRATO (sinus) TABLE -----------------------------

signed short *pt_vibratotable;
signed short *pt_tremolotable;

signed short pt_sinetable[64] =
        {0,24,49,74,97,120,141,161,180,197,212,224,235,244,250,253,
         255,253,250,244,235,224,212,197,180,161,141,120,97,74,49,24,
         0,-24,-49,-74,-97,-120,-141,-161,-180,-197,-212,-224,-235,
         -244,-250,-253,-255,-253,-250,-244,-235,-224,-212,-197,
         -180,-161,-141,-120,-97,-74,-49,-24};

signed short pt_ramptable[64];

signed short pt_squaretable[64] =
        {0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         255,255,255,255,255,255,255,255,
         255,255,255,255,255,255,255,255,
         0,0,0,0,0,0,0,0,
         0,0,0,0,0,0,0,0,
         -256,-256,-256,-256,-256,-256,-256,-256,
         -256,-256,-256,-256,-256,-256,-256,-256};

signed short pt_randtable[64];

signed short *pt_waveforms[4] = {pt_sinetable,
                                 pt_ramptable,
                                 pt_squaretable,
                                 pt_randtable};

// ihan pikkupikkuriikkisen levitetyt panoroinnit
unsigned char pt_defaultpan[32] =
      {7,9,9,7, 7,9,9,7, 7,9,9,7, 7,9,9,7,
       7,9,9,7, 7,9,9,7, 7,9,9,7, 7,9,9,7};

#define PAN_LEFT  0
#define PAN_RIGHT 15

// Amiga-tyyliset "hienot" panoroinnit
/*unsigned char pt_defaultpan[32] =
      {PAN_LEFT,PAN_RIGHT,PAN_RIGHT,PAN_LEFT,
       PAN_LEFT,PAN_RIGHT,PAN_RIGHT,PAN_LEFT,
       PAN_LEFT,PAN_RIGHT,PAN_RIGHT,PAN_LEFT,
       PAN_LEFT,PAN_RIGHT,PAN_RIGHT,PAN_LEFT}; */

// ihan kokeelliset panoroinnit vaan
/* unsigned char pt_defaultpan[32] =
      {1,5,10,14, 7,9,9,7, 7,9,9,7, 7,9,9,7,
       7,9,9,7, 7,9,9,7, 7,9,9,7, 7,9,9,7}; */

// MOD information ------------------------------

   unsigned  pt_channels;       // kanavien lukumäärä
   unsigned  pt_slen[32],       // samplen pituus
                  pt_loops[32],      // loopin alkukohta
                  pt_loope[32],      // loopin pituus (<=2, jos ei ole)
                  pt_svol[32];       // volume
   unsigned char  pt_finetune[32],   // finetune
                  pt_songlen,        // pituus orderissa
                  pt_lastpattern,    // korkein patternin numero
                  pt_order[128];     // "song order"
   unsigned char *pt_patterns[128];  // patternidata

// end-of-MOD-information -----------------------


// ------- channel specific variables --------

   int            pt_curperiod[32],    // kanavan nykyinen periodi
                  pt_curnote[32],      // kanavan nykyinen sävel
                  pt_curvol[32],       // kanavan nykyinen voimakkuus
                  pt_cursample[32],    // kanavan nykyinen sample
                  pt_tporta[32],       // tone portamenton nopeus
                  pt_curtarget[32],    // tone portamenton kohdeperiodi
		  pt_vibs[32],	       // vibraton nopeus
		  pt_vibd[32],	       // vibraton amplitudi ("depth")
		  pt_vibc[32],	       // vibraton laskuri (0..63)
		  pt_trms[32],	       // tremolon nopeus
		  pt_trmd[32],	       // tremolon amplitudi
                  pt_trmc[32],         // tremolon laskuri (0..63)
		  pt_curfine[32],      // kanavan nyk. finetune
		  pt_glissando[32],    // onko glissando?
		  pt_notedelay[32],    // delayn pituus (ec, e9, ed)
                  pt_pattdelay[32],    // montako riviä täytyy odotella
                  pt_pattloop[32],     // montako looppia on tekemättä
                  pt_pattloopstart[32],// ja mille riville loopataan
                  pt_pan[32];          // kanavan panorointi

// ------- end-of-channel specific variables --------

   unsigned int   pt_songpos,          // missä ollaan orderissa
		  pt_repstart,	       // mistä aletaan, kun orderi wrappaa
		  pt_firstline,        // miltä riviltä seuraava patt. alkaa
		  pt_vbcount,	       // lasketaan tickejä (0..vbtempo-1)
		  pt_curpattern,       // nykyisen patternin numero
		  pt_bpmtempo,	       // tempo, (bpmtempo = 2.5 * ticks/sec)
		  pt_vbtempo,	       // montako tickiä per rivi
                  pt_rowcount;         // millä rivillä ollaan

   unsigned char *pt_lineptr;        // osoitin riville

     // ---------- HUOM!
//     unsigned int pt_allocpatterns=0;  // varataanko patterneille muistia?
     // Oletusarvona patternipointerit laitetaan osoittamaan siihen
     // muistialueeseen, josta ne luetaan, eikä niille varata erikseen
     // muistia ja siirretä uuteen paikkaan. Siis jos mottuuli ladataan
     // levyltä, ei muistialuetta saa vapauttaa ja käyttää uudestaan,
     // jos tässä on nolla!!!

   unsigned char  *pt_errorstr; // tässä sitten lukee jotain tai ei lue...

   unsigned char   pt_modid[5];

   unsigned char  *pt_modid_table[] =
   {"2CHN", "4CHN", "M.K.", "M!K!", "FLT4", "FLT8", "OCTA", "6CHN", "8CHN",
    "10CH", "12CH", "14CH", "16CH", "18CH", "20CH", "22CH",
    "24CH", "26CH", "28CH", "30CH", "32CH", "STOP" };

   unsigned short pt_modid_channels_table[] =
   { 2, 4, 4, 4, 4, 8, 8, 6, 8,
     10, 12, 14, 16, 18, 20, 22,
     24, 26, 28, 30, 32, 0 };


void pt_init ()
// alustetaan ne muuttujat
{

        int c, i, j;

        for (c=0; c<32; c++)
        {
                pt_curperiod[c]=pt_curnote[c]=pt_curvol[c]=pt_cursample[c]=
                pt_tporta[c]=pt_curtarget[c]=0;
                pt_curfine[c]=0;
                pt_vibs[c]=pt_vibd[c]=pt_vibc[c]=
                pt_trms[c]=pt_trmd[c]=pt_trmc[c]=0;
                pt_pattdelay[c] = pt_pattloop[c] = pt_pattloopstart[c] = 0;
        }

        pt_songpos = -1; // seuraava on 0
        pt_firstline = 0;
        pt_vbtempo = 6; pt_bpmtempo = 125;
        pt_vbcount = pt_vbtempo-1; // seuraavalla mennään...
        pt_curpattern = 0;
        pt_rowcount = 63; // yli menee heti ekalla...

        pt_vibratotable = pt_sinetable;
        pt_tremolotable = pt_sinetable;

        for (i=0; i<64; i++)
        {
                pt_randtable[i] = (rand()%511)-256;
                pt_ramptable[i] = 255-i*8;
        }

} // pt_init

// ---------------- pt_convertpattern ----------------------
// Konvertoi MOD-patternin hienon
//     [smhi:perhi] [perlo] [smlo:cmd] [parm] -muodon
// vieläkin hienompaan
//     [smp] [note] [cmd] [parm] -muotoon.

void pt_convertpattern (unsigned char *src)
{

  unsigned int i, i2, ofs=0;
  unsigned short peri;
  for (i=0; i<(pt_channels*64); i++)
    {
      peri = (unsigned short)((src[ofs]&15)<<8) + (src[ofs+1]);

      src[ofs] = (src[ofs] & 0xF0) + ((src[ofs+2] & 0xF0) >> 4);
      src[ofs+2] &= 0xF;

      // haetaan perioditaulukosta ko. periodi
      for (i2=0; (i2<NO_NOTE) && (peri<tuning[0][i2]); i2++);

      src[ofs+1] = i2;

      // src[ofs+3] ei tarvitse käsittelyä

      ofs += 4; // seuraava nuotti
    }

} // convertpattern

// -------------------------------------------------------
// - Luetaanpas se MOD-file jostakin, eli pt_takemod -----
// -------------------------------------------------------

  unsigned char *rb_src; // rb eli read block
  int rb_ofs;

unsigned short read68kword ()
{ unsigned short i;

  i = (rb_src[rb_ofs]<<8) + rb_src[rb_ofs+1];
  rb_ofs += 2;
  return (i);
}

unsigned char readbyte () { return (rb_src[rb_ofs++]); }

void skipbytes (int length) { rb_ofs += length; }

int  pt_takemod (unsigned char *src)
// lukee MOD-fileen muistista (ei tiedostosta)
// palauttaa nollan, jos tuli virhe, 1 muulloin
{
  int i;

  rb_src = src; // alustetaan lukualue
  rb_ofs = 0;

  skipbytes (20); // hypätään nimi yli

  for (i=1; i<=31; i++)
    {
      skipbytes (22); // samplen nimi (ei tarvita mihinkään)
      pt_slen[i] = read68kword() * 2;    // samplen pituus
      pt_finetune[i] = readbyte() & 15;   // samplen finetune
      pt_svol[i] = readbyte();		  // samplen volume
      if (pt_svol[i] > 64) pt_svol[i] = 64;  // rajataan volume 64:ään
      pt_loops[i] = read68kword() * 2;   // loopin alku
      pt_loope[i] = read68kword() * 2;   // loopin pituus
    }
  pt_songlen = readbyte();	// song length
  pt_repstart = readbyte();	// repeat start
      if (pt_repstart > 126) pt_repstart = 0;

      for (i=0; i<128; i++) 	// song order
          pt_order[i] = readbyte();	// (128 bytes)

      pt_modid[4] = 0;

      for (i=0; i<=3; i++)
          pt_modid[i] = readbyte();	// mod id (4 chars)
  
  // onkohan tämä for-lause vai while? :)
  for (i=0; (strncmp(pt_modid_table[i], "STOP", 4)) &&
       (strncmp(pt_modid, pt_modid_table[i], 4)); i++)
      /*printf("Trying id %d...\n", i)*/;
  pt_channels = pt_modid_channels_table[i];
  	
  if (pt_channels == 0)
    {
      pt_errorstr = "pt_takemod error: unknown module type!";
      return (0);
    }

  // ---- etsitään korkein pattern-numero
  pt_lastpattern = 0;
  for (i=0; i<128; i++)
    if (pt_order[i] > pt_lastpattern)
      pt_lastpattern = pt_order[i];

  /* if (pt_allocpatterns) PÖÖ! OTA KOMMENTIT POIS JOS ON TARVIS!
       {
	 for (i=0; i<=pt_lastpattern; i++)
	   pt_patterns[i] = malloc(pt_channels*256);

       } */

  // konvertoidaan patternit ja asetetaan pointerit
  for (i=0; i<=pt_lastpattern; i++)
    {
      pt_patterns[i] = &rb_src[rb_ofs];
      pt_convertpattern (pt_patterns[i]);
      rb_ofs += pt_channels*256;
    }

  // ladataan samplet GUSin muistiin ja asetetaan muuttujat
  for (i=1; i<=31; i++)
  if (pt_slen[i] > 0)
  {

        if (pt_loope[i] > 2)
        {
                sd_getsample(i, &rb_src[rb_ofs], pt_slen[i],
                             pt_loops[i],
                             pt_loops[i] + pt_loope[i],
                             LOOP_NORMAL);
        }
        else
        {
                sd_getsample(i, &rb_src[rb_ofs], pt_slen[i],
                             pt_loops[i],
                             pt_loops[i] + pt_loope[i],
                             LOOP_OFF);
        }

        rb_ofs += pt_slen[i];

  } // (pt_slen[i] > 0)


        sd_setactivechannels(pt_channels);
  
  return (1);
} // pt_takemod

// ------------------------------------------------------------
// - pt_play () -----------------------------------------------
// ------------------------------------------------------------
// - No niin, nyt päästään Aasiaan! Tämän systeemin pitäisi ---
// - ihan soittaakin jotakin ilmoille. ------------------------
// ------------------------------------------------------------

void pt_play (void)
{
        int c, i, oldvbtempo, cmdprm;
        long l;
        unsigned char *row; // osoitin riville
        unsigned char sm, nt, cmd, prm;

        if ((pt_vbtempo)&&(++pt_vbcount>=pt_vbtempo))
//        if (++pt_vbcount>=pt_vbtempo)
        { /* uusi rivi otetaan nyt */
                pt_vbcount = 0;

                i = 0;
                for (c=0; c<pt_channels; c++)
                {
                        if (pt_pattdelay[c] > 0)
                        {
                                pt_pattdelay[c] --;
                                i++;
                        }
                }
                if (i>0) return;

                if (++pt_rowcount>=64)
                {
                        pt_rowcount = pt_firstline;
                        pt_firstline = 0;
                        if (++pt_songpos >= pt_songlen) pt_songpos = pt_repstart;
                } /* seuraava patterni */
                pt_curpattern = pt_order[pt_songpos];
                pt_lineptr =
			&(pt_patterns[pt_curpattern][pt_rowcount*pt_channels*4]);
		
        } /* Otettiin se uusi rivi sieltä */

        row = pt_lineptr;

        for (c=0; c<pt_channels; c++)
        {
                sm = row[0]; nt = row[1]; cmd = row[2]; prm = row[3];

		/* cmdprm = yhdistetty komento ja parametri */
                cmdprm = ((int)cmd << 8) + ((int)prm & 0xF0);
                if ((cmdprm&0xF00)!=0xE00) cmdprm = (cmdprm & 0xF00);

                sd_selectchannel (c);

                if (pt_vbcount == 0)
                { /* patternin käsittely, uusi rivi */
                        if (sm > 0)
                        {
                                pt_cursample[c] = sm;
                                pt_pan[c] = pt_defaultpan[c]<<4;
                                pt_curvol[c] = pt_svol[sm];
                                if (cmd!=0xC) sd_setvolume(pt_curvol[c]);
                                if (cmd!=8) sd_setpanning(pt_pan[c]);
                                sd_setsample(sm);
                        } /* if  samplen numero olemassa */
                        if (nt < NO_NOTE)
                        {
                                pt_curfine[c]=pt_finetune[pt_cursample[c]];
                                pt_curtarget[c] = tuning[pt_curfine[c]][nt];
                                if ((cmd!=3)&&(cmd!=5))
                                { /* ei tone portamentoa */
                                        if (cmdprm!=0xED0)
                                        { /* ei note delayta */
                                                pt_curperiod[c] = pt_curtarget[c];
                                                sd_setamigaperiod(pt_curperiod[c]);
                                                if (cmd!=9) sd_setoffset(0);
                                                pt_curnote[c] = nt;
                                        } /* ei note delayta */
                                } /* ei tone portamentoa */
                        } /* if  nuotti olemassa */

                        switch (cmdprm) /* komentojen käsittely, 1. kerta */
                        {
                                case 0x000: if (prm>0)
                                            sd_setamigaperiod(
                                                tuning[pt_curfine[c]]
                                                        [pt_curnote[c]]);
                                            break;
                                case 0x800: sd_setpanning(pt_pan[c]=prm); break;
                                case 0x900: sd_setoffset((int)prm<<8); break;
                                case 0xB00: pt_rowcount = 63;
                                            pt_songpos = prm - 1; break;
                                case 0xC00: sd_setvolume(pt_curvol[c]=prm); break;
                                case 0xD00: pt_rowcount = 63;
                                            pt_firstline = (prm >> 4) * 10 +
                                                           (prm & 0x0F); break;
                                case 0xE10: if (pt_curperiod[c]>pt_periodmax)
                                            {
                                                pt_curperiod[c]--;
                                                sd_setamigaperiod(pt_curperiod[c]);
                                            }
                                            break;
                                case 0xE20: if (pt_curperiod[c]<pt_periodmax)
                                            {
                                                pt_curperiod[c]++;
                                                sd_setamigaperiod(pt_curperiod[c]);
                                            }
                                            break;
                                case 0xE30: pt_glissando[c] = (prm&0xF);
                                            break;
                                case 0xE40: if ((prm&0xF)<4) pt_vibc[c]=0;
                                            pt_vibratotable = pt_waveforms[prm&3];
                                            break;
                                case 0xE50: pt_curfine[c] = (prm&0xF); break;
                                case 0xE60: if ((prm & 0x0F)==0)
                                                pt_pattloopstart[c] = pt_rowcount;
                                            else
                                            if (pt_pattloop[c] == 0)
                                            {
                                                pt_pattloop[c] = prm & 0x0F;
                                                pt_rowcount = pt_pattloopstart[c] - 1;
                                            }
                                            else
                                            if ((--pt_pattloop[c])>0)
                                                pt_rowcount = pt_pattloopstart[c] - 1;
                                            break;
                                case 0xE70: if ((prm&0xF)<4) pt_trmc[c]=0;
                                            pt_tremolotable = pt_waveforms[prm&3];
                                case 0xE80: sd_setpanning((pt_defaultpan[c]=(prm&0xF))<<4);
                                            break;
                                case 0xEA0: if (pt_curvol[c]<64)
                                            {
                                                pt_curvol[c]++;
                                                sd_setvolume(pt_curvol[c]);
                                            }
                                            break;
                                case 0xEB0: if (pt_curvol[c]>0)
                                            {
                                                pt_curvol[c]--;
                                                sd_setvolume(pt_curvol[c]);
                                            }
                                            break;
                                case 0xEE0: pt_pattdelay[c] = prm & 0x0F; break;
                                case 0xF00: if (prm<32) pt_vbtempo = prm;
                                            else pt_bpmtempo = prm;
                                            break;
                        } /* switch (cmdprm) */
                } /* patternin käsittely, uusi rivi, vbcount = 0 */
                else
                { /* patternin käsittely, ei uusi rivi */
                        switch (cmdprm) /* komentojen käsittely, 2. kerta */
                        {
                                case 0x000: if (prm!=0)
                                            switch (pt_vbcount%3) {
                                            case 0:
                                            sd_setamigaperiod(
                                                tuning[pt_curfine[c]]
                                                        [pt_curnote[c]]);
                                            break;
                                            case 2:
                                            sd_setamigaperiod(
                                                tuning[pt_curfine[c]]
                                                        [pt_curnote[c]+(prm&15)]);
                                            break;
                                            case 1:
                                            sd_setamigaperiod(
                                                tuning[pt_curfine[c]]
                                                        [pt_curnote[c]+(prm>>4)]);
                                            break; } /* switch */
                                            break;
                                case 0x100: pt_curperiod[c] -= prm;
                                            if (pt_curperiod[c]<pt_periodmin)
                                                pt_curperiod[c]=pt_periodmin;
                                            sd_setamigaperiod(pt_curperiod[c]);
                                            break;
                                case 0x200: pt_curperiod[c] += prm;
                                            if (pt_curperiod[c]>pt_periodmax)
                                                pt_curperiod[c]=pt_periodmax;
                                            sd_setamigaperiod(pt_curperiod[c]);
                                            break;
                                case 0x300: if (prm != 0) pt_tporta[c] = prm;
                                            if (pt_curperiod[c]<pt_curtarget[c])
                                            {
                                                    pt_curperiod[c] += (pt_tporta[c]);
                                                    if (pt_curperiod[c]>pt_curtarget[c])
                                                    pt_curperiod[c] = pt_curtarget[c];
                                            }
                                            else
                                            if (pt_curperiod[c]>pt_curtarget[c])
                                            {
                                                    pt_curperiod[c] -= (pt_tporta[c]);
                                                    if (pt_curperiod[c]<pt_curtarget[c])
                                                    pt_curperiod[c] = pt_curtarget[c];
                                            }
                                            if (!pt_glissando[c])
                                                    sd_setamigaperiod(pt_curperiod[c]);
                                            else
                                            {
                                                    for (i=NO_NOTE; (((tuning[pt_curfine[c]][i])<pt_curperiod[c])
                                                               && (i>0)); i--);
                                                    sd_setamigaperiod(tuning[pt_curfine[c]][i]);
                                            }
                                            break;
                                case 0x400: if ((prm&0x0F) > 0) pt_vibd[c]=(prm&0xF);
                                            if ((prm&0xF0) > 0) pt_vibs[c]=(prm>>4);
                                            sd_setamigaperiod (pt_curperiod[c] +
                                                               pt_vibratotable[pt_vibc[c]]*pt_vibd[c] / 127);
                                            pt_vibc[c] = (pt_vibc[c]+pt_vibs[c]) & 63;
                                            break;
                                case 0x500: if (pt_curperiod[c]<pt_curtarget[c])
                                            {
                                            pt_curperiod[c] += pt_tporta[c];
                                            if (pt_curperiod[c]>pt_curtarget[c])
                                            pt_curperiod[c] = pt_curtarget[c];
                                            }
                                            else
                                            if (pt_curperiod[c]>pt_curtarget[c])
                                            {
                                            pt_curperiod[c] -= pt_tporta[c];
                                            if (pt_curperiod[c]<pt_curtarget[c])
                                            pt_curperiod[c] = pt_curtarget[c];
                                            }

                                            sd_setamigaperiod(pt_curperiod[c]);

                                            goto dovolslideandbehappy;

                                            break;
                                case 0x600: sd_setamigaperiod (pt_curperiod[c] +
                                                               pt_vibratotable[pt_vibc[c]]*pt_vibd[c] / 127);
                                            pt_vibc[c] = (pt_vibc[c]+pt_vibs[c]) & 63;
                                            goto dovolslideandbehappy;
                                            break;
                                case 0x700: if ((prm&0x0F) > 0) pt_trmd[c]=(prm&0xF)*2;
                                            if ((prm&0xF0) > 0) pt_trms[c]=(prm>>4);
                                            i = pt_curvol[c] +
                                                pt_tremolotable[pt_trmc[c]]*pt_trmd[c] / 127;
                                            pt_trmc[c] = (pt_trmc[c]+pt_trms[c]) & 63;
                                            if (i<0) i=0; if (i>64) i=64;
                                            sd_setvolume(i);
                                            break;
                                case 0xA00: dovolslideandbehappy:
                                            if (prm > 15)
                                            pt_curvol[c] += (prm >> 4);
                                            else
                                            pt_curvol[c] -= (prm & 15);
                                            if (pt_curvol[c]<0) pt_curvol[c]=0;
                                            else
                                            if (pt_curvol[c]>64) pt_curvol[c]=64;
                                            sd_setvolume(pt_curvol[c]);
                                            break;
                                case 0xE90: if ((prm&0xF)>0)
                                            if ((nt<NO_NOTE)&&/*(*/((pt_vbcount%(prm&0xF))==0)
                                                /* || ((pt_vbcount==pt_vbtempo-1)
                                                  &&((prm&0xF)>=pt_vbtempo))) */
                                                 )
                                            {
                                                pt_curperiod[c] = tuning[pt_curfine[c]][nt];
                                                sd_setvolume(pt_curvol[c]);
                                                sd_setamigaperiod(pt_curperiod[c]);
                                                sd_setoffset(0);
                                            }
                                            break;
                                case 0xEC0: if ((pt_vbcount==(prm&0xF))||
                                                ((pt_vbcount==pt_vbtempo-1)
                                                  &&((prm&0xF)>=pt_vbtempo)))
                                            {
                                                sd_setvolume(0);
                                                /* sd_stopsample(); ?? */
                                            } break;
                                case 0xED0: if (
                                                        (nt<NO_NOTE)
                                                        &&
                                                        (
                                                                (pt_vbcount==(prm&0xF))
                                                                ||
                                                                (
                                                                        (pt_vbcount==(pt_vbtempo-1))
                                                                        &&
                                                                        ((prm&0xF)>=pt_vbtempo)
                                                                )
                                                        )
                                               )
                                            {
                                                pt_curnote[c] = nt;
                                                pt_curperiod[c] = tuning[pt_curfine[c]][nt];
                                                sd_setvolume(pt_curvol[c]);
                                                sd_setamigaperiod(pt_curperiod[c]);
                                                sd_setoffset(0);
                                            }
                                            break;
                        } /* switch (cmdprm) */
                } /* patternin käsittely, ei uusi rivi */

                row += 4;
        } /* for channels */
} /* pt_play */

