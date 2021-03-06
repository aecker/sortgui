import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;


public class SpikeTimeView extends View {

	float[][] times = new float[0][0], amplitudes = new float[0][0];
	int[][] groups = new int[0][0];
	float T = 0;
	
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
	
	public void setNumGroups(int n) {
		groups = new int[n][0];
	}
	
	public void setGroup(int i, int[] k) {
		groups[i] = k;
	}

	@Override
	public DisplayLists genLists(GL2 gl) {

		int n = times.length;
		DisplayLists lists = new DisplayLists(gl, n);
		for (int i = 0; i != n; ++i) {
			lists.newList(i);
			gl.glBegin(GL2.GL_POINTS);
			float[] t = times[i], a = amplitudes[i];
			for (int j = 0; j != t.length; ++j) {
				gl.glVertex2f(t[j], a[j] - 1);
			}
			gl.glEnd();
			gl.glEndList();
		}
		return lists;
	}
		
	@Override
	protected void draw(GLAutoDrawable glautodrawable) {

		// clear background & set coordinate system
		GL2 gl = glautodrawable.getGL().getGL2();
		gl.glMatrixMode(GL2.GL_PROJECTION);
        gl.glLoadIdentity();
        gl.glClearColor(0.2f, 0.2f, 0.2f, 1);
        gl.glClear(GL.GL_COLOR_BUFFER_BIT);
        gl.glOrtho(0.0f, T > 0 ? T : 1, -0.5f, selected.length - 0.5f, -1, 1);

        // draw lists
		gl.glTranslatef(0, selected.length, 0);
		for (int i = 0; i != selected.length; ++i) {
			gl.glTranslatef(0, -1, 0);
			float[] c = colors.getColor(selected[i]);
			gl.glColor3f(c[0], c[1], c[2]);
			for (int j = 0; j != groups[selected[i]].length; ++j) {
				callList(groups[selected[i]][j]);
			}
        }
	}

}
