# olduitable

**olduitable** is a Matlab class that implements a Java-based table. It includes many of the properties of the Matlab uitable, with an interface similar to its undocumented version (v0). Besides this class incorporates new properties such as `ColumnAlign`, `ColumnColor`, `ColumnToolTip`, `GridColor`, `HeaderBackground`, `SelectionBackground`, among others, and methods to insert or delete rows and columns and paste blocks of cells as a typical spreadsheet.

<p align="center"><img src="https://la.mathworks.com/matlabcentral/mlc-downloads/downloads/b37b5fbe-a3df-4bc4-8773-9616320a12aa/e7315e73-aac1-4402-8210-48ae01b11e48/images/screenshot.png" width="50%" alt="examples"></p>

## First steps
Once downloaded, we must copy the `@olduitable` folder to any folder that is in the Matlab search path (type `userpath` in the command window to see the first folder in the path) or use `addpath` to add this folder.

## Usage
### Creation of the table

```
t = olduitable;
t = olduitable('PropertyName1',value1,'PropertyName2',value2,...);
t = olduitable(parent,'PropertyName1',value1,'PropertyName2',value2,...);
```

As usual in Matlab, the property name can be in lowercase during this stage.

### Modification of properties

```
t.PropertyName = value; % prefer this form
set('PropertyName1',value1,'PropertyName2',value2,...);
```

The property name can be in lowercase only for the second form.

### Methods

```
t.methodName(arg1,arg2,...);
methodName(t,arg1,arg2,...);
```

## List of properties

<table style="width:120%">

<tr><th>Property<th>Valid inputs<th>Examples<th>Notes

<tr>
  <td><b>ButtonDownFcn</b><br>Function that executes when a mouse button is pressed in the table
  <td>&#9656;'' (default)<br>&#9656;function handle<br>&#9656;cell array<br>&#9656; char vector
  <td>t.ButtonDownFcn = @function1;<br><br>t.ButtonDownFcn = @(~,e)disp(['a ',...<br>e.Button,' click was made on ',e.ClickedArea]);<br><br>t.ButtonDownFcn = {@function2,...<br>extraArg1,extraArg2};<br><br>t.ButtonDownFcn = 'disp(''a mouse button was pressed'')';
  <td>The function handle receives 2 arguments by default: the Source and the EventData. The first is the olduitable object involved and the last one is a structure with the fields ClickedArea, Button, ClickCount and ClickPosition.

<tr>
  <td><b>CellEditCallback</b><br>Function that executes when the contents of table change
  <td>&#9656;'' (default)<br>&#9656;function handle<br>&#9656;cell array<br>&#9656;char vector
  <td>t = olduitable('ColumnEditable',true,...<br>'Data',magic(5),...<br>'CellEditCallback', @(~,e)disp(['the cell (',...<br>num2str([e.RowIndices(1) e.ColumnIndices(1)]),...<br>') was the first one edited']));
  <td>The EventData structure contains the fields: RowIndices, ColumnIndices, PreviousData, EditData and EventName.

<tr>
  <td><b>CellSelectionCallback</b><br>Function that executes when the table selection changes
  <td>&#9656;'' (default)<br>&#9656;function handle<br>&#9656;cell array
  <td>
  <td>The EventData structure contains the fields: RowIndices and ColumnIndices.

<tr>
  <td><b>ColumnAlign</b><br>Indicates the alignment of the columns.
  <td>&#9656;'center' (default), 'letf' or 'right'<br>&#9656;1-by-n or n-by-1 cell array of character vectors with any of those values for each column.
  <td>t = olduitable('Data',magic(2),...<br>'ColumnAlign',{'left','right'});
  <td>If the length of the ColumnAlign array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with the default value.<br><br>
This property won't have effect for the columns with 'color' or 'logical' formats.

