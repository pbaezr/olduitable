package asd.fgh.olduitable;
import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;

public class RowHeaderRenderer extends DefaultTableCellRenderer implements TableCellRenderer {
	
	private Color bgcolor = new Color(240, 240, 240);
	private Color fgcolor = Color.black;
	private Color selbgcolor = new Color(204, 204, 204);
	private Color selfgcolor = Color.black;
	//private Color leftbordercolor = new Color(66, 133, 244);	
	
	public RowHeaderRenderer() {
		setHorizontalAlignment(CENTER);		
	}
	
	public RowHeaderRenderer(Color bg_color) {
		setHorizontalAlignment(CENTER);		
		bgcolor = bg_color;
	}

	public RowHeaderRenderer(Color bg_color, Color fg_color) {
		setHorizontalAlignment(CENTER);
		bgcolor = bg_color;
		fgcolor = fg_color;
	}
	
	public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
		
		super.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column);		
		
		setBorder(noFocusBorder);		
		
		// highlight the row headers according to the selection
		if (isSelected) {
			setBackground(selbgcolor);
			setForeground(selfgcolor);
			//setBorder(new CompoundBorder(new MatteBorder(0, 1, 0, 0, leftbordercolor),new EmptyBorder(1, 0, 1, 1)));
		}
		else {
			setBackground(bgcolor);
			setForeground(fgcolor);
		}

		return this;
	}
	
	public void setBackgroundColor(Color bg_color) {
		bgcolor = bg_color;
	}
	
	public void setForegroundColor(Color fg_color) {
		fgcolor = fg_color;
	}	
	
	public void setSelectionBgcolor(Color sel_bgcolor) {
		selbgcolor = sel_bgcolor;
	}
	
	public void setSelectionFgcolor(Color sel_fgcolor) {
		selfgcolor = sel_fgcolor;
	}
	
	/*
	public void setSelectionLeftBorderColor(Color sel_bordercolor) {
		leftbordercolor = sel_bordercolor;
	}
	*/
}