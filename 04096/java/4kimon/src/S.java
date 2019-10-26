import java.awt.AWTEvent;
import java.awt.BasicStroke;
import java.awt.Canvas;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import java.net.URL;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;
import javax.swing.JFrame;
import javax.swing.JOptionPane;


/**
 * Second submision to java 4k contest 2006, a homage to Ralph Baer.
 */
public class S extends Canvas{
	private static int mx, my; // mouse position
	
	private S(){
		enableEvents(AWTEvent.MOUSE_EVENT_MASK);
	}
	
	public static void main(String[] a){
//		long time; //Unused
		final Color[] color = {Color.RED, Color.GREEN, Color.YELLOW, Color.BLUE}; 
		final int[] tone = {220, 440, 392, 293};
		
		// Create and set the frame and the canvas component
		final JFrame f = new JFrame();
		final S s = new S();
		f.add(s);
		f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		s.setPreferredSize(new Dimension(400, 300));
		f.pack();
		f.setLocationRelativeTo(null);
		f.show();
		
		//XXX vars
		Graphics2D g;
		BufferedImage main; // here we will draw :)
		main = s.getGraphicsConfiguration().createCompatibleImage(400, 300);
		int setPlay = 0; //this note will be set to be played on the next loop it is set to.
		int gamestate = 0; //state of the game 0=waiting to start, 1=sampling the level, 2=getting input
		int level = 0;
		int slp = 1;
		int[] sequence = new int[0];
		int seqstate = 0; //index of the sequence we are playing on this loop
		a = new String[]{"Ready?", "Repeat", "Listen"}; // some strings
		String msg = a[0];
		
		int disc_w = 300, disc_h = 170; // inline this if we are done.
		while(true){
			//XXX Rendering
			g = main.createGraphics();
			g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
			g.setColor(Color.BLACK);//clear the screen
			g.fillRect(0, 0, 400, 300);
			
			for(int i = 0; i < 4; i++){ // draw the segments
				g.setColor(color[i]);
				g.fillArc((f.getWidth() >> 1) - (disc_w >> 1), (f.getHeight() >> 1) - (disc_h >> 1),
						disc_w, disc_h, 90 * i, 90);
				if(setPlay == tone[i]){
					g.setColor(new Color(0x7fffffff, true));
					g.fillArc((f.getWidth() >> 1) - (disc_w >> 1), (f.getHeight() >> 1) - (disc_h >> 1),
							disc_w, disc_h, 90 * i, 90);
				}
					
			}
			//draw some arcs so it looks like they are separated
			g.setStroke(new BasicStroke(12f));//XXX line stroke
			g.setColor(Color.DARK_GRAY);
			g.drawArc((f.getWidth() >> 1) - (disc_w >> 1), (f.getHeight() >> 1) - (disc_h >> 1),
					disc_w, disc_h + 5, 0, 360);
			g.drawArc((f.getWidth() >> 1) - (disc_w >> 2), (f.getHeight() >> 1) - (disc_h >> 2) - 5,
					disc_w >> 1, disc_h >> 1, 0, 360);
			g.drawRect((f.getWidth() >> 1), (f.getHeight() >> 1) - (disc_h >> 1), 1, disc_h);
			g.drawRect((f.getWidth() >> 1) - (disc_w >> 1), (f.getHeight() >> 1),  disc_w, 1);
			
			//fill the center so the segments are coronaes now
			g.setColor(Color.GRAY);
			g.fillArc((f.getWidth() >> 1) - (disc_w >> 2), (f.getHeight() >> 1) - (disc_h >> 2) - 6,
					(disc_w >> 1), (disc_h >> 1), 0, 360);
			
			// draw the text
			g.setColor(Color.WHITE); //XXX text msg
			if(setPlay == 100)
				g.setColor(Color.RED);
			g.setFont(g.getFont().deriveFont(25f));
			g.drawString(a[Math.min(gamestate, 2)],
					(f.getWidth() >> 1) - a[Math.min(gamestate, 2)].length() * 7, (f.getHeight() >> 1));
			g.drawString(msg, (f.getWidth() >> 1) - (msg.length() * 7), 30);
			
			// done
			g.dispose();
			s.getGraphics().drawImage(main, 0, 0, null);
			
			//XXX Tone dispatch
			//setPlay si(A3) = 220, re(D4) = 293, sol(G4) = 392, si(A4) = 440
			if(setPlay > 0){
				int time = setPlay >> 2;
				// Gets a line with a determinate format
				SourceDataLine line = null;
//				final AudioFormat format = new AudioFormat(AudioFormat.Encoding.PCM_SIGNED,
//						22050, 16, 1, 2, 22050, false);// pcm, 22050 samples/s, 16 bits, mono, 2b per frame, 22050 frames/s 
//				//[inlined on line] 
				try {
//					DataLine.Info info = new DataLine.Info(SourceDataLine.class, format);
//					if(!AudioSystem.isLineSupported(info)){
//						JOptionPane.showMessageDialog(null, info.toString() + " is not supported");
//						return;	// Line not supported.
//					}
					
					line = AudioSystem.getSourceDataLine(new AudioFormat(AudioFormat.Encoding.PCM_SIGNED,
							22050, 16, 1, 2, 22050, false));
					line.open();
				} catch (Exception e) {
//					StringBuilder b = new StringBuilder();
//					b.append(e.toString());
//					for (StackTraceElement stack : e.getStackTrace()) {
//						b.append('\n');
//						b.append(stack.toString());
//					}
//					e.printStackTrace();
//					JOptionPane.showMessageDialog(null, b.toString());
					msg = e.getMessage(); /* Line unavaliable, return */
				}
				// Prepares the sample
				final byte[] sample;
//				final float ampl;
				int samples_in_wave, samp;
//				double sine;

				int indx = 0;
				int nsamples = (22050 * 2) / setPlay;
				sample = new byte[nsamples]; // Big enough to store the larges sample (the smallest note)
				line.start();
				
//				ampl = 32767f * 0.5f; // max volume (signed 16b -> 2^15 - 1) * Set at half volume. [inlined on samp]
				samples_in_wave = 22050 / setPlay;
				for (int i = 0; i < samples_in_wave; i++) {
//					sine = Math.sin(((double)i/samples_in_wave) * 2.0 * Math.PI); [inlined in samp]
					samp  = (int)((Math.sin(((double)i/samples_in_wave) * 2 * Math.PI)) * (32767f));
					sample[indx] = (byte) (samp & 0xff);					// lower byte
					sample[indx + 1] = (byte) ((samp >> 8) & 0xff); // higher byte
					indx += 2;
				}

				while(time > 0){ // use only the fresh written part of the array
					line.write(sample, 0, indx);
					time--;
				}
				line.drain();
				line.stop();
				
				setPlay = 0;
			}
			switch (gamestate){
			case 0:
				if(level > 0 || mx != 0){
					//XXX tone sequence generation
					//add a tone to the sequence
					int[] seqbkp = sequence.clone();
					sequence = new int[level + 1];
					System.arraycopy(seqbkp, 0, sequence, 0, level);
					sequence[level] = (int)(Math.random() * 4);
					//reset the index and play the sequence
					seqstate = 0;
					gamestate = 2;
					mx = 0;
				}					
				break;
			case 2://play the full sequence
				slp = 1;
				if(seqstate > level){
					gamestate = 1;
					seqstate = 0;
				} else {
					if(seqstate == 0)
						slp = 500;
					setPlay = tone[sequence[seqstate]];
					gamestate = 3;
					seqstate++;
				}
				break;
			case 1:
				//XXX input handling
				if(mx != 0){
					for(int i = 0; i < 4; i++){ // get the color where we clicked
						if(color[i].getRGB() == main.getRGB(mx, my)){
							setPlay = tone[i]; // set to play it's note
							if(tone[sequence[seqstate]] != setPlay){ // if it's not the next in the sequence
								setPlay = 100; //play a low note
								gamestate = 4;
							} else {
								seqstate++; // advance in the sequence or start the next level
								if(seqstate > level){
									level++;
									msg = "Level " + level;
									gamestate = 0;
								}
							}
						}
					}
					mx = 0;
				}
				break;
				case 3://paue betwen tones
					slp = 50;
					gamestate = 2;
					break;
				case 4: // dead, send record?
					String st = JOptionPane.showInputDialog("Level " + level);
					if(st != null && st.length() > 0){
						try {
							URL u = new URL("http://flx.proyectoanonimo.com/proyectos/webstart/4kimon/s.php?"
										+ "l=" + level + "&n=" + st);
							level = u.openConnection().getInputStream().read();
							if(level != '0'){
								msg = "DB Err";
							}
						} catch (Exception e) {}
					}
					level = 0; // generate a new sequence
					gamestate = 0;
					break;
			}
			try { Thread.sleep(slp); } catch (Exception e) {}
		}
	}

	protected final void processMouseEvent(final MouseEvent e) {
		if(e.getID() == MouseEvent.MOUSE_PRESSED){ //Mouse pressed event
			mx = e.getX();
			my = e.getY();
		}
	}
}
