package trb.pinball4k.editor;

import java.awt.*;
import javax.swing.*;

public class QuadBezier extends JPanel {
	
	public void paintComponent(Graphics g) {		
		float[] xs = {100, 200, 200, 200, 300};
		float[] ys = {100, 100, 200, 150, 200};
		
		for (int curveIdx=0; curveIdx < (xs.length-1)/2; curveIdx++) {
			int idx = curveIdx * 2;
			float x0 = xs[idx];
			float y0 = ys[idx];
			float x1 = xs[idx+1];
			float y1 = ys[idx+1];
			float x2 = xs[idx+2];
			float y2 = ys[idx+2];
			
			float prevx = x0;
			float prevy = y0;
			for (float t=0; t<=1; t+=0.01f) {
				float t2 = t*t;
				float tinv = 1-t;
				float tinv2 = tinv*tinv;
				
				float x = tinv2 * x0 + 2*t*tinv*x1 + t2*x2; 
				float y = tinv2 * y0 + 2*t*tinv*y1 + t2*y2;
				g.drawLine((int) prevx, (int) prevy, (int) x, (int) y);
				prevx = x;
				prevy = y;
			}
		}
	}
	

	public static void main(String[] args) {
		JFrame frame = new JFrame();
		frame.setSize(640, 480);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.getContentPane().add(new QuadBezier(), BorderLayout.CENTER);
		frame.setVisible(true);
	}
}
