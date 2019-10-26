package trb.pinball4k.editor;

import java.awt.*;
import java.awt.geom.Point2D;
import java.io.*;
import java.util.*;

/**
 * Before packing flags, score and behavior id:
 * before:                             4181, 636, 430
 * after packing:                      4170, 484, 419
 * after packing and changing loading: 4185, 484, 419
 * 
 * @author tombr
 *
 */
public class Level {
	
	public static final int VISIBLE_MASK 	= (1 << 0);	
	public static final int COLLIDABLE_MASK = (1 << 1);
	public static final int ROLL_OVER_MASK 	= (1 << 2);
	public static final int DROP_DOWN_MASK 	= (1 << 3);
	public static final int GATE_MASK 		= (1 << 4);
	public static final int BUMPER_MASK		= (1 << 5);
	public static final int WRITE_SCORE		= (1 << 6);
	public static final int WRITE_ID		= (1 << 7);
	
	private static final int DEFAULT_WIDTH = 256*4;
	private static final int DEFAULT_HEIGHT = 256*6;

	private int width = DEFAULT_WIDTH;
	private int height = DEFAULT_HEIGHT;
	
	private ArrayList<LevelObject> levelObjects = new ArrayList<LevelObject>();
	public GroupList groups = new GroupList();
	
	/**
	 * Creates a new empty level with the default size.
	 */
	public Level() {
	}
	
	/**
	 * Creates a level read from the specified input stream.
	 * @param in
	 * @throws IOException
	 */
	public Level(InputStream in) throws IOException {
		read(in);
	}
	
	/**
	 * Gets the size of the level in pixels.
	 * @return the size of the level
	 */
	public Dimension getSize() {
		return new Dimension(width, height);
	}
	
	/**
	 * Adds the specified level object to the level.
	 * @param obj the object to add
	 */
	public void add(LevelObject obj) {
		levelObjects.add(obj);
	}
	
	/**
	 * Draws itself to the specified graphics object
	 * @param g where to draw
	 */
	public void draw(Graphics2D g, LevelPanel levelPanel) {
		for (LevelObject obj : levelObjects) {
			obj.draw(g, levelPanel);
		}
	}
	
	/**
	 * Draws the handles to the specified graphics object
	 * @param g where to draw
	 */
	public void drawHandles(Graphics2D g, LevelPanel levelPanel) {
		for (LevelObject obj : levelObjects) {
			obj.drawHandles(g, levelPanel);
		}
	}
	
	/**
	 * Selects the handles that lies withing the specified bounds.
	 * @param rect the selection bounds
	 * @return a list of selected handles
	 */
	public ArrayList<Handle> select(Rectangle rect) {
		ArrayList selected = new ArrayList();
		for (LevelObject obj : levelObjects) {
			ArrayList<Handle> handles = obj.getHandles();
			for (Handle handle : handles) {
				if (handle.intersects(rect)) {
					selected.add(handle);
				}
			}
		}
		
		return selected;
	}
	
	public ArrayList<Handle> select(ArrayList<LevelObject> objects) {
		ArrayList<Handle> selected = new ArrayList<Handle>();
		for (LevelObject obj : levelObjects) {
			if (objects.contains(obj)) {
				selected.addAll(obj.getHandles());
			}
		}
		
		return selected;
	}
	
	/**
	 * Deletes the specified handles.
	 * @param selection the handles to delete
	 */
	public void delete(ArrayList<Handle> selection) {
		System.out.println("delete " + selection.size());
		for (int i = selection.size() - 1; i >= 0; i--) {
			Handle handle = selection.get(i);
			LevelObject obj = handle.getLevelObject();
			if (obj != null) {
				levelObjects.remove(obj);
				selection.remove(i);
				groups.remove(obj);
			}
		}
	}
	
	private ArrayList<ArrayList<Line>> createLineStrips(ArrayList<Line> lines) {
		ArrayList<Line> clone = (ArrayList<Line>) lines.clone();
		ArrayList<ArrayList<Line>> strips = new ArrayList<ArrayList<Line>>();
		
		while (clone.size() > 0) {
			ArrayList<Line> strip = createStrip(clone);
			strips.add(strip);
		}
		
		System.out.println("lines="+lines.size()+" strips="+strips.size());
		return strips;
	}

