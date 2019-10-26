#include "std.h"
#include "mesha.hpp"

// #define PARTY

int MainAnim = 0;
int Anim[][256] = {

//--------------------------------------
// Scene1
//--------------------------------------
  {
    APROC, 1, 1,0,1, 0,         // fa tabla
    APROC, 2, 1,1,5, 4,         // meshes szoveg (delay kell majd)
    AWAIT, 8,
    APROC, 3, 1,6,18, 2,        // url szoveg (delay kell majd)
    AWAIT, 7,
    AWAIT, 4,
    APROC, 4, 1,0,6, 0,         // fa+szovegek
    APROC, 4, 1,6,18, 0,        // fa+szovegek
    AWAIT, 6,
    AWAIT, 4,
    AFADE,

    AJMP, 5,
    AQUIT },

// fatabla beporgese
  { APOS, 0,0,7,
    ADIR, 0,0,5,
    ADDIR, 1,2,3,
    ADPOS, -7,7,-7,
    AADJUST,15,
    AWAIT, 8,
    ANODPOS,
    ANODDIR,
    AEND,
    AQUIT },

// meshes cim bejovetel
  {
    APOS,  7,-3,-4,
    ADIR, 6,6,0,
    ADPOS, 5,0,0,
    AADJUST,1,
    ADDIR,2,2,0,
    ADPOS,0,0,3,
    AWAIT,8,
    ANODDIR,
    ANODPOS,

    APOS, 0,0,7,
    AOFS, 7,-3,-4,
    ADOFS, 5,0,0,
    AADJUST,1,
    ANODOFS,
    AEND,
    AQUIT },
// 3 url cim bejovetel
  { ASIZE, 4,
    APOS, 0,0,6,
    AOFS, 6,6,4,  // 7,5,-4,
    ADOFS, 3,0,0,
    AADJUST,7,
//    ADDIR, -6,-6,-6,
//    ADOFS, 5,-4,-4,
//    ADPOS, 0,0,5,
//    AWAIT,5,
    ADDIR, -5,-5,-5,
    ADOFS, 4,-3,-3,
    ADPOS, 0,0,4,
    AWAIT,6,
    ANODOFS,
    ANODDIR,
    ANODPOS,
    AEND,
    AQUIT },
// 4 fatabla es betuk kiporgese
  {
    ADPOS, -1,-1,-4,
    ADDIR, -1,0,3,
    AEND,
    AQUIT },

//--------------------------------------
// Scene2
//--------------------------------------
  {
    APROC, 1, 7,0,1, 0,         // hatter
    APROC, 2, 7,1,12, 4,
    AWAIT, 8,
    APROC, 2, 7,12,14, 4,
#ifndef PARTY
    AWAIT, 8,
    APROC, 2, 7,26,10, 4,
#endif
    AWAIT, 9,
    AFADE,

 //-------
    APROC, 3, 3,0,10,  0,         // wormhole
    APROC, 4, 3,1,8,  5,         // 8golyo
    AWAIT, 9,
    AFADE,

    AJMP, 5,
    AQUIT },

// 2d hatter
  { APOS, 0,0,8,
    ADPOS, 0,0,3,
    AADJUST,0,
    ANODPOS,
    ADDIR, 0,0,3,
    AEND,
    AQUIT },

// text
  { ADIR, 0,-5,3,
    APOS, 8,0,5,
    ADPOS, -5,0,0,
    ADDIR, 1,2,0,
    AWAIT, 8,
    ASIZE, 0,
    AEND,
    AQUIT },

  { ADIR,4,0,0,
    ADDIR,0,4,0,
    APOS,0,6,7,
    ADPOS,0,0,1,
    AEND,
    AQUIT },

  { AOFS,0,-4,0,
    ADDIR,0,-3,0,
    ADOFS,0,-4,1,
    AWAIT,7,
    ADOFS,0,0,2,
    AWAIT,7,
    ANODOFS,
    AEND,
    AQUIT },

//--------------------------------------
// Scene
//--------------------------------------
  {
    APROC, 1, 5,1,2, 0,         // karok
    APROC, 3, 5,3,1, 0,         // kozepso obj
    APROC, 6, 5,0,3, 0,         // hatter + karok

    AWAIT, 9,
    APROC, 2, 5,4,7, 5,         // bejon ASM szoveg
    AWAIT, 9,
    AFADE,
    AJMP,8,
    AQUIT },

  { AOFS, 0,8,0,        // karok
    AWAIT,7,
    ADOFS,0,-5,0,
    AWAIT,7,
    ANODOFS,
    AEND,
    AQUIT },

  { APOS,0,-7,7,
    AOFS,0,0,-6,
    ADDIR, 0,3,0,
    ADPOS, 0,4,0,
    AWAIT, 7,
    ANODPOS,
    AEND,
    AQUIT },

// kozepen forgo object elol
  { APOS, 0,0,5,
    ADDIR, 2,3,0,
    ADPOS, 0,0,3,
    AWAIT, 7,
    AWAIT, 6,
    ANODPOS,
    AQUIT },

// kozepen forgo object
  { APOS, 0,0,7,
    ADDIR, 2,3,0,
    AEND,
    AQUIT },

// forgo betuk
  { AOFS, 0,0,-6,
    ADDIR, 0,-4,0,
    AADJUST,0,
    ADDIR, 2,5,0,
    AEND,
    AQUIT },

// hatter
  { APOS, 0,0,7,
    AQUIT },

  { ADIR, 1,4,0,
    ADDIR,0,0,6,
    AADJUST,1,
    ADDIR, 0,1,0,
    AWAIT,8,
    ADPOS, 0,0,-1,
    AWAIT,7,
    ANODPOS,
    AEND,
    AQUIT },

  {
  //-------
    APROC, -2, 6,0,3, 0,          // hatter
    APROC, 2, 6,1,2, 0,           // ket arc
    AWAIT, 10,
    AFADE,

 //-------
    APROC, 1, 4,0,3, 0,         // hatter
    APROC, 3, 4,1,1, 0,         // alatet
    APROC, 4, 4,2,1, 0,         // forgo
    AWAIT, 9,
    AFADE,

 //-------
    APROC, -2, 2,0,1, 0,         // hatter
    APROC, -4, 2,1,8, 0,         // kozepso obj
    APROC, -3, 2,2,7, 0,         // the end szoveg
    AWAIT, 9,
    AFADE,

    ASIZE, -1,
    AEND,
    AQUIT },

  { APOS, 0,-6,7,                // hatter lejebb
    ADIR, 4,0,0,
    ADDIR,0,2,0,
    AWAIT,8,
    ADPOS,0,3,0,
    AEND,
    AQUIT },

// ketarc
  { APOS,8,0,7,
    ADPOS,-4,0,-1,
    ADDIR,2,3,0,
    AWAIT,9,
    AWAIT,8,
    ADPOS, -3,0,-2,
    AEND,
    AQUIT },

  { AOFS,0,8,0,
    ADOFS,0,-4,0,
    AWAIT,7,
    ANODOFS,
    AEND,
    AQUIT },

  { AOFS,0,-6,0,
    ADOFS,0,6,0,
    AADJUST,2,
    ANODOFS,
    ADDIR,0,5,0,
    AWAIT,7,
    ADOFS,0,5,0,
    AWAIT,7,
    ANODOFS,
    AEND,
    AQUIT },

  { AQUIT }
};

