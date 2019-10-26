import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import java.applet.*;
import java.io.*;

/**
 * The main application class.
 * 
 * The fluid algorithm is derived from the work of Jos Stam, see http://www.dgp.toronto.edu/~stam/reality/Research/pub.html
 */
public class Main extends Applet implements Runnable, MouseListener, MouseMotionListener, KeyListener
{
    private static final boolean DEVELOPER_MODE = false;
    private boolean DEBUG_DRAW_VELOCITIES;
    
    private static final int BAR_HEIGHT = 16;
    private static final int SCR_WIDTH = 256;
    private static final int SCR_HEIGHT = 256 + BAR_HEIGHT * 2;
    private static final int SCR_PIXELS = SCR_WIDTH * SCR_HEIGHT;
    
    private static final int WIDTH = 64;
    private static final int HEIGHT = 64;
    private static final int PIXELS = WIDTH * HEIGHT;
    
    private static final int FPS = 40;
    private static final int FRAME_MS = 1000 / FPS;
    private static final float FRAME_TIME = 1.f / (float)FPS;
    
    private static final float DIFFUSE = 0.0f;
    private static final float VISCOSITY = 0.0005f;
    
    private static final String LEVELS = LevelData.LEVELS;
    
    private boolean running;
    private char pressed_char;
    private BufferedImage backbuffer;
    private int[] backbuffer_pixels;
    
    private boolean mouse_b1;
    private boolean mouse_b2;
    private int mouse_x;
    private int mouse_y;
    private int mouse_prev_x;
    private int mouse_prev_y;
    
    private int[] boundary;
    private int[] field;
    private float[] u;
    private float[] v;
    private float[] u_prev;
    private float[] v_prev;
    private float[] dens;
    private float[] dens_prev;
    
    private float goal_pulse;
    
    private int cur_level;
    private float collected;
    private float wasted;
    private float total;
    private float goal;
    private float left;

    private int score_at_start;
    private int level_score;
    private int hiscore;
    
    public void start()
    {
        running = true;
        backbuffer = new BufferedImage( SCR_WIDTH, SCR_HEIGHT, BufferedImage.TYPE_INT_BGR );
        backbuffer_pixels = new int[ SCR_PIXELS ];
        
        // Read the current hiscore
        try
        {
            InputStream in = getAppletContext().getStream( "a" );
            hiscore = in.read();
            hiscore |= in.read() << 8;
            hiscore |= in.read() << 16;
            hiscore |= in.read() << 24;
        }
        catch ( Throwable t )
        {
        }
        
        // Start(init) the game 
        startGame();
        
        // Init the running env
        addMouseListener( this );
        addMouseMotionListener( this );
        addKeyListener( this );
        (new Thread( this )).start();
    }
    
    public void stop()
    {
        running = false;
    }
    
    private final void startGame()
    {
        boundary = new int[ PIXELS ];
        field = new int[ PIXELS ];
        u = new float[ PIXELS ];
        v = new float[ PIXELS ];
        u_prev = new float[ PIXELS ];
        v_prev = new float[ PIXELS ];
        dens = new float[ PIXELS ];
        dens_prev = new float[ PIXELS ];
        
        collected = 0;
        wasted = 0;
        left = 0;
        
        // Update the scores
        level_score = 0;
        
        // Borders
        for ( int i = 0; i < WIDTH; ++i )
        {
            boundary[ i ] = 1;
            boundary[ PIXELS - 1 - i ] = 1;
        }
        for ( int i = 0; i < HEIGHT; ++i )
        {
            boundary[ i * WIDTH ] = 1;
            boundary[ WIDTH - 1 + i * WIDTH ] = 1;
        }

        // The level
        int offs = cur_level * ( 1 + 8 * 4 );
        if ( offs >= LEVELS.length() )
        {
            cur_level = 0;
            offs = 0;
            score_at_start = 0;
        }
        
        int goal_val = (int) LEVELS.charAt( offs++ );
        
        int idx = 0;
        for ( int y = 0; y < HEIGHT; ++y )
        {
            for ( int x = 0; x < WIDTH; ++x, ++idx )
            {
                int lx = x / 8;
                int ly = y / 8;
                
                int val = (int) LEVELS.charAt( offs + ly * 4 + (lx/2) );
                if ( (lx&1) != 0 ) val >>= 4;
                val &= 0xf;
                
                switch ( val )
                {
                case 1:		boundary[ idx ] = 1; break;
                case 2:		dens[ idx ] = 5.f; break;
                }
                if ( val >= 3 )
                    field[ idx ] = val - 2;
            }
        }
        
        total = calculateTotalDensity();
        if ( total < 0.001f )
            total = 0.001f; // prevent a division by zero
        
        goal = total * (float)goal_val / 255.f;
        
        // Preprocess the boundary
        for ( int y = 0; y < HEIGHT; ++y )
        {
            for ( int x = 0; x < WIDTH; ++x )
            {
                int ind = x + y * WIDTH;
                if ( boundary[ ind ] == 0 )
                    continue;
                dens[ ind ] = 0;
                
                int dx = 0; // -1, 0 or 1
                if ( x > 0 && boundary[ ind-1 ] == 0 ) dx = -1;
                if ( x < WIDTH-1 && boundary[ ind+1 ] == 0 ) dx += 1;
                
                int dy = 0; // -1, 0 or 1
                if ( y > 0 && boundary[ ind-WIDTH ] == 0 ) dy = -1;
                if ( y < HEIGHT-1 && boundary[ ind+WIDTH ] == 0 ) dy += 1;
                
                boundary[ ind ] = 0x10000000 | (dx+1) | ((dy+1)<<8); 
            }
        }
    }
    