	/**
	 * 98 - 20 - 39 - 38
	 * Creates a strip from lines and removes strip from lines.
	 * @param lines line soup
	 */
	private ArrayList<Line> createStrip(ArrayList<Line> lines) {
		ArrayList<Line> strip = new ArrayList<Line>();
		
		ArrayList<Line> searchList = (ArrayList<Line>) lines.clone();
		Line start = searchList.get(0);
		
		while (start != null) {
			searchList.remove(start);
			Line newStart = findConnectedLine(searchList, start, false);
			if (newStart == null) {
				break;
			}
			start = newStart;
		}
		
		
		while (start != null) {
			lines.remove(start);
			strip.add(start);
			start = findConnectedLine(lines, start, true);
		}		
		
		return strip;
	}

	private Line findConnectedLine(ArrayList<Line> lines, Line source, boolean forward) {
		for (int i=0; i<lines.size(); i++) {
			Line line = lines.get(i);
			if (line.getSortValue() == source.getSortValue()) {
				if (forward) {
					Point p = source.p2;
					if (p.equals(line.p)) {
						return line;
					}
					if (p.equals(line.p2) && !line.isGate) {
						Point temp = line.p;
						line.p = line.p2;
						line.p2 = temp;
						return line;
					} 
				} else {
					Point p = source.p;
					if (p.equals(line.p) || p.equals(line.p2)) {
						return line;
					}
				}
			}
		}
		
		return null;
	}

	/*
	for (int i = 0; i < groups.getSize() ; i++) {
		ArrayList<LevelObject> group = (ArrayList<LevelObject>) groups.getElementAt(i);
		dataOut.writeByte(group.size());
		for (LevelObject obj : group) {
			dataOut.writeByte(objIdxMap.get(obj).intValue());
		}*/
	private void sortGroups(ArrayList objects) {
		ArrayList sortedList = new ArrayList();
		for (int groupIdx = 0; groupIdx < groups.getSize(); groupIdx++) {
			ArrayList<LevelObject> group = (ArrayList<LevelObject>) groups.getElementAt(groupIdx);
			for (int groupObjIdx = group.size()-1; groupObjIdx>=0; groupObjIdx--) {
				LevelObject groupObj = group.get(groupObjIdx);
				for (int objIdx=0; objIdx<objects.size(); objIdx++) {
					LevelObject curObj = (LevelObject) objects.get(objIdx);
					if (groupObj == curObj) {
						sortedList.add(0, curObj);
						objects.remove(curObj);
					}
				}
			}
		}
		
		objects.addAll(sortedList);
	}
	
