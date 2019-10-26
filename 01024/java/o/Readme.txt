    
            oooooo
          oo      oo
         o          o
        o  1k intro  o
        o  Assembly  o
        o    2012    o
         o          o
          oo      oo
            oooooo

Created by Itchi / Lonely Coders

This is a 1 kilobyte Java program compressed to a Windows batch script.
Run by doubleclicking o.bat file in Windows Explorer or executing command "o.bat" from console.
Java must be properly installed and found from PATH.
A generic cross-platform version is available as o_safe.jar. You can run it with the command "java -jar o_safe.jar" or by double clicking the file.
The intro only supports 1280x720 resolution.

The program has been hand-optimized with Java assembly language.
This intro pales in comparison with modern 1k-intros (e.g. no music), but creating this was a fun experiment and I wanted to see if it is possible to create small intros with Java.
The following programs have been used for development:
 IntelliJ IDEA - Java IDE (http://www.jetbrains.com/idea/)
 Apache Ant - Java based build system (http://ant.apache.org/)
 ProGuard - Java class file optimizer (http://proguard.sourceforge.net/)
 Jasper - Java Class File Disassembler (http://www.angelfire.com/tx4/cus/jasper/)
 Jasmin - Java Assembler (http://jasmin.sourceforge.net/)

Greetings to Unreal Voodoo, Blobtrox, Moonhazard, Traction and Faemiyah

Q. When starting the intro, the following error is printed to console:
'PK??¶' is not recognized as an internal or external command, operable program or batch file.
A. This is intentional. Don't mind, the intro should work despite this message if Java is properly installed.

Q. When pressing ESC, the application terminates with the following error printed to console:
Exception in thread "main" java.lang.NullPointerException
        at o.main(Unknown Source)
A. This is not a problem either. Throwing NullPointerException is just an optimized way to terminate the application.
