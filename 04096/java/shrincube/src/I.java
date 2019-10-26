
import java.applet.Applet;
import java.awt.Color;
import java.awt.Event;
import java.awt.Graphics;
import java.awt.image.BufferedImage;

/*
 * Nice Improvements:
 *
 * 4k transition tasks:
 * TODO perhaps moving Integer.toString to Integer.toString will save some space.
 *      - Integer.toString: jar=4239, pack.gz=3440
 *      - Long.toString: jar=4243, pack.gz=3446
 *      And it fluctuates.  So this is HIGHLY dependent upon the compression.
 *      Play with this in the final version!
 *
 * If space becomes a concern:
 * TODO remove the pointer visual
 * 
 * TODO check if just binary data loading is smaller
 */

public class I extends Applet implements Runnable {
    private static final int FRAMES_PER_SECOND = 30;

    private static final int VIEW_WIDTH_2 = 150;
    private static final int VIEW_HEIGHT_2 = 150;

    private static final int VIEW_WIDTH = 300;
    private static final int VIEW_HEIGHT = 300;

    private static final int SCREEN_WIDTH = 600;
    private static final int SCREEN_HEIGHT = 600;
    
    private static final String X = "`";
    private static final int L = `;
    `

    public void start() {
        new Thread(this).start();
    }

