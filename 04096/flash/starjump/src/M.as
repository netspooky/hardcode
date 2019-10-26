//Music data and player for the StarJump 4K Flash 10 intro
//by Shiru (shiru@mail.ru), 07'09

package
{
import flash.events.*;
import flash.media.*;
import flash.utils.*;

public class M
{
    //sequence data format:

    //0..95     note, followed by length (in frames)
    //96..127   volume
    //128       loop start, followed by number of loops (255 for endless loop)
    //129       loop end
    //140       set saw waveform
    //141       set square waveform
    //142       set triangle waveform
    //144       set filter, followed by frequency, range, and speed
    //145       set envelope and slide, followed by attack, sustain, release, and slide
    //146       set delay, followed by length and level

    private var sound:Sound;
    private var ca:S;
    private var cb:S;
    private var cc:S;
    private var music:ByteArray;
    private var ptr:uint;

    private var sa:Array=[
    144,4000,2000,.001,2,
    145,1/40,0,1/10,0,
    146,40000,.3,
    142,
    98,
    128,255,45,16,48,8,47,8,41,32,129
    ];
    private var sb:Array=[
    144,2000,500,.005,0,
    145,1,0,1/5,2.5,
    141,
    146,25000,.2,
    128,255,
    128,31,104,36,2,100,36,6,129,128,2,108,36,4,129,
    129
    ];
    private var sc:Array=[
    144,500,200,.01,2.5,
    145,1,0,1/10,0,
    146,16384,.4,
    140,
    110,
    128,255,
    128,64,9,2,129,
    128,32,5,2,129,
    128,32,7,2,129,
    129
    ];

    public function M():void
    {
        ca=new S(sa);
        cb=new S(sb);
        cc=new S(sc);

        music=new ByteArray();
        ptr=128;
    }

    public function G():uint
    {
        var i:uint;
        var buf:Array=[];
 
        if(!ptr) return ptr;
 
        for(i=0;i<8192;i++) buf[i]=0;
 
        ca.R(buf);
        cb.R(buf);
        cc.R(buf);
 
        for(i=0;i<8192;i++) music.writeFloat(Number(buf[i]));

        ptr--;
 
        if(!ptr)
        {
            music.position=0;
            sound=new Sound();
            sound.addEventListener(SampleDataEvent.SAMPLE_DATA,R);
            sound.play();
        }
 
        return ptr;
    }
 
    private function R(e:SampleDataEvent):void
    {
        var i:uint;
        var s:Number;
 
        for(i=0;i<8192;i++)
        {
            s=music.readFloat();
            e.data.writeFloat(s);
            e.data.writeFloat(s);
        }
        music.position%=music.length;
    }
}
}