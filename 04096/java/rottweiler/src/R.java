/** Rottweiler 4k, by rostok(AT)3e.pl
 */

import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import java.awt.geom.*;
import java.util.Random;

import javax.swing.*;

public class R extends JFrame
{
    private static boolean[] keys = new boolean[65536];
//    private static int mouseButton;
//    private static int xMouse, yMouse;

    /**
     * This seems to be the smallest way of reading input events to the JFrame.
     */
    public void processEvent(AWTEvent e)
    {
        switch (e.getID())
        {
            case WindowEvent.WINDOW_CLOSING:
                System.exit(0);
//            case MouseEvent.MOUSE_RELEASED:
//                mouseButton = 0;
//                break;
//            case MouseEvent.MOUSE_PRESSED:
//                mouseButton = ((MouseEvent)e).getButton();
//            case MouseEvent.MOUSE_MOVED:
//            case MouseEvent.MOUSE_DRAGGED:
//                xMouse = ((MouseEvent)e).getX();
//                yMouse = ((MouseEvent)e).getY();
                break;
            case KeyEvent.KEY_PRESSED:
            case KeyEvent.KEY_RELEASED:
                keys[((KeyEvent)e).getKeyCode()] = e.getID() == KeyEvent.KEY_PRESSED;
                //System.out.println (((KeyEvent)e).getKeyCode());
        }
    }

