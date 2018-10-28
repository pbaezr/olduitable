package asd.fgh.olduitable;
import java.awt.*;
import javax.swing.*;
import javax.swing.table.TableCellEditor;

public class LongTextCellEditor extends AbstractCellEditor implements TableCellEditor {	

	private TextAreaComboBox button;
	private String text = " ";

	public LongTextCellEditor(TextAreaComboBox specialButton) {		
		button = specialButton;		
	}

	public Component getTableCellEditorComponent(JTable table, Object value, boolean isSelected, int row, int column) {		

		if (value != null)
			text = String.valueOf(table.getValueAt(row, column));
		else
			text = "";
		
		button.getTextArea().setText(text);
		button.getJLabel().setText(text);

		return button;
	}
	
	public Object getCellEditorValue() {		
		return button.getTextArea().getText();
	}

	public boolean stopCellEditing() {
		/*button.setSelected(false);
		if (!button.getArrowButton().isSelected()) {
			super.cancelCellEditing();
		}*/
		super.cancelCellEditing();
		return super.stopCellEditing();	
    }
}