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
        
        canvas = new GLCanvas();
        WaveformView waveView = new WaveformView ();
        canvas.addGLEventListener(waveView);
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
        int[] sel = {2, 3, 4};
        ccgView.setSelected(sel);
        
        // show some random spike times
        M = 10;
        N = 10000;
        spikeView.setNumCells(M);
        spikeView.setNumGroups(M);
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
            int[] k = {i};
            spikeView.setGroup(i, k);
        }
        spikeView.setSelected(sel);
        
        // show some random waveforms
        float[] spike = {0, 10, 18, 10, -25, -60, -35, -11, 0, 7, 10, 12, 13, 13, 12, 10, 7, 3, 1, 0};
        int D = spike.length;
        int K = 12;
        float[] locx = {0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1};
        float[] locy = {0, 0.5f, 1, 1.5f, 2, 2.5f, 3, 3.5f, 4, 4.5f, 5, 5.5f};
        float[][][][] waveforms = new float[M][K][1][D];
        int[] peaks = new int[M];
        float a, px, py = 1, sdx, sdy, dx, dy;
        for (int i = 0; i != M; ++i) {
        	px = rand.nextFloat();
        	py += rand.nextFloat() * 0.8;
        	peaks[i] = Math.round(2 * py);
        	sdx = 0.2f + rand.nextFloat() * 0.3f;
        	sdy = 1 + (float) (rand.nextGaussian() * 0.2);
        	for (int j = 0; j != K; ++j) {
        		dx = (locx[j] - px) / sdx;
        		dy = (locy[j] - py) / sdy;
                a = (float) Math.exp(-0.5 * (dx * dx + dy * dy));
                for (int k = 0; k != D; ++k) {
        			waveforms[i][j][0][k] = a * spike[k];
        		}
        	}
        }
        waveView.setChannelLayout(locx, locy);
        waveView.setWaveforms(waveforms, peaks);
        waveView.setSelected(sel);
    }
}
