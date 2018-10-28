package asd.fgh.olduitable;
import java.util.*;
import javax.swing.*;
import javax.swing.table.*;

public class Sorter extends TableRowSorter<TableModel>{

	private Comparator comparator = new Comparator() {
        public int compare(Object o1, Object o2) {
			if (o1 instanceof Double && o2 instanceof Double)
				return ((Double)o1).compareTo((Double)o2);
			else
				return o1.toString().compareTo(o2.toString());
			}
    };
	
	private List<RowSorter.SortKey> sortKeys = new ArrayList<>(1);
	
	public Sorter(TableModel model) {
		super(model);
	}

	public boolean isSortable(int column) {
		return false;
	}
	
	public void setComparators() {	
		for (int column = 0; column < this.getModel().getColumnCount(); column++) {
			this.setComparator(column, comparator);
		}
	}
	
	public void setSortKeys(int column, String sortOrder) {
		sortKeys.clear();
		if (sortOrder.equalsIgnoreCase("ascend"))
			sortKeys.add(new RowSorter.SortKey(column, SortOrder.ASCENDING));
		else
			sortKeys.add(new RowSorter.SortKey(column, SortOrder.DESCENDING));
		super.setSortKeys(sortKeys);
	}
}


