package trb.pinball4k.editor;

import java.awt.Graphics2D;
import java.awt.Point;
import java.io.DataInput;
import java.io.IOException;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Comparator;

public abstract class LevelObject implements Comparator<LevelObject> {

	
	/** Is object visible or not */
	public boolean visible = true;

	/** Is object collidable or not */
	public boolean collidable = true;
	
	/** Is drop down object */
	public boolean isDropDown = false;
	
	/** Is drop down object */
	public boolean isRollOver = false;
	
	/** Is drop down object */
	public boolean isGate = false;
	
	public boolean isStripStart = false;
	public int flagOr = 0;
	
	/** The score to add object is triggered */
	public int score = 0;
	
	/** The bounce factor  */
	public float bounce = 0.75f;	
	
	/** Object behaviour */
	public int behaviorId = 0;

	/** location of object */
	public Point p;
	
	/** The object properties */
	//public ObjectProperties properties = new ObjectProperties();
	

	public LevelObject() {
	}
	
	/** 
	 * The list of handles that can manipulate this object. Must be set by objects
	 * that inherits from this class.
	 */
	protected ArrayList<Handle> handles = new ArrayList<Handle>();
	
	/**
	 * Draws itself to the specified graphics object
	 * @param g where to draw
	 */
	public abstract void draw(Graphics2D g, LevelPanel levelPanel);
	
	/**
	 * Draws the handles to the specified graphics object
	 * @param g where to draw
	 */
	public abstract void drawHandles(Graphics2D g, LevelPanel levelPanel);
	
	/**
	 * Gets the object handles.
	 * @return the list of object handles
	 */
	public ArrayList<Handle> getHandles() {
		return handles;
	}
	
	/**
	 * The public properties to show in the editor ui.
	 * @return the properties to show
	 */
	public Field[] getProperties() {
		return new Field[0];
	}
	
	/**
	 * Gets a list of fields by their names.
	 * @param names names of the fields to get
	 * @return the fields
	 */
	protected Field[] getFields(String... names) {
		Field[] fields = new Field[names.length];
		try {
			Class cls = getClass();
			for (int i=0; i<names.length; i++) {
				fields[i] = cls.getField(names[i]);
			}
		} catch (NoSuchFieldException e) {
			e.printStackTrace();
			return new Field[0];
		}
		return fields;
	}
	
	public int getSortValue() {
		int value = 0;
		value |= isDropDown ? (1 << 0) : 0;
		value |= isRollOver ? (1 << 1) : 0;
		value |= isGate     ? (1 << 2) : 0;
		value |= visible    ? (1 << 3) : 0;
		value |= collidable ? (1 << 4) : 0;

		value |= ((int) (bounce*64) << 12);
		value |= (score << 20);
		value |= (behaviorId << 28);
		return value;
	}
	
	/**
	 * Implements Comparator.
	 */
	public int compare(LevelObject o1, LevelObject o2) {
		return o1.getSortValue() - o2.getSortValue();
	}
}
