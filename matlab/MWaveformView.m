classdef MWaveformView < MView
    % Waveform view (Matlab interface for Java class WaveformView).

    properties
        scaling
        padding
    end
    
    
    methods
        function self = MWaveformView()
            % Constructor for MWaveformView.
            
            self = self@MView(WaveformView(), 'Waveforms', 30);
            
            % add toolbar
            self.addToToolbar('JLabel', 55, 'Text', 'Spacing:', 'HorizontalAlignment', javax.swing.SwingConstants.RIGHT);
            self.scaling = self.addToToolbar('JSpinner', 60, 'Value', 15);
            self.scaling.StateChangedCallback = @(src, evt) self.setSpacing(src.Value);
            m = self.scaling.JavaComponent.getModel();
            m.setMinimum(java.lang.Integer(5));
            m.setStepSize(java.lang.Integer(5));

            self.addToToolbar('JLabel', 70, 'Text', 'Padding:', 'HorizontalAlignment', javax.swing.SwingConstants.RIGHT);
            self.padding = self.addToToolbar('JSpinner', 45, 'Value', 2);
            self.padding.StateChangedCallback = @(src, evt) self.setPadding(src.Value);
            m = self.padding.JavaComponent.getModel();
            m.setMinimum(java.lang.Integer(0));

        end
        
        function setChannelLayout(self, x, y)
            self.jobj.setChannelLayout(x, y);
        end
        
        function setWaveforms(self, waveforms)
            % Set waveforms
            %   self.setWaveforms(waveforms) sets the waveforms, a 4d array
            %   of [samples, channels, neurons, blocks].
            
            ampl = sum(sum(waveforms .^ 2, 1), 4);
            ampl = permute(ampl, [2 3 1]);
            [~, peaks] = max(ampl);
            waveforms = permute(waveforms, [3 2 4 1]);
            self.jobj.setWaveforms(waveforms, peaks - 1);
            self.repaint();
        end
        
        function setSpacing(self, s)
            self.jobj.setSpacing(s);
            self.repaint();
        end
        
        function setPadding(self, p)
            self.jobj.setPadding(p);
            self.repaint();
        end
    end
end
