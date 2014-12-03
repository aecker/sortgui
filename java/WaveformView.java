import javax.media.opengl.GL;
import javax.media.opengl.GL2;
import javax.media.opengl.GLAutoDrawable;


public class WaveformView extends View {

	int neurons; // number of templates
	int channels; // number of channels
	float[][][][] waveforms;
	int[] peaks;
	float[] locx, locy;
	float spacing;
	int padding;
	
	public WaveformView() {
		waveforms = new float[0][0][0][0];
		peaks = new int[0];
		locx = new float[0];
		locy = new float[0];
		spacing = 100;
		padding = 2;
	}
	
	public void setChannelLayout(float[] x, float[] y) {
		locx = x;
		locy = y;
	}
	
	public void setWaveforms(float[][][][] w, int[] p) {
		waveforms = w;
		peaks = p;
		repaint = true;
	}
	
	public void setSpacing(float s) {
		spacing = s;
	}
	
	public void setPadding(int p) {
		padding = p;
	}

	@Override
	protected DisplayLists genLists(GL2 gl) {
		neurons = waveforms.length;
		if (neurons == 0) {
			return new DisplayLists(gl, 0);
		}
		channels = waveforms[0].length;
		int blocks = waveforms[0][0].length;
		int samples = waveforms[0][0][0].length;
		DisplayLists lists = new DisplayLists(gl, neurons * channels);
		for (int i = 0; i != neurons; ++i) {
			for (int j = 0; j != channels; ++j) {
				lists.newList(i + j * neurons);
				float[] c = colors.getColor(i);
				gl.glPushMatrix();
				gl.glScalef(1 / (float) samples, 1, 1);
				gl.glColor3f(c[0], c[1], c[2]);
				for (int k = 0; k != blocks; ++k) {
					gl.glBegin(GL2.GL_LINE_STRIP);
					float[] w = waveforms[i][j][k];
					for (int l = 0; l != samples; ++l) {
						gl.glVertex2f(l, w[l]);
					}
					gl.glEnd();
				}
				gl.glPopMatrix();
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
		
		if (channels == 0) return;

		// determine range of channels to plot
		int first = channels - 1, last = 0;
		for (int i = 0; i != selected.length; ++i) {
			first = Math.min(first, peaks[selected[i]]);
			last = Math.max(last, peaks[selected[i]]);
		}
		first = Math.max(first - padding, 0);
		last = Math.min(last + padding, channels - 1);
		
		// determine number of columns
		float xdist = 1;
		for (int i = 0; i != channels; ++i) {
			xdist = Math.max(xdist, locx[i] + 1);
		}
		
		// set coordinate system
		float left = 0;
		float right = selected.length * xdist;
		float bottom = (locy[first] - 1) * spacing;
		float top = (locy[last] + 1) * spacing;
		gl.glOrtho(left, right, bottom, top, -1, 1);

		// draw waveforms
		for (int i = 0; i != selected.length; ++i) {
			for (int j = first; j <= last; ++j) {
				gl.glPushMatrix();
				gl.glTranslatef(locx[j] + i * xdist, locy[j] * spacing, 0);
				callList(selected[i] + j * neurons);
				gl.glPopMatrix();
			}
		}
	}
}
