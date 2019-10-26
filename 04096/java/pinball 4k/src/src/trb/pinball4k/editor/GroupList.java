package trb.pinball4k.editor;

import java.awt.Component;
import java.util.ArrayList;

import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;
import javax.swing.ListModel;
import javax.swing.event.ListDataEvent;
import javax.swing.event.ListDataListener;

public class GroupList implements ListModel {
	private ArrayList<ArrayList<LevelObject>> groups = new ArrayList<ArrayList<LevelObject>>();
	
	private ArrayList<ListDataListener> listeners = new ArrayList<ListDataListener>();

	public void add(ArrayList<LevelObject> obj) {
		groups.add(obj);
		
		for (ListDataListener l : listeners) {
			l.intervalAdded(new ListDataEvent(this, ListDataEvent.INTERVAL_ADDED, 0, groups.size()));
		}
	}
	
	public void remove(LevelObject obj) {
		for (ArrayList<LevelObject> group : groups) {
			group.remove(obj);
		}

		for (ListDataListener l : listeners) {
			l.contentsChanged(new ListDataEvent(this, ListDataEvent.CONTENTS_CHANGED, 0, groups.size()));
		}
	}
	
	/**
	 * Removes the specified group.
	 * @param group the group to remove
	 */
	public void remove(ArrayList<LevelObject> group) {
		groups.remove(group);

		for (ListDataListener l : listeners) {
			l.intervalRemoved(new ListDataEvent(this, ListDataEvent.INTERVAL_REMOVED, 0, groups.size()));
		}
	}
	
	public void move(int idx, boolean up) {
		System.out.println(getClass() + " move(" + idx +", " + (up ? "up" : "down"));
		if (up) {
			if (idx < 1 || idx >= groups.size()) {
				return;
			}
		} else {
			if (idx < 0 || idx >= groups.size() - 1) {
				return;
			}
		}
		ArrayList<LevelObject> obj = groups.remove(idx);
		groups.add((up ? idx - 1 : idx + 1), obj);
		
		for (ListDataListener l : listeners) {
			l.contentsChanged(new ListDataEvent(this, ListDataEvent.CONTENTS_CHANGED, 0, groups.size()));
		}
	}
	
	/*
	 *  (non-Javadoc)
	 * @see javax.swing.ListModel#getSize()
	 */
	public int getSize() {
		return groups.size();
	}

	/*
	 *  (non-Javadoc)
	 * @see javax.swing.ListModel#addListDataListener(javax.swing.event.ListDataListener)
	 */
	public void addListDataListener(ListDataListener l) {
		listeners.add(l);
	}

	/*
	 *  (non-Javadoc)
	 * @see javax.swing.ListModel#getElementAt(int)
	 */
	public Object getElementAt(int index) {
		return groups.get(index);
	}

	/*
	 *  (non-Javadoc)
	 * @see javax.swing.ListModel#removeListDataListener(javax.swing.event.ListDataListener)
	 */
	public void removeListDataListener(ListDataListener l) {
		listeners.remove(l);
	}

}