    private final void updateFrame()
    {
        // Keyboard control
        if ( pressed_char != 0 )
        {
            char ch = pressed_char;
            pressed_char = 0;
            
	        switch ( ch )
	        {
	        case ' ':
	            if ( !DEVELOPER_MODE )
	            {
	                if ( collected >= goal )
	                    return;
	            }
	            startGame();
	            break;
	            
	        case '\n':
	            if ( !DEVELOPER_MODE )
	            {
	                if ( collected < goal )
	                    return;
	            }
	            
	            // Update the scores
	            score_at_start += level_score;
	            
	            if ( score_at_start > hiscore )
	                hiscore = score_at_start;
	            
	            // Save the score
	            try
	            {
	                byte[] data = new byte[ 4 ];
	                data[ 0 ] = (byte) ((hiscore >> 0) & 0xff);
	                data[ 1 ] = (byte) ((hiscore >> 8) & 0xff);
	                data[ 2 ] = (byte) ((hiscore >> 16) & 0xff);
	                data[ 3 ] = (byte) ((hiscore >> 24) & 0xff);
	                
	                getAppletContext().setStream( "a", new ByteArrayInputStream( data ) );
	            }
	            catch ( Throwable t )
	            {
	            }
	            
	            // Next level
	            ++cur_level;
	            startGame();
	            break;
	        }
	        
	        if ( DEVELOPER_MODE )
	        {
	            if ( ch == 'v' )
	                DEBUG_DRAW_VELOCITIES = !DEBUG_DRAW_VELOCITIES;
	        }
    	}
        
        // Goal pulsing
        goal_pulse += FRAME_TIME * 8;
        
        // Update controls
        if ( mouse_x >= 0 && mouse_x < WIDTH && mouse_y >= 0 && mouse_y < HEIGHT )
        {
            int ind = mouse_x + mouse_y * WIDTH;
        
            if ( boundary[ ind ] == 0 )
            {
                // Ripples/moving
		        if ( mouse_b1 )
		        {
		            u_prev[ ind ] = 555.f * (mouse_x-mouse_prev_x);
		            v_prev[ ind ] = 555.f * (mouse_y-mouse_prev_y);
		        }
		        
		        // Drawing
		        if ( DEVELOPER_MODE )
		        {
			        if ( mouse_b2 )
			        {
			            dens_prev[ ind ] = 100.f;
			        }
		        }
            }
        }
        
        // Update the field
        if ( DEVELOPER_MODE ) left = 0.f;
        for ( int i = 0; i < PIXELS; ++i )
        {
            final float force = 10.f;
         
            if ( boundary[ i ] != 0 )
            {
                dens[ i ] = 0;
                continue;
            }
            
            switch ( field[ i ] )
            {
            case 1:
                {
                	float amt = dens[ i ] * 0.3f;
                	dens[ i ] -= amt;
                	//if ( amt > 0.01f )
                	    collected += amt;
                	//else
                	    //wasted += amt;
                }
                break;

            case 2:
            	{
                	float amt = dens[ i ] * 0.2f;
                	dens[ i ] -= amt;
                	wasted += amt;
            	}
            	break;
                
            case 3:		u_prev[ i ] -= force; break;
            case 4:		v_prev[ i ] -= force; break;
            case 5:		u_prev[ i ] += force; break;
            case 6:		v_prev[ i ] += force; break;
            }
            
            if ( DEVELOPER_MODE ) left += dens[ i ];
        }
        
        // Calculate the level score
        level_score = (int)((collected/total)*100)*100;
        
        // Run the simulation
        runSim( FRAME_TIME );
        
        // Update the mouse
        mouse_prev_x = mouse_x;
        mouse_prev_y = mouse_y;
    }
    
