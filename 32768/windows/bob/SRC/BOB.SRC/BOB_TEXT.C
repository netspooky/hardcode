/*
  This file is part of bob, a 32k game for Mekka Symposium 2001.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file copying.txt); if not, write 
  to the Free Software Foundation, Inc., 
  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "bob_text.h"

#include <stdio.h>

menu_item menu_common_back = { ACTION_BACK, NULL, "back" };

menu_item menu_radix1_b    = { ACTION_R1_B, NULL, "2" };
menu_item menu_radix1_o    = { ACTION_R1_O, NULL, "8" };
menu_item menu_radix1_d    = { ACTION_R1_D, NULL, "10" };
menu_item menu_radix1_h    = { ACTION_R1_H, NULL, "16" };

menu_item * menu_radix1[]  = { &menu_radix1_b,
                               &menu_radix1_o,
                               &menu_radix1_d,
                               &menu_radix1_h,
                               NULL };

menu_item menu_radix2_b    = { ACTION_R2_B, NULL, "2" };
menu_item menu_radix2_o    = { ACTION_R2_O, NULL, "8" };
menu_item menu_radix2_d    = { ACTION_R2_D, NULL, "10" };
menu_item menu_radix2_h    = { ACTION_R2_H, NULL, "16" };

menu_item * menu_radix2[]  = { &menu_radix2_b,
                               &menu_radix2_o,
                               &menu_radix2_d,
                               &menu_radix2_h,
                               NULL };

menu_item menu_map1_qwerty = { ACTION_QWER1, NULL, "qwerty" };
menu_item menu_map1_dvorak = { ACTION_DVOR1, NULL, "dvorak" };

menu_item * menu_map1[]    = { &menu_map1_qwerty,
                               &menu_map1_dvorak,
                               NULL };

menu_item menu_map2_qwerty = { ACTION_QWER2, NULL, "qwerty" };
menu_item menu_map2_dvorak = { ACTION_DVOR2, NULL, "dvorak" };

menu_item * menu_map2[]    = { &menu_map2_qwerty,
                               &menu_map2_dvorak,
                               NULL };

menu_item menu_cpu1_yes    = { ACTION_CPU1, NULL, "yes" };
menu_item menu_cpu1_no     = { ACTION_MAN1, NULL, "no" };

menu_item * menu_cpu1[]    = { &menu_cpu1_yes,
                               &menu_cpu1_no,
                               NULL };

menu_item menu_cpu2_yes    = { ACTION_CPU2, NULL, "yes" };
menu_item menu_cpu2_no     = { ACTION_MAN2, NULL, "no" };

menu_item * menu_cpu2[]    = { &menu_cpu2_yes,
                               &menu_cpu2_no,
                               NULL };

menu_item menu_cfg1_kmap   = { ACTION_NOP,   &menu_map1, "keymap" };
menu_item menu_cfg1_name   = { ACTION_NAME1, NULL, "name" };
menu_item menu_cfg1_keyb   = { ACTION_KEYB1, NULL, "controls" };
menu_item menu_cfg1_radx   = { ACTION_NOP,   &menu_radix1, "radix" };
menu_item menu_cfg1_cpu    = { ACTION_NOP  , &menu_cpu1, "cpu player?" };

menu_item * menu_cfg1[]    = { &menu_cfg1_kmap,
                               &menu_cfg1_name,
                               &menu_cfg1_keyb,
                               &menu_cfg1_radx,
                               &menu_cfg1_cpu,
                               &menu_common_back,
                               NULL };

menu_item menu_cfg2_kmap   = { ACTION_NOP  , &menu_map2, "keymap" };
menu_item menu_cfg2_name   = { ACTION_NAME2, NULL, "name" };
menu_item menu_cfg2_keyb   = { ACTION_KEYB2, NULL, "controls" };
menu_item menu_cfg2_radx   = { ACTION_NOP  , &menu_radix2, "radix" };
menu_item menu_cfg2_cpu    = { ACTION_NOP  , &menu_cpu2, "cpu player?" };

menu_item * menu_cfg2[]    = { &menu_cfg2_kmap,
                               &menu_cfg2_name,
                               &menu_cfg2_keyb,
                               &menu_cfg2_radx,
                               &menu_cfg2_cpu,
                               &menu_common_back,
                               NULL };

menu_item menu_games_4     = { ACTION_GAME4,  NULL,  "4" };
menu_item menu_games_8     = { ACTION_GAME8,  NULL,  "8" };
menu_item menu_games_16    = { ACTION_GAM16,  NULL, "16" };
menu_item menu_games_32    = { ACTION_GAM32,  NULL, "32" };
menu_item menu_games_64    = { ACTION_GAM64,  NULL, "64" };

menu_item * menu_games[]   = { &menu_games_4,
                               &menu_games_8,
                               &menu_games_16,
                               &menu_games_32,
                               &menu_games_64,
                               NULL };

menu_item menu_cfg_p1     = { ACTION_NOP  , &menu_cfg1,  "p1 setup" };
menu_item menu_cfg_p2     = { ACTION_NOP  , &menu_cfg2,  "p2 setup" };
menu_item menu_cfg_games  = { ACTION_NOP  , &menu_games, "championship" };
menu_item menu_cfg_save   = { ACTION_SAVE , NULL, "save setup" };

menu_item * menu_cfg[]    = { &menu_cfg_p1,
                              &menu_cfg_p2,
                              &menu_cfg_games,
                              &menu_cfg_save,
                              &menu_common_back,
                              NULL };

#ifdef MENU_INFO
menu_item menu_info_story = { ACTION_STORY, NULL, "story" };
menu_item menu_info_disc  = { ACTION_DISC , NULL, "disclaimer" };
menu_item menu_info_cred  = { ACTION_CRED , NULL, "credits" };
#endif

#ifdef MENU_INFO
menu_item * menu_info[]   = { &menu_info_story, 
                              &menu_info_disc, 
                              &menu_info_cred, 
                              &menu_common_back,
                              NULL };
#endif

menu_item menu_main_start = { ACTION_GAME, NULL      , "start game" };
menu_item menu_main_cfg   = { ACTION_NOP , &menu_cfg , "options" };
#ifdef MENU_INFO
menu_item menu_main_info  = { ACTION_NOP , &menu_info, "info" };
#endif
menu_item menu_main_quit  = { ACTION_BACK, NULL      , "quit" };

menu_item * menu_main[]  = { &menu_main_start, 
                              &menu_main_cfg, 
#ifdef MENU_INFO
                              &menu_main_info, 
#endif
                              &menu_main_quit,
                              NULL };

menu_item menu_quit_quit  = { ACTION_NOP , NULL      , "quit game?" };
menu_item menu_quit_yes   = { ACTION_QUIT, NULL      , "yes" };
menu_item menu_quit_no    = { ACTION_NOP,  &menu_main, "no" };

menu_item * menu_quit[]   = { &menu_quit_quit, 
                              &menu_quit_yes, 
                              &menu_quit_no,
                              NULL };

#ifdef MENU_INFO
char * DISCLAIMER = "bob [a game in 32k]\n"
  "copyright 2001 warp/bliss.\n"                 
  "\n"                                           
  "this program is free software; you can\n"     
  "redistribute it and/or modify it under\n"     
  "the terms of the gnu general public\n"        
  "license as published by the free\n"           
  "software foundation; either version 2\n"      
  "of the license, or [at your option] any\n"    
  "later version.\n"                             
  "\n"                                           
  "this program is distributed in the hope\n"    
  "that it will be useful, but without any\n"    
  "warranty; without even the implied\n"         
  "warranty of merchantability or fitness\n"     
  "for a particular purpose. see the gnu\n"      
  "general public license for more details.\n"   
  "\n"                                           
  "you should have received a copy of the\n"     
  "gnu general public license along with\n"      
  "this program; see the file copying.txt;\n"    
  "if not, write to the free software\n"         
  "foundation, inc., 59 temple place,\n"         
  "suite 330, boston, ma  02111-1307  usa.\n"    
  "\n"                                           
  "\n"                                           
  "press <action> to continue.";
#endif

#ifdef MENU_INFO
char * STORY = "bob\n"               
  "copyright 2001 warp/bliss.\n"                 
  "\n"                                           
  "once upon a time there was a snowman.\n"      
  "a snowman called bob, which is a very\n"      
  "good name for a snowman. this snowman\n"      
  "called bob had a friend called bob.\n"        
  "which seems rather confusing, but bob\n"      
  "didn't mind, and neither did bob.\n"          
  "\n"                                           
  "one day, bob and bob had an argument,\n"      
  "and they stopped talking to each other.\n"    
  "but then they got real lonely on\n"           
  "christmas, and so both of them decided\n"     
  "to make a new friend out of snow. when\n"     
  "bob saw what bob was doing things got\n"      
  "really ugly while both of them tried\n"       
  "to sabotage the other's progress...\n"        
  "\n"                                           
  "so, this is where you people come in,\n"      
  "please help bob and bob create their\n"       
  "friend out of snow.\n"                        
  "\n"                                           
  "press <action> to continue.\n"                
  "\n"                                           
  "ps. avoid the evil mutant snowmen.";
#endif

#ifdef MENU_INFO
char * CREDITS = "credits:\n\n"
  "the idea for bob and bob came from a\n"
  "commodore 64 game called jawbreaker\n"
  "\n"
  "code: warp.\n"
  "graphics: warp.\n"
  "music: tharsis.\n"
  "music player: fxmp by spectre of flare.\n"
  "\n"
  "many thanks to smoke and avoozl for help\n"
  "and support.\n"
  "\n"
  "and thanks to cougar for driving me and\n"
  "avoozl to MS2001 on such short notice.\n"
  "\n"
  "this game is a 32k game compo entry for\n"
  "mekka&symposium 2001.\n"
  "\n"
  "visit http://lnxscene.org and #demoscene\n"
  "for all your open source demo needs.\n"
  "\n"
  "bliss is at http://www.demonic.demon.nl,\n"
  "and you can reach me at <warp-tmt@dds.nl>.\n"
  "\n"
  "press <action> to continue.";
#endif

char * PRESS_UP     = "press key for up";
char * PRESS_DOWN   = "press key for down";
char * PRESS_LEFT   = "press key for left";
char * PRESS_RIGHT  = "press key for right";
char * PRESS_ACTION = "press key for action";
char * PRESS_ESCAPE = "press key for escape";

char * ENTER_NAME   = "enter your name:";
char * CONTINUE     = "press <action> to continue.";
char * SAVE_ERROR   = "error saving bob.cfg.";
char * SAVED        = "saved settings to bob.cfg.";

