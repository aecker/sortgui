classdef MCorrelogramView < MView
    % Correlogram view (Matlab interface for Java class CorrelogramView).
    
    methods
        function self = MCorrelogramView()
            % Constructor for MCorrelogramView.
            
            self = self@MView(CorrelogramView(), 'Cross-correlograms');
            self.jobj.OpenCallback = @(evt) disp(evt);
        end
        
        function setCCG(self, ccg)
            % Set cross-correlograms.
            %   self.setCCG(ccg) sets the cross-correlograms. The 3d array
            %   ccg is of size #bins-by-K-by-K, where K is the number of
            %   neurons.
            
            ccg = bsxfun(@rdivide, ccg, max(ccg));
            ccg = permute(ccg, [3 2 1]);
            self.jobj.setCCG(ccg);
            self.repaint();
        end
        
        function setSelected(self, sel)
            % Set selection of neurons whose CCGs are shown.
            %   self.setSelected(sel) sets the selection to the neuron
            %   indices specified by sel. Indices are one-based.
            
            self.jobj.setSelected(int32(sel - 1));
            self.repaint();
        end
    end
end