int Object[][256] = {
// Format: objno,ref,mat,col
// 0 fa tabla
// 1 arc
// 2 vagott gomb
// 3 wormhole
// 4 center metal csikos fenyeffekt
// 5 gomb belso ter
// 6 gomb
// 7 reaktor
// 8 tuskegomb
// 9 gombfuvokak
// 10 tartoelem

{ // 0: temp object for main process (after every fade activated)
     ' ',0,0,0,
-1,},
{ // Obj1: fatablan es cim
  // 0: fatable
     0,0,5,14,
  // 1..5: 6 'MESHA'
     'M',0,4,9,'E',-1,'S',-1,'H',-1,'A',-1,
  // 6..23: 18 'RHYME.SCENE-HU.COM'
#ifdef PARTY
     ' ',-1,'W',-1,'W',-1,'W',-1,'.',-1,'S',-1,'C',-1,'E',-1,'N',-1,'E',-1,'-',-1,'H',-1,'U',-1,'.',-1,'C',-1,'O',-1,'M',-1,' ',-1,
#else
     'R',-1,'H',-1,'Y',-1,'M',-1,'E',-1,'.',-1,'S',-1,'C',-1,'E',-1,'N',-1,'E',-1,'-',-1,'H',-1,'U',-1,'.',-1,'C',-1,'O',-1,'M',-1,
#endif
-1},
{ //Obj2: the end gombben
  // 0: hatter gomb
     5,0,3,8,
  // 1: vagott gomb
     2,0,2,13,
  // 2..8: 7 'THE END'
     'T',1,2,11,'H',-1,'E',-1,' ',-1,'E',-1,'N',-1,'D',-1,
-1},
{ //Obj3: wormholebol kijonnek a gombok es kint fogognak
  // 0: wormhole
     3,0,0,11,
  // 1..8: 8 gomb
     6,1,4,8,6,-1,6,-1,6,-1,6,-1,6,-1,6,-1,6,-1,' ',-1,
-1},
{ //Obj4: tarto elojon raesik a gombfuvoka
  // 0: talaj
     5,0,3,13,
  // 1: tartoelem
     10,0,4,14,
  // 2: gombfuvoka
     9,0,0,14,
-1},
{ //Obj5: tuskefogog majd reaktor karok es asm98 felirat
  // 0: hattergomb
     5,0,3,14,
  // 1..2: 2 reaktor kar
     7,0,3,13,7,-1,
  // 3: tuskegomb
     8,0,4,8,
  // 4..9: 6 'ASM'98'
     'A',1,2,0,'S',-1,'M',-1,'1',-1,'9',-1,'9',-1,'8',-1,
-1},
{ //Obj6: dupla arc, gombben
  // 0: hatter gomb
     5,0,5,5,
  // 1..2: 2 arc
     1,1,1,0,
     1,1,1,5,
-1},
{ //Obj7: napszeru hatter, szovegek
  // 0: hatter
     4,1,2,0,
  // 1..12: 12 'ULTIMATE 3D '
     'U',1,2,8,'L',-1,'T',-1,'I',-1,'M',-1,'A',-1,'T',-1,'E',-1,
     ' ',-1,'3',-1,'D',-1,' ',-1,
  // 12..25: 14 ' IN 4096 BYTES' (elso space az elozobol jon)
     'I',-1,'N',-1,' ',-1,'4',-1,'0',-1,'9',-1,'6',-1,' ',-1,
     'B',-1,'Y',-1,'T',-1,'E',-1,'S',-1,
  // 26..35: 10 'BY PICARD '
     'B',-1,'Y',-1,' ',-1,'P',-1,'I',-1,'C',-1,'A',-1,'R',-1,
     'D',-1,' ',-1,
-1},

/*--------------
{ //Obj3: gombok '8' palyan
  // 0: hatter gomb
     7,0,4,2,
  // 1..8: 8 gomb
     8,1,2,12,8,-1,8,-1,8,-1,8,-1,8,-1,8,-1,8,-1,
-1},

{ //Obj6: negycsucsos terben kozepen object
  // 0: ter
     5,0,3,5,
  // 1: bemelyedeses gomb
     10,0,1,12,
-1},
{ //Obj10: napszeru hatter egyoldasas arc atforog
  // 0: hatter
     6,1,3,0,
  // 1: arc
     1,0,3,7,
-1},
{ //Obj9: [] torus
  // 0: hatter gomb
     7,0,2,9,
  // 1..8: 8 '['
     '[',0,3,7,'[',-1,'[',-1,'[',-1,'[',-1,'[',-1,'[',-1,'[',-1,
  // 9..17: 8 ']'
     ']',0,3,7,']',-1,']',-1,']',-1,']',-1,']',-1,']',-1,']',-1,
-1},

{ //Obj13: 2d metal hatter effekt wormhole lyukaval, szoveg
  // 0: 2d hatter
     3,1,5,3,
  // 1..10: 10 'IMPRESSED?'
     'I',0,2,1,'M',-1,'P',-1,'R',-1,'E',-1,'S',-1,'S',-1,'E',-1,
     'D',-1,'?',-1,
-1},
*/
/*
{ //Obj4: wormholebol greatings
  // 0: wormhole
     3,0,3,4,
  // 1..22: 22 'GREATINGS TO EVERYBODY'
     'G',1,3,0,'R',-1,'E',-1,'A',-1,'T',-1,'I',-1,'N',-1,'G',-1,'S',-1,
     ' ',-1,'T',-1,'O',-1,' ',-1,'E',-1,'V',-1,'E',-1,'R',-1,'Y',-1,
     'B',-1,'O',-1,'D',-1,'Y',-1,
-1},
*/

{-1}
};

