import java.io.*;

public class LevelMaker
{
	public static void main( String[] args )
	{
		String inf = "levels.txt";
		String outf = "../src/LevelData.java";

		try
		{
			StringBuffer data = new StringBuffer();

			System.out.println( "Reading file: " + inf );
			BufferedReader in = new BufferedReader( new FileReader( inf ) );

			int level_count = 0;

			while ( true )
			{
				String percent_line = in.readLine();
				if ( percent_line.equals( "END" ) )
					break;

				++level_count;

				float percent = Float.parseFloat( percent_line ) / 100.f;
				int complete_value = (int)(percent*255.f);
				data.append( (char)complete_value );

				for ( int y = 0; y < 8; ++y )
				{
					String line = in.readLine();
					int idx = 0;
					int left = 8 / 2;
					while ( left-- > 0 )
					{
						int v1 = mapChar( line, idx++ );
						int v2 = mapChar( line, idx++ );
						int v = v1 | (v2 << 4);

						data.append( (char) v );
					}
				}
			}

			in.close();

			System.out.println( "Number of levels: " + level_count );

			System.out.println( "Writing file: " + outf );
			PrintWriter out = new PrintWriter( new FileWriter( outf ) );

			out.println( "// GENERATED FILE BY LevelMaker!" );
			out.println( "public final class LevelData" );
			out.println( "{" );
			out.print( "\tpublic static final String LEVELS = \"" );
			String out_data = data.toString();
			for ( int i = 0; i < out_data.length(); ++i )
			{
				char c = out_data.charAt( i );
				out.print( '\\' );
				out.print( Integer.toOctalString(c) );
			}
			out.println( "\";" );
			out.println( "}" );
			out.close();
		}
		catch ( Throwable t )
		{
			t.printStackTrace();
		}
		finally
		{
			System.out.println( "Done!" );
		}
	}

	private static int mapChar( String line, int idx )
	{
		if ( idx < 0 || idx >= line.length() )
			return 0;

		switch ( line.charAt( idx ) )
		{
		case '*':
		case '#':	return 1;
		case '-':	return 2;
		case 'o':
		case 'O':	return 3;
		case 'x':
		case 'X':	return 4;
		case '<':	return 5;
		case '^':	return 6;
		case '>':	return 7;
		case 'v':	return 8;
		}
		return 0;
	}
}