    //@Override
    public void run() {
        while (! isActive()) {
            Thread.yield();
        }
        
        BufferedImage image = new BufferedImage(VIEW_HEIGHT, VIEW_WIDTH,
                BufferedImage.TYPE_INT_RGB);

        int[] xPoints = new int[BOX_FACE_POINT_COUNT];
        int[] yPoints = new int[BOX_FACE_POINT_COUNT];
        
        String msg = null;
        int msgPosY = -1;
        int baseLength;
        int baseWidth;
        int baseSize;
        int level = -1;
        int levelscore;
        int totalscore;
        int totalpar;
        double rotateAngle;
        int bombSquarePos;
        // bits: bit 0 == manual bomb active, 1 == "advantage" bomb active
        int bombActive;
        boolean parActive;
        int betweenLevels;
        int fadeLevel = 255;
        // Stores both squares that are highlighted because they were
        // removed, and where the active "advantage" squares are.
        // Structure:
        //   [0,baseSize): current color effect
        //   [baseSize,2*baseSize): current advantage squares
        int[] highlightedSquares;
        int removeSquareHeight;
        double angle = 0;
        double cosAngle = Math.cos(angle);
        double sinAngle = Math.sin(angle);
        int[] viewPos3d = new int[] { 200, 0, 0 };
        Color black = new Color(0, 0, 0, 0xff);
        Color white = new Color(0xff, 0xff, 0xff, 0xff);
        Color green = new Color(0, 0xff, 0, 0xff);

        // 0 = no box, 1 = normal box, 2 = bomb box, 3 = don't hit
        int[] topBoxes;
        int topBoxesFirstPos;

        // array unpacking here
        int[] data = new int[L];
        
        // Technique 1 - about 160 compressed bytes
        char[] cc = X.toCharArray();
        int i = 0;
        int j = 0;
        int ii, jj, x = 0, y;
        
// i ALLOC
// cc ALLOC
// j ALLOC
// ii ALLOC
// jj ALLOC
        while (i < cc.length) {
            ii = cc[i++];
            //System.out.print((i-1) + ":" + Integer.toHexString(c) + " - ");
            if (ii <= 0x79) {
                data[j] = ii - 1;
            } else
            if (ii >= 0x80) {
                data[j] = ii;
            } else
            if (ii == 0x7a) {
                data[j] = 0 - (int) cc[i++];
            } else {
                // 7e conversion
                data[j] = 0;
                for (jj = 0; jj < ii - 0x7a; jj++) {
                    data[j] *= 0x7e;
                    data[j] += cc[i++] - 1;
                }
            }
            j++;
        }
// i FREE
// j FREE
// ii FREE
// jj FREE
// cc FREE
        
        int maxLevel = data[MAX_LEVEL_START];
        int[] levelPar = new int[maxLevel];
        int[] levelWidth = new int[maxLevel];
        int[] levelLength = new int[maxLevel];
        int[] topBoxlevelLength = new int[maxLevel];
        int[][] topBoxLevels = new int[maxLevel][];
// i ALLOC
// j ALLOC
// ii ALLOC
// jj ALLOC
// x ALLOC
// y ALLOC
        // j = index in our data array
        j = COMPRESSED_LEVELS_START;
        for (i = 0; i < maxLevel; i++) {
            // Decode the level packing
            /*
             * Each level is encoded such:
             *   int 0 =
             *           (bits 24-17 = total amount of box locations to decode - 1 (range [1-256]))
             *           (bits 16-12 = total number of box rows - 1 (range [1-32]))
             *           (bits 11-7 = level par (range [0,31])
             *           (bits 6-2 = level length - 4 (range [4,35]))
             *           (bits 1-0 = level width - 3 (range [3,6]))
             *   int 1-ceil(box rows * level width / 16) = box data,
             *       where each box is encoded in 2 bits:
             *              00 = no box
             *              01 = normal box
             *              10 = bomb box
             *              11 = don't destroy box
             *       these bits are in low-bit order, meaning block 0 is in bits 1-0
             */
            // jj == data value
            jj = data[j++];
            levelWidth[i] = (jj & 0x3) + 3;
            jj >>>= 2;
            levelLength[i] = (jj & 0x1f) + 4;
            jj >>>= 5;
            levelPar[i] = (jj & 0x1f);
            jj >>>= 5;
            topBoxlevelLength[i] = ((jj & 0x1f) + 1) * levelWidth[i];
            jj >>>= 5;
            // jj is now number of blocks to decode 
            jj &= 0xff;
            jj++;
            topBoxLevels[i] = new int[jj];
            // ii == block number in the byte we're looking at
            // x = data
            // y = index in topBoxLevels
            ii = 16;
            for (y = 0; y < jj; y++) {
                if (ii == 16) {
                    ii = 0;
                    x = data[j++];
                }
                topBoxLevels[i][y] = x & 0x3;
                x >>>= 2;
                ii++;
            }
        }
// i FREE
// j FREE
// ii FREE
// jj FREE
// x FREE
// y FREE
        
        
        
        Graphics ogr = image.getGraphics();
        long lastTime = System.nanoTime();

        game: while (true) {
            // setup game
            levelscore = 0;
            totalpar = 0;
            totalscore = 0;
            // System.out.println("start game");

            level: while (true) {
                // System.out.println("start level");
                level++;
                totalscore += levelscore;
                totalpar += levelPar[level];

                life: while (true) {
                    // setup map
                    baseWidth = levelWidth[level];
                    baseLength = levelLength[level];
                    rotateAngle = START_ROTATE_ANGLE;
                    bombSquarePos = -1;
                    bombActive = 0;
                    parActive = false;
                    levelscore = 0;
                    betweenLevels = BETWEEN_LEVEL_FRAMECOUNT;

                    baseSize = baseWidth * baseLength;
                    highlightedSquares = new int[baseSize * 2];
                    removeSquareHeight = 0;
                    topBoxes = new int[baseSize * 2];
// i ALLOC
                    for (i = 0; i < baseSize - topBoxlevelLength[level]; i++) {
                        topBoxes[i] = 0;
                    }
                    for (i = 0; i < topBoxLevels[level].length; i++) {
                        topBoxes[i + baseSize - topBoxlevelLength[level]] = topBoxLevels[level][i];
                    }
                    for (i = topBoxLevels[level].length + baseSize
                            - topBoxlevelLength[level]; i < topBoxes.length; i++) {
                        topBoxes[i] = 0;
                    }
// i FREE
                    // above this is always Zeros
                    topBoxesFirstPos = baseWidth;
                    
                    // set the start position
                    viewPos3d[0] = baseWidth * BOX_WIDTH / 2;
                    viewPos3d[1] = 
                        (levelLength[level] - topBoxlevelLength[level] / levelWidth[level]) * BOX_WIDTH / 2 - 1;
                    boolean updateView = true;

                    frame: while (true) {
// updateView ALLOC
                        int bvox = (int) (viewPos3d[0] / BOX_WIDTH);
                        int bvoy = (int) (viewPos3d[1] / BOX_WIDTH);
                        boolean ohit = topBoxes[baseWidth * bvoy
                                + bvox + topBoxesFirstPos] > 0;
                        // handle camera
                        // FIXME move these variables to shared variables
                        boolean changed = level == 0;
// i ALLOC
// j ALLOC
                        i = viewPos3d[0];
                        j = viewPos3d[1];
                        if (betweenLevels == 0) {
                            if (keys[KEY_FORWARD]) {
                                j += MAX_XLATE_SPEED;
                                changed = true;
                            }
                            if (keys[KEY_BACK]) {
                                j -= MAX_XLATE_SPEED;
                                changed = true;
                            }
                            if (keys[KEY_LEFT]) {
                                i -= MAX_XLATE_SPEED;
                                changed = true;
                            }
                            if (keys[KEY_RIGHT]) {
                                i += MAX_XLATE_SPEED;
                                changed = true;
                            }
                            if (changed) {
                                if (level > 0) {
// ii ALLOC
// jj ALLOC
                                    ii = (int) (i / BOX_WIDTH);
                                    jj = (int) (j / BOX_WIDTH);
                                    boolean nhit = topBoxes[baseWidth * jj
                                            + ii + topBoxesFirstPos] > 0;
                                    if (
                                    // not rotating & hit on new location or old
                                    // location or...
                                    (rotateAngle < 0. && (nhit || ohit)) ||
    
                                    // rotating and..
                                            (rotateAngle >= 0. && (
                                            // passing down into the new hit box
                                            // or...
                                            (nhit && !ohit && jj < bvoy) ||
    
                                            // passing up through hit-line or...
                                                    (!nhit && ohit && jj > bvoy) ||
    
                                            // passing from one cube to another
                                            // along the y axis
                                            (nhit && ohit && jj != bvoy)))) {
                                        changed = false;
                                    } else {
                                        ohit = nhit;
                                    }
// ii FREE
// jj FREE
                                }
                                if (changed) {
                                    viewPos3d[0] = i;
                                    viewPos3d[1] = j;
                                    updateView = true;
                                }
                            }
// i FREE
// j FREE
    
                            // calculate view
                            if (updateView) {
                                updateView = false;
                                if (viewPos3d[0] < 0) {
                                    viewPos3d[0] = 0;
                                }
                                if (viewPos3d[0] >= baseWidth * BOX_WIDTH) {
                                    viewPos3d[0] = baseWidth * BOX_WIDTH - 1;
                                }
                                if (viewPos3d[1] < 0) {
                                    viewPos3d[1] = 0;
                                }
                                if (viewPos3d[1] >= baseLength * BOX_WIDTH) {
                                    viewPos3d[1] = baseLength * BOX_WIDTH - 1;
                                }
                                if (level == 0) {
                                    angle += INTRO_ROTATE_SPEED;
                                    if (angle > CIRCLE_RADIANS) {
                                        angle = 0.;
                                    }
    
                                    // check here for starting a new game
                                    if (keys[KEY_DROP]) {
                                        keys[KEY_DROP] = false;
                                        level = 0;
                                        msg = "Next Level";
                                        msgPosY = 0;
                                        continue game;
                                    }
                                } else {
                                    // the angle is based on the % distance
                                    double dx = viewPos3d[0] - BOX_WIDTH
                                            * (baseWidth) / 2.0;
                                    double percentX = dx
                                            / (BOX_WIDTH * (baseWidth + 1) / 2.);
    
                                    angle = percentX * (MAX_ANGLE - MIN_ANGLE);
                                    if (angle < MIN_ANGLE) {
                                        angle = MIN_ANGLE;
                                    } else if (angle > MAX_ANGLE) {
                                        angle = MAX_ANGLE;
                                    }
                                }
    
                                cosAngle = Math.cos(angle);
                                sinAngle = Math.sin(angle);
                            }
// updateView FREE

                            
                            if (keys[KEY_RESTART]) {
                                keys[KEY_RESTART] = false;
                                // restart level
                                msgPosY = 0;
                                msg = "Restarting Level";
                                continue life;
                            }
                            boolean advanceLevel = false;
                            if (keys[KEY_NEXT]) {
                                keys[KEY_NEXT] = false;
                                advanceLevel = true;
                                // don't credit the player with this level
                                levelscore = 0;
                                totalpar -= levelPar[level];
                            }
                            if (removeSquareHeight > 0) {
                                // removing squares, not rotating
                                removeSquareHeight += BOX_HEIGHT_REDUCE_PER_FRAME;
                                if (removeSquareHeight > BOX_WIDTH) {
                                    // finished removing
                                    removeSquareHeight = 0;
                                    
                                    // actually remove them from the map
// i ALLOC
                                    for (i = 0; i < baseSize; i++) {
                                        if (highlightedSquares[i] == BOMB_BOX_COLOR) {
                                            if (topBoxes[i + topBoxesFirstPos] == 3) {
                                                levelscore += 3;
                                            }
                                            if (topBoxes[i + topBoxesFirstPos] == 2) {
                                                highlightedSquares[i + baseSize] = 1;
                                            } else {
                                                highlightedSquares[i] = 0;
                                            }
                                            topBoxes[i + topBoxesFirstPos] = 0;
                                        }
                                        if (highlightedSquares[i + baseSize] != 0) {
                                            highlightedSquares[i] = MARKED_BOMBBOX_COLOR;
                                        }
                                    }
// i FREE
                                }
                            } else {
                                rotateAngle += ROTATE_ANGLE_SPEED;
                            }
                            if (rotateAngle > 0
                                    && rotateAngle < ROTATE_ANGLE_SPEED * 1.9) {
                                topBoxesFirstPos += baseWidth;
                                
                                if (level > 0) {
                                    // New rotation
                                    
                                    
                                    // if there are any blocks that fall, then
                                    // those count against the score.  Also,
                                    // check if there are any squares remaining
// j ALLOC
                                    j = 0;
// i ALLOC
                                    for (i = baseSize; --i >= 0;) {
                                        if (topBoxes[i + topBoxesFirstPos] != 3
                                                && topBoxes[i + topBoxesFirstPos] > 0) {
                                            j++;
                                        }
                                    }
                                    for (i = baseWidth; --i >= 0;) {
                                        // last row
                                        if (topBoxes[topBoxesFirstPos - i] != 3 &&
                                                topBoxes[topBoxesFirstPos - i] > 0) {
                                            levelscore += 2;
                                        }
                                    }
// i FREE
                                    if (j == 0) {
                                        // finished the level
                                        advanceLevel = true;
                                    }
// j FREE
                                    if (topBoxesFirstPos >= baseSize) {
                                        advanceLevel = true;
                                    }
                                } else if (topBoxesFirstPos >= baseSize) {
                                    topBoxesFirstPos = baseWidth;
                                }
                            }
                            
                            if (advanceLevel) {
                                // check if the player made it at
                                // or under par; if not, restart level
                                if (levelscore > levelPar[level]) {
                                    msg = "Try Again";
                                } else
                                if (level + 1 >= maxLevel) {
                                    // end of levels
                                    level = -1;
                                    msg = "The End";
                                    continue level;
                                } else {
                                    msg = "Next Level";// + level;
                                }
                                msgPosY = 0;
                                betweenLevels = -BETWEEN_LEVEL_FRAMECOUNT;
                                if (levelscore > levelPar[level]) {
                                    continue life;
                                }
                            }
                            // advance level before death check
                            if (level > 0
                                    && rotateAngle <= 0.
                                    && ohit) {
                                // player under a block == death
                                // restart level
                                msgPosY = 0;
                                msg = "Player Death - Restarting Level";
                                continue life;
                            }
                            
                            
                            if (keys[KEY_DROP]) {
                                keys[KEY_DROP] = false;
                                if (bombSquarePos >= 0) {
                                    // Activate the current bomb
                                    bombActive |= 1; // turn on bit 0
                                    highlightedSquares[bombSquarePos] = BOMB_BOX_COLOR;
                                } else {
                                    //if (bombSquarePos >= 0) {
                                    //    // reset the old position - note that this
                                    //    // can be used with the advantage squares
                                    //    // to your, um, advantage.
                                    //    highlightedSquares[bombSquarePos] = 0;
                                    //}
                                    bombSquarePos = bvox + bvoy * baseWidth;
                                    bombActive &= 2; // turn off bit 0
                                    highlightedSquares[bombSquarePos] = MARKED_BOX_COLOR;
                                }
                            }
// updateView ALLOC
                            if (keys[KEY_ACTIVATE] && removeSquareHeight == 0) {
                                keys[KEY_ACTIVATE] = false;
                                // Activate the advantage squares.
                                // This happens immediately
                                bombActive |= 2; // turn on bit 1
// i ALLOC
                                for (i = 0; i < baseSize; i++) {
                                    if (highlightedSquares[i + baseSize] == 1) {
                                        // Mark the squares for removal
// x ALLOC
// y ALLOC
// ii ALLOC
// jj ALLOC
                                        x = i % baseWidth;
                                        y = i / baseWidth;
                                        
                                        for (ii = -1; ii <= 1; ii++) {
                                            for (jj = -1; ii + x >= 0
                                                    && ii + x < baseWidth
                                                    && jj <= 1; jj++) {
// j ALLOC
                                                j = i + ii + jj * baseWidth;
                                                if (bombSquarePos != j && jj + y >= 0
                                                        && jj + y < baseLength) {
                                                    highlightedSquares[j] = BOMB_BOX_COLOR;
                                                }
// j FREE
                                            }
                                        }
// x FREE
// y FREE
// ii FREE
// jj FREE
                                        highlightedSquares[i + baseSize] = 0;
                                    }
                                }
// i FREE
                            }
                            if (rotateAngle >= MAX_ROTATE_ANGLE) {
                                rotateAngle = START_ROTATE_ANGLE;
                                if (parActive) {
                                    levelscore++;
                                }
                            }
                            // activating bombs can happen at any point before
                            // rotation begins
                            if (rotateAngle < 0. && removeSquareHeight <= 0) {
                                if (bombActive != 0) {
                                    if ((bombActive & 1) == 1) { // bit 0 set?
                                        // only clear out the bomb placement
                                        // if it was activated
                                        bombSquarePos = -1;
                                    }
                                    bombActive = 0;
                                    if (! parActive) {
                                        levelscore++;
                                        parActive = true;
                                    }
                                    
                                    // activate all squares marked for removal
                                    
// i ALLOC
                                    for (i = 0; i < baseSize; i++) {
                                        if (highlightedSquares[i] == BOMB_BOX_COLOR) {
                                            // slated for removal
                                            if (topBoxes[i + topBoxesFirstPos] == 2) {
                                                highlightedSquares[i + baseSize] = 1;
                                            }
                                        }
                                    }
// i FREE
                                    removeSquareHeight = BOX_HEIGHT_REDUCE_PER_FRAME;
        
                                    
                                }
                                
                            }
                        } else if (betweenLevels < 0) {
                            // before new level loads
                            betweenLevels++;
                            // fade out
                            fadeLevel = -255 * betweenLevels / BETWEEN_LEVEL_FRAMECOUNT;
                            if (betweenLevels == 0) {
                                continue level;
                            }
                        } else {
                            // after new level loaded
                            betweenLevels--;
                            // fade in
                            fadeLevel = 255 * (BETWEEN_LEVEL_FRAMECOUNT - betweenLevels) / BETWEEN_LEVEL_FRAMECOUNT;
                        }
                        
                        double cosRotate = Math.cos(ROTATE_ANGLE_ADJUST
                                - rotateAngle);
                        double sinRotate = Math.sin(ROTATE_ANGLE_ADJUST
                                - rotateAngle);

                        // int[] xPoints = new int[BOX_FACE_POINT_COUNT];
                        // int[] yPoints = new int[BOX_FACE_POINT_COUNT];
                        int[] points2dDist = new int[MAX_POINT2D_SIZE];
                        int[] facesData = new int[MAX_FACEPOINTS];
                        int facesDataIndex = FACE_VALUE_COUNT; // skip player
                        int point2dDistIndex = POINT2D_WITH_DIST_SIZE * 4; // skip
                                                                           // player
                        ogr.setColor(black);
                        ogr.fillRect(0, 0, VIEW_WIDTH, VIEW_HEIGHT);

                        // project points
                        // rendering:
                        // 1. translate points to view point perspective
                        // 2. rotate along x axis downwards by 45 degrees
                        // 3. rotate along z axis by "angle" degrees

                        // First thing to render is the "player". We only have
                        // to worry
                        // about the right initial x/y translated point; the
                        // rest comes
                        // from hard-coded variables. Also, ordering in the face
                        // list
                        // is simple (it's the only thing in the list).
                        
                        // FIXME - these end up being constant points.
                        
                        double cosZ = cosAngle;
                        double sinZ = sinAngle;
                        double cosX = COS_X;
                        double sinX = SIN_X;
                        
                        /*
                        double px = 0;
                        double py = px;
                        double pz = -10;

                        double dx = sinZ * py + cosZ * px;
                        double dy = sinX * pz
                                + cosX * (cosZ * py - sinZ * px);
                        double dz = cosX * pz
                                - sinX * (cosZ * py - sinZ * px);
                        // now translate the point into the camera perspective
                        dy += CAMERA_TO_ORIGIN_DIST;

                        int px0 = (int) (CAMERA_TO_VIEW_DIST * dx / dy)
                                + VIEW_WIDTH_2;
                        int px1 = (int) (CAMERA_TO_VIEW_DIST * dz / dy)
                                + VIEW_HEIGHT_2;
                        // squared distance; this is based on a higher pz
                        // value, so that it will appear lower to the ground,
                        // but not have things stacked on top of it
                        // A good value is pz = -55.  Using this, the difference
                        // between pz = -10 and pz = -55 for the dy and dz
                        // values is constant.
                        // This is the test code to show that the delta is
                        //constant, and what the delta equals.
                        //
                        //pz = -55;
                        //double distDY = sinX * pz
                        //        + cosX * (cosZ * py - sinZ * px)
                        //        + CAMERA_TO_ORIGIN_DIST;
                        //double distDZ = cosX * pz
                        //        - sinX * (cosZ * py - sinZ * px);
                        //msgPosY = 40;
                        //msg = "dist: dy="+(distDY-dy)+"; dz="+(distDZ-dz);
                        //int px2 = (int) -(dx * dx + distDY * distDY + distDZ * distDZ);
                        
                        And this is the test code to show that the Avatar point is always
                        constant
                        dy -= 38.97114317029968;
                        dz -= 22.5;
                        int px2 = (int) -(dx * dx + dy * dy + dz * dz);
System.out.println("[" + px0 + "," + px1 + "," + px2 + "]");
                        int px3;
                        */
                        
                        if (level > 0) {
                            // Draw avatar
                            // px0 = 150
                            // px1 = 149
                            // px2 = -363604
                            
                            // p1
                            points2dDist[0] = 150;
                            points2dDist[1] = 149;
                            points2dDist[2] = -363604;
                            // p2
                            points2dDist[3] = 150;
                            points2dDist[4] = 149 + 5;
                            points2dDist[5] = -363604;
                            // p3
                            points2dDist[6] = 150 + 5;
                            points2dDist[7] = 149 + 5;
                            points2dDist[8] = -363604;
                            // p4
                            points2dDist[9] = 150 + 5;
                            points2dDist[10] = 149;
                            points2dDist[11] = -363604;

                            // 4 point indices + color + distance
                            facesData[0] = 0;
                            facesData[1] = POINT2D_WITH_DIST_SIZE;
                            facesData[2] = POINT2D_WITH_DIST_SIZE * 2;
                            facesData[3] = POINT2D_WITH_DIST_SIZE * 3;
                            facesData[4] = PLAYER_COLOR;
                            facesData[5] = -363604;
                        }
                        
                        // start from the back and paint forward
                        int px0, px1, px2, px3;
                        double px, py, pz, dx, dy, dz;
                        for (int boxlevel = 0; boxlevel < 2; boxlevel++) {
                            // double height = CAMERA_HEIGHT - boxlevel *
                            // BOX_WIDTH;
                            double height = -boxlevel * BOX_WIDTH;
                            for (int h = baseLength; --h >= -1;) {
                                if (h < 0 && boxlevel == 0) {
                                    break;
                                }
                                double hy = h * BOX_WIDTH;
                                
                                // is this within our frustrum?
                                // - angle between camera and furthest south
                                // point =
                                // atan(VIEW_HEIGHT_2 / CAMERA_TO_VIEW_DIST)
                                // - ray goes from camera along angle.
                                // - if line at point y > height, then it's
                                // viewable.
                                
                                if (CAMERA_HEIGHT_OVER_LOWER_BOUND_Z0_HACK -
                                        height >
                                        CAMERA_HEIGHT_OVER_LOWER_BOUND_Z0
                                        * (viewPos3d[1] - hy)) {
                                    continue;
                                }
                                
                                for (int w = 0; w < baseWidth; w++) {
                                    double hx = w * BOX_WIDTH;
                                    double hz = BOX_WIDTH;
                                    int renderPoints = 0;
                                    int faceRender = 0xff;
                                    
                                    int renderColor = data[BOX_COLOR_START + BASE_COLOR];
                                    if (boxlevel == 0) {
                                        // optimize what we can render
                                        faceRender = 2;
                                        if (h == 0) {
                                            faceRender |= 1 << 3;
                                        }
                                        if (w == 0) {
                                            faceRender |= 1 << 6;
                                        }
                                        if (w == baseWidth - 1) {
                                            faceRender |= 1 << 5;
                                        }
                                    } else {
// j ALLOC
                                        j = w + h * baseWidth;
                                        if (j >= 0) {
                                            if (highlightedSquares[j] == BOMB_BOX_COLOR) {
                                                hz -= removeSquareHeight;
                                            }
                                            if (highlightedSquares[j + baseSize] != 0) {
                                                // add a visual pointer (rectangle)
                                                
                                                //-------------------------------------------------------
                                                renderPoints = 0;
                                                int p0 = point2dDistIndex;
                                                int bitvector = BOX_VERTICIES_BITVECTOR;
                                                
// i ALLOC
                                                i = 0;
                                                while (i < 12) {
                                                    px = data[POINTER_LOCATIONS_START + i++] +
                                                        hx - viewPos3d[0];
                                                    py = data[POINTER_LOCATIONS_START + i++] +
                                                        hy - viewPos3d[1];
                                                    pz = height - data[POINTER_LOCATIONS_START + i++];
    
                                                    // Full-out expansion
                                                    // - eventually, this should be
                                                    // compressed down into the
                                                    // optimized form
    
                                                    dx = sinZ * py + cosZ * px;
                                                    dy = sinX * pz + cosX * (cosZ * py - sinZ * px);
                                                    dz = cosX * pz - sinX * (cosZ * py - sinZ * px);
                                                    // now translate the point into the
                                                    // camera perspective
                                                    dy += CAMERA_TO_ORIGIN_DIST;
                                                    
                                                    int xx = (int) (CAMERA_TO_VIEW_DIST
                                                            * dx / dy)
                                                            + VIEW_WIDTH_2;
                                                    int yy = (int) (CAMERA_TO_VIEW_DIST
                                                            * dz / dy)
                                                            + VIEW_HEIGHT_2;
                                                    int dd = (int) -(dx
                                                            * dx + dy * dy + dz * dz);
                                                    if (xx >= 0 && xx < VIEW_WIDTH &&
                                                        yy >= 0 && yy < VIEW_HEIGHT) {
                                                        renderPoints++;
                                                    }
    
                                                    points2dDist[point2dDistIndex++] = xx;
                                                    points2dDist[point2dDistIndex++] = yy;
                                                    // squared negative distance
                                                    points2dDist[point2dDistIndex++] = dd;
                                                }
// i FREE
    
                                                // render faces
                                                if (renderPoints > 0) {
                                                    int dist = 
                                                        points2dDist[
                                                             p0 + 2];

                                                    px0 = p0;
                                                    xPoints[0] = points2dDist[px0];
                                                    yPoints[0] = points2dDist[px0 + 1];
                                                    px1 = p0 + POINT2D_WITH_DIST_SIZE;
                                                    xPoints[1] = points2dDist[px1];
                                                    yPoints[1] = points2dDist[px1 + 1];
                                                    px2 = p0 + POINT2D_WITH_DIST_SIZE * 2;
                                                    xPoints[2] = points2dDist[px2];
                                                    yPoints[2] = points2dDist[px2 + 1];
                                                    px3 = p0 + POINT2D_WITH_DIST_SIZE * 3;
                                                    xPoints[3] = points2dDist[px3];
                                                    yPoints[3] = points2dDist[px3 + 1];
                                                    

                                                    // insertion sort
                                                    // start from the back, since
                                                    // the method for drawing
                                                    // squares
                                                    // is generally in-order. point
                                                    // k to the distance of
                                                    // the previous runs
                                                    int k = facesDataIndex - 1;
                                                    while (k > 0
                                                            && facesData[k] >= dist) {
                                                        k -= FACE_VALUE_COUNT;
                                                    }
                                                    // k points to the dist of the
                                                    // one we're interested in;
                                                    // change it to point to the
                                                    // start
                                                    k++;
                                                    if (k < 0) {
                                                        k = 0;
                                                    }
                                                    // push all the other data
                                                    // forward
                                                    facesDataIndex += FACE_VALUE_COUNT;
                                                    for (int m = facesDataIndex; --m >= k
                                                            + FACE_VALUE_COUNT;) {
                                                        facesData[m] = facesData[m
                                                                - FACE_VALUE_COUNT];
                                                    }

                                                    // 4 points + color + distance
                                                    facesData[k++] = px0;
                                                    facesData[k++] = px1;
                                                    facesData[k++] = px2;
                                                    facesData[k++] = px3;
                                                    facesData[k++] = POINTER_COLOR;
                                                    facesData[k++] = dist;
                                                }
                                                
                                                
                                                
                                                //-------------------------------------------------------
                                            }
                                        }
                                        j += topBoxesFirstPos;
                                        renderColor = data[BOX_COLOR_START + topBoxes[j]];
// j FREE
                                    }
                                    if (renderColor == 0) {
                                        continue;
                                    }
                                    if (viewPos3d[0] >= hx
                                            && viewPos3d[0] < hx + BOX_WIDTH
                                            && viewPos3d[1] >= hy
                                            && viewPos3d[1] < hy + BOX_WIDTH) {
                                        // player on it
                                        renderColor |= PLAYER_ON_BOX_COLOR;
                                    }
                                    if (h >= 0
                                            && highlightedSquares[w + h
                                                    * baseWidth] > 0) {
                                        renderColor |= highlightedSquares[w + h
                                                * baseWidth];
                                        if (boxlevel > 0) {
                                            renderColor += 0x80000000;
                                        }
                                    }

                                    int p0 = point2dDistIndex;
                                    int bitvector = BOX_VERTICIES_BITVECTOR;
// i ALLOC
                                    for (i = 0; i < VERTICES_COUNT; i++) {
                                        // world-to-view space is rotating about
                                        // the view position,
                                        // so translate to that first.
                                        
                                        px = (bitvector & 0x1) * BOX_WIDTH;
                                        bitvector >>>= 1;
                                        py = (bitvector & 0x1) * BOX_WIDTH;
                                        bitvector >>>= 1;
                                        
                                        // Adjust the height down if it's
                                        // shrinking; this gives the illusion
                                        // that it's shrinking, when it's
                                        // really just sinking, but it doesn't
                                        // look good when a block is sinking on
                                        // the edges.
                                        // This method requires setting hz to
                                        // 0, and then adding that to
                                        // removeSquareHeight
                                        //pz = (bitvector & 0x1) * BOX_WIDTH +
                                        //    hz;
                                        
                                        // alternate method is to just
                                        // multiply by hz; this means that
                                        // the bitvector needs to be inverted
                                        // on the Z bit, and the hz needs to
                                        // be first set to BOX_WIDTH, then
                                        // have removeSquareHeight subtracted
                                        // from it.
                                        // pz = (bitvector & 0x1) * hz;
                                        //pz = BOX_WIDTH -
                                        //    (1 - (bitvector & 0x1)) * hz;
                                        pz = BOX_WIDTH -
                                            (1 - (bitvector & 0x1)) * hz;
                                        
                                        bitvector >>>= 1;
                                        

                                        if (boxlevel > 0 && rotateAngle > 0) {
                                            // rotate box about x-axis forwards
                                            dy = py * cosRotate - pz
                                                    * sinRotate;
                                            dz = py * sinRotate + pz
                                                    * cosRotate;
                                            py = dy + BOX_WIDTH; // rotating
                                                                 // from behind
                                                                 // where we
                                                                 // want to be
                                            pz = dz + BOX_WIDTH;
                                            faceRender = 0xff;
                                        } else if (boxlevel > 0 && h < 0) {
                                            // drop the box down
                                            pz -= (START_ROTATE_ANGLE - rotateAngle)
                                                    * BOX_WIDTH * 8.;
                                        }
                                        px += hx - viewPos3d[0];
                                        py += hy - viewPos3d[1];
                                        pz += height;

                                        // Full-out expansion
                                        // - eventually, this should be
                                        // compressed down into the
                                        // optimized form

                                        dx = sinZ * py + cosZ * px;
                                        dy = sinX * pz + cosX * (cosZ * py - sinZ * px);
                                        dz = cosX * pz - sinX * (cosZ * py - sinZ * px);
                                        // now translate the point into the
                                        // camera perspective
                                        dy += CAMERA_TO_ORIGIN_DIST;
                                        
                                        int xx = (int) (CAMERA_TO_VIEW_DIST
                                                * dx / dy)
                                                + VIEW_WIDTH_2;
                                        int yy = (int) (CAMERA_TO_VIEW_DIST
                                                * dz / dy)
                                                + VIEW_HEIGHT_2;
                                        int dd = (int) -(dx
                                                * dx + dy * dy + dz * dz);
                                        if (xx >= 0 && xx < VIEW_WIDTH &&
                                            yy >= 0 && yy < VIEW_HEIGHT) {
                                            renderPoints++;
                                        }

                                        points2dDist[point2dDistIndex++] = xx;
                                        points2dDist[point2dDistIndex++] = yy;
                                        // squared negative distance
                                        points2dDist[point2dDistIndex++] = dd;
                                    }
// i FREE

                                    // render faces
                                    if (renderPoints > 0) {
// i ALLOC
                                        for (i = 0; i < BOX_FACE_COUNT; i++) {
                                            if ((faceRender & (1 << (i + 1))) == 0) {
                                                continue;
                                            }
                                            
                                            int verticiesBitVector = data[
                                                BOX_FACE_VERTEX_BITVECTORS_START + i];
                                            int vv0 = (verticiesBitVector & 0x7);
                                            verticiesBitVector >>>= 3;
                                            int vv1 = (verticiesBitVector & 0x7);
                                            verticiesBitVector >>>= 3;
                                            int vv2 = (verticiesBitVector & 0x7);
                                            verticiesBitVector >>>= 3;
                                            int vv3 = (verticiesBitVector & 0x7);

                                            // correct way is to judge based on
                                            // the average of the
                                            // all the points, but even that
                                            // isn't quite correct.
                                            int dist = (
                                                points2dDist[
                                                     p0 + 2 + POINT2D_WITH_DIST_SIZE * vv0] +
                                                points2dDist[
                                                     p0 + 2 + POINT2D_WITH_DIST_SIZE * vv1] +
                                                points2dDist[
                                                     p0 + 2 + POINT2D_WITH_DIST_SIZE * vv2] +
                                                points2dDist[
                                                     p0 + 2 + POINT2D_WITH_DIST_SIZE * vv3]
                                                ) >> 2 /* / 4 */;

                                            px0 = p0
                                                + POINT2D_WITH_DIST_SIZE * vv0;
                                            xPoints[0] = points2dDist[px0];
                                            yPoints[0] = points2dDist[px0 + 1];
                                            px1 = p0
                                                + POINT2D_WITH_DIST_SIZE * vv1;
                                            xPoints[1] = points2dDist[px1];
                                            yPoints[1] = points2dDist[px1 + 1];
                                            px2 = p0
                                                + POINT2D_WITH_DIST_SIZE * vv2;
                                            xPoints[2] = points2dDist[px2];
                                            yPoints[2] = points2dDist[px2 + 1];
                                            px3 = p0
                                                + POINT2D_WITH_DIST_SIZE * vv3;
                                            xPoints[3] = points2dDist[px3];
                                            yPoints[3] = points2dDist[px3 + 1];
                                            

                                            // perform backface culling
                                            // Use the cross-product of the view
                                            // space transformed
                                            // face. If the z-component of the
                                            // cross product is
                                            // positive (facing towards us),
                                            // then it's viewable.
                                            //
                                            // z-component cross product only
                                            // uses x & y coordinates, so
                                            // we're golden here
                                            int v1 = xPoints[1] - xPoints[0];
                                            int w1 = xPoints[3] - xPoints[0];
                                            int v2 = yPoints[1] - yPoints[0];
                                            int w2 = yPoints[3] - yPoints[0];
                                            if ((v1 * w2 - v2 * w1) > 0) {
                                                // insertion sort
                                                // start from the back, since
                                                // the method for drawing
                                                // squares
                                                // is generally in-order. point
                                                // k to the distance of
                                                // the previous runs
                                                int k = facesDataIndex - 1;
                                                while (k > 0
                                                        && facesData[k] >= dist) {
                                                    k -= FACE_VALUE_COUNT;
                                                }
                                                // k points to the dist of the
                                                // one we're interested in;
                                                // change it to point to the
                                                // start
                                                k++;
                                                if (k < 0) {
                                                    k = 0;
                                                }
                                                // push all the other data
                                                // forward
                                                facesDataIndex += FACE_VALUE_COUNT;
                                                for (int m = facesDataIndex; --m >= k
                                                        + FACE_VALUE_COUNT;) {
                                                    facesData[m] = facesData[m
                                                            - FACE_VALUE_COUNT];
                                                }

                                                // 4 points + color + distance
                                                facesData[k++] = px0;
                                                facesData[k++] = px1;
                                                facesData[k++] = px2;
                                                facesData[k++] = px3;
                                                facesData[k++] = renderColor;
                                                facesData[k++] = dist;
                                            }
                                        }
// i FREE
                                    }
                                }
                            }
                        }
// i ALLOC
                        i = 0;
                        while (i < facesDataIndex) {
                            xPoints[0] = points2dDist[facesData[i]];
                            yPoints[0] = points2dDist[facesData[i++] + 1];
                            xPoints[1] = points2dDist[facesData[i]];
                            yPoints[1] = points2dDist[facesData[i++] + 1];
                            xPoints[2] = points2dDist[facesData[i]];
                            yPoints[2] = points2dDist[facesData[i++] + 1];
                            xPoints[3] = points2dDist[facesData[i]];
                            yPoints[3] = points2dDist[facesData[i++] + 1];
                            int renderColor = facesData[i++];
                            int dist = facesData[i++];

                            Color c;
                            double distPercent = (double) -dist
                                    / MAX_DIST_SQUARED;
                            int a = 0xff - ((renderColor >>> 24) & 0xff);
                            {
                                // protected Color getColor(int argb, int
                                // dist, boolean isLine) {
                                // dist is squared
                                int intensity = (int) (255 - 255 * distPercent);
                                if (intensity > 0) {
                                    if (intensity > 255) {
                                        intensity = 255;
                                    }
                                    
                                    // include fade factor
                                    intensity = intensity * fadeLevel / 255;
                                    
                                    int r = (((renderColor >>> 16) & 0xff) * intensity) >> 8;
                                    int g = (((renderColor >>> 8) & 0xff) * intensity) >> 8;
                                    int b = ((renderColor & 0xff) * intensity) >> 8;
                                    c = new Color(r, g, b, a);
                                    ogr.setColor(c);
                                    ogr.fillPolygon(xPoints, yPoints,
                                            BOX_FACE_POINT_COUNT);
                                }
                            }

                            // lines are more intense, and fade slower
                            distPercent /= 2.;
                            {
                                // protected Color getColor(int argb, int
                                // dist, boolean isLine) {
                                // dist is squared
                                int intensity = (int) (255 - 255 * distPercent);
                                if (intensity > 0) {
                                    if (intensity > 255) {
                                        intensity = 255;
                                    }
                                    
                                    // don't include fade factor?
                                    // - this allows for the wireframe to show
                                    //   through, giving a better preview
                                    intensity = intensity * fadeLevel / 255;
                                    
                                    
                                    int r = (((renderColor >>> 16) & 0xff) * intensity) >> 8;
                                    int g = (((renderColor >>> 8) & 0xff) * intensity) >> 8;
                                    int b = ((renderColor & 0xff) * intensity) >> 8;
                                    c = new Color(r, g, b, a);
                                    ogr.setColor(c);
                                    ogr.drawPolygon(xPoints, yPoints,
                                            BOX_FACE_POINT_COUNT);
                                }
                            }
                        }
// i FREE

                        // ========================================================
                        // Draw stats
                        ogr.setColor(white);
                        yPoints[0] = yPoints[1] = 16;
                        if (level > 0) {
                            ogr.drawString(Integer.toString(levelscore), 2, 14);
                            xPoints[0] = 2;
                            xPoints[1] = 26;
                            ogr.drawPolygon(xPoints, yPoints, 2);
                            ogr.drawString(Integer.toString(levelPar[level]), 2,
                                    29);
                            ogr.setColor(green);
                            ogr.drawString(Integer.toString(level), 2, 42);
                            ogr.setColor(white);
                        }
                        ogr.drawString(
                                Integer.toString(totalscore + levelscore),
                                VIEW_WIDTH - 30, 14);
                        xPoints[0] = VIEW_WIDTH - 30;
                        xPoints[1] = VIEW_WIDTH - 4;
                        ogr.drawPolygon(xPoints, yPoints, 2);
                        ogr.drawString(Integer.toString(totalpar),
                                VIEW_WIDTH - 30, 29);
                        
                        /* fps
                        int fps = (int) (10000000000. / (double) (System
                                .nanoTime() - lastTime));
                        if (fps < 0) {
                            fps = 0 - fps;
                        }
                        ogr.drawString(Integer.toString(fps / 10) + "."
                                + Integer.toString(fps % 10), 2,
                                VIEW_HEIGHT - 1);
                        */
                        if (msgPosY >= 0) {
                            ogr.drawString(msg, 2, msgPosY);
                            msgPosY += 4;
                            if (msgPosY > VIEW_HEIGHT + 5) {
                                msgPosY = -1;
                            }
                        }
                        // ========================================================
                        // re-initialize on each frame, to handle the case where
                        // the user clicks away and comes back
                        Graphics sg = getGraphics();
                        sg.drawImage(image, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, // destination
                                0, 0, VIEW_WIDTH, VIEW_HEIGHT, // source
                                null);
                        do {
                            Thread.yield();
                        } while (System.nanoTime() - lastTime < 0);
                        if (!isActive()) {
                            return;
                        }

                        lastTime += (1000000000 / FRAMES_PER_SECOND);
                    }
                }
            }
        }
    }

