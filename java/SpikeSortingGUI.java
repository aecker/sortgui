import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.Random;

import javax.media.opengl.awt.GLCanvas;

public class SpikeSortingGUI {

	public static void main(String[] args) {
        Frame frame = new Frame("Spike Sorting GUI");
        GLCanvas canvas = new GLCanvas();
        CorrelogramView gui = new CorrelogramView(canvas);
        canvas.addGLEventListener(gui);
        frame.add(canvas);
        frame.setSize(500, 300);
        frame.setVisible(true);
        frame.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
        
        // show some data
        int m = 10, n = 21;
        Random rand = new Random();
        float[][][] ccg = new float[m][m][n];
        for (int i = 0; i != m; ++i) {
        	for (int j = i; j != m; ++j) {
        		for (int k = 0; k != n; ++k) {
        			ccg[i][j][k] = rand.nextFloat();
        			ccg[j][i][n - k - 1] = ccg[i][j][k]; 
        		}
        	}
        }
        gui.setData(ccg);
        int[] sel = {1, 9};
        gui.setSelected(sel);
    }
}
