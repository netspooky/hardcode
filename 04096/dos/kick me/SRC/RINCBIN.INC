;
;    Rincbin 2.1     01/8/1994    philippe Rhode (c)1994
;

incbin                  macro  nom,taille
                        local  @@deb,@@fin
@@deb                   label  byte
                        db     '~Riá'
                        dd     taille
                        db     nom,0
@@fin                   label  byte
                        db     taille-(@@fin-@@deb) dup (0)
                        endm