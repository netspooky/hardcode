//Kaleidoscope 1K Flash 10 intro
//by Shiru (shiru@mail.ru), 09'09

package
{
import flash.display.*;
import flash.geom.*;

[SWF(width="640",height="480",widthPercent="100",heightPercent="100",frameRate="50",backgroundColor="0",pageTitle="")]

public class M extends Sprite
{
    private var c:BitmapData;
    private var s:BitmapData;
    private var p:BitmapData;
    private var a:*=10;
    private var b:*=10;
    private var h:*=0;
    private var v:*=0;
    private var w:*=0;

    public function M():*
    {
        c=new BitmapData(640,480);
        s=new BitmapData(200,400,true,0);
        p=new BitmapData(2048,2048,true,0);

        var sh:Shape=new Shape();
        sh.graphics.lineStyle(1,0xffffff);
        for(var i:int=0;i<530;i++)
        {
            sh.graphics.moveTo(100,0);
            sh.graphics.lineTo(365-i,989);
        }
        s.draw(sh);
 
        p.perlinNoise(128,128,3,0,true,false,7);
        p.colorTransform(new Rectangle(0,0,2048,2048),new ColorTransform(4,4,4,1,-255,-255,-255,0));

        addChild(new Bitmap(c));
        addEventListener("enterFrame",D);
    }
 
    public function D(e:*):*
    {
        var t:BitmapData=new BitmapData(200,400);
        var q:BitmapData=new BitmapData(320,240);
        var m:Matrix;

        w-=1;
        if(w<0)
        {
            w=100+Math.random()*60;
            do
            {
                h=(-5+Math.random()*10)>>0;
                v=(-5+Math.random()*10)>>0;
            }
            while(h+v==0);
        }

        if(w>40)
        {
            a+=h;
            b+=v;
            if(a<10||a>1840) h=-h;
            if(b<10||b>1640) v=-v;
        }

        for(var i:int=0;i<3;i++)
        {
            t.copyPixels(p,new Rectangle(a,b,200,400),new Point());
            t.copyChannel(s,new Rectangle(0,0,200,400),new Point(),1,8);
 
            m=new Matrix();
            m.translate(-100,0);
            if(i==1) m.scale(-1,1);
            m.rotate((105+i*30)*.0174532925);
            m.translate(320,240);
 
            q.draw(t,m,null,null,null,true);
        }

        m=new Matrix();
        c.draw(q,m);
        m.scale(-1,1);
        m.translate(640,0);
        c.draw(q,m);
        m.scale(1,-1);
        m.translate(0,480);
        c.draw(q,m);
        m=new Matrix();
        m.scale(1,-1);
        m.translate(0,480);
        c.draw(q,m);
    }
}
}