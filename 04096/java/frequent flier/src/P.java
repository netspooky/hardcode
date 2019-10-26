import java.awt.*;
import java.awt.geom.RoundRectangle2D;

import javax.sound.sampled.*;

public class P extends javax.swing.JFrame{	
	
	public static void main(String[] args) throws Exception{
		new P();
	}
	public P() throws Exception{
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		
		AudioFormat AF = new AudioFormat(16000, 16, 1, true, true);
		double D = -2*Math.PI/1500;
		int n = -1; //background noise level
		
		int[] x = new int[50];
		int[] y = new int[50];
		int[] w = new int[50];
		int cc = 0; //cloud count
		int gy = 240; //gap y pos
		int gd = 0; //delta gy
		int gs = 300; //gap size
		
		setTitle("Frequent Flier");
		int cp = 250;//current pitch
		TargetDataLine l = (TargetDataLine) AudioSystem.getLine(new DataLine.Info(TargetDataLine.class, AF));
		l.open(AF);
		AudioInputStream in = new AudioInputStream(l);
		byte[] b = new byte[3000];
		int[] a = new int[1500];
		double[] r = new double[101];//DFT reals
		setSize(640,480);
		setResizable(false);
		setVisible(true);
		
		Image off = createImage(640,480);
		//make the background image
		Image bk = createImage(640,480);
		
		int it = getInsets().top-1;
		int il = getInsets().left-1;
		
		int f = 10000; //frames
		int sc = 0; //score
		int sM = 0; //score multiplier
		
		int cnt = 0; //calibration count
		int cv = 0; //varying calibration value;
		int dv = 16; //final calibration value
		l.start();
		int lv = 0;//level
		
		boolean st = true;
		boolean P = false;
		int p1 = 0; //previous pitch
		int h1 = -100; //five historic notes, for pattern checking
		int h2 = -100;
		int h3 = -100;
		int h4 = -100;
		int h5 = -100;
		
		int e = 0; //type of effect
		int et = 0; //effect countdown
		
		int v = 0; //volume
		while(true) {
			long lf = System.nanoTime();
			if(f >= 1200+60) { //end of level
				lv++;
				if(lv > 3) {
					lv = 1;
					st = true;
					P = true;
				}
				cc = 0;
				cp = 250;
				gs = 300;
				gy = 180;
				gd = 0;
				f = 0;
				Graphics2D g = (Graphics2D)bk.getGraphics();
				g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
				switch(lv) { //make the level background image
					case 1:
						for(int i = 0; i < 640; i++) {
							int k = Math.abs(100-(i%200)); //undulating from 0 to 100
							g.setPaint(new Color(70,170-k/2,120+k/2));
							g.drawLine(i,0,i,480);
							g.setPaint(new Color(64,50+k,180-k));
							int o = (int)(Math.sin(i*0.05)*10);
							for(int j =0; j < 640+15; j += 30) {
								g.drawLine(i,j+o,i,j+o+15);
							}
						}
						break;	
					case 2:
						g.setPaint(Color.BLACK);
						g.fillRect(0,0,640,480);
						for(int i = 0; i < 640; i+=80) {
							g.setPaint(new Color(255,255,255,250-Math.abs(i-320)/2));
							for(int j = 0; j < 480; j+=40){
								int ix = 0;
								if(j%80 == 0) ix = 40;
								RoundRectangle2D rb= new RoundRectangle2D.Double(i+ix,j,40,40,6,6);
								g.fill(rb);
							}
						}
						break;
					case 3:
						g.setPaint(new GradientPaint(0,0,new Color(192,128,64),320,0,new Color(200,175,100),true));
						g.fillRect(0,0,640,480);
						
				}
			}
			
			int bp = p1;//best "pitch" (the target)
			
			int dt = bp*3; //delta position, based on pitch
			if(dt < 0) dt*= 2; //same delta as last time
			if(!st) {
				sc++;
				f++;
			}
			
			int p; //for loops and stuff
			int av = in.available();
			if(av >= 3000) {
				v = 0;
				in.skip(av-3000);
				in.read(b);
				//convert to ints
				for(p = 0; p < 1024; p++) {
					int m = (int)(b[p*2+1]);
					if(n < 0) m += 256;
					a[p] = (int)(b[p*2]<<8) | m;
					v+=Math.abs(a[p]);
				}
				if(n == -1)
					n = v;
				
				// *** DFT *** 
				for(p=1; p < r.length; p++) {
					r[p] = 0;
					double im = 0;
					for(int j = 0; j < 1500; j++) { 
						double s = j*p*D;
						r[p] += a[j]*Math.cos(s);
						im += a[j]*Math.sin(s);
					}
					r[p] = Math.sqrt(r[p]*r[p]+im*im);
				}
				//find wavelength
				p = 20;//"pitch" 20 ~= 440Hz
				int bs = 0;//best score
				while(p > 3) { //4 = 64Hz
					int c = 0;//current score
					for(int i = 1; i < 6; i++) c += r[i*p];
					if(c > bs) {
						bs = c;
						bp = p;
					}
					p--;
				}
				while(bp < (dv*3)/4) bp *= 2; //within octave centred on dv (from dv*0.75 to dv*1.5)
				while(bp > (dv*3)/2) bp /= 2;
				bp = bp - dv;
				
				if(v < n*2 ) {
					h5 = h4;
					h4 = h3;
					h3 = h2;
					h2 = h1;
					h1 = p1;
					bp = p1 = -100;
					dt = 0;//no change-(dv*9)/2; //so no pitch is drawn this time
					if(e != 2) sM = 0;
					else sc += sM/2; //multiplier effect works through silence
				}
				else if(st) {
					if(bp == cv) { //calibrating proceeds...
						cnt++;
						if(cnt > 2) { //calibrating done
							st = false;
							sc = 0; //clear the score
							f = 0;
							bp -= cv;//for correct value this iteration
							dv += cv;
						}
					}
					else {
						cv = bp; //restart calibration
						cnt = 0;
					}
				}
				else {
					if((bp == p1 && e != 1) || e == 2) { //holding a note and not invulnerable, or has multiplier effect
						sM++;
						if(sM > 39) sM = 39;
						sc += sM/2;
					}
					if(bp != p1){
						h5 = h4;
						h4 = h3;
						h3 = h2;
						h2 = h1;
						h1 = p1;
					}
					//move the saucer
					dt = bp*3;
					if(dt < 0) dt *= 2;//half as many low values
					dt = -dt;
					cp += dt;
						
					if(cp < 28) cp = 28;
					if(cp > 480-it-18) cp = 480-it-18;
					p1 = bp;
				}
				//test for patterns
				boolean pat = false; //pattern found
				if(h1 != -100 && h2 != -100 && h2 != -100 && h4 != -100) {
					if(h1 == h5 && h2 == h4 && h3 != h1) { //invulnerability
						pat = true;
						e = 1;
						et = 101;
						sM = 0; //cancels multiplier
					}
					else if(h1 < h2 && h2 < h3 && h3 < h4 && h4 < h5) { //multiplier
						pat = true;
						e = 2;
						et = 41;
						sM = 39; //straight to max multiplier
					}
				/*	else if(h1 == ((dv*3)/2) && h3 == h1 && h5 == h1) {
						gs -= 50; //shrink the gap!
						pat = true;
						if(lv == 3) {
							cc = 0; //clear the screen for level 3
						}
					}*/
				}
				if(pat) {
					h1 = h2 = h3 = h4 = -100;
				}
			}
			if(!st) {
				boolean de = false; //dead
				
				//check collisions and move clouds
				int lx = 0; //last x value
				for(p = 0; p < cc; p++) {
					if(x[p] > -45) x[p]-=10;
					
					if(x[p] > lx) lx = x[p];
					double d = Math.sqrt((250-x[p])*(250-x[p])+(cp-y[p])*(cp-y[p]));
					
					if(lv == 1 && d <= w[p]/2)
						de = true;
					
					if(lv == 2 && x[p] > 210 && x[p] < 250 && y[p] < cp && y[p]+w[p] > cp) 
						de = true;
					if(lv == 3) {
						y[p]+= w[p];
						if(d <= 10) 
							de = true;
						if(y[p] < 50+it) w[p] = Math.abs(w[p]);
						if(y[p] > 470) w[p] = -Math.abs(w[p]);
					}
				}
				
				if(de && e != 1) { //dead and not invulnerable
					gy = 220;
					st = true;
					P = true;
					lv = 0;
					f = 10000;
					cv = 0; //restart calibration, but leave dv
				}
				
				//add new obstacles
				if(f < 1200) {
					int cn = 0;
					for(p = 0; p < x.length; p++) {
						if(lv == 1 && ((p < cc && x[p] < 0) || (p == cc && Math.random() < 0.1))) { //add it to the front
							y[p] = (int)(Math.random()*(480-gs));
							w[p] = (int)(Math.random()*100);
							x[p] = 640+w[p];
							if(y[p] > gy-gs/2 && y[p] < gy+gs/2) 
								y[p] += gs; //mind the gap
							if(p == cc)
								cc++;
						}
						if(lv == 2 && ((640-lx > gs*3-300) || cc == 0)) {
							if(cn == 3) break;
							if(x[p] < -40 || p == cc) {
								x[p] = 640+60;
								if(cn == 0) {
									y[p] = 35+it;
									w[p] = gy-30;
								}
								if(cn == 1) {
									y[p] = gy+30+35+it;
									w[p] = 480-35-16-it-gy-gy-60;
								}
								if(cn == 2) {
									y[p] = 480-gy+30-16;
									w[p] = gy-30;
								}
								if(p == cc) cc++;
								cn++;
							
							}
									
						}
						if(lv == 3 && ((Math.random() < 0.0001*f+0.005) || cc == 0)) {
							if(x[p] < -w[p] || p == cc) {
								x[p] = 640+30;
								y[p] = (int)(Math.random()*(440-it));
								w[p] = (int)(14*Math.random()) - 7;
								if(p == cc) cc++;
								break;
							}
						}
					}

				}

				//reduce any effects counters
				if(e != 0) {
					et--;
					if(et <= 0)
						e = 0;
				}
				
				//move the gap
				if(f % 5 == 0) { //4 times per second
					gy += gd;
					switch(lv) {
						case 2:
							if(gy > (480-40-16-it)/2) gy = (480-40-16-it)/2;
							if(gy >= (480-40-16-it)/2) gd = -Math.abs(gd);
							if(gy < 50) gd = Math.abs(gd);
						case 1:
							gd += (int)(Math.random()*5)-2;//occasionally move the gap
							if(gy < gs/2) gd = Math.abs(gd);
							if(gy > 480-gs/2) gd = -Math.abs(gd);
	
							if(gs > 120) gs--;//shrink the gap, twice a second
							break;
					}
				}
			}
			//do drawing
			Graphics2D gf = (Graphics2D)getGraphics();
			Graphics2D g = (Graphics2D)off.getGraphics();
			
			g.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
			g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
			if(st) { //start screen
				g.setColor(Color.WHITE);
				g.fillRect(0,0,640,480);
				g.setFont(new Font("Arial",Font.BOLD,30));
				g.setPaint(Color.BLACK);
				if(sc > 0) {
					g.drawString("Score:", 235,200);
					g.drawString(String.valueOf(sc), 335,200);
				}
				g.drawString("Sing a note to begin", 170,250);
			}
			else {
				g.drawImage(bk, 0, 0, null);
				//draw the saucer
				if(e == 1) 
					g.setPaint(Color.RED);
				else if(e == 2)
					g.setPaint(Color.BLUE);
				else
					g.setPaint(Color.WHITE);
				g.fillOval(240, cp,20,10);
				g.setPaint(Color.BLACK);
				g.drawOval(240, cp,20,10);
				//draw clouds
				g.setStroke(new BasicStroke(3));
				for(p = 0; p < cc; p++) {
					switch(lv) {
						case 1:
							g.setPaint(new Color(200,200,200,255-Math.abs(250-x[p])/2));
							g.fillOval(x[p]-w[p]/2, y[p]-w[p]/2, w[p], w[p]);
							break;
						case 2:
							g.setPaint(new GradientPaint(0,y[p],Color.RED,0,y[p]+w[p],Color.ORANGE));
							g.fillRect(x[p], y[p], 60, w[p]);
							g.setPaint(Color.RED);
							g.drawRect(x[p], y[p], 60, w[p]);
							break;
						case 3:
							if((Math.abs(w[p]) & 1) == 0) {
								g.setPaint(Color.BLUE);
								g.fillRect(x[p]-10,y[p]-10,20,20);
								g.setPaint(new Color(0,0,128));
								g.drawRect(x[p]-10,y[p]-10,20,20);
							}
							else {
								g.setPaint(Color.RED);
								g.fillOval(x[p]-10,y[p]-10,20,20);
								g.setPaint(new Color(128,0,0));
								g.drawOval(x[p]-10,y[p]-10,20,20);
							}
					}
				}
			}
			//draw the frame
			g.setPaint(Color.GRAY);
			g.fillRect(il,it,640,19);
			g.fillRect(il,it,19,480);
			g.fillRect(640-19-il,0,19,480);
			g.fillRect(il,480-19,640,19);
			g.setPaint(Color.BLACK);
			RoundRectangle2D rb = new RoundRectangle2D.Double(il+18,it+18,640-36-il-il,480-36-it,15,15);
			g.setStroke(new BasicStroke(3));
			g.draw(rb);
			if(!st) { //draw the score/multiplier/pitch box
				int ts = Math.min(40,2*f);
				g.setPaint(new GradientPaint(0,-5,Color.BLACK,0,ts+it,Color.GRAY));
				
				g.fillRect(il,it,640,ts);
				g.setPaint(Color.BLACK);
				rb = new RoundRectangle2D.Double(il,-5,640-il-il-3,ts+5+it,15,15);
				g.draw(rb);
				g.setFont(new Font("Arial",Font.BOLD,20));
				g.drawString("Score:",il+25,it+ts-10);
				g.drawString(String.valueOf(sc),il+90,it+ts-10);
				g.drawString("x",il+200,it+ts-10);
				g.drawString(String.valueOf(1+sM/2),il+215,it+ts-10);
				
				g.fillRect(640-il-152,it+ts-22,136,9);
				if(v >= n*2 ) {
					if( bp > 0) g.setPaint(Color.GREEN);
					else if(bp < 0) g.setPaint(Color.RED);
					else g.setPaint(Color.BLUE);
					g.fillRect(640-il-150, it+ts-20, (int)(134*(0.5 + dt/((9.0*dv)/2))), 6);
				}
				if(f <= 20) {
					g.setFont(new Font("Arial",Font.BOLD,100));
					g.setColor(new Color(255,255,255,200-f*10));
					g.drawString("Level", 154, 284);
					g.drawString(String.valueOf(lv), 434, 284);
					g.setColor(new Color(0,0,0,200-f*10));
					g.drawString("Level", 150, 280);
					g.drawString(String.valueOf(lv), 430, 280);
				}
			}
			/*
			* Draw the off buffer to the frame's graphics context.
			*/
			gf.drawImage(off,0,0,null);

			g.dispose();
			gf.dispose();
			if(P) { //pause after a loss
				Thread.sleep(500);
				in.skip(in.available());
				P = false;
			}
			while (System.nanoTime() < lf + 50000000) {
	    		Thread.yield();
	    	}
	    	lf = System.nanoTime();
		}
	}
}
