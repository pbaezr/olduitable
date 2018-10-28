package asd.fgh.olduitable;
import java.awt.*;
import javax.swing.*;
import javax.swing.table.TableCellEditor;

public class ColorCellEditor extends AbstractCellEditor implements TableCellEditor {

	private ColorComboBox button;

	public ColorCellEditor(ColorComboBox specialButton) {		
		button = specialButton;		
	}

	public Component getTableCellEditorComponent(JTable table, Object value, boolean isSelected, int row, int column) {

		try {
			button.getJLabel().setBackground((Color)table.getValueAt(row, column));
		}
		catch (Exception e) {
			button.getJLabel().setBackground(Color.white);
		}
		
		return button;
	}
	
	public Object getCellEditorValue() {
		return button.getJLabel().getBackground();
	}
	
	public boolean stopCellEditing() {
		button.setSelected(false);
		super.cancelCellEditing(); // the editor's behavior was implemented in Matlab to increase the performace in large tables (in which 'stopCellEditng' and 'getCellEditorValue' functions may last seconds!!)
		return super.stopCellEditing();	
    }
}
