
public class MyColorScheme implements ColorScheme {

	float[][] colors;
	
	public MyColorScheme(float[][] c) {
		colors = c;
	}
	
	@Override
	public float[] getColor(int i) {
		return colors[i % colors.length];
	}

}
