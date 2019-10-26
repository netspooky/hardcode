//
//
//      MAZE4k
//
//      M.E.@2010
//
//      
//      A 4k prototype of a multi-user on-line game.
//      The 4k version can only be played by one player.
//      Proof of concept and game-play test     
//
//
//
import java.applet.Applet;
import java.awt.image.*;
import java.awt.event.*;
import java.awt.*;




public class a extends Applet implements Runnable {
//public class a extends Applet {
        // BEGIN OF PUBLICs
        //      
        int x=0;
	int y=0;
        int maction=104;                // Menu Action levelmenu


        // END OF PUBLICs
        //

  
        
// Remove and use a while loop in init .. but it is not as smooth
        public final void start() {
                new Thread(this).start();
        }

// Without a run this is smaller .. but does not run smooth
// public final void init(){

        public final void run() {




// Make it visible..
// This is used when you have only an init method
//		show();



// Time used when no run method
// long t_;

                   final int EXTRA_X=240;                       // Board position               
                   final int EXTRA_Y=96;

                  final int TILESIZE=24;                       // The pixelsize of the tile
                  final int GRID=16;                            // How may items are on a line (grid*grid)

                  final int PLAYERS=4;                          // Nr of Players

                //
                // Game States
                //
                     final int PLAY=100;
                     final int RESTART=101;
                     final int DRAW=102;
                     final int NEXTLEVEL=103;
                     final int LEVELMENU=104;
                     final int DOWN=105;
                     

                     final int red=-65536;
                     final int white=-1;
                     final int black=-16777216;
                     final int gray=-8355712;


                     final int maxlevels=16;

                     final int GRASS=15;
                     final int HEDGE=8;
                     final int ROCK=7;
                     final int WATER=6;
                     final int HOLE=4;
                     final int WOOD=5;
                     final int FENCE1=10;
                     final int FENCE1SWITCH=9;
                     final int GOAL=11;
                     final int FENCE2=13;
                     final int FENCE2SWITCH=12;
                     final int COIN=14;





                     final int PLAYER1COLOR=-16711681; // (int)Color.cyan;
                     final int PLAYER2COLOR=-14336; // (int)Color.orange;
                     final int PLAYER3COLOR=-256; // (int)Color.yellow;
                     final int PLAYER4COLOR=-65281; // (int)Color.magenta;






		     final int width=48;       
		     final int height=48;   




			// SpriteSheet

final int color[]={12415288, -14474206, -11126134, -12509002, -12053698, -7979234, -4361928, -2506674, -1194233, -11457462, -7657863, -2804230, -15923708, -14544787, -6639166, -13496054, -11195379, -2970533, -5472184, -1977453, -9286378, -14006492, -12236988, -8812390, -10053838, -10713045, -12949486, -14996209, -10516397, -12217150, -4138787};
final String str="                                                    $%&&        '())        ()*+        ,-..       /0&&1%      23))45      ((*+6+      ,,..6-      0%&&&1      2()))4      7)*++6      ,-...6      /0%&&%      22())5      (7)+++      ,,-..-       $0%%        '2((        (3))        ,'--        /0/0        /222        23((        '',,       $0%&&%      '2())5      3()*++      ',-..-     $0%%&1&%    '23()455    3())+6++    ',--.6--    $%%&&&1&    '3()))4)    3))**+6+    '--...6.   8$$0000%0   8''2222'2   8337777)7   8'',,,,-,   8888888     8888888     8888888     8888888                                            ,9::::                5)*6*445                 99::11::              3)*6*56445     ;  ;;      9999::1::  <==;=/>;   3)**5464*)   <&00?;??;   $98$99:111;<82/2232=;  /()5*64*)(   00@@&0000   $,:9$99:19=((32//2(2/  2235))5)(*  01@@1111&10  '$9,9>9999>/////////2  /2235*)*)*  &@@1@1@@1&1  $//$,99$99///////////  /2335*)*54 ?&&@@1@A@1@&  '''$$9:9:9;,2////////  /23()45454  <0&&::1:&&? >/99/$$9:9  ==////,>==  /23()45455   ?;;?<?<<   $>/'9'>>$9   ;<;        2/23()(5(<               ,$/>/''/              ,89///22;<?<               >////$        8?=                                           8?8=                                            ?89;;?=                                        <<8==<?>=             0@   0A  0A               ?=?88?<>=              $A@@AA@@@A   *6*64*+    == =8=>;                $A  $A  $A  +6)==7876    >$?>>??>?              $A@@AA@@@A  *    ==85* 8?$>>9/=8=?     &@A      $A  &A  &A  6*      84  9 8>88?89?    0&&@A     $A11@A11@A  =6*    *6+ ?8$>$$>98?    <=<==      >/=</>==$    56*+++6)    //8822=>    <;<<                     877777    >$//3(5                                ==<=<                                       ;;<;<<<<;<<<                                    <<<?;<<<<<<<                            +66     <<<<<<<<<?;<            7+   76  76    4+++6    ;<?;?<<;<;<;             26*++6+++6    4+++6    <<<<<<<<<?<?             26  26  26     4+6     ;<<<<<<<<<;;             26*++6**+6             ;<<;<<<;;<<<    +4A      26  76  76             <;;<<;<<?;<<   7++66     26*++6+++6             <;<<<?;<<<<<  <==<=      $2==/2==/     >==      ;<<;<<<<<<<<  ;;;<                     5<       ;<;<?<<<?<<;                                    <<;<<<<<<<<<";








                  boolean on=false;

                  int playcounter[]=new int[PLAYERS+1]; // Which player is doing what
                  int lastposition[]=new int[PLAYERS+1];        // last play-list position of player

                  boolean ok=true;                      // Can we show or drag something?


                //
                // remember the order of steps
                // this for walking the line ....
                //
                  int orderline[][]=new int[PLAYERS+1][(GRID*GRID)+4];
                  int step=1;                           // Step that the player needs to do
                  int playernr=-1;                      // The playerobject we clicked on at first
                                                        //  dragging is the playernr we need
                                                        // to store.

		// Board / Grid

                  int map[]=new int[(GRID*GRID)+4];
                  int tempmap[]=new int[(GRID*GRID)+4]; // keep a backup
final String maps="PPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIPPIAPPPPPPPPPPLIPPIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIPPIPPPAPHPEPLPPIPPIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIPPIAPFPGPFPEPPLIPPIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIPPIPPAPPPPJPPPPIPPIIIIIIIIIIIIIIPPIPPPPPPIIPPPPIPPIPPLPPPPKPPPCIPPIPPPPPPIIPPPPIPPIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIPPIPPPPPIPPPPPPIPPIPPPPPIPPPPPPIPPIPPPFPIPIDPMPIPPIIIIAPIIIHIIPIPPIILGKGNFPEPIPIPPIIIBPPPPPIJICIPPIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIIIIAPPIPPPPPPPPPDIIPPPIPPPIPPPIPPIIPIPPPPIIPIPPPPIIPIPPHPPEPIIHPPIIPPPPPPEGEPPPIPIIPPIIIEGPGEIPPPIIPPPPEGPLPGIPPPIIPIPPPEGEGIPPPPIIPIPPPPEGEEPPIPIIPFPPHPPEPPPPPPIIPIPPPPPPPIIIPPIIPPIIPPPIPFPPPPIIPPPPPPIPPPPPIPIICPIPPPIPPPPPPBIIIIIIIIIIIIIIIIIPPPPPPIIIIIIIIIPPPPPPPIDIPPPPPIPIIIIIIIPIPIPIPIPIPPPPIIPIPIAIPIPIPIPPIIHIPPPPPIPIPIPPPPPPPIPPIPPIPIPCPPHPPIBPIPPIPIPPIPEPPPPPIPPIPIPPIIJIIPPPIPPIPIPPIIIIIPPIIIPIPPPPIIIIIIIIPIPIPPPKEPPPPPPPLIPIIIIIIIIIIIIIPIPPPPPPPPPPPPPIIIPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPGGGGGGGGGGGGGGPPPPPPPPPPPPPPPGPPGPGGPGGGPGGGPGPPGDPPPPPPPPAPPGPPGGGGGGGHHHGGPGPPGHHHFFFPPPPPGGPPGPPPPPPPPPPGPGPPGPPGGGGGGGGGPGPPGPPGLPPPPPPPPGPPGPPGGGGGGGGPPGPPGCPPPPPPPPBGGGPPGGGGGGGGGGGGPGPPPPPPPPPPPPPPPGPPGGGGGGGGGGGGGGPPPPPPPPPPPPPPPPPIIIIIIIIIIIIIIIIIPPPPPPPPPPPPPPIIPPIIIIIIPPPOPPIIPIPPPOPPIPPPIPIIPIPOPPPAIPOPIPIIPIPIIIIIIPPPIPIIPIPIIIIPPPPPIPIIPIOPPPPPOPPIPPIIPIPPPPPPPPPIPPIIPPIIPPOPPPPIPPIIPPPPIIIIIIIPPPIIPPPPPPPPPPPPPPIIPPOPPPPPPPPOPPIIPPPPPPPPPPPPPIIIPPPPPPPPPPPPNLIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIBPPPPPPPPPPPPDIIPPHHOHHOHHHPPPIIPHEEOEEOEEEHPPIIPHEIIIIIIIEHPPIIPHEIEEEEEIEHPPIIPOOIEIIIEIOHPPIIPHEIEILIEIEHPPIIPHEIEINIEIEHPPIIPOOIEEEEEIOHPPIIPHEPPPHPPPEHPPIIPHEEOEEOEEEHPPIIPPHHHHHHHHHPPPIIPPPPPPPPPPPPPPIIAPPPPPPPPPPPPCIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIBPPPPPPPPPPPPAIIPIIIIIOIIIIIIPIIPOPPPPPPPPPOIPIIPIPPPIPPIFIPIPIIPIOIFPIPPPIPIPIIPIPIPPOPHPPPOPIIPOPPPHPIPPIPIPIIPIPIPJPPOPIPIPIIPIPIPPIPIPPPIPIIPIPPPPPPPPPMIPIIPIIPIIIPIPIOIPIIPPPPOPPPPPPPPPIIPPOPPPPPIIIIPPIIDPPPEGEGNNKLICIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIOOOOOOEOOOOOOOIIOIIIIIPIIIIIIOIIOIPPPPPPPPPPIOIIOIPPPPPPPPPPIOIIOIPPPPPPPPPPIOIIOIPPPPFPPPPPIOIIEPPPIFCDHIPPPGIIOIPPIPPPPIPPIOIIOIPPPPBPPPPPIOIIOIPPPPFPPPPPIOIIOIPPPPPPPPPPIOIIOIPPPPPPPPPPIOIIOIIIIPPPIIIIINIIOOOOOOGOOOOAILIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIOEDPPPIPPPPBIOIIPPPPPPPPPPPPPGIIPPPPPPPPPPIPPPIIPPPPHFFFHPPPPPIIPPPPFGGGFPPPIPIIPPPPFGMGFPIPIPIIPPIPFGGGFPPPPPIIPPPPHFFFHPPPPPIIPIPPPPPPPPPIIPIIPIPPPPPPPPPPPPIIPIPPPPIPPPPPIPIIPIPPIIIPPPIPIAIIEIPPPPIPPPEEIIIIOICPPPPPPPENNLIIIIIIIIIIIIIIIIIEHEHEHEHEHEHEHEHHOHDCBAHACDBPHOEEPPPPPPPPPPPPPEHHHPPPPPPPPPHPPPEEPIPPEEHEEPPPPPHHPPPPEEHEEPPPHPEEPPHPHHOHHPPPHPHHPPHPEEHEEPHPPPEEPPPPEEHEEPPPPPHHPIPPPPPPPPPEHPEEPHPPPPPPPPPPPPHHPHAHPPHPPPPHHPEEPHDPHIIPPPBDCAHHEHBHEHHHEHHHHHHEOHCPPPPPPJENKLHHEHEHEHEHEHHHHHHIIIIIIIIIIIIIIIIICPIPPPPPIPPPPAIIIPIPPIPPGIPPPPIIIPPPPFPPMGHPIPIIOGPIPPHPIPPPPPIIPIIPPPPPPFPPHPIIPPPGHPIPHPPPIPIIIIPPGPPPPPHPPPIIPPIPPGHPPIPFIPIIPIPPPPGPPIPPPPIIPPHPPPPGPPPPPBIIPPPOPHPPGGGPNHIIPPIJPIPHPHPIGHIIPPPPPPPPPPPNKGIIDPPPPPPPPPPPHLIIIIIIIIIIIIIIIIIPPPPPPPPPPPPPPPPHEHEHEHEHEHHHHHHHOPPHGPOPPEPPPDHHPPHHJOPPPEPPPPHHPHGPOIOPPPEPPPHHHGPEFOGPPEPPPPHHHPPPGPPPEPPPPPHHPPPFBEEEEEEEEEHHPFPEIPPPPPPPFPHHFGFFPPFPPGPPPPHHAPGPPPPPPIHIPPHHEPPPPPPPPGMGGGHHNGGGGGGGGGGGGPHHKGGEGGPPPGGGFFHHLNGEPPPPGPPPFCHHHHHHHHHHHHHHHHH";


                  BufferedImage object[]=new BufferedImage[17];         // Each object on board



                  int redline=-1;                       // For displaying a bad line (fall in hole)


                  int action=NEXTLEVEL;

                  int level=0;

	

                  int scores[]=new int[maxlevels+1];
                  int score=0;


                // Set up the graphics stuff, double-buffering.
                final BufferedImage screen = new BufferedImage(800, 600, BufferedImage.TYPE_INT_RGB);
                Graphics g =  screen.getGraphics();
                final Graphics appletGraphics = (Graphics)getGraphics();

		// omitting this saves a lot of bytes .. but it isn't that nice
		// 
                //g.setFont(new Font("Helvetica",Font.PLAIN,18));
                // But if we remove helvetica it saves another 4 bytes
                g.setFont(new Font("",Font.PLAIN,18));




                // Create SpriteSheet
                // 
                // Cut/Paste from the a.gif.txt file
                // This file is generated by the gif to fillRect converter
                //
                //*************************************************************
                //*************************************************************
                //*************************************************************


                //*************************************************************
                // -- End of SpriteSheet
                //*************************************************************

                final BufferedImage SpriteSheet=new BufferedImage(4*TILESIZE,4*TILESIZE,BufferedImage.TYPE_INT_ARGB);
                Graphics ssg=SpriteSheet.getGraphics();
                for(int i=0; i < str.length(); i++){
                        // Don't draw the transparency .. CHANGE THIS WHEN COLORS CHANGE!
                        if(str.charAt(i)!=' '){
                                int cc=str.charAt(i)-35;
                                ssg.setColor(new Color(color[cc]));
                                ssg.fillRect((i%width)*(TILESIZE/12),(i/height)*(TILESIZE/12), TILESIZE/12, TILESIZE/12);
                        }
                }               
                for(int i=16; i > -1; i--){
			// Make a TILESIZE object
                        object[i]=new BufferedImage(TILESIZE, TILESIZE, BufferedImage.TYPE_INT_ARGB);
			//
			// Tried Anti-Alias and took some extra bytes and it wasn't that nice
			//
	

//                        if(i!=15)object[i].getGraphics().drawImage(SpriteSheet, -((15%4)*TILESIZE), -((15/4)*TILESIZE),null);
			// Draw background
			object[i].getGraphics().drawImage(SpriteSheet, -((15%4)*TILESIZE), -((15/4)*TILESIZE),null);
			// Then draw sprite (if it is background it is double .. but an if takes a bit more bytes :)
                        object[i].getGraphics().drawImage(SpriteSheet,-((i%4)*TILESIZE), -((i>0?i/4:0)*TILESIZE),null);

                }


                
                // Hide cursor
                setCursor(Toolkit.getDefaultToolkit().createCustomCursor(new BufferedImage(1,1,BufferedImage.TYPE_INT_ARGB),new Point(),null));
                // Game loop.
                while (true) {
        	        //
                	// Sleeper. This timer will change when we need to pause
	                //
	                int sleeptime=1;

// Use when you don't have a run method
//t_=System.currentTimeMillis();

                        // Render
                        g.setColor(new Color(black));
                        g.fillRect(0, 0, 800, 600);
                        
                        switch(action){
                                case LEVELMENU:
                                        g.setColor(new Color(white));
                                        for(int i=1; i<maxlevels+1; i++)
                                                g.drawString("LEVEL "+(i), EXTRA_X+150, (EXTRA_Y-TILESIZE)+((1+i)*TILESIZE));
                                        break;

                                
                                case NEXTLEVEL:
                                        // Go back to the first level
                                        if(level++ > maxlevels-1){level=1;}

                                        //
                                        // All GRASS
                                        //
                                        for(int i=0; i<(GRID*GRID)+1   ;i++) {map[i]=GRASS;}
                                        //
                                        // Reset the players
                                        for(int plc=0; plc < PLAYERS; plc++){
                                                for(int i=0; i < (GRID*GRID)+4 ; i++){ 
                                                        orderline[plc][i]=-1;
                                                }

                                        }

        
                                        // Turn maps into map[]
                                        for(int i=0; i < (GRID*GRID); i++){
                                                map[i]=maps.charAt(i+((level-1)*256))-65;
                                        }


                                        action=DRAW;
                                        break;


                                        // 
                                        //
                                        // End of NEXTLEVEL

                                //
                                // When we hit the START button the players are moving
                                //
                                case PLAY:
                                        // for each player
                                        for(int plc=0; plc < PLAYERS; plc++){
                                                // We might run into trouble so we
                                                // catch problems for each individual
                                                // player and therefore the other players
                                                // are moving along the board without interruption
                                                // it took too many bytes .. remove the try/catch exception clause
                                                int direction=0;                // The direction of the walk of the player
        
                                                // for each player 
                                                // ONE MOVE per player !!
                                                if(orderline[plc][playcounter[plc]] != -1){
                                                       if(playcounter[plc] > 0){
                                                                direction=orderline[plc][playcounter[plc]]-orderline[plc][playcounter[plc]-1];
                                                        }
                                                        // check the action that we need to perform...
                                                        //--
                                                        // if we encounter hole or water
                                                        // we need to stop
                                                        //--
                                                        switch(map[orderline[plc][playcounter[plc]]]){
                                                      
                                                		case WATER:
                                                		case HOLE:
                                                		case HEDGE:
                                                		case FENCE1:
                                                		case FENCE2:
                                                			redline=plc;
                                                			action=RESTART;
                                                			break;
                                                        // ---------------
                                                        // Pushing WOOD
                                                        // ---------------
                                              			case WOOD:
        
                                                                // check what the next tile is
                                                                	if(map[orderline[plc][playcounter[plc]]+direction]==WATER ||
                                                                		map[orderline[plc][playcounter[plc]]+direction]==HOLE 
                                                                	
                                                                	){
                                                                	
                                                                        	map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                        	map[orderline[plc][playcounter[plc]]+direction]=GRASS;
        
        
                                                                        }else{

                                                                        	// if we are pushing to a player
                                                                        	for(int jjj=0; jjj< 5; jjj++){
                                                                        		if(lastposition[jjj]==orderline[plc][playcounter[plc]]+direction){
                                                                        			redline=plc;
                                                                        			action=RESTART;
                                                                        		}
                                                                        	}
                                                                        	if(map[orderline[plc][playcounter[plc]]+direction]==GRASS ){
                                                                        		map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                        		map[orderline[plc][playcounter[plc]]+direction]=WOOD;
                                                                        	}else{
                                                                        		redline=plc;
                                                                        		action=RESTART;
                                                                        	}
                
                                                                        } // water or hole
                                                                        break;
                                
                                                        // ROCK
                        
                                                        case ROCK:
                                                                // check what the next tile is
                                                                if(
                                                                        map[orderline[plc][playcounter[plc]]+direction]==HOLE 
                                                                ){
                                                                        map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                        map[orderline[plc][playcounter[plc]]+direction]=GRASS;
                                                                        
                
                
                                                                }else{ // hole or something else
                                                                        // if we are pushing to a player
                                                                        for(int jjj=0; jjj< 5; jjj++){
                                                                                if(lastposition[jjj]==orderline[plc][playcounter[plc]]+direction){
                                                                                        redline=plc;
                                                                                        action=RESTART;
                                                                                }
                                                                        }
                                                                
                                                                        if(map[orderline[plc][playcounter[plc]]+direction]==GRASS ){
                                                                        	map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                        	map[orderline[plc][playcounter[plc]]+direction]=ROCK;
                                                                        }else{
                                                                        	if(map[orderline[plc][playcounter[plc]]+direction]==WATER){ 
                                                                        		map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                        	}else{	
                                                                        		redline=plc;
                                                                        		action=RESTART;
                                                                        	}       
                                                                        }
                                                                }
                
                                                        	break;
                                                                        

                                                        //
                                                        // FENCE
                                                        //
                                                	case FENCE1SWITCH:
                                                                map[orderline[plc][playcounter[plc]]]=GRASS;
                
                                                                // search for FIRST switch and get rid of it
                                                                // we use COINS for the other (So no FOUND now!)
                                                                for(int jjj=0;jjj<(GRID*GRID)+1;jjj++){
                                                                        if(map[jjj]==FENCE1){
                                                                                map[jjj]=GRASS;         
                                                                        }
                                                                }
                                                        	break;

                
                                                        //
                                                        // FENCE2
                                                        //
                                                	case FENCE2SWITCH:

                                                                map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                boolean found=false;    // We only want to find one gate (coins can be used as well!))
                                                                // search for switch and get rid of it
                                                                for(int jjj=0;jjj<(GRID*GRID)+1 && ! found;jjj++){
                                                                        if(map[jjj]==FENCE2){
                                                                                found=true;
                                                                                map[jjj]=GRASS;         
                                                                        }
                                                                }

                                                        	break;
                                                        //
                                                        // COIN
                                                        //
                                                	case COIN:
                                                                map[orderline[plc][playcounter[plc]]]=GRASS;
                                                                found=false;
                                                                // search for switch and get rid of it
                                                                for(int jjj=0;jjj<(GRID*GRID)+1 && !found;jjj++){
                                                                        if(map[jjj]==COIN){
                                                                                found=true;             
                                                                        }
                                                                }
                                                                // We have no COINS any more .. remove the gate
                                                                if(!found){
                                                                        for(int jjj=0;jjj<(GRID*GRID)+1 && !found;jjj++){
                                                                                if(map[jjj]==FENCE2){
                                                                                        map[jjj]=GRASS;
                                                                                        found=true;             
                                                                                }
                                                                        }

                                                                }
                                                        	break;

                                                        //
                                                        // GOAL 
                                                        //
                                                	case GOAL:
                                                                scores[level]=score;
                                                                action=NEXTLEVEL;
                                                                
                                                        	break;
                                                        } // switch
                                                        // show step
                                                        // Get the player
                                                        lastposition[plc]=orderline[plc][playcounter[plc]]; // only show last player
                                                        playcounter[plc]++;     
                                                                
                                                // if plc==-1   
                                                }else{
                                                        int jjj=0;
                                                        // check all the play-lines and count if we are ready
                                                        for(int plcc=0; plcc<PLAYERS;plcc++){
                                                                if(orderline[plcc][playcounter[plc]]==-1){
                                                                	jjj++;
                                                                }
        
                                                                if(jjj == PLAYERS){
                                                                        action=RESTART;
                                                                }
                                                        }

        
// removed catch exception for byte - saving .. it would be better to catch it ..       
						} // if we have playermovement, or if we are ready?!? 
                                        } // for each player
                                        break;

                                case RESTART:
                                        for(int jjj=0; jjj<(GRID*GRID)+1; jjj++){
                                              map[jjj]=tempmap[jjj];
					}
        
                                        
                                        sleeptime=1500;
                                        action=DRAW;
                                        break;
                        }   // Switch action
        


                        //
                        // DRAW
                        //
                        // Do we need to draw the board?
                        if(action == DRAW || action == PLAY || action == RESTART){
				sleeptime=1;
                                // If we playback we do it a little bit slower
                                if(action != DRAW) sleeptime=160;

                                // Reset score
                                if(action==DRAW){
                                        // reset position on board
                                        for(int jjj=0; jjj < 5; jjj++){
        
                                                lastposition[jjj]=-1;
                                        }
        
                                        score=0;
                                }

                                // Draw each grid item
                                for(int i=0; i < GRID*GRID; i++){
                                        int xx=EXTRA_X+((i%GRID)*TILESIZE);
                                        int yy=EXTRA_Y+((i>0?i/GRID:0)*TILESIZE);
                                        int showmap=map[i];
                                        // When we find walkingposition of the player we
                                        //  change it for a PAWN
        
                                        // if we want the player to be shown
                                        for(int jjj=0; jjj < 5; jjj++)
                                                if(i==lastposition[jjj])showmap=jjj;

                                        // if we are in play mode remove the player from the grid .. we use showmap to display it
                                        if(action == PLAY && map[i] < 4 && lastposition[map[i]]!=-1)map[i]=15;


                                        // Draw object
                                        // remove null-check .. it will save a few bytes
                                        //if(object[showmap]!=null){                                             
                                                g.drawImage(object[showmap], xx, yy, null);
                                        //}



                                        //
                                        // Show the lines of the different players
                                        //
                                        // do not show orderlines when we are playing back                      
                                        if(action == DRAW ){

                                                // orderline
                                                boolean found=false;
                                                for(int pl=0; pl < PLAYERS ; pl++){
                                                        int ii=0;
                                                        found=false;
                                                        while(!found){
                                                                if(orderline[pl][ii] == i){

                                                                        // Do we have a bad path to show ...
                                                                        // a bad path is one that can't run in play
                                                                        // mode .. for instance when you walk into a hole
                                                                        if(pl==redline){
                                                                                g.setColor(new Color(red));
                                                                        }else{
                                                                                switch(pl){
                                                                                        case 0:
                                                                                                g.setColor(new Color(PLAYER1COLOR));
                                                                                                break;
                                                                                        case 1:
                                                                                                g.setColor(new Color(PLAYER2COLOR));
                                                                                                break;
                                                                                        case 2:
                                                                                                g.setColor(new Color(PLAYER3COLOR));
                                                                                                break;
                                                                                        case 3:
                                                                                                g.setColor(new Color(PLAYER4COLOR));
                                                                                                break;
                                                                                        default:        
                                                                                                found=false;
                                                                                                break;
                        
                                                                                }
                                                                        }
                                                                        if(action == DRAW){
                                                                        	// jjj = before 
                                                                                int jjj=i-orderline[pl][ii>0?ii-1:0];
                                                                                int after=orderline[pl][ii+1];
                                                                                if(after<0)after=0;
                                                                                after=i-after;
                                                                                int nieuw=-1;
        
                                                                                if(jjj==-1 && after==1)nieuw=0;
                                                                                if(jjj==-1 && after==+GRID)nieuw=2;
                                                                                if(jjj==-1 && after==-GRID)nieuw=3;
                                                                                if(jjj==-GRID && after==-1)nieuw=3;
                                                                                if(jjj==-GRID && after==1)nieuw=4;
                                                                                if(jjj==-GRID && after==GRID)nieuw=1;
                                                                                if(jjj==1 && after==GRID)nieuw=5;
                                                                                if(jjj==1 && after==-GRID)nieuw=4;
                                                                                if(jjj==1 && after==-1)nieuw=0;
                                                                                if(jjj==GRID && after==1)nieuw=5;
                                                                                if(jjj==GRID && after==-1)nieuw=2;
                                                                                if(jjj==GRID && after==-GRID)nieuw=1;
                                                                                if(after == i)nieuw=6;
                                                                                
                                                                                
                                                                                switch(nieuw){
                                                                                        case 0:
                                                                                                g.fillRect(xx,yy+((TILESIZE/2)-3),TILESIZE, TILESIZE/6);

                                                                                                break;
                                                                                        case 1:
                                                                                                g.fillRect(xx+((TILESIZE/2)-3),yy, TILESIZE/6,TILESIZE);


                                                        
                                                                                                break;
                                                                                        case 5:
                                                                                                g.fillRect(xx,yy+((TILESIZE/2)-3),TILESIZE/2, TILESIZE/6);
                                                                                                g.fillRect(xx+((TILESIZE/2)-3),yy, TILESIZE/6,TILESIZE/2);


        
                                                                                                break;
                                                                                        case 3:
                                                                                                g.fillRect(xx+(TILESIZE/2),yy+((TILESIZE/2)-3),TILESIZE/2, TILESIZE/6);
                                                                                                g.fillRect(xx+((TILESIZE/2)-3),yy+(TILESIZE/2), TILESIZE/6,TILESIZE/2);

        
                                                                                                break;
                                                                                        case 4:
                                                                                                //Lower half |
                                                                                                g.fillRect(xx+((TILESIZE/2)-3),yy+(TILESIZE/2), TILESIZE/6,TILESIZE/2);
                                                                                                // Left half -

                                                                                                g.fillRect(xx,yy+((TILESIZE/2)-3),TILESIZE/2, TILESIZE/6);
        
                                                                                                break;
                                                                                        case 2:
                                                                                                //Upper half |
        
                                                                                                g.fillRect(xx+((TILESIZE/2)-3),yy, TILESIZE/6,TILESIZE/2);
                                                                                                // Right half -
                                                                                                g.fillRect(xx+(TILESIZE/2),yy+((TILESIZE/2)-3),TILESIZE/2, TILESIZE/6);

                                                                                                break;
                                                                                        case 6:

                                                                                                if(orderline[pl][ii+1]==-1)
                                                                                                        score--;
                                                                                                g.fillRect((xx+(TILESIZE/2))-6, (yy+(TILESIZE/2))-6,12,12);
                                                                                                
                                                                                                break;
                                                                                        default:
                                                                                                if(orderline[pl][ii-1>0?ii-1:0]==-1)
                                                                                                        score--;
        

                                                                                                g.fillRect((xx+(TILESIZE/2))-6, (yy+(TILESIZE/2))-6,12, 12);

                                                                                                
                                                                                                break;
                                                                                }
                                                                                score++;
                                                                                found=true;
                                                                        } // if we draw then teh lines are visible

                                                                } //  if orderline[pl]
                
                                                                if(ii++ > GRID*GRID)found = true;
                                                        } // while found
                                                } // for each player
                                        } // all grid items
                                } // are we playing back?
                        } // action == DRAW








                        //
                        // End of DRAW

                        //


                        //
                        // When we used the mouse to click on something ...
                        //
                        if(maction == Event.MOUSE_DOWN){
                                
                                maction=0;
                                int i=(y*GRID)+x;
                                // grid object
                                // Check coordinates .. are we in Menu?
                                if(i > (GRID*GRID)-1 || i < 0 ){
                                        // START BUTTON
                                        if(i > 267 && i < 272){
                                                for(int plcc=0;plcc<PLAYERS+1; plcc++){
                                                        playcounter[plcc]=0;
                                                }

                                                // Store the current map in a tempmap
                                                for(int jjj=0; jjj < (GRID*GRID)+1; jjj++){
                                                        tempmap[jjj]=map[jjj];
                                                }


                                                redline=-1;     // We don't have a redline anymore
                                                action=PLAY;
                                        }
                                        // MENU BUTTON
                                        if(i > (GRID*GRID)-1 && i < (GRID*GRID)+2){
                                                action=LEVELMENU;
                                        }


                                }else{
                                        // level selection in the menu
                                        if(action == LEVELMENU){
						//level=y-1;
						level=y;
                                                if(level < 0)level=0;
// this costs 3 more bytes so use level= if level<0 level = 0
//                                              level=y-2<0?0:y-2;
                                                action=NEXTLEVEL;
                                                
                                        }else{
                                                // We clicked on a player
                                                if(map[i] > -1 && map[i] < 4){

                                                        if(map[i] == playernr && on){
                                                                on=false;

                                                        }else{
                                                                int j;
                                                                playernr=map[i];
                                                                        // remove old line
                                                                for(j=0; j < (GRID*GRID)+4 ; j++){
                                                                        orderline[playernr][j]=-1;
                                                                }
                                                                orderline[playernr][0]=i;
                                                                if(redline == playernr)redline=-1;
                                                                step=1;
                                                                on=true;
                                                        }
                                                        

                                                }else{
                                                        // If we are in level menu?
                                                        playernr=-1;

                                                        on=false;
                                                }
                                        } // if menulevel or not?
                                } // if menu or on board?
                        } // DOWN


                        // We are in the line - making phase....
                        if(on){

                                int i=(y*GRID)+x;
                                // if we are moving a pawn we tend to go for false ..                                   
                                ok=false;
                                if(
                                        i == orderline[playernr][step-1]-1 ||
                                        i == orderline[playernr][step-1]+1 ||
                                        i == orderline[playernr][step-1]-GRID ||
                                        i == orderline[playernr][step-1]+GRID 
                                )
                                {
                                                // check if i != in list
                                                ok=true;
                                                // Check leaving the board to the left or right
                                                if(x == EXTRA_X  || x < 0 || x > GRID-1 ){
                                                        ok=false;
                                                }
                                                if( (i < 0 || i > (GRID*GRID)-1) || playernr < 0 ){
                                                        ok=false;
                                                }
                                                // Check previous position .. if we are going back 1 map item remove it
                                                if(step > 1 && i == orderline[playernr][step-2]){
                                                        orderline[playernr][step-1]=-1;
                                                        orderline[playernr][step]=-1;
                                                        if(step==2)step=1;else  step-=2;
                                                }else{
                                                        // Be sure that we didn't have the line allready 
                                                        // (when moving to the left  for instance of an existing player-path)
                                                        for(int pppp=0; pppp < PLAYERS && ok; pppp++){
                                                                int inlist=0;
                                                                while(orderline[pppp][inlist]!=-1 && ok){
                                                                        if(orderline[pppp][inlist]==i)ok=false; 
                                                                        inlist++;
                                                                }
                                                        }
                                                }

                                                //  Hedge or another player-icon ..no good path!
                                                if(ok && map[i] != HEDGE && map[i] > 3){
                                                                orderline[playernr][step]=i;
                                                                step++;
                                                                ok=true;
                                                }
                                } // if we are going back or advance to the next available map-position
                        } // if on


                        // end of maction ....



                        //
                        // INSTRUCTIONs
                        //
                        if(action==DRAW){
                                switch(level){
                                        case 1:
                                                g.setColor(new Color(white));
                                                g.drawString("Click ONCE on PAWN",270,120);

                                                g.drawString("Move to make a line of direction",270,250);

                                                g.drawString("Click mouse for destination",270,310);

                                                g.drawString("Don't move the mouse too fast",270,370);

                                                g.drawString("When done click START button", 330,470);
                                                break;
                                        case 2:
                                                g.setColor(new Color(white));


                                                g.drawString("ROCK can go in hole",380,220);
                                                break;
                                        case 3:
                                                g.setColor(new Color(white));

                                                g.drawString("WOOD can go in hole & water",300,220);
                                                break;

                                        case 4:
                                                g.setColor(new Color(white));
                                                
                                                g.drawString("Wait before a switch opens the gate",270,330);
                                                g.drawString("Make a detour with the other pawn",270,380);

                                                break;

                                        case 5:
                                                g.setColor(new Color(white));
                                                
                                                g.drawString("Don't cross a previous path",270,340);
                                                g.drawString("Don't push two objects at the same time",270,380);


                                                break;


                                } // switch

                                g.setColor(new Color(white));
                                // Make the button
                                g.setColor(new Color(gray));
                                g.fillRect(EXTRA_X+((GRID-5)*TILESIZE), EXTRA_Y+((((GRID*GRID)+1)/GRID)*TILESIZE), (TILESIZE*5), TILESIZE);
                                g.setColor(new Color(black));
                                g.drawString("START",EXTRA_X+((GRID-4)*TILESIZE)+6, EXTRA_Y+((((GRID*GRID)+1)/GRID)*TILESIZE)+18);

                                //g.setColor(new Color(white));
                                g.setColor(new Color(gray));

                                g.fillRect(EXTRA_X, EXTRA_Y+((((GRID*GRID)+1)/GRID)*TILESIZE), (TILESIZE*2), TILESIZE);
                                g.setColor(new Color(black));
                                g.drawString("levels",EXTRA_X+2, EXTRA_Y+((((GRID*GRID)+1)/GRID)*TILESIZE)+18);


                        } // if draw

                        if(action == DRAW || action == PLAY){
                                //
                                //  MENU
                                //
                                g.setColor(new Color(white));
                                // it is nicer to show the level only when drawing lines .. but 
                                // the if takes away 4 bytes ..
//                                if(action == DRAW)
                                        g.drawString("LEVEL: "+(level), 50,112);

                                g.drawString("STEPS: "+(score), 50,134);

                                for(int i=1; i < maxlevels+1; i++){
                                        g.drawString("level "+(i)+" = "+(scores[i]), 50,160+(i*20));
                                }
                                // remove last player


                        }

        


                        g.setColor(new Color(white));
                        // Draw the CURSOR
                        //g.drawRect(EXTRA_X+(x*TILESIZE), EXTRA_Y+(y*TILESIZE), TILESIZE-1,TILESIZE-1); 
			// avoiding drawRect saves 15 bytes .. but it is a bit less beautifull 
			g.fillRect(EXTRA_X+(x*TILESIZE)+6, EXTRA_Y+(y*TILESIZE)+6,12,12); 
                        // Draw the entire results on the screen.
                        appletGraphics.drawImage(screen, 0, 0, null);

                        try{Thread.sleep(sleeptime);}catch(Exception e){}
// This is when you don't have a run method
//	                while((System.currentTimeMillis()-t_) < sleeptime);

                }
        }


	//
	// store the kind of action into maction and
	// use the maction in the main - loop
	//
        public boolean handleEvent(Event e) {
                if(e.id == Event.MOUSE_DOWN || e.id == Event.MOUSE_MOVE){
			x=240;y=0;
			if(e.x>240)x=(e.x-240)/32;
			if(e.y>0)y=(e.y-15)/32;
			maction=e.id;
                }
                return false;
        } // handlevent
}