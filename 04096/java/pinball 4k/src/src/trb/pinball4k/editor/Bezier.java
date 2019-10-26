package trb.pinball4k.editor;


import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.geom.Point2D;
import java.lang.reflect.Field;

public class Bezier extends LevelObject {
	public Point p2;
	public Point p3;
	public int subdivs = 8;
	
	private EndpointHandle p1Handle = new EndpointHandle(0);
	private EndpointHandle p2Handle = new EndpointHandle(1);
	private EndpointHandle p3Handle = new EndpointHandle(2);
	
	public Bezier(Point p1, Point p2, Point p3) {
		this.p = new Point(p1);
		this.p2 = new Point(p2);
		this.p3 = new Point(p3);
		
		handles.add(p1Handle);
		handles.add(p2Handle);
		handles.add(p3Handle);
	}
	
	/**
	 * Draws itself to the specified graphics object
	 * @param g where to draw
	 */
	public void draw(Graphics2D g, LevelPanel levelPanel) {
		g.setColor(Color.WHITE);
		float x0 = p.x;
		float y0 = p.y;
		float x1 = p2.x;
		float y1 = p2.y;
		float x2 = p3.x;
		float y2 = p3.y;
		
		//int subdivs = (int) Math.max(5, ((Math.abs(x2-x0) + Math.abs(y2-y0)) / 10));
		
		float prevx = x0;
		float prevy = y0;
		for (int i=1; i<=subdivs; i++) {
			float t = i / (float) (subdivs);
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
	
	public Point2D.Float interpolate(float t) {
		float t2 = t*t;
		float tinv = 1-t;
		float tinv2 = tinv*tinv;
		
		float x = tinv2 * p.x + 2*t*tinv*p2.x + t2*p3.x; 
		float y = tinv2 * p.y + 2*t*tinv*p2.y + t2*p3.y;
		return new Point2D.Float(x, y);
	}
	
	/**
	 * Draws the handles to the specified graphics object
	 * @param g where to draw
	 */
	public void drawHandles(Graphics2D g, LevelPanel levelPanel) {
		p1Handle.draw(g, levelPanel);
		p2Handle.draw(g, levelPanel);
		p3Handle.draw(g, levelPanel);
	}	
	
	/**
	 * The public properties to show in the editor ui.
	 * @return the properties to show
	 */
	public Field[] getProperties() {
		return getFields("visible", "collidable", "isRollOver", "score", "bounce", "behaviorId", "p", "p2", "p3", "subdivs");
	}	
	
	/*
	 *  (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		return "Bezier (" + p.x + ", " + p.y + ")" + " (" + p2.x + ", " + p2.y + ")" + " (" + p3.x + ", " + p3.y + ")";
	}
	
	/**
	 * A handle for one of the lines.
	 * @author tombr
	 *
	 */
	class EndpointHandle extends Handle {
		int pointIdx = 0;
		EndpointHandle(int pointIdx) {
			this.pointIdx = pointIdx;
		}
		
		/**
		 * Overrides Handle. Gets the endpoint.
		 * @return the handles endpoint
		 */
		public Point getCenter() {
			if (pointIdx == 1) {
				return p2;
			} else if (pointIdx == 2) {
				return p3;
			}
			
			return p;
		}
		
		/**
		 * The handle is dragged to the specified position. Moves the endpoin 
		 * the distance dragged.
		 * @param p where the handle is dragged to
		 */
		public void dragged(int dx, int dy) {
			getCenter().translate(dx, dy);
		}
		
		/**
		 * Gets the level object the hangle controlls. Can be null.
		 * @return the level object
		 */
		public LevelObject getLevelObject() {
			return Bezier.this;
		}
	}
}
