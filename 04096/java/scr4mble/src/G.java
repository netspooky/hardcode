/* Scr4mble
*
* 4K word game experiment
*
* Matt Campbell
* javaunlimited.net
*/

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.awt.image.*;
import java.util.*;
import java.lang.*;
import java.lang.reflect.*;
public class G extends JFrame implements Runnable {
	static final int W = 800, H = 600, TILE = 60;
	static ArrayList w,a;
	boolean key[],play = true;
	String input,scr,word;
	int inc = 0;
	long time,max;
	JPanel p;
	public G() {
		super("Scr4mble");
		input = "";
		scr = "WELCOME";
		word = new String(scr);
		key = new boolean[52];
		p = new JPanel();
		p.setPreferredSize(new Dimension(W,H));
		p.setFocusable(false);
		enableEvents(AWTEvent.KEY_EVENT_MASK);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		getContentPane().add(p);
		pack();
		Dimension d = getToolkit().getScreenSize();
		setLocation((d.width/2)-(W/2),(d.height/2)-(H/2));
		show();
		new Thread(this).start();
	}

	/* Extracts words from a Class,
	* and rescursively initiates the same process
	* for Methods and the Superclass
	*/
	static void g(Class c) {
		if (c == null || c.isPrimitive()) {
			return;
		}
		a.add(c);
		Method m[] = c.getDeclaredMethods();
		int j,n,x,y,l;
		Class r;
		String s[],t;
		for (j = 0;j < m.length;j++) {
			r = m[j].getReturnType();
			if (r != null && !a.contains(r)) g(r); // extract words from this Method's Class type

			// Clean up the string and create an array of space-separated words
			s = m[j].toString().replaceAll("[$._,\\(]"," ").replaceAll("[\\[\\]\\)0-9]","").split(" ");

			for (n = 0;n < s.length;n++) { // for each word..
				y = 0;
				l = s[n].length();

				// Parses camel notation to find wordsLikeThese
				for (x = 0;x < l;x++) {
					while (x < l && s[n].charAt(x) >= 97) { // While lowercase and not end-of-word
						x++; // Keep looking for the next uppercase letter
					}

					// Add the word
					t = s[n].substring(y,x).toUpperCase();
					if (t.length() > 3 && t.length() < 12 && !w.contains(t)) {
						w.add(t);
					}

					y = x; // Mark the position of this uppercase letter
				}
			}
		}

		// Perform the same process for this Class' parent class
		g(c.getSuperclass());
	}


