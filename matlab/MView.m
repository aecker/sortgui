classdef MView < OpenGLWindow
    % Matlab interface for Java class View.
    
    properties (Access = protected)
        jobj        % View Java object
    end
    
    methods
        function self = MView(jobj, title, varargin)
            % Constructor for MView.
            
            jobj = handle(jobj, 'CallbackProperties');
            self = self@OpenGLWindow(jobj, title, varargin{:});
            self.jobj = jobj;
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
            
            if isnumeric(c)
                c = MyColorScheme(c);
            end
            self.jobj.setColorScheme(c);
            self.repaint();
        end
    end
end
