package asd.fgh.olduitable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.table.*;
	
public class RowHeader extends JTable {

	private int startDrag = -1; // first row selected (through the row header) that could the beginning of the drag with the mouse
	
	public RowHeader(final JTable table) {
		this(new DefaultTableModel(1,1), table);
	}
	
	public RowHeader(TableModel model, final JTable table) {
		super(model);
		
		// default settings
		getColumnModel().getColumn(0).setPreferredWidth(30);
		setRowHeight(20);
		setGridColor(new Color(0.75F,0.75F,0.75F));
		setCellSelectionEnabled(true);			
		setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
		setDefaultRenderer(getColumnClass(0), new RowHeaderRenderer());
		setPreferredScrollableViewportSize(getPreferredSize()); // adjust viewport to rowheader size
		
		// add mouse listeners to highlight the table's rows according to the selection of the row headers
		addMouseListener(new MouseAdapter() {			
			public void mousePressed(MouseEvent e) {							
				int row = rowAtPoint(e.getPoint());
				if (table.isEnabled() && row > -1) {
					startDrag = row;
					table.setColumnSelectionInterval(table.getColumnCount() - 1,0);
					table.setRowSelectionInterval(row,row);
				}
			}
			public void mouseReleased(MouseEvent e) {
				table.requestFocus(); // return focus to the main table
			}
		});
		
		addMouseMotionListener(new MouseMotionListener() {			
			public void mouseDragged(MouseEvent e) {
				if (table.isEnabled() && startDrag > -1) {
					int row = rowAtPoint(e.getPoint());
					if (row > -1) {
						table.setRowSelectionInterval(startDrag,row);
						table.setColumnSelectionInterval(table.getColumnCount() - 1,0);
						table.scrollRectToVisible(table.getCellRect(row,0,true));
						/*if (e.getX() > getWidth() || e.getX() < 0)
							setRowSelectionInterval(startDrag,row);*/
					}					
				}				
			}			
			public void mouseMoved(MouseEvent e) {}
		});

		
		// highlight the row headers according to the table's selection
		table.getSelectionModel().addListSelectionListener(new ListSelectionListener() {
			public void valueChanged(ListSelectionEvent e) {				
				int firstRow = table.getSelectedRow();
				if (table.getSelectedRowCount() == getRowCount())
					selectAll();				
				else if (firstRow == -1 || table.getSelectedColumnCount() == 0)
					clearSelection(); 
				else {
					int leadRow = table.getSelectionModel().getLeadSelectionIndex();
					int lastRow = firstRow + table.getSelectedRowCount() - 1; // table.getSelectionModel().getMaxSelectionIndex()					
					setColumnSelectionInterval(0,0);
					if (leadRow > firstRow)
						setRowSelectionInterval(firstRow, lastRow);
					else
						setRowSelectionInterval(lastRow, leadRow);
				}
			}
		});
	}
	
	@Override
	public boolean isCellEditable(int row, int column) {
		return false;
	}
}