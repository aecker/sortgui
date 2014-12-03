import javax.media.opengl.GLEventListener;


public abstract class View implements GLEventListener {

	protected int[] selected;
	protected boolean repaint;
	protected ColorScheme colors;
	
	public View() {
		selected = new int[0];
		repaint = false;
		colors = new HSVColorScheme();
	}

	public void setColorScheme(ColorScheme c) {
		colors = c;
		repaint = true;
	}
	
	public void setSelected(int[] selected) {
		this.selected = selected;
	}

}
