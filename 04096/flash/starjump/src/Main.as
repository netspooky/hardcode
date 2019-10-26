//StarJump 4K Flash 10 intro
//by Shiru (shiru@mail.ru), 07'09

package
{
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.utils.*;
import flash.text.*;

[SWF(width="640",height="480",widthPercent="100",heightPercent="100",frameRate="50",backgroundColor="0",pageTitle="")]

public class Main extends Sprite
{
    private var c:BitmapData;
 
    private var t:Timer;
    private var tb:int;
    private var ta:int;
    private var ts:int;
    private var te:int;
 
    private var a:Array=[];
 
    private var oz:Number;
    private var rr:Number;
    private var rx:Number;
    private var rd:Number;
 
    private var fr:Number;
    private var fg:Number;
    private var fb:Number;
 
    private var g:BitmapData;
    private var m:M;
    private var l:TextField;
 


    public function Main():void
    {
        var i:uint,j:uint,v:uint;

        stage.scaleMode=StageScaleMode.NO_SCALE;
        stage.align=StageAlign.TOP_LEFT;

        c=new BitmapData(640,480,false);
        stage.addChild(new Bitmap(c));
 
        for(i=0;i<2000;i++)
        {
            a[i]=Math.random()*360*Math.PI/180;
            a[i+2000]=(200+Math.random()*10000)*200;
            a[i+4000]=Math.random()*4000;
        }
 
        oz=0;
        rr=0;
        rx=0;
        rd=.00002;
 
        fr=0;
        fg=0;
        fb=0;
 
        g=new BitmapData(256,2048,true,0);
 
        for(i=0;i<8;i++)
        {
            for(j=0;j<8;j++)
            {
                v=(i*j)<<26;
                g.setPixel32(i,j,v);
                g.setPixel32(15-i,j,v);
                g.setPixel32(i,15-j,v);
                g.setPixel32(15-i,15-j,v);
            }
        }
 
        for(i=0;i<16;i++)
        {
            g.copyPixels(g,new Rectangle(0,0,16,16),new Point(i*16,0));
            g.colorTransform(new Rectangle(i*16,0,16,16),new ColorTransform(0,0,0,1,255-i*8,255,127+i*8,0));
        }
 
        for(i=0;i<128;i++)
        {
            g.copyPixels(g,new Rectangle(0,0,256,16),new Point(0,i*16));
            g.colorTransform(new Rectangle(0,i*16,256,16),new ColorTransform(1,1,1,1,0,0,0,-i*2));
        }
 
        t=new Timer(20,1);
        t.addEventListener(TimerEvent.TIMER,T);
        t.start();

        l=new TextField();
        l.defaultTextFormat=new TextFormat(null,15);
        l.autoSize=TextFieldAutoSize.LEFT;
        stage.addChild(l);
 
        m=new M();
    }
 
    private function T(e:TimerEvent):void
    {
        var i:uint;
        var n:Number;
        var s:Number;
        var z:Number;
        var p:Point=new Point();
        var r:Rectangle=new Rectangle(0,0,16,16);
        var td:int;
        var to:int;

        tb=getTimer();
        to=(tb-ta)-ts;
 
        U();

        i=m.G();
 
        if(!i)
        {
            l.text="";
            c.lock();
 
            c.colorTransform(c.rect,new ColorTransform(.9+.095*Math.cos(fr),.9+.095*Math.cos(fg),.9+.095*Math.cos(fb),1,0,0,0,0));
 
            for(i=0;i<2000;i++)
            {
                z=Number(a[i+4000])-oz;
                if(z<0) z+=4000;
                r.x=(i&15)*16;
                r.y=uint(127/4000*z)*16;
                z+=200;
                n=Number(a[i])+rr;
                s=Number(a[i+2000]);
                p.x=312+Math.cos(n)*s/z;
                p.y=232-Math.sin(n)*s/z;
                c.copyPixels(g,r,p);
            }
 
            c.unlock();
        }
        else
        {
            l.text="Receiving data from the hyperspace ("+String(uint(100-100/128*i))+"%)";
        }
 
        ta=getTimer();
        td=ta-tb;
        ts=(20-td)-to;
        if(ts<=0)
        {
            te-=ts;
            ts=2;
        }
 
        t.reset();
        t.delay=ts;
        t.start();
 
        while(te>20)
        {
            U();
            te-=20;
        }
    }

    private function U():void
    {
        oz=(oz+20)%4000;

        rr+=rx;
        rx+=rd;
        if(rx>.0075||rx<-.0075) rd=0-rd;
 
        fr+=.01;
        fg+=.008;
        fb+=.012;
    }
}
}