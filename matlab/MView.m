classdef MView < OpenGLWindow
    % Matlab interface for Java class View.
    
    properties (Access = protected)
        jobj        % View Java object
    end
    
    methods
        function self = MView(jobj, title)
            % Constructor for MView.
            
            self = self@OpenGLWindow(title);
            self.jobj = jobj;
            self.glcanvas.jcomp.addGLEventListener(self.jobj);
        end
        
        function setSelected(self, sel)
            % Set selection of neurons to be shown.
            %   self.setSelected(sel) sets the selection to the neuron
            %   indices specified by sel. Indices are one-based.
            
            self.jobj.setSelected(int32(sel - 1));
            self.repaint();
        end
        
        function setColorScheme(self, c)
            % Set color scheme.
            %   self.setColorScheme(colors) sets the color scheme for the
            %   view. colors is an N-by-3 array of colors.
            
            scheme = MyColorScheme(c);
            self.jobj.setColorScheme(scheme);
            self.repaint();
        end
    end
end
