DIM raster(40, 2)
DIM virt(4000)
DIM hame(1000)
DIM hime(1000)
DIM teksti$(21)

SCREEN 0
WIDTH 40, 25
CLS

pee = 2 * pi
koht = 190

FOR x = 0 TO 12
  READ raster(x, 0)
  READ raster(x, 1)
  raster(25 - x, 0) = raster(x, 0)
  raster(25 - x, 1) = raster(x, 1)
NEXT x

FOR x = 0 TO 8
  READ raster(26 + x, 0)
  READ raster(26 + x, 1)
NEXT x

FOR x = 0 TO 20
  READ teksti$(x)
NEXT x
puokki = INT(20 - LEN(teksti$(0)) / 2)

DO
  READ eppo$
  skrolleri$ = skrolleri$ + eppo$
LOOP UNTIL eppo$ = " "
vika = LEN(skrolleri$) - 80


FOR y = 0 TO 99
  FOR x = 0 TO 39
    k = x + y * 40
    virt(k) = 13 + INT((SIN(x / 6.36) - COS(y / 6.36)) * 6.5)
  NEXT x
NEXT y
FOR x = 0 TO 999
  hime(x) = virt(x)
NEXT x

DEF SEG = &HB800

FOR x = 0 TO 39
  POKE 961 + x * 2, 15
NEXT x

POKE 961, 0: POKE 963, 1: POKE 965, 5: POKE 967, 13
POKE 1033, 13: POKE 1035, 5: POKE 1037, 1: POKE 1039, 0


DO
  kello = TIMER + .01
  d = d + 1
  z = z + .05
  ee = ee + .03
  guu = SIN(ee) * 15
  IF z > pee THEN z = z - pee
 
  p = (38 + INT(SIN(z) * 38)) * 40

    FOR x = 0 TO 999
      dee = x + p + INT(SIN((d + x) / 100) * guu)
      IF dee < 0 THEN dee = 0
      IF dee > 3999 THEN dee = 3999
      hame(x) = virt(dee)
    NEXT x
   
    goo = 40
    FOR y = 0 TO 10
      FOR x = 1 TO LEN(teksti$(y))
        kee$ = MID$(teksti$(y), x, 1)
        IF kee$ = "*" THEN
          hame(goo + x - 1) = 26 + INT(hame(goo + x - 1) / 3)
        ELSEIF kee$ = "." THEN
          hame(goo + x - 1) = 0
        END IF
      NEXT x
      goo = goo + 40
    NEXT y
   
    goo = 480
    FOR y = 0 TO 11
      FOR x = 1 TO LEN(teksti$(y + 10))
        kee$ = MID$(teksti$(y + 10), x, 1)
        IF kee$ = "*" THEN
          hame(goo + x - 1) = 26 + INT(hame(goo + x - 1) / 3)
        ELSEIF kee$ = "." THEN
          hame(goo + x - 1) = 0
        END IF
      NEXT x
      goo = goo + 40
    NEXT y
 
  FOR x = 0 TO 958 STEP 2
    k = hame(x / 2)
    POKE x, raster(k, 0)
    POKE x + 1, raster(k, 1)
  NEXT x


  FOR x = 1040 TO 1998 STEP 2
    k = hame(x / 2)
    POKE x, raster(k, 0)
    POKE x + 1, raster(k, 1)
  NEXT x


  nahka = nahka + .5
  IF nahka < 1 THEN nahka = 1
  IF nahka > vika THEN nahka = vika
  FOR x = 0 TO 39
    POKE 960 + x * 2, ASC(MID$(skrolleri$, INT(nahka) + x, 1))
  NEXT x

  DO: LOOP WHILE kello > TIMER

  IF INKEY$ = CHR$(27) THEN END

LOOP






DATA 32,0, 176,1, 177,1, 178,1, 219,1
DATA 176,20, 177,20, 178,20, 219,20
DATA 176,77, 177,77, 178,77, 219,77
DATA 219,&h0a, 178,&h2a, 177,&h2a, 176,&h2a, 32,&h2a
DATA 178,&h02, 177,&h02, 176,&h02, 32,&h02