    //private static final int MAX_BASELENGTH = 4444;
    //private static final int MAX_BASEWIDTH = 7;

    

    private boolean[] keys = new boolean[KEY_COUNT];
    private static final int KEY_FORWARD = 0;
    private static final int KEY_LEFT = 1;
    private static final int KEY_RIGHT = 2;
    private static final int KEY_BACK = 3;
    private static final int KEY_DROP = 4;
    private static final int KEY_ACTIVATE = 5;
    private static final int KEY_RESTART = 6;
    private static final int KEY_NEXT = 7;
    private static final int KEY_COUNT = 8;
    

    private static final double MAX_ROTATE_ANGLE = 1.5707963267948966;
        /*Math.PI / 2.;*/
    private static final int BETWEEN_LEVEL_FRAMECOUNT = 45;
        /* 1.5 * FRAMES_PER_SECOND */
    // 3 seconds per quarter turn
    private static final double ROTATE_ANGLE_SPEED = 0.02617993877991494;
        /* MAX_ROTATE_ANGLE / 2. / FRAMES_PER_SECOND;*/
    // 2 seconds of stationary
    private static final double START_ROTATE_ANGLE = -1.5707963267948966;
        /* 0. - ROTATE_ANGLE_SPEED * FRAMES_PER_SECOND * 2.; */
    private static final double ROTATE_ANGLE_ADJUST = 4.71238898038469;
        /*Math.PI * 3. / 2.;*/
    
