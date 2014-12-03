classdef MSpikeTimeView < MView
    % Spike time view (Matlab interface for Java class SpikeTimeView).
    
    methods
        function self = MSpikeTimeView()
            % Constructor for MSpikeTimeView.
            
            self = self@MView(SpikeTimeView(), 'Spike times and amplitudes');
        end
        
        function setSpikes(self, times, amplitudes, assignments)
            % Set spike times and amplitudes
            %   self.setSpikes(times, amplitudes, assignments) sets the
            %   spike times, amplitudes, and cluster assignments. All three
            %   are vectors of the same length.
            
            K = max(assignments);
            self.jobj.setNumCells(K);
            for i = 1 : K
                ndx = assignments == i;
                self.jobj.setSpikes(i - 1, times(ndx), amplitudes(ndx));
            end
            self.repaint();
        end
    end
end
