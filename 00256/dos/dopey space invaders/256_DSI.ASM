;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Most .ASM files are dead boring to read. I will try and rectify this.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;
;Remember DSI? The gaming company that made all those great old games like
;Stunts... DSI also stands for:
;
;ÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ Û Û    ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ    ÛÛÛ Û Û Û Û ÛÛÛ ÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ
;Û Û Û Û Û Û Û   Û Û    Û   Û Û Û Û  Û Û Û       Û  ÛÛÛ Û Û Û Û Û Û Û   Û Û Û
;Û Û Û Û ÛÛÛ ÛÛ   Û     ÛÛÛ ÛÛÛ ÛÛÛ  Û   ÛÛ      Û  ÛÛÛ Û Û ÛÛÛ Û Û ÛÛ  ÛÛ  ÛÛÛ
;Û Û Û Û Û   Û    Û       Û Û   Û Û  Û Û Û       Û  ÛÛÛ Û Û Û Û Û Û Û   Û Û   Û
;ÛÛ  ÛÛÛ Û   ÛÛÛ  Û     ÛÛÛ Û   Û Û  ÛÛÛ ÛÛÛ    ÛÛÛ Û Û  Û  Û Û ÛÛ  ÛÛÛ Û Û ÛÛÛ
;
;
;DON'T YOU HATE PEOPLE WHO SHOUT AT YOU?
;Don't you hate people who answer their own questions? yeah!
;There are three types of people... those who can count and those who can't.
;"The only good thing about the swedish are their knives.", Aussie pub, 28/11/97
;  (now I will start a war... whoops, sorry. Hit me in the head... free shot.)
;
; My top score:   ";"    which equates to something like about 27.
;
; Do I win the most compiliations for a 256 byte entry?... 1113 times...
;

;Main aim of game:
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Move the ship back and fourth and take out as many alien ships as possible.
;Haven't you seen ID4 yet?

;Controls:
;ÄÄÄÄÄÄÄÄÄ
;Left :         Right <ALT>
;Right:         Right <CTRL>
;Fire :         Left  <SHIFT>
;Quit :         Right <SHIFT>


;Music
;ÄÄÄÄÄ
;none.
;(couldn't quite fit in the 200 odd K of 44khz samples.)


;Questions
;ÄÄÄÄÄÄÄÄÄ
;Q1) Why do the aliens scroll so crappy, and why do they go over the screen
;    boundary?
;A1) What are you talking about? I fixed that!.
;
;Q2) This game sux. My dog can code better.
;A2) My cat coded this. Would I put my name on this junk?
;
;Q3) Hey! Wow! this is the coolest game I have ever played. How did you do it?
;A3) Ask my cat.
;
;Q4) ...in 256 bytes? I could have done that in 120 and entered it in the
;       128 byte compo a few years ago, and that's with VGA and everything.
;A4) Well good for you. You are better than my cat. I suck, you are a guru,
;       and you can't even ask a proper question. It should go in the
;       statement section.
;
;Q5) Your code is hard to read! why did you do that for?
;A5) If you want the code, then just dump it in DEBUG or any other debugger.
;    I don't know why I did it... just to make it hard to read I guess.
;    "TD 256_DSI.COM"
;
;Q6) When I change the number of aliens, your code won't compile.
;A6) It will under TASM. Use it.  "TASM /M9 256_DSI" / "TLINK /T 256_DSI"
;
;Q7) Why is the cursor still there?
;A7) Coz I err... my cat ran out of room. Anyway, it is the Mother Ship that
;    you can't kill.
;
;Q8) Hey your game is too hard to play, even with four aliens....
;A8) well... I can only get around 27 of the little fellows, and I am no
;    game player. I haven't even finished Sam & Max, and Monkey Island 2 yet,
;    let alone Doom 2, Quake...
;
;Q9) Hey this game is too easy! When does it get harder?
;A9) When you up the "No_Aliens" below, to around 20.
;
;Q10) Why dont you clear the screen when you hit Quit?
;A11) I couldn't fit in a lousy 5 bytes. Can you?


;...and remember to watch out for those beady liitle eyes. They're everywhere!
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;log file:
;KEYBOARD/DISPLAY SHIP/QUIT
;178 bytes. not looking good at all!
;173, 149 bytes. ~40 bytes need to be taken off!
;109 bytes. hey! did it. awesome. 147 bytes to play with. woo-hoo!
;105 bytes (6.ASM). 151 bytes to play with now. 5 more & I'll call it quits.
;97 bytes... keeps going down. when will this stop?
;
;KEYBOARD/DISPLAY/ALIEN/FIRE and fancy alien DNA sticky stuff that stinks.
;256 bytes.
;
;21-Feb. Decided to fix the scrolly aliens so it looked much better,
;        unfortunatley I have now lost the nice CLS when one quits.
;        Though I think it is worth having a nice scrolling aliens than a
;        dopey old buggy back & forth & jump-up aliens which are all over the
;        place, and forego the nice 5 byte CLS. Just can't fit it in...
;        Can you?

