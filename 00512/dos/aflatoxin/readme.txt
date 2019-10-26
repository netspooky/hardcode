510バイトの粒が舞うデモです。

実行は自己責任でお願いします。

video.comが実行ファイルです。
Windows XPだと直接起動できるかもしれませんが
Vistaだとエラーがでると思います。
その場合はDOSBoxというフリーウェアをご使用下さい。
http://www.dosbox.com/

またはAFLAtoxin_qemu.batを実行して下さい。
この場合はqemuというCPUエミュレータ上で
AFLAtoxin.bin
の中身がMBR(Master Boot Record)にあるプログラムとして実行されます。
MBRとはPCが起動してOSを立ち上げるときに一番最初に実行されるプログラムが格納された場所です。
AFLAtoxin.binをハードディスクかUSBメモリの最初の510バイトに書き込んで
PCをそこから起動させるとプログラムが実行されると思います。

QEMUのサイト
http://www.qemu.org/

http://www.youtube.com/watch?v=6Mlw8UY2Ed8
にキャプチャした動画があります。

開発者はWindows XPを持っていないのでWindows XPで正常に動作するかテストしていません。

このプログラムは2008年頃に作ったものです。
付属のqemuもそのときに使っていたものです。

real modeで動作します。