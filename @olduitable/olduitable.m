classdef olduitable < matlab.mixin.SetGet
    % OLDUITABLE is a Matlab class that implements a Java-based table.
    % It includes many of the properties of the Matlab uitable, with an interface
    % similar to its undocumented version (v0). Besides this class incorporates
    % new properties such as ColumnAlign, ColumnColor, ColumnToolTip, GridColor,
    % HeaderBackground, SelectionBackground, among others, and methods to insert
    % or delete rows and columns and paste blocks of cells as a typical spreadsheet.
    %
    % For more details go to <a href="matlab:web('https://github.com/pbaezr/olduitable/blob/master/README.md')">online documentation<div></div></a>
    
    % Licensed under the terms of the MIT License
    % Copyright (c) 2018 Pablo Baez R.

    %% Properties    
    properties % callbacks (3/5)
        ButtonDownFcn = '' % Function that is executed when a button mouse is clicked.<li>Valid Inputs: function handle | cell array | char vector
        CellEditCallback = '' % Function that is executed when the contents of table change.<li>Valid Inputs: function handle | cell array | char vector
        CellSelectionCallback = '' % Function that is executed when the table selection changes.<li>Valid Inputs: function handle | cell array | char vector
    end
    
    properties (Dependent)     
        ColumnAlign % Indicates the alignment of the columns.<li>Valid Inputs: 'letf' | 'center' | 'right' | cell array of char vectors
        ColumnColor % Indicates the pattern for the columns' background colors.<li>Valid Inputs: matrix of RGB triplets
        ColumnEditable % Indicates the ability to edit the column cells.<li>Valid Inputs: logical scalar or array | numeric scalar or array with binary values
        ColumnFormat % Indicates the column displays.<li>Valid Inputs: '' | 'bank' | 'char' | 'color' | 'logical' | 'longchar' | 'popup' | char vector with a formatting operator | cell array of char vectors
        ColumnFormatData % Indicates the list of options for the columns with a 'popup' ColumnFormat value.<li>Valid Inputs: cell array with empty values or cellstr arrays
        ColumnName % Indicates the names of the column headers.<li>Valid Inputs: 'numbered' | empty array | cell array of char vectors
        ColumnResizable % Indicates the ability to resize the column widths.<li>Valid Inputs: logical scalar or array | numeric scalar or array with binary values
        ColumnSortable % Indicates the ability to sort the column.<li>Valid Inputs: logical scalar or array | numeric scalar or array with binary values
        ColumnStriping % Indicates if columns have a shading pattern.<li>Valid Inputs: 'on' | 'off'
        ColumnToolTip % Indicates the tooltips for the column headers.<li>Valid Inputs: '' | cell array of char vectors
        ColumnWidth % Indicates the width of the columns.<li>Valid Inputs: positive number | cell array with positive numbers
        Data % Indicates the contents of the table.<li>Valid Inputs: numeric, logical or cell array
        Enable % Indicates the ability to interact with the mouse and keyborad in the table.<li>Valid Inputs: 'on' | 'off'
        FontName % Indicates the font for the cell content.<li>Valid Inputs: see <a href="matlab:listfonts">List system fonts</a>)
        FontSize % Indicates the font size for the table.<li>Valid Inputs: positive number whose value is in pixel units)
        FontStyle % Indicates the font style for the table.<li>Valid Inputs: 'normal' (0) | 'bold' (1) | 'italic' (2)
        ForegroundColor % Indicates the cell text color.<li>Valid Inputs: short or long name of the color | RGB triplet
        GridColor % Indicates the color of the grid in the table.<li>Valid Inputs: short or long name of the color | RGB triplet
        HeaderBackground % Indicates the background color of row and column headers.<li>Valid Inputs: short or long name of the color | RGB triplet
        HeaderForeground % Indicates the foreground color of row and column headers.<li>Valid Inputs: short or long name of the color | RGB triplet
        HeaderGridColor % Indicates the color of the grid in the row and column headers.<li>Valid Inputs: short or long name of the color | RGB triplet
        HeaderSelectionBg % Indicates the selection background color of row and column headers.<li>Valid Inputs: short or long name of the color | RGB triplet
        HeaderSelectionFg % Indicates the selection foreground color of row and column headers.<li>Valid Inputs: short or long name of the color | RGB triplet
    end
    
    properties % callbacks (5/5)
        KeyPressFcn = '' % Function that is executed when a key is pressed.<li>Valid Inputs: function handle | cell array | char vector
        KeyReleaseFcn = '' % Function that is executed when a key is released.<li>Valid Inputs: function handle | cell array | char vector
    end
    
    properties (Dependent)
        Parent % Indicates the parent object of the table.<li>Valid Inputs: Figure | Panel | ButtonGroup | Tab
        Position % Indicates the location and size of the table with respect to its parent.<li>Valid Inputs: numeric array [left bottom width height]
        RowColor % Indicates the pattern for the rows' background colors.<li>Valid Inputs: matrix of RGB triplets
        RowHeight % Indicates the height of the rows.<li>Valid Inputs: 'auto' | positive number whose value is in pixel units
        RowName % Indicates the names of the column headers.<li>Valid Inputs: 'numbered' | empty array | cell arry of char vectors
        RowStriping % Indicates if rows have a shading pattern.<li>Valid Inputs: 'on' | 'off'
        SelectionBackground % Indicates the selection background color of cells.<li>Valid Inputs: short or long name of the color | RGB triplet
        SelectionForeground % Indicates the selection foreground color of cells.<li>Valid Inputs: short or long name of the color | RGB triplet
        SelectionBorderColor % Indicates the color of the external selection border.<li>Valid Inputs: short or long name of the color | RGB triplet
        Tag % Assigns the table identifier.<li>Valid Inputs: char vector
        UIContextMenu % Indicates the context menu for table.<li>Valid Inputs: empty array | 'default' | a Java component of type javax.swing.JPopupMenu
        Units % Indicates the units of measure in which the Position vector is expressed.<li>Valid Inputs: 'pixels' | 'normalized' | 'inches' | 'centimeters' | 'points' | 'characters'
        UserData % Indicates the user data associated with the 'olduitable' object.<li>Valid Inputs: any Matlab array
        Visible % Indicates the table visibility.<li>Valid Inputs: 'on' | 'off'
    end
    
    % read-only properties
    properties (SetAccess = private)
        RowSortIndices % Read-only property that indicates the row indices for the current sort mode according to the unsorted state (= [] if columns are unsorted)
        SortDirection % Read-only property that indicates the current sort direction.<li>Values: 0 (unsorted), 1 (ascend) or -1 (descend)
        SortedColumn % Read-only property that indicates the current sorted column index (= 0 if columns are unsorted)            
    end
    
    %% Internal properties
    properties (Access = protected, Hidden)
        editing % parameter that prevents the 'TableChangedCallback' re-entrancy
        editingRow = -1 % index for the last row that was in an edit mode
        editingCol = -1 % index for the last column that was in an edit mode
        editType % parameter that indicates the type of edition in the table ('CellEdit','ColumnsInsertion','RowsInsertion','ColumnsDelete', etc.)
        fontMetrics % parameter to measure the strings according to the font used in the table
        fontMetricsRowHeader % idem for the row headers
        inConstruction = false % parameter that indicates whether table is still in construction
        info % variable that works as a backup that store all the settable properties (except for callback functions, Data, Parent and UserData)
        isDataModified = false % parameter that indicates whether a cell was modified
        oldValue % previous value for the last cell edited
        rheaderWidth = 0 % width of the row headers
        rownames % cell array of chars vectors that contains the row heading names
        theaderHeight = 0 % height of the column headers        
    end

    properties (Access = protected, Hidden) % java objects
        columnHeader % the column header (a 'asd.fgh.olduitable.ColumnHeader' object that extends the JTableHeader class)
        columnModel % the column model (a 'javax.swing.table.DefaultTableColumnModel' object)
        cont % the table's container (a 'matlab.ui.container.Panel' object)
        corner % upper left corner of table (a 'javax.swing.JLabel' object)
        jtable % the main table (a 'asd.fgh.olduitable.Table' object that extends the JTable class)
        jscrollpane % the scroll pane (a 'javax.swing.JScrollPane' object)
        rowheader % the row header (a 'asd.fgh.olduitable.RowHeader' object that extends the JTable class)
        sorter % the object that provides the sorting ('asd.fgh.olduitable.Sorter' object that extends the TableRowSorter class)
        tableModel % the table model (a 'asd.fgh.olduitable.EditableModel' object that extends the DefaultTableModel class)
        defaultContextMenu % the context menu by default (a 'javax.swing.JPopupMenu' object)
    end

    properties (Access = protected, Hidden) % auxiliary variables that indicate the selection changes in table     
        ColumnsSelectionRange = {0,0} % {FirstColumnSelected,LastColumnSelected} ---> selection sequence (not ordered by the indices)
        RowsSelectionRange = {0,0} % idem for the rows
    end
    
    properties (Access = protected, Hidden)
        colorEditor = struct('cellbutton',[],'dropdownMenu',[]) % structure that stores the color picker (a javax.swing.JPopupMenu object)
        colorFormat % parameter that indicate if the column has a 'color' value for the 'columnformat' property 
        longcharEditor = struct('cellbutton',[],'dropdownMenu',[],'area',[]) % structure that stores the ... (a javax.swing.JPopupMenu object)
    end

    properties (Constant, Hidden)
        listfonts = [listfonts;'MS Sans Serif'] % list of available fonts (at least in MS Windows)
        propertyList = {'ButtonDownFcn','CellEditCallback','CellSelectionCallback','ColumnAlign','ColumnColor','ColumnEditable',...
            'ColumnFormat','ColumnFormatData','ColumnName','ColumnResizable','ColumnSortable','ColumnStriping','ColumnToolTip',...
            'ColumnWidth','Data','Enable','FontName','FontSize','FontStyle','ForegroundColor','GridColor','HeaderBackground',...
            'HeaderForeground','HeaderGridColor','HeaderSelectionBg','HeaderSelectionFg','KeyPressFcn','KeyReleaseFcn','Parent',...
            'Position','RowColor','RowHeight','RowName','RowStriping','SelectionBackground','SelectionForeground','SelectionBorderColor',...
            'Tag','UIContextMenu','Units','UserData','Visible'}'        
        validParent = {'matlab.ui.Figure','matlab.ui.container.Tab','matlab.ui.container.Panel','matlab.ui.container.ButtonGroup'}'        
    end

    %% Constructor
    methods        
        function obj = olduitable(varargin)            
            %Creates a new olduitable object.<font face="consolas"><li>t = olduitable;<li>t = olduitable('PropertyName',value,...);<li>t = olduitable(parent,'PropertyName',value,...);
            
            % create input parser scheme to validate the arguments
            scheme = inputParser;

            if verLessThan('matlab','8.2') % --> versions earlier than R2013b
                addParamFcn = 'addParamValue';                
            else
                addParamFcn = 'addParameter';             
            end
            
            scheme.(addParamFcn)('ButtonDownFcn','',@(x)obj.callbackValidation(x));
            scheme.(addParamFcn)('CellEditCallback','',@(x)obj.callbackValidation(x));
            scheme.(addParamFcn)('CellSelectionCallback','',@(x)obj.callbackValidation(x));
            scheme.(addParamFcn)('ColumnAlign','center',@(x)obj.columnalignValidation(x));
            scheme.(addParamFcn)('ColumnColor',[1 1 1;16/17*ones(1,3)],@(x)obj.rgbValidation(x));
            scheme.(addParamFcn)('ColumnEditable',false,@(x)obj.binaryValidation(x));
            scheme.(addParamFcn)('ColumnFormat','',@(x)obj.columnformatValidation(x));
            scheme.(addParamFcn)('ColumnFormatData',{},@(x)obj.colformatdataValidation(x));
            scheme.(addParamFcn)('ColumnName','numbered',@(x)obj.headerNamesValidation(x));
            scheme.(addParamFcn)('ColumnResizable',true,@(x)obj.binaryValidation(x)); 
            scheme.(addParamFcn)('ColumnSortable',true,@(x)obj.binaryValidation(x));
            scheme.(addParamFcn)('ColumnStriping','off',@(x)obj.onoffValidation(x));
            scheme.(addParamFcn)('ColumnToolTip','',@(x)obj.tooltipsValidation(x));
            scheme.(addParamFcn)('ColumnWidth',75,@(x)obj.columnwidthValidation(x));
            scheme.(addParamFcn)('Data',cell(1,1),@(x)obj.dataValidation(x));
            scheme.(addParamFcn)('Enable','on',@(x)obj.onoffValidation(x));
            scheme.(addParamFcn)('FontName','',@(x)obj.fontnameValidation(x));
            scheme.(addParamFcn)('FontSize',12,@(x)obj.fontsizeValidation(x));
            scheme.(addParamFcn)('FontStyle',0,@(x)obj.fontstyleValidation(x));
            scheme.(addParamFcn)('ForegroundColor',[0 0 0],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('GridColor',0.85*[1 1 1],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('HeaderBackground',16/17*[1 1 1],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('HeaderForeground',[0 0 0],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('HeaderGridColor',0.75*[1 1 1],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('HeaderSelectionBg',0.8*[1 1 1],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('HeaderSelectionFg',[0 0 0],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('KeyPressFcn','',@(x)obj.callbackValidation(x));
            scheme.(addParamFcn)('KeyReleaseFcn','',@(x)obj.callbackValidation(x));
            scheme.(addParamFcn)('Parent',[],@(x)obj.parentValidation(x));
            scheme.(addParamFcn)('Position',[1 1 350 300],@(x)obj.positionValidation(x));
            scheme.(addParamFcn)('RowColor',[1 1 1;16/17*ones(1,3)],@(x)obj.rgbValidation(x));
            scheme.(addParamFcn)('RowHeight','auto',@(x)obj.rowheightValidation(x));
            scheme.(addParamFcn)('RowName','numbered',@(x)obj.headerNamesValidation(x));
            scheme.(addParamFcn)('RowStriping','off',@(x)obj.onoffValidation(x));
            scheme.(addParamFcn)('SelectionBackground',[236 243 255]./255,@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('SelectionForeground',[0 0 0],@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('SelectionBorderColor',[66 133 244]./255,@(x)obj.colorValidation(x));
            scheme.(addParamFcn)('Tag','',@(x)obj.tagValidation(x));
            scheme.(addParamFcn)('UIContextMenu','auto',@(x)obj.jpopupValidation(x));
            scheme.(addParamFcn)('Units','pixels',@(x)obj.unitsValidation(x));
            scheme.(addParamFcn)('UserData',[]);
            scheme.(addParamFcn)('Visible','on',@(x)obj.onoffValidation(x));
            
            %ind0 = 1;
            if isempty(varargin)
                ind0 = []; % t = olduitable
            elseif ischar(varargin{1})
                ind0 = 1; % t = olduitable('PropertyName1',value1,'PropertyName2',value2,...)
            elseif ismember(class(varargin{1}),obj.validParent) && isvalid(varargin{1})
                ind0 = 2; % t = olduitable(Parent,'PropertyName1',value1,...)
            end

            parse(scheme,varargin{ind0:end});
            params = scheme.Results;

            % initial construction -----------------------------------------------------------------------------------------------
            obj.inConstruction = true; % notify start of construction
            
            % add the java classes to the dynamic path
            folder = fullfile(fileparts(which('olduitable')),'javaClasses.jar');
            if ~ismember(folder,javaclasspath('-all'))
                if ~isempty(javaclasspath('-dynamic'))
                    warning(['Clear the classes or create a custom classpath including the filename ',folder]);
                    return;
                else
                    javaaddpath(folder);
                end
            end

            % if local region doesn't have the dot(.) as the decimal separator, change the region to one that has it
            formatSymbols = java.text.DecimalFormatSymbols(java.util.Locale.getDefault); % default symbols according to regional settings
            if ~strcmp(formatSymbols.getDecimalSeparator,'.') && ...
                    ~strcmp(java.util.Locale.getDefault.toString,'en_US')
                java.util.Locale.setDefault(java.util.Locale.US); % Locale.ENGLISH
            end            

            % define parent
            if isempty(params.Parent) && ~isempty(ind0) && ind0 == 2
                params.Parent = varargin{1}; % parent will be the first argument
            elseif isempty(params.Parent)
                params.Parent = gcf; % table will be assigned to the current figure (or a new if doesn't exist)
            end            

            % define the java components
            
            % custom table model that implements the 'ColumnEditable' property
            model = javaObjectEDT('asd.fgh.olduitable.EditableModel',cell(1,1),' ');
            obj.tableModel = handle(model,'CallbackProperties');            
            
            % jtable
            table = javaObjectEDT('asd.fgh.olduitable.Table',obj.tableModel);           
            obj.jtable = handle(table,'CallbackProperties');
            defaultFont = obj.jtable.getFont;
            obj.fontMetrics = java.awt.Canvas().getFontMetrics(defaultFont);
            obj.fontMetricsRowHeader = obj.fontMetrics;
            
            % column model
            obj.columnModel = handle(obj.jtable.getColumnModel,'CallbackProperties');
            
            % sorter
            obj.sorter = asd.fgh.olduitable.Sorter(obj.tableModel);
            %obj.sorter.setSortsOnUpdates(true);
            obj.jtable.setRowSorter(obj.sorter);

            % jscrollpane
            obj.cont = uipanel(params.Parent,'BorderType','beveledout','DeleteFcn',@(~,~)obj.delete);
            obj.jscrollpane = javaObjectEDT('javax.swing.JScrollPane',obj.jtable);
            [obj.jscrollpane,wrapper] = javacomponent(obj.jscrollpane,[],obj.cont);
            wrapper.Units = 'normalized';
            wrapper.Position = [0 0 1 1];            
                        
            % column header
            columnheader = javaObjectEDT('asd.fgh.olduitable.ColumnHeader',obj.jtable);
            obj.columnHeader = handle(columnheader,'CallbackProperties');
            obj.jtable.setTableHeader(obj.columnHeader);
            obj.jscrollpane.setColumnHeaderView(obj.columnHeader);
            d = obj.columnHeader.getPreferredSize; d.height = 24;            
            obj.columnHeader.getParent.setPreferredSize(d);

            % row header
            %rheader = javaObjectEDT('asd.fgh.olduitable.RowHeader',obj.jtable);
            rheaderModel = javaObjectEDT('javax.swing.table.DefaultTableModel',cell(1,1),' ');            
            rheader = javaObjectEDT('asd.fgh.olduitable.RowHeader',rheaderModel,obj.jtable);
            obj.rowheader = handle(rheader,'CallbackProperties');
            obj.jscrollpane.setRowHeaderView(obj.rowheader);          

            % upper left corner
            corner = javaObjectEDT('javax.swing.JLabel','<html>&#9698;');
            obj.corner = handle(corner,'CallbackProperties');
            obj.jscrollpane.setCorner(javax.swing.ScrollPaneConstants.UPPER_LEFT_CORNER,obj.corner);
            obj.corner.setOpaque(true);
            border = javax.swing.border.CompoundBorder(...
                javax.swing.border.MatteBorder(0,0,1,1,java.awt.Color(0.75,0.75,0.75)),javax.swing.border.EmptyBorder(0,0,-1,2));
            obj.corner.setBorder(border);
            obj.corner.setHorizontalAlignment(javax.swing.SwingConstants.RIGHT);
            obj.corner.setVerticalAlignment(javax.swing.SwingConstants.BOTTOM);
            obj.corner.setFont(java.awt.Font(defaultFont.getName,0,16));
            obj.corner.setForeground(java.awt.Color(0.8,0.8,0.8));

            % Set property values -----------------------------------------------------------------------------------------------
            
            % resize values for the properties that could vary in each column
            n = size(params.Data,2);
            colProperties = {'ColumnAlign','ColumnEditable','ColumnFormat','ColumnFormatData','ColumnResizable','ColumnSortable','ColumnToolTip','ColumnWidth'};
            defaultvalues = {'center',false,'',{},true,true,'',75};
            for i = [1 3 4 7 8]
                params.(colProperties{i}) = obj.resize2columncount(n,defaultvalues{i},params.(colProperties{i}));
            end
            for i = [2 5 6]
                params.(colProperties{i}) = obj.resizelogical2columns(n,defaultvalues{i},params.(colProperties{i}));
            end

            % store user-defined or default values in backup            
            obj.info = params;
            obj.info.Data = []; % store the data is not necessary (and could take much memory space)
            obj.info.Parent = [];
            obj.info.UserData = [];

            % assign essential properties (with user-defined or default values)
            % ('Parent' has already been assigned)
            properties1 = {'Visible','Units','Position','Data','ColumnName','RowName','UIContextMenu'};
            for i = 1:length(properties1)
                obj.(properties1{i}) = params.(properties1{i});
            end
            
            % assign additional properties if those were defined by the user, except for 'ColumnFormatData' that has already assigned internally)
            % (with certain order according to their interdependence)
            if ~isempty(ind0)
                index = 1:length(obj.propertyList);
                if ~isstruct(varargin{ind0})
                    [verify,~] = ismember(lower(obj.propertyList),lower(varargin(ind0:2:end-1)));                    
                else % that case is for when 'olduitable.loadinfo' function is used
                    [verify,~] = ismember(lower(obj.propertyList),lower(fieldnames(varargin{ind0})));
                end
                for k = index(verify), toSet.(obj.propertyList{k}) = true; end
                for k = index(~verify), toSet.(obj.propertyList{k}) = false; end
                properties2 = {'FontName','FontStyle','FontSize','RowHeight','Tag','UserData',...
                    'RowStriping','RowColor','ColumnStriping','ColumnColor','ForegroundColor','GridColor',...
                    'HeaderBackground','HeaderForeground','HeaderGridColor','HeaderSelectionBg','HeaderSelectionFg',...
                    'SelectionBackground','SelectionForeground','SelectionBorderColor',...
                    'ColumnAlign','ColumnFormat','ColumnEditable','ColumnResizable','ColumnSortable','ColumnToolTip','ColumnWidth','Enable',...
                    'ButtonDownFcn','CellEditCallback','CellSelectionCallback','KeyPressFcn','KeyReleaseFcn'};             
                for i = 1:length(properties2)
                    if toSet.(properties2{i}), obj.(properties2{i}) = params.(properties2{i}); end
                end
            end

            % callbacks assignments -----------------------------------------------------------------------------------------------
            obj.jtable.stopEditingWhenOtherComponentIsClicked;
            obj.jtable.ComponentResizedCallback = @obj.columnResize;
            obj.tableModel.TableChangedCallback = @obj.cellEdit;
            
            % add listeners to the selection models
            rowSelectionHandle = handle(obj.jtable.getSelectionModel,'CallbackProperties');
            colSelectionHandle = handle(obj.jtable.getColumnModel.getSelectionModel,'CallbackProperties');
            rowSelectionHandle.ValueChangedCallback = {@obj.selectionChanged,'Rows'};
            colSelectionHandle.ValueChangedCallback = {@obj.selectionChanged,'Columns'};
            
            % add mouse and keyboard listeners to the jscrollpane's components that trigger the user's callbacks
            obj.jtable.MousePressedCallback = @obj.jtableSelection;
            obj.jtable.KeyPressedCallback = @obj.keyfunction;
            obj.jtable.KeyReleasedCallback = {@obj.callKeyFcn,'KeyReleaseFcn'};                
            obj.corner.MousePressedCallback = @obj.cornerSelection;
            obj.rowheader.MousePressedCallback = @(~,evt)obj.callButtonDownFcn(evt,'RowHeader');
            obj.columnHeader.MousePressedCallback = @obj.colheaderSelection;
            set(handle(obj.jscrollpane.getViewport,'CallbackProperties'),...
                'MousePressedCallback',@(~,evt)obj.callButtonDownFcn(evt,'EmptyPanel'));
            obj.jscrollpane.MousePressedCallback = @(~,evt)obj.callButtonDownFcn(evt,'OtherCorners');

            % finally --------------------------------------------------------------------------------------------------
            obj.jtable.repaint;
            obj.jtable.changeSelection(0,0,false,false);
            obj.rowheader.changeSelection(0,0,false,false);
            obj.inConstruction = false;
        end        
    end

    %% User methods
    % Syntax:
    %       methodName(obj,arg1,arg2,...)
    %       obj.methodName(arg1,arg2,...)
    methods

        % Destructor
        function delete(obj)
            % olduitable object destructor (this function runs automatically if the parent is destroyed)<br><font face="consolas">t.delete
            if ~isempty(obj.cont) && strcmp(obj.cont.BeingDeleted,'off')
                delete(obj.cont); % necessary if manual removal is performed
            end
        end
        
        % Recoverer
        function saveInfo(obj,varargin)
            % This function saves the property values in a *.mat file.<br><font face="consolas">t.saveInfo<br>t.saveInfo('filename')
            
            % define the filename
            if isempty(varargin)
                filename = inputname(1); % use object's name if filename isn't specified
            elseif nargin == 2 && ischar(varargin{1}) && isrow(varargin{1}) && ...                    
                regexp(varargin{1},['^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)','(\..+)?$)[^\x00-\x1f\\?*:\"><|/]+$'],'once')
                % taken from https://www.mathworks.com/matlabcentral/answers/44165-check-if-filename-is-valid#answer_54287
                filename = varargin{1};
            else
                error('Input must be a character vector that contains a valid file name');
            end
            
            % store values in a structure named 'properties' (except for the 'Parent' and for a custom 'UIContextMenu')
            properties = obj.info;
            properties.Data = obj.Data;
            properties.Parent = [];
            properties.UserData = obj.cont.UserData;
            if ~ischar(properties.UIContextMenu), properties.UIContextMenu = []; end
            
            % store callback functions
            callbacks = {'ButtonDownFcn','CellEditCallback','CellSelectionCallback','KeyPressFcn','KeyReleaseFcn'};
            for i = 1:5
                properties.(callbacks{i}) = obj.(callbacks{i});
            end            
            
            % save the structure in the filename.mat file
            save(filename,'properties')
        end        
        
        function fitColumns2Panel(obj)
            % Function to adjust the column widths to the visible area of the scroll pane.<br><font face="consolas">t.fitColumns2Panel
            obj.jtable.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_ALL_COLUMNS);
        end
        
%         % function to adjust the column widths depending on the contents (not implemented to avoid legal problems)
%         function fitcolumn2data(obj)
%             obj.jtable.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_OFF);
%             com.mathworks.mwswing.MJUtilities.initJIDE;
%             com.jidesoft.grid.TableUtils.autoResizeAllColumns(obj.jtable);            
%         end        
        
        function setSelection(obj,firstCell,lastCell)
            % Function to select a range of cells.<br><font face="consolas">t.setSelection(firstCell,lastCell); % where firstCell = [firstRowIndex, firstColumnIndex] and lastCell = [lastRowIndex, lastColumnIndex]
            
            % validate inputs
            cells = {firstCell,lastCell};
            for i = 1:2
                cell = cells{i};
                validateattributes(cell,{'numeric'},{'row','size',[1,2]});
                validateattributes(cell(1),{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getRowCount});
                validateattributes(cell(2),{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            end
            
            % change the selection
            obj.jtable.setRowSelectionInterval(firstCell(1)-1,lastCell(1)-1);
            obj.jtable.setColumnSelectionInterval(firstCell(2)-1,lastCell(2)-1);
            
            % scroll to first cell
            obj.jtable.scrollRectToVisible(obj.jtable.getCellRect(firstCell(1)-1,firstCell(2)-1,true));
        end        
        
        function val = getValue(obj,row,column)
            % Function to get the content of a specific cell.<br><font face="consolas">value = t.getValue(rowIndex,columnIndex);
            
            % validate inputs
            validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getRowCount});
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            
            % get the cell value
            val = obj.jtable.getValueAt(row-1,column-1);
        end

        function setValue(obj,val,row,column)
            % Function to set the content of a specific cell.<br><font face="consolas">t.setValue(value,rowIndex,columnIndex);
            
            % validate inputs
            if (~isscalar(val) && ~ischar(val)) || iscell(val)
                error('Value must be a scalar or char vector that is not contained in a cell array');
            end
            validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getRowCount});
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            
            % set the cell value
            obj.jtable.setValueAt(val,row-1,column-1); % according to the current view
        end
        
        function setCellBg(obj,val,row,column)
            % Function to set the background of a specific cell.<br><font face="consolas">t.setCellBg(color,rowIndex,columnIndex); % the color value is a RGB triplet or the short or long name of a basic color
           
            % validate inputs
            obj.colorValidation(val,'Color');
            validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getRowCount});
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            
            % convert the value to a java color
            val = obj.rgb2java(obj.char2rgb(val));
            
            % paint the cell foreground
            if ~obj.colorFormat(column)
                obj.columnModel.getColumn(column-1).getCellRenderer.setCellBg(val,row-1,column-1);
                obj.jtable.repaint;
            end
        end

        function setCellFg(obj,val,row,column)
            % Function to set the foreground of a specific cell.<br><font face="consolas">t.setCellFg(color,rowIndex,columnIndex); % the color value is a RGB triplet or the short or long name of a basic color
            
            % validate inputs
            obj.colorValidation(val,'Color');
            validateattributes(row,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getRowCount});
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            
            % convert the value to a java color
            val = obj.rgb2java(obj.char2rgb(val));
            
            % paint the cell background
            if ~obj.colorFormat(column) && ~strcmpi(obj.info.ColumnFormat{column},'logical')
                obj.columnModel.getColumn(column-1).getCellRenderer.setCellFg(val,row-1,column-1);
                obj.jtable.repaint;
            end
        end

        function resetCellBg(obj,column)
            % Function to return to the previous background (for a single column) defined by the <font face="consolas">RowColor</font> or <font face="consolas">ColumnColor</font> properties.<br><font face="consolas">t.resetCellBg(columnIndex)
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            obj.columnModel.getColumn(column-1).getCellRenderer.resetCellBg;
        end
        
        function resetCellFg(obj,column)
            % Function to return to the previous foreground (for a single column) defined by the <font face="consolas">ForegroundColor</font> property.<br><font face="consolas">t.resetCellFg(columnIndex)
            validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
            obj.columnModel.getColumn(column-1).getCellRenderer.resetCellFg;
        end        
        
        function sortColumn(obj,column,direction,varargin)
            % Function to sort the rows of a column.<br><font face="consolas">t.sortColumn(columnIndex,direction) % direction is the char vector 'ascend' or 'descend'
            
            % validate inputs (varargin is used only to denote an internal use of this function, so the validation in that case is not necessary)
            if isempty(varargin)
                validateattributes(column,{'numeric'},{'scalar','integer','>',0,'<=',obj.jtable.getColumnCount});
                direction = validatestring(direction,{'ascend','descend'});
            end
            
            % if function was internally called...
            if isnumeric(direction)
                if direction == 1
                    direction = 'ascend';
                else
                    direction = 'descend';
                end
            end            
           
            previousSelectedRowCount = obj.jtable.getSelectedRowCount;            
            
            % sort column
            sortKeys = obj.sorter.getSortKeys;
            if obj.isDataModified
                obj.unsort;
                obj.sorter.setSortKeys(column-1,direction);
                obj.isDataModified = false;
            elseif sortKeys.isEmpty || column ~= obj.SortedColumn || ...
                    ~strcmpi([direction,'ing'],char(sortKeys.get(0).getSortOrder))
                obj.sorter.setSortKeys(column-1,direction);
            else
                return;
            end            

            % get reordered row indices (according to the underlying model)
            m = obj.jtable.getRowCount;
            sortedInd = zeros(1,m);            
            for i = 1:m
                sortedInd(i) = 1 + obj.jtable.convertRowIndexToModel(i-1);
            end           

            % reorder the row heading names 
            %javaMethodEDT('getModel',obj.rowheader);
            if m < length(obj.rownames)               
                rowheaders = obj.getDataInModel(obj.rowheader.getModel);
                [~,ind] = ismember(obj.rownames,rowheaders);
                rnames = obj.rownames(ind>0);
                obj.rowheader.getModel.setDataVector(rnames(sortedInd),' ');                    
            elseif ~isempty(obj.rownames)
                obj.rowheader.getModel.setDataVector(obj.rownames(sortedInd),' ');
            end
            
            % store the new sort parameters
            obj.RowSortIndices = sortedInd;            
            obj.SortedColumn = column;
            if strcmpi(direction,'ascend')
                obj.SortDirection = 1;
            else%if strcmpi(direction,'descend')
                obj.SortDirection = -1;
            end
            
            % try to restore the previous selection
            % if it wasn't consecutive with respect to the current view, deselect
            if obj.jtable.getSelectedRowCount ~= previousSelectedRowCount
                obj.jtable.clearSelection;
            else
                obj.highlightRowHeaders;
            end
        end

        function unsort(obj)
            % Function to unsort the table.<br><font face="consolas">t.unsort
            
            % verify that there is a sort state, if not return 
            if obj.SortDirection == 0, return; end
            
            % update the parameters
            obj.SortedColumn = 0;
            obj.SortDirection = 0;
            obj.RowSortIndices = [];            
            obj.sorter.setSortKeys([]);

            % restore the row heading names
            %javaMethodEDT('getModel',obj.rowheader);
            if obj.jtable.getRowCount < length(obj.rownames) % ---> some rows were removed              
                rowheaders = obj.getDataInModel(obj.rowheader.getModel);
                [~,ind] = ismember(obj.rownames,rowheaders);
                obj.rowheader.getModel.setDataVector(obj.rownames(ind>0),' ');                    
            else
                obj.RowName = obj.info.RowName;
            end
        end

        function paste(obj,varargin)
            % Function to paste a block of cells (copied from excel, for example) in the table.<br><font face="consolas">t.paste
            
            % get the reference cell from which to start
            row0 = obj.jtable.getSelectedRow;            
            col0 = obj.jtable.getSelectedColumn;
            
            % return if there are no selected cells
            if row0 == -1 || col0 == -1, return; end
            
            obj.stopEditing;
            
            % get the system clipboard content or a value to replicate in each selected cell
            % (this last option is used to delete the cells' contents)
            if isempty(varargin)
                obj.editType = 'ContentsReplacement';
                editData = obj.getclipdata;
            else
                obj.editType = 'ContentsRemoval';
                editData = varargin{:};
            end            

            % define number of rows and columns to edit and resize 'editData' according to this                
            if isscalar(editData)
                numRows = obj.jtable.getSelectedRowCount;
                numCols = obj.jtable.getSelectedColumnCount;
                editData = repmat(editData,numRows,numCols); % replicate in each selected cell the unique value
            else            
                numRows = min(size(editData,1),obj.jtable.getRowCount - row0);
                numCols = min(size(editData,2),obj.jtable.getColumnCount - col0);
                editData = editData(1:numRows,1:numCols);
            end
            
            % if any column in the selection interval is not editable, return                
            colEditable = obj.tableModel.getColumnEditable;
            if any(~colEditable((1+col0:col0+numCols)))
                obj.editType = '';
                return              
            end
            
            % disable default callback
            obj.tableModel.TableChangedCallback = [];
            
%             % this discarded code is to allow a partial edition at intervals 
%             % in which at least the first selected column is editable
%             ind = 1:obj.jtable.getColumnCount;
%             NotEditableInd=ind(~colEditable) - 1; % java index            
%             firstNonColEdit = min(NotEditableInd(NotEditableInd >= col0)); 
%             if ~isempty(firstNonColEdit) && firstNonColEdit >= col0 && firstNonColEdit < col0 + numCols
%                 numCols = firstNonColEdit - col0;
%                 editData = editData(:,1:numCols);
%                 warning(['The edition was interrupted in column index = ',...
%                     num2str(firstNonColEdit + 1),' because this column is not editable.']);
%             end

            % store old data
            oldData = obj.Data;

            % define the indices where to paste the new contents
            editedRows = 1 + row0 : row0 + numRows; % matlab indices
            editedColumns = 1 + col0 : col0 + numCols; % matlab indices               

            % edit in jtable (it could take a few seconds in large tables (> 1000 x 1000 cells))
            if numRows * numCols < 40000 % && numCols > 0
                % reasonable number of edited cells in which double loop is the fastest procedure
                for j = 0:numCols-1                   
                    for i = 0:numRows-1
                        obj.jtable.setValueAt(editData{i+1,j+1}, i + row0, j + col0);
                    end
                end
                obj.isDataModified = true;
                % call user callback function
                obj.callCellEditCallback(editedRows',editedColumns',oldData,editData,obj.editType);                    
            else % re-set the complete data could be faster than double loop in large tables
                % verify that there is no a sort mode, if not return
                if (obj.isSortModeActive('paste'))
                    obj.editType = '';
                    obj.tableModel.TableChangedCallback = @obj.cellEdit; % enable default callback
                    return;
                end
                newData = oldData;
                newData(editedRows,editedColumns) = editData;
                obj.Data = newData;
            end

            % select edited cells
            if numCols > 0
                obj.jtable.setRowSelectionInterval(row0,row0+numRows-1);
                obj.jtable.setColumnSelectionInterval(col0,col0+numCols-1);
                if numRows * numCols >= 40000, obj.highlightRowHeaders; end
            end

            % enable default callback
            obj.tableModel.TableChangedCallback = @obj.cellEdit;                
            
        end        

        function cut(obj)
            % Function to cut the contents of the selected cells in the table.<br><font face="consolas">t.cut
            obj.keyRobot('control','c');
            obj.paste({''});
        end

        function insertRows(obj,direction,varargin)
            % Function to insert rows according to the current selection.<br><font face="consolas">t.insertRows(direction) % where direction is 'above' or 'below'
            
            % validate inputs (varargin is used only to denote an internal use of this function, 
            % so the validation in that case is not necessary)
            if isempty(varargin), direction = validatestring(direction,{'above','below'}); end

            % verify that all columns are editable and at least one cell is selected
            if any(~obj.ColumnEditable) || obj.jtable.getSelectedRow == -1, return; end

            % verify that there is no a sort mode, if not return 
            if (obj.isSortModeActive('insertRows')), return; end
            
            % disable default callback (this works in single cell editions)                
            obj.tableModel.TableChangedCallback = [];
            
            obj.stopEditing;

            % get the reference where begin the insertion
            selectedRows = obj.jtable.getSelectedRows;
            if strcmp(direction,'above')
                ind = selectedRows(1) - 1;
            else%if strcmp('below')
                if length(selectedRows) > 1
                    ind = selectedRows(end);
                else
                    ind = selectedRows;
                end
            end            
            
            % store old data
            oldData = obj.Data;
            
            % add empty rows (in the main table as also in the row headers)
            n = obj.jtable.getColumnCount;
            numAddedRows = length(selectedRows);
            for i =1:numAddedRows
                obj.rowheader.getModel.insertRow(ind+i,cell(1,1));
                obj.tableModel.insertRow(ind+i,cell(1,n));                
            end

            % re-assign the row names if these are numbers, otherwise it is only necessary to store the new empty values
            if ischar(obj.info.RowName) %&& strcmpi(obj.info.RowName,'numbered')
                obj.RowName = 'numbered';
            else
                obj.info.RowName = [obj.info.RowName(1:ind+1);cell(numAddedRows,1);obj.info.RowName(ind+2:end)];
            end

            % select the added rows
            obj.jtable.setColumnSelectionInterval(n-1,0);
            interval = [selectedRows(1),selectedRows(end)];
            if strcmp(direction,'below'), interval = interval + numAddedRows; end
            obj.jtable.setRowSelectionInterval(interval(1),interval(2));
            obj.jtable.scrollRectToVisible(obj.jtable.getCellRect(interval(2),0,true));
            
            % call user's callback function
            obj.callCellEditCallback(selectedRows+1,[],oldData,{},'RowsInsertion')
            
            % enable default callback
            obj.tableModel.TableChangedCallback = @obj.cellEdit;
        end

        function insertColumns(obj,direction,varargin)
            % Function to insert columns according to the current selection.<br><font face="consolas">t.insertColumns(direction) % where direction is 'left' or 'right'
            
            % validate inputs (varargin is used only to denote an internal use of this function, 
            % so the validation in that case is not necessary)
            if isempty(varargin), direction = validatestring(direction,{'left','right'}); end            
            
            % verify that all columns are editable and at least one cell is selected
            if any(~obj.ColumnEditable) || obj.jtable.getSelectedRow == -1, return; end
            
            obj.editType = 'ColumnsInsertion';            

            % store previous sort mode and unsort if required
            %if (obj.isSortModeActive('insertColumns')), return; end            
            sortMode = obj.SortDirection;            
            if sortMode ~= 0
                sortedColumn = obj.SortedColumn;
                sortedData = obj.Data;
                obj.unsort;
            end

            % get the reference where begin the insertion
            selectedCols = obj.jtable.getSelectedColumns;
            if strcmp(direction,'left')
                ind = selectedCols(1) - 1;
            else%if strcmp('right')
                if length(selectedCols) > 1
                    ind = selectedCols(end);
                else
                    ind = selectedCols;
                end
            end
            
            % store previous data
            oldData = obj.Data;
            
            % update property values (in backup) that depend of the number of columns
            numAddedCols = length(selectedCols);
            m = obj.jtable.getRowCount;
            n = obj.jtable.getColumnCount;            
            prop = {'ColumnAlign','ColumnFormat','ColumnFormatData','ColumnToolTip','ColumnWidth'};
            val0 = {'center','',{},'',75};
            for k = 1:length(prop)
                oldValues = obj.info.(prop{k});
%                 % this is to get the vector for all the columns and not a single value
%                 if ~iscell(oldValues), oldValues = repmat({oldValues},1,n); end
                obj.info.(prop{k}) = [oldValues(1:ind+1),repmat(val0(k),1,numAddedCols),oldValues(ind+2:end)];
            end
            if ~ischar(obj.info.ColumnName) % && ~strcmpi(obj.info.ColumnName,'numbered')
                obj.info.ColumnName = [obj.info.ColumnName(1:ind+1),repmat({''},1,numAddedCols),obj.info.ColumnName(ind+2:end)];
            end
            obj.info.ColumnEditable = true(1,n+numAddedCols);
            obj.info.ColumnResizable = [obj.info.ColumnResizable(1:ind+1),true(1,numAddedCols),obj.info.ColumnResizable(ind+2:end)];
            obj.info.ColumnSortable = [obj.info.ColumnSortable(1:ind+1),true(1,numAddedCols),obj.info.ColumnSortable(ind+2:end)];

            % re-assign the data to include the "added columns" (and with it: the renderers, editors, column names, etc.)
            % The methods 'addColumn' and 'moveColumn' aren't used because the column indices in the model don't match with the "view indices" 
            % what could cause a great confusion (the added columns would have the last indices in terms of the model...). In this sense, 
            % the methods 'convertColumnIndexToView' and 'convertColumnIndexToModel' could help. But, the main reason for not using the
            % 'moveColumn' method is because the old column is shifted left or right (randomly?), so we would have to reorder a lot of columns...
            obj.Data = [oldData(:,1:ind+1),cell(m,numAddedCols),oldData(:,ind+2:end)];

            % restore the previous sort mode
            if sortMode ~= 0
                if ind + 2 <= sortedColumn, sortedColumn = sortedColumn + numAddedCols; end
                obj.sortColumn(sortedColumn,sortMode,'InternalUse');
                oldData = sortedData;
            end
            
            % select the added columns
            obj.jtable.setRowSelectionInterval(m-1,0);
            interval = [selectedCols(1),selectedCols(end)];
            if strcmp(direction,'right'), interval = interval + numAddedCols; end
            obj.jtable.setColumnSelectionInterval(interval(1),interval(2));
            obj.jtable.scrollRectToVisible(obj.jtable.getCellRect(0,interval(2),true));
            obj.rowheader.selectAll;
            
            % call user's callback function
            obj.callCellEditCallback([],selectedCols+1,oldData,{},'ColumnsInsertion');
        end

        function deleteRows(obj)            
            % Function to delete the selected rows<br><font face="consolas">t.deleteRows
            
            % verify that all columns are editable and at least one cell is selected
            if any(~obj.ColumnEditable) || obj.jtable.getSelectedRow == -1, return; end

            % disable default callback                
            obj.tableModel.TableChangedCallback = [];
            
            obj.stopEditing;
            
            % get the selected rows (that will be removed)
            selectedRows = obj.jtable.getSelectedRows;
            numDeletedRows = length(selectedRows);
            
            % clear selection (this is to avoid conflicts with the selection listeners)
            obj.jtable.clearSelection;
            
            % store old data
            oldData = obj.Data;

            % delete the selected rows (in the main table as also in the row headers)            
            for i = 1:numDeletedRows
                indice=obj.jtable.convertRowIndexToModel(selectedRows(1));
                obj.tableModel.removeRow(indice);
                obj.rowheader.getModel.removeRow(selectedRows(1));
            end
            
            % all rows were deleted? let an empty one
            if numDeletedRows == size(oldData,1)
                obj.rowheader.getModel.insertRow(0,'1');
                obj.tableModel.insertRow(0,cell(1,obj.jtable.getColumnCount));                
            end

            % update the 'RowSortIndices' if sort mode is active
            if obj.SortedColumn > 0
                m = obj.jtable.getRowCount;
                sortedInd = zeros(1,m);            
                for i = 1:m
                    sortedInd(i) = 1 + obj.jtable.convertRowIndexToModel(i-1);
                end
                obj.RowSortIndices = sortedInd;
            end         
            
            % call user's callback function
            obj.callCellEditCallback(selectedRows+1,[],oldData,{},'RowsDelete');

            % enable default callback
            obj.tableModel.TableChangedCallback = @obj.cellEdit;
        end

        function deleteColumns(obj)
            % Function to delete the selected columns<br><font face="consolas">t.deleteColumns
            
            % verify that all columns are editable and at least one cell is selected
            if any(~obj.ColumnEditable) || obj.jtable.getSelectedRow == -1, return; end
            
            obj.editType = 'ColumnsDelete';
            
            % get the selected columns (that will be "removed")
            selectedCols = obj.jtable.getSelectedColumns;
            numDeletedCols = length(selectedCols);
            
            % store previous sort mode and unsort if required
            %if (obj.isSortModeActive('deleteColumns')), return; end            
            sortMode = obj.SortDirection;           
            if sortMode ~= 0
                sortedColumn = obj.SortedColumn;
                sortedData = obj.Data;
                obj.unsort;
            end
            
            % store previous (unsorted) data
            oldData = obj.Data;

%             for i =1:numDeletedCols
%                 obj.jtable.removeColumn(obj.columnModel.getColumn(selectedCols(1)));                
%             end

            % update values of the properties (in backup) that can vary from column to column            
            n = obj.jtable.getColumnCount;
            prop = {'ColumnAlign','ColumnFormat','ColumnFormatData','ColumnToolTip','ColumnWidth'};
            val0 = {'center','',{},'',75};
            if numDeletedCols < n
                for k = 1:length(prop)
                    oldValues = obj.info.(prop{k});
%                     % this is to get the vector for all the columns and not a single value
%                     if ~iscell(oldValues), oldValues = repmat({oldValues},1,n); end
                    obj.info.(prop{k}) = oldValues([1:selectedCols(1),selectedCols(end)+2:end]);
                end

                if ~ischar(obj.info.ColumnName) % && ~strcmpi(obj.info.ColumnName,'numbered')
                    obj.info.ColumnName = obj.info.ColumnName([1:selectedCols(1),selectedCols(end)+2:end]);
                end
                obj.info.ColumnEditable = true(1,n-numDeletedCols);                
                obj.info.ColumnResizable = obj.info.ColumnResizable([1:selectedCols(1),selectedCols(end)+2:end]);
                obj.info.ColumnSortable = obj.info.ColumnSortable([1:selectedCols(1),selectedCols(end)+2:end]);
                
                updatedData = oldData(:,[1:selectedCols(1),selectedCols(end)+2:end]);                
            else % delete all columns ? Nope, let an empty column
                for k = 1:length(prop)                    
                    obj.info.(prop{k}) = val0{k};
                end
                obj.colorFormat = [];
                obj.info.ColumnName = 'numbered';
                obj.info.ColumnResizable = true;
                obj.info.ColumnSortable = true;
                updatedData = cell(obj.jtable.getRowCount,1);
            end

            % re-assign the data
            obj.Data = updatedData;

            % restore the previous sort mode if it exists provide that the sorted column had not been deleted
            % if not, display the unsorted data
            if sortMode ~= 0
                if ~ismember(sortedColumn,selectedCols+1)
                    if sortedColumn >= selectedCols(end)+1                        
                        sortedColumn = sortedColumn - numDeletedCols;
                    end
                    obj.sortColumn(sortedColumn,sortMode,'InternalUse');
                    oldData = sortedData;
                end
            end
            
            % clear selection
            obj.rowheader.clearSelection;
            
            % call user's callback function
            obj.callCellEditCallback([],selectedCols+1,oldData,{},'ColumnsDelete');
        end        
        
    end
    
    % Deconstructor    
    methods (Static)
        function obj = loadInfo(filename)
            % Function to redraw the table whose properties were stored in the <font face="consolas">filename.mat</font> file through the <font face="consolas">saveInfo</font> function<br><font face="consolas">t2 = olduitable.loadInfo('filename');
            properties = [];
            load(filename,'properties'); % load property values
            obj = olduitable(figure,properties(:)); % redraw table in a new figure
        end
    end

    %% Get/Set methods
    methods
        % ButtonDownFcn ----------------------------------------------------------------------
        function set.ButtonDownFcn(obj,val)
            obj.callbackValidation(val,'ButtonDownFcn');
            obj.ButtonDownFcn = val;            
        end % get method is not necessary for callbacks properties because these aren't 'Dependent'
        
        % CellEditCallback -------------------------------------------------------------------
        function set.CellEditCallback(obj,val) 
            obj.callbackValidation(val,'CellEditCallback');
            obj.CellEditCallback = val;            
        end
        
        % CellSelectionCallback -------------------------------------------------------------------
        function set.CellSelectionCallback(obj,val)
            obj.callbackValidation(val,'CellSelectionCallback');
            obj.CellSelectionCallback = val;
        end
        
        % ColumnAlign -------------------------------------------------------------------
        function val = get.ColumnAlign(obj)
            val = obj.info.ColumnAlign;
        end % get.ColumnAlign
        
        function set.ColumnAlign(obj,val)
            % validate input (if table is being built the validation already was done)
            if ~obj.inConstruction
                obj.columnalignValidation(val,'ColumnAlign');
                val = obj.resize2columncount(obj.jtable.getColumnCount,'center',val);
                %[colalign,obj.info.ColumnAlign] = obj.resize2columncount(obj.jtable.getColumnCount,'center',val);
            end
            
            % modify renderer to include the new value
            obj.modifyRenderer('setHorizontalAlignment',val);
            
            % store value in backup
            obj.info.ColumnAlign = val;
        end % set.ColumnAlign      
        
        % ColumnColor -------------------------------------------------------------------
        function val = get.ColumnColor(obj)
            val = obj.info.ColumnColor;
        end % get.ColumnColor
        
        function set.ColumnColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.rgbValidation(val,'ColumnColor'); end
            
            % modify renderer to include the new value
            colcolors = single(val);
            if strcmpi(obj.info.ColumnStriping,'off') && strcmpi(obj.info.RowStriping,'off')
                obj.modifyRenderer('setColumnStriping',false);
            elseif strcmpi(obj.info.ColumnStriping,'on')
                obj.modifyRenderer('setColumnColor',colcolors);
            end
            
            % store value in backup
            obj.info.ColumnColor = val;
        end % set.ColumnColor
        
        % ColumnEditable -------------------------------------------------------------------
        function val = get.ColumnEditable(obj)
            val = obj.info.ColumnEditable;
            if ~islogical(val), val = logical(val); end
        end % get.ColumnEditable
        
        function set.ColumnEditable(obj,val)
            % validate input
            if ~obj.inConstruction
                obj.binaryValidation(val,'ColumnEditable');
                if isscalar(obj.uniqueValue(val))
                    val = repmat(val(1),1,obj.jtable.getColumnCount);
                else
                    val = obj.resizelogical2columns(obj.jtable.getColumnCount,false,val);
                end
                %[coleditable,obj.info.ColumnEditable] = obj.resizelogical2columns(n,false,val);
            end
            
            % assign the column editable property value
            for j = 1:obj.jtable.getColumnCount
                obj.tableModel.setColumnEditable(j-1,val(j));
            end

            % enable/disable items of the default context menu if it is assigned
            if strcmpi(obj.UIContextMenu,'auto')
                items = obj.defaultContextMenu.getComponents;
                if all(logical(val))
                    for i = 1:length(items), items(i).setEnabled(true); end
                else
                    for i = 5:length(items), items(i).setEnabled(false); end
                end
            end
            
            % store value in backup
            obj.info.ColumnEditable = val;            
        end % set.ColumnEditable
        
        % ColumnFormat -------------------------------------------------------------------
        function val = get.ColumnFormat(obj)
            val = obj.info.ColumnFormat;
        end % get.ColumnFormat
        
        function set.ColumnFormat(obj,val)
            % validate input
            n = obj.jtable.getColumnCount;
            if ~obj.inConstruction
                obj.columnformatValidation(val,'ColumnFormat');
                val = obj.resize2columncount(n,'',val);
                %[colformat,obj.info.ColumnFormat] = obj.resize2columncount(n,'',val);
            end            
            columnformat = val;
            
            % reset colorFormat parameter
            obj.colorFormat = false(1,n);            
            
            % retrive property values if required (in case that column renderer is not suitable for the assigned format)
            colalign = obj.info.ColumnAlign;
            colformatdata = obj.info.ColumnFormatData;
            data = obj.Data;
            args = {strcmpi(obj.info.RowStriping,'on'),strcmpi(obj.info.ColumnStriping,'on'),...
                single(obj.info.RowColor),single(obj.info.ColumnColor),...
                obj.rgb2java(obj.char2rgb(obj.info.SelectionBackground)),...                
                obj.rgb2java(obj.char2rgb(obj.info.SelectionBorderColor)),...
                obj.rgb2java(obj.char2rgb(obj.info.SelectionForeground))};
            
            % loop in all columns
            for j = 1:n
                column = obj.columnModel.getColumn(j-1);
                cr = column.getCellRenderer;
                if strcmpi(columnformat{j},'color')
                    obj.colorFormat(j) = true;
                    if isa(cr,'asd.fgh.olduitable.ColorCellRenderer'), continue; end                    
                    if isempty(obj.colorEditor.cellbutton), loadColorPicker(obj); end
                    column.setCellEditor(asd.fgh.olduitable.ColorCellEditor(obj.colorEditor.cellbutton));
                    column.setCellRenderer(asd.fgh.olduitable.ColorCellRenderer);
                elseif strcmpi(columnformat{j},'logical')
                    if ~isa(cr,'asd.fgh.olduitable.CheckBoxRenderer')
                        column.setCellRenderer(asd.fgh.olduitable.CheckBoxRenderer(args{1:end-1}));
                    end
                    column.setCellEditor(javax.swing.DefaultCellEditor(asd.fgh.olduitable.CheckBoxRenderer));
                else
                    % verify renderer's assignment
                    if ~isa(cr,'asd.fgh.olduitable.CellRenderer')
                        cr = asd.fgh.olduitable.CellRenderer(args{:});
                        cr.setHorizontalAlignment(colalign{j});
                    end
                    
                    % verify editor's assignment
                    if strcmpi(columnformat{j},'longchar')
                        if ~isa(column.getCellEditor,'asd.fgh.olduitable.LongTextCellEditor')
                            if isempty(obj.longcharEditor.cellbutton), loadTextArea(obj); end
                            column.setCellEditor(asd.fgh.olduitable.LongTextCellEditor(obj.longcharEditor.cellbutton));
                        end
                    elseif strcmpi(columnformat{j},'popup')
                        if isempty(colformatdata{j})
                            if iscellstr(data(:,j))
                                colformatdata{j} = data(:,j);
                            elseif all(cellfun(@(x)isnumeric(x) || ischar(x),data(:,j)))
                                colformatdata{j} = cellfun(@num2str,data(:,j),'UniformOutput',false);
                            end
                            obj.info.ColumnFormatData{j} = colformatdata{j};
                        end
                        obj.assignPopupList(j,colformatdata{j});
                    else
                        if strcmpi(columnformat{j},'bank')
                            columnformat{j} = '%.2f';
                        elseif strcmpi(columnformat{j},'char')
                            columnformat{j} = '%s';
                        end
                        cr.setColumnFormat(columnformat{j});
                        column.setCellEditor(asd.fgh.olduitable.CellEditor(colalign{j}));
                    end
                    
                    % update the renderer
                    column.setCellRenderer(cr);
                end                
            end
            
            % repaint the table to include the changes
            obj.jtable.repaint;
            
            % store value in backup
            obj.info.ColumnFormat = val;
        end % set.ColumnFormat
        
        % ColumnFormatData -------------------------------------------------------------------
        function val = get.ColumnFormatData(obj)
            val = obj.info.ColumnFormatData;
        end % get.ColumnFormat
        
        % ColumnFormatData -------------------------------------------------------------------
        function set.ColumnFormatData(obj,val)
            % validate input
            n = obj.jtable.getColumnCount;
            if ~obj.inConstruction
                obj.colformatdataValidation(val,'ColumnFormatData');
                val = obj.resize2columncount(n,{},val);
            end            
            
            % assign the popup list (if ColumnFormat corresponds to 'popup')
            ind = 1:n;
            ind = ind(~cellfun(@isempty,val));
            columnformat = obj.info.ColumnFormat;
            for j = ind
                if strcmpi(columnformat{j},'popup')
                    %if ~isequal(sort(obj.info.ColumnFormatData{j}),sort(val{j}))
                    obj.assignPopupList(j,val{j});
                    %end
                else
                    warning('%s\n',['The format of the column in the index = ',num2str(j),' is not equal to ''popup''.'],...
                        'Change the ''Columnformat'' for this column so that ''ColumnFormatData'' takes effect.');
                end
            end
            
            % store value in backup
            obj.info.ColumnFormatData = val;
        end % get.ColumnFormat
        
        
        % ColumnName -------------------------------------------------------------------
        function val = get.ColumnName(obj)
            val = obj.info.ColumnName;
        end % get.ColumnName
        
        function set.ColumnName(obj,val)
            % validate input
            if ~obj.inConstruction, obj.headerNamesValidation(val,'ColumnName'); end
            if ~ischar(val) && iscolumn(val), val = val'; end
            
            n = obj.jtable.getColumnCount;
            d = obj.columnHeader.getPreferredSize;
            
            % assign the new column headers
            if isempty(val)
                d.height = 0;
            else                
                newlines = 0;                
                if ischar(val) %&& strcmpi(val,'numbered')
                    colnames = obj.num2cellstr(1:n);
                    for j = 1:n                        
                        obj.columnModel.getColumn(j-1).setHeaderValue(colnames{j}); %num2str(j)                     
                    end
                else
                    val = obj.resize2columncount(n,'',val);
                    colnames = val;
                    
                    % define a multiline column name if the vertical slash (|) is included
                    %ind = cellfun(@(x)~isempty(x),strfind(lower(colnames),'|'));
                    %colnames = cellfun(@(x)strrep(x,'|','<br>'),colnames,'UniformOutput',false);                    
                    for j = 1:n                        
                        ind = strfind(colnames{j},'|');
                        if ~isempty(ind)
                            colnames{j} = ['<html><center>',strrep(colnames{j},'|','<br>')];
                            newlines = max(newlines,length(ind));
%                         else
%                             ind = strfind(lower(colnames{j}),'<br');
%                             newlines = max(newlines,length(ind));
                        end
                        obj.columnModel.getColumn(j-1).setHeaderValue(colnames{j});
                    end                   
                    newlines = max(newlines);
                    %newlines = max(cellfun(@length,strfind(lower(colnames),'<br'))); % if is used <br/> or <br /> instead <br>
                end
                
                % update the column header's height according to the line count
                if newlines == 0
                    d.height = 24;
                else
                    %d.height = 1.2*obj.fontMetrics.getHeight*(1+newlines); % line-height~1.2xfontHeight
                    d.height = 1.2*16*(1+newlines);
                end                
            end
            
            % change the column header's height if necessary
            if ~isequal(d.height,obj.theaderHeight)
                obj.theaderHeight = d.height;
                obj.columnHeader.getParent.setPreferredSize(d);
                obj.columnHeader.revalidate;
            end
            
            % update current view
            obj.columnHeader.repaint;
            
            % store new value in backup
            obj.info.ColumnName = val;
        end % set.ColumnName
        
        % ColumnResizable -------------------------------------------------------------------
        function val = get.ColumnResizable(obj)
            val = obj.info.ColumnResizable;
            if ~islogical(val), val = logical(val); end
        end % get.ColumnResizable
        
        function set.ColumnResizable(obj,val)
            % validate input
            if ~obj.inConstruction
                obj.binaryValidation(val,'ColumnResizable');
                val = obj.resizelogical2columns(obj.jtable.getColumnCount,true,val);
                %[colresizable,obj.info.ColumnResizable] = obj.resizelogical2columns(obj.jtable.getColumnCount,true,val);
            end
            
            % assign the new value
            for j = 1:obj.jtable.getColumnCount
                column = obj.columnModel.getColumn(j-1);
                column.setResizable(val(j));
            end
            
            % store new value in backup
            obj.info.ColumnResizable = val;
        end % set.ColumnResizable
        
        % ColumnSortable -------------------------------------------------------------------
        function val = get.ColumnSortable(obj)
            val = obj.info.ColumnSortable;
            if ~islogical(val), val = logical(val); end
        end % get.ColumnSortable
        
        function set.ColumnSortable(obj,val)
            % validate input and store in backup
            if ~obj.inConstruction
                obj.binaryValidation(val,'ColumnSortable');
                obj.info.ColumnSortable = obj.resizelogical2columns(obj.jtable.getColumnCount,true,val);
                %[colsortable,obj.info.ColumnSortable] = obj.resizelogical2columns(obj.jtable.getColumnCount,true,val);
            end
        end % set.ColumnSortable
        
        % ColumnStriping -------------------------------------------------------------------
        function val = get.ColumnStriping(obj)
            val = obj.info.ColumnStriping;
        end % get.ColumnStriping
        
        function set.ColumnStriping(obj,val)
            % validate input
            if ~obj.inConstruction, obj.onoffValidation(val,'ColumnStriping'); end
            
            % store value in backup
            obj.info.ColumnStriping = val;
            
            % modify renderer to include the new value
            obj.modifyRenderer('setColumnStriping',strcmpi(val,'on'));
            
            % reassign the 'ColumnColor' property (really, it's only necessary if value is 'on')
            if ~obj.inConstruction, obj.ColumnColor = obj.info.ColumnColor; end
        end % set.ColumnStriping
        
        % ColumnToolTip -------------------------------------------------------------------
        function val = get.ColumnToolTip(obj)
            val = obj.info.ColumnToolTip;
        end % get.ColumnToolTip
        
        function set.ColumnToolTip(obj,val)
            % validate input
            if ~obj.inConstruction
                obj.tooltipsValidation(val,'ColumnToolTip');
                val = obj.resize2columncount(obj.jtable.getColumnCount,'',val);
            end
            
            % define a multiline column tooltip if the vertical slash (|) is included
            for j = 1:obj.jtable.getColumnCount
                ind = strfind(val{j},'|');
                if ~isempty(ind)
                    val{j} = ['<html>',strrep(val{j},'|','<br>')];
                end 
            end
            
            % update the column tooltips
            obj.columnHeader.setColumnToolTips(val);
            
            % store value in backup
            obj.info.ColumnToolTip = val;            
        end % set.ColumnStriping
        
        % ColumnWidth -------------------------------------------------------------------
        function val = get.ColumnWidth(obj)
            if obj.jtable.getAutoResizeMode == 0
                val = obj.info.ColumnWidth;
            else%if obj.jtable.getAutoResizeMode == 4 % ('AUTO_RESIZE_ALL_COLUMNS')
                val = cell(1,obj.jtable.getColumnCount);                
                for j = 1:obj.jtable.getColumnCount
                    column = obj.columnModel.getColumn(j-1);
                    val{j}=column.getWidth;
                end
            end
            %val = obj.uniqueValue(val); % display the unique value if it exists and not the cell array
        end % get.ColumnWidth
        
        function set.ColumnWidth(obj,val)
            % validate input
            if ~obj.inConstruction
                obj.columnwidthValidation(val,'ColumnWidth');
                val = obj.resize2columncount(obj.jtable.getColumnCount,75,val);
                %[colwidth,obj.info.ColumnWidth] = obj.resize2columncount(obj.jtable.getColumnCount,75,val);
            end
            
            % assign column widths
            obj.jtable.setAutoResizeMode(javax.swing.JTable.AUTO_RESIZE_OFF);
            for j = 1:obj.jtable.getColumnCount
                column = obj.columnModel.getColumn(j-1);
                column.setPreferredWidth(val{j});
            end
            
            % store value in backup
            obj.info.ColumnWidth = val;
        end % set.ColumnWidth
        
        % Data -------------------------------------------------------------------
        function val = get.Data(obj)
            val = obj.getDataInModel(obj.tableModel);
            if ~isempty(obj.RowSortIndices), val = val(obj.RowSortIndices,:); end
        end % get.Data
        
        function set.Data(obj,val)
            % validate input
            if ~obj.inConstruction, obj.dataValidation(val,'Data'); end            
            
            % convert value to a cell array
            if isnumeric(val) || islogical(val), val = num2cell(val); end

            % reset the sort status
            obj.SortDirection = 0;
            obj.SortedColumn = 0;
            obj.RowSortIndices = [];
            
            % disable 'TableChangedCallback'
            obj.tableModel.TableChangedCallback = [];
            
            % set the new data in the table and update the row header
            m = size(val,1);
            n = size(val,2);
            if n ~= obj.jtable.getColumnCount, obj.tableModel.resizeEditableArray(n); end
            obj.tableModel.setDataVector(val,repmat({' '},1,n)); drawnow;
            if m ~= obj.rowheader.getRowCount, obj.rowheader.getModel.setRowCount(m); end; drawnow
            
            % reassign comparators for the sorter
            obj.sorter.setComparators;

            % update properties that can depend of the table size (really, if we use
            % 'setRowCount' + 'setValueAt' methods and the column count doesn't change,
            % the custom renderers and editors (in columns) won't be deleted, but 'setDataVector'
            % is a more direct and often faster method, even with these reassignments, so ....)
            if ~obj.inConstruction
                if m ~= length(obj.rownames), obj.RowName = obj.info.RowName; end
                obj.ColumnName = obj.info.ColumnName;
                reAssignRenderers_Editors(obj);
                obj.ColumnEditable = obj.info.ColumnEditable;                
                obj.ColumnResizable = obj.info.ColumnResizable;
                obj.ColumnSortable = obj.info.ColumnSortable;
                obj.ColumnToolTip = obj.info.ColumnToolTip;
                obj.ColumnWidth = obj.info.ColumnWidth;
                
                % check if method wasn't called from another (such as insertColumns, deleteColumns, etc.)
                if isempty(obj.editType)
                    obj.rememberSelection; % restore previous selection                    
                else
                    obj.editType = '';
                end
            end

            % enable 'TableChangedCallback'           
            obj.tableModel.TableChangedCallback = @obj.cellEdit;
        end % set.Data
        
        % Enable -------------------------------------------------------------------
        function val = get.Enable(obj)
            val = obj.info.Enable;
        end % get.Enable
        
        function set.Enable(obj,val)
            % validate input
            if ~obj.inConstruction, obj.onoffValidation(val,'Enable'); end
            flag = strcmpi(val,'on');
            
            % enable or disable the java components
            obj.stopEditing;
            obj.jtable.setEnabled(flag);
            obj.rowheader.setEnabled(flag);
            obj.columnHeader.setEnabled(flag);
            obj.jscrollpane.getVerticalScrollBar.setEnabled(flag);
            obj.jscrollpane.getHorizontalScrollBar.setEnabled(flag);
            
            % enable or disable the 'ColumnToolTip' and 'UIContextMenu' properties
            if flag               
                if ~obj.inConstruction
                    obj.ColumnToolTip = obj.info.ColumnToolTip;
                    obj.UIContextMenu = obj.info.UIContextMenu;
                end
            else
                obj.columnHeader.setColumnToolTips({});
                obj.jtable.setComponentPopupMenu([]);                
            end
            
            % store value in backup
            obj.info.Enable = val;
        end % set.Enable
        
        % FontName -------------------------------------------------------------------
        function val = get.FontName(obj)
            % val = obj.info.FontName;
            val = char(obj.jtable.getFont.getFontName);
        end % get.FontName
        
        function set.FontName(obj,val)
            % validate input
            if ~obj.inConstruction, obj.fontnameValidation(val,'FontName'); end
            
            % get the currrent font in jtable and update value
            font = obj.jtable.getFont;
            font = java.awt.Font(val,font.getStyle,font.getSize);
            
            % set value in the body
            obj.jtable.setFont(font);
            %obj.rowheader.setFont(font);

            % store value in backup
            obj.info.FontName = val;
            
            % update rowheight if the 'auto' value is assigned
            obj.fontMetrics = java.awt.Canvas().getFontMetrics(font);
            if ischar(obj.info.RowHeight), obj.RowHeight = obj.info.RowHeight; end            
        end % set.FontName
        
        % FontSize -------------------------------------------------------------------
        function val = get.FontSize(obj)
            val = obj.info.FontSize;
        end % get.FontSize
        
        function set.FontSize(obj,val)
            % validate input
            if ~obj.inConstruction, obj.fontsizeValidation(val,'FontSize'); end
            val = round(val); % round val to the nearest integer
            
            % get the currrent font in jtable and update value
            font = obj.jtable.getFont;
            font = java.awt.Font(font.getName,font.getStyle,val);
            
            % set value in the body
            obj.jtable.setFont(font);
            %obj.rowheader.setFont(font);            
            
            % store value in backup
            obj.info.FontSize = val;
            
            % update rowheight if the 'auto' value is assigned
            obj.fontMetrics = java.awt.Canvas().getFontMetrics(font);
            if ischar(obj.info.RowHeight), obj.RowHeight = obj.info.RowHeight; end            
        end % set.FontSize
        
        % FontStyle -------------------------------------------------------------------
        function val = get.FontStyle(obj)
            val = obj.info.FontStyle;
            if isnumeric(val)
                if val == 0
                    val = 'normal';
                elseif val == 1
                    val = 'bold';
                elseif val == 2
                    val = 'italic';
                else%if val == 3
                    val = 'bold italic';
                end            
            end
        end % get.FontStyle
        
        function set.FontStyle(obj,val)
            % validate input
            if ~obj.inConstruction, obj.fontstyleValidation(val,'FontStyle'); end
            if ischar(val)
                if strcmpi(val,'normal')
                    val = 0;
                elseif strcmpi(val,'bold')
                    val = 1;
                elseif strcmpi(val,'italic')
                    val = 2;
                else%if strcmpi(val,'bold italic')
                    val = 3;% java.awt.Font.BOLD + java.awt.Font.ITALIC
                end
            end
            
            % get the currrent font in jtable and update value
            font = obj.jtable.getFont;
            font = java.awt.Font(font.getName,val,font.getSize);
            
            % set value in the body
            obj.jtable.setFont(font);
            %obj.rowheader.setFont(font);
            
            % store value in backup
            obj.info.FontStyle = val;           
        end % set.FontStyle
        
        % ForegroundColor -------------------------------------------------------------------
        function val = get.ForegroundColor(obj)
            val = obj.info.ForegroundColor;
        end % get.ForegroundColor
        
        function set.ForegroundColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'ForegroundColor'); end
            rgbColor = obj.char2rgb(val);
            
            % assign value in the table
            obj.jtable.setForeground(obj.rgb2java(rgbColor));            
            
            % store value in backup
            obj.info.ForegroundColor = rgbColor;
        end % set.ForegroundColor
        
        % GridColor -------------------------------------------------------------------
        function val = get.GridColor(obj)
            val = obj.info.GridColor;
        end % get.GridColor
        
        function set.GridColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'GridColor'); end
            rgbColor = obj.char2rgb(val);
            
            % assign value in the table
            obj.jtable.setGridColor(obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.GridColor = rgbColor;
        end % set.GridColor
        
        % HeaderBackground -------------------------------------------------------------------
        function val = get.HeaderBackground(obj)
            val = obj.info.HeaderBackground;
        end % get.HeaderBackground
        
        function set.HeaderBackground(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'HeaderBackground'); end
            rgbColor = obj.char2rgb(val);
            javaColor = obj.rgb2java(rgbColor);
            
            % modify headers' renderers and corner background
            obj.modifyHeadersRenderer('setBackgroundColor',javaColor);
            obj.corner.setBackground(javaColor);
            
            % store value in backup
            obj.info.HeaderBackground = rgbColor;
        end % set.HeaderBackground
        
        % HeaderForeground -------------------------------------------------------------------
        function val = get.HeaderForeground(obj)
            val = obj.info.HeaderForeground;
        end % get.HeaderForeground
        
        function set.HeaderForeground(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'HeaderForeground'); end
            rgbColor = obj.char2rgb(val);
            
            % modify headers' renderers to include the new value
            obj.modifyHeadersRenderer('setForegroundColor',obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.HeaderForeground = rgbColor;
        end % set.HeaderForeground
        
        % HeaderGridColor -------------------------------------------------------------------
        function val = get.HeaderGridColor(obj)
            val = obj.info.HeaderGridColor;
        end % get.HeaderGridColor
        
        function set.HeaderGridColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'HeaderGridColor'); end
            rgbColor = obj.char2rgb(val);
            javaColor = obj.rgb2java(rgbColor);
            
            % set value for the row headers
            obj.rowheader.setGridColor(javaColor);
            
            % set value for the column headers
            columnheaderRenderer = obj.columnHeader.getDefaultRenderer;
            columnheaderRenderer.setGridColor(javaColor);
            obj.columnHeader.setDefaultRenderer(columnheaderRenderer);
            obj.columnHeader.repaint;
            
            % set value for the corner
            border = javax.swing.border.CompoundBorder(...
                javax.swing.border.MatteBorder(0,0,1,1,javaColor),javax.swing.border.EmptyBorder(0,0,-1,2));
            obj.corner.setBorder(border);
            
            % store value in backup
            obj.info.HeaderGridColor = rgbColor; 
        end % set.HeaderGridColor
        
        % HeaderSelectionBg -------------------------------------------------------------------
        function val = get.HeaderSelectionBg(obj)
            val = obj.info.HeaderSelectionBg;
        end % get.HeaderSelectionBg
        
        function set.HeaderSelectionBg(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'HeaderSelectionBg'); end
            rgbColor = obj.char2rgb(val);
            javaColor = obj.rgb2java(rgbColor);
            
            % modify headers' renderers and corner to include the new value
            obj.modifyHeadersRenderer('setSelectionBgcolor',javaColor);
            obj.corner.setForeground(javaColor);
            
            % store value in backup
            obj.info.HeaderSelectionBg = rgbColor;
        end % set.HeaderSelectionBg
        
        % HeaderSelectionFg -------------------------------------------------------------------
        function val = get.HeaderSelectionFg(obj)
            val = obj.info.HeaderSelectionFg;
        end % get.HeaderSelectionFg
        
        function set.HeaderSelectionFg(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'HeaderSelectionFg'); end
            rgbColor = obj.char2rgb(val);
            
            % modify headers' renderers to include the new value
            obj.modifyHeadersRenderer('setSelectionFgcolor',obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.HeaderSelectionFg = rgbColor;
        end % set.HeaderSelectionFg
        
        % KeyPressFcn -------------------------------------------------------------------
        function set.KeyPressFcn(obj,val)
            obj.callbackValidation(val,'KeyPressFcn');
            obj.KeyPressFcn = val;
        end
        
        % KeyReleaseFcn -------------------------------------------------------------------
        function set.KeyReleaseFcn(obj,val)
            obj.callbackValidation(val,'KeyReleaseFcn');
            obj.KeyReleaseFcn = val;
        end
        
        % Parent -------------------------------------------------------------------
        function val = get.Parent(obj)
            val = obj.cont.Parent;
        end % get.Parent
        
        function set.Parent(obj,val)
            if ~obj.inConstruction, obj.parentValidation(val,'Parent'); end
            obj.cont.Parent = val;
        end % set.Parent
        
        % Position -------------------------------------------------------------------
        function val = get.Position(obj)
            val = obj.cont.Position;
        end % get.Position
        
        function set.Position(obj,val)            
            if ~obj.inConstruction, obj.positionValidation(val,'Position'); end            
            obj.cont.Position = val;
            obj.info.Position = val;
        end % set.Position
        
        % RowColor -------------------------------------------------------------------
        function val = get.RowColor(obj)
            val = obj.info.RowColor;
        end % get.RowColor
        
        function set.RowColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.rgbValidation(val,'RowColor'); end
            rowcolors = single(val);
            
            % modify renderer to include the new value
            if strcmpi(obj.info.RowStriping,'on')
                obj.modifyRenderer('setRowColor',rowcolors);
            else
                if ~isequal(rowcolors(1,:),[1 1 1])
                    obj.modifyRenderer('setRowColor',rowcolors(1,:));
                end
            end
            
            % store value in backup
            obj.info.RowColor = val;
        end % set.RowColor
        
        % RowHeight -------------------------------------------------------------------
        function val = get.RowHeight(obj)
            val = obj.info.RowHeight;
        end % get.RowHeight
        
        function set.RowHeight(obj,val)
            % validate input
            if ~obj.inConstruction, obj.rowheightValidation(val,'RowHeight'); end
            
            % define row height and round to the nearest integer
            if strcmpi(val,'auto')
                %rowHeight = round(obj.info.FontSize*20/12);
                rowHeight = round(1.25*obj.fontMetrics.getHeight);
            else
                val = round(val);
                rowHeight = val;
            end
            
            % assign value in main table and row headers
            obj.jtable.setRowHeight(rowHeight);
            obj.rowheader.setRowHeight(rowHeight);
            
            % store value in backup
            obj.info.RowHeight = val;
        end % set.RowHeight
        
        % RowName -------------------------------------------------------------------
        function val = get.RowName(obj)            
            if ~isempty(obj.rownames) && (obj.SortDirection ~= 0 || obj.jtable.getRowCount < length(obj.rownames))
                val = obj.getDataInModel(obj.rowheader.getModel);                    
            else
                val = obj.info.RowName;
            end
        end % get.RowName
        
        function set.RowName(obj,val)
            % validate input
            if ~obj.inConstruction, obj.headerNamesValidation(val,'RowName'); end
            m = obj.jtable.getRowCount;    
            if ~ischar(val) && isrow(val), val = val'; end
            
            % define row headers and their widths
            if isempty(val)
                obj.rownames = {};
                rnames = repmat({''},m,1);
                width = 0;
            else
                if ischar(val) && strcmpi(val,'numbered')
                    rnames = obj.num2cellstr(1:m)';
                    % define the width that fits the content of the row header (this implies getting the string width of the largest number)
                    width = 10 + javax.swing.SwingUtilities.computeStringWidth(obj.fontMetricsRowHeader,rnames{m});
                else
                    val = obj.resize2columncount(m,'',val')';
                    rnames = val;
                    width = max(15,10 + max(cellfun(@(x)javax.swing.SwingUtilities.computeStringWidth(obj.fontMetricsRowHeader,x),rnames)));
                end
                obj.rownames = rnames; % store values shown on the screen             
            end
            
            % assign row headers
            obj.rowheader.getModel.setDataVector(rnames,' ');
            
            % assign row header width
            if ~isequal(width,obj.rheaderWidth)
                obj.rheaderWidth = width;
                d2 = obj.rowheader.getPreferredSize;
                d2.width = width;
                obj.rowheader.setPreferredScrollableViewportSize(d2);
            end
            
            % update view
            obj.rowheader.getModel.fireTableDataChanged;
            obj.highlightRowHeaders;
            
            % store value in backup
            obj.info.RowName = val;
        end % set.RowName
        
        % RowStriping -------------------------------------------------------------------
        function val = get.RowStriping(obj)
            val = obj.info.RowStriping;
        end % get.RowStriping
        
        function set.RowStriping(obj,val)
            % validate input
            if ~obj.inConstruction, obj.onoffValidation(val,'RowStriping'); end
            
            % store value in backup
            obj.info.RowStriping = val;
            
            % modify renderer to include the new value
            obj.modifyRenderer('setRowStriping',strcmpi(val,'on'));
            
            % re-assign the row colors if required
            if ~obj.inConstruction
                if strcmpi(val,'on'), obj.RowColor = obj.info.RowColor; end                
            end
        end % set.RowStriping
        
        % SelectionBackground -------------------------------------------------------------------
        function val = get.SelectionBackground(obj)
            val = obj.info.SelectionBackground;
        end % get.SelectionBackground
        
        function set.SelectionBackground(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'SelectionBackground'); end
            rgbColor = obj.char2rgb(val);
            
            % modify renderer to include the new value
            obj.modifyRenderer('setSelectionBgColor',obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.SelectionBackground = rgbColor;
        end % set.SelectionBackground
        
        % SelectionForeground -------------------------------------------------------------------
        function val = get.SelectionForeground(obj)
            val = obj.info.SelectionForeground;
        end % get.SelectionForeground
        
        function set.SelectionForeground(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'SelectionForeground'); end
            rgbColor = obj.char2rgb(val);
            
            % modify renderer to include the new value
            obj.modifyRenderer('setSelectionFgColor',obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.SelectionForeground = rgbColor;
        end % set.SelectionForeground
        
        % SelectionBorderColor -------------------------------------------------------------------
        function val = get.SelectionBorderColor(obj)
            val = obj.info.SelectionBorderColor;
        end % get.SelectionBorderColor
        
        function set.SelectionBorderColor(obj,val)
            % validate input
            if ~obj.inConstruction, obj.colorValidation(val,'SelectionBorderColor'); end
            rgbColor = obj.char2rgb(val);
            
            % modify renderer to include the new value
            obj.modifyRenderer('setSelectionBorderColor',obj.rgb2java(rgbColor));
            
            % store value in backup
            obj.info.SelectionBorderColor = rgbColor;
        end % set.SelectionBorderColor
        
        % Tag -------------------------------------------------------------------
        function val = get.Tag(obj)
            val = obj.cont.Tag;
        end % get.Tag
        
        function set.Tag(obj,val)
            if ~obj.inConstruction, obj.tagValidation(val,'Visible'); end
            obj.cont.Tag = val;
            obj.info.Tag = val;
        end % set.Tag
        
        % UIContextMenu -------------------------------------------------------------------
        function val = get.UIContextMenu(obj)
            val = obj.info.UIContextMenu;
        end % get.UIContextMenu
        
        function set.UIContextMenu(obj,val)
            % validate input
            if ~obj.inConstruction, obj.jpopupValidation(val,'UIContextMenu'); end
            
            % assign context menu
            if ischar(val) && strcmpi(val,'auto')
                if isempty(obj.defaultContextMenu), loadDefaultContextMenu(obj); end
                obj.jtable.setComponentPopupMenu(obj.defaultContextMenu);
            else
                obj.jtable.setComponentPopupMenu(val);
            end
            
            % store value in backup
            obj.info.UIContextMenu = val;
        end % set.UIContextMenu
        
        % Units -------------------------------------------------------------------
        function val = get.Units(obj)
            val = obj.cont.Units;
        end % get.Units
        
        function set.Units(obj,val)
            if ~obj.inConstruction, obj.unitsValidation(val,'Units'); end
            obj.cont.Units = val;
            obj.info.Units = val;
            obj.info.Position = obj.cont.Position; % update position according to new units
        end % set.Units
        
        % UserData -------------------------------------------------------------------
        function val = get.UserData(obj)
            val = obj.cont.UserData;
        end % get.UserData
        
        function set.UserData(obj,val)            
            obj.cont.UserData = val;
        end % set.UserData
        
        % Visible -------------------------------------------------------------------
        function val = get.Visible(obj)
            val = obj.cont.Visible;
        end % get.Visible
        
        function set.Visible(obj,val)
            if ~obj.inConstruction, obj.onoffValidation(val,'Visible'); end
            obj.cont.Visible = val;
            obj.info.Visible = val;
        end % set.Visible
    end
    
    % utility functions to facilitate the update of the renderers
    methods (Access = private, Hidden)        
        % this function modifies the renderers according to the new user assignments 
        function modifyRenderer(obj,method,value)
            % exclude the columns with a 'color' format (these have a non-editable renderer)
            ind = 1:obj.jtable.getColumnCount;
            if ~isempty(obj.colorFormat), ind = ind(~obj.colorFormat); end
            columnFormat = obj.info.ColumnFormat;
            
            % loop in the columns with a customizable renderer            
            for j = ind
                % verify renderer and validity of method
                column = obj.columnModel.getColumn(j-1);
                cr = column.getCellRenderer;
                if strcmp(columnFormat{j},'logical')
                    if ismember(method,{'setHorizontalAlignment','setSelectionFgColor'})
                        continue; % these properties don't apply for the 'logical' format
                    elseif ~isa(cr,'asd.fgh.olduitable.CheckBoxRenderer')
                        cr = asd.fgh.olduitable.CheckBoxRenderer;
                    end
                elseif isempty(cr) % assign a renderer if the column doesn't have                    
                    cr = asd.fgh.olduitable.CellRenderer;                 
                end
                
                % modify renderer
                if ~iscell(value) % is the value the same for all columns?
                    cr.(method)(value);
                else
                    cr.(method)(value{j});
                end
                
                % assign modified renderer
                column.setCellRenderer(cr);
            end
            
            % update the current view
            obj.jtable.repaint;
        end
        
        % this function reassigns the renderers and editors.
        % It applies when new data is established (and editors and renderers are removed)
        function reAssignRenderers_Editors(obj)
            % retrieve property values for renderers
            n = obj.jtable.getColumnCount;
            %if ~iscell(colalign), colalign = repmat({colalign},1,n); end
            colalign = obj.resize2columncount(n,'center',obj.info.ColumnAlign);
            columnformat = obj.resize2columncount(n,'',obj.info.ColumnFormat);
            args = {strcmpi(obj.info.RowStriping,'on'),strcmpi(obj.info.ColumnStriping,'on'),...
                single(obj.info.RowColor),single(obj.info.ColumnColor),...
                obj.rgb2java(obj.char2rgb(obj.info.SelectionBackground)),...                
                obj.rgb2java(obj.char2rgb(obj.info.SelectionBorderColor)),...
                obj.rgb2java(obj.char2rgb(obj.info.SelectionForeground))};            

            % exclude the columns with a 'color' format
            ind = 1:n;
            if ~isempty(obj.colorFormat)
                obj.colorFormat = obj.resizelogical2columns(n,false,obj.colorFormat);
                ind = ind(~obj.colorFormat);
            end
            
            % loop in the columns to reassign the renderers            
            for j = ind
                column = obj.columnModel.getColumn(j-1);
                if ~strcmpi(columnformat{j},'logical')
                    cr = asd.fgh.olduitable.CellRenderer(args{:});
                    cr.setHorizontalAlignment(colalign{j});
                else
                    cr = asd.fgh.olduitable.CheckBoxRenderer(args{1:end-1});
                end                
                column.setCellRenderer(cr);
            end
            
            % store
            obj.info.ColumnAlign = colalign;
            
            % reassign special renderers and all editors
            obj.ColumnFormat = columnformat;
        end
        
        % this function modifies the headers renderer (for columns and rows) according to the new user assignments
        function modifyHeadersRenderer(obj,method,value)            
            % retrive the current renderers
            objectClass = obj.rowheader.getColumnClass(0);
            rowheaderRenderer = obj.rowheader.getDefaultRenderer(objectClass);
            columnheaderRenderer = obj.columnHeader.getDefaultRenderer;
            
            % modify renderer
            rowheaderRenderer.(method)(value);
            columnheaderRenderer.(method)(value);
            
            % assign modified renderer
            obj.rowheader.setDefaultRenderer(objectClass,rowheaderRenderer);
            obj.columnHeader.setDefaultRenderer(columnheaderRenderer);
            
            % update the current view
            obj.columnHeader.repaint;
            obj.rowheader.repaint;
        end
        
        function assignPopupList(obj,columnIndex,list)
            cb = javax.swing.JComboBox(unique(list));
            obj.columnModel.getColumn(columnIndex-1).setCellEditor(javax.swing.DefaultCellEditor(cb));
        end
    end    
    
    %% Default context menu, color picker and longchar editor
    methods (Access = private, Hidden)        
        % Default context menu -----------------------------------------------------------------------------------
        
        % function that creates the default context menu associated to the table
        function loadDefaultContextMenu(obj)
            % create a 'javax.swing.JPopupMenu' component
            contextMenu = javaObjectEDT('javax.swing.JPopupMenu');
            obj.defaultContextMenu = handle(contextMenu,'CallbackProperties');
            
            % define labels for the items
            labels = {'Cut','Copy','Paste','Clear Contents','Insert Row(s) Above','Insert Row(s) Below',...
                'Insert Column(s) to the Left','Insert Column(s) to the Right','Delete Row(s)','Delete Column(s)'};
            
            % define callbacks
            actions = {@(~,~)obj.cut,@(~,~)obj.keyRobot('control','c'),@(~,~)obj.paste,@(~,~)obj.paste({''}),...
                @(~,~)obj.insertRows('above','InternalUse'),@(~,~)obj.insertRows('below','InternalUse'),...
                @(~,~)obj.insertColumns('left','InternalUse'),@(~,~)obj.insertColumns('right','InternalUse'),...
                @(~,~)obj.deleteRows,@(~,~)obj.deleteColumns};
            
            % define keyboard shortcuts
            keyCode = [88,67,86,127,38,40,37,39,45,8];
            modifier = [2,2,2,0,8,8,8,8,2,2];
            
            % create items and assign properties
            for i = 1:length(labels)
                item = handle(javax.swing.JMenuItem(labels{i}),'CallbackProperties');
                item.setAccelerator(javax.swing.KeyStroke.getKeyStroke(keyCode(i),modifier(i)));
                if i == 5; obj.defaultContextMenu.addSeparator; end
                if i >= 5, item.setEnabled(false); end % at the beginning, by default, the table isn't editable
                item.ActionPerformedCallback = actions{i};
                obj.defaultContextMenu.add(item);
            end
            
            % associate popup-menu to table (only its body, excluding so the row and column headers)
            obj.jtable.setComponentPopupMenu(obj.defaultContextMenu);
        end
        
        % Color picker ---------------------------------------------------------------------------------------------
        % The folow functions complement the color cell editor. Without question
        % the JIDE class "com.jidesoft.combobox.ColorComboBox" (available in Matlab)
        % is a much better choise, but to avoid any legal problem it won't be used.

        % function that preloads the color picker immediately user sets the
        % property 'ColumnFormat' for any column with a 'color' value
        function loadColorPicker(obj)
            % define palette of colors (many of them are the same that use JIDE's ColorComboBox)
            rgbColors = 1/255*[0 0 0; 82 48 48; 51 51 0; 0 51 0; 0 51 102; 0 0 128; 39 58 95; 51 51 51;
                128 0 0; 135 81 81; 128 128 0; 27 79 53; 0 128 128; 0 0 255; 51 51 153; 80 80 80;
                162 20 47; 153 51 0; 119 172 48; 59 113 86; 51 204 204; 78 101 148; 102 102 153; 128 128 128;
                255 0 0; 255 102 0; 153 204 0; 0 128 0; 0 255 255; 51 102 255; 128 0 128; 153 153 153;
                255 0 255; 255 153 0; 191 191 0; 51 153 102; 204 255 255; 0 114 189; 153 51 102; 192 192 192;
                255 153 204; 255 204 0; 255 255 0; 0 255 0; 205 224 247; 0 204 255; 131 97 123; 220 220 220;
                236 214 214; 255 204 153; 255 255 153; 204 255 204; 222 235 250; 153 204 255; 204 153 255; 255 255 255];
            
            % define tooltip texts for the basic colors
            colorNames = cell(1,size(rgbColors,1));
            colorNames([1,14,25,29,33,43,44,56]) = {'black','blue','red','cyan','magenta','yellow','green','white'};
            
            % create a 'javax.swing.JPopupMenu' component
            n = 8; % number of colors per row
            popup = javaObjectEDT('javax.swing.JPopupMenu');
            popup = handle(popup,'CallbackProperties');
            popup.setPreferredSize(java.awt.Dimension(164,172));
            
            % define the grid to place the colors           
            popup.setLayout(java.awt.GridBagLayout);
            grid = java.awt.GridBagConstraints;
            
            % define border for the menu items (to create empty spaces between colors)
            customBorder = javax.swing.border.CompoundBorder(...
                javax.swing.border.LineBorder(java.awt.Color(0.94,0.94,0.94),3),...
                javax.swing.border.LineBorder(java.awt.Color.black));
            
            % create a 'javax.swing.JMenuItem' for each color and assign properties
            dim = java.awt.Dimension(19,19);
            for i=1:size(rgbColors,1)
                % define the place in the grid for the color
                grid.gridy = floor((i-0.1)/n);
                
                % paint the item according to the color
                color = handle(javax.swing.JMenuItem(''),'CallbackProperties'); 
                color.setPreferredSize(dim);
                color.setOpaque(true);
                color.setBackground(java.awt.Color(rgbColors(i,1),rgbColors(i,2),rgbColors(i,3)));                
                color.setBorderPainted(true);
                color.setBorder(customBorder);
                
                % set the tooltip (for the non-basic colors show the RGB triplet)
                if isempty(colorNames{i})
                    color.setToolTipText(mat2str(rgbColors(i,:),2));
                else
                    color.setToolTipText(colorNames{i});
                end                
                
                color.MousePressedCallback = @(~,~)obj.jtable.setValueAt(color.getBackground,obj.editingRow,obj.editingCol);
                
                % add item to the popup menu
                popup.add(color,grid);
            end
            
            % define the buttons 'More Colors' and 'None' for the color picker
            buttonsNames={'More Colors','None'};
            grid.gridwidth=4;
            grid.gridy=grid.gridy+1;
            grid.insets = java.awt.Insets(5,3,4,3);
            buttonBorder(1)=javax.swing.border.CompoundBorder(...
                javax.swing.border.LineBorder(java.awt.Color(0.5,0.5,0.5)),javax.swing.border.EmptyBorder(-2,-30,0,0));
            buttonBorder(2)=javax.swing.border.CompoundBorder(...
                javax.swing.border.LineBorder(java.awt.Color(0.5,0.5,0.5)),javax.swing.border.EmptyBorder(-2,-11,0,0));
            action{1} = @obj.moreColorsButton;
            action{2} = @obj.noneButton;            

            for i=1:2
                grid.gridx = 4*(i-1);
                button = handle(javax.swing.JMenuItem(buttonsNames{i}),'CallbackProperties');                
                button.setOpaque(true);
                button.setBackground(java.awt.Color(0.88,0.88,0.88));
                button.setPreferredSize(java.awt.Dimension(70,20));
                button.setBorderPainted(true);
                button.setBorder(buttonBorder(i));
                button.MousePressedCallback = action{i};
                button.MouseEnteredCallback = @(~,~)button.setBackground(java.awt.Color(0.9,0.95,0.98));
                button.MouseExitedCallback = @(~,~)button.setBackground(java.awt.Color(0.88,0.88,0.88));                
                popup.add(button,grid);
            end
            
            % create a custom dropdown button which will be displayed when the edit mode is active
            ddbutton = javaObjectEDT('asd.fgh.olduitable.ColorComboBox');
            ddbutton = handle(ddbutton,'CallbackProperties');
            arrowButton = handle(ddbutton.getArrowButton,'CallbackProperties');
            label = handle(ddbutton.getJLabel,'CallbackProperties');
            ddbutton.setPopupMenu(popup);            
            
            % assign callbacks to show or hide the color picker if the cell, whose column has a 'color' format, is clicked
            clickOnCell = @(~,~)obj.displayPopupEditor('colorEditor');
            ddbutton.MousePressedCallback = clickOnCell;
            arrowButton.MousePressedCallback = clickOnCell;
            label.MousePressedCallback = clickOnCell;
            
            % assign miscellaneous callbacks to avoid the occurrence of unwanted behaviors
            arrowButton.MouseWheelMovedCallback = @(~,~)obj.jtable.requestFocus;
            arrowButton.KeyPressedCallback = @(~,~)popup.setVisible(false);
            arrowButton.FocusLostCallback = @(~,~)obj.colorEditorLostFocus;
            obj.jtable.AncestorMovedCallback = @(~,~)obj.stopEditing;
            
            % store objects
            obj.colorEditor.cellbutton = ddbutton;
            obj.colorEditor.dropdownMenu = popup;            
        end
        
        % function that runs when the color picker loses the focus
        function colorEditorLostFocus(obj)
            focusOwner = java.awt.KeyboardFocusManager.getCurrentKeyboardFocusManager.getFocusOwner;
            if isempty(focusOwner) || isa(focusOwner,'asd.fgh.olduitable.RowHeader')
                if isvalid(obj)
                    obj.colorEditor.dropdownMenu.setVisible(false);
                    obj.colorEditor.cellbutton.setSelected(false);
                end
            end
        end
        
        % function that runs when the 'More Colors' button is pressed
        function moreColorsButton(obj,button,~)
            button.setBackground(java.awt.Color(0.88,0.88,0.88));
            label = obj.colorEditor.cellbutton.getJLabel;
            color = javax.swing.JColorChooser.showDialog(javax.swing.JButton,'Select Color',label.getBackground);
            if ~isempty(color)
                label.setBackground(color);
                obj.jtable.setValueAt(color,obj.editingRow,obj.editingCol);
            end
            obj.colorEditor.cellbutton.setSelected(false);
        end
        
        % function that runs when the 'None' button is pressed
        function noneButton(obj,button,~)
            button.setBackground(java.awt.Color(0.88,0.88,0.88));
            white = java.awt.Color.white;
            obj.jtable.setValueAt(white,obj.editingRow,obj.editingCol);
            obj.colorEditor.cellbutton.getJLabel.setBackground(white);
            obj.colorEditor.cellbutton.setSelected(false);
        end
        
        % function that shows or hides the popup editor (for columns with the 'color' or 'longchar' format)
        function displayPopupEditor(obj,editor)
            % retrieve editor parameters
            cellButton = obj.(editor).cellbutton;
            editArea = obj.(editor).dropdownMenu;
            
            % get the selected cell
            editRow = obj.jtable.getSelectedRow;
            editCol = obj.jtable.getSelectedColumn;
            
            % start the edit mode if necessary
            if isempty(obj.jtable.getCellEditor), obj.jtable.editCellAt(editRow,editCol); end
            
            % The popup editors will be displayed each time the selection changes to a column with the proper format.
            % This was implemented in the 'asd.fgh.olduitable.Table' class through a selection listener, so this function 
            % will only work when the same cell is clicked or when the edition was interrupted by a sort action.
            if ~editArea.isVisible && obj.editingRow == editRow && obj.editingCol == editCol
                cellButton.setSelected(~cellButton.isSelected);
                if cellButton.isSelected, cellButton.showPopup; end
            elseif obj.editingRow == -1
                obj.editingRow = editRow;
                obj.editingCol = editCol;
                cellButton.showPopup;
            end
        end
        
        % longchar -------------------------------------------------------------------------------------------------------------
        % function that preloads the long char editor
        function loadTextArea(obj)            
            % create the dropdown menu
            popup = javaObjectEDT('javax.swing.JPopupMenu');
            popup = handle(popup,'CallbackProperties');            
            popup.setPreferredSize(java.awt.Dimension(164,172));
            popup.setLayout(java.awt.GridBagLayout);
            
            % define the text area
            textarea = handle(javax.swing.JTextArea(7,1),'CallbackProperties');           
            panel = javax.swing.JScrollPane(textarea,javax.swing.JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,...
                javax.swing.JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
            
            % define grid and add panel (and with it the text area) to popup
            grid = java.awt.GridBagConstraints;
            grid.gridwidth = 2;
            grid.fill = java.awt.GridBagConstraints.HORIZONTAL;
            grid.insets = java.awt.Insets(2,2,2,2);
            grid.weightx = 1; 
            popup.add(panel,grid);
            
            % define the buttons 'Ok' and 'Cancel'
            buttonsNames={'Ok','Cancel'};            
            grid.gridy = 1; % second row (java indices)
            grid.gridwidth = 1;            
            grid.insets = java.awt.Insets(3,2,1,2);
            % define borders to try to center the label of menu items
            buttonBorder(1)=javax.swing.border.CompoundBorder(...
                javax.swing.border.LineBorder(java.awt.Color(0.5,0.5,0.5)),javax.swing.border.EmptyBorder(-2,-3,0,0));
            buttonBorder(2)=javax.swing.border.CompoundBorder(...
                javax.swing.border.LineBorder(java.awt.Color(0.5,0.5,0.5)),javax.swing.border.EmptyBorder(-2,-13,0,0));
            action{1} = @obj.okButton;
            action{2} = @obj.cancelButton;

            for i=1:2
                button = handle(javax.swing.JMenuItem(buttonsNames{i}),'CallbackProperties');                
                button.setOpaque(true);
                button.setBackground(java.awt.Color(0.88,0.88,0.88));
                button.setPreferredSize(java.awt.Dimension(40,20));
                button.setBorderPainted(true);
                button.setBorder(buttonBorder(i));
                button.MousePressedCallback = action{i};
                button.MouseEnteredCallback = @(~,~)button.setBackground(java.awt.Color(0.9,0.95,0.98));
                button.MouseExitedCallback = @(~,~)button.setBackground(java.awt.Color(0.88,0.88,0.88));                
                popup.add(button,grid);
            end
            
            % create a custom dropdown button which will be displayed when the edit mode is active
            ddbutton = javaObjectEDT('asd.fgh.olduitable.TextAreaComboBox',textarea);
            ddbutton = handle(ddbutton,'CallbackProperties');
            ddbutton.setPopupMenu(popup);
            arrowButton = handle(ddbutton.getArrowButton,'CallbackProperties');
            label = handle(ddbutton.getJLabel,'CallbackProperties');                        
            
            % display the text area if the cell, whose column has a 'longchar' format, is clicked
            ddbutton.MousePressedCallback = @(~,~)obj.displayPopupEditor('longcharEditor');
            arrowButton.MousePressedCallback = @(~,~)obj.displayPopupEditor('longcharEditor');
            label.MousePressedCallback = @(~,~)obj.displayPopupEditor('longcharEditor');

            % fix behavior if the editor lost the focus
            textarea.FocusLostCallback = @(~,~)obj.textAreaLostFocus;
            obj.jtable.AncestorMovedCallback = @(~,~)obj.stopEditing;
            
            % store objects
            obj.longcharEditor.area = textarea;
            obj.longcharEditor.cellbutton = ddbutton;            
            obj.longcharEditor.dropdownMenu = popup;
        end
        
        % function that is executed when the 'longchar' editor loses the focus
        function textAreaLostFocus(obj)
            row = obj.jtable.getSelectedRow;
            col = obj.jtable.getSelectedColumn;
            if obj.jtable.getSelectedRowCount == 1 && obj.jtable.getSelectedColumnCount == 1 && obj.tableModel.getColumnEditable(col)
                if ismember(obj.info.ColumnFormat{col+1},{'color','popup'})
                    obj.jtable.editCellAt(row,col);
                    obj.jtable.getEditorComponent.showPopup;
                elseif strcmpi(obj.info.ColumnFormat{col+1},'logical')
                    obj.jtable.editCellAt(row,col);
                else
                    obj.longcharEditor.cellbutton.requestFocus;
                end
            else
                obj.longcharEditor.dropdownMenu.setVisible(false);
            end
        end
        
        % function that runs when the 'Ok' button is pressed
        function okButton(obj,button,~)            
            button.setBackground(java.awt.Color(0.88,0.88,0.88));            
            obj.jtable.setValueAt(obj.longcharEditor.area.getText,obj.editingRow,obj.editingCol);
            obj.longcharEditor.cellbutton.setSelected(false);
            %obj.longcharEditor.cellbutton.getArrowButton.setSelected(true);
        end
        
        % function that runs when the 'Cancel' button is pressed
        function cancelButton(obj,button,~)
            button.setBackground(java.awt.Color(0.88,0.88,0.88));           
            obj.longcharEditor.cellbutton.setSelected(false);
            %obj.longcharEditor.cellbutton.getArrowButton.setSelected(false);
        end
        
    end
        
    %% Callbacks associated with mouse and keyboard actions
    methods (Access = private, Hidden)
        % Mouse functions ------------------------------------------------------------------------------

        % actions when the upper left corner is selected
        function cornerSelection(obj,~,evt)
            if obj.jtable.isEnabled
                obj.stopEditing;
                obj.jtable.selectAll;                
                obj.jtable.requestFocus; % return focus to table's body
            end
            obj.callButtonDownFcn(evt,'Corner'); % call user's callback
        end
        
        % actions when the table's body is selected
        function jtableSelection(obj,jtable,evt)
            % store cell value prior to editing
            if jtable.isEditing
                obj.oldValue = jtable.getValueAt(jtable.getEditingRow,jtable.getEditingColumn);
            end

            % right click ----> context menu
            if evt.isMetaDown && jtable.isEnabled
                obj.stopEditing;
                
                % select cell when the right click occurs outside the current selected interval
                point = evt.getPoint;
                row = jtable.rowAtPoint(point);
                col = jtable.columnAtPoint(point);                
                if ~ismember(row,jtable.getSelectedRows) || ~ismember(col,jtable.getSelectedColumns)
                    jtable.changeSelection(row,col,false,false);
                end

                % if the default context menu is present, enable/disable the 
                % 'cut', 'paste' & 'clear' items according to the column editable property
                if ischar(obj.UIContextMenu) && strcmpi(obj.UIContextMenu,'auto')
                    editable = obj.tableModel.getColumnEditable;
                    items = obj.defaultContextMenu.getComponents;
                    flag = all(editable((jtable.getSelectedColumns + 1)));
                    for i = [1 3 4]
                        items(i).setEnabled(flag);
                    end
                end
            end

            % call user's callback ('CellSelectionCallback' is triggered in the 'selectionChanged' function)
            if ~jtable.isEnabled, obj.callButtonDownFcn(evt,'Body'); end
        end
        
        % actions when the column headers are selected
        function colheaderSelection(obj,colheader,evt)
            % fix problem with popup editors when the column headers are clicked
            if ~isempty(obj.colorEditor.dropdownMenu), obj.colorEditor.dropdownMenu.setVisible(false); end
            if ~isempty(obj.longcharEditor.dropdownMenu), obj.longcharEditor.dropdownMenu.setVisible(false); end
            
            % (un)sort the column when its header is left-clicked
            column = 1 + colheader.columnAtPoint(evt.getPoint);
            if obj.jtable.isEnabled && column > 0 && ~evt.isMetaDown && isempty(colheader.getResizingColumn) && obj.info.ColumnSortable(column)
                if column == obj.SortedColumn && ~obj.isDataModified
                    if obj.SortDirection == 1
                        obj.sortColumn(column,'descend','InternalUse');
                    else%if obj.SortDirection == -1
                        obj.unsort;
                    end
                else
                    obj.sortColumn(column,'ascend','InternalUse');                
                end
            end
            
            % call user's callback
            obj.callButtonDownFcn(evt,'ColumnHeader');
        end
        
        % function to update the width of a resized column
        function columnResize(obj,~,~)
            resizedColumn = obj.columnHeader.getResizingColumn;
            if ~isempty(resizedColumn)
                obj.info.ColumnWidth{resizedColumn.getModelIndex + 1} = resizedColumn.getWidth;
            end
        end

        % function that creates the 'eventdata' for the 'ButtonDownFcn' property and executes this callback
        function callButtonDownFcn(obj,evt,areaName)
            % areaName = 'Body' (main table), 'ColumnHeader', 'RowHeader', 'EmptyPanel' or 'Corner' (top-left of pane)
            if ~isempty(obj.ButtonDownFcn)
                % create 'eventdata' structure
                click = {'left','middle','right'};
                eventdata.ClickedArea = areaName;
                eventdata.Button = click{ismember([1 2 3],evt.getButton)};
                eventdata.ClickCount = evt.getClickCount;
                eventdata.ClickPosition = [evt.getPoint.x,evt.getPoint.y]; % [0,0] -> top-left of area (in relative pixels units)                
                                
                % evalue user's callback function
                obj.evalFcn(obj.ButtonDownFcn,eventdata);
            end
        end
        
        % function that evalues the user's callback depending on whether it is a 'function handle', a cell array or a char
        function evalFcn(obj,fcn,eventdata)
            if isa(fcn,'function_handle')
                feval(fcn,obj,eventdata);
            elseif iscell(fcn)
                feval(fcn{1},obj,eventdata,fcn{2:end});
            elseif ischar(fcn)
                evalin('base',fcn);
            end
        end
        
        % Keyboard functions ---------------------------------------------------------------------------------------------
        
        % actions when key is pressed while jtable has the focus
        function keyfunction(obj,jtable,evt)
            % store cell value prior to editing
            if jtable.isEditing
                obj.oldValue = jtable.getValueAt(jtable.getEditingRow,jtable.getEditingColumn);
            end
            
            % define keyboard shortcuts
            if evt.getModifiers == 2 && evt.getKeyCode == 86 % Ctrl + V
                if jtable.getSelectedRow > -1, obj.paste; end
            elseif evt.getKeyCode == 127 % delete
                if jtable.getSelectedRow > -1, obj.paste({''}); end
            elseif evt.getModifiers == 2 && evt.getKeyCode == 88 % Ctrl + X
                obj.cut;
            elseif evt.getModifiers == 2 && ismember(evt.getKeyCode,37:40) % Ctrl + navigation arrows
                if jtable.getSelectedRow > -1
                    if evt.getKeyCode == 38
                        jtable.changeSelection(0,jtable.getSelectedColumn,false,false)
                    elseif evt.getKeyCode == 40
                        jtable.changeSelection(jtable.getRowCount-1,jtable.getSelectedColumn,false,false)
                    elseif evt.getKeyCode == 37
                        jtable.changeSelection(jtable.getSelectedRow,0,false,false)
                    else%if evt.getKeyCode == 39
                        jtable.changeSelection(jtable.getSelectedRow,jtable.getColumnCount-1,false,false)
                    end
                end
            elseif evt.getModifiers == 8 && ismember(evt.getKeyCode,37:40) % Alt + navigation arrows
                if evt.getKeyCode == 38
                    obj.insertRows('above','InternalUse');
                elseif evt.getKeyCode == 40
                    obj.insertRows('below','InternalUse');
                elseif evt.getKeyCode == 37
                    obj.insertColumns('left','InternalUse');
                else%if evt.getKeyCode == 39
                    obj.insertColumns('right','InternalUse');
                end
            elseif evt.getModifiers == 2 && (strcmp(evt.getKeyChar,'-') || evt.getKeyCode == 45) % Ctrl + Minus
                obj.deleteRows;
            elseif evt.getModifiers == 2 && evt.getKeyCode == 8 % Ctrl + backspace
                obj.deleteColumns;
            end

            % call user's callback
            obj.callKeyFcn([],evt,'KeyPressFcn');
        end

        % function that creates the 'eventdata' for the 'KeyPressFcn' and 'KeyReleaseFcn' properties and executes the callback
        function callKeyFcn(obj,~,evt,keyFcn)
            if ~isempty(obj.(keyFcn))
                % create 'eventdata' structure
                eventdata.Character = lower(evt.getKeyChar);
                eventdata.Modifier = lower(char(evt.getKeyModifiersText(evt.getModifiers)));
                eventdata.Key = lower(char(evt.getKeyText(evt.getKeyCode)));
                
                % use the english designation for the keys
                if evt.getKeyCode == 37
                    eventdata.Key = 'leftarrow';
                elseif evt.getKeyCode == 38
                    eventdata.Key = 'uparrow';
                elseif evt.getKeyCode == 39
                    eventdata.Key = 'rightarrow';
                elseif evt.getKeyCode == 40
                    eventdata.Key = 'downarrow';
                elseif evt.getKeyCode == 8
                    eventdata.Key = 'backspace';
                elseif evt.getKeyCode == 9
                    eventdata.Key = 'tab';
                elseif evt.getKeyCode == 10
                    eventdata.Key = 'return';
                elseif evt.getKeyCode == 20
                    eventdata.Key = 'capslock';
                elseif evt.getKeyCode == 127
                    eventdata.Key = 'delete';
                    .... % among other keys
                end
                eventdata.EventName = keyFcn(1:end-3);                
                
                % evalue user's callback function
                obj.evalFcn(obj.(keyFcn),eventdata);             
            end
        end
        
        % CellEditCallback ----------------------------------------------------------------------------------------------
        
        % function that creates the 'eventdata' for the 'CellEditCallback' property and executes this callback
        function callCellEditCallback(obj,rows,cols,oldData,editData,eventName)
            if ~isempty(obj.CellEditCallback)
                % create 'eventdata' structure
                eventdata.RowIndices = double(rows);
                eventdata.ColumnIndices = double(cols);             
                eventdata.PreviousData = oldData;
                eventdata.EditData = editData;
                % callbackdata.NewData = obj.Data;
                eventdata.EventName = eventName;
                
                % evalue user's callback function
                obj.evalFcn(obj.CellEditCallback,eventdata);
            end
        end

        % this function will only be used when a single cell is edited (see 'cut', 'paste', 'insertColumns',
        % 'insertRows', 'deleteColumns' and 'deleteRows' functions for the other edition types)
        function cellEdit(obj,model,eventdata)
            % control callback re-entrancy
            % taken from https://undocumentedmatlab.com/blog/controlling-callback-re-entrancy#comment-73083
            if ~isempty(obj.editing)
                return
            else                
                obj.editing = true;
            end

            % get the cell edited (according to the model)
            i = eventdata.getFirstRow;
            j = eventdata.getColumn;
            
            if i > -1 && j > -1
                % store data (according to the view)
                oldData = obj.Data;
                
                % get and store new data
                editData = model.getValueAt(i,j);
                numData = str2double(editData); % convert string to double if required                                  
                if ~isnan(numData) && ~ismember(obj.info.ColumnFormat{j+1},{'char','longchar','popup'})
                    editData = numData;
                    model.setValueAt(editData,i,j);
                end                
                
                % call user's callback function if the value is really modified
                if ~isequal(editData,obj.oldValue)
                    obj.isDataModified = true;
                    
                    i = obj.jtable.convertRowIndexToView(i);
                    %j = obj.jtable.convertColumnIndexToView(j);
                    oldData{i+1,j+1} = obj.oldValue;
                    
                    obj.callCellEditCallback(i+1,j+1,oldData,editData,'CellEdition');
                end

                drawnow
                obj.editing = [];
            end
        end
        
        % function that stops the current edition
        function stopEditing(obj)
            editor = obj.jtable.getCellEditor;
            if ~isempty(editor), editor.stopCellEditing; end
        end
        
        % function that displays a warning if a sort mode is currently active
        function flag = isSortModeActive(obj,functionName)
            flag = (obj.SortDirection ~= 0); % obj.SortedColumn > 0
            if flag
                warning(['''',functionName,''' was interrupted to avoid errors or unwanted behaviors when the sort mode is active.']);
            end
        end

        % -----------------------------------------------------------------------------------------------------------------------------------
        % function that is executed when the selection in the table changes
        function selectionChanged(obj,src,evt,mode) %#ok<INUSL>
            % registry the current cell that is in edit mode
            obj.editingRow = obj.jtable.getEditingRow;
            obj.editingCol = obj.jtable.getEditingColumn;
            
            if obj.jtable.getSelectedRowCount > 0 && obj.jtable.getSelectedColumnCount > 0 %~src.isSelectionEmpty
                % get first and last (or lead) row/column selected
                first = src.getMinSelectionIndex;
                last = src.getLeadSelectionIndex;
                if last == first, first = src.getMaxSelectionIndex; end
                obj.([mode,'SelectionRange']) = {first,last};

                % call user's callback
                if ~isempty(obj.CellSelectionCallback) %&& ~evt.getValueIsAdjusting
%                     % this code was discarded because the number of selected cells (or pair of Indices) in large tables could be excessive
%                     ind = 1 + combvec(obj.jtable.getSelectedColumns',obj.jtable.getSelectedRows')';
%                     callbackdata.Indices = ind(:,[2 1]);

                    callbackdata.RowIndices = double(obj.jtable.getSelectedRows) + 1;
                    callbackdata.ColumnIndices = double(obj.jtable.getSelectedColumns) + 1;
                    
                    % evalue user's callback function
                    obj.evalFcn(obj.CellSelectionCallback,callbackdata);
                end
            end
        end
        
        % function to restore the previous selection when new data is assigned in the table
        function rememberSelection(obj)
            if ~isempty(obj.RowsSelectionRange) && ...
                    max(obj.RowsSelectionRange{:}) < obj.jtable.getRowCount && ...
                    max(obj.ColumnsSelectionRange{:}) < obj.jtable.getColumnCount
                obj.jtable.setColumnSelectionInterval(obj.ColumnsSelectionRange{:});
                obj.jtable.setRowSelectionInterval(obj.RowsSelectionRange{:});
            end
        end
        
        % function to hightlight the row headers according to the selection in the table
        function highlightRowHeaders(obj)
            firstRow = obj.jtable.getSelectedRow;
            if firstRow == -1 || obj.jtable.getSelectedColumnCount == 0
                obj.rowheader.clearSelection;
            else
                obj.rowheader.setColumnSelectionInterval(0,0);
                obj.rowheader.setRowSelectionInterval(firstRow,firstRow + obj.jtable.getSelectedRowCount - 1);
            end
            
        end
    end
    
    %%  Validation functions
    % the follow functions validates the user inputs (when the table is created or property is updated)
    methods (Static, Access = protected, Hidden)
        function binaryValidation(x,varargin)
            % validateattributes(x,{'numeric','logical'},{'vector','binary'})
            flag = (islogical(x) && isvector(x)) || ...
                (isnumeric(x) && isvector(x) && all(ismember(x,[0 1]))); % 'isvector' function validates scalar values
            if ~flag % assert(flag,blablabla)
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a logical or logical array ',...
                    '- a numeric scalar 0 or 1 ',...
                    '- a 1-by-n or n-by-1 numeric array with binary values ');
            end
        end
        
        function callbackValidation(x,varargin)
            flag = isempty(x) || isa(x,'function_handle') || ...
                ((ischar(x) || iscell(x)) && isrow(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a function handle (@fcnName) ',...
                    '- a character vector (''fcnName'') ',...
                    '- a cell array containing @fcnName or ''fcnName'' and extra arguments if function requires it ');
            end
        end
        
        function flag = colorValidation(x,varargin)
            flag = (isnumeric(x) && all(size(x) == [1 3]) && (min(x) >= 0) && (max(x) <= 1)) || ...
                (ischar(x) && isscalar(x) && ismember(lower(x),{'y','m','c','r','g','b','w','k'})) || ...
                (ischar(x) && isrow(x) && ismember(lower(x),{'yellow','magenta','cyan','red','green','blue','white','black'}));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a short name of color (''r'', ''g'', ''b'', ''y'', ''m'', ''c'', ''w'' or ''k'') ',...
                    '- a long name of color (''red'', ''green'', ''blue'', ''yellow'', ''magenta'', ''cyan'', ''white'' or ''black'') ',...
                    '- a RGB triplet (1-by-3 row vector with values in the range [0,1]) ');
            end
        end
        
        function flag = columnalignValidation(x,varargin)
            flag = ((ischar(x) &&  isrow(x)) || (iscellstr(x) && isvector(x))) && all(ismember(lower(x),{'left','center','right'}));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a char ''left'', ''center'' or ''right'' ',...
                    '- a 1-by-n or n-by-1 cell array of character vectors with those values ');
            end
        end
        
        function flag = columnformatValidation(x,varargin)
            % validateattributes(x,{'char','cell'},{})
            flag = ischar(x) || (iscellstr(x) && isvector(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end
                formatInfo = ['- a character vector with a valid formatting operator (see ',...
                    '<a href="',fullfile(docroot,'matlab/ref/sprintf.html#input_argument_d118e979713'),'">documentation</a>) '];
                error('\b\n%s',premsg,'This must be either: ',...
                    '- an empty char vector '''' ','- char vectors as ''bank'', ''char'', ''color'', ''logical'', ''longchar'' or ''popup'' ',...
                    formatInfo,'- a 1-by-n or n-by-1 cell array of character vectors with those formats ');                
            end
        end
        
        function flag = colformatdataValidation(x,varargin)
            flag = iscell(x) && all(cellfun(@(arg)isempty(arg) || iscellstr(arg),x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end
                error('\b\n%s',premsg,'This must be either: ',...
                    '- an empty cell array {}',...
                    '- a 1-by-n or n-by-1 cell array with empty values or cellstr arrays ');         
            end
        end

        function flag = columnwidthValidation(x,varargin)
            % validateattributes(x,{'cell','numeric'},{'vector','nonnegative'});
            flag = (isnumeric(x) && isscalar(x) && x >= 0) || ...
                (iscell(x) && isvector(x) && all(cellfun(@(arg)isnumeric(arg) && arg >= 0,x)));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a positive number (value is in pixel units) ',...                    
                    '- a 1-by-n or n-by-1 cell array with positive numbers ');                
            end
        end
        
        function flag = dataValidation(x,varargin)
            % validateattributes(x,{'cell','numeric','logical'},{'2d'});
            flag = (iscell(x) || isnumeric(x) || islogical(x)) && ismatrix(x);
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be a 2D numeric, logical or cell array ');               
            end
        end
        
        function flag = fontnameValidation(x,varargin)
            % validateattributes(x,{'char'},{});
            flag = ischar(x) && isrow(x) && any(strcmpi(x,olduitable.listfonts));
            if ~flag
                premsg = '';                
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,...
                    'This must be a char vector with the name of a supported system font (see <a href="matlab:listfonts">List system fonts</a>) ');
            end
        end
        
        function flag = fontsizeValidation(x,varargin)
            % validateattributes(x,{'numeric'},{'scalar','integer','positive'});
            flag = isnumeric(x) && isscalar(x) && x > 0; % && rem(x,1) == 0
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be a positive number (value is in pixel units) ');                
            end
        end
        
        function flag = fontstyleValidation(x,varargin)
            flag = (isnumeric(x) && isscalar(x) && ismember(x,[0 1 2 3])) || ...
                (ischar(x) && ismember(lower(x),{'normal','bold','italic','bold italic'}));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- char vector ''normal'' (or 0) ',...
                    '- char vector ''bold'' (or 1) ',...
                    '- char vector ''italic'' (or 2) ',...
                    '- char vector ''bold italic'' (or 3) ');                
            end
        end
        
        function flag = headerNamesValidation(x,varargin)
            flag = isempty(x) || (ischar(x) && strcmpi(x,'numbered')) || (iscellstr(x) && isvector(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- char vector ''numbered'' ',...
                    '- an empty cell array {} or matrix [] ',...
                    '- a 1-by-n or n-by-1 cell array of character vectors ');                
            end
        end
        
        function flag = jpopupValidation(x,varargin)
            flag = isempty(x) || (ischar(x) && strcmpi(x,'auto')) || ...
                isa(x,'javax.swing.JPopupMenu') || isa(x,'javahandle_withcallbacks.javax.swing.JPopupMenu');
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- char vector ''auto'' ',...
                    '- an empty cell array {} or matrix [] ',...                    
                    '- a Java component of type javax.swing.JPopupMenu ');                
            end
        end

        function flag = onoffValidation(x,varargin)
            % any(validatestring(x,{'on','off'}))
            flag = ischar(x) && ismember(x,{'on','off'});
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be one of these values: ''on'' | ''off'' ');
            end
        end
        
        function flag = parentValidation(x,varargin)
            flag = (isempty(x) && (iscell(x) || isnumeric(x))) || ...
                (ismember(class(x),olduitable.validParent) && isvalid(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid  or handle was deleted. ']; end
                error('\b\n%s',premsg,'Parent must be one of these objects: Figure | Panel | ButtonGroup | Tab ');
            end
        end
        
        function flag = positionValidation(x,varargin)
            % validateattributes(x,{'numeric'},{'size',[1,4],'nonnegative'})
            flag = isnumeric(x) && all(size(x) == [1,4]) && min(x) >= 0;
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end
                error('\b\n%s',premsg,'This must be a 1-by-4 numeric array of the form [left bottom width height] ');
            end
        end
        
        function flag = rgbValidation(x,varargin)
            % validateattributes(x,{'numeric'},{'size',[NaN,3],'<=',1,'>=',0})
            flag = isnumeric(x) && size(x,1) >= 1 && size(x,2) == 3 && (min(x(:)) >= 0) && (max(x(:)) <= 1);
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end               
                error('\b\n%s',premsg,'This must be either: ',...
                    '- a RGB triplet (1-by-3 numeric array with values in the range [0,1]) ',...
                    '- an m-by-3 matrix of RGB triplets ');
            end
        end
        
        function flag = rowheightValidation(x,varargin)
            flag = (ischar(x) && strcmpi(x,'auto')) || (isnumeric(x) && isscalar(x) && x >= 0);
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- char vector ''auto'' ',...
                    '- a positive number (value is in pixel units) ');                
            end
        end

        function flag = tagValidation(x,varargin)
            flag = ischar(x) && (isempty(x) || isrow(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be a character vector (''tagName'') ');                
            end
        end
        
        function flag = tooltipsValidation(x,varargin)
            flag = (ischar(x) && isempty(x)) || (iscellstr(x) && isvector(x));
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end                
                error('\b\n%s',premsg,'This must be either: ',...
                    '- an empty char '''' ',...
                    '- a 1-by-n or n-by-1 cell array of character vectors ');                
            end
        end
        
        function flag = unitsValidation(x,varargin)
            % any(validatestring(x,{'pixels','normalized','inches','centimeters','points','characters'}))
            flag = ischar(x) && isrow(x) && ismember(x,{'pixels','normalized','inches','centimeters','points','characters'});
            if ~flag
                premsg = '';
                if nargin == 2, premsg = ['''',varargin{:},'''',' value is invalid. ']; end
                error('\b\n%s',premsg,'It must be one of these: ',...
                    '''pixels'' | ''normalized'' | ''inches'' | ''centimeters'' | ''points'' | ''characters'' ');
            end
        end

    end
    
    %% Utility functions
    methods (Static, Access = protected, Hidden)       
        
        % function that returns the rgb triplet form of a color since its 
        % short or long name (val) or the same value if it is already a rgb triplet
        function val = char2rgb(val)
            if ischar(val)
                colors = [1 1 0;1 0 1;0 1 1;1 0 0;0 1 0;0 0 1;1 1 1;0 0 0];
                if length(val) == 1
                    %val = bitget(find('krgybmcw' == val)-1,1:3); 
                    [~,ind] = ismember(lower(val),{'y','m','c','r','g','b','w','k'});                    
                else         
                    [~,ind] = ismember(lower(val),{'yellow','magenta','cyan','red','green','blue','white','black'});   
                end
                val = colors(ind,:);
            end
            %javacolor = java.awt.Color(val(1),val(2),val(3));
        end
        
        % function that adjusts a value (val) to fit to the num of columns in table (n)
        function val = resize2columncount(n,val0,val) % [val,uniVal] = resize2columncount(n,val0,val)          
            if ischar(val) || (isnumeric(val) && isscalar(val))
                %uniVal = val;
                val = repmat({val},1,n); % repeat single value n times
            else
                if length(val)<n
                    val = [val,repmat({val0},1,n-length(val))]; % fill short cell array with default value (val0)
                elseif length(val)>n
                    val = val(1:n); % truncate long cell array up to a length n
                end
                %uniVal = olduitable.uniqueValue(val); % verify and registry if cell array has only one value
            end
        end
        
        % idem to 'resize2columncount' but for logical or 0-1 arrays (or scalar with those values)
        function val = resizelogical2columns(n,val0,val) % [val,uniVal] = resizelogical2columns(n,val0,val)
            if isscalar(val)
                %uniVal = val;
                val = repmat(val,1,n);
            else
                if length(val)<n
                    val = [val,repmat(val0,1,n-length(val))];
                elseif length(val)>n
                    val = val(1:n);
                end
                %uniVal = olduitable.uniqueValue(val);
            end
        end
        
        % function that convert an rgb triplet to the equivalent java color
        function javacolor = rgb2java(val)
            javacolor = java.awt.Color(val(1),val(2),val(3));
        end
        
        % function that convert a numeric row vector to a cell array of chars
        function cell = num2cellstr(val)
%             if verLessThan('matlab','8.1') % versions earlier than R2013a
%                 cell = cellstr(cellfun(@num2str,num2cell(val'),'UniformOutput',false))';
            if verLessThan('matlab','9.1') % versions earlier than R2016b
                cell = strsplit(num2str(val));
            else
                cell = cellstr(string(val));
            end
        end
        
        % function that returns the unique value in the vector 'val' or the same vector if it has more than one value
        function val = uniqueValue(val)
            if iscell(val)
                uniques = unique(cellfun(@num2str,val,'UniformOutput',false));
                if isscalar(uniques)
                    val = uniques{1};
                    num = str2double(val);
                    if ~isnan(num), val = num; end
                end
            elseif isnumeric(val) || islogical(val)
                uniques = unique(val);
                if isscalar(uniques), val = uniques; end
            end
        end
        
        % function that converts the contents of the clipboard to a cell array
        function data = getclipdata()
            % get the contents of the clipboard and convert it to a java.lang.String object
            c = java.awt.Toolkit.getDefaultToolkit.getSystemClipboard;
            clip = java.lang.String(c.getData(java.awt.datatransfer.DataFlavor.stringFlavor));
            % clip = java.lang.String(clipboard('paste'));

            % convert the string to an m-by-1 java array (where m is the number of rows in the data)
            rowStringData = clip.split('\n');

            % split each row into individual elements (cells)
            stringData = cell(0,0);
            for i = 1:length(rowStringData)
                stringData(i,:) = cell(rowStringData(i).split('\t'));
            end

            % return 'stringData' to a numerical type if required 
            numData = str2double(stringData);
            ind = isnan(numData);
            data = num2cell(numData);
            data(ind) = stringData(ind);
        end
        
        % function that simulates a keyboard action
        function keyRobot(modifier,keyChar)
            robot = java.awt.Robot;
            robot.keyPress(java.awt.event.KeyEvent.(['VK_',upper(modifier)]));
            robot.keyPress(java.awt.event.KeyEvent.(['VK_',upper(keyChar)]));
            robot.keyRelease(java.awt.event.KeyEvent.(['VK_',upper(keyChar)]));
            robot.keyRelease(java.awt.event.KeyEvent.(['VK_',upper(modifier)]));
        end
        
        % function that obtains the data from a table model as a cell array
        function dataInModel = getDataInModel(model)
            vectors = feature(44,model.getDataVector,1);
            dataVectors = cellfun(@(x)feature(44,x,1),vectors,'UniformOutput',false);
            dataInModel = [dataVectors{:}]';
        end        
    end
end