<tr><td><b>ColumnColor</b><br>Indicates the pattern for the columns' background colors.
  <td>&#9656;[1 1 1; 0.94 0.94 0.94] (default)<br>&#9656;m-by-3 matrix of RGB triplets
  <td>t = olduitable('data', magic(10),...<br>'ColumnStriping','on',...<br>'ColumnColor',[1 0 0; 0 1 0; 0 0 1]);
  <td>This property will take effect as long as the ColumnStriping property is set to 'on' and the RowStriping property is 'off'.<br><br>
See also the setCellBg method.

<tr><td><b>ColumnEditable</b><br>Indicates the ability to edit the column cells
  <td>&#9656;logical scalar or array (false by default)<br>&#9656;numeric scalar or array with binary values
  <td>t = olduitable('data',magic(2),...<br>'ColumnEditable',[true false]);<br><br>t2 = olduitable(figure,'Data',magic(2),...<br>'ColumnEditable',[1 0]);
  <td>If the length of the ColumnEditable array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with the default value (or repeating the assigned unique value).

<tr>
  <td><b>ColumnFormat</b><br>Indicates the column displays
  <td>&#9656;empty char '' (default)<br>&#9656;char vectors as 'bank', 'char', 'color', 'logical', 'longchar' or 'popup'<br>&#9656;char vector with a valid formatting operator (see <a href="https://www.mathworks.com/help/matlab/ref/sprintf.html?s_tid=doc_ta#btf_bfy-1_sep_shared-formatSpec">Matlab Documentation</a>)
<br>&#9656;1-by-n or n-by-1 cell array of char vectors with any of those values for each column.
    <td>data = {'red','dog',true,pi,repmat('a',1,100);<br>'blue','cat',false,25,repmat('b',1,100)};<br>t = olduitable('ColumnEditable',true,...<br>'ColumnFormat',{'color','popup','logical','%.2f','longchar'},...<br>'Data',data);<br><br>t2 = olduitable(figure,'ColumnEditable',true,...<br>'ColumnFormat','color',...<br>'Data',{java.awt.Color(0.7,0.4,0.9),'m'});
    <td>If the ColumnEditable property for the columns with formats like 'color', 'logical', 'longchar' or 'popup' is false (or 0), user won't be able to interact with these columns.<br><br>The 'color' format supports a short or long name of the basic colors and a java.awt.Color object, as in the second example.

<tr>
  <td><b>ColumnFormatData</b><br>Indicates the list of options for the columns with a 'popup' ColumnFormat value.
  <td>&#9656;empty cell array {} (default)
<br>&#9656;1-by-n or n-by-1 cell array with empty values or cellstr arrays.
  <td>t = olduitable('ColumnEditable',true,...<br>'ColumnFormat',{'color','popup'},...<br>'Data',{'red','dog'; 'blue','cat'});<br>t.ColumnFormatData{2} = {'dog','cat',...<br>'rabbit','turtle'};
  <td>If the format of the column is not equal to 'popup' and the ColumnFormatData value is a cellstr a warning will appear and the popup list won't be assigned. Despite this, the value will be stored in case the user assigns the appropriate format later.<br><br>
If the ColumnFormatData is empty for a column that has a 'popup' format (as shown in the example for the ColumnFormat property) the popup list will be created automatically considering all the different cell values for this column.

<tr>
  <td><b>ColumnName</b><br>Indicates the names of the column headers
  <td>&#9656;'numbered'(default)<br>&#9656;empty array<br>&#9656;1-by-n or n-by-1 cell array of char vectors
  <td>t = olduitable('Data',magic(2),...<br>'ColumnName',{'header 1',...<br>'too long|header for a|single line'});<br>
  <td>If an empty array is assigned ({} or []), the table won't have column headers.<br><br>If the length of the ColumnName array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with empty chars ('').

<tr>
  <td><b>ColumnResizable</b><br>Indicates the ability to resize the column widths
  <td>&#9656;logical scalar or array (true by default)<br>&#9656;numeric scalar or array with binary values
  <td>t = olduitable('data',magic(2),...<br>'ColumnResizable',[true false]);<br><br>t2 = olduitable(figure,'Data',magic(2), 'ColumnResizable',[1 0]);
  <td>If the length of the ColumnResizable array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with the default value.

