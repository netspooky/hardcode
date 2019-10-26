/*
 * Copyright (c) 2001-2002 Fredrik "quarn" Ehnbom <quarn@home.se>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.

 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import java.applet.*;
import java.awt.*;
import java.io.*;

import sun.audio.*;

/**
 * Yep. here it is. the source code for a simple java 4k I wrote for the
 * demoparty "Mainframe". It competed in the 4k compo, and also in the "GNU demo
 * award" where it's source code was judged. So that is why I have tried to
 * comment this code a little :)
 *
 * <p>
 * And yes... The song used in this intro (it is made by zantac btw,
 * http://www.zantac.tk) has been used before... BUT I could
 * not make it fit in less than 4k then, so it's ok anyway ;)
 *
 * <p>
 * Also this intro uses sun-classes for audioplayer (notice the
 * "import sun.audio.*" above). these are not standard so it is possible that
 * this intro does not work with your java-version
 *
 * <p>
 * It does however work with
 * <li>Internet Explorer 3 and up
 * <li>Netscape version ????
 *
 * <p>
 * OH! the compo version was compiled with
 * <a href="http://www.microsoft.com/java">Microsofts java compiler</a> and
 * then obfuscated with <a href="http://www.retrologic.com">Retroguard</a>
 *
 * <p>
 * Hello to everyone I know. (what? I'm lazy... ;))
 */
