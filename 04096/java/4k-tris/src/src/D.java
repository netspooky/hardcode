import java.io.*;

public class D {
	public static void main(String[]args) throws Exception {
		FileInputStream is = new FileInputStream("aa.raw");
		byte[]b = new byte[100];
		int len = is.read(b);
		for (int i = 0;i<len;i++) {
			System.out.print("" + b[i] + ", ");
		}
		is.close();
	}
}
