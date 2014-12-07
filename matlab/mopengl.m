% OpenGL directly from Matlab


%% Option 1: directly in JFrame
gl = handle(OpenGLCanvas, 'CallbackProperties');
% set(gl, 'DisplayCallback', @(varargin) callbackOnEDTQueue(@glDisplay, varargin{:}))
set(gl, 'DisplayCallback', @glDisplay)
set(gl, 'ReshapeCallback', @glReshape)

glc = handle(javax.media.opengl.awt.GLCanvas);
glc.addGLEventListener(gl);

jframe = handle(javax.swing.JFrame);
jframe.setSize(300, 300)
jframe.setVisible(1)
jframe.add(glc)


%% Option 2: in figure using uicomponent
gl = handle(OpenGLCanvas, 'CallbackProperties');
set(gl, 'DisplayCallback', @(varargin) callbackOnEDTQueue(@glDisplay, varargin{:}))
win = OpenGLWindow(gl, 'Test');
% s = struct(win);
% s.hdl.Position = [0 0 300 300];
