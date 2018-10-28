package asd.fgh.olduitable;
import java.util.Arrays;
import javax.swing.table.*;

public class EditableModel extends DefaultTableModel implements TableModel {
  
    boolean[] columnEditable = new boolean[this.getColumnCount()];	
  
	public EditableModel(Object[][] data, Object[] columnNames) {
		super(data, columnNames);
		Arrays.fill(columnEditable, false);
	}
  
	public boolean isCellEditable(int row, int column) {
		return columnEditable[column];
	}
	
	public boolean[] getColumnEditable() {
		return columnEditable;
	}	
		
	public boolean getColumnEditable(int column) {
		return columnEditable[column];
	}
	
	//adjust 'columnEditable' to a specific number of columns (this must be used before any method that changes the column count to avoid the 'java.lang.ArrayIndexOutOfBounds' exception)
	public void resizeEditableArray(int columnCount) {
		if (columnEditable.length < columnCount) {
			boolean[] aux = Arrays.copyOf(columnEditable, columnCount);			
			Arrays.fill(aux, columnEditable.length, columnCount - 1, false) ;
			columnEditable = aux;		 
		}
		else if (columnEditable.length > columnCount) {
			boolean[] aux = Arrays.copyOf(columnEditable, columnCount);
			columnEditable = aux;
		}
	}

	public void setEditable(boolean editable) {
		Arrays.fill(columnEditable, editable);
	}	
	
	public void setColumnEditable(int column, boolean editable) {
		columnEditable[column] = editable;
	}
}