public class MainFrame4k
	extends Applet
	implements Runnable
{
	/** this object plays all the music */
	private AudioInput data = new AudioInput();

	/** doublebuffer image */
	private Image doubleBuffer;
	/** The graphics object used when drawing to the doublebuffer */
	private Graphics graphics;

	/**
	 * How loud the instrument for the channels are beeing played. We use
	 * this to fade everything in the intro (if you do not know what I mean;
	 * watch the intro damn it!)
	 */
	private int[]   CHANNELintensity        = new int[5];

	/**
	 * The time for when the last note was played. If it has not been played
	 * yet it has a value of -1
	 */
	private long    lastNote = -1;

	public void init() {
		doubleBuffer = createImage(512, 256);
		graphics = doubleBuffer.getGraphics();
	}

	public void start() {
		new Thread(this).start();
	}


	public void update(Graphics g) {
		paint(g);
	}

	public void paint(Graphics g) {
		g.drawImage(doubleBuffer, 0, 0, this);
	}

	public void run() {
		long start = System.currentTimeMillis();
		try {
			AudioPlayer.player.start(data);
			while (true) {
				double time = (System.currentTimeMillis() - start) / 1000.0f;

				// clear screen
				graphics.setColor(Color.white);
				graphics.fillRect(0,0, 512,256);

				// draw the two circle-thingies
				int color;
				for (int i = 0; i < 2; i++) {
					color = 255 - CHANNELintensity[2+i];
					graphics.setColor(
						new Color(
							color,
							color,
							color
						)
					);
					int x = 128+128 + (int) (Math.sin(time*1.3+i)* 64);
					int y = 128 + (int) (Math.cos(time*2+i)  * 64);
					for (int j = 0; j < 20; j++) {
						graphics.drawOval(x-j*8, y-j*8, 40+j*16, 40+j*16);
					}

				}
				color = CHANNELintensity[4];
				graphics.setColor(
					new Color(
						color,
						color,
						color
					)
				);
				// left side bar
				graphics.fillRect(0,0, 128, 256);
				// right side bar
				graphics.fillRect(128+256,0, 128, 256);

				// draw all the text
				graphics.setFont(new Font("Times New Roman", Font.BOLD, 20));

				color = CHANNELintensity[0];
				graphics.setColor(
					new Color(
						color,
						color,
						color
					)
				);

				graphics.drawString("quarn", 26, 20);
				graphics.drawString("zantac", 432-20, 256-20);
				graphics.drawString("outbreak", 208, 130);

				// fade in "the end"
				if (lastNote > 0) {
					color = 255 - (int) ((time - ((lastNote-start)/1000.0f))*64);
					color = color > 255 ? 255 : color < 0 ? 0 : color;

					graphics.setColor(
						new Color(
							color,
							color,
							color
						)
					);
					graphics.drawString("the end", 213, 160);
				}

				repaint();
				// just so that we do not hog all the cpu-power
				Thread.sleep(10);
			}
		} catch (Throwable t) {
		}
	}

	/**
	 * This class takes care of everything regarding audio. It has a simple
	 * sine-samplegenerator and a player for a format which works kind of
	 * like xm.
	 *
	 * <p>
	 * Let me tell you a little about how the format works.
	 * First I wrote a converter to convert between xm and this format.
	 * It loaded up the xm and then splitted the patterndata between the 5
	 * channels so that one channel only had to care about it's own patterns.
	 * That program then analyzed the patterns for each channel to find out
	 * which patterns where the same. Then each channel created it's own
	 * pattern order table.
	 *
	 * <p>
	 * Voila! done.
	 *
	 * <p>
	 * If you do not understand how it works yet, I am sure you can figure
	 * it out.. I mean, you have the source code :)
	 *
	 * <p>
	 * Look further down how to read in the songdata. Here it is if you are
	 * to lazy to scroll down:
	 * <pre>
	 * <code>
	 * for (int chn = 0; chn < 5; chn++) {
	 *	// read patternTable for channel
	 *	CHANNELpatternTable[chn] = new byte[in.read()];
	 *	in.read(CHANNELpatternTable[chn]);
	 *
	 *	// read patterndata for channel
	 *	CHANNELpatternData[chn] = new byte[in.read()][];
	 *	for (int j = 0; j < CHANNELpatternData[chn].length; j++) {
	 *      	// read all the patterns
	 *		CHANNELpatternData[chn][j] = new byte[in.read()];
	 *		in.read(CHANNELpatternData[chn][j]);
	 *	}
	 * }
	 * </code>
	 * </pre>
	 */
	private class AudioInput
		extends InputStream
	{
		/** the current pitch for each channel */
		private double[]	CHANNELpitch		= new double[5];
		/** the volume for each channel */
		private double[]	CHANNELvolume		= new double[5];
		/** the instrument used by each channel */
		private int[]		CHANNELinstrument	= new int[5];
		/** the basenote for each channel */
		private int[]		CHANNELbaseNote		= new int[5];
		/** the sampledata position for each channel */
		private double[]	CHANNELsamplepos	= new double[5];

		/** the patterndata for each pattern and channel */
		private byte[][][]	CHANNELpatternData	= new byte[5][][];
		/** the pattern order table for each channel */
		private byte[][]	CHANNELpatternTable	= new byte[5][];
		/** the pattern data position far each channel */
		private int[]		CHANNELpatternPos	= new int[5];

		/** the current pattern position in the pattern order tables */
		private int		PATTERNpos		= 0;

		/** the sampledata for the instruments */
		private double[][]	INSTRUMENTsamples	= new double[3][];

		/** the number of ticks before an update */
		private int		GENERALtempo		= 1;
		/** the number of samples before next tick */
		private int		GENERALsamplesLeft	= 0;

		/** mixing buffer for audio data */
		private double[]	GENERALbuffer		= new double[4096];


		/**
		 * not used
		 */
		public int read() {
			return 0;
		}

		/**
		 * Reads len-bytes of audio data into buf
		 */
		public int read(byte[] buf, int off, int len) {
			int cnt = off;
			for (int i = 0; i < len; i++) GENERALbuffer[i+off] = 0;

			while (cnt < len) {
				if (GENERALsamplesLeft == 0) {
					if (--GENERALtempo == 0) {
						// update data
						if (PATTERNpos + 1 < CHANNELpatternTable[0].length) {
							if (CHANNELpatternPos[0] >= CHANNELpatternData[0][CHANNELpatternTable[0][PATTERNpos]].length) {
								for (int chn = 0; chn < 5; chn++) {
									CHANNELpatternPos[chn] = 0;
								}
								PATTERNpos++;
							}

							for (int chn = 0; chn < 5; chn++) {
								int check = 0;

								byte[]  data = CHANNELpatternData[chn][CHANNELpatternTable[chn][PATTERNpos]];
								if (CHANNELpatternPos[chn] < data.length) {
									check = data[CHANNELpatternPos[chn]++];

									if ((check &0x80) != 0) {
										int freq = (int) (8363d * Math.pow(2d, ((6d * 12d * 16d * 4d - ((10*12*16*4) - (((check&0x3f) + CHANNELbaseNote[chn])*16*4))) / (double) (12 * 16 * 4))));
										CHANNELpitch[chn] = freq / 8000d;
										CHANNELvolume[chn] = 1;
										CHANNELsamplepos[chn] = 0;
									} else if (check != 0) {
										if (chn == 0) {
											int freq = (int) (8363d * Math.pow(2d, ((6d * 12d * 16d * 4d - ((10*12*16*4) - (CHANNELbaseNote[chn]*16*4))) / (double) (12 * 16 * 4))));
											CHANNELpitch[chn] = freq / 8000d;
											CHANNELsamplepos[chn] = 0;
											CHANNELvolume[chn] = 0.3;
										} else {
											CHANNELpitch[chn] = -1;
										}
									}
								}
							}
						} else if (lastNote < 0) {
							// this will make the "the end" fade in
							lastNote = System.currentTimeMillis();
						}

						GENERALtempo = 2;
					}
					GENERALsamplesLeft = (5 * 22050) / (2 * 90);
				}

				int read = Math.min(GENERALsamplesLeft-cnt, len-cnt);

				// mix
				for (int chn = 5; --chn >= 0;) {
					if (CHANNELpitch[chn] == -1) {
						CHANNELintensity[chn] = 0;
						continue;
					}

					double stuff = 0;
					for (int i = 0; i < read; i++) {
						double stuff2 = INSTRUMENTsamples[CHANNELinstrument[chn]][(int) CHANNELsamplepos[chn]] * CHANNELvolume[chn] * 60;
						GENERALbuffer[cnt+i] += stuff2;
						CHANNELsamplepos[chn] += CHANNELpitch[chn];

						stuff2 = stuff2 < 0 ? -stuff2: stuff2;
						stuff += stuff2;

						if (CHANNELsamplepos[chn] >= INSTRUMENTsamples[CHANNELinstrument[chn]].length) {
							CHANNELpitch[chn] = -1;
							CHANNELintensity[chn] = 0;
							break;
						}
					}

					if (chn < 2)
						stuff /= ((read/10)*250) / (500 / CHANNELsamplepos[chn]);
					else
						stuff /= ((read/10)*250) / (25 / CHANNELsamplepos[chn]);
					stuff = stuff > 1 ? 1 : stuff < 0 ? 0 : stuff;
					CHANNELintensity[chn] = (int) (255 * stuff);
				}
				read += cnt;

				// convert from 16 bit linear to ulaw
				for (; cnt < read; GENERALsamplesLeft--, cnt++) {
					int sample = (int) GENERALbuffer[off + cnt];

					// lose right channel, just in case :)
					sample = (sample << 16) >> 16;

					if (sample >= 0) {
						// Convert from 16 bit linear to ulaw.
						int exponent = lut[sample >> 7];
						int mantissa = (sample >> (exponent + 3)) & 0x0F;
						buf[cnt] = (byte) (((exponent << 4) | mantissa) ^ 0xFF);
					} else {
						sample = -sample;
						// Convert from 16 bit linear to ulaw.
						int exponent = lut[sample >> 7];
						int mantissa = (sample >> (exponent + 3)) & 0x0F;
						buf[cnt] = (byte) (((exponent << 4) | mantissa) ^ 0x7F);
					}
				}
			}
			return len;
		}

		/**
		 * samplegenerator... yeah, yeah, I know.. this sucks. But if
		 * you want the whole samplegenerator, with gui, source code and
		 * all, just surf to
		 * <a href="http://www.outbreak.nu/quarn/softsynth/">
		 * http://www.outbreak.nu/quarn/softsynth/
		 * </a>
		 */
		void sine(double[] samples, Point[] freq, Point[] fakevol, float volume) {
			double constant = (Math.PI * 2) / 44100;
			double constant2 = samples.length / 240d;

			double[] freqPitches = new double[freq.length-1];
			double[] freqLengths = new double[freqPitches.length];
			for (int i = 0; i < freqPitches.length; i++) {
				double y1 = freq[i].y * constant;
				double y2 = freq[i+1].y * constant;

				double x1 = freq[i].x * constant2;
				double x2 = freq[i+1].x * constant2;

				freqPitches[i] = (y2 - y1) / (x2 - x1);
				freqLengths[i] = x2 - x1;
			}

			double[] volPitches = new double[fakevol.length-1];
			double[] volLengths = new double[volPitches.length];
			for (int i = 0; i < volPitches.length; i++) {
				double y1 = (fakevol[i].y / 50d) * volume;
				double y2 = (fakevol[i+1].y / 50d) * volume;

				double x1 = fakevol[i].x * constant2;
				double x2 = fakevol[i+1].x * constant2;

				volPitches[i] = (y2 - y1) / (x2 - x1);
				volLengths[i] = x2 - x1;
			}

			int freqPos = 0;
			int volPos = 0;

			double pitch = freq[0].y * constant;

			double freqPitch = freqPitches[freqPos];
			double pos = 0;
			int freqLen = (int) freqLengths[freqPos];

			double vol = (fakevol[0].y/50d) * volume;
			double volPitch = volPitches[volPos];
			int volLen = (int) volLengths[volPos];

			for (int i = 0; i < samples.length; i++) {
				samples[i] += ((Math.sin(pos) * vol));
				vol += volPitch;
				pos += pitch;
				pitch += freqPitch;

				if (--volLen < 0) {
					volPos++;
					volPitch = volPitches[volPos];
					volLen = (int) volLengths[volPos];
				}

				if (--freqLen < 0) {
					freqPos++;
					freqPitch = freqPitches[freqPos];
					freqLen = (int) freqLengths[freqPos];
				}
			}
		}

		public AudioInput() {
			// read in the song data
			try {
				BufferedInputStream in = new BufferedInputStream(super.getClass().getResource("/song.4k").openStream());

				for (int chn = 0; chn < 5; chn++) {
					// read patternTable for channel
					CHANNELpatternTable[chn] = new byte[in.read()];
					in.read(CHANNELpatternTable[chn]);

					// read patterndata for channel
					CHANNELpatternData[chn] = new byte[in.read()][];
					for (int j = 0; j < CHANNELpatternData[chn].length; j++) {
						// read all the patterns
						CHANNELpatternData[chn][j] = new byte[in.read()];
						in.read(CHANNELpatternData[chn][j]);
					}
				}
				in.close();
			} catch (Throwable t) {
				t.printStackTrace();
			}

			// instrument used by channel
			CHANNELinstrument[1] = CHANNELinstrument[4] = 1;
			CHANNELinstrument[2] = CHANNELinstrument[3] = 2;

			// base notes for channels
			CHANNELbaseNote[0] = 90;
			CHANNELbaseNote[1] = 44;
			CHANNELbaseNote[2] = CHANNELbaseNote[3] = 50;
			CHANNELbaseNote[4] = 75;

			// generate samples
			Point volStart = new Point(0, 79);
			Point volEnd = new Point(240, 0);

			// snare
			INSTRUMENTsamples[0] = new double[8000];
			Point[] freq = new Point[] {new Point(0, 79*25), new Point(6, 24*25), volEnd};
			Point[] vol = new Point[] {volStart, new Point(10, 77), new Point(11, 0), volEnd};
			sine(INSTRUMENTsamples[0], freq, vol, 100);

			// drum
			INSTRUMENTsamples[1] = new double[44100];
			freq = new Point[] {new Point(0, 12*25), new Point(33, 0),volEnd};
			vol = new Point[] {volStart, new Point(51, 0),volEnd};
			sine(INSTRUMENTsamples[1], freq, vol, 84);

			// melody
			INSTRUMENTsamples[2] = new double[80000];
			freq = new Point[] {new Point(0, 448), new Point(240, 448)};
			vol[1] = new Point(55, 27);
			sine(INSTRUMENTsamples[2], freq, vol, 100);

			for (int i = 0; i < 5; i++) CHANNELpitch[i] = -1;

			// generate ulaw lookup table
			int pos = 2;
			for (int i = 1; i < 8; i++) {
				int tmp = (int) Math.pow(2, i);

				for (int j = tmp; --j >= 0;) {
					lut[pos++] = i;
				}
			}
		}

		/** ulaw lookup table */
		private final int lut[] = new int[256];
	}
}