    private static final double INTRO_ROTATE_SPEED = 0.026179939;
        /* Math.PI / 4. / FRAMES_PER_SECOND; */
    private static final double CIRCLE_RADIANS = 6.283185308;
        /* Math.PI * 2.; */
    
    // movement statics
    private static final int MAX_XLATE_SPEED = 10;

    // precalcs
    //private static final double AXIS_X_ROTATE_ANGLE = 1.0471975511965976;
        /*Math.PI / 3.*/
    private static final double COS_X = 0.5;
        /*Math.cos(AXIS_X_ROTATE_ANGLE);*/
    private static final double SIN_X = 0.8660254037844386;
        /*Math.sin(AXIS_X_ROTATE_ANGLE);*/

    // definitions for camera & view plane
    private static final int BOX_WIDTH = 100;
    private static final double CAMERA_TO_VIEW_DIST = 190;
    private static final double CAMERA_TO_ORIGIN_DIST = 650;
    //private static final double CAMERA_HEIGHT = 562.9165124598851;
        /* CAMERA_TO_ORIGIN_DIST * SIN_X; */
    private static final double MAX_ANGLE = 1.0471975511965976;
        /*Math.PI / 3.; */
    private static final double MIN_ANGLE = -1.0471975511965976;
        /*0 - Math.PI / 3.;*/
    
