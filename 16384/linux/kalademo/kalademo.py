# -*- coding: utf-8 -*-
import sys, os
import curses, time, curses.wrapper, random
from kalademo_data import *

def demo(screen):
    screen = curses.initscr()
    curses.start_color()
    curses.init_pair(1, 6, 4)
    curses.init_pair(2, 5, 4)
    curses.init_pair(3, 2, 4)
    curses.init_pair(4, 7, 4)
    curses.init_pair(5, 3, 4)

    vsininen = curses.color_pair(1)
    pinkki = curses.color_pair(2)
    vihrea = curses.color_pair(3)
    valkoinen = curses.color_pair(4)
    keltainen = curses.color_pair(5)
    #scr = screen
    scr = screen.subwin(43, 104, 0, 0)
    max_y, max_x = scr.getmaxyx()
    curses.curs_set(0)
    scr.leaveok(1)

    def ui(kala, rng, param_y, param_x, \
           lisakalat=0, lisakala_y=5, lisakala_x=0, \
           reverse=False, tauko=0.2, koordinaatit=False):

        color = keltainen
        keskikohta  = len(kala)/2
        keskikala   = kala[keskikohta]
        kalanpituus = len(keskikala)

        def osakala(kala, paikka, koordinaatit=False):
            for j in range(len(kala)):
                osakala = kala[j]
                if x >= max_x or x <= 0:
                    break             
                else:
                    scr.addstr([(y-j-1), y, (y+j+1)][paikka], x, osakala, color)
                    if koordinaatit:
                        piste = str(x-3).zfill(2)+","+str(max_y-y-4).zfill(2)
                        scr.addstr(y, [x+4, x+2][reverse], piste, color)
                        ruudulle(max_y-1, 1, koordinaatisto, vsininen, 0)

        for i in range(rng):
            if reverse: x = param_x-i-10
            else: x = param_x+i+10
            y = param_y


            osakala(kala[:keskikohta], 0, koordinaatit)
            osakala([keskikala], 1, koordinaatit)
            osakala(kala[keskikohta+1:], 2, koordinaatit)
            
            if lisakalat:
                y = param_y-lisakala_y
                x = x-kalanpituus+lisakala_x
                for i in range(lisakalat):
                    ui(kala, 1, y, x, \
                       0, lisakala_y, lisakala_x, \
                       reverse, tauko, koordinaatit)
                    y = y-lisakala_y # jokainen kala on lisakala_y:n verran edellistä korkeammalla
                    x = x-lisakala_x # jokainen kala on lisakala_x:n verran edellisen oikealla
            else:
                time.sleep(tauko)

            scr.refresh()

    def randompaikka(reuna=1):
        x = random.randint(reuna-1, max_x-reuna)
        y = random.randint(reuna-1, max_y-reuna)
        return y, x

    def kuplia(rng, tauko=0.2):
        for i in range(rng):
          ilmakupla = random.choice("Oo0")
          y, x = randompaikka(13)
          scr.addch(y, x, ilmakupla)
          time.sleep(tauko)
          ruudulle(max_y-1, 1, [vesikasvit1, vesikasvit2][i%2==0], vihrea, 0.05)
          scr.refresh()

    def ruudulle(param_y, param_x, teksti, vari, tauko=0.1):
        y, x = param_y, param_x
        for rivi in teksti:
            scr.addstr(y, x, rivi, vari)
            y = y-1
            time.sleep(tauko)
            scr.refresh()

    def kalajahti(jahtikala, jahtikala_rev, saaliskala, rng, param_y, param_x):
        ruudulle(max_y-1, 1, vesikasvit1, vihrea, 0)
        jy, jx = sy, sx = param_y, param_x

        for i in range(rng):
            if i<14:
                sx = sx+1
                ui(saaliskala, 1, sy, sx)
            elif i==14:
                ruudulle(sy-3, sx+15, apua, keltainen, 0.06)
                time.sleep(1)
                ruudulle(sy-3, sx+15, [' '*len(a) for a in apua], vsininen, 0.03)

            elif i%3==0:
                jx = jx+1
                ui(jahtikala, 1, jy, jx, tauko=0.05)
            else:
                sx = sx+1
                ui(saaliskala, 1, sy, sx, tauko=0.15)
        
        ruudulle(sy+1, sx, ['    '*len(s) for s in saaliskala], vsininen, 0.08)
        ruudulle(jy-4, jx+15, hoh, keltainen, 0.06)
        time.sleep(1)
        ruudulle(jy-4, jx+15, [' '*len(h) for h in hoh], vsininen, 0.03)
        ui(jahtikala_rev, jx+19, jy, jx+21, tauko=0.1, reverse=True)
        ruudulle(max_y-16, 1, [' '*len(j) for j in jahtikala], vsininen, 0.03)
        
    def onnistunut_kalajahti(jahtikala, jahtikala_iso, saaliskala, rng, param_y, param_x):
        ruudulle(max_y-1, 1, vesikasvit1, vihrea, 0)
        jy, jx = sy, sx = param_y, param_x

        for i in range(rng):
            if i<14:
                sx = sx+1
                ui(saaliskala, 1, sy, sx)
            elif i==14:
                ruudulle(sy-3, sx+15, apua, keltainen, 0.06)
                time.sleep(1)
                ruudulle(sy-3, sx+15, [' '*len(a) for a in apua], vsininen, 0.03)
            elif i%2==0:
                jx = jx+2
                ui(jahtikala, 2, jy, jx, tauko=0.1)
            elif i<=20:
                sx = sx+1
                ui(saaliskala, 1, sy, sx, tauko=0.2)

        ruudulle(jy-4, jx+15, jee, keltainen, 0.06)
        time.sleep(0.5)
        ui(jahtikala_iso, 1, jy, jx)
        time.sleep(1.5)
        ruudulle(jy-4, jx+15, [' '*len(j) for j in jee], vsininen, 0.03)
        ui(jahtikala_iso, 83, jy, jx, tauko=0.1)


    # nyt alkaa
    # kalat ui ruudun päästä päähän
    scr.bkgd(" ", vsininen)
    ruudulle(max_y-1, 1, vesikasvit1, vihrea, 0.001)
    ui(pikkukala(True), 95, max_y-23, max_x,  reverse=True, tauko=0.2)
    ruudulle(max_y-23, 1, [' '*6], vihrea, 0.03)
    ui(keskikala("+"), 95, max_y-20, -10, lisakalat=3, tauko=0.07)
    scr.clear()


    # teksti KALADEMO
    ruudulle(max_y-1,  1, otsikko, vsininen)
    ruudulle(max_y-8,  1, otsikko[::-1], valkoinen)
    ruudulle(max_y-15, 1, otsikko, vsininen)
    ruudulle(max_y-22, 1, otsikko[::-1], valkoinen)
    ruudulle(max_y-29, 1, otsikko, vsininen)
    ruudulle(max_y-36, 1, otsikko[::-1], valkoinen)
    time.sleep(1)
    scr.bkgd(" ", pinkki)
    scr.refresh()
    time.sleep(1)
    scr.bkgd(" ", valkoinen)
    scr.refresh()
    time.sleep(1)
    scr.clear()
    scr.bkgd(" ", vsininen)
    scr.refresh()

    # kuplat
    ruudulle(max_y-1, 1, vesikasvit2, vihrea, 0.001)
    kuplia(25)
    scr.clear()

    # koordinaatisto
    # tässon äänetki!
    ruudulle(max_y-1, 1, koordinaatisto, vsininen, 0)
    ui(koordinaattikala(), 30, max_y-20, -10, koordinaatit=True)
    curses.beep()
    ui(koordinaattikala(True), 35, max_y-32, max_x, reverse=True, koordinaatit=True)
    curses.beep()
    ui(koordinaattikala(), 65, max_y-12, -10, \
       lisakalat=1, lisakala_y=5, lisakala_x=20, tauko=0.1, koordinaatit=True)
    curses.beep()
    time.sleep(0.05)
    curses.beep()
    time.sleep(0.5)
    for i in range(10):
        y, x = randompaikka(reuna=15)
        if i%2==0:
            ui(koordinaattikala(), 1, y, x, \
               tauko=1, koordinaatit=True)
            curses.beep()
        else:
            ui(koordinaattikala(True), 1, y, x, \
               reverse=True, tauko=1, koordinaatit=True)
            curses.beep()
    scr.clear()

    # epäonninen ja onnistunut kalajahti
    ruudulle(max_y-1, 1, vesikasvit1, vihrea, 0.01)
    kalajahti(isokala('+'), isokala('+', True), keskikala('*'), 145, max_y-18, -13)
    onnistunut_kalajahti(isokala('+'), jattikala('+'), pikkukala(), 30, max_y-18, -13)    
    scr.clear()

    # loppukuplat ja -tekstit
    ruudulle(max_y-1, 1, vesikasvit2, vihrea, 0.001)
    kuplia(55, 0.01)
    ruudulle(25, 25, kiitos, valkoinen, 0.2)
    time.sleep(4)

if __name__ == "__main__":
    curses.wrapper(demo)