;
;Get a dog up ya, and drive a Jack'd up Subey with 33x12/r15's! ...eh Grumble?
;Six sevens are forty, 2 nines are 8 and who put this bloody shoe on my head?

;As usual I do things the hard way. Take a quick squiz at the stupid way I
; move the alien. I know that there is a much better way of doing this...
; there has to be. Just wish I knew what it was! My method is way too big!!


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

;The town of Quirindi today declared war against people driving over the
; towns only round-about. A spokesman for the tooth-pick company said
; "Gee, thats too bad.", while I received four hours of community service.

;The game started off well, the ball being dropped into
 freds segment ;which helped Mr Freds win the game 4-nill.

 Public ;outrage was the venue of today's game when Ms Walker ran across the
 ; field bare-naked. Police authories quickly caught and covered the 22 year
 ; old, while the crowd was going bezerk.

;The towns only historic site
			      ORG 100H ;may have its name changed shortly.
;The new name will become ORG 101H, due to the owners memory loss.

;The organisers of the bazzare happenings of late have come under
;spot-light. The mayor of the town speculated that if something is not soon
;the town may as well pack up and go home. A question was asked "where is home,
;if home is not here". Mr Mayor got confused, grabbed his coat, and left the
;building, via the back door.

;Mr Roger Wilco of Xenon today put a motion forward that the road
; "Assume Cresent", 15 kilometers north of the town, should be renamed to:
  Assume Cs                                                         : Freds
; back for more in Night Mare on Elm Street part 48. Opening tonight!

;Overheard the otherday...
;" Whats under the bonnet?"
;" 454 bored out to
                    .386 ;"
;" ...err?!  bored out to what?"
;" to 386. Dont you know anything?"
;" nah... obviously not.", turns around to the bloke behind him and says
;" what the hell is this bloke on about? who has ever heard of boring a 454
;" out to .386?"
;" buggered if I know mate."

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ


No_Aliens       equ     4


;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

I      :mov     al, 11b                 ;010
        int     10000b                  ;010
        mov     bl, 110101b             ;010
am     :push    cs                      ;001   Remove this and it wont work!
        pop     es                      ;001   ...because I said so thats why!
        mov     dx, 154 - (no_aliens * 4) ;10010110b           ;011
        mov     di, offset @@           ;011
        mov     eax, 00000111100101000000011100100000b      ;110
        mov     cl, No_Aliens           ;010
        rep     stosd                   ;011
        push    1011100000000000b       ;011
        pop     es                      ;001
        mov     eax, 00000111110111000000011111011100b      ;110
        mov     cl, 100b                ;010
        mov     di, 110111011010b       ;011
wacked :stosd                           ;010
        add     di, 11110b              ;011
        loop    wacked                  ;010
        xor     di, di                  ;010
        xor     bp, bp                  ;010
up     :pusha                           ;001
        mov     dx, 1111011010b         ;011
on     :in      al, dx                  ;001
        test    al, 1000b               ;010
        je      on                      ;010
scooby :in      al, dx                  ;001
        test    al, 1000b               ;010
        jne     scooby                  ;010
        call    @@ÿÿÿÿÿÿÿÿÿÿ            ;011
        push    cs                      ;001
        pop     ds                      ;001
        mov     si, offset @@           ;011
        mov     cx, No_Aliens * 10b     ;011
        rep     movsw                   ;010
        popa                            ;001
        push    es                      ;001
        pop     ds                      ;001
        push    0                       ;010
        pop     fs                      ;010
        mov     al, fs:[10000010111b]   ;100
        test    al, 1                   ;010
        je      snacks                  ;010
;        mov     ax, 11b   ;cant fit it  ;011    Nice exit! Gotta have this.
;        int     10000b    ;in.          ;010    Dont you hate all of those
        ret                             ;001    old games that had no exit/
snacks :test    al, 10b                 ;010    quit in them? How bloody hard
        je      @@ÿ                     ;010    is it to wack in:
        or      si, si                  ;010       ASM
        jg      @@ÿ                     ;010          MOV AX, 3
        lea     si, [bx+10001b]         ;011          INT 10h
        mov     byte ptr [si], 10110011b;011          MOV AX, 4Ch
