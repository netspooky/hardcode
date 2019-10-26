/***************************************************************************
 *   By MeteoriK of Approximate <giles@spacepigs.com>                      *
 ***************************************************************************/

#include <Main.h>
#include <Audio.h>
#include <BitBuffer.h>
#include <sys/wait.h>
#include <test.mprx.h>

using namespace Mapprox;

int main(int argc, char* argv[])
{
    Audio* audio;
    SynthContainer* synth_container;
    BitBuffer buffer(test_mprx);
    
    synth_container = new SynthContainer;
    synth_container->LoadData(buffer);

    audio = new Audio();
    audio->SetSource ( synth_container );
    audio->Start();
    
    synth_container->PlaySong();
    while(true)
    {
        wait(0);
    }
}
