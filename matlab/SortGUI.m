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
            pos = [left, top, width, height];
            self.fig = figure('MenuBar', 'none', 'ToolBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'Selection', 'Position', pos);
            
            % cluster list
            s = self.spacing;
            h = height - 2 * s;
            w = 50;
            pos = [s, height - h - s, w, h];
            v = arrayfun(@num2str, [1 : 30 100], 'uni', false);
            self.selection = uicontrol('Style', 'list', 'Position', pos, ...
                'Min', 0, 'Max', Inf, 'FontSize', 12, 'String', v, ...
                'Callback', @selectionChanged);
            
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
            self.up = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '-', 'Callback', @(~, ~) self.expandSel(-1));
            pos = [2 * s + w, height - 2 * s - 4 * h, wi, h];
            self.down = uicontrol('Style', 'pushbutton', 'Position', pos, ...
                'FontSize', 14, 'String', '+', 'Callback', @(~, ~) self.expandSel(1));
            
            % cross-correlograms
            M = max(assignments);
            ccg = correlogram(t, assignments, M, 0.2, 10);
            self.ccgView = MCorrelogramView;
            self.ccgView.setCCG(ccg)
            w = 600;
            set(self.ccgView, 'Position', [left + width, top - height, w, height]);
            
            % waveforms
            self.waveView = MWaveformView;
            self.waveView.setChannelLayout(channelLayout(:, 1), channelLayout(:, 2))
            self.waveView.setWaveforms(W)
            set(self.waveView, 'Position', [left + width, top - 2 * height, w, height]);
            
            % spike times
            self.spikeView = MSpikeTimeView;
            self.spikeView.setSpikes(t, ampl, assignments)
            set(self.spikeView, 'Position', [left + width + w, top - height, w, height]);
            
            % set selection
            sel = 1 : min(8, M);
            self.selection.Value = sel;
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
            self.selection.Value = setdiff(s + i : e + i, ignore);
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
                self.selection.Value = setdiff(s - i : e, ignore);
            else
                self.selection.Value = setdiff(s : e + i, ignore);
            end
        end
        
        function selectionChanged(src, ~)
            sel = src.Value;
            self.ccgView.setSelection(sel);
            self.spikeView.setSelection(sel);
            self.waveView.setSelection(sel);
        end
        
    end
end