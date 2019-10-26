/*
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                                                                          ú
      ÜÜÜ  ÜÜÜ ÜÜÜ  ÜÜÜ ÜÜÜ ÜÜÜ ÜÜÜ  ÜÜÜ ÜÜÜÜÜÜÜÜ ÜÜÜ     ÜÜÜ ÜÜÜ  ÜÜÜ    ù
      ÛÛÛ  ÛÛÛ ÛÛÛÛÜÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛÛÜÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ     ÛÛÛ ÛÛÛÛÜÛÛÛ    |
      ÛÛÛ  ÛÛÛ ÛÛÛ ßÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ ßÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ     ÛÛÛ ÛÛÛ ßÛÛÛ    ³
      ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛßÛÜÜ ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ     ÛÛÛ ÛÛÛ  ÛÛÛ    ³
      ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ     ÛÛÛ ÛÛÛ  ÛÛÛ    ³
      ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ  Û  ÛÛÛ ÛÛÛ  ÛÛÛ    ³
      ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛ  ÛÛÛ ÛÛÛÜÛßÛÜÛÛÛ ÛÛÛ  ÛÛÛ    ³
      ßßßßßßßß ßßß  ßßß ßßß ßßß ßßß  ßßß ßßßßßßßß ßßßß   ßßßß ßßß  ßßß    ³
                                                                          ³
      °±°±±²²ÛÛÜÜÜÜÜÜÜÜÜ                             ÜÜÜÜÜÜÜÜÜÛÛ²²±±°±°   ³
                       ßßß²²ÛÜÜÜÜÜÜ       ÜÜÜÜÜÜÛ²²ßßß                    ³
       °°°±± °°°°   °ÜÜÜ                              ÜÜÜ°   °°°° ±±°°°   ³
ú ù Ä°°°±±²±°°°°°   ŞÛÛİ   °±±°°° ú ù ÄÄÄ ù ú°°°±±°   ŞÛÛİ   °°°°°±²±±°°°ÄÙ
     ß²±±²²Û±°°°°°   °°°  °²ÛÛÛ±              ±ÛÛÛ²°  °°°   °°°°°±Û²²±±²ß
          ß²²²Ü°°°°°°°° °ÜÛÛ²ß                  ß²ÛÛÜ° °°°°°°°°Ü²²²ß
              ß±±°°°±±±²ÛÛßß                      ßßÛÛ²±±±°°°±±ß

                         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                         ³ UNKNOWN PRODUCTIONS NTM. ³
                         ³    (Not a TradeMark)     ³
                         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   

                               by Jcl of Unknown

        This is my contribution to the Imphobia #11 - CodeGems #5 compo.

        It creates an EXE (yep, not COM) of 56 bytes that put the words
        "ImphobiaCoderCompo" in the screen.
        Please note that the compo was made in December 1995, but I read
        it yesterday!
        See the compo rules in the file COMPO.RLZ included in the package.


        Notes:
              - It can be 4 bytes less if I don't exit to DOS (the
              instructions "mov ah,4Ch" and "int 21h" are quite big.
              - It can be just 30 bytes as a COM, but the compo
              rules said it MUST be an EXE.
              - The complete listing for TASM is available in IMP.ASM
              - The instructions are from a COM file I generated with
              IMP.ASM, then I faked an EXE header so it didn't have
              relocations, etc...
              - If you compile IMP.ASM to an EXE it will not work, bcoz
              the offset of the string is not accurate and it will be
              about 80h bytes before (I think if I quit the "ORG 100h"
              directive it will be fixed... but who cares?)


        Well, if ya wanna contact me, do it!

                Snail-Mail:
                        Javier Campos Laencina
                           C/Bolos, 1, 3-A
                            30005, Murcia
                                Spain

                Phone:
                        +34-68-298639 (Outta Spain)
                         (968) 298639 (From Spain)

                e-Mail:
                        laencina@lander.es



                   This was an Unknown production in 1996

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
*/

#include <dos.h>
#include <stdlib.h>

typedef unsigned char byte;

/*
        The header of the Exe, modified to change the entry point, so that
        the instructions can be put at offset 26, instead of 512 (flushed
        out relocation tables, changed number of paragraphs and the initial
        CS:IP). Starts with the two characters 'MZ'.
*/
byte exe_header[26]={
	77,90,56,0,1,0,0,0,1,0,0,0,255,255,0,0,0,0,0,0,
	10,0,0,0,62,0
};

/*
        A COM file containing the instructions and the data in the same
        segment. This array is the same as linking IMP.ASM with the TLINK
        /t option. It will generate a 30bytes COM file containing all this.
*/
byte program_instructions[30]={
        186,0x15,0x01    // mov dx,[115h]  (This comes from LEA DX,[String])
        180, 0x9,        // mov ah,9h
        205,0x21,        // int 21h
        180,0x4C,        // mov ah,4Ch
        205,0x21,        // int 21h

        73,109,112,104,111,98,105,97,67,       //The String is at offset 115h
        111,100,101,114,67,111,109,112,111,36  //inside the program, taking
                                               //in account the initial CS:IP
                                               //and the Entry Point in the
                                               //EXE header. Also, take notice
                                               //of that the program is at
                                               //100h due to the "ORG 100h"
                                               //TASM directive.
                                               //The string is finished with
                                               //a '$' character (24h=36d)
};


// Now, let's create our 56 bytes long EXE file
void main(void) {
	int handle;
	int error;

        error=_dos_creat("COMPO.EXE", _A_NORMAL, &handle); // Create a new file
        if(error!=0) exit(1);                              // called COMPO.EXE

        _dos_write(handle,exe_header,26,NULL);             // Write the header

        _dos_write(handle,program_instructions,30,NULL);   // Write the program
                                                           // itself

        _dos_close(handle);                                // And close the file
}