    private static final int BOX_HEIGHT_REDUCE_PER_FRAME = 10;

    // derivations of precalcs and camera
    // lower bounds to the view frustrum
    //private static final double CAMERA_Y_TO_LOWER_BOUND_Z0 = -82.02193963201515;
        /* CAMERA_HEIGHT * Math.tan(Math.PI / 2. - AXIS_X_ROTATE_ANGLE
                    - Math.atan(VIEW_HEIGHT_2 / CAMERA_TO_VIEW_DIST)); */
    private static final double CAMERA_HEIGHT_OVER_LOWER_BOUND_Z0 = -6.862999277819628;
        /* CAMERA_HEIGHT / CAMERA_Y_TO_LOWER_BOUND_Z0; */
    // A non-mathematical hack to account for the X rotation
    private static final double CAMERA_HEIGHT_OVER_LOWER_BOUND_Z0_HACK = -8437.08348754;
        /* CAMERA_HEIGHT - 90 * BOX_WIDTH; */

    private static final int VERTICES_COUNT = 8;
    private static final int POINT2D_WITH_DIST_SIZE = 3;

    //private static final int[] BOX_VERTICES_3D = {
    //        0, 0, 0,
    //        BOX_WIDTH, 0, 0,
    //        BOX_WIDTH, BOX_WIDTH, 0,
    //        0, BOX_WIDTH, 0,
    //
    //        0, 0, BOX_WIDTH,
    //        BOX_WIDTH, 0, BOX_WIDTH,
    //        BOX_WIDTH, BOX_WIDTH, BOX_WIDTH,
    //        0, BOX_WIDTH, BOX_WIDTH, };
    // the above is converted in reverse order
    // with ZYX ordered bits
    //   in binary:
    //    110 111 101 100 010 011 001 000
    //   which in hex:
    //    1101 1110 1100 0100 1100 1000
    private static final int BOX_VERTICIES_BITVECTOR =
            0xdec4c8;
    private static final int BOX_FACE_POINT_COUNT = 4;
    private static final int BOX_FACE_COUNT = 6;
    
    private static final int BASE_COLOR = 4; /*BOX_COLOR.length - 1; */
    private static final int PLAYER_ON_BOX_COLOR = 0x00002f;
    private static final int PLAYER_COLOR = 0x00ff80ff;
    private static final int MARKED_BOX_COLOR = 0x7f7f00;
    private static final int BOMB_BOX_COLOR = 0x7f007f;
    private static final int MARKED_BOMBBOX_COLOR = 0x007f00;
    private static final int MARKED_BADBOX_COLOR = 0x2f2f2f;
    private static final int POINTER_COLOR = 0x8000ff00;

    //private static final int MAX_BOX_LEVELS = 2;
    
    
    //private static final int MAX_FACES = 62216;
        /* (MAX_BOX_LEVELS * MAX_BASELENGTH * MAX_BASEWIDTH); */
    
    // + 1 for the color, + 1 for the distance, and 4 verticies
    private static final int FACE_VALUE_COUNT = 6;
        /* BOX_FACE_POINT_COUNT + 2; */
    private static final int MAX_FACEPOINTS = 373296;
        /* MAX_FACES * FACE_VALUE_COUNT; */
    private static final int MAX_POINT2D_SIZE = 746592;
        /* MAX_FACES * BOX_FACE_POINT_COUNT * POINT2D_WITH_DIST_SIZE; */

