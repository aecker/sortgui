import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GLEventListener;


public abstract class View implements GLEventListener, MouseListener {

	protected int width, height;
	DisplayLists lists;
	boolean repaint;
	protected int[] selected;
	protected ColorScheme colors;
	
	public View() {
		selected = new int[0];
		repaint = true;
		colors = new HSVColorScheme();
	}

	public void setColorScheme(ColorScheme c) {
		colors = c;
		repaint = true;
	}
	
	public void setSelected(int[] sel) {
		selected = (sel == null) ? new int[0] : sel;
	}
	
	protected void repaint() {
		repaint = true;
	}

	@Override
	public void init(GLAutoDrawable glautodrawable) {
		lists = genLists(glautodrawable.getGL().getGL2());
		repaint = false;
	}

	@Override
	public void display(GLAutoDrawable glautodrawable) {
		if (repaint) {
			// remove existing display lists (if any)
			if (lists != null) {
				lists.delete();
			}
			lists = genLists(glautodrawable.getGL().getGL2());
			repaint = false;
		}
		draw(glautodrawable);
	}

	@Override
	public void dispose(GLAutoDrawable glautodrawable) {
		// delete display lists
		if (lists != null) {
			lists.delete();
		}
	}

	@Override
	public void reshape(GLAutoDrawable glautodrawable, int x, int y, int width, int height) {
		this.width = width;
		this.height = height;
		GL2 gl = glautodrawable.getGL().getGL2();
        gl.glMatrixMode(GL2.GL_MODELVIEW);
        gl.glLoadIdentity();
        gl.glViewport(0, 0, width, height);
	}
	
	protected void callList(int i) {
		lists.callList(i);
	}
	
	protected abstract DisplayLists genLists(GL2 gl);
	
	protected abstract void draw(GLAutoDrawable glautodrawable);

	@Override
	public void mouseClicked(MouseEvent e) {
	}

	@Override
	public void mouseEntered(MouseEvent e) {
	}

	@Override
	public void mouseExited(MouseEvent e) {
	}

	@Override
	public void mousePressed(MouseEvent e) {
	}

	@Override
	public void mouseReleased(MouseEvent e) {
	}
}