<tr>
  <td><b>ColumnSortable</b><br>Indicates the ability to sort the columns
  <td>&#9656;logical scalar or array (true by default)<br>&#9656;numeric scalar or array with binary values
  <td>t = olduitable('data',magic(10),...<br>'ColumnSortable',[true(1,5) false(1,5)]);
  <td>To sort a column we must left-click the header.<br>
The sort order is unsorted > ascending > descending, then the cycle starts again.<br><br>
See also the sortColumn and unsort methods.

<tr>
  <td><b>ColumnStriping</b><br>Indicates if columns have a shading pattern
  <td>&#9656;'on'<br>&#9656;'off' (default)
  <td>t = olduitable('Data',magic(10),...<br>'ColumnStriping','on');
  <td>This property will take effect as long as the RowStriping property is 'off'.

<tr>
  <td><b>ColumnToolTip</b><br>Indicates the tooltips for the column headers
  <td>&#9656;empty char '' (default)<br>&#9656;1-by-n or n-by-1 cell array of char vectors
  <td>t = olduitable('Data',magic(3),...<br>'ColumnToolTip',...<br>{['this tooltip is very long|',...<br>'to show it in a single line'],'',...<br>'hi, I am the tooltip for the third column'});
  <td>If the length of the ColumnToolTip array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with the default empty value (so, there will be no tooltips in these columns).

<tr>
  <td><b>ColumnWidth</b><br>Indicates the width of the columns
  <td>&#9656;positive number (75 by default)<br>&#9656;1-by-n or n-by-1 cell array with positive numbers whose values are in pixel units
  <td>t = olduitable('Data',magic(10),...<br>'ColumnWidth',50);
  <td>If the length of the ColumnWidth array doesn't match the number of columns in the table, it will be resized truncating to the correct size or filling in with the default value.<br><br>
See also the fitAllColumns2Panel and fitColumn2Data methods.

<tr>
  <td><b>Data</b><br>Indicates the contents of the table
  <td>numeric, logical or cell array
  <td>
  <td>See also the getValue, setValue, paste and cut methods.

<tr>
  <td><b>Enable</b><br>Indicates the ability to interact with the mouse and keyborad in the table
  <td>&#9656;'on' (default)<br>&#9656;'off'
  <td>
  <td>The Regardless of the Enable setting, ButtonDownFcn property will remain active.

<tr><td><b>FontName</b><br>Indicates the font for the cell content.
  <td>any system supported font name that MATLAB can renderer
  <td>t = olduitable('data',magic(5),...<br>'FontName','Courier New');
  <td>

<tr>
  <td><b>FontSize</b><br>Indicates the font size for the table
  <td>positive number whose value is in pixel units (12 by default)
  <td>
  <td>If a decimal number is assigned it will be rounded to the nearest integer.

<tr>
  <td><b>FontStyle</b><br>Indicates the font style for the table
  <td>&#9656;'normal' or 0 (default)<br>&#9656;'bold' or 1<br>&#9656;'italic' or 2<br>&#9656;'bold italic' or 3
  <td>
  <td>

<tr>
  <td><b>ForegroundColor</b><br>Indicates the cell text color
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0 0 0] by default)
  <td>t = olduitable('Data',magic(5),...<br>'ForegroundColor','blue');
  <td>See also the setCellFg method.

<tr>
  <td><b>GridColor</b><br>Indicates the color of the grid in the table
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.85 0.85 0.85] by default)
  <td>t = olduitable('Data',magic(5),...<br>'GridColor','blue');
  <td>

<tr>
  <td><b>HeaderBackground</b><br>Indicates the background color of row and column headers
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.94 0.94 0.94] by default)
  <td>t = olduitable('Data',magic(5),...<br>'HeaderBackground',[0.57 0.79 0.97]);
  <td>

