import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;


public class SpikeTimeView extends View {

	int lists, n;
	float[][] times, amplitudes;
	float T;
	
	public SpikeTimeView() {
		times = new float[0][0];
		amplitudes = new float[0][0];
	}
	
	public void setNumCells(int n) {
		times = new float[n][0];
		amplitudes = new float[n][0];
		T = 0;
		repaint = true;
	}
	
	public void setSpikes(int i, float[] times, float[] amplitudes) {
		this.times[i] = times;
		this.amplitudes[i] = amplitudes;
		T = Math.max(T, times[times.length - 1]);
		repaint = true;
	}

	@Override
	public void display(GLAutoDrawable glautodrawable) {
		
		GL2 gl = glautodrawable.getGL().getGL2();

		if (repaint) {
			// remove existing display lists (if any)
			if (gl.glIsList(lists)) {
				gl.glDeleteLists(lists, n);
			}

			// create display lists
			n = times.length;
			lists = gl.glGenLists(n);
			for (int i = 0; i != n; ++i) {
				gl.glNewList(lists + i, GL2.GL_COMPILE);
				gl.glPushMatrix();
				float[] c = colors.getColor(i);
				gl.glColor3f(c[0], c[1], c[2]);
				gl.glBegin(GL2.GL_POINTS);
				float[] t = times[i], a = amplitudes[i];
				for (int j = 0; j != t.length; ++j) {
					gl.glVertex2f(t[j], a[j] - 1);
				}
				gl.glEnd();
				gl.glPopMatrix();
				gl.glEndList();
			}
			repaint = false;
		}

		// clear background & set coordinate system
		gl.glMatrixMode(GL2.GL_PROJECTION);
        gl.glLoadIdentity();
        gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
        gl.glClear(GL.GL_COLOR_BUFFER_BIT);
        gl.glOrtho(0.0f, T > 0 ? T : 1, -0.5f, selected.length - 0.5f, -1, 1);

        // draw lists
		gl.glTranslatef(0, selected.length, 0);
		for (int i = 0; i != selected.length; ++i) {
			gl.glTranslatef(0, -1, 0);
			gl.glCallList(lists + selected[i]);
        }
	}

	@Override
	public void dispose(GLAutoDrawable glautodrawable) {
		// delete display lists
		GL2 gl = glautodrawable.getGL().getGL2();
        if (gl.glIsList(lists)) {
			gl.glDeleteLists(lists, n);
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

}
