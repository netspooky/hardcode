package trb.pinball4k.editor;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListCellRenderer;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

/**
 * A panel where the user can edit the level object properties.
 * @author tombr
 */
public class GroupUI extends JPanel implements ActionListener, ListSelectionListener {

	private GroupList groups;
	private LevelPanel levelPanel;
	private JList myList;
	private JButton upBtn = new JButton("Up");
	private JButton downBtn = new JButton("Down");
	private JButton deleteBtn = new JButton("Delete");
	
	
	public GroupUI(GroupList groups, LevelPanel levelPanel) {
		this.groups = groups;
		this.levelPanel = levelPanel;
		
		myList = new JList(groups);
		myList.setCellRenderer(new GroupsCellRenderer());
		myList.addListSelectionListener(this);
		
		deleteBtn.addActionListener(this);
		upBtn.addActionListener(this);
		downBtn.addActionListener(this);
		
		JPanel buttonPnl = new JPanel();
		buttonPnl.add(upBtn);
		buttonPnl.add(downBtn);
		buttonPnl.add(deleteBtn);
		
		setLayout(new BorderLayout());
		add(new JLabel("Groups:"), BorderLayout.NORTH);
		add(new JScrollPane(myList), BorderLayout.CENTER);
		add(buttonPnl, BorderLayout.SOUTH);
	}
	
	public void levelChanged() {
		this.groups = levelPanel.level.groups;
		myList.setModel(groups);
	}
	
	public void actionPerformed(ActionEvent e) {
		if (e.getSource() == deleteBtn) {
			groups.remove((ArrayList<LevelObject>) myList.getSelectedValue());
		} else if (e.getSource() == upBtn) {
			int selectedIdx = myList.getSelectedIndex();
			if (selectedIdx > 0) {
				groups.move(myList.getSelectedIndex(), true);
				myList.setSelectedIndex(selectedIdx - 1);
			}
		} else if (e.getSource() == downBtn) {
			int selectedIdx = myList.getSelectedIndex();
			if (selectedIdx >= 0 && selectedIdx < groups.getSize() - 1) {
				groups.move(myList.getSelectedIndex(), false);
				myList.setSelectedIndex(selectedIdx + 1);
			}
		}
	}

	class GroupsCellRenderer extends JLabel implements ListCellRenderer {
		public Component getListCellRendererComponent(
	    	       JList list,              // the list
	    	       Object value,            // value to display
	    	       int index,               // cell index
	    	       boolean isSelected,      // is the cell selected
	    	       boolean cellHasFocus)    // does the cell have focus
		 {
		     String s = value.toString();
		     setText(s);
		     
		     if (isSelected) {
		         setBackground(list.getSelectionBackground());
		         setForeground(list.getSelectionForeground());
		     } else {
		         setBackground(list.getBackground());
		         setForeground(list.getForeground());
		     }
		     setEnabled(list.isEnabled());
		     setFont(list.getFont());
		     setOpaque(true);
		     return this;
		 }	
	}

	/**
	 * Implements ListSelectionListener.
	 */
	public void valueChanged(ListSelectionEvent e) {
		if (myList.getSelectedValue() != null) {
			ArrayList<LevelObject> group = (ArrayList<LevelObject>) myList.getSelectedValue();
			levelPanel.setSelection(group);
		}
		
	}
}