    public static void main(String[] args) throws Throwable
    {
        int screenW = 640;
        int screenH = 448;

		// var game vars 
		int maxJump = 150;
		int horizon= 390;

        // Create the window
        R a = new R();
        a.setSize(screenW, screenH);
        a.setResizable(false);
        a.enableEvents(KeyEvent.KEY_PRESSED | MouseEvent.MOUSE_DRAGGED | MouseEvent.MOUSE_MOVED | MouseEvent.MOUSE_PRESSED | MouseEvent.MOUSE_RELEASED);
        a.setVisible(true);

        // Set up the graphics objects we'll need
        Graphics grScreen = a.getGraphics();
        BufferedImage img = new BufferedImage(screenW, screenH, BufferedImage.TYPE_INT_RGB);
        //int[] pixels = ((DataBufferInt)img.getRaster().getDataBuffer()).getData();
        // backbuffer
        BufferedImage imgBack = new BufferedImage(screenW, screenH, BufferedImage.TYPE_INT_RGB);
        Graphics2D grBack = imgBack.createGraphics();
        //grBack.setColor(new Color(255, 255, 255));
        grBack.setRenderingHint ( RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON );

		// background
        BufferedImage imgBgd = new BufferedImage(screenW, screenH, BufferedImage.TYPE_INT_RGB);
        int[] pixelsBgd = ((DataBufferInt)imgBgd.getRaster().getDataBuffer()).getData();
        Graphics2D grBgd = imgBgd.createGraphics();
		// trees
        BufferedImage imgTrees = new BufferedImage(2048, horizon, BufferedImage.TYPE_INT_ARGB);
        int[] pixelsTrees = ((DataBufferInt)imgTrees.getRaster().getDataBuffer()).getData();
        Graphics2D grTrees = imgTrees.createGraphics();
        grTrees.setRenderingHint ( RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON );

        Random random = new Random();

		// input
		float dx = 0;
		float dy = 0;

		// temp
		int i, j, k = 0, l = 0;
		float d=0, aa, ta;

		// ziemia
		for (j=0; j<screenH; j++)
		{
		    if (j<horizon)
		    {
    			for (i=0; i<screenW; i++)
    				pixelsBgd[i+j*screenW] = 
    											( 81+ (255- 81) * j/horizon* j/horizon* j/horizon)<<16 | 
    		    								(156+ (255-156) * j/horizon* j/horizon* j/horizon)<<8 | 
    		    								255;

			}
			else
			{
    			for (i=0; i<screenW; i++)
    			{
    			    k = (j-horizon) * (random.nextInt(128)+128)>>8;
       				pixelsBgd[i+j*screenW] = 0x100010 | (random.nextInt(36)+100-100 * k/(screenH-horizon))<<8 ;
   				}
			}
		}                                                    

		//drzewo
		l=128;
		int x0=l;
		int y0=l+32;
		// pien
		for (j=y0+l>>1;j<horizon;j++)
		for (i=x0-16;i<x0+16;i++)
		{
//            if (i >= 0 && j >= 0 && i < 2048 && j < horizon)
            {
				pixelsTrees[i+j*2048] = 0xff004000 | (random.nextInt(64)+64)<<16;
			}
		}
		// liscie
//     	grTrees.setPaint( new Color(0xff208020) );
// 		grTrees.fill( new Ellipse2D.Float(   x0-l, y0-l, l<<1, l<<1 ) ); 

		grTrees.setStroke( new BasicStroke(8, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
        for (k=0; k<2000; k++)
        {
			i = random.nextInt(l*2)-l;
			j = random.nextInt(l*2)-l;
		    if (i*i+j*j < (int)(l*l*0.9))
		    {
				grTrees.setPaint( new Color(0xff200020 | (random.nextInt(64)+64)<<8 ) );
				i+=x0;
				j+=y0;
				d = random.nextInt(1024)*0.012272f;
				grTrees.drawLine(i,j,i+(int)(Math.sin(d)*d),j+(int)(Math.cos(d)*d)); // lisc
     			
     			if (k>1950)
     			{
     			grTrees.setPaint( new Color(0xff30ff30) );
 				grTrees.fill( new Ellipse2D.Float(   i+1, j-3, 6, 6 ) ); 
 				grTrees.fill( new Ellipse2D.Float(   i-1, j, 10, 10 ) ); 
     			grTrees.setPaint( new Color(0xff30aa30) );
 				grTrees.fill( new Ellipse2D.Float(   i+2, j-3, 6, 6 ) ); 
 				grTrees.fill( new Ellipse2D.Float(   i, j, 10, 10 ) ); 
 				}
			}
        }
/**/

		// kopiuj dalej
		l+=l;
		k=128;
		for (i=0; i<16; i++)
		{
		    k += random.nextInt(l)+l/2;
			grTrees.drawImage(imgTrees,Math.min(2048-l,k),random.nextInt(32),Math.min(2048-l,k)+l,horizon,0,0,l,horizon,null); 
		}


        while (!keys[27])
        {
			int globalX = 0;
			boolean gameStarted=true;
            int frame = 0;

    		// dog
   			int dogHealth=100;
    		int dogx=-200;
    		int dogy=horizon+5;
    		int dogDir=1;
    		int dogState = 0;
    		int dogJaws = 0;
    		float dogSpeedX= 0;
    		float dogSpeedY= 0;
    		int dogBite = 20;
    		int kills = 0;

    		// blood drops
    		float blood[][] = new float[2048][7];
    		// blood[][0] - x
    		// blood[][1] - y
    		// blood[][2] - old x
    		// blood[][3] - old y
    		// blood[][4] - speed x
    		// blood[][5] - speed y
    		// blood[][6] - state

    		// thiefs
    		int thiefKick = 10;
    		int thief[][] = new int[40][7];
    		// thief[][0] - x
    		// thief[][1] - y
    		// thief[][2] - health
    		// thief[][3] - state
    		// thief[][4] - attackstate
    		// thief[][5] - dir
    		// thief[][5] - rozkrok/speed

           	// thief setup
           	k=640;
           	for (i=0; i<40; i++)
           	{
           		k = thief[i][0] = k + random.nextInt(256)+128;
           		thief[i][1] = horizon+5;
           		thief[i][2] = 100;
           		thief[i][3] = 0;
           		thief[i][4] = 0;
    //     		thief[i][3] = (i==0 ? 0 : -1);
           		thief[i][5] = -1;
    //       		thief[i][6] = random.nextInt(40)+75;
           	}


//          mouseButton = 0;
			// main loop 
            while (gameStarted && !keys[27])
            {
				long fsTime=System.nanoTime();
                frame++;

                if (dogHealth>0)
                {
                	// input
                	dx = 0;
                	dy = 0;
                	if (keys[37]) dx -= 10;
                	if (keys[39]) dx += 10;
                	if (keys[38]) dy -= 10;
                	if (keys[40]) dy += 10;

                	// dog logic
                    switch(dogState)
                    {
                    case 0: // stop                     
                    		if (dx!=0) dogState=1; // run
                    		if (dy>0 && dogHealth<100) dogState=5;  // eat
                    		break;

                    case 1: // run
                    		if (dy>0) dogState=5; // eat
                    		if (dy<0) dogState=2; // run
                    		if (dy<0 && Math.abs(dogSpeedX)>0) 
                    		{
                    			// jump start
                    			dogSpeedY = -15;
                    			dogState=2;
                    		}
                    		if (dy==0 && Math.abs(dogSpeedX)<1) dogState=0;
                    		break;

                    case 2: // jump
                    		dogSpeedY+=1;
    						if (dogy<horizon-maxJump || dy>=0 || dogSpeedY>0) 
    						{
    							dogState=3;  // fall
    							dogSpeedY=0;
    						}
                    		break;

                    case 3: // fall
                    		dy = 0;
                    		dogSpeedY+=1;
                    		if (dogy>=horizon+5)
                    		{
                    		    // on ground
                    		    dogy=horizon+5;
                    		    dogSpeedY = 0;
                    			if (dx!=0) dogState=1; // run
                    			else	   dogState=0; // stop
                    		}
                    		break;

    //                case 4: // hit
    //                		break;

                    case 5: // eat
                    		if (dx!=0) dogState=1; // run
                    		if (dogHealth==100) dogState=0; // stop
                    		break;

    //                case 6: // dead
    //                		break;
                    }
        			
        			if (keys[32]) dogJaws = Math.min(100,   dogJaws+20);
        			else 		  dogJaws = Math.max(0,     dogJaws-22);

    	           	//movement
    				dogSpeedX = Math.min(dogSpeedX + dx, 10)*0.9f;
    				dogSpeedX = Math.max(dogSpeedX     ,-10);

                	if (dogSpeedX<0) dogDir = -1;
                	if (dogSpeedX>0) dogDir =  1;

                	dogx = Math.max(80, 		dogx+(int)dogSpeedX);
                	dogy = Math.min(horizon+5, 	dogy+(int)dogSpeedY);

                	if (dogx-globalX<80) 		{ globalX = -dogx+80; 	}
                	if (dogx-globalX>320)   	{ globalX = -dogx+320; 	}
            	}

            	// thief logic
            	for (i=0; i<40; i++)
            	{
            		switch (thief[i][3])
            		{
            		case 0: // pursuit
            		        k = (dogHealth<=0) ? 1 : dogx - thief[i][0];
//            		        k = dogx - thief[i][0];
           		        	if (k<0) thief[i][5] =  1;
           		        	if (k>0) thief[i][5] = -1;
            		        if ( Math.abs(k) < screenW )
            		        {
            		        	//if (k!=0) 
            		        	thief[i][0] -= (random.nextInt(2)+1)*thief[i][5];//k/Math.abs(k);
//            		        	if (k!=0) thief[i][0] += (random.nextInt(2)+1)*k/Math.abs(k);
//            		        	if (k!=0) thief[i][0] += (thief[i][6]*k/100)/Math.abs(k);
            		        }
        
                    		// is dog close
                    		if (Math.abs(dogx-thief[i][0])<50)
                    		{
								thief[i][3] = 1; // switch to attack
                    		}
            				break;

            		case 1: // attack
                    		if (Math.abs(dogx-thief[i][0])<50 && dogy>=horizon-maxJump>>1 && dogState!=6)
                    		{
								if (thief[i][4]>90) // front kick
								{
									dogHealth -= thiefKick;
									dogx -= 3*thief[i][5];
									if (dogHealth<=0) 
									{
										dogState = 6;
										dogSpeedY=0;
										dogy = horizon;
									}

									if (thief[i][4]>100)
									{
										thief[i][3] = 2; // swing back
									}
								}                    			
								thief[i][4] += 20;
                    		}
                    		else
                    		{
								thief[i][3] = 2; // swing back
                    		}
                    		break;
            			
            		case 2: // swing back
							thief[i][4] -= 21;
							if (thief[i][4]<=0)
							{
							    thief[i][4]=0; // stop anim
								thief[i][3]=0; // pursuit
							}                    			
                    		break;
            			
					case 6: // dead
//                    		if (Math.abs(thief[i][0]+40-dogx)<80)
//                    		if (dogState==5)
//                    		if (dogJaws>85)
//                    		if (thief[i][2]>-100)
                    		if (Math.abs(thief[i][0]+40-dogx)<80 && dogState==5 && dogJaws>85 && thief[i][2]>-100)
                    		{
//                    			System.out.println ("eat");
							    dogHealth = Math.min(dogHealth+dogBite/2+1, 100);
								thief[i][2] -= dogBite;
								if (thief[i][2]<=-100)
								{
									// eaten
									thief[i][3] = -1;
								}

        						// create blood drops
        						l = random.nextInt(32)+16;
        					    k = 0;
        					    j = 0;
        					    while (j<l && k<2048)
        					    {
        					    	if (blood[k][6]==0.0f)
        					    	{          
        					    		blood[k][0] = dogx;
        					    		blood[k][1] = dogy-10;
        					    		blood[k][2] = dogx;
        					    		blood[k][3] = dogy-10;
        					    		blood[k][4] = (random.nextInt(500)-250)*0.01f;
        					    		blood[k][5] = -random.nextInt(500)*0.01f;
        					    		blood[k][6] = 1.0f;
        					    		j++;
                    					//System.out.println ("blood drop"+j);
        					    	}
        					    	k++;
        					    }
/*  */

                    		}
							break;
            		}

					// normal bite					
					if (thief[i][3] != 6)
					if (thief[i][3] != -1)
               		if (Math.abs(thief[i][0]-dogx)<30)
					if (keys[32] && dogJaws>50 && dogJaws<90) // closed
					{
						thief[i][2] -= dogBite; // reduce thief health
						if (dogy < horizon)
						{
							thief[i][2] -= dogBite; // reduce thief health
						}

						// create blood drops
						l = random.nextInt(32)+16;
					    k = 0;
					    j = 0;
					    while (j<l && k<2048)
					    {
					    	if (blood[k][6]==0.0f)
					    	{          
					    		blood[k][0] = dogx;
					    		blood[k][1] = dogy-75;
					    		blood[k][2] = dogx;
					    		blood[k][3] = dogy-75;
					    		blood[k][4] = dogSpeedX+(random.nextInt(1000)-500)*0.01f;
					    		blood[k][5] = dogSpeedY-random.nextInt(500)*0.01f;
					    		blood[k][6] = 1.0f;
					    		j++;
            					//System.out.println ("blood drop"+j);
					    	}
					    	k++;
					    }

						if (thief[i][2]<=0)
						{
							thief[i][4] = 0; // sotp anim
							thief[i][3] = 6; // dead
							thief[i][2] = 0;
							kills++;
						}
					}                    			
            	}

            	// blood logic
            	for (i=0; i<2048; i++)
                	if (blood[i][6]==1.0f)
                	{
                		if (blood[i][1]>=horizon) blood[i][6] = 0.0f;
                		blood[i][2] = blood[i][0];
                		blood[i][3] = blood[i][1];
                		blood[i][0]+= blood[i][4];
                		blood[i][1]+= blood[i][5];
                		blood[i][4]*=0.9;
                		blood[i][5]+=1;
                	}

                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                /// render screen ///////////////////////////////////////////////////////////////////////////////////////////////////
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                // background
                grBack.drawImage(imgBgd, 0, 0, null);
//                grBack.drawImage(imgBgd, globalX % screenW, 0, null);
//                grBack.drawImage(imgBgd, globalX % screenW+screenW, 0, null);
                k=horizon;
                l=horizon+4;
                for (i=0; i<5; i++)
                {
                    j = (globalX*(i+1)>>2) % screenW;
                	grBack.drawImage(imgBgd, j,     	k, j+screenW,         l, 0,k, screenW, l, null);
                	grBack.drawImage(imgBgd, j+screenW, k, j+screenW+screenW, l, 0,k, screenW, l, null);
                	int oh2=l;
                	l+=(l-k)*(i+1);
                	k=oh2;
                }

                // trees
//              	grBack.drawImage(imgTrees, (globalX>>2) % 512,       horizon*3/4, 512, horizon>>2, null);
//              	grBack.drawImage(imgTrees, (globalX>>2) % 512+512,   horizon*3/4, 512, horizon>>2, null);
              	grBack.drawImage(imgTrees, (globalX>>1) % 1024,      horizon>>1, 1024, 1+horizon>>1, null);
              	grBack.drawImage(imgTrees, (globalX>>1) % 1024+1024, horizon>>1, 1024, 1+horizon>>1, null);
                grBack.drawImage(imgTrees, globalX % 2048, 	    3, null);
                grBack.drawImage(imgTrees, globalX % 2048+2048, 3, null);

                // thieves
                for (i=0; i<40; i++)
                {
                	if (thief[i][3]==-1) continue;
                	ta = -thief[i][4]*0.007854f;//0.01f*3.141592653589793f*0.25f;

            		int lx, ly, mx, my;
            		int llx, lly, mmx, mmy;
            		if (Math.abs(ta)>0.01f || thief[i][3]==6)
            		{   // kick
            			llx =  -3+(int)(Math.sin(ta)*60);
            			lly = -63+(int)(Math.cos(ta)*60);
            			mx = mmx = -0;
            			my = -33;
            			mmy = -3;
            			lx = (-3+llx)>>1;
            			ly = (-63+lly)>>1;

                		k = (int)(Math.sin(ta/2.0f)*33);
                		l = -90+(int)(Math.cos(ta/2.0f)*33); 
                		d = 0;
            		}
            		else
            		{	// walk
            		    ta=(float)(((frame+i*3)%60)/30.0f*Math.PI);
   						d = (float)Math.cos(ta)/2.0f*0.9f; // rozkrok
//   						d = (float)Math.cos(ta)/2.0f*(thief[i][6]*0.01f); // rozkrok
       					lx = - 3+(int)(Math.sin(d)*30);
       					ly = -63+(int)(Math.cos(d)*30);
       					mx = -lx;
       					my = ly;

       					aa = (float)(Math.sin(ta+Math.PI)*Math.PI/5.0f+0.2f);
       					if (aa<0) aa=-aa/2;//
       					ta = (float)(Math.sin(ta        )*Math.PI/5.0f+0.2f);
       					if (ta<0) ta=-ta/2;//
            			llx = lx+(int)(Math.sin(d+ta)*30);
            			lly = ly+(int)(Math.cos(d+ta)*30);
            			mmx = mx+(int)(Math.sin(-d+aa)*30);
            			mmy = my+(int)(Math.cos(-d+aa)*30);

                		k=(int)(Math.sin(d*1.2)*33);
                		l=-90+(int)(Math.cos(d*1.2)*33); // reka
					}
					d = -Math.max(mmy, lly)-5;
			
//		            if (frame<50 && i==1)
//		            	System.out.println ((ta/Math.PI*180)+"\t"+(lx)+"\t"+(ly)+"\t"+(llx)+"\t"+(lly)+"");
//		            if (i==1)
//		            	System.out.println ((mmy+d)+" "+(lly+d));
        			
        			grBack.translate( globalX+thief[i][0], thief[i][1]+d );

        			grBack.scale( thief[i][5], 1 );
               		// dead
                	if (thief[i][3]==6) grBack.rotate(Math.PI/2.0f,-5,-15);

                	grBack.setPaint( new Color(0x8e6f6f) );
            		grBack.setStroke( new BasicStroke(7) );
            		grBack.drawLine( 0,-94, -3,-101); // kark
                	grBack.setPaint( Color.BLACK );
            		grBack.setStroke( new BasicStroke(15, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
            		grBack.drawLine( -1,-109, -1,-113); // wlosy

                	grBack.setPaint( new Color(0xcd8e7e) );
            		grBack.setStroke( new BasicStroke(12, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
            		grBack.drawLine( -3,-106, -3,-110); // glowa
            		

            		// reka tylnia
                	grBack.setPaint( new Color(0xcd8e7e) );
            		grBack.setStroke( new BasicStroke(8, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
               		grBack.drawLine(0,-85,-k,l); // reka

               		// nogi
               		grBack.setPaint( new Color(0x6f5f5f) );
            		grBack.setStroke( new BasicStroke(12, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
        			grBack.drawLine(-3,-63,lx,ly); // noga
        			grBack.drawLine( 3,-63,lx,ly); // noga
        			grBack.drawLine(llx,lly,lx,ly); // noga

//                	grBack.setPaint( new Color(0xAAAAAA) );
//            		grBack.setStroke( new BasicStroke(6) );
//             		grBack.drawLine(llx,lly+3,llx-10,lly+3); // bucik

            		grBack.setPaint( new Color(0x8e6f6f) );
            		grBack.setStroke( new BasicStroke(12, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
        			grBack.drawLine(-3,-63,mx,my); // noga
        			grBack.drawLine( 3,-63,mx,my); // noga
        			grBack.drawLine(mmx,mmy,mx,my); // noga

                	grBack.setPaint( new Color(0xAAAAAA) );
            		grBack.setStroke( new BasicStroke(6) );
              		grBack.drawLine(mmx,mmy+3,mmx-10,mmy+3); // bucik
              		grBack.drawLine(llx,lly+3,llx-10,lly+3); // bucik

               		// tulow
                	grBack.setPaint( new Color(0x202020) );
            		grBack.setStroke( new BasicStroke(16) );
            		grBack.drawLine( 0,-85,-2,-71); 
            		grBack.drawLine( 0,-85, 2,-71);

            		// reka przednia
                	grBack.setPaint( new Color(0xcd8e7e) );
            		grBack.setStroke( new BasicStroke(8, BasicStroke.CAP_ROUND, BasicStroke.JOIN_ROUND) );
               		grBack.drawLine(0,-85,k,l); 

               		// dead
                	if (thief[i][3]==6) grBack.rotate(-Math.PI/2,-5,-15);
        			grBack.scale( thief[i][5], 1 );
        			grBack.translate(-globalX-thief[i][0], -thief[i][1]-d );
                }

	       		// dog
       			d = (dogState==2 || dogState==3) ? (float)-Math.PI*0.4f : (float)Math.sin( (frame%20)/10.0f*Math.PI )*dogSpeedX/10.0f;
       			if (dogState==6) d=(float)(-Math.PI/2.0f); // dead

        		grBack.setPaint( Color.BLACK );
        		grBack.translate( globalX+dogx, k=(dogy + (dogState==6 ? 25:0)) );
       			grBack.scale( dogDir, 1 );
               	grBack.rotate(Math.PI*0.005125f*dogSpeedY,0,0); // jump rotate

        		grBack.setStroke( new BasicStroke(7) );
       			grBack.drawLine(  -62,-24,-68+(int)(Math.sin(d)*20f),-24+(l=(int)(Math.cos(d)*20f))); // back leg
       			grBack.drawLine(  -21,-22,-21-(int)(Math.sin(d)*20f),-22+l); // front leg

        		grBack.setStroke( new BasicStroke(18) );
        		grBack.drawLine(  -57,-32,-24,-29 ); // stomach
        		grBack.drawLine(  -54,-33,-25,-40 ); // upper body

           			if (dogState>=4) grBack.rotate(+1.09f,-21,-27);
            		grBack.drawLine(  -22,-31,-15,-51 ); // neck
            		grBack.drawLine(  -32,-34,-15,-51 ); // neck

            		grBack.setStroke( new BasicStroke(5) );
            		grBack.drawLine(  -16,-47,- 6, (int)(-43.0f-dogJaws*0.04f) ); // lower jaw

            		grBack.setStroke( new BasicStroke(7) );
            		grBack.drawLine(  - 9,-54,- 5,-54 ); // upper jaw
            		grBack.drawLine(  -20,-57,-10,-57 ); // cap
            		// ucho
            		grBack.setPaint( new Color(0x202020) );
            		grBack.drawLine(  -18,
            						  -59, 
            						  -18-(int)(Math.sin(Math.abs(dogSpeedX)*0.05*Math.PI)*5.0f), 
            						  -59+(int)(Math.cos(Math.abs(dogSpeedX)*0.05*Math.PI)*5.0f) ); 
/**/
           			if (dogState>=4) grBack.rotate(-1.09f,-21,-27);

               	grBack.rotate(-Math.PI*0.005125f*dogSpeedY,0,0);
       			grBack.scale( dogDir, 1 );
        		grBack.translate( -globalX-dogx, -k);
  
            	// blood
           		grBack.setPaint( Color.RED );
           		grBack.setStroke( new BasicStroke(2) );
            	for (i=0; i<2048; i++)
                	if (blood[i][6]==1.0f)
                	{
                		grBack.drawLine( globalX+(int)blood[i][0], (int)blood[i][1],
                						 globalX+(int)blood[i][2], (int)blood[i][3] ); 
                	}

				grBack.setPaint( Color.WHITE );
                grBack.drawString("Health:"+dogHealth, 10, 36); 
                grBack.drawString("Kills:"+kills, 10, 52); 

				if (kills>=40)
				{
                	grBack.drawString("You won!", 310, 200); 
				}

				if ((dogHealth<=0 && dogy==horizon) || (kills>=40))
				{
                	grBack.drawString("Press ENTER to play!", 280, 240); 
                	if (keys[10]) gameStarted=false;
				}
/*                grBack.drawString("dogy:"+dogy, 10, y); y+=16;
                grBack.drawString("dogHealth:"+dogHealth, 10, y); y+=16;
                grBack.drawString("dx:"+dx, 10, y); y+=16;
                grBack.drawString("dy:"+dy, 10, y); y+=16;
                grBack.drawString("dSx:"+dogSpeedX, 10, y); y+=16;
                grBack.drawString("dSy:"+dogSpeedY, 10, y); y+=16;
                grBack.drawString("globalX:"+globalX, 10, y); y+=16;

				frameEndTime=System.nanoTime();
                grBack.drawString("time:"+frame*1000000.0/(System.nanoTime()/1000-startTime/1000), 10, y); y+=16;
                grBack.drawString("time:"+(1000000000.0f/(frameEndTime-frameStartTime)), 10, y); y+=16;
				frameStartTime=System.nanoTime();
*/

				// show frame
                grScreen.drawImage(imgBack, 0, 0, null);

                // A small sleep prevents the game from eating all the cpu power
//                Thread.sleep(10);
				fsTime = (System.nanoTime()-fsTime)/1000000;
				if (fsTime<20)
                	Thread.sleep(20-fsTime);

            }
        }

        // System.exit(0) makes sure nothing is left in the background
        System.exit(0);
    }


}
