import javax.media.opengl.GL;
import javax.media.opengl.GLAutoDrawable;
import javax.media.opengl.GL2;


public class CorrelogramView extends View {

	int lists;
	int n, bins; 
	float[][][] ccg;
	int padding;
	
	public CorrelogramView() {
		ccg = new float[0][0][0];
		n = 0;
		bins = 0;
		padding = 2;
	}
	
	public void setCCG(float[][][] ccg) {
		this.ccg = ccg.clone();
		n = ccg.length;
		bins = n > 0 ? ccg[0][0].length : 0;
		repaint = true;
	}
	
	@Override
	public void display(GLAutoDrawable glautodrawable) {

		GL2 gl = glautodrawable.getGL().getGL2();

		if (repaint) {
			// remove existing display lists (if any)
			if (gl.glIsList(lists)) {
				gl.glDeleteLists(lists, n * n);
			}

			// create display lists
			lists = gl.glGenLists(n * n);
			for (int i = 0; i != n; ++i) {
				for (int j = 0; j != n; ++j) {
					gl.glNewList(lists + i * n + j, GL2.GL_COMPILE);
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
			repaint = false;
		}

		// clear background
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
        		gl.glCallList(pair2list(i, j));
        		gl.glPopMatrix();
        	}
        }
	}

	@Override
	public void dispose(GLAutoDrawable glautodrawable) {
		// delete display lists
		GL2 gl = glautodrawable.getGL().getGL2();
        if (gl.glIsList(lists)) {
			gl.glDeleteLists(lists, n * n);
		}		
	}

	@Override
	public void init(GLAutoDrawable glautodrawable) {
		
	}

	@Override
	public void reshape(GLAutoDrawable glautodrawable, int x, int y, int width, int height) {
		GL2 gl = glautodrawable.getGL().getGL2();
        gl.glMatrixMode(GL2.GL_MODELVIEW);
        gl.glLoadIdentity();
        gl.glViewport(0, 0, width, height);
	}
	
	private int pair2list(int i, int j) {
		return lists + i * n + j;
	}

}
