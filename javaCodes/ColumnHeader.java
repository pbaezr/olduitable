package asd.fgh.olduitable;
import java.awt.Component;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.table.JTableHeader;

public class ColumnHeader extends JTableHeader {
	
	private int startdrag = -1; // first column selected (through the column header) that could the beginning of the drag with the mouse
	private String[] columnToolTips;
	private int currentIndex = -1;	
	
	public ColumnHeader(final JTable table) {
		super(table.getColumnModel());
		
		// initial adjustements
		setDefaultRenderer(new ColHeaderRenderer());		
		setReorderingAllowed(false);

		// select the columns if the headers are right-clicked
		addMouseListener(new MouseAdapter() {
			public void mousePressed(MouseEvent e) {							
				int col = columnAtPoint(e.getPoint());
				if (e.isMetaDown() && table.isEnabled() && col > -1 && getResizingColumn() == null) {
					startdrag = col;
					table.setColumnSelectionInterval(col,col);
					table.setRowSelectionInterval(table.getRowCount() - 1,0);							
				}
			}
		});

		addMouseMotionListener(new MouseMotionListener() {			
			public void mouseDragged(MouseEvent e) {
				if (e.isMetaDown() && table.isEnabled() && startdrag > -1) {								
					int col = columnAtPoint(e.getPoint());
					if (col > -1 && getResizingColumn() == null) {
						table.setColumnSelectionInterval(startdrag,col);
						table.scrollRectToVisible(table.getCellRect(0,col,true));								
					}
				}
			}
			
			// show a custom tooltip for column		
			public void mouseMoved(MouseEvent e) {
				int colIndex = table.columnAtPoint(e.getPoint());
				if (columnToolTips != null) {					
					if (colIndex > - 1 && colIndex != currentIndex) {
						currentIndex = colIndex;
						if (!columnToolTips[colIndex].isEmpty())
							setToolTipText(columnToolTips[colIndex]);
						else
							setToolTipText(null);
					}
				}
				else
					setToolTipText(null);				
			}						
		});		
	}

	@Override
	public void columnSelectionChanged(ListSelectionEvent e) {
		repaint();
	}
	
	public void setColumnToolTips(String[] tooltips) {
		columnToolTips = tooltips;
	}
}