DATA "                  .                     "
DATA "                 .*.                    "
DATA "                 .*.                    "
DATA "           .     .*.        .           "
DATA "           .    .***.     ..            "
DATA "          .*.   .***.    .*.            "
DATA "          .*..  .***.   .*.             "
DATA "          .**.. .***. ..**.             "
DATA "          ..**...***...***.             "
DATA "     ..    .***..***..***.      .       "
DATA "     .*.    .**..***..***.     .*.      "

DATA "      .****...**.***.**....*****..      "
DATA "       ...***..**.*.**..***.....        "
DATA "          ...**..***..**...             "
DATA "            ...*******...               "
DATA "           ..**...*...**...             "
DATA "          .**..  .*.  ..***.            "
DATA "         .*..    .*.    ...             "
DATA "          .       .*.                   "
DATA "                   .*.                  "
DATA "                    .                   "

DATA "                                          "
DATA " -- L A U M A T A J U   O P A S T A A --  "
DATA "                                          "
DATA " 'KANNABIS ON PORTTI HUUMEISIIN' "
DATA "                                          "
DATA "Kannabisyhdistys kampanjoi Suomessa voimakkaasti kannabiksen "
DATA "laillistamisen puolesta kertoo auliisti kyseess„ olevan puhtaan "
DATA "luonnontuotteen, jolla ei ole haittavaikutuksia. Yleens„ he vetoavat "
DATA "siihen, ett„ kannabis aiheuttaa v„hemm„n haittoja, kuin alkoholi.    "
DATA "Suomessa on yli 2 miljoonaa alkoholin k„ytt„j„„ ja arviolta 50-60000 "
DATA "kannabiksen k„ytt„j„„. Kannabiksen k„yt”n yleistymisen my”t„ my”s "
DATA "rauhoittavien l„„kkeitten k„ytt” on lis„„ntynyt ja nimenomaan siin„ "
DATA "ryhm„ss„, joka k„ytt„„ kannabista on kasvu ollut voimakasta. "
DATA "Suomessa on lukuisia suuryrityksi„, joita johtaa alkoholisti mutta ei ainuttakaan sellaista, jonka johtajana on kannabiksen vakiok„ytt„j„!!!! "
DATA "Yliopistoissa opiskelevat tiet„v„t tarkkaan, ett„ kannabiksen k„ytt” on lopetettava ainakin viikko ennen tenttej„, koska muuten lukemisesta tai keskittymisest„ ei tule mit„„n. "
DATA "Kannabisyhdistys vetoaa yleens„ Hollannin esimerkkiin ja siihen, ett„ eih„n siell„k„„n ole mit„„n ongelmia huumeen suhteen. Valitettavan yksipuolista tietoa.... "
DATA "Hollannista joutuu joka vuosi hoitoon 30 000 ihmist„ ja valtaosa kannabiksen vuoksi. "
DATA "Hollannin tulliin tai poliisiin ei maailmalla luota kukaan suurten huumeongelmien takia. Esim. YK ei palkkaa Hollantilaisia poliiseja siviilipoliiseiksi. "
DATA "T„ss„ vain pieni osa Hollannin todellisista ongelmista, joita kannabis aiheuttaa.   "
DATA "Kannabisyhdistys kiist„„ nk. porttiteorian, jonka mukaan k„ytt„j„t siirtyv„t miedommista aineista k„ytt„m„„n kovempia. "
DATA "Valitettavasti kovien aineiden k„ytt„j„t l„hes poikkeuksetta ovat kertoneet aloittaneensa kannabiksesta, eli yhdistys valehtelee tietoisesti. "
DATA "Koukuttaako huume ja miss„ ajassa? Yleisp„tev„„ vastausta kysymykseen ei ole. On ihmisi„, jotka juovat viinaa koko ik„ns„ tulematta alkoholisteiksi, eli he pystyv„t lopettamaan koska tahansa. "
DATA "Samoin on ihmisi„, jotka pystyv„t lopettamaan huumausaineiden k„yt”n noin vain ja jopa pit„m„„n sen viikonloppuk„ytt”n„ mutta heit„ ei ole paljon. Lis„ksi kukaan ei tied„, kuka on se, joka j„„ koukkuun... "
DATA "On ihmisi„, jotka ovat j„„neet koukkuun ensimm„isest„ hasispiipusta, tai amfetamiinipiikist„. "
DATA "Jos kannabis laillistettaisiin, olisi kaikilla Suomalaisilla oikeus sit„ my”s k„ytt„„, vai olisiko sittenk„„n? "
DATA "Mitk„ ammattiryhm„t rajattaisiin perustuslain vastaisesti ulkopuolelle ? Mit„ sanoisitte, jos poliisit, liikennelent„j„t, bussikuskit, taksikuskit, junankuljettajat, l„„k„rit, sairaanhoitajat, palomiehet ym.
DATA "avainammattilaiset alkaisivat k„ytt„„ hasista? "
DATA "Menisitk” leikattavaksi l„„k„rille, jonka tiet„isit s„„nn”llisesti k„ytt„v„n huumeita? Mit„ sanoisit, jos sinua oikeudessa tuomitseva tuomari olisi huumeenk„ytt„j„? "
DATA "Ent„ jos joutuisit tekemisiin poliisin kanssa, jonka tiet„isit vapaa-aikoinaan k„ytt„v„n kannabista? "
DATA "Valitettavasti jotkut Suomalaiset julkishenkil”t ovat lehtien palstoilla ilmoittaneet, ett„ heid„n mielest„„n on jokaisen oma asia, jos k„ytt„„ huumausaineita, kuten n„yttelij„ Irina Bj”rklund haastattelussaan sanoi. "
DATA "Onko huumeita k„ytt„v„ ihminen sitten yksin aineensa kanssa? Ei ole...jokaista k„ytt„j„„ kohti k„rsii ainakin 20 muuta ihmist„. "
DATA "K„ytt„j„n omaiset ovat yht„lailla k„rsij”it„, kaveripiiri ja muut omaiset my”skin. Unohtaa ei sovi veronmaksajia! "
DATA "Huumeriippuvaisen hoito maksaa helposti miljoona vanhaa markkaa vuodessa. Kun siihen lis„t„„n rikosvahinkojen korvaukset, rauhoittavat l„„kkeet ja sairaala, sek„ l„„k„rikulut, oikeudenk„yntikulut yms. "
DATA "et menot, joita aineista aiheutuu, puhutaan huikeista summista, jotka kaikki ovat poissa mm. vanhustenhoidosta. "
DATA "Armeijan helikopterihankinnoista on noussut hirve„ meteli ja tunteikkaasti ollaan vedottu sairaan- ja vanhustenhoitoon ja niiden tilaan. "
DATA "Jokainen veronmaksaja kustantaa pelk„st„„n rauhoittavina l„„kkein„ ja l„„k„rikuluina narkomaaneille v„hint„„n saman summan, kuin joutuisi maksamaan armeijan hankinnoista mutta kukaan poliitikkomme, "
DATA "tai p„„tt„j„t eiv„t ole uskaltaneet ottaa sanallakaan puheeksi t„t„ asiaa. "
DATA "Jos pieness„ 10 000 asukkaan kunnassa on asutettuna esim 10 narkomaania, voi jokainen laskea, kuinka paljon jokainen veroja maksava kuntalainen maksaa vuosittain n„iden el„tt„misest„ ja hoidosta! "
DATA "Jos t„m„n j„lkeen viel„ joku tosissaan v„itt„„, ett„ huumeiden k„ytt” on jokaisen oma asia, niin... "

DATA "                                          "
DATA " "

