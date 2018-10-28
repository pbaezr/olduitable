package asd.fgh.olduitable;
import java.awt.*;
import java.util.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;

public class CellRenderer extends DefaultTableCellRenderer implements TableCellRenderer {

	private Color selbgcolor = new Color(236, 243, 255);
	private Color selfgcolor = new Color(0, 0, 0);
	private Color selbordercolor = new Color(66, 133, 244);
	
	private Color[] rowcolor = {Color.white, new Color(240,240,240)};
	private Color[] colcolor = {Color.white, new Color(240,240,240)};	
	private boolean rowstriping = false, colstriping = false;	
	private double id_rowcolor, id_colcolor;
	
	private Color cellcolor, cellfg;
	private Map<Vector,Color> cellBgInfo = new HashMap<>();
	private Map<Vector,Color> cellFgInfo = new HashMap<>();
	
	private String colformat = "";
	
	public CellRenderer() {
		setHorizontalAlignment(CENTER);		
	}
	
	public CellRenderer(boolean row_striping, boolean col_striping, float[][] row_color, float[][] col_color, Color selbg_color, Color selborder_color, Color selfg_color) {
		rowstriping = row_striping;
		colstriping = col_striping;
		rowcolor = triplet2color(row_color);		
		colcolor = triplet2color(col_color);
		selbgcolor = selbg_color;
		selbordercolor = selborder_color;
		selfgcolor = selfg_color;		
	}

	public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
		
