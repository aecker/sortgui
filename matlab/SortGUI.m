classdef SortGUI < handle
    
    properties
        fig
        selection
        up
        down
        more
        less
        ccgView
        spikeView
        waveView
    end
    
    properties (Access = private, Constant)
        spacing = 8;
    end
    
    
    methods
        
        function self = SortGUI(t, assignments, ampl, W, channelLayout)
            
            % GUI main window
            height = 400;
            width = 130;
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
            
            % cluster list
            M = max(assignments);
            s = self.spacing;
            h = height - 2 * s;
            w = 50;
            pos = [s, height - h - s, w, h];
            v = arrayfun(@num2str, 1 : M, 'uni', false);
            self.selection = uicontrol('Style', 'list', 'Position', pos, ...
                'Min', 0, 'Max', Inf, 'FontSize', 12, 'String', v);
            
            % buttons for moving the list
            h = 30;
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
            ccg = correlogram(t, assignments, M, 0.2, 10);
            self.ccgView = MCorrelogramView;
            self.ccgView.setCCG(ccg)
            w = 600;
            set(self.ccgView, 'Position', [left + width, top - height, w, height]);
            
            % waveforms
            th = 22;
            self.waveView = MWaveformView;
            self.waveView.setChannelLayout(channelLayout(:, 1), channelLayout(:, 2))
            self.waveView.setWaveforms(W)
            set(self.waveView, 'Position', [left + width, top - 2 * height - th, w, height]);
            
            % spike times
            self.spikeView = MSpikeTimeView;
            self.spikeView.setSpikes(t, ampl, assignments)
            set(self.spikeView, 'Position', [left + width + w, top - height, w, height]);
            
            % set selection
            sel = 1 : min(8, M);
            self.selection.Callback = @(src, ~) self.setSelected(src.Value);
            self.setSelected(sel);
            
            self.fig.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            self.up.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            self.down.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            self.less.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            self.more.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            self.selection.KeyPressFcn = @(~, evt) self.handleKeyboard(evt);
            set(self.ccgView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.waveView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
            set(self.spikeView, 'KeyPressFcn', @(~, evt) self.handleKeyboard(evt));
        end
        
    end
    
    
    methods (Access = private)
        
        function moveSel(self, i)
            sel = self.selection.Value;
            s = min(sel);
            e = max(sel);
            if s + i < 1 || e + i > numel(self.selection.String)
                return
            end
            ignore = setdiff(s : e, sel);
            self.setSelected(setdiff(s + i : e + i, ignore));
        end
        
        function expandSel(self, i)
            sel = self.selection.Value;
            s = min(sel);
            e = max(sel);
            ignore = setdiff(s : e, sel);
            if e + i > numel(self.selection.String)
                if s - i < 1
                    return
                end
                self.setSelected(setdiff(s - i : e, ignore));
            else
                self.setSelected(setdiff(s : e + i, ignore));
            end
        end
        
        function setSelected(self, sel)
            if ~isequal(self.selection.Value, sel)
                self.selection.Value = sel;
            end
            self.ccgView.setSelected(sel);
            self.spikeView.setSelected(sel);
            self.waveView.setSelected(sel);
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
                case 'h'
                    disp ' '
                    disp 'Key bindings'
                    disp ' '
                    disp ' down  | shrink selection'
                    disp ' up    | expand selection'
                    disp ' left  | move selection backward'
                    disp ' right | move selection forward'
                    disp ' h     | help'
                    disp ' '
            end
        end
        
    end
end