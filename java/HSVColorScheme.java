
public class HSVColorScheme implements ColorScheme {

	private static float[][] colors = {
		{1, 0, 0}, {0.8f, 1, 0}, {0, 0.8f, 1}, {1, 0, 0.6f}, {1, 0.8f, 0},  
		{0, 1, 0.8f}, {0.7f, 0, 1}, {1, 0.4f, 0}, {0.4f, 1, 0}, {0, 0.4f, 1}
	};
	
	@Override
	public float[] getColor(int i) {
		return colors[i % colors.length];
	}

}
