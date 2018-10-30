package asd.fgh.olduitable;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import javax.swing.table.TableCellRenderer;
import javax.swing.SwingUtilities;
	
public class Table extends JTable {
	
	public Table(EditableModel model) {
		super(model);
		
		// initial adjustements
		setRowHeight(20);
		setGridColor(new Color(0.85F,0.85F,0.85F));
		setAutoResizeMode(JTable.AUTO_RESIZE_OFF);
		setCellSelectionEnabled(true);          
		setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
		setDefaultRenderer(getColumnClass(0), new CellRenderer());
		setDefaultEditor(getColumnClass(0), new CellEditor("center"));
		putClientProperty("terminateEditOnFocusLost", true); // Boolean.TRUE // it only works if the current focus owner is a child of the table's top level ancestor

		// this is to ensure that the popup editor appears immediately after the cell is clicked
		ListSelectionListener startEditing = new ListSelectionListener() {
			public void valueChanged(ListSelectionEvent e) {
				if (isEditing() && !e.getValueIsAdjusting()) {
					Component editor = getEditorComponent();
					if (editor instanceof JComboBox)
						((JComboBox)editor).showPopup();
					else if (editor instanceof ColorComboBox) {
						((ColorComboBox)editor).showPopup();
					}
					else if (editor instanceof TextAreaComboBox) {
						((TextAreaComboBox)editor).showPopup();
					}
				}				
			}
		};

		getSelectionModel().addListSelectionListener(startEditing);
		getColumnModel().getSelectionModel().addListSelectionListener(startEditing);

	}
	
	public void stopEditingWhenOtherComponentIsClicked() {
		MouseAdapter stopEditing = new MouseAdapter() {
			public void mousePressed(MouseEvent e) {
				Component editor = getEditorComponent();
				if (editor != null) {
					if (editor instanceof TextAreaComboBox) ((TextAreaComboBox)editor).setSelected(false);					
					getCellEditor().stopCellEditing();
				}
			}
		};
		
		JScrollPane scrollpane = (JScrollPane)getParent().getParent();
		JScrollBar hscrollbar = scrollpane.getHorizontalScrollBar();
		JScrollBar vscrollbar = scrollpane.getVerticalScrollBar();		
		
		getTableHeader().addMouseListener(stopEditing); // click on the column headers
		scrollpane.addMouseListener(stopEditing); // click on the empty corners
		getParent().addMouseListener(stopEditing); // click on the empty panel area
		hscrollbar.addMouseListener(stopEditing); // click on the scroll bars
		vscrollbar.addMouseListener(stopEditing);
		hscrollbar.getComponent(0).addMouseListener(stopEditing); // click on the arrows
		hscrollbar.getComponent(1).addMouseListener(stopEditing);
		vscrollbar.getComponent(0).addMouseListener(stopEditing);
		vscrollbar.getComponent(1).addMouseListener(stopEditing);
	}
	
	public int getOptimalColumnWidth(int column) {
		int width = 0;
		TableCellRenderer renderer = getColumnModel().getColumn(column).getCellRenderer();
		FontMetrics fontMetrics = getFontMetrics(getFont());
		for(int row = 0; row < getRowCount(); row++) {
			CellRenderer cellRenderer = (CellRenderer)prepareRenderer(renderer, row, column);
			width = Math.max(width, SwingUtilities.computeStringWidth(fontMetrics, cellRenderer.getText()));
		}
		return width;
	}
}