	/**
	 * Writes the level to the specified output stream.
	 * @param out where to write the level
	 */
	public void write(OutputStream out, boolean writeBeziers) throws IOException {
		// sort level object into different types
		ArrayList<Flipper> flippers = new ArrayList<Flipper>();
		ArrayList<Line> lines = new ArrayList<Line>();
		ArrayList<Sircle> sircles = new ArrayList<Sircle>();
		ArrayList<Arrow> arrows = new ArrayList<Arrow>();
		ArrayList<Bezier> beziers = new ArrayList<Bezier>();
		
		for (LevelObject obj : levelObjects) {
			if (obj instanceof Flipper) {
				flippers.add((Flipper) obj);
			} else if (obj instanceof Line) {
				lines.add((Line) obj);
			} else if (obj instanceof Sircle) {
				sircles.add((Sircle) obj);
			} else if (obj instanceof Arrow) {
				arrows.add((Arrow) obj);
			} else if (obj instanceof Bezier) {
				Bezier bezier = (Bezier) obj;
				if (writeBeziers) {
					beziers.add(bezier);
				} else {
					Point2D.Float p1 = bezier.interpolate(0);
					int subdivs = bezier.subdivs;
					for (int i=1; i<=subdivs; i++) {
						Point2D.Float p2 = bezier.interpolate(i/(float)subdivs);
						
						Point p1Int = new Point(Math.round(p1.x), Math.round(p1.y));
						Point p2Int = new Point(Math.round(p2.x), Math.round(p2.y));
						
						Line line = new Line(p1Int, p2Int);
						lines.add(line);
						
						p1 = p2;
					}
				}				
			} else {
				System.out.println(getClass() + " level object not supported " + obj.getClass());
			}
		}
		
		Collections.sort(lines, new Line(new Point(), new Point()));
		Collections.sort(sircles, new Line(new Point(), new Point()));
		Collections.sort(arrows, new Line(new Point(), new Point()));
		
		sortGroups(lines);
		sortGroups(sircles);

		// move first line of each strip into lines array. strip will reference this array later
		HashMap<ArrayList<Line>, Integer> stripLineMap = new HashMap<ArrayList<Line>, Integer>();
		ArrayList<ArrayList<Line>> strips = createLineStrips(lines);
		lines.clear();
		for (int stripIdx=0; stripIdx<strips.size(); stripIdx++) {
			ArrayList<Line> strip = strips.get(stripIdx);
			Line firstLine = strip.remove(0);
			if (strip.size() == 0) {
				strips.remove(strip);
				stripIdx--;
			} else {
				stripLineMap.put(strip, lines.size());
			}
			lines.add(firstLine);
		}

		ArrayList<LevelObject> objects = new ArrayList<LevelObject>();

		for (Sircle sircle : sircles) {
			objects.add(sircle);
		}

		for (Arrow arrow : arrows) {
			objects.add(arrow);
		}

		for (Flipper flipper : flippers) {
			objects.add(flipper);
		}
		
		for (Line line : lines) {
			objects.add(line);
		}
		
		// start writing
		DataOutputStream dataOut = new DataOutputStream(out);

		dataOut.writeByte('|');
		dataOut.writeByte('|');
		dataOut.writeByte(flippers.size());
		dataOut.writeByte(sircles.size());
		dataOut.writeByte(arrows.size());
		dataOut.writeByte(lines.size());
		dataOut.writeByte(lines.size()+arrows.size()+sircles.size()+flippers.size());
		
		HashMap<LevelObject, Integer> objIdxMap = new HashMap<LevelObject, Integer>();

		int idx = 0;
		for (LevelObject obj : objects) {
			int flags = getFlags(obj);
			flags |= obj.flagOr;
			dataOut.writeByte(flags);
			dataOut.writeByte(obj.score);
			dataOut.writeByte(obj.behaviorId);
			objIdxMap.put(obj, new Integer(idx));
			idx++;
		}
		for (LevelObject obj : objects) {
			dataOut.writeByte((byte) (obj.p.x / 4));
			dataOut.writeByte((byte) (obj.p.y / 6));
		}
		
		// write sircles
		for (Sircle sircle : sircles) {
//			if (sircle.flagOr != 0) {
				dataOut.writeByte((byte) sircle.radius);
//			}
		}
		
		// write arrows
		for (Arrow arrow : arrows) {
			dataOut.writeByte((byte) arrow.angle);
		}

		// write flippers
		for (Flipper flipper : flippers) {
			if (flipper.minAngle < 0 || flipper.maxAngle < 0) {
				flipper.minAngle = Flipper.toPacked(Flipper.toAngle(flipper.minAngle) + 2*Math.PI);
				flipper.maxAngle = Flipper.toPacked(Flipper.toAngle(flipper.maxAngle) + 2*Math.PI);
			}
			
			dataOut.writeByte((byte) (flipper.minAngle));
			dataOut.writeByte((byte) (flipper.maxAngle));
			dataOut.writeByte(flipper.leftFlipper ? 0 : 2);
		}

		// write lines
		int lineStartIdx = flippers.size() + sircles.size() + arrows.size();
		for (Line line : lines) {
			dataOut.writeByte((byte) (line.p2.x / 4));
			dataOut.writeByte((byte) (line.p2.y / 6));
		}
		
		// write line strips
		dataOut.writeByte(strips.size());
		for (ArrayList<Line> strip : strips) {
			dataOut.writeByte(strip.size());
			dataOut.writeByte(stripLineMap.get(strip)+lineStartIdx);
			for (Line line : strip) {
				dataOut.writeByte((byte) (line.p2.x / 4));
				dataOut.writeByte((byte) (line.p2.y / 6));
				objIdxMap.put(line, new Integer(idx));
				idx++;
			}
		}
		
		dataOut.writeByte(groups.getSize());
		for (int i = 0; i < groups.getSize() ; i++) {
			ArrayList<LevelObject> group = (ArrayList<LevelObject>) groups.getElementAt(i);
			dataOut.writeByte(group.size());
			int firstIdx = objIdxMap.get(group.get(0)).intValue();
			if (group.size() > 0) {
				dataOut.writeByte(firstIdx);
			}
			for (LevelObject obj : group) {
				System.out.print(objIdxMap.get(obj).intValue()+" ");
			}
			System.out.print(" | ");
			for (int j=0; j<group.size(); j++) {
				System.out.print((firstIdx + j)+" ");
			}
			System.out.println();
		}

		if (beziers.size() > 0) {
			dataOut.writeByte(beziers.size());
			// write beziers
			for (Bezier bezier : beziers) {
				dataOut.writeByte((byte) (bezier.p.x / 4));
				dataOut.writeByte((byte) (bezier.p.y / 6));
				dataOut.writeByte((byte) (bezier.p2.x / 4));
				dataOut.writeByte((byte) (bezier.p2.y / 6));
				dataOut.writeByte((byte) (bezier.p3.x / 4));
				dataOut.writeByte((byte) (bezier.p3.y / 6));
				dataOut.writeByte((byte) bezier.subdivs);
			}
		}
		
		System.out.println((objects.size() + beziers.size()) + " objects saved");
	}
	
	
	private int getFlags(LevelObject obj) {
		int flags = 0;
		if (obj.visible) {
			flags |= VISIBLE_MASK;
		}
		if (obj.collidable) {
			flags |= COLLIDABLE_MASK;
		}
		if (obj.isDropDown) {
			flags |= DROP_DOWN_MASK;
		}
		if (obj.isRollOver) {
			flags |= ROLL_OVER_MASK;
		}
		if (obj.isGate) {
			flags |= GATE_MASK;
		}
		if (obj.bounce > 1) {
			flags |= BUMPER_MASK;
		}

		return flags;
	}
	
