package trb.pinball4k.editor;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;

public abstract class Handle {

	/**
	 * Gets the center of the handle.
	 * @return the center
	 */
	public abstract Point getCenter();
	
	/** 
	 * Gets the size of the handle.
	 * @return the size of the handle
	 */
	public int getSize() {
		return 12;
	}
	
	/**
	 * Draws itself to the specified graphics object
	 * @param g where to draw
	 */
	public void draw(Graphics2D g, LevelPanel levelPanel) {
		if (levelPanel.getState() == LevelPanel.State.SELECT) {
			Point handleCenter = getCenter();
			int x = handleCenter.x;
			int y = handleCenter.y;
			int size = getSize();
			x -= size / 2;
			y -= size / 2;
			Rectangle rect = new Rectangle(x, y, size, size);
			g.setColor(new Color(0xff0000ff));
			Point mousePos = levelPanel.getMousePosition();
			if ((mousePos != null && rect.contains(mousePos)) 
					|| levelPanel.isHandleSelected(this)) {
				g.fillRect(x, y, size, size);
			} else {
				g.drawRect(x, y, size, size);
			}
		}
	}
	
	/**
	 * Checks if handle contains the specified point.
	 * @param p the point to check
	 * @return true if handle contains point
	 */
	/*public boolean contains(Point p) {
		return getBounds().contains(p);
	}*/
	public boolean intersects(Rectangle rect) {
		return (getBounds().intersects(rect) || rect.contains(getCenter()));
	}
	
	/**
	 * Gets the bounds of the handle
	 * @return the bounds
	 */
	private Rectangle getBounds() {
		Point p = getCenter();
		int s = getSize();
		return new Rectangle(p.x - (s / 2), p.y - (s / 2), s, s);
	}
	
	public abstract void dragged(int dx, int dy);
	
	/**
	 * Gets the level object the hangle controlls. Can be null.
	 * @return the level object
	 */
	public LevelObject getLevelObject() {
		return null;
	}
}
