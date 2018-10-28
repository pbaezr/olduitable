package asd.fgh.olduitable;
import java.awt.*;
import javax.swing.*;
import javax.swing.border.LineBorder;

public class CellEditor extends DefaultCellEditor {
	
	public CellEditor(String columnalign) {
		super(new JTextField());		
        JTextField textField = (JTextField) getComponent();
		if (columnalign.equals("left"))
			textField.setHorizontalAlignment(JTextField.LEFT);
		else if (columnalign.equals("center"))
			textField.setHorizontalAlignment(JTextField.CENTER);
		else
			textField.setHorizontalAlignment(JTextField.RIGHT);
		//textField.setBorder(null);
		textField.setBorder(new LineBorder(Color.black));		
	}

    @Override
    public Component getTableCellEditorComponent(JTable table, Object value, boolean isSelected, int row, int column) {
        JTextField textField = (JTextField) super.getTableCellEditorComponent(table, value, isSelected, row, column);
		textField.selectAll();
        return textField;
    }
}