schar Model[] = {
// 0 fa tabla
    8,10,11,
      0,6,1, 0,0,0,
      0,7,0, 0,1,0,
      3,6,1, 0,0,0,
      4,7,0, 1,1,0,
      3,0,1, 0,0,0,
      4,0,0, 1,0,0,
      0,0,1, 0,0,0,
      0,0,0, 0,0,0,
    3,
      P4,1,3,2,0,
      P4,3,5,4,2,
      P33,0,2,6,4,
  MMIRRORY,
  MMIRRORX,
  MMIRRORZ,
  MNEW,3,

// 1 arc
    15,9,9,
      0,0,-8,    0,0,-6,
      4,0,-7,   0,0,0,
      0,-3,-8,    0,-2,0,
      0,-4,-3,   0,-1,4,
      4,-2,-7,   +2,2,-2,
      3,-3,-5,  +3,0,-1,
      6,0,-3,   0,0,0,
      5,0,2,    0,0,2,    // ny-1
      4,-2,-1,   -2,-1,-1,
      4,-3,-3,   +1,1,0,
      0,-4,-2,   0,1,-1,
      2,-3,-1,   -1,-1,-2,
      3,-2,3,    +1,1,2,
      0,-6,2,    0,-1,1,
      3,0,6,    +1,0,1,   // ny-1
    0,
  MVERTEX,
    6,9,9,
      2,-3,2,    -2,-1,2,
      0,-3,6,     0,-2,0,
      1,-5,2,   1,0,0,
      0,-4,3,    0,0,1,
      0,-1,7,     0,-6,3,
      0,0,7,      0,0,0,

    15,
      P33,19,14,16,12,
      P33,14,7,12,8,
      P33,2,4,0,1,
      P3,1,4,6,
      P33,4,2,5,3,
      P33,5,3,9,10,
      P33,9,6,5,4,
      P33,7,6,8,9,
      P33,9,10,8,11,
      P33,12,8,15,11,
      P33,11,10,15,17,
      P33,10,13,17,18,
      P33,18,16,15,12,
      P3,18,15,17,
      P3,14,19,20,
  MMIRRORX,
//  MMIRRORZ,
  MNEW,3,

// 2 vagott gomb
    4,9,10,
      7,3,1, 7,0,0,
      1,7,1, 0,7,0,
      1,3,7, 0,0,7,
      1,3,1, 0,0,0,
    2,
      P33,0,2,1,3,
      P33,2,0,3,1,
  MMIRRORX,
  MMIRRORY,
  MMIRRORZ,
  MNEW,3,

// 3 wormhole
    6,11,10,
      -7,-7,0, -4,7,0,
      0,-7,7, 0,7,4,
      -5,-7,5, -2,7,2,
      0,-3,1, 0,0,3,
      -1,-3,0, -3,0,0,
      0,2,0,  0,-7,0,
    3,
      P33,0,2,4,3,
      P3,4,3,5,
      P3,2,1,3,
  MMIRRORZ,
  MMIRRORX,
  MNEWS,4,

/*
// 4 lapos krater
    3,11,11,
      7,0,-2, 0,0,2,
      0,7,-2, 0,0,2,
      0,0,0, 0,0,3,
    1,
      P3,2,0,1,
  MMIRRORY,
  MMIRRORX,
  MNEW,4,       //XY mapping kell, mert lapos, sphere szaru nez ki
// 5 kozepso negy csucsos belso ter
    3,11,15,
      1,0,0, 5,0,0,
      0,7,0, 0,1,0,
      0,0,1, 0,0,5,
    1,
      P3, 1,2,0,
  MMIRRORY,
  MMIRRORX,
  MMIRRORZ,
  MNEWS,4,
*/

// 4 center metal csikos fenyeffekt
    4,11,10,
      0,1,-7, 0,7,0,
      1,0,-7, 7,0,0,
      0,0,7, 0,0,0,
      0,0,7, 0,0,0,
    1,
      P4, 2,1,0,3,
  MMIRRORY,
  MMIRRORX,
  MNEW,5,

// 5 gomb belso ter
    3,12,12,
      3,0,0, 7,0,0,
      0,3,0, 0,7,0,
      0,0,3, 0,0,7,
    1,
      P3,0,1,2,
  MMIRRORX,
  MMIRRORY,
  MMIRRORZ,
  MNEWS,3,

// 6 gomb
    3,7,7,
      4,0,0, 7,0,0,
      0,4,0, 0,7,0,
      0,0,4, 0,0,7,
    1,
      P3,2,1,0,
  MMIRRORX,
  MMIRRORY,
  MMIRRORZ,
  MNEW,3,

// 7 reaktor
    6,10,11,
      4,7,0, -7,-2,-5,
      0,7,4, 3,2,-7,
      0,2,1, 1,0,0,
      1,2,0, 0,0,2,
      1,2,0, 7,-6,0,
      0,2,1, 0,-7,6,
    2,
      P4, 3,2,1,0,
      P4, 2,3,4,5,
  MMIRRORZ,
  MMIRRORX,
  MNEW,4,

// 8 tuskegomb
    4,8,10,
      0,0,7, 0,0,-3,
      0,7,0, 0,-3,0,
      7,0,0, -3,0,0,
      4,4,4, 0,0,0,
    2,
      P33, 0,1,3,2,
      P3,  0,3,2,
  MMIRRORZ,
  MMIRRORX,
  MMIRRORY,
  MNEW,3,

/*
// 11 bemelyedeses gomb
    4,8,10,
      0,0,5, 0,0,3,
      0,5,0, 0,3,0,
      5,0,0, 3,0,0,
      2,2,2, -1,-1,-1,
    2,
      P33, 0,1,3,2,
      P3,  0,3,2,
  MMIRRORZ,
  MMIRRORX,
  MMIRRORY,
  MNEW,4,
*/

// 9 gombfuvokak
    4,10,12,
      0,0,1, 0,0,3,
      0,1,0, 0,3,0,
      1,0,0, 3,0,0,
      2,2,2, 1,1,1,
    2,
      P33, 0,1,3,2,
      P3,  0,3,2,
  MMIRRORZ,
  MMIRRORX,
  MMIRRORY,
  MNEW,4,

// 10 tartoelem
    4,10,12,
      0,2,5, 0,4,7,
      -5,2,0, -7,4,0,
      0,1,2, 0,0,1,
      -2,1,0, -1,0,0,
    1,
      P4, 1,3,2,0,
  MMIRRORY,
  MVERTEX,
    0,
    2,
      P4, 1,5,4,0,
      P4, 2,6,7,3,
  MMIRRORX,
  MMIRRORZ,
  MQUIT,4

};
