;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

polypar struc
  polyScrPtr dd 0A0000h
  polyScrWid dd 320
  polyMinX dd 0
  polyMaxX dd 320
  polyMinY dd 0
  polyMaxY dd 200
  polyDrawLine dd ?
  polyCoords dd ?
  polyTxtPtr dd ?
  polyTxt2Ptr dd ?
ends

polyloc struc
  toppointpar dd 0
  currow dd 0
  midrow dd 0
  endrow dd 0
  calcseg3 dd 0

  scrpos dd 0
  curx1 dd 0
  curx2 dd 0
  dltx1 dd 0
  dltx2 dd 0
  lastx1 dd 0

  widthconst dd 0
  diffy2 dd 0
  diffy3 dd 0
  diffx2 dd 0
  diffx3 dd 0
  shiftdown db 0,0,0,0

  diffx1 dd 0
  diffy1 dd 0
  coords dd 0,0,0,0,0,0

  cachex dd 0
  cachex1 dd 0
  dltpx dd 0,0,0,0,0,0
  curpv dd 0,0,0,0,0,0
  cachedltpx dd 0,0,0,0,0,0
  dltpy dd 0,0,0,0,0,0
ends

polydata struc
  polyloc <>
  par polypar <>
ends

global polyLocals:polyloc
global _polyPar:polypar
