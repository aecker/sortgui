classdef MSpikeTimeView < OpenGLWindow
    % Spike time view (Matlab interface for Java class SpikeTimeView).
    
    properties (Access = private)
        jobj        % SpikeTimeView Java object
    end
    
    methods
        function self = MSpikeTimeView()
            % Constructor for MSpikeTimeView.
            
            self = self@OpenGLWindow('Spike times and amplitudes');
            self.jobj = SpikeTimeView();
            self.glcanvas.jcomp.addGLEventListener(self.jobj);
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
        
        function setSelected(self, sel)
            % Set selection of neurons whose spike times are shown.
            %   self.setSelected(sel) sets the selection to the neuron
            %   indices specified by sel. Indices are one-based.
            
            self.jobj.setSelected(int32(sel - 1));
            self.repaint();
        end
    end
end