@@ÿ             :                       ;             INT 21h
        test    al, 100b                ;010       END
        je      @@ÿÿ                    ;010
        inc     bx                      ;001
        inc     bx                      ;001       eh? thats want I want
        cmp     bl, 1111110b            ;011       to know!
        jge     @@ÿÿÿ                   ;010
@@ÿÿ            :
        test    al, 1000b               ;010
        je      @@ÿÿÿÿ                  ;010
@@ÿÿÿ           :
        sub     bl, 10b                 ;011
        jge     @@ÿÿÿÿ                  ;010
        inc     bx                      ;001
        inc     bx                      ;001
@@ÿÿÿÿ          :
        mov     bh, 1111b               ;010
        test    si, si                  ;010
        jle     @@ÿÿÿÿÿ                 ;010
        mov     byte ptr [si], 100000b  ;011
        sub     si, 10100000b           ;100
        mov     al, 10110011b           ;010
        xchg    byte ptr [si], al       ;010
        cmp     al, 10010100b           ;010
        jne     @@ÿÿÿÿÿ                 ;010
        inc     byte ptr ds:[111110011100b]  ;111 "kill-your-mam-with-an-axe-
        mov     byte ptr [si], 100000b  ;011       score" routine. huge!
        inc     bp                      ;001
        push    cs                      ;001
        pop     es                      ;001
	pusha                         ;A 1 for the money
	mov     si, di                ;A 2 for the show
        mov     di, offset @@         ;A 3 for the blues, now go cat go...
        mov     cl, No_Aliens * 100b    ;010              ;Elvis couldn't sing.
        rep     movsw                   ;010
        popa                            ;001
        push    ds                      ;001
        pop     es                      ;001
@@ÿÿÿÿÿ         :
        mov     dword ptr [bx+ 1101b], 00000111110111000000011100100000b        ;6
	mov     dword ptr [bx+10001b], 00000111110111000000011111011011b
	mov     byte  ptr [bx+10101b], 00100000b
        cmp     bp, No_Aliens - 1       ;011
        jg      am                      ;100
        cmp     di, 111100000010b       ;100
        jg      @@ÿÿÿÿÿÿÿÿÿÿÿ           ;010
        test    cl, cl                  ;010
        jne     @@ÿÿÿÿÿÿÿ      ÿ        ;010
        inc     di                      ;001
        inc     di                      ;001
        cmp     di, dx                  ;010
        jne     @@ÿÿÿÿÿÿÿÿÿ             ;010
        inc     cx                      ;001
        jmp     @@ÿÿÿÿÿÿÿÿ              ;010
@@ÿÿÿÿÿÿÿ       :
        dec     di                      ;001
        dec     di                      ;001
        push    dx                      ;001
        add     dx, (No_Aliens * 100b) + (No_Aliens * 010b)   ;011
        cmp     di, dx                  ;010
        pop     dx                      ;001
        jg      @@ÿÿÿÿÿÿÿÿÿ
        dec     cx                      ;001
        add     dx, 101000000b          ;100
@@ÿÿÿÿÿÿÿÿ      :
        call    @@ÿÿÿÿÿÿÿÿÿÿ            ;011
        add     di, 10100000b           ;100
@@ÿÿÿÿÿÿÿÿÿ     :
        jmp     up                      ;011
@@ÿÿÿÿÿÿÿÿÿÿ    :
        pusha                           ;001
        mov     cl, (No_Aliens + 1)*10b ;010
        mov     al, 100000b             ;010
        rep     stosw                   ;010
        popa                            ;001
@@ÿÿÿÿÿÿÿÿÿÿÿ   :
        ret                             ;001
@@ÿÿÿÿÿÿÿÿÿÿÿÿÿ db      0
@@              dw      No_Aliens dup (?)        ;0






;...and so the life of Mr
                   Freds ends ;having a heart attack after the third quarter.
                 ; The game was too violent, the all-blacks receiving
                 ; 12 penalties in the first-half while Yardi Morrison
                 ; pulled an iron bar out from jersey and up'd the coach.
                 ; The sight of blood caused Mr Freds to go into a state of
                 ; massive shock, and being unfit, his life ended in a massive
                 ; heart attack on the field.  Max had to race him to the
                 ; hospital though on his way, missed the turn, and ended up
                 ; in a dead
                             end                               I ;meanwhile
                 ; stayed until the saga had finished and was quite tired
                 ; when I finally got home.

      ;That's it.. Good luck. And keep on dancing.
                                                                      ÿ
                                                                      ÿ
