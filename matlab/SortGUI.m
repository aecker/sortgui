classdef SortGUI < handle
    
    properties
        fig
        table
        selection
        up
        down
        more
        less
        colorScheme
        ccgView
        spikeView
        waveView
        singleUnits
        ignore
        rate
        selFirst
        selLast
        M
    end
    
    properties (Access = private, Constant)
        spacing = 8;
        btnHeight = 30;
    end
    
    
    methods
        
        function self = SortGUI(t, assignments, ampl, W, channelLayout)
            
            % GUI main window
            height = 400;
            width = 270;
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
            self.M = max(assignments);
            s = self.spacing;
            h = height - 2 * s;
            w = 200;
            pos = [s, height - h - s, w, h];
            
            self.table = uitable('Data', {}, 'RowName', [], ...
                'ColumnName', {'Color', 'SU', 'Rate', 'Ignore'}, ...
                'ColumnWidth', {40 20 40 40}, ...
                'ColumnEditable', [false, true, false, true], ...
                'BackgroundColor', [1 1 1], ...
                'Position', pos, 'FontSize', 12, ...
                'CellEditCallback', @(src, evt) self.tableEdit(src, evt));
            
            % buttons for moving the list
            h = self.btnHeight;
            wi = 40;
            pos = [2 * s + w, height - s - h, wi, h];
            self.up = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '//\\', 'Callback', @(~, ~) self.moveSel(-1));
            pos = [2 * s + w, height - s - 2 * h, wi, h];
            self.down = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '\\//', 'Callback', @(~, ~) self.moveSel(1));
            
            % buttons for selecting more or less clusters
            pos = [2 * s + w, height - 2 * s - 3 * h, wi, h];
            self.less = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '-', 'Callback', @(~, ~) self.expandSel(-1));
            pos = [2 * s + w, height - 2 * s - 4 * h, wi, h];
            self.more = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '+', 'Callback', @(~, ~) self.expandSel(1));
            
            % cross-correlograms
            ccg = correlogram(t, assignments, self.M, 0.2, 10);
            self.ccgView = MCorrelogramView;
            self.ccgView.setCCG(ccg)
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
            self.rate = histc(assignments, 1 : self.M) / (t(end) - t(1)) * 1000;
            self.singleUnits = false(self.M, 1);
            self.ignore = false(self.M, 1);
            self.setSelection(1, 15);
            
            set(self.fig, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.up, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.down, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.less, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.more, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.table, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.ccgView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.waveView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.spikeView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
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
            if last > self.M
                first = first - last + self.M;
                last = self.M;
            end
            if first < 1
                last = last + 1 - first;
                first = 1;
            end
            self.selFirst = min(self.M, max(1, first));
            self.selLast = min(self.M, max(self.selFirst, last));
            indices = (self.selFirst : self.selLast)';
            
            % update stats table
            colors = arrayfun(@(k) colorPatch(self.colorScheme.getColor(k - 1)), indices, 'uni', false);
            [colors{self.ignore(indices)}] = deal('');
            self.table.RowName = num2cell(indices);
            self.table.Data = [colors, num2cell(self.singleUnits(indices)), ...
                arrayfun(@(x) sprintf('<html><p align="right" width=35">%.1f</p></html>', x), self.rate(indices), 'uni', false), ...
                num2cell(self.ignore(indices))];
            
            % update views
            sel = indices(~self.ignore(indices));
            self.ccgView.setSelected(sel);
            self.spikeView.setSelected(sel);
            self.waveView.setSelected(sel);
        end
        
        function tableEdit(self, ~, evt)
            indices = self.selFirst : self.selLast;
            switch evt.Indices(2)
                case 2
                    self.singleUnits(indices(evt.Indices(1))) = evt.NewData;
                case 4
                    self.ignore(indices(evt.Indices(1))) = evt.NewData;
            end
            self.setSelection(self.selFirst, self.selLast);
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

