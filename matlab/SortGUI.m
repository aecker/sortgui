classdef SortGUI < handle
    
    properties %#ok<*PROP>
        fig
        table
        tableSel
        selection
        upBtn
        downBtn
        moreBtn
        lessBtn
        doneBtn
        groupBtn
        ungroupBtn
        colorScheme
        ccgView
        spikeView
        waveView
        singleUnits
        groupings
        ignore
        rate
        selFirst
        selLast
        numTemplates
        numGroups
        t
        assignments
        ampl
        W
        channelLayout
        ccg
    end
    
    properties (Access = private, Constant)
        spacing = 8;
        btnHeight = 30;
    end
    
    
    methods (Static)
        
        function su = open(t, assignments, ampl, W, channelLayout)
            % Open GUI window
            
            % open GUI window and block command window
            gui = SortGUI(t, assignments, ampl, W, channelLayout);
            uiwait(gui.fig);
            
            % close all windows
            if ishghandle(gui.fig)
                close(gui.fig)
            end
            
            % return single units
            su = gui.singleUnits;
        end
        
    end

    
    methods
        
        function self = SortGUI(t, assignments, ampl, W, channelLayout)
            
            % data
            self.t = t;
            self.assignments = assignments;
            self.ampl = ampl;
            self.W = W;
            self.channelLayout = channelLayout;
            self.numTemplates = max(assignments);
            self.groupings = num2cell(1 : self.numTemplates)';
            self.numGroups = numel(self.groupings);
            
            % GUI main window
            height = 400;
            width = 300;
            pos = getenv('SORTGUI_POSITION');
            if isempty(pos)
                left = 50;
                pos = get(0, 'ScreenSize');
                top = pos(4) - 50;
            else
                left = pos(1);
                top = pos(2);
            end
            pos = [left, top - height, width, height];
            self.fig = figure('MenuBar', 'none', 'ToolBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'Selection', 'Position', pos);
            self.colorScheme = HSVColorScheme;
            
            % cluster list
            s = self.spacing;
            h = height - 2 * s;
            w = 220;
            pos = [s, height - h - s, w, h];
            
            self.table = uitable('Data', {}, 'RowName', [], ...
                'ColumnName', {'Color', 'SU', 'Rate', 'Ignore', '#'}, ...
                'ColumnWidth', {40 20 40 40 20}, ...
                'ColumnEditable', [false, true, false, true, false], ...
                'BackgroundColor', [1 1 1], ...
                'Position', pos, 'FontSize', 12, ...
                'CellEditCallback', @(~, evt) self.tableEdit(evt), ...
                'CellSelectionCallback', @(~, evt) self.tableSelect(evt));
            
            % buttons for moving the list
            h = self.btnHeight;
            wi = 50;
            pos = [2 * s + w, height - s - h, wi, h];
            self.upBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '//\\', 'Callback', @(~, ~) self.moveSel(-1));
            pos(2) = pos(2) - h;
            self.downBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '\\//', 'Callback', @(~, ~) self.moveSel(1));
            
            % buttons for selecting more or less clusters
            pos(2) = pos(2) - s - h;
            self.lessBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '-', 'Callback', @(~, ~) self.expandSel(-1));
            pos(2) = pos(2) - h;
            self.moreBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '+', 'Callback', @(~, ~) self.expandSel(1));

            % (un)group buttons
            pos(2) = pos(2) - s - h;
            self.groupBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'String', 'group', 'Callback', @(~, ~) self.group());
            pos(2) = pos(2) - h;
            self.ungroupBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'String', 'ungroup', 'Callback', @(~, ~) self.ungroup());
            
            % done button
            pos = [2 * s + w, s, wi, h];
            self.doneBtn = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'String', 'OK', 'Callback', @(~, ~) uiresume(self.fig));
            
            % cross-correlograms
            self.ccg = correlogram(t, assignments, self.numTemplates, 0.2, 10);
            self.ccgView = MCorrelogramView;
            self.ccgView.setCCG(self.ccg)
            w = 1200;
            height = 800;
            set(self.ccgView, 'Position', [left + width, top - height, w, height]);
            
            % waveforms
            th = 22;
            self.waveView = MWaveformView;
            self.waveView.setChannelLayout(channelLayout(:, 1), channelLayout(:, 2))
            self.waveView.setWaveforms(W)
            set(self.waveView, 'Position', [left + width, top - 1.5 * height - th, w, 0.5 * height]);
            
            % spike times
            self.spikeView = MSpikeTimeView;
            self.spikeView.setSpikes(t, ampl, assignments)
            set(self.spikeView, 'Position', [left + width + w, top - height, round(w / 3), height]);
            
            % statistics etc
            self.rate = histc(assignments, 1 : self.numTemplates) / (t(end) - t(1)) * 1000;
            self.singleUnits = false(self.numGroups, 1);
            self.ignore = false(self.numGroups, 1);
            self.setSelection(1, 15);
            
            set(self.fig, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.upBtn, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.downBtn, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.lessBtn, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.moreBtn, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.table, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.ccgView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.waveView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.spikeView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            
            set(self.fig, 'DeleteFcn', @(~, ~) self.close(), ...
                          'ResizeFcn', @(~, ~) self.resize())
        end
        
    end
    
    
    methods (Access = private)
        
        function moveSel(self, i)
            self.setSelection(self.selFirst + i, self.selLast + i);
        end
        
        
        function expandSel(self, i)
            self.setSelection(self.selFirst, self.selLast + i);
        end
        
        
        function setSelection(self, first, last)
            
            % determine units to be selected
            if last > self.numGroups
                first = first - last + self.numGroups;
                last = self.numGroups;
            end
            if first < 1
                last = last + 1 - first;
                first = 1;
            end
            self.selFirst = min(self.numGroups, max(1, first));
            self.selLast = min(self.numGroups, max(self.selFirst, last));
            indices = (self.selFirst : self.selLast)';
            
            % update stats table
            d = cell(numel(indices), 5);
            for i = 1 : numel(indices)
                d{i, 1} = colorPatch(self.colorScheme.getColor(indices(i) - 1));
                d{i, 2} = self.singleUnits(indices(i));
                d{i, 3} = sprintf('<html><p align="right" width=35">%.1f</p></html>', sum(self.rate(self.groupings{indices(i)})));
                d{i, 4} = self.ignore(indices(i));
                d{i, 5} = groupStr(numel(self.groupings{indices(i)}));
            end
            self.table.Data = d;
            
            % update views
            sel = indices(~self.ignore(indices));
            self.ccgView.setSelected(sel);
            self.spikeView.setSelected(sel);
            self.waveView.setSelected(sel);
        end
        
        
        function group(self)
            indices = self.selFirst : self.selLast;
            sel = indices(self.tableSel);
            if ~isempty(sel)
                self.groupings{sel(1)} = sort([self.groupings{sel}]);
                self.groupings(sel(2 : end)) = [];
                self.numGroups = numel(self.groupings);
                self.singleUnits(sel(1)) = true; % grouping implies single unit
                self.singleUnits(sel(2 : end)) = [];
                self.setSelection(self.selFirst, self.selLast);
                self.updatePlots()
            end
        end
        
        
        function ungroup(self)
            indices = self.selFirst : self.selLast;
            sel = sort(indices(self.tableSel), 'descend');
            for i = 1 : numel(sel)
                templates = self.groupings{sel(i)};
                n = numel(templates);
                if n > 1
                    self.groupings(sel(i) + n : end + n - 1) = self.groupings(sel(i) + 1 : end);
                    self.groupings(sel(i) : sel(i) + n - 1) = num2cell(templates);
                    self.numGroups = numel(self.groupings);
                    self.singleUnits(sel(i) + n : end + n - 1) = self.singleUnits(sel(i) + 1 : end);
                    self.singleUnits(sel(i) : sel(i) + n - 1) = false;
                    self.setSelection(self.selFirst, self.selLast);
                end
            end
            self.updatePlots()
        end
        
        
        function tableEdit(self, evt)
            indices = self.selFirst : self.selLast;
            switch evt.Indices(2)
                case 2
                    self.singleUnits(indices(evt.Indices(1))) = evt.NewData;
                case 4
                    self.ignore(indices(evt.Indices(1))) = evt.NewData;
            end
            self.setSelection(self.selFirst, self.selLast);
        end
        
        
        function tableSelect(self, evt)
            self.tableSel = unique(evt.Indices(:, 1));
        end
        
        
        function updatePlots(self)
            self.updateCCGs()
            self.updateWaveforms()
            self.updateSpikeTimes()
        end
        
        
        function updateCCGs(self)
            bins = size(self.ccg, 1);
            ccg = zeros(bins, self.numGroups, self.numGroups);
            for i = 1 : self.numGroups
                for j = 1 : self.numGroups
                    ccg(:, i, j) = sum(sum(self.ccg(:, self.groupings{i}, self.groupings{j}), 2), 3);
                end
            end
            self.ccgView.setCCG(ccg)
        end
        
        
        function updateWaveforms(self)
            [D, K, ~, B] = size(self.W);
            W = zeros(D, K, self.numGroups, B);
            for i = 1 : self.numGroups
                idx = self.groupings{i};
                W(:, :, i, :) = sum(bsxfun(@times, self.W(:, :, idx, :), permute(self.rate(idx), [2 3 1])), 3) / sum(self.rate(idx));
            end
            self.waveView.setWaveforms(W);
        end
        
        
        function updateSpikeTimes(self)
            a = zeros(size(self.assignments));
            for i = 1 : self.numGroups
                idx = ismember(self.assignments, self.groupings{i});
                a(idx) = i;
            end
            self.spikeView.setSpikes(self.t, self.ampl, a);
        end
        
        
        function handleKeyboard(self, evt)
            switch evt.Key
                case {'downarrow', 'hyphen'}
                    self.expandSel(-1);
                case {'uparrow', 'equal', 'plus'}
                    self.expandSel(1);
                case 'leftarrow'
                    self.moveSel(-1);
                case 'rightarrow'
                    self.moveSel(1);
            end
            
            switch evt.Character
                case {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
                    k = str2double(evt.Key);
                    k = k + 10 * (k == 0);
                    self.setSelection(self.selFirst, self.selFirst + k - 1);
                case 'h'
                    disp ' '
                    disp 'Key bindings'
                    disp ' '
                    disp ' down  | shrink selection'
                    disp ' up    | expand selection'
                    disp ' left  | move selection backward'
                    disp ' right | move selection forward'
                    disp ' h     | help'
                    disp ' 0-9   | select N clusters (0: select 10)'
                    disp ' '
            end
        end
        
        
        function resize(self)
            height = self.fig.Position(4);
            h = self.btnHeight;
            s = self.spacing;
            self.upBtn.Position(2) = height - s - h;
            self.downBtn.Position(2) = self.upBtn.Position(2) - h;
            self.lessBtn.Position(2) = self.downBtn.Position(2) - s - h;
            self.moreBtn.Position(2) = self.lessBtn.Position(2) - h;
            self.groupBtn.Position(2) = self.moreBtn.Position(2) - s - h;
            self.ungroupBtn.Position(2) = self.groupBtn.Position(2) - h;
            self.table.Position(4) = height - 2 * s;
        end
        
        
        function close(self)
            delete(self.ccgView)
            delete(self.spikeView)
            delete(self.waveView)
        end
        
    end
end


function html = colorPatch(color)
    color = round(color * 255);
    html = sprintf('<html><div style="background: #%s%s%s; width: 25px; height: 8px"></div></html>', ...
        dec2hex(color(1), 2), dec2hex(color(2), 2), dec2hex(color(3), 2));
end


function str = groupStr(n)
    if n > 1
        str = num2str(n);
    else
        str = '';
    end
end
    

