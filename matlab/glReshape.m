function glReshape(~, evt)

% gl = javaObjectEDT(javaMethodEDT('getGL', evt.glautodrawable));
% gl = javaObjectEDT(gl.getGL2());

gl = javaMethodEDT('getGL', evt);
gl = javaMethodEDT('getGL2', gl);

% gl.glMatrixMode(javax.media.opengl.GL2.GL_MODELVIEW);
% gl.glLoadIdentity();
% gl.glViewport(0, 0, 1, 1);
javaMethodEDT('glMatrixMode', gl, javax.media.opengl.GL2.GL_MODELVIEW);
javaMethodEDT('glLoadIdentity', gl);
javaMethodEDT('glViewport', gl, 0, 0, 1, 1);
