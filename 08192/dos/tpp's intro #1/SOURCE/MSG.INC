;
; Message-file for TPP's intro #1. (C)1996 TPP Devlopments.
;

NoVGAMsg  db 13,10,'VGA card not detected! Hey... is this an XT or what???'
          db 13,10,13,10,"$"

; Main msg: must have a 9-chars 'title, message finished with 1, end with 0.
;           Message window is 32 x 10 chars.
; Title valid chars  : A...Z
; Message valid chars: A...Z, 0...9, (, ), ., coma, ', -, ?, !, #

MainMsg   db "THE INTRO"
          db " TPP PRESENTS (NOT TOO PROUDLY) "
          db "  HIS FIRST REAL INTRO RELEASE  "
          db "  CALLED...                     "
          db "                                "
          db "                                "
          db "       - TPP'S INTRO #1 -       "
          db "                                "
          db "                                "
          db " (YES, ALLRIGHT, BUT ATLEAST IS "
          db "     KINDA ORIGINAL, HUH?)      "
          ;
          db "                                "
          db "AS YOU SURELY GUESSED,THIS INTRO"
          db "IS A SEND-SOME-MESSYS ONE,SO I'D"
          db "SUGGEST THAT IF YOU DISLIKE THIS"
          db "CREATURE, HAVE IN MIND THAT IT'S"
          db " PURPOSE IS TO SEND SOME GREETS "
          db "AND TO GIVE ME A BREAK OF CODING"
          db "SOME MORE ADVANCED (AND COMPLEX)"
          db "STUFF....                       "
          db "                                "
          db 1
          db "GREETINGS"
          db " OK, BEFORE YOU GET ASLEEP, I'D "
          db " LIKE TO SEND FROM HERE A..FEW? "
          db " GREETS.                        "
          db "                                "
          db "  WHOLE TLH - WHOLE BRAINSTORM  "
          db "   (HOW'S YOUR WORKS COMING?)   "
          db "                                "
          db "           WHOLE DLD            "
          db "  (ALWAYS A PLEASURE TO MEET!)  "
          db "                                "
          ;
          db "MAX - TLH (TNX FOR ALL!)        "
          db "TSL - BRS (LIKE THE ADDY?)      "
          db "JOSE LUIS (COOLEST GUY ARROUND!)"
          db "PATO      (THE SAME ABOVE)      "
          db "MPG       (LEAVE WINDOWS 95!!!!)"
          db "                                "
          db " GUYS AT FIDO... ALOT OF PEPOLE "
          db "  TO MENTION HERE, BUT YA KNOW  "
          db "WHO YOU'RE, ANYWAY. I'VE LEARNED"
          db "  MORE THERE THAN ANYWARE ELSE  "
          ;
          db 1
          db "SOME INFO"
          db "                                "
          db "  WELL...THE CODE ITSELF 'AINT  "
          db " SOMETHING SPECTACULAR.... THIS "
          db " INTRO WAS CODED ON A 386 DX.IT "
          db " WAS COMPILED WITH TASM 3.1,AND "
          db " THE GFXS WERE MADE WITH DELUXE "
          db "PAINT 2 ENCHANCED.IT TOOK ALMOST"
          db "6 DAYS TO CODE AND DRAW ALL FROM"
          db "            SCRATCH.            "
          db "                                "
          ;
          db "BTW, DO YOU RECOGNIZE THIS FONT?"
          db "  NAH... WELL, IS A PIX-BY-PIX  "
          db " COPY FROM HACKER (THE GOOD OLD "
          db "   C64.. SNIF). I'VE GOT SOME   "
          db " SCREENSHOTS IN AN OLD MAG, AND "
          db " I FOUND THE FONT NICE ENOUGH.. "
          db "                                "
          db "  (WELL, ATLEAST ON THAT GAME   "
          db "       LOOKED GREAT...)         "
          db "                                "
          ;
          db "                                "
          db "THE MUSIC.. WELL, I'VE SOME NICE"
          db "  MODS FROM ANONYMUS COMPOSERS  "
          db " IN MY HD, BUT THE FACT IS THAT "
          db "I HAVEN'T FINISHED MY S3M REPLAY"
          db " YET, I'VE NO TIME ETHIER.. AND "
          db "  I THINK THIS ONE DESERVES NO  "
          db " MUSIC ANYWAY... MAYBE THE NEXT "
          db "  WOULD USE STMIK, WHO KNOWS?   "
          db "                                "
          ;
          db 1
          db " THE END "
          db "                                "
          db "                                "
          db "                                "
          db "            WRAPPING            "
          db "           ARROUND...           "
          db "                                "
          db "                                "
          db "                                "
          db "                                "
          db "                                "
          db 0