	private void read(InputStream in) throws IOException {
		DataInputStream dataIn = new DataInputStream(in);
		
		// skip header
		dataIn.readUnsignedByte();
		dataIn.readUnsignedByte();
		int flippers = dataIn.readByte();
		int sircles = dataIn.readByte();
		int arrows = dataIn.readByte();
		int lineCnt = dataIn.readUnsignedByte();
		// obj count
		dataIn.readUnsignedByte();

		for (int i = 0; i < sircles; i++) {
			Sircle sircle = new Sircle(new Point(0, 0), new Point(1, 0));
			levelObjects.add(sircle);
		}

		for (int i = 0; i < arrows; i++) {
			Arrow arrow = new Arrow(new Point(0, 0), new Point(1, 0));
			levelObjects.add(arrow);
		}

		for (int i = 0; i < flippers; i++) {
			Flipper flipper = new Flipper(new Point(0, 0), new Point(1, 0));
			levelObjects.add(flipper);
		}

		for (int i = 0; i < lineCnt; i++) {
			Line line = new Line(new Point(0, 0), new Point(0, 0));
			levelObjects.add(line);
		}			
		
		for (LevelObject obj : levelObjects) {
			int flags = dataIn.readByte();
			obj.visible = (flags & VISIBLE_MASK) != 0;
			obj.collidable = (flags & COLLIDABLE_MASK) != 0;
			obj.isRollOver = (flags & ROLL_OVER_MASK) != 0;
			obj.isDropDown = (flags & DROP_DOWN_MASK) != 0;
			obj.isGate = (flags & GATE_MASK) != 0;
			obj.score = dataIn.readUnsignedByte();
			obj.behaviorId = dataIn.readUnsignedByte();
			//obj.bounce = dataIn.readUnsignedByte() / 64f;
			obj.bounce = (flags & BUMPER_MASK) != 0 ? 1.1f : 0.75f;
		}
		for (LevelObject obj : levelObjects) {
			obj.p.x = dataIn.readUnsignedByte() * 4;
			obj.p.y = dataIn.readUnsignedByte() * 6;
		}
		
		int levelObjIdx = 0;
		
		for (int i = 0; i < sircles; i++) {
			Sircle sircle = (Sircle) levelObjects.get(levelObjIdx++);
			sircle.radius = dataIn.readUnsignedByte();
		}
		
		for (int i = 0; i < arrows; i++) {
			Arrow arrow = (Arrow) levelObjects.get(levelObjIdx++);
			arrow.angle = dataIn.readUnsignedByte();
		}

		for (int i = 0; i < flippers; i++) {
			Flipper flipper = (Flipper) levelObjects.get(levelObjIdx++);
			flipper.length = 134;
			flipper.minAngle = dataIn.readUnsignedByte();
			flipper.maxAngle = dataIn.readUnsignedByte();
			flipper.leftFlipper = (dataIn.readUnsignedByte() == 0);
		}
		
		for (int i = 0; i < lineCnt; i++) {
			Line line = (Line) levelObjects.get(levelObjIdx++);
			line.p2.x = dataIn.readUnsignedByte() * 4;
			line.p2.y = dataIn.readUnsignedByte() * 6;
		}


		ArrayList<ArrayList<Line>> stripsArray = new ArrayList<ArrayList<Line>>();
		
		int strips = dataIn.readByte();
		int stripBytes = 1+(strips*2);
		for (int stripIdx=0; stripIdx<strips; stripIdx++) {
			int lines = dataIn.readUnsignedByte();
			int prevIdx = dataIn.readUnsignedByte();
			ArrayList<Line> linesArray = new ArrayList<Line>();
			linesArray.add((Line) levelObjects.get(prevIdx));
			for (int lineIdx=0; lineIdx<lines; lineIdx++) {
				Line line = new Line((Line) levelObjects.get(prevIdx));
				line.p.setLocation(line.p2);
				int x_ = dataIn.readUnsignedByte();
				int y_ = dataIn.readUnsignedByte();
				line.p2.x = x_ * 4;
				line.p2.y = y_ * 6;
				prevIdx = levelObjects.size();
				levelObjects.add(line);
				stripBytes += 2;
				
				linesArray.add(line);
			}			
			
			stripsArray.add(linesArray);			
		}
		
		int groupCnt = dataIn.readByte();
		int groupBytes = 1+groupCnt*2;
		for (int groupIdx = 0; groupIdx < groupCnt; groupIdx++) {
			int objCnt = dataIn.readByte();
			int firstIdx = dataIn.readByte();
			ArrayList<LevelObject> group = new ArrayList<LevelObject>();
			for (int objIdx = 0; objIdx < objCnt; objIdx++) {
				int groupObjIdx = firstIdx + objIdx;
				LevelObject groupObj = levelObjects.get(groupObjIdx);
				group.add(groupObj);
			}
			groups.add(group);
		}

		if (dataIn.available() > 0) {
			int beziers = dataIn.readByte();
			for (int i = 0; i < beziers; i++) {
				Bezier bezier = new Bezier(new Point(0, 0), new Point(0, 0), new Point(0, 0));
				bezier.p.x = dataIn.readUnsignedByte() * 4;
				bezier.p.y = dataIn.readUnsignedByte() * 6;
				bezier.p2.x = dataIn.readUnsignedByte() * 4;
				bezier.p2.y = dataIn.readUnsignedByte() * 6;
				bezier.p3.x = dataIn.readUnsignedByte() * 4;
				bezier.p3.y = dataIn.readUnsignedByte() * 6;
				bezier.subdivs = dataIn.readUnsignedByte();
				levelObjects.add(bezier);
			}
		}
		
		int flipperBytes = 1 + (flippers * 9);
		int sircleBytes = 1 + (sircles * 6);
		int arrowBytes = 1 + (arrows * 6);
		int lineBytes = 1 + (lineCnt * 7);
		int total = flipperBytes + sircleBytes + stripBytes + groupBytes + lineBytes;
		System.out.println("reading level");
		System.out.println(flippers+" flippers (9) "+flipperBytes);
		System.out.println(sircles+" sircles (6) "+sircleBytes);
		System.out.println(arrows+" arrows (6) "+arrowBytes);
		System.out.println(lineCnt+" lines (7) "+lineBytes);
		System.out.println(strips+" strips "+stripBytes);
		System.out.println(groupCnt+" groupes "+groupBytes);
		System.out.println(total+" total");

	
		/*
		// paint strips
		try {
			JFrame frame = new JFrame();
			frame.setSize(1024, 768);
			frame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
		
			BufferedImage img = new BufferedImage(552, 868, BufferedImage.TYPE_INT_ARGB);
			Graphics g = img.getGraphics();
			g.setColor(Color.BLACK);
			g.fillRect(0, 0, 2000, 2000);
			for (ArrayList<Line> strip : stripsArray) {
				g.setColor(new Color(0x8080 | (int) (Math.random() * 0xffffff)));
				for (Line line : strip) {
					g.drawLine(line.p.x/2, line.p.y/2, line.p2.x/2, line.p2.y/2);
				}
			}
			g.dispose();
			ImageIcon icon = new ImageIcon(img);
			JLabel lbl = new JLabel(icon);
			frame.getContentPane().add(lbl, BorderLayout.CENTER);
			frame.setVisible(true);
		} catch (Exception e) {
			e.printStackTrace();
		}*/
	}
}
