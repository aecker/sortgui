function glDisplay(~, evt)

% gl = javaObjectEDT(evt.glautodrawable.getGL());

% gl = javaObjectEDT(javaMethodEDT('getGL', evt));
% gl = javaObjectEDT(javaMethodEDT('getGL2', gl));

gl = javaMethodEDT('getGL', evt);
gl = javaMethodEDT('getGL2', gl);

% gl = evt.getGL();
% gl = gl.getGL2();

import javax.media.opengl.*

% gl.glMatrixMode(javax.media.opengl.GL2.GL_MODELVIEW);
% gl.glLoadIdentity();
% gl.glViewport(0, 0, 1, 1);
javaMethodEDT('glMatrixMode', gl, GL2.GL_MODELVIEW);
javaMethodEDT('glLoadIdentity', gl);
javaMethodEDT('glViewport', gl, 0, 0, 1, 1);
% f = javaObjectEDT(java.nio.FloatBuffer.allocate(4));
% javaMethodEDT('glGetFloatv', gl, GL2.GL_VIEWPORT, f);
% disp(javaMethodEDT('array', f)')

% gl.glMatrixMode(GL2.GL_PROJECTION);
% gl.glLoadIdentity();
% gl.glClearColor(0.2, 0.2, 0.2, 1);
% gl.glClear(GL.GL_COLOR_BUFFER_BIT);
% gl.glOrtho(0, 1, 0, 1, -1, 1);
javaMethodEDT('glMatrixMode', gl, GL2.GL_PROJECTION);
javaMethodEDT('glLoadIdentity', gl);
javaMethodEDT('glClearColor', gl, 0.2, 0.2, 0.2, 1);
javaMethodEDT('glClear', gl, GL.GL_COLOR_BUFFER_BIT);
javaMethodEDT('glOrtho', gl, 0, 1, 0, 1, -1, 1);

% % gl.glColor3f(1, 0, 0);
% % gl.glPointSize(10);
% % gl.glBegin(GL2.GL_POINTS);
% javaMethodEDT('glColor3f', gl, 1, 0, 0);
% javaMethodEDT('glPointSize', gl, 10);
% javaMethodEDT('glBegin', gl, GL2.GL_POINTS);
% n = 20;
% r = rand(n, 2);
% for i = 1 : n
% %     gl.glVertex2f(r(i, 1), r(i, 2));
%     javaMethodEDT('glVertex2f', gl, r(i, 1), r(i, 2));
% end
% % gl.glEnd();
% javaMethodEDT('glEnd', gl);