		JComponent cell = (JComponent) super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);
		JLabel text = (JLabel) cell;
		
		// set the format
		if (value != null && !value.toString().isEmpty() && !colformat.isEmpty()) {
			try {
				text.setText(String.format(colformat, value));
			}
			catch (java.util.IllegalFormatConversionException e) {
				try {
					text.setText(String.format(colformat, Double.valueOf(value.toString())));					
				}
				catch (Exception e2) { //java.lang.NumberFormatException
				}
			}
			catch (Exception e3) { // incompatible format
				//System.err.println("Exception in row = " + (row + 1) + ", column = " + (column + 1)); // matlab indices				
				//throw e;
			}			
		}
		//else if (value instanceof Double)
			//text.setText(String.format("%g", value)); // "%g" doesn't work like in C or Matlab
		
		// set the background		
		cell.setBackground(table.getBackground()); // default colors
		cell.setForeground(table.getForeground());		
		
		if (rowstriping) { // rowstriping has priority
			id_rowcolor = (double)row - rowcolor.length * Math.floor(row / rowcolor.length);
			cell.setBackground(rowcolor[(int)id_rowcolor]);			
		}
		else if (colstriping) {
			id_colcolor = (double)column - colcolor.length * Math.floor(column / colcolor.length);
			cell.setBackground(colcolor[(int)id_colcolor]);
		}

		// set the background and foreground properties for a specific cell through the "setCellBg" and "setCellFg" methods (idea taken from Yair Altman's "ColoredFieldCellRenderer" class) 
		int colored_row = -1, colored_col = -1;		
		cellcolor = cellBgInfo.get(new Vector(Arrays.asList(row,column)));
		if (cellcolor != null) {
			cell.setBackground(cellcolor);
			colored_row = row;
			colored_col = column;
		}
		
		cellfg = cellFgInfo.get(new Vector(Arrays.asList(row,column)));
		if (cellfg != null) {			
			cell.setForeground(cellfg);
			colored_row = row;
			colored_col = column;
		}
		

		// highlight the selection as in matlab's old uitable (with diferent border and background color, however)
		if (isSelected) {
			// if table is using 'rowstriping' or 'colstriping', selection only will appear with a outer border			
			if (!rowstriping && !colstriping && colored_row == -1 && colored_col == -1) {
				if (row != table.getSelectionModel().getLeadSelectionIndex() || column != table.getColumnModel().getSelectionModel().getLeadSelectionIndex()) { // cell selected isn't the lead (lead selection will be white)
					cell.setBackground(selbgcolor);
					cell.setForeground(selfgcolor);
				}
			}
			/*
			else
				cell.setBackground(cell.getBackground().darker());*/			
			
			// get the current selection
			int r0 = table.getSelectedRow(); // min row index from selection
			int rf = r0 + table.getSelectedRowCount() - 1; // max row index
			int c0 = table.getSelectedColumn(); // min col index
			int cf = c0 + table.getSelectedColumnCount() - 1; // max col index
			
			this.setCellBorders(cell, selbordercolor, row, column, r0, rf, c0, cf);		
		}

		return cell;
	}		

	public void setSelectionBgColor(Color color) {
		selbgcolor = color;
	}
	
	public void setSelectionFgColor(Color color) {
		selfgcolor = color;
	}
	
	public void setSelectionBorderColor(Color color) {
		selbordercolor = color;
	}
	
	public void setColumnFormat(String value) {
		colformat = value;
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
	
	public void setHorizontalAlignment(String align) {		
		if (align.equalsIgnoreCase("left"))
			setHorizontalAlignment(LEFT);
		else if (align.equalsIgnoreCase("center"))
			setHorizontalAlignment(CENTER);
		else
			setHorizontalAlignment(RIGHT);
	}
	
	public void setCellBg(Color color, int row, int column) {		
		cellBgInfo.put(new Vector(Arrays.asList(row, column)), color);
	}
	
	public void setCellFg(Color color, int row, int column) {
		cellFgInfo.put(new Vector(Arrays.asList(row, column)), color);
	}
	
	public void resetCellBg() {
		cellBgInfo.clear();
	}
	
	public void resetCellFg() {
		cellBgInfo.clear();
	}

	private Color[] triplet2color(float[][] colors)	{
		Color[] colorArray = new Color[colors.length];
		for(int i = 0; i < colors.length; i++){
			colorArray[i] = new Color(colors[i][0], colors[i][1], colors[i][2]);
		}
		return colorArray;
	}
	
	// this function is static only to recycle code and use it in the "CheckBoxRenderer" class 
	public static void setCellBorders(JComponent cell, Color borderColor, int row, int column, int r0, int rf, int c0, int cf) {
		if (r0 == rf && c0 == cf) // one cell selection
			cell.setBorder(new LineBorder(borderColor));
		else if (r0 < rf && c0 == cf) { // vertical selection
			if (row == r0)			
				cell.setBorder(new CompoundBorder(new MatteBorder(1, 1, 0, 1, borderColor),new EmptyBorder(0, 0, 1, 0)));
			else if (row < rf)
				cell.setBorder(new CompoundBorder(new MatteBorder(0, 1, 0, 1, borderColor),new EmptyBorder(1,0,1,0)));
			else // if (row == rf)
				cell.setBorder(new CompoundBorder(new MatteBorder(0, 1, 1, 1, borderColor),new EmptyBorder(1, 0,0,0)));
		}
		else if (r0 == rf && c0 < cf) { // horizontal selection
			if (column == c0)
				cell.setBorder(new CompoundBorder(new MatteBorder(1, 1, 1, 0, borderColor),new EmptyBorder(0, 0, 0, 1)));
			else if (column < cf)
				cell.setBorder(new CompoundBorder(new MatteBorder(1, 0, 1, 0, borderColor),new EmptyBorder(0, 1, 0, 1)));
			else // if (column == cf)
				cell.setBorder(new CompoundBorder(new MatteBorder(1, 0, 1, 1, borderColor),new EmptyBorder(0, 1, 0, 0)));			
		}
		else if (r0 < rf && c0 < cf) { // 2D selection
			if (column == c0) {
				if (row == r0)			
					cell.setBorder(new CompoundBorder(new MatteBorder(1, 1, 0, 0, borderColor),new EmptyBorder(0, 0, 1, 1)));
				else if (row < rf)
					cell.setBorder(new CompoundBorder(new MatteBorder(0, 1, 0, 0, borderColor),new EmptyBorder(1, 0, 1, 1)));
				else // if (row == rf)
					cell.setBorder(new CompoundBorder(new MatteBorder(0, 1, 1, 0, borderColor),new EmptyBorder(1, 0, 0, 1)));
			}
			else if (column < cf) {
				if (row == r0)			
					cell.setBorder(new CompoundBorder(new MatteBorder(1, 0, 0, 0, borderColor),new EmptyBorder(0, 1, 1, 1)));
				else if (row == rf)
					cell.setBorder(new CompoundBorder(new MatteBorder(0, 0, 1, 0, borderColor),new EmptyBorder(1, 1, 0, 1)));
			}			
			else /* if (column == cf)*/ {
				if (row == r0)			
					cell.setBorder(new CompoundBorder(new MatteBorder(1, 0, 0, 1, borderColor),new EmptyBorder(0, 1, 1, 0)));
				else if (row < rf)
					cell.setBorder(new CompoundBorder(new MatteBorder(0, 0, 0, 1, borderColor),new EmptyBorder(1, 1, 1, 0)));
				else // if (row == rf)
					cell.setBorder(new CompoundBorder(new MatteBorder(0, 0, 1, 1, borderColor),new EmptyBorder(1, 1, 0, 0)));			
			}		
		}
	}
}