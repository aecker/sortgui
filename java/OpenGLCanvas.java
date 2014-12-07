import javax.media.opengl.GL;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLEventListener;


public class OpenGLCanvas implements GLEventListener {
	
	@SuppressWarnings("rawtypes")
	private java.util.Vector data = new java.util.Vector();
	
	@SuppressWarnings("unchecked")
	public void addOpenGLListener(OpenGLListener lis) {
		data.addElement(lis);
	}
	
	public void removeOpenGLListener(OpenGLListener lis) {
		data.removeElement(lis);
	}
	
	public interface OpenGLListener extends java.util.EventListener {
		void display(OpenGLEvent event);
		void dispose(OpenGLEvent event);
		void init(OpenGLEvent event);
		void reshape(OpenGLEvent event /*, int x, int y, int w, int h*/);
	}
	
	public class OpenGLEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		private GL gl;
		public GL getGL() {
			return gl;
		}
		OpenGLEvent(Object obj, GL gl) {
			super(obj);
			this.gl = gl;
		}
	}
	
	@Override
	public void display(GLAutoDrawable glautodrawable) {
		java.util.Vector dataCopy;
		dataCopy = (java.util.Vector) data.clone();
        for (int i = 0; i < dataCopy.size(); ++i) {
			OpenGLEvent event = new OpenGLEvent(this, glautodrawable.getGL());
			((OpenGLListener) dataCopy.elementAt(i)).display(event);
		}
	}

	@Override
	public void dispose(GLAutoDrawable glautodrawable) {
		for (int i = 0; i < data.size(); ++i) {
			OpenGLEvent event = new OpenGLEvent(this, glautodrawable.getGL());
			((OpenGLListener) data.elementAt(i)).dispose(event);
		}
	}

	@Override
	public void init(GLAutoDrawable glautodrawable) {
		for (int i = 0; i < data.size(); ++i) {
			OpenGLEvent event = new OpenGLEvent(this, glautodrawable.getGL());
			((OpenGLListener) data.elementAt(i)).init(event);
		}
	}

	@Override
	public void reshape(GLAutoDrawable glautodrawable, int x, int y, int w, int h) {
		for (int i = 0; i < data.size(); ++i) {
			OpenGLEvent event = new OpenGLEvent(this, glautodrawable.getGL());
			((OpenGLListener) data.elementAt(i)).reshape(event /*, x, y, w, h*/);
		}
	}
}
