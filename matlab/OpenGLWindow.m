classdef OpenGLWindow < handle
    % OpenGL window for Matlab using Java (JOGL).
    
    properties (Access = private)
        fig     % figure handle
        hdl     % uicomponent matlab handle
        toolbarHeight   % height of toolbar at the top of the window
        toolbar         % handles of toolbar components (struct: h, j)
    end
    
    properties (Access = private, Constant)
        toolbarSpacing = 8;   % px between toolbar components
    end
    
    events
        MouseClicked
        KeyPressed
    end
    
    methods
        function self = OpenGLWindow(evtListener, name, toolbarHeight)
            % Constructor for OpenGLWindow.
            
            if nargin  < 3
                self.toolbarHeight = 0;
            else
                self.toolbarHeight = toolbarHeight;
            end
            self.toolbar = {};
            self.fig = figure('MenuBar', 'none', 'ToolBar', 'none', 'NumberTitle', 'off', 'Name', name);
            self.hdl = uicomponent('Style', 'javax.media.opengl.awt.GLCanvas', 'Parent', self.fig, 'Position', [0 0 10 10]);
            set(self.fig, 'SizeChangedFcn', @(~, ~) self.onResize());
            self.onResize();
            self.hdl.JavaComponent.addGLEventListener(evtListener);
            
            % set up events
            self.hdl.MouseClickedCallback = @(src, evt) self.notify('MouseClicked', MouseClickedEventData(handle(evt)));
            self.hdl.KeyPressedCallback = @(src, evt) self.notify('KeyPressed', KeyPressedEventData(handle(evt)));
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
            
            k = nargout;
            [varargout{1 : k}] = get(self.fig, varargin{:});
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
        
        function repaint(self)
            self.hdl.JavaComponent.repaint();
        end
        
        function delete(self)
            if ishghandle(self.fig)
                close(self.fig)
            end
        end
        
    end
    
    
    methods (Access = protected)
        
        function h = addToToolbar(self, style, width, varargin)
            % Add UI component to toolbar.
            %   [h, j] = addToToolbar('JSpinner', 100) adds a 100px-wide
            %   JSpinner to the toolbar (using uicomponent()) and returns
            %   the Matlab and Java handles.
            
            x = self.getToolbarWidth() + self.toolbarSpacing;
            y = self.getToolbarBottom();
            p = [x, y, width, self.toolbarHeight];
            h = uicomponent('Style', style, 'Parent', self.fig, 'Position', p, varargin{:});
            self.toolbar{end + 1} = h;
        end
        
    end
    
    
    methods (Access = private)
        
        function onResize(self)
            w = self.fig.Position(3) + 1;
            h = self.getToolbarBottom();
            self.hdl.Position(3 : 4) = [w, h];
            for i = 1 : numel(self.toolbar)
                self.toolbar{i}.Position(2) = h;
            end
        end
        
        function w = getToolbarWidth(self)
            if isempty(self.toolbar)
                w = 0;
            else
                p = self.toolbar{end}.Position;
                w = p(1) + p(3);
            end
        end
        
        function b = getToolbarBottom(self)
            b = self.fig.Position(4) - self.toolbarHeight;
        end
        
    end
    
end
