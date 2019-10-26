package trb.pinball4k.editor;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.border.BevelBorder;

/**
 * Pinball level editor.
 * 
 * @author tombr
 *
 */
public class Editor extends JFrame {
	
	ObjectPropertiesUI propsPnl = new ObjectPropertiesUI();;
	JPanel statusBar = new JPanel();
	
	/**
	 * Creates an editor.
	 *
	 */
	public Editor() {
		super("Pinball Editor");
		setSize(1400, 800);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		
		LevelPanel levelPnl = new LevelPanel(this);
		
		JScrollPane levelScroll = new JScrollPane(levelPnl);
		levelScroll.setMinimumSize(new Dimension(200, 100));

		GroupUI groupsPnl = new GroupUI(levelPnl.level.groups, levelPnl);
		levelPnl.groupUI = groupsPnl;
		
		JSplitPane propsSplit = new JSplitPane(JSplitPane.VERTICAL_SPLIT, propsPnl, groupsPnl);
		propsSplit.setDividerLocation(200);
		
		JSplitPane levelSplit = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT, levelScroll, propsSplit);
		levelSplit.setDividerLocation(1100);

		// setup status bar
		statusBar.setBorder(new BevelBorder(BevelBorder.LOWERED));
		statusBar.add(new JLabel("Hello world"));
		
		getContentPane().setLayout(new BorderLayout());
		getContentPane().add(levelSplit, BorderLayout.CENTER);
		getContentPane().add(levelPnl.getToolBar(), BorderLayout.NORTH);		
		getContentPane().add(statusBar, BorderLayout.SOUTH);		
		
		//setExtendedState(JFrame.MAXIMIZED_BOTH);
		setVisible(true);

		levelPnl.requestFocusInWindow();
	}
	
	public void select(ArrayList<Handle> selection) {
		/*
		ArrayList<ObjectProperties> props = new ArrayList<ObjectProperties>();
		for (Handle handle : selection) {
			if (handle.getLevelObject() != null) {
				LevelObject levelObj = handle.getLevelObject();
				//propsPnl.load(levelObj.properties);
				//break;
				if (props.contains(levelObj) == false) {
					props.add(levelObj.properties);
				}
			}
		}
		propsPnl.load(props);
		*/

		// print selected objects to status bar
		ArrayList<LevelObject> uniqueObjs = new ArrayList<LevelObject>();
		String selectionStr = "";
		for (Handle handle : selection) {
			LevelObject obj = handle.getLevelObject();
			if (obj != null && !uniqueObjs.contains(obj)) {
				uniqueObjs.add(obj);
				selectionStr += "" + obj.toString() + " ";
			}
		}
		selectionStr = selectionStr.trim().equals("") ? "Nothing selected" : selectionStr;
		JLabel lbl = (JLabel) statusBar.getComponent(0);
		lbl.setText(selectionStr);
		

		propsPnl.setSelection(uniqueObjs);
	}

	/**
	 * Main entry point of editor application.
	 * @param args not used
	 */
	public static void main(String args[]) {
		new Editor();
	}
}