<tr>
  <td><b>HeaderForeground</b><br>Indicates the foreground color of row and column headers
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0 0 0] by default)
  <td>
  <td>

<tr>
  <td><b>HeaderGridColor</b><br>Indicates the color of the borders in the row and column headers
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.75 0.75 0.75] by default)
  <td>t = olduitable('Data',magic(5),...<br>'HeaderGridColor','black');
  <td>

<tr>
  <td><b>HeaderSelectionBg</b><br>Indicates the selection background color of row and column headers
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.8 0.8 0.8] by default)
  <td>t = olduitable('Data',magic(5),...<br>'HeaderSelectionBg','c');
  <td>

<tr>
  <td><b>HeaderSelectionFg</b><br>Indicates the selection foreground color of row and column headers
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0 0 0] by default)
  <td>
  <td>

<tr>
  <td><b>KeyPressFcn</b><br>Function that executes when a key is pressed
  <td>&#9656;'' (default)<br>&#9656;function handle<br>&#9656;cell array<br>&#9656;char vector
  <td>t = olduitable('Data',magic(5),...<br>'KeyPressFcn',...<br>@(~,e)disp(['the ''',e.Key,''' key has been pressed']));
  <td>The EventData structure contains the fields: Character, Modifier, Key, and EventName.

<tr>
  <td><b>KeyReleaseFcn</b><br>Function that executes when a key is released
  <td>&#9656;'' (default)<br>&#9656;function handle<br>&#9656;cell array<br>&#9656;char vector
  <td>
  <td>The EventData structure contains the fields: Character, Modifier, Key, and EventName.

<tr>
  <td><b>Parent</b><br>Indicates the parent object of the table
  <td>&#9656;Figure (gcf by default)<br>&#9656;Panel<br>&#9656;ButtonGroup<br>&#9656;Tab
  <td>f = figure;<br>f2 = figure;<br>t = olduitable(f,'Data',magic(5),...<br>'Parent',f2);
  <td>Parent assignment will have priority over the first argument

<tr>
  <td><b>Position</b><br>Indicates the location and size of the table with respect to its parent
  <td>numeric array<br>[left bottom width height]<br>([1 1 350 300] by default)
  <td>t = olduitable('Data',magic(25));<br>set(t,'Units','normalized',...<br>'Position',[0 0 1 1]);
  <td>If multiple properties are assigned in a single call, as in the example , Units property must be declared first than Position.

<tr>
  <td><b>RowColor</b><br>Indicates the background colors of the rows
  <td>matrix of RGB triplets ([1 1 1; 0.94 0.94 0.94] by default)
  <td>t = olduitable('data',magic(10),...<br>'RowStriping','on',...<br>'RowColor',[1 0 0; 0 1 0; 0 0 1]);
  <td>This property will take effect as long as the RowStriping property is 'on'. If not, the first RGB triplet will be used to color all the rows.<br><br>
See also the setCellBg method.

<tr>
  <td><b>RowHeight</b><br>Indicates the height of the rows
  <td>&#9656;'auto' (default)<br>&#9656;positive number whose value is in pixel units
  <td>t = olduitable('Data',magic(5),...<br>'RowHeight',18);
  <td>The 'auto' value depends on the FontSize and FontName properties.<br><br>If a decimal number is assigned it will be rounded to the nearest integer.

<tr>
  <td><b>RowName</b><br>Indicates the names of the column headers
  <td>&#9656;'numbered' (default)<br>&#9656;empty char ''<br>&#9656;m-by-1 or 1-by-m cell array of char vectors
  <td>t = olduitable('Data',magic(2),...<br>'RowName',{'Row 1';'Row 2'});
  <td>If an empty array is assigned ({} or []), the table won't have row headers.<br><br>If the length of the RowName array doesn't match the number of rows in the table, it will be resized truncating to the correct size or filling in with empty chars ('').

<tr>
  <td><b>RowStriping</b><br>Indicates if rows have a shading pattern
  <td>&#9656;'on'<br>&#9656;'off' (default)
  <td>t = olduitable('Data',magic(10),...<br>'RowStriping','on');
  <td>This property will have priority over ColumnStriping, so, if both properties are 'on', only the rows will have a shadding pattern. In the case that RowStriping is 'off' and ColumnStriping is 'on', the columns will appear colored.

<tr>
  <td><b>SelectionBackground</b><br>Indicates the selection background color of cells
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.93 0.95 1] by default)
  <td>t = olduitable('Data',magic(10),...<br>'SelectionBackground',[0.65 0.81 0.95]);
  <td>The lead selection (last cell selected) will always have a white background color.
<br><br>If the rows or columns have a striped pattern, this property will have no effect.

<tr><td><b>SelectionForeground</b><br>Indicates the selection foreground color of cells
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0 0 0] by default)
  <td>t = olduitable('Data',magic(10),...<br>'SelectionForeground','g');
  <td>The lead selection will always have a black foreground color.
<br><br>If the rows or columns have a striped pattern, this property will have no effect.

<tr>
  <td><b>SelectionBorderColor</b><br>Indicates the color of the external selection border
  <td>&#9656;short or long name of a basic color<br>&#9656;RGB triplet ([0.26 0.52  0.96] by default)
  <td>t = olduitable('Data',magic(10),...<br>'SelectionBackground',[0.65 0.81 0.95],...<br>'SelectionBorderColor','k');
  <td>

<tr>
  <td><b>Tag</b><br>Assigns the table identifier
  <td>char vector ('' by default)
  <td>
  <td>

<tr>
  <td><b>UIContextMenu</b><br>Indicates the context menu for table
  <td>&#9656;'auto' (default)<br>&#9656;empty array<br>&#9656;a javax.swing.JPopupMenu component
  <td>
  <td>The default UIContextMenu is similar to the context menu of the Matlab Variables Editor, so it has items such as Cut, Copy, Paste, Clear Contents and Insert and Delete Rows or Columns (the latter will only be available if the entire table is editable).

<tr>
  <td><b>Units</b><br>Indicates the units of measure in which the Position vector is expressed
  <td>&#9656;'pixels' (default)<br>&#9656;'normalized' <br>&#9656;'inches' <br>&#9656;'centimeters' <br>&#9656;'points' <br>&#9656;'characters'
  <td>
  <td>

<tr>
  <td><b>UserData</b><br>Indicates the user data associated with the <i>olduitable</i> object
  <td>any Matlab array ([] by default)
  <td>
  <td>

<tr>
  <td><b>Visible</b><br>Indicates the table visibility
  <td>&#9656;'on' (default)<br>&#9656;'off'
  <td>
  <td>

</table>

## Methods

### Destructor

To programmatically destroy the `olduitable` object named `t`, use:

`t.delete`

### Recoverer

To save the property values (except for the `Parent` and for a custom `UIContextMenu`) in a structure within a *.mat file, use:

`t.saveInfo; % it creates the t.mat file in the current directory`

or

`t.saveInfo('filename'); % it creates the filename.mat file in the current directory`

### Deconstructor

To programmatically redraw the `olduitable` whose properties were stored in the `filename.mat` file, use:

`t2 = olduitable.loadInfo('filename'); % it's not necessary to include the .mat extension`

### Adjust the column widths

To adjust the column widths to the visible area of the scroll pane, use:

`t.fitAllColumns2Panel`

If instead, we want to adjust the panel container to the table's size, use:

```
previousUnits = t.Units;
t.Units = 'pixels';
t.Position(3:4) = t.Extent;
t.Units = previousUnits;
```

On the other hand, to adjust the width for a column according to its content, use any of the following commands:

```
t.fitColumn2Data(columnIndex)
t.fitColumn2Data(columnIndex,considerHeader)
```

where `considerHeader` is a logical scalar (`false` by default) that indicates if the column heading name is considered in the calculation.

This method won't have effect if the format for the column is `'longchar'` and the `considerHeader` input is `false`. If it is `true`, the resulting column width will be the one that best fits the width of the header.

### Select a range of cells

To programmatically select a rectangular block defined by the opposite cells `firstCell` and  `lastCell`, use:

`t.setSelection(firstCell,lastCell);`

where `firstCell = [firstRowIndex, firstColumnIndex]` and `lastCell = [lastRowIndex, lastColumnIndex]`.

Besides we can select a column by right-clicking the header or select multiple columns through mouse drag (with the same right button). In the same way, clicking on the upper left corner selects the entire table.

### Sort a column
To sort a column, even if the `ColumnSortable` property for this is `false`, use:

`t.sortColumn(column,direction);`

where `column` is the column index and `direction` is the char vector `'ascend'` or `'descend'`.

The current sorted column will have an arrow indicating the sort direction. Additionally, the follow read-only properties show this information.

```
indices = t.RowSortIndices; % indicates the order of the rows order with respect to the unsorted state
sortedColumn = t.SortedColumn; % 0 if the columns are unsorted
sortDirection = t.SortDirection; % 0 = unsorted, 1 = ascending and -1 = descending
```

On the other hand, if we consult the `Data` and `RowName` properties, will see reflected the current sort status.

### Unsort the table
To programmatically unsort the table, use

`t.unsort;`

### Get the  the content of a specific cell

To get the cell value at `row` and `column`, use:

`value = t.getValue(row,column);`

### Set the content of a specific cell

To programmatically set the cell value at `row` and `column`, use:

`t.setValue(value,row,column)`

The input `value` must be a scalar that is not contained in a cell array (use `{value}` will cause an error).

### Set the background color for a single cell
To set the background color for a cell at `row` and `column`, use

`t.setCellBg(value,row,column)`

where `value` may be a char vector with the short or long name of a basic color (`'r'` or `'red'`for example) or a RGB triplet (`[1 0.5 0]` for example).

To return to the previous background defined by the `RowColor` or `ColumnColor` properties, use

`t.resetCellBg(column)`

### Set the foreground color for a single cell
To set the foreground color for a cell at `row` and `column`, use

`t.setCellFg(value,row,column)`

where `value` may be a char vector with the short or long name of a basic color or a RGB triplet.

To return to the previous foreground defined by the `ForegroundColor` property, use

`t.resetCellFg(column)`

**Note**: These "reset" functions will only have effect for the specfied column.

### Paste data in the table

To paste the contents of the clipboard (including data from Excel), use any of the following options:

* the default context menu
* <kbd>Ctrl</kbd> + <kbd>V</kbd>
* the command `t.paste`

### Cut data from the table

To cut the contents of the selected cells in the table `t` use:

* the default context menu
* <kbd>Ctrl</kbd> + <kbd>X</kbd>
* the command `t.cut`

### Clear contents

To clear the contents of the selected cells use:

* the default context menu
* <kbd>delete</kbd> key
* the command `t.paste({''})`

**Note**: The methods to paste, cut and clear the contents won't work if the selected columns are not editable.

### Insert rows

To insert rows above or below the selected cells use:

* the default context menu
* <kbd>Alt</kbd> + <kbd>&uparrow;</kbd> (to insert rows above)
* <kbd>Alt</kbd> + <kbd>&downarrow;</kbd> (to insert rows below)
* the command `t.insertRows(direction)` where `direction` is `'above'` or `'below'`.

### Insert columns

To insert columns to the left or right of the selected cells use:

* the default context menu
* <kbd>Alt</kbd> + <kbd>&leftarrow;</kbd> (to insert columns to the left)
* <kbd>Alt</kbd> + <kbd>&rightarrow;</kbd> (to insert columns to the right)
* the command `t.insertColumns(direction)` where `direction` is `'left'` or `'right'`.

### Delete rows

To delete the selected rows use:

* the default context menu
* <kbd>Ctrl</kbd> + <kbd>&minus;</kbd>
* the command `t.deleteRows`

### Delete columns

To delete the selected columns use:

* the default context menu
* <kbd>Ctrl</kbd> + <kbd>backspace</kbd>
* the command `t.deleteColumns`

**Note**: By design the methods to insert and delete rows and columns only work if the **entire** table is editable.

### Common keyboard shortcuts

* <kbd>Ctrl</kbd> + <kbd>A</kbd> selects the entire table
* <kbd>Ctrl</kbd> + <kbd>C</kbd> copies the content of the selected cells to the system clipboard
* <kbd>Ctrl</kbd> + <kbd>&uparrow;</kbd> goes to the first row
* <kbd>Ctrl</kbd> + <kbd>&downarrow;</kbd> goes to the last row
* <kbd>Ctrl</kbd> + <kbd>&leftarrow;</kbd> goes to the first column
* <kbd>Ctrl</kbd> + <kbd>&rightarrow;</kbd> goes to the last column
* <kbd>Shift</kbd> + <kbd>arrow</kbd> expands/contracts the current selection

## Limitations/Known Issues

1. `olduitable` should work since Matlab R2014b, mainly due the dot notation usage, however it hasn't been tested, so maybe it could work in previous versions. Besides, should be considered the version of Java (really, the JVM) that Matlab is using. The package `asd.fgh.olduitable` used in this class was compiled in Java 7 (used for the first time in R2013b), so for earlier versions the Java classes must be recompiled and repacked.

1. The JAR file that contains these classes is added to the dynamic path by the `javaaddpath` function. This could produce problems if another package was added before. So, the best option is to include it in the static path through a customized `javaclasspath.txt` located in the "preference folder" (type `prefdir` in the command window to know which is) or in the "startup folder". This file must contain the full name of the JAR file, like the following example:
```
<before>
C:\Documents\MATLAB\@olduitable\javaClasses.jar
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Any change in the static Java class path will be available in the next Matlab session.

3. The formats `'bank'` and `'char'` don't determine the alignment of the content like Matlab (left-justified for chars and right-justified for numerical data). To reproduce this behavior, we must use the `ColumnAlign` property.

4. The use of multiple sort keys was not implemented, so only the current column sorted controls the order for the rows. Besides, if we edit the content of the cells when a sort mode is active, the new data is not re-sorted. In that case the sort sequence is reset, starting an ascending sorting if we click on the column header again. It could be easily fixed by defining `sorter.setSortsOnUpdates(true)`, but this would complicate the rearrangement of the row headers. On the other hand, the methods to insert rows are disabled while a sort mode is active.

5. The procedures to insert and delete columns aren't very elegant and can be quite inefficient compared to `addColumn` and `moveColumn` methods, because, basically, a new data with empty columns is assigned in the table (and with it, renderers, editors, etc.), however they are the easiest way to maintain order in the columns, by matching the indices in the view with the model. In this sense, if shorcuts are used, avoid keep the left or right arrow keys pressed for a long time, it can produce a very poor performance.

6. The drag in the headers with the <kbd>Ctrl</kbd> key + mouse combination was not implemented. It'll make the highlighted headers doesn't match the selection of the table (particularly for the row header, that is other javax.swing.JTable object).

7. If we drag the scroll bars directly, specially for the horizontal bar, would see a bit of delay between the renderers of the headers and the table's body. This is probably because every time the view changes, the components of the jscrollpane are repainted. The solution for this is …..??

## License

This project is licensed under the terms of the <a href="https://github.com/pbaezr/olduitable/blob/master/LICENSE">MIT License</a>.

## Author

<a href="mailto:pbaez@ug.uchile.cl">Pablo Báez R.</a>

## Version

1.0 (2018-10-27)
