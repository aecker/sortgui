classdef MCorrelogramView
    % Correlogram view (Matlab interface for Java class CorrelogramView).
    
    properties (Access = private)
        fig         % figure handle
        glcanvas    % uicomponent handles
        jobj        % CorrelogramView Java object
    end
    
    methods
        function self = MCorrelogramView()
            % Constructor for MCorrelogramView.
            
            self.fig = figure('MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', 'Cross-correlograms');
            [self.glcanvas.hdl, self.glcanvas.jcomp] = uicomponent('Style', 'javax.media.opengl.awt.GLCanvas', 'Parent', self.fig);
            set(self.glcanvas.hdl, 'Units', 'normalized', 'Position', [0 0 1 1])
            self.jobj = CorrelogramView(self.glcanvas.jcomp);
            self.glcanvas.jcomp.addGLEventListener(self.jobj);
        end
        
        function setCCG(self, ccg)
            % Set cross-correlograms.
            %   self.setCCG(ccg) sets the cross-correlograms. The 3d array
            %   ccg is of size #bins-by-K-by-K, where K is the number of
            %   neurons.
            
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
    
    methods (Access = private)
        function repaint(self)
            self.glcanvas.jcomp.repaint();
        end            
    end
end
