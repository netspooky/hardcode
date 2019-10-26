//
// TinyPTC by Gaffer
// www.gaffer.org/tinyptc
//

#include "tinyptc.h"


#ifdef __PTC_WINMAIN_CRT__

    extern int main();
    void WinMainCRTStartup()
    {
        main();
    }

#endif


#ifdef __PTC_MAIN_CRT__

    extern int main();
    void MainCRTStartup()
    {
        main();
    }

#endif