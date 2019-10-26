// as3compile -T 10 -X 800 -Y 512 -r 60 -M C C.as
package {
import flash.display.*;
public class C extends Sprite
{
  public function C():void
  {
    for(x=410;x<2300;x+=11)
      {
	graphics.lineStyle(20,(1864180*x)|16711680,0.75);
	graphics.curveTo(0,0,(Math.cos(0.0628318*(x%100))*x/10),
			 (Math.sin(0.0628318*(x%100))*x/10));
      }
    x=stage.stageWidth/2;
    y=stage.stageHeight/2;
    addEventListener("enterFrame",S);
  }
  public function S(e:Object):void
  {
    rotation-=stage.mouseX/2;
  }
}}