	/* Game setup/loop */
	public void run() {
		int j,n,x,score = 0;
		long last = System.currentTimeMillis();
		max = 120*100*10;
		time = max-10; // this will trigger the welcome/timeup screen when app is launched
		Graphics g;
		Image buf = createImage(W,H);
		Image c[] = new Image[72]; // letter tiles
		FontMetrics fm;
		String tmp;
		for (j = 0;j < 36;j++) {
			for (n = 0; n < 2;n++) {
				c[j+n*36] = new BufferedImage(TILE,TILE,BufferedImage.TYPE_INT_ARGB);
				g = c[j+n*36].getGraphics();
				((Graphics2D)g).setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
				if (n > 0) {
					g.setColor(Color.white);
					g.fillRoundRect(0,0,TILE,TILE,15,15);
					g.setColor(Color.black);
				}
				else {
					g.setColor(new Color(40,115,190));
					g.fillRoundRect(0,0,TILE,TILE,15,15);
					g.setColor(Color.white);
				}
				g.setFont(new Font("SansSerif",Font.BOLD,42));
				fm = g.getFontMetrics();
				if (j < 26) word = String.valueOf((char)(j+65));
				else word = String.valueOf(j-26);
				g.drawString(word,(TILE/2)-(fm.stringWidth(word)/2),45);
				g.dispose();
			}
		}
		word = "";

		while (true) {

			/* game logic */

			// update timer
			if (play && time < max) {
				time+=(System.currentTimeMillis()-last);
				if (time >= max) {
					// time is up
					play = false;
					time = max;
					input = "";
					scr = "WELCOME";
					word = new String(scr);
				}
				last = System.currentTimeMillis();
			}

			// check for word match
			if (input.equals(word)) {
				if (!play) {
					// new game initiated
					score = 0;
					inc = 0;
					input = "";
					play = true;
					last = System.currentTimeMillis();
					time = 0;
				}
				score+=inc;
				if (score < 0) score = 0;
				input = "";
				word = w.get((int)(Math.random()*(w.size()-1))).toString();
				s();
				inc = word.length();
			}

			// check input
			for (j = 0;j < 26 && play && input.length() < word.length();j++) {
				if (key[j]) {
					input+=(char)(j+65);
					key[j] = false;
				}
			}


			/* rendering */

			g = buf.getGraphics();
			((Graphics2D)g).setPaint(new GradientPaint(0,0,new Color(0,128,255),W+150,H+150,Color.white));
			g.fillRect(0,0,W,H);
			g.setColor(Color.white);
			
			// draw input
			n = (W/2)-((input.length()*TILE+input.length()*5)/2);
			for (j = 0;j < input.length() && play;j++) {
				g.drawImage(c[input.charAt(j)-65],n+j*TILE+5*j,H-TILE-40,null);
			}


			// draw scrambled word
			x = (H/2)-(TILE/2);
			n = (W/2)-((scr.length()*TILE+scr.length()*5)/2);
			for (j = 0;j < scr.length();j++) {
				g.drawImage(c[scr.charAt(j)-29],n+j*TILE+5*j,x,null);
			}

			// draw score
			tmp = String.valueOf(score);
			while (tmp.length() < 4) tmp = "0"+tmp;
			for (j = 0;j < tmp.length();j++) {
				g.drawImage(c[Integer.parseInt(String.valueOf(tmp.charAt(j)))+26],5+(j+1)*5+j*TILE,10,null);
			}

			// draw time
			tmp = String.valueOf(120-(int)(time/1000));
			while (tmp.length() < 3) tmp = "0"+tmp;
			n = W-(5*tmp.length()+TILE*tmp.length()+5);
			for (j = 0;j < tmp.length();j++) {
				g.drawImage(c[Integer.parseInt(String.valueOf(tmp.charAt(j)))+26],n,10,null);
				n+=TILE+5;
			}

			// render to screen
			g = p.getGraphics();
			if (g != null) {
				g.drawImage(buf,0,0,null);
			}
			Thread.yield();
		}
	}

	/* Word scrambler */
	public void s() {
		scr = "";
		boolean b[] = new boolean[word.length()];
		for (int j = 0;j < b.length;j++) {
			int n = (int)(Math.random()*b.length);
			do {
				n = (int)(Math.random()*b.length);
			} while (b[n]);
			scr+=word.charAt(n);
			b[n] = true;
		}
	}
	
	/* Input handling */
	public void processKeyEvent(KeyEvent e) {
		if (e.getID() == KeyEvent.KEY_PRESSED) {
			if (e.getKeyCode() == KeyEvent.VK_BACK_SPACE && input.length() > 0) {
				input = input.substring(0,input.length()-1);
			}
			if (e.getKeyCode() == KeyEvent.VK_SPACE) {
				if (play) s();
			}
			if (e.getKeyCode() == KeyEvent.VK_ENTER) {
				if (play && inc > 0) {
					scr = new String(word);
					inc*=-1;
				}
				else input = new String(word); // triggers game to start
			}
			if (e.getKeyCode() == KeyEvent.VK_ESCAPE) {
				if (play) {
					time = max-10;
				}
				else System.exit(0);
			}
				
		}
		int c = (int)Character.toUpperCase(e.getKeyChar());
		int t = e.getID();
		if (c >= 65 && c <= 90) {
			if (t == KeyEvent.KEY_PRESSED) {
				if (!key[(c-65)+26]) { // avoids key-repeat
					key[c-65] = true;
					key[(c-65)+26] = true;
				}
			}
			else if (t == KeyEvent.KEY_RELEASED) {
				key[c-65] = false;
				key[(c-65)+26] = false;
			}
		}
	}

	public static void main(String args[]) {
		w = new ArrayList(); // List of words
		a = new ArrayList(); // Used to avoid dupe processing of a class
		g(Window.class);
		new G();
	}
}