    public void paint( Graphics scr_g )
    {
    }
    
    public void update( Graphics scr_g )
    {
        Graphics g = backbuffer.getGraphics();
        
        g.setColor( Color.BLACK );
        g.fillRect( 0, 0, SCR_WIDTH, SCR_HEIGHT );
        
        // Draw the field
        int goal_col = (int) (180 + 70 * Math.sin( goal_pulse ));
        int antigoal_col = (int) (180 + 70 * Math.sin( goal_pulse + 5.f ));
            
        int didx = 0;
        for ( int y = 0; y < (HEIGHT*4); ++y )
            for ( int x = 0; x < (WIDTH*4); ++x )
            {
                int idx = (x/4) + (y/4)*WIDTH;
                float d = dens[ idx ] * 5.f;
                int cr = (int)(d*255.f);
                int cg = cr;
                int cb = cr;
                
                int blow_val = 0;
                switch ( field[ idx ] )
                {
                case 0: break;
                case 1: cb += goal_col; break;
                case 2: cr += antigoal_col; break;
                case 3: blow_val = x; break;
                case 4: blow_val = y; break;
                case 5: blow_val = -x; break;
                case 6: blow_val = -y; break;
                }
                
            	if ( blow_val != 0 )
            	{
                	int val = (int) (120 + 70 * Math.sin( goal_pulse + blow_val / 10.f ));
                	cr += val;
                	cg += val;
            	}
                
            	// Clamp the color
                if ( cr > 255 ) cr = 255;
                if ( cg > 255 ) cg = 255;
                if ( cb > 255 ) cb = 255;
                int c = 0xff000000 | (cr<<16) | (cg<<8) | (cb<<0);
                if ( boundary[ idx ] != 0 )
                    c = 0xff1f7f3f;
                
                backbuffer_pixels[ didx++ ] = c;
            }

        backbuffer.setRGB( 0, BAR_HEIGHT, WIDTH * 4, HEIGHT * 4, backbuffer_pixels, 0, WIDTH * 4 );

        // Collected bar
        int collected_w = (int)((float)SCR_WIDTH * collected / total);
        int wasted_w = (int)((float)SCR_WIDTH * wasted / total);
        int goal_x = (int)((float)SCR_WIDTH * goal / total);
        
        g.setColor( Color.RED );
        g.fillRect( SCR_WIDTH - 1 - wasted_w, 0, wasted_w, BAR_HEIGHT );
        g.setColor( (collected < goal) ? Color.BLUE : new Color( 0, 0, goal_col ) );
        g.fillRect( 0, 0, collected_w, BAR_HEIGHT );
        g.setColor( Color.GREEN );
        g.drawLine( goal_x, 0, goal_x, BAR_HEIGHT );

        g.setColor( Color.WHITE );
        g.setFont( scr_g.getFont().deriveFont( 9.f ) );
        g.drawString( String.valueOf( score_at_start + level_score ), 5, BAR_HEIGHT - 4 );

        g.drawString( String.valueOf( hiscore ), SCR_WIDTH - 30, BAR_HEIGHT - 4 );
        
        // Status bar
        String msg = "Drag the gas to the blue area, press space to restart.";
        if ( collected >= goal )
            msg = "Press enter to continue to next level.";
        g.drawString( String.valueOf( cur_level + 1 ), 5, SCR_HEIGHT - 4 );
        g.drawString( msg, 16, SCR_HEIGHT - 4 );
        
        // Debug: Draw the velocity vectors
        if ( DEVELOPER_MODE )
        {
	        if ( DEBUG_DRAW_VELOCITIES )
	        {
		        g.setColor( Color.YELLOW );
		        for ( int y = 0; y < HEIGHT; y += 1 )
		            for ( int x = 0; x < WIDTH; x += 1 )
		            {
		                int i = x + y * WIDTH;
		                int x2 = (int)(u[i] * 100.f);
		                int y2 = (int)(v[i] * 100.f);
		                
		                int sx = 2 + x * 4;
		                int sy = BAR_HEIGHT + 2 + y * 4;
		                
		                g.drawLine( sx, sy, sx + x2, sy + y2 );
		            }
	        }
        }
        
        if ( DEVELOPER_MODE )
        {
            g.setColor( Color.GREEN );
            g.drawString( "Collected: " + collected + " (" + (100.f*collected/total) + "%)", 5, 30 );
            g.drawString( "Wasted: " + wasted + " (" + (100.f*wasted/total) + "%)", 5, 40 );
            g.drawString( "Left: " + left + " (" + (100.f*left/total) + "%)", 5, 50 );
            g.drawString( "Summed: " + (collected+wasted+left) + " == " + total, 5, 60 );
        }
        
        // Blit the backbuffer to screen
        scr_g.drawImage( backbuffer, 0, 0, null );
    }
    
    public void run()
    {
        while ( running )
        {
            updateFrame();
            //invalidate();
            repaint();
            try { Thread.sleep( FRAME_MS ); }
            catch ( Throwable t ) { }
        }
    }
    
    public void mouseClicked(MouseEvent e)
    {
    }
    
    public void mouseEntered(MouseEvent e)
    {
        mouseMoved( e );
    }
    
    public void mouseExited(MouseEvent e)
    {
        mouseMoved( e );
    }
    
    public void mousePressed(MouseEvent e)
    {
        mouseMoved( e );
        
        int b = e.getButton();
        if ( b == MouseEvent.BUTTON1 ) mouse_b1 = true;
        if ( b == MouseEvent.BUTTON3 ) mouse_b2 = true;
    }
    
    public void mouseReleased(MouseEvent e) 
    {
        mouseMoved( e );
        
        int b = e.getButton();
        if ( b == MouseEvent.BUTTON1 ) mouse_b1 = false;
        if ( b == MouseEvent.BUTTON3 ) mouse_b2 = false;
    }
    
    public void mouseDragged(MouseEvent e)
    {
        mouseMoved( e );
    }
    
    public void mouseMoved(MouseEvent e)
    {
        mouse_x = e.getX() / 4;
        mouse_y = e.getY() / 4;
    }
    
    public void keyPressed(KeyEvent e)
    {
        pressed_char = e.getKeyChar();
    }
    
    public void keyReleased(KeyEvent e)
    {
    }
    
    public void keyTyped(KeyEvent e)
    {
    }
    
    ///////////////////////////////////
    ///////////////////////////////////
    ///////////////////////////////////
    
    private final void addSource( float[] x, float[] s, float dt )
    {
        for ( int i = 0; i < PIXELS; ++i )
            x[ i ] += dt * s[ i ];
    }
    
    private final void setBounds( int type, float[] x )
    {
        for ( int i = 0; i < PIXELS; ++i )
        {
            int b = boundary[ i ];
            if ( b == 0 )
                continue;
            int dx = ((b>>0) & 0xff) - 1;
            int dy = ((b>>8) & 0xff) - 1;
            
            float v = x[ i + dx + dy * WIDTH ];
            if ( type == 1 && dx != 0 ) v = -v; 
            if ( type == 2 && dy != 0 ) v = -v; 
            if ( dx == 0 && dy == 0 ) v = 0;
            
            v*=0.9f;
            x[ i ] = v;
        }
    }
    
    private final void linearSolve( int type, float[] x, float[] x0, float a, float c )
    {
        int left = 20; // 20
        while ( left-- > 0 )
        {
            for ( int j = 1; j < HEIGHT-1; ++j )
            {
                int ind = 1 + j * WIDTH;
                for ( int i = 1; i < WIDTH-1; ++i, ++ind )
                {
                    x[ ind ] = (x0[ind] + a*(x[ind-1]+x[ind+1]+x[ind-WIDTH]+x[ind+WIDTH])) / c;
                }
            }
            setBounds( type, x );
        }
    }
    
    private final void diffuse( int type, float[] x, float[] x0, float diff, float dt )
    {
        float a = dt * diff * (float)PIXELS;
        linearSolve( type, x, x0, a, 1.f + 4.f*a );
    }
    
