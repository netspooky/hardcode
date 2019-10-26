package trb.pinball4k.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.geom.Line2D;
import java.lang.reflect.Field;
import java.util.Comparator;

public class Line extends LevelObject {
	
	private static int nextId = 1;
	
	private int id = 0;
	
	public Point p2;
	
	private LineHandle lineHandle = new LineHandle();
	private EndpointHandle p1Handle = new EndpointHandle(true);
	private EndpointHandle p2Handle = new EndpointHandle(false);
	
	public Line(Line line) {
		this(line.p, line.p2);
		
		this.isDropDown = line.isDropDown;
		this.isRollOver = line.isRollOver;
		this.isGate = line.isGate;
		this.visible = line.visible;
		this.collidable = line.collidable;
		this.bounce = line.bounce;
		this.behaviorId = line.behaviorId;
		this.score = line.score;
	}
	
	public Line(Point p1, Point p2) {
		this.p = new Point(p1);
		this.p2 = new Point(p2);
		this.id = nextId++;
		
		handles.add(lineHandle);
		handles.add(p1Handle);
		handles.add(p2Handle);
	}
	
	/**
	 * Draws itself to the specified graphics object
	 * @param g where to draw
	 */
	public void draw(Graphics2D g, LevelPanel levelPanel) {
		g.setColor(Color.WHITE);
		if (levelPanel.getState() == LevelPanel.State.SELECT) {
			if (levelPanel.isSelected(this)) {
				g.setColor(Color.red);
			}
			
			Point mousePos = levelPanel.getMousePosition();
			if (mousePos != null) {
				Rectangle mouseRect = new Rectangle(mousePos, new Dimension(1, 1));
				if (lineHandle.intersects(mouseRect)) {
					g.setColor(new Color(0xff7f0000));				
				}
			}
			if (lineHandle.intersects(levelPanel.selectRect)) {
				g.setColor(new Color(0xff7f0000));				
			}
		}
		
		g.drawLine(p.x, p.y, p2.x, p2.y);
	}	
	
	/**
	 * Draws the handles to the specified graphics object
	 * @param g where to draw
	 */
	public void drawHandles(Graphics2D g, LevelPanel levelPanel) {
		p1Handle.draw(g, levelPanel);
		p2Handle.draw(g, levelPanel);
	}		
	
	/**
	 * The public properties to show in the editor ui.
	 * @return the properties to show
	 */
	public Field[] getProperties() {
		return getFields("visible", "collidable", "isDropDown", "isRollOver"
				, "isGate", "score", "bounce", "behaviorId", "p", "p2");
	}	
	
	/*
	 *  (non-Javadoc)
	 * @see java.lang.Object#toString()
	 */
	public String toString() {
		return "Line "+id;
	}
	
	/**
	 * A handle for one of the lines.
	 * @author tombr
	 *
	 */
	class LineHandle extends Handle {
		LineHandle() {
		}
		
		/**
		 * Draws itself to the specified graphics object
		 * @param g where to draw
		 */
		public void draw(Graphics2D g, LevelPanel levelPanel) {
		}
		
		public boolean intersects(Rectangle rect) {
			Line2D.Float line = new Line2D.Float(p, p2);
			if (rect.width <= 1 && rect.height <= 1) {
				return line.ptSegDist(new Point(rect.x, rect.y)) < 5;
			} 

			return line.intersects(rect);
			/*
			if (rect.contains(p) || rect.contains(p2)) {
				return true;
			}
			*/
			
		}
		
		/**
		 * Overrides Handle. Gets the endpoint.
		 * @return the handles endpoint
		 */
		public Point getCenter() {
			return p;
		}
		
		/**
		 * The handle is dragged to the specified position. Moves the endpoin 
		 * the distance dragged.
		 * @param p where the handle is dragged to
		 */
		public void dragged(int dx, int dy) {
			if (!LevelPanel.instance.selection.contains(p1Handle) && !LevelPanel.instance.selection.contains(p2Handle)) {
				p.translate(dx, dy);
				p2.translate(dx, dy);
			}
		}
		
		/**
		 * Gets the level object the hangle controlls. Can be null.
		 * @return the level object
		 */
		public LevelObject getLevelObject() {
			return Line.this;
		}
	}
	
	/**
	 * A handle for one of the lines.
	 * @author tombr
	 *
	 */
	class EndpointHandle extends Handle {
		boolean handleFirstEndpoint = true;
		EndpointHandle(boolean handleFirstEndpoint) {
			this.handleFirstEndpoint = handleFirstEndpoint;
		}
		
		/**
		 * Overrides Handle. Gets the endpoint.
		 * @return the handles endpoint
		 */
		public Point getCenter() {
			return handleFirstEndpoint ? p : p2;
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
			return Line.this;
		}
	}
}
