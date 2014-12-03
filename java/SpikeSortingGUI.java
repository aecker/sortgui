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
        CorrelogramView ccgView = new CorrelogramView();
        canvas.addGLEventListener(ccgView);
        frame.add(canvas);
        
        canvas = new GLCanvas();
        SpikeTimeView spikeView = new SpikeTimeView();
        canvas.addGLEventListener(spikeView);
        frame.add(canvas);
        
        frame.setSize(500, 300);
        frame.setVisible(true);
        frame.addWindowListener(new WindowAdapter() {
            public void windowClosing(WindowEvent e) {
                System.exit(0);
            }
        });
        
        // show some data for CCGs
        int M = 10, N = 21;
        Random rand = new Random();
        float[][][] ccg = new float[M][M][N];
        for (int i = 0; i != M; ++i) {
        	for (int j = i; j != M; ++j) {
        		for (int k = 0; k != N; ++k) {
        			ccg[i][j][k] = rand.nextFloat();
        			ccg[j][i][N - k - 1] = ccg[i][j][k]; 
        		}
        	}
        }
        ccgView.setCCG(ccg);
        int[] sel = {1, 9};
        ccgView.setSelected(sel);
        
        // show some random spike times
        M = 10;
        N = 10000;
        spikeView.setNumCells(M);
        for (int i = 0; i != M; ++i) {
        	float[] times = new float[N];
            float[] amplitudes = new float[N];
            times[0] = rand.nextFloat();
        	amplitudes[0] = (float) (1 + rand.nextGaussian() / 20.0);
        	for (int j = 1; j != N; ++j) {
        		times[j] = times[j - 1] - (float) Math.log(1 - rand.nextDouble());
            	amplitudes[j] = (float) (1 + rand.nextGaussian() / 20.0);
        	}
            spikeView.setSpikes(i, times, amplitudes);
        }
        spikeView.setSelected(sel);
    }
}
