//Very simple sound synth for the StarJump 4K Flash 10 intro
//by Shiru (shiru@mail.ru), 07'09

package
{
import flash.events.*;
import flash.media.*;
import flash.utils.*;

public class S
{
    private var sCnt:Number;    //sound generator counter
    private var sOut:Number;    //sound output
    private var sFrq:Number;    //sound frequency
    private var sSld:Number;    //frequency slide (added to sFrq every frame)
    private var sVol:Number;    //sound volume
    private var sLen:Number;    //length of note (frames)
    private var sWave:uint;     //waveform type (0=saw,1=square,2=triangle)
    private var sTri:Number;    //triangle direction
 
    private var eSta:uint;      //envelope stage (0=Attack,1=Sustain,2=Release,3=inactive)
    private var eAR:Number;     //envelope attack time
    private var eSR:Number;     //envelope sustain time (in frames)
    private var eRR:Number;     //envelope release time
    private var eLev:Number;    //envelope current level
    private var eWait:Number;   //envelope sustain counter

    private var fA:Number;      //filter buffer 0
    private var fB:Number;      //filter buffer 1
    private var fFrq:Number;    //filter frequency
    private var fRng:Number;    //filter generator range
    private var fCnt:Number;    //filter generator counter
    private var fSpd:Number;    //filter generator speed
 
    private var dBuf:Array=[];  //delay buffer
    private var dPtr:uint;      //delay buffer pointer
    private var dFb:Number;     //delay feedback
    private var dSize:uint;     //delay buffer size
 
    private var nFrq:Array=[];  //note frequencies table

    private var rowC:uint;      //row counter
    private var sPtr:uint;      //sequence data pointer
    private var lLst:Array=[];  //loop list
    private var seq:Array;      //sequence data



    public function S(s:Array):void
    {
        var i:uint,j:uint;
        var f:Number;

        seq=s;

        f=32.70;

        for(i=0;i<12;i++)
        {
            for(j=0;j<7;j++) nFrq[i+j*12]=f*Number(j+1);
            f*=1.059463;
        }
 
        sCnt=0;
        sOut=0;
        sVol=.5;
        sLen=0;
        sWave=0;
        sTri=.125;
        fA=0;
        fB=0;
 
        rowC=0;
        sPtr=0;
    }

    public function R(buf:Array):void
    {
        var i:uint,j:uint;
        var f:Number,q:Number;
        var hp:Number,bp:Number;
        var fb:Number;
        var tag:Number;
        var cnt:uint;
        var ptr:uint;
        var row:Boolean;
        var p:uint;
 
        p=0;
 
        for(i=0;i<16;i++)
        {
            if(!rowC)
            {
                if(sLen)
                {
                    sLen--;
                }
                else
                {
                    row=true;
 
                    while(row)
                    {
                        tag=seq[sPtr++];
 
                        switch(tag)
                        {
                        case 128://loop begin (number of loops, 255 to endless loop)
                            lLst.push(sPtr+1);
                            lLst.push(seq[sPtr++]);
                            break;

                        case 129://loop end
                            cnt=lLst.pop();
                            ptr=lLst.pop();
                            if(cnt>1)
                            {
                                if(cnt<255) cnt--;
                                sPtr=ptr;
                                lLst.push(sPtr);
                                lLst.push(cnt);
                            }
                            break;

                        case 140://saw
                            sWave=0;
                            sOut=0;
                            break;

                        case 141://square
                            sWave=1;
                            sOut=.5;
                            break;

                        case 142://triangle
                            sWave=2;
                            break;

                        case 144://set filter (freq,range,speed)
                            fFrq=seq[sPtr++];
                            fRng=seq[sPtr++];
                            fSpd=seq[sPtr++];
                            fCnt=seq[sPtr++];
                            break;

                        case 145://set ASR and slide (attack,sustain,release,slide)
                            eSta=3;
                            eAR=seq[sPtr++];
                            eSR=seq[sPtr++];
                            eRR=seq[sPtr++];
                            sSld=seq[sPtr++];
                            break;

                        case 146://set delay (length,level)
                            dPtr=0;
                            dSize=seq[sPtr++];
                            dFb=seq[sPtr++];
                            for(j=0;j<dSize;j++) dBuf[j]=0;
                            break;

                        default:
                            if(tag<96)
                            {
                                sFrq=44100/(Number(nFrq[tag])*16);
                                eSta=0;
                                eLev=0;
                                sLen=seq[sPtr++]-1;
                                row=false;
                            }
                            else
                            {
                                if(tag<128)
                                {
                                    sVol=1/32*(tag-96);
                                }
                            }
                        };
                    }
                }
 
                rowC=8;
            }

            rowC--;

            f=fFrq+fRng*Math.cos(fCnt);
            fCnt+=fSpd;
 
            f=2*Math.sin(Math.PI*f/44100);
            q=.8;
            fb=q+q/(1-f);

            switch(eSta)
            {
            case 0://attack
                eLev+=eAR;
                if(eLev>1)
                {
                    eLev=1;
                    eWait=eSR;
                    eSta++;
                }
                break;
            case 1://sustain
                eWait--;
                if(eWait<0) eSta++;
                break;
            case 2://release
                eLev-=eRR;
                if(eLev<0)
                {
                    eLev=0;
                    eSta++;
                }
                break;
            }

            for(j=0;j<512;j++)
            {
                hp=(sOut*eLev+Number(dBuf[dPtr]))-fA;
                bp=fA-fB;
                fA=fA+f*(hp+fb*bp);
                fB=fB+f*(fA-fB);
                dBuf[dPtr++]=fB*dFb;
                if(dPtr>=dSize) dPtr=0;

                sCnt--;
                if(sCnt<0)
                {
                    switch(sWave)
                    {
                    case 0://saw
                        sCnt+=sFrq;
                        sOut-=.0625;
                        if(sOut<-.5) sOut+=1;
                        break;
                    case 1://square
                        sCnt+=sFrq*8
                        sOut=0-sOut;
                        break;
                    case 2://triangle
                        sCnt+=sFrq/8;
                        sOut+=sTri;
                        if(sOut<=-1)
                        {
                            sOut=-1;
                            sTri=0-sTri;
                        }
                        if(sOut>=1)
                        {
                            sOut=1;
                            sTri=0-sTri;
                        }
                        break;
                    }
                }

                buf[p++]+=fB*sVol;
            }
 
            sFrq+=sSld;
            if(sFrq<0) sFrq=0;
        }
    }
}
}