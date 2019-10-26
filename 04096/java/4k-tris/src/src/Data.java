import java.awt.Color;
import java.awt.Rectangle;
import java.io.ObjectOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.*;

public class Data {
	private static final int BOX_SIZE = 25;
	private static final int FIELD_WIDTH = 11;
	private static final int FIELD_HEIGHT = 20;

	private static final int WINDOW_WIDTH = FIELD_WIDTH*BOX_SIZE * 2;
	private static final int WINDOW_HEIGHT = FIELD_HEIGHT*BOX_SIZE + 65;

	private static final int FIELD_SHIFT = 40;


	private final byte[]sound1 = new byte[] {
		125, 126, 126, 125, 124, 124, 123, 123, 125, 124, 122, 119, 
		-126, -117, -1, 0, -104, -1, -124, 0, -81, -1, -119, 12, -93,
		-40, -60, 75, 101, -89, -41, -119, 90, 125, -89, -105, 109,
		100, 117, -120, -124, 113, 
	};
	
	// 8 per line, 8*4 per block
	private final byte[]items = new byte[] {
		// indexes 0 - 223
		//T
		-1, 0, 0, 1, 0, 0, 0, -1,
		0, 1, -1, 0, 0, 0, 1, 0,
		0, 1, 0, 0, 0, -1, 1, 0,
		-1, 0, 0, 0, 1, 0, 0, -1,
		//--__
		-1, 0, -1, -1, 0, 1, 0, 0,
		-1, 0, 0, 0, 0, -1, 1, -1,
		-1, 0, -1, -1, 0, 1, 0, 0,
		-1, 0, 0, 0, 0, -1, 1, -1,
		//__--
		-1, 1, -1, 0, 0, 0, 0, -1, 
		0, 0, 1, 0, -1, -1, 0, -1,
		-1, 1, -1, 0, 0, 0, 0, -1, 
		0, 0, 1, 0, -1, -1, 0, -1,
		// !L
		-1,-1, 0, 1, 0, 0, 0, -1,
		-1, 1, -1, 0, 0, 0, 1, 0,
		0, 1, 0, 0, 0, -1, 1, 1,
		-1, 0, 0, 0, 1, 0, 1, -1,
		// L
		-1, 1, -1, 0, -1, -1, 0, -1,
		-2, 0, -1, 0, 0, 0, -2, -1,
		-2, 1, -1, 1, -1, 0, -1, -1,
		0, 1, -2, 0, -1, 0, 0, 0,
		//line
		0, 2, 0, 1, 0, 0, 0, -1,
		-1, 1, 0, 1, 1, 1, 2, 1,
		0, 2, 0, 1, 0, 0, 0, -1,
		-1, 1, 0, 1, 1, 1, 2, 1,
		//Square
		-1, 0, 0, 0, -1, -1, 0, -1,
		-1, 0, 0, 0, -1, -1, 0, -1,
		-1, 0, 0, 0, -1, -1, 0, -1,
		-1, 0, 0, 0, -1, -1, 0, -1,

		// sound1: 224 - 265 (len = 42)
		125, 126, 126, 125, 124, 124, 123, 123, 125, 124, 122, 119, 
		-126, -117, -1, 0, -104, -1, -124, 0, -81, -1, -119, 12, -93,
		-40, -60, 75, 101, -89, -41, -119, 90, 125, -89, -105, 109,
		100, 117, -120, -124, 113, 

	};
	private Color[]colors;

	private Rectangle[]rect;

	Rectangle[]initRect() {
		Rectangle[]r = new Rectangle[11];
		r[0] = new Rectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
		r[1] = new Rectangle(FIELD_SHIFT + 10, FIELD_SHIFT + 10, BOX_SIZE*FIELD_WIDTH+3, BOX_SIZE*FIELD_HEIGHT+3);
		r[2] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*4 + 10, 90, 70);
		r[3] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 130, BOX_SIZE*8 + 10, 90, BOX_SIZE*6);
		r[4] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 119, BOX_SIZE*4-1, 92, 72);
		r[5] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 119, BOX_SIZE*8-1, 92, BOX_SIZE*6 + 2);
		r[6] = new Rectangle(FIELD_SHIFT - 3, FIELD_SHIFT - 3, BOX_SIZE*FIELD_WIDTH+5, BOX_SIZE*FIELD_HEIGHT+5);
		r[7] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 121, BOX_SIZE*4+1, 88, 68);
		r[8] = new Rectangle(FIELD_WIDTH*BOX_SIZE + 121, BOX_SIZE*8+1, 88, BOX_SIZE*6 - 2);
		r[9] = new Rectangle(FIELD_SHIFT -1 , FIELD_SHIFT - 1, BOX_SIZE*FIELD_WIDTH+1, BOX_SIZE*FIELD_HEIGHT+1);
		r[10]= new Rectangle(WINDOW_WIDTH, 0, FIELD_WIDTH*BOX_SIZE, (FIELD_HEIGHT+2)*BOX_SIZE);

		return r;
	}

	Color[] initColors() {
		Color[]colors = new Color[11];
		for (int i = 0;i<8;i++) {
			int x1 = i & 1;
			int x2 = i & 2;
			int x3 = i & 4;
			colors[i] = new Color(x1 * 180, x2 * 90, x3 * 45);
			//colors[i+8] = Color.black;//new Color(x1 * 100 , x2 * 50, x3 * 25);
		}
		colors[8] = colors[7];
		colors[7] = colors[6];
		colors[6] = colors[8];
		//colors[7] = Color.black;
		colors[8] = new Color(167, 216, 225);
		colors[9] = new Color(180, 225, 179);
		colors[10] = new Color(83, 108, 112);
		/*for (int i = 0;i<colors.length;i++) {
			colors[i] = Color.black;
		}*/
		return colors;
	}
	
	/**
	 * Write the data into a file.
	 * @param fn The filename of the file to write data into.
	 */
	Data(final String fn) throws IOException {
		colors = initColors();
		rect = initRect();

		FileOutputStream os = new FileOutputStream(fn);
		ObjectOutputStream oos = new ObjectOutputStream(os);
		oos.writeObject(items);
//		oos.writeObject(sound1);
		oos.writeObject(colors);

//		oos.writeObject(rect);//new Rectangle(10,20,100,110));

		oos.close();


		System.out.println("Items len = " + items.length);
		System.out.println("Snd1  len = " + sound1.length);
	}

	public static void main(String[]args) throws IOException {
		new Data("o");
	}
}

