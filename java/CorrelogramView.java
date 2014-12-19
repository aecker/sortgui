import java.awt.event.MouseEvent;

import javax.media.opengl.GL;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GL2;


public class CorrelogramView extends View {

	int n = 0, bins = 0;
	float[][][] ccg = new float[0][0][0];
	int padding = 0;

	@SuppressWarnings("rawtypes")
	java.util.Vector listeners = new java.util.Vector();

	@SuppressWarnings("unchecked")
	public void addCorrelogramViewListener(CorrelogramViewListener lis) {
		listeners.addElement(lis);
	}

	public void removeCorrelogramViewListener(CorrelogramViewListener lis) {
		listeners.removeElement(lis);
	}

	public interface CorrelogramViewListener extends java.util.EventListener {
		void open(CorrelogramViewEvent event);
	}

	public class CorrelogramViewEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		private int i, j;

		CorrelogramViewEvent(Object obj, int i, int j) {
			super(obj);
			this.i = i;
			this.j = j;
		}
		
		public int getI() { return i; }
		public int getJ() { return j; }
	}

	public void setCCG(float[][][] ccg) {
		this.ccg = ccg;
		n = ccg.length;
		bins = n > 0 ? ccg[0][0].length : 0;
		repaint = true;
	}
	
	@Override
	protected DisplayLists genLists(GL2 gl) {
		DisplayLists lists = new DisplayLists(gl, n * n);
		for (int i = 0; i != n; ++i) {
			for (int j = 0; j != n; ++j) {
				lists.newList(i * n + j);
				gl.glPushMatrix();
				gl.glScalef(1 / (float) bins, 1.0f, 1.0f);
				float[] c = colors.getColor(j);
				if (i == j) {
					gl.glColor3f(c[0], c[1], c[2]);
				} else {
					gl.glColor3f(0, 0, 0);
				}
				gl.glBegin(GL2.GL_QUADS);
				for (int k = 0; k != bins; ++k) {
					gl.glVertex2f(k, 0);
					gl.glVertex2f(k + 1, 0);
					gl.glVertex2f(k + 1, ccg[i][j][k]);
					gl.glVertex2f(k, ccg[i][j][k]);
				}
				gl.glEnd();
				gl.glPopMatrix();
				if (i != j) {
					c = colors.getColor(i);
					gl.glColor3f(c[0], c[1], c[2]);
					gl.glPointSize(5);
					gl.glBegin(GL2.GL_TRIANGLES);
					gl.glVertex2f(0.47f,  0);
					gl.glVertex2f(0.53f,  0);
					gl.glVertex2f(0.5f,  0.06f);
					gl.glEnd();
				}
				gl.glEndList();
			}
		}
		return lists;
	}
	
	@Override
	protected void draw(GLAutoDrawable glautodrawable) {

		// clear background
		GL2 gl = glautodrawable.getGL().getGL2();
		gl.glMatrixMode(GL2.GL_PROJECTION);
        gl.glLoadIdentity();
        gl.glClearColor(0.3f, 0.3f, 0.3f, 1);
        gl.glClear(GL.GL_COLOR_BUFFER_BIT);
		
		// select units to draw
        int numSelected = selected.length;
		if (numSelected == 0) return;
		int padl = Math.min(padding, selected[0]);
		int padr = Math.min(padding, n - selected[numSelected - 1] - 1); 
        int numTotal = numSelected + padl + padr;
        int[] sel = new int[numTotal];
		int i, j;
        for (i = 0; i != padl; ++i) sel[i] = selected[0] - padl + i;
		for (j = 0; j != numSelected; ++i, ++j) sel[i] = selected[j];
		for (j = 0; j != padr; ++i, ++j) sel[i] = selected[numSelected - 1] + 1 + j;

	     // set coordinate system
        gl.glOrtho(0.0f, sel.length, 0.0f, numSelected, -1, 1);

        // draw lists
		for (int row = 0; row != numSelected; ++row) {
        	for (int col = 0; col != sel.length; ++col) {
        		i = sel[row + padl];
        		j = sel[col];
        		gl.glPushMatrix();
        		gl.glTranslatef(col, numSelected - row - 1, 0);
        		gl.glScalef(0.9f,  0.9f,  1.0f);
        		callList(i * n + j);
        		gl.glPopMatrix();
        	}
        }
	}	

	@Override
	public void mouseClicked(MouseEvent e) {
		int x = e.getX(), y = e.getY();
		int n = selected.length;
		int i = Math.max(0,  Math.min(n - 1, (y * n) / height));
		int j = Math.max(0,  Math.min(n - 1, (x * n) / width));
		for (int k = 0; k < listeners.size(); ++k) {
			CorrelogramViewEvent event = new CorrelogramViewEvent(this, i, j);
			((CorrelogramViewListener) listeners.elementAt(k)).open(event);
		}
	}
}
