package asd.fgh.olduitable;
import java.awt.*;
import java.util.List;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.table.*;
		
public class ColHeaderRenderer extends JLabel implements TableCellRenderer {

	private Color bgcolor = new Color(240, 240, 240);
	private Color fgcolor = new Color(0, 0, 0);
	private Color selbgcolor = new Color(204, 204, 204);
	private Color selfgcolor = new Color(0, 0, 0);
	private Color gridcolor = new Color(0.75F, 0.75F, 0.75F);
	//private Color topbordercolor = new Color(66, 133, 244);
	
	private JLabel header = new JLabel();
	private JLabel arrow = new JLabel();
	private int left, bottom; // these are the borders' widths to try to center the texts of the previous jlabels
	
	public ColHeaderRenderer() {
		setOpaque(true);
		setLayout(new BorderLayout());
		arrow.setFont(new Font(arrow.getFont().getName(),0,9));		
		header.setHorizontalAlignment(JLabel.CENTER);
		add(header, BorderLayout.CENTER);
		add(arrow, BorderLayout.EAST);
	}
	
	@Override
	public Component getTableCellRendererComponent(JTable table, Object value, boolean isSelected, boolean hasFocus, int row, int column) {
		
		setBorder(new MatteBorder(0, 0, 1, 1, gridcolor));
		
		// highlight column header according to the table selection
		if (table.isColumnSelected(column)) {
			setBackground(selbgcolor);
			header.setForeground(selfgcolor);
			//setBorder(new CompoundBorder(new MatteBorder(1, 0, 0, 0, topbordercolor),new MatteBorder(0, 0, 1, 1, new Color(0.75F, 0.75F, 0.75F))));
		} else {
			setBackground(bgcolor);
			header.setForeground(fgcolor);
			//setBorder(new MatteBorder(1, 0, 1, 1, new Color(0.75F, 0.75F, 0.75F)));			
		}		
		
		if (value != null)
			header.setText(String.valueOf(value));
		else
			header.setText("");
		
		// put an arrow indicating if the column is sorted
		bottom = 0;
		left = 4;
		arrow.setText("");
		List<? extends RowSorter.SortKey> keys = table.getRowSorter().getSortKeys();
		
        if (!keys.isEmpty() && column == keys.get(0).getColumn()) {
			left = 12;
			arrow.setForeground(selbgcolor.darker());
			if (keys.get(0).getSortOrder() == SortOrder.ASCENDING) {
				bottom = 2;
				arrow.setText("<html>&#9650;");
			}
			else
				arrow.setText("<html>&#9660;");
		}
		
		arrow.setBorder(new EmptyBorder(0, 0, bottom, 4));
		header.setBorder(new EmptyBorder(0, left, 0, 0));

		return this;
	}

	public void setBackgroundColor(Color bg_color) {
		bgcolor = bg_color;
	}

	public void setForegroundColor(Color fg_color) {
		fgcolor = fg_color;
	}	
	
	public void setGridColor(Color grid_color) {
		gridcolor = grid_color;
	}
	
	public void setSelectionBgcolor(Color sel_bgcolor) {
		selbgcolor = sel_bgcolor;
	}
	
	public void setSelectionFgcolor(Color sel_fgcolor) {
		selfgcolor = sel_fgcolor;
	}
	
	/*
	public void setSelectionTopBorderColor(Color sel_bordercolor) {
		topbordercolor = sel_bordercolor;
	}
	*/
}