package asd.fgh.olduitable;
import java.awt.*;
import java.lang.reflect.Field;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;

public class ColorCellRenderer extends DefaultTableCellRenderer implements TableCellRenderer {
	
	private Color jcolor;
	private CompoundBorder border = new CompoundBorder(new LineBorder(Color.white, 3), new LineBorder(new Color(51, 51, 51)));

	public ColorCellRenderer() {}	

	public Component getTableCellRendererComponent(JTable table, Object color, boolean isSelected, boolean hasFocus, int row, int column) {
		
		JComponent cell = (JComponent) super.getTableCellRendererComponent(table, color, isSelected, hasFocus, row, column);
		
		try {
			if (color == null)
				jcolor = Color.white;
			else if (color instanceof Color)
				jcolor = (Color) color;			
			else /*if (color instanceof String)*/ {
				try {
					String colorName = String.valueOf(color);				
					if (colorName.equalsIgnoreCase("r"))
						colorName = "red";
					else if (colorName.equalsIgnoreCase("g"))
						colorName = "green";
					else if (colorName.equalsIgnoreCase("b"))
						colorName = "blue";
					else if (colorName.equalsIgnoreCase("y"))
						colorName = "yellow";
					else if (colorName.equalsIgnoreCase("m"))
						colorName = "magenta";
					else if (colorName.equalsIgnoreCase("c"))
						colorName = "cyan";
					else if (colorName.equalsIgnoreCase("k"))
						colorName = "black";
					Field field = Color.class.getField(colorName);
					jcolor = (Color) field.get(null);
					table.setValueAt(jcolor, row, column);
				}
				catch (Exception e) {
					jcolor = Color.white;
				}				
			}		
		}
		catch (Exception e2) {
			jcolor = Color.white;
		}
		
		setText("");
		cell.setBackground(jcolor);
		cell.setBorder(border);		

		return cell;
	}
}