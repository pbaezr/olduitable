package asd.fgh.olduitable;
import java.awt.*;
import java.util.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;

public class CheckBoxRenderer extends JCheckBox implements TableCellRenderer {

	private Color selbgcolor = new Color(236, 243, 255);
	private Color selbordercolor = new Color(66, 133, 244);
	
	private Color[] rowcolor = {Color.white, new Color(240,240,240)};
	private Color[] colcolor = {Color.white, new Color(240,240,240)};
	private boolean rowstriping = false, colstriping = false;
	private double id_rowcolor, id_colcolor;
	
	private Color cellcolor;
	private Map<Vector,Color> cellBgInfo = new HashMap<>();

	public CheckBoxRenderer() {
		setHorizontalAlignment(CENTER);
		setBorderPainted(true);		
	}
	
	public CheckBoxRenderer(boolean row_striping, boolean col_striping, float[][] row_color, float[][] col_color, Color selbg_color, Color selborder_color) {
		setHorizontalAlignment(CENTER);
		setBorderPainted(true);
		rowstriping = row_striping;
		colstriping = col_striping;
		rowcolor = triplet2color(row_color);		
		colcolor = triplet2color(col_color);
		selbgcolor = selbg_color;
		selbordercolor = selborder_color;
	}

	public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {

		// set the background		
		setBackground(table.getBackground()); // default color		
		
		if (rowstriping) { // rowstriping has priority
			id_rowcolor = (double)row - rowcolor.length * Math.floor(row / rowcolor.length);
			setBackground(rowcolor[(int)id_rowcolor]);			
		}
		else if (colstriping) {
			id_colcolor = (double)column - colcolor.length * Math.floor(column / colcolor.length);
			setBackground(colcolor[(int)id_colcolor]);
		}

		// set the background property for a specific cell through the "setCellBg" method (idea taken from Yair Altman's "ColoredFieldCellRenderer" class) 
		int colored_row = -1, colored_col = -1;		
		cellcolor = cellBgInfo.get(new Vector(Arrays.asList(row, column)));
		if (cellcolor != null) {
			setBackground(cellcolor);
			colored_row = row;
			colored_col = column;
		}

		setBorder(new EmptyBorder(1, 1, 1, 1));
		
		// highlight the selection as in matlab old uitable (with diferent border and background color, however)
		if (isSelected) {
			// if table is using 'rowstriping' or 'colstriping' selection only will appear with a outer border			
			if (!rowstriping && !colstriping && colored_row == -1 && colored_col == -1) {
				if (row != table.getSelectionModel().getLeadSelectionIndex() || column != table.getColumnModel().getSelectionModel().getLeadSelectionIndex()) // cell selected isn't the lead (lead selection will be white)
					setBackground(selbgcolor);
			}
			/*
			else
				setBackground(getBackground().darker());*/

			// get the current selection
			int r0 = table.getSelectedRow(); // min row index from selection 
			int rf = r0 + table.getSelectedRowCount() - 1; // max row index
			int c0 = table.getSelectedColumn(); // min col index 
			int cf = c0 + table.getSelectedColumnCount() - 1; // max col index
			
			CellRenderer.setCellBorders(this, selbordercolor, row, column, r0, rf, c0, cf);
			if (r0 == rf && c0 == cf) setBorder(new EmptyBorder(1, 1, 1, 1));
		}
		
		// define the status of the check box (if the assigned value is not a boolean, show an unchecked box)
		if (value == null) value = false;	
		boolean flag = new Boolean(value.toString());	
		setSelected(flag);

		return this;
	}

	public void setSelectionBgColor(Color color) {
		selbgcolor = color;
	}
	
	public void setSelectionBorderColor(Color color) {
		selbordercolor = color;
	}
	
	public void setRowStriping(boolean value) {
		rowstriping = value;
	}
	
	public void setColumnStriping(boolean value) {
		colstriping = value;
	}
	
	public void setRowColor(float[][] colors) {
		rowstriping = true;
		rowcolor = triplet2color(colors);
	}
	
	public void setColumnColor(float[][] colors) {
		colstriping = true;
		colcolor = triplet2color(colors);
	}
	
	public void setCellBg(Color color, int row, int column) {		
		cellBgInfo.put(new Vector(Arrays.asList(row, column)), color);
	}
	
	public void resetCellBg() {
		cellBgInfo.clear();
	}
	
	private Color[] triplet2color(float[][] colors)	{
		Color[] colorArray = new Color[colors.length];
		for(int i = 0; i < colors.length; i++){
			colorArray[i] = new Color(colors[i][0], colors[i][1], colors[i][2]);
		}
		return colorArray;
	}	
}