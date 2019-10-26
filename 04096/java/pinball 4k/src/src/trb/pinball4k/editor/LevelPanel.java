package trb.pinball4k.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.awt.geom.Rectangle2D;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComponent;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JToggleButton;
import javax.swing.JToolBar;
import javax.swing.border.BevelBorder;

public class LevelPanel extends JComponent implements MouseListener
		, MouseMotionListener, ActionListener, KeyListener {
	
	
	public static LevelPanel instance;

	public enum State {SELECT, LINE, SIRCLE, ARROW, TRIGGER, FLIPPER, BEZIER};
	
	private State currentState = State.SELECT;
	
	GroupUI groupUI;
	Editor editor;
	Level level;
	
	private static boolean snapToGrid = true;
	private ArrayList<Point> clickedPoints = new ArrayList<Point>();
	private Point pressedPoint = null;
	private Point draggedPoint = null;
	private Point movedPoint = null;

	JToolBar toolbar = new JToolBar();
	JToggleButton selectBtn = new JToggleButton("Select");
	JToggleButton lineBtn = new JToggleButton("Line");
	JToggleButton sircleBtn = new JToggleButton("Sircle");
	JToggleButton arrowBtn = new JToggleButton("Arrow");
	JToggleButton triggerBtn = new JToggleButton("Trigger");
	JToggleButton flipperBtn = new JToggleButton("Flipper");
	JToggleButton bezierBtn = new JToggleButton("Bezier");

	JButton groupBtn = new JButton("Group");
	JButton deleteBtn = new JButton("Delete");
	JButton newBtn = new JButton("New");
	JButton openBtn = new JButton("Open...");
	JButton saveBtn = new JButton("Save");
	JButton saveAsBtn = new JButton("Save As...");
	JButton backgroundBtn = new JButton("Background...");
	JButton runBtn = new JButton("Run");
	
	JCheckBox bezierChk = new JCheckBox("Export beziers");
		
	// The directory that is opened in the file choosers. Is updated when a
	// file is opened or saved.
	File currentDirectory = null;
	File currentFile = null;
	
	Rectangle selectRect = new Rectangle();
	ArrayList<Handle> selection = new ArrayList<Handle>();
	boolean dragSelection = false;
	
	private BufferedImage backgroundImage = null;
	
	public LevelPanel(Editor editor) {
		super();
	
		this.editor = editor;
		
		currentDirectory = new File(System.getProperty("user.dir"));
		//openLevel(new File(System.getProperty("user.dir") + "/levelShort.bin"));
		openLevel(new File(System.getProperty("user.dir") + "/a"));
		
		Dimension preferredSize = new Dimension(level.getSize());
		preferredSize.height += 32;
		setPreferredSize(preferredSize);
		revalidate();
		
		addMouseListener(this);
		addMouseMotionListener(this);
		addKeyListener(this);
		setFocusable(true);
		
		selectBtn.setMnemonic(KeyEvent.VK_S);
		lineBtn.setMnemonic(KeyEvent.VK_L);
		triggerBtn.setMnemonic(KeyEvent.VK_T);
		flipperBtn.setMnemonic(KeyEvent.VK_F);
		sircleBtn.setMnemonic(KeyEvent.VK_I);
		arrowBtn.setMnemonic(KeyEvent.VK_A);
		deleteBtn.setMnemonic(KeyEvent.VK_D);
		runBtn.setMnemonic(KeyEvent.VK_R);
		bezierBtn.setMnemonic(KeyEvent.VK_B);

		// setup toolbar
		selectBtn.addActionListener(this);
		lineBtn.addActionListener(this);
		sircleBtn.addActionListener(this);
		arrowBtn.addActionListener(this);
		triggerBtn.addActionListener(this);
		flipperBtn.addActionListener(this);
		bezierBtn.addActionListener(this);
		groupBtn.addActionListener(this);
		deleteBtn.addActionListener(this);
		newBtn.addActionListener(this);
		openBtn.addActionListener(this);
		saveBtn.addActionListener(this);
		saveAsBtn.addActionListener(this);
		backgroundBtn.addActionListener(this);
		runBtn.addActionListener(this);
		
		ButtonGroup buttonGroup = new ButtonGroup();
		buttonGroup.add(selectBtn);
		buttonGroup.add(lineBtn);
		buttonGroup.add(sircleBtn);
		buttonGroup.add(arrowBtn);
		buttonGroup.add(triggerBtn);
		buttonGroup.add(flipperBtn);
		buttonGroup.add(bezierBtn);
		
		selectBtn.setSelected(true);
		
		toolbar.setFloatable(false);
		toolbar.add(newBtn);
		toolbar.add(openBtn);
		toolbar.add(saveBtn);
		toolbar.add(saveAsBtn);
		toolbar.addSeparator();
		toolbar.add(runBtn);
		toolbar.addSeparator();
		toolbar.add(backgroundBtn);
		toolbar.addSeparator();
		toolbar.add(selectBtn);
		toolbar.add(lineBtn);
		toolbar.add(arrowBtn);		
		toolbar.add(sircleBtn);		
		toolbar.add(triggerBtn);
		toolbar.add(flipperBtn);
		toolbar.add(bezierBtn);
		toolbar.addSeparator();
		toolbar.add(groupBtn);
		toolbar.add(deleteBtn);
		toolbar.addSeparator();
		toolbar.add(bezierChk);
		
		instance = this;
	}
	
	/**
	 * Overrides JComponent. Draws the level.
	 */
    protected void paintComponent(Graphics g) {
    	try {
            g.setColor(Color.BLACK);
            g.fillRect(0, 0, getWidth(), getHeight());
            Graphics2D g2d = (Graphics2D)g.create();

            if (backgroundImage != null) {
            	//int width = backgroundImage.getWidth() * 1400 / backgroundImage.getHeight();
            	//g.drawImage(backgroundImage, 0, 0, width, 1400, null);
            	g.drawImage(backgroundImage, 0, 0, null);
            }
            
            g.setColor(new Color(32, 32, 32));
            for (int y=0; y<100; y++) {
            	g.drawLine(0, y*24, 10000, y*24);
            	g.drawLine(y*16, 0, y*16, 10000);
            }
            g.setColor(new Color(64, 64, 64));
            for (int y=0; y<20; y++) {
            	g.drawLine(0, y*24*8, 10000, y*24*8);
            	g.drawLine(y*16*8, 0, y*16*8, 10000);
            }
            g.setColor(Color.RED);
            g.drawRect(0, 0, level.getSize().width, level.getSize().height);
            
            level.draw(g2d, this);
            level.drawHandles(g2d, this);
            
            if (pressedPoint != null && draggedPoint != null) {
            	switch (currentState) {
            	case SIRCLE:
            		Sircle sircle = new Sircle(pressedPoint, draggedPoint);
            		sircle.draw(g2d, this);
            		break;
            	case FLIPPER:
            		Flipper flipper = new Flipper(pressedPoint, draggedPoint);
            		flipper.draw(g2d, this);
            		break;
            	}
            }
            
        	switch (currentState) {
        	case LINE:
                if (clickedPoints.size() > 0 && movedPoint != null) {
                	Line line = new Line(clickedPoints.get(0), movedPoint);
                	line.draw(g2d, this);
                }
        		break;
        	case ARROW:
                if (clickedPoints.size() > 0 && movedPoint != null) {
                	Arrow arrow = new Arrow(clickedPoints.get(0), movedPoint);
                	arrow.draw(g2d, this);
                }
        		break;
        	case BEZIER:
        		if (clickedPoints.size() > 1 && movedPoint != null) {
            		Bezier bezier = new Bezier(clickedPoints.get(0), clickedPoints.get(1), movedPoint);
            		bezier.draw(g2d, this);
        		} else if (clickedPoints.size() > 0 && movedPoint != null) {
            		Bezier bezier = new Bezier(clickedPoints.get(0), movedPoint, movedPoint);
            		bezier.draw(g2d, this);
        		}
        		break;
        	}
            
            // draw cross
            if (movedPoint != null) {
            	Point p = snapToGrid(movedPoint);
            	g2d.setColor(new Color(0xffffff00));
            	int crossSize = 5;
            	g2d.drawLine(p.x - crossSize, p.y, p.x + crossSize, p.y);
            	g2d.drawLine(p.x, p.y - crossSize, p.x, p.y + crossSize);

            	String text = "(" + p.x + ", " + p.y + ")";
            	Font font = new Font("SansSerif", Font.PLAIN, 12);
        		g2d.setFont(font);
        		Rectangle2D bounds = font.getStringBounds(text, g2d.getFontRenderContext());
        		g2d.drawString(text, p.x - (int) bounds.getWidth() / 2, p.y - 5);
            }
            
            if (dragSelection) {
            	g2d.setColor(new Color(0xffffffff));
            	Rectangle r = toRect(pressedPoint, draggedPoint);
            	g2d.drawRect(r.x, r.y, r.width, r.height);
            }
            
            g2d.dispose(); //clean up
    	} catch (Throwable t) {
    		t.printStackTrace();
    	}
    }
    
    /**
     * 
     * @param p
     * @return
     */
    public static Point snapToGrid(java.awt.Point p) {
    	if (snapToGrid) {
        	return new Point((p.x + 2) / 4 * 4, (int) (Math.round(p.y / 6f) * 6)); 
    	}
    	
    	return p;
    }

	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == selectBtn) {
			setState(LevelPanel.State.SELECT);
		} else if (e.getSource() == lineBtn) {
			setState(LevelPanel.State.LINE);	
		} else if (e.getSource() == sircleBtn) {
			setState(LevelPanel.State.SIRCLE);	
		} else if (e.getSource() == arrowBtn) {
			setState(LevelPanel.State.ARROW);	
		} else if (e.getSource() == triggerBtn) {
			setState(LevelPanel.State.TRIGGER);	
		} else if (e.getSource() == flipperBtn) {
			setState(LevelPanel.State.FLIPPER);	
		} else if (e.getSource() == bezierBtn) {
			setState(LevelPanel.State.BEZIER);	
		} else if (e.getSource() == groupBtn) {
			ArrayList<LevelObject> group = new ArrayList<LevelObject>();
			for (Handle handle : selection) {
				LevelObject obj = handle.getLevelObject();
				if (obj != null && !group.contains(obj)) {
					group.add(obj);
				}
			}
			if (group.size() > 0) {
				level.groups.add(group);
			}
		} else if (e.getSource() == deleteBtn) {
			level.delete(selection);
		} else if (e.getSource() == newBtn) {
			level = new Level();
			groupUI.levelChanged();
		} else if (e.getSource() == backgroundBtn) {
			JFileChooser chooser = new JFileChooser(currentDirectory);
		    int returnVal = chooser.showOpenDialog(editor);
		    if (returnVal == JFileChooser.APPROVE_OPTION) {
		    	currentDirectory = chooser.getCurrentDirectory();
		    	openBackground(chooser.getSelectedFile());
		    }	
		} else if (e.getSource() == openBtn) {
			JFileChooser chooser = new JFileChooser(currentDirectory);
		    int returnVal = chooser.showOpenDialog(editor);
		    if (returnVal == JFileChooser.APPROVE_OPTION) {
		    	currentDirectory = chooser.getCurrentDirectory();
		    	openLevel(chooser.getSelectedFile());
		    }	
		} else if (e.getSource() == saveBtn) {
			saveLevel();
		} else if (e.getSource() == saveAsBtn) {
			JFileChooser chooser = new JFileChooser(currentDirectory);
		    int returnVal = chooser.showSaveDialog(editor);
		    if (returnVal == JFileChooser.APPROVE_OPTION) {
		    	currentDirectory = chooser.getCurrentDirectory();
		    	currentFile = chooser.getSelectedFile();
		    	saveLevel();
		    	saveBtn.setEnabled(true);
		    }	
		} else if (e.getSource() == runBtn) {
			try {
				System.out.println("run");
				ProcessBuilder processBuilder = new ProcessBuilder("java", "-classpath", "bin;.", "a");
				processBuilder.redirectErrorStream(true);
				Process p = processBuilder.start();
				new ProcessStreamReader(p.getInputStream());
				System.out.println(processBuilder.directory());
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		repaint();
	}

	public void mouseClicked(MouseEvent e) {
		clickedPoints.add(snapToGrid(e.getPoint()));
		handleClick(clickedPoints);
	}

	public void mouseEntered(MouseEvent e) {
	}

	public void mouseExited(MouseEvent e) {
	}

	public void mousePressed(MouseEvent e) {
		dragSelection = false;
		if (e.getButton() == MouseEvent.BUTTON1) {
			
			pressedPoint = snapToGrid(e.getPoint());
			draggedPoint = snapToGrid(e.getPoint());
			
			if (currentState == State.SELECT) {
				selectRect = new Rectangle(e.getPoint(), new Dimension(1, 1));
				ArrayList<Handle> newSelection = level.select(selectRect);
				
				if (!e.isControlDown()) {
					selection.clear();
				}
				
				for (Handle handle : newSelection) {
					if (selection.contains(handle) == false) {
						selection.add(handle);
					} else {
						selection.remove(handle);
					}
				}
				
				if (selection.size() == 0) {
					dragSelection = true;
				} else {
					editor.select(selection);
				}
			}
			
			repaint();
		}
		
		requestFocusInWindow();
	}

	public void mouseReleased(MouseEvent e) {
		try {
			selectRect = new Rectangle();
			if (dragSelection) {
				editor.select(selection);
				dragSelection = false;
			}
			if (e.getButton() == MouseEvent.BUTTON1) {
				Point releasePoint = snapToGrid(e.getPoint());
				handleDrag(pressedPoint, releasePoint);
				if ((e.getModifiersEx() & MouseEvent.CTRL_DOWN_MASK) != 0) {
					pressedPoint = releasePoint;
					draggedPoint = releasePoint;
				} else {
					pressedPoint = null;
					draggedPoint = null;
				}
				repaint();
			}
		} catch (Throwable t) {
			t.printStackTrace();
		}
	}

	public void mouseDragged(MouseEvent e) {
		try {
			Point lastDraggedPoint = draggedPoint;
			movedPoint = snapToGrid(e.getPoint());
			draggedPoint = (currentState == State.SIRCLE ? e.getPoint() : snapToGrid(e.getPoint()));
			
			if (currentState == State.SELECT) {
				if (dragSelection) {
					selectRect = toRect(pressedPoint, draggedPoint);
					selection.clear();
					selection = level.select(selectRect);
				} else {
					for (Handle handle : selection) {
						handle.dragged(draggedPoint.x-lastDraggedPoint.x, draggedPoint.y-lastDraggedPoint.y);
					}
				}
			}
			
			repaint();
		} catch (Throwable t) {
			t.printStackTrace();
		}
	}

	public void mouseMoved(MouseEvent e) {
		movedPoint = snapToGrid(e.getPoint());
		repaint();
	}

	public void keyPressed(KeyEvent e) {
		try {
			boolean ctrlDown = ((e.getModifiersEx() & KeyEvent.CTRL_DOWN_MASK) != 0);
			if (ctrlDown) {
				if (e.getKeyCode() == KeyEvent.VK_S) {
					saveBtn.doClick();
				}			
			} else {
				switch (e.getKeyCode()) {
				case KeyEvent.VK_DELETE:
				case KeyEvent.VK_SPACE:
					deleteBtn.doClick();
					break;
				case KeyEvent.VK_F1:
					selectBtn.doClick();
					break;
				case KeyEvent.VK_F2:
					sircleBtn.doClick();
					break;
				case KeyEvent.VK_F3:
					arrowBtn.doClick();
					break;
				case KeyEvent.VK_F4:
					lineBtn.doClick();
					break;
				case KeyEvent.VK_F5:
					flipperBtn.doClick();
					break;
				case KeyEvent.VK_F6:
					triggerBtn.doClick();
					break;
				case KeyEvent.VK_W:
					if (currentState == State.SELECT) {
						for (Handle handle : selection) {
							handle.dragged(0, -6);
						}
						repaint();
					}
					break;
				case KeyEvent.VK_S:
					if (currentState == State.SELECT) {
						for (Handle handle : selection) {
							handle.dragged(0, 6);
						}
						repaint();
					}
					break;
				case KeyEvent.VK_A:
					if (currentState == State.SELECT) {
						for (Handle handle : selection) {
							handle.dragged(-4, 0);
						}
						repaint();
					}
					break;
				case KeyEvent.VK_D:
					if (currentState == State.SELECT) {
						for (Handle handle : selection) {
							handle.dragged(4, 0);
						}
						repaint();
					}
					break;
				}
			}
		} catch (Throwable t) {
			t.printStackTrace();
		}
	}

	public void keyReleased(KeyEvent e) {
	}

	public void keyTyped(KeyEvent e) {
	}
	
	/**
	 * Handles a mouse drag or click.
	 * @param pressedPos the position of the mouse when it was pressed
	 * @param releasedPos the position of the mouse when it was released
	 */
	private void handleDrag(Point pressedPos, Point releasedPos) {
		if (pressedPos != null && releasedPos != null) {
			if (releasedPos.equals(pressedPos) == false) {
				switch (currentState) {
				case SIRCLE:
					Sircle sircle = new Sircle(pressedPos, releasedPos);
					level.add(sircle);
					break;

				case FLIPPER:
					Flipper flipper = new Flipper(pressedPos, releasedPos);
					level.add(flipper);
					break;
				}
			}
		}
	}
	
	/**
	 * Handles a mouse drag or click.
	 * @param pressedPos the position of the mouse when it was pressed
	 * @param releasedPos the position of the mouse when it was released
	 */
	private void handleClick(ArrayList<Point> list) {
		switch (currentState) {
		case LINE:
			if (list.size() >= 2 && !list.get(0).equals(list.get(1))) {
				Line line = new Line(list.get(0), list.get(1));
				level.add(line);
				list.clear();
			}
			break;
		case ARROW:
			if (list.size() >= 2 && !list.get(0).equals(list.get(1))) {
				Arrow arrow = new Arrow(list.get(0), list.get(1));
				level.add(arrow);
				list.clear();
			}
			break;
		case BEZIER:
			if (list.size() >= 3 && !list.get(0).equals(list.get(1))) {
				Bezier line = new Bezier(list.get(0), list.get(1), list.get(2));
				level.add(line);
				list.clear();
			}
			break;
		}
	}
	
	/**
	 * Sets the new edit state.
	 * @param newState the state to set
	 */
	public void setState(State newState) {
		currentState = newState;
		pressedPoint = null;
		draggedPoint = null;
		clickedPoints.clear();
		repaint();
	}
	
	/**
	 * Gets the state.
	 * @return the state
	 */
	public State getState() {
		return currentState;
	}
	
	/**
	 * Gets the toolbar
	 * @return the toolbar
	 */
	public JToolBar getToolBar() {
		return toolbar;
	}
	
	/**
	 * Checks if the specified handle is currently selected
	 * @param handle the handle to check
	 * @return true if handle is selected false otherwise
	 */
	public boolean isHandleSelected(Handle handle) {
		for (Handle h : selection) {
			if (h == handle) {
				return true;
			}
		}
		
		return false;
	}
	
	public boolean isSelected(LevelObject obj) {
		for (Handle h : selection) {
			if (h.getLevelObject() == obj) {
				return true;
			}
		}
		
		return false;		
	}
	
	/**
	 * 
	 * @param p1
	 * @param p2
	 * @return
	 */
	public Rectangle toRect(Point p1, Point p2) {
		return new Rectangle(p1, new Dimension()).union(new Rectangle(p2, new Dimension()));
	}
	
	public void setSelection(ArrayList<LevelObject> objects) {
		selection = level.select(objects);		
		repaint();
	}
	
	/**
	 * Opens the specified level file.
	 * @param file the level file
	 */
	public void openLevel(File file) {
		try {
			currentFile = file;
			FileInputStream fileIn = new FileInputStream(currentFile);
			level = new Level(fileIn);
			saveBtn.setEnabled(true);
		} catch (Exception e) {
			e.printStackTrace();
			currentFile = null;
			saveBtn.setEnabled(false);
			level = new Level();
		}		
		if (groupUI != null) {
			groupUI.levelChanged();
		}
	}
	
	/**
	 * Saves the level the the currently opened file.
	 */
	public void saveLevel() {
		try {
			FileOutputStream file2Out = new FileOutputStream(currentFile);
			level.write(file2Out, bezierChk.isSelected());
			file2Out.close();
		} catch (IOException ioException) {
			ioException.printStackTrace();
		}
	}
	
	/**
	 * Opens the specified image as background.
	 * @param file the image file
	 */
	public void openBackground(File file) {
		try {
			backgroundImage = ImageIO.read(file);
		} catch (IOException e) {
			e.printStackTrace();
			backgroundImage = null;
		}
	}
	
	class ProcessStreamReader implements Runnable {
		
		BufferedInputStream in;
		
		public ProcessStreamReader(InputStream in) {
			this.in = new BufferedInputStream(in);
			Thread thread = new Thread(this);
			thread.setDaemon(true);
			thread.start();
		}
		
		public void run() {
			try {
				int bytesRead = 0;
				byte[] data = new byte[1024];
				while ((bytesRead = in.read(data)) != -1) {
					System.out.write(data, 0, bytesRead);
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}
