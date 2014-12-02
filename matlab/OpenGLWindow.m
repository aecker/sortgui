classdef OpenGLWindow < handle
    % OpenGL window for Matlab using Java (JOGL).
    
    properties (Access = protected)
        fig         % figure handle
        glcanvas    % uicomponent handles
    end
    
    methods
        function self = OpenGLWindow(name)
            % Constructor for OpenGLWindow.
            
            self.fig = figure('MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', name);
            [self.glcanvas.hdl, self.glcanvas.jcomp] = uicomponent('Style', 'javax.media.opengl.awt.GLCanvas', 'Parent', self.fig);
            set(self.glcanvas.hdl, 'Units', 'normalized', 'Position', [0 0 1 1])
        end
        
        function delete(self)
            % Destructor for MCorrelogramView.
            
            if isvalid(self.fig)
                close(self.fig)
            end
        end
        
        function set(self, varargin)
            % Set figure property.
            %   set(self, 'prop', val) sets the given property of the CCG
            %   figure window to val.
            
            set(self.fig, varargin{:});
        end
        
        function varargout = get(self, varargin)
            % Get figure property.
            %   val = get(self, 'prop') returns the value of the given
            %   property of the CCG figure window.
            
            [varargout{:}] = get(self.fig, varargin{:});
        end
        
        function resize(self, width, height)
            % Resize figure window.
            
            pos = get(self.fig, 'Position');
            pos(3) = width;
            h = pos(4);
            pos(2) = pos(2) + h - height;
            pos(4) = height;
            set(self.fig, 'Position', pos);
        end
    end

    methods (Access = protected)
        function repaint(self)
            self.glcanvas.jcomp.repaint();
        end            
    end
end
