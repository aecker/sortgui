import javax.media.opengl.GL2;


public class DisplayLists {
	
	int start, num;
	GL2 gl;
	
	public DisplayLists(GL2 gl, int num) {
		this.gl = gl;
		this.start = gl.glGenLists(num);
		this.num = num;
	}
	
	public void newList(int i) {
		gl.glNewList(start + i, GL2.GL_COMPILE);
	}
	
	public void callList(int i) {
		gl.glCallList(start + i);
	}
	
	public void delete() {
		gl.glDeleteLists(start, num);
	}
}