    private final void advect( int type, float[] d, float[] d0, float[] _u, float[] _v, float dt )
    {
        float dt0 = dt * (float)WIDTH;
        for ( int j = 1; j < HEIGHT-1; ++j )
        {
            int ind = 1 + j * WIDTH;
            for ( int i = 1; i < WIDTH-1; ++i, ++ind )
            {
                float x = (float)i - dt0 * _u[ ind ];
                float y = (float)j - dt0 * _v[ ind ];
                
                if ( x < 0.5f ) x = 0.5f;
                if ( x > (WIDTH-1.5f) ) x = (WIDTH-1.5f); 
                if ( y < 0.5f ) y = 0.5f;
                if ( y > (HEIGHT-1.5f) ) y = (HEIGHT-1.5f);
                
                int i0 = (int)x;
                int j0 = (int)y;
                
                float s1 = x-(float)i0;
                float s0 = 1.f - s1;
                float t1 = y-(float)j0;
                float t0 = 1.f - t1;

                int ind2 = i0 + j0 * WIDTH;
                
                d[ ind ] =
                    s0 * ( t0*d0[ ind2 ] + t1*d0[ ind2 + WIDTH ] ) +
                    s1 * ( t0*d0[ ind2 + 1 ] + t1*d0[ ind2 + 1 + WIDTH ] );
            }
        }
        
        setBounds( type, d );
    }
    
    private final void project( float[] _u, float[] _v, float[] p, float[] div )
    {
        for ( int j = 1; j < HEIGHT-1; ++j )
        {
            int ind = 1 + j * WIDTH;
            for ( int i = 1; i < WIDTH-1; ++i, ++ind )
            {
                div[ ind ] = -0.5f * (_u[ind+1]-_u[ind-1] + _v[ind+WIDTH]-_v[ind-WIDTH]) / (float)WIDTH;
                p[ ind ] = 0.f;
            }
        }
        setBounds( 0, div );
        setBounds( 0, p );
        
        linearSolve( 0, p, div, 1.f, 4.f );
        
        for ( int j = 1; j < HEIGHT-1; ++j )
        {
            int ind = 1 + j * WIDTH;
            for ( int i = 1; i < WIDTH-1; ++i, ++ind )
            {
                _u[ ind ] -= 0.5f * (float)WIDTH * ( p[ind+1] - p[ind-1] );
                _v[ ind ] -= 0.5f * (float)WIDTH * ( p[ind+WIDTH] - p[ind-WIDTH] );
            }
        }
        setBounds( 1, _u );
        setBounds( 2, _v );
    }
    
    private final void velocityStep( float dt )
    {
        addSource( u, u_prev, dt );
        diffuse( 1, u_prev, u, VISCOSITY, dt );
        
        addSource( v, v_prev, dt );
        diffuse( 2, v_prev, v, VISCOSITY, dt );
        
        project( u_prev, v_prev, u, v );
        
        advect( 1, u, u_prev, u_prev, v_prev, dt );
        advect( 2, v, v_prev, u_prev, v_prev, dt );
        
        project( u, v, u_prev, v_prev );
    }
    
    private final float calculateTotalDensity()
    {
        float ret = 0;
        for ( int i = 0; i < PIXELS; ++i )
        {
            if ( boundary[ i ] != 0 )
                dens[ i ] = 0;
            ret += dens[ i ];
        }
        return ret;
    }
    
    private final void densityStep( float dt )
    {
        addSource( dens, dens_prev, dt );
        float total_start = calculateTotalDensity();
        
		diffuse( 0, dens_prev, dens, DIFFUSE, dt );
		advect( 0, dens, dens_prev, u, v, dt );

        float total_end = calculateTotalDensity();
        
        // Keep the total amount of density at a constant level (same at the end as in the start)
        if ( total_end > 0.001f )
        {
            float scale = total_start / total_end;

            for ( int i = 0; i < PIXELS; ++i )
                dens[ i ] *= scale;
        }
    }
    
    private final void runSim( float dt )
    {
        velocityStep( dt );
        densityStep( dt );
        
        for ( int i = 0; i < PIXELS; ++i )
        {
            u_prev[ i ] = v_prev[ i ] = dens_prev[ i ] = 0.f;
        }
    }
}