    //private static final double MAX_DIST = 1450.0;
        /* BOX_WIDTH * 10 + (CAMERA_TO_ORIGIN_DIST - MAX_BOX_LEVELS * BOX_WIDTH); */
    private static final double MAX_DIST_SQUARED = 2102500.0;
        /* MAX_DIST * MAX_DIST; */

    public boolean handleEvent(Event e) {
        // Process the key and mouse events.
        // Note that this can miss key and mouse events if they happen faster
        // than the frame processing can accept them. Fixing this, though,
        // leads to having to deal with key repeats being processed as multiple
        // key pressed and key released events.
        boolean down = false;

        switch (e.id) {
        case Event.KEY_PRESS:
        case Event.KEY_ACTION:
            down = true;
            // fall through
        case Event.KEY_RELEASE:
            switch (e.key) {
                case 'w':
                case 'W':
                case 'i':
                case 'I':
                    this.keys[KEY_FORWARD] = down;
                    break;
                case 'a':
                case 'A':
                case 'j':
                case 'J':
                    this.keys[KEY_LEFT] = down;
                    break;
                case 's':
                case 'S':
                case 'k':
                case 'K':
                    this.keys[KEY_BACK] = down;
                    break;
                case 'd':
                case 'D':
                case 'l':
                case 'L':
                    this.keys[KEY_RIGHT] = down;
                    break;
                case ' ':
                    this.keys[KEY_DROP] = down;
                    break;
                case '\n':
                case 'v':
                case 'V':
                    this.keys[KEY_ACTIVATE] = down;
                    break;
                case 'r':
                case 'R':
                    this.keys[KEY_RESTART] = down;
                    break;
                case 'n':
                case 'N':
                    this.keys[KEY_NEXT] = down;
            }
        }
        return false;
    }

}
