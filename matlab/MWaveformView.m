classdef MWaveformView < MView
    % Waveform view (Matlab interface for Java class WaveformView).
    
    methods
        function self = MWaveformView()
            % Constructor for MWaveformView.
            
            self = self@MView(WaveformView(), 'Waveforms');
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
            self.jobj.setWaveforms(waveforms, peaks);
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
