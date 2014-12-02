import javax.swing.JFrame;

import java.awt.GridLayout;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.Random;

import javax.media.opengl.awt.GLCanvas;

public class SpikeSortingGUI {

	public static void main(String[] args) {
        JFrame frame = new JFrame("Spike Sorting GUI");
        frame.setLayout(new GridLayout());
        
        GLCanvas canvas = new GLCanvas();
        CorrelogramView ccgView = new CorrelogramView(canvas);
        canvas.addGLEventListener(ccgView);
        frame.add(canvas);
        
        canvas = new GLCanvas();
        SpikeTimeView spikeView = new SpikeTimeView(canvas);
        canvas.addGLEventListener(spikeView);
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
        ccgView.setCCG(ccg);
        int[] sel = {1, 9};
        ccgView.setSelected(sel);
        
        m = 10;
        n = 10000;
        spikeView.setNumCells(m);
        for (int i = 0; i != m; ++i) {
        	float[] times = new float[n];
            float[] amplitudes = new float[n];
            times[0] = rand.nextFloat();
        	amplitudes[0] = (float) (1 + rand.nextGaussian() / 20.0);
        	for (int j = 1; j != n; ++j) {
        		times[j] = times[j - 1] - (float) Math.log(1 - rand.nextDouble());
            	amplitudes[j] = (float) (1 + rand.nextGaussian() / 20.0);
        	}
            spikeView.setSpikes(i, times, amplitudes);
        }
        spikeView.setSelected(sel);
    }
}
