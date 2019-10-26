雇用の欺瞞

作者: Tomohiro
メガデモコンサルタント: hole, q
ジャンル: PC 4k intro
Tokyo Demo Fest 2014で公開

実行は自己責任でお願いします。
プログラムが起動しない場合, 一時的にアンチウィルスソフトを無効にすると動く場合があります。
(自分のPCではアバストを無効にしないと実行できない)

使い方
--------
Escキーで終了。

必要なもの
--------
OpenGL3をサポートした3Dアクセラレータ.
NvidiaとIntelの3Dアクセラレータしか持ってないけど,
OpenGLの仕様書を読んでだいたい規格通りにOpenGLを使ったつもりなので
OpenGL3に対応した3Dアクセラレータなら動くはず・・・

OS: Windows7 or 8 (テストしてないけどXP, Vistaでも動くかも)
CPU: x87 FPUに対応したCPU
(1スレッドしか使わないので, マルチコアCPUで動かしても意味無いです)

Credit
--------
Code, Sound, etc: Tomohiro

使った道具
--------
Crinkler:
コードを圧縮してくれる凄いリンカ.
http://www.crinkler.net/

shader_minifier.exe
GLSLのコードを圧縮されやすいように変換するツール.
これ無しで4k intro用のGLSLコードを書くのは凄くたいへん!
http://www.ctrl-alt-test.fr/?p=358

glew4k:
4k intro用にOpenGLの拡張関数を準備してくれるライブラリ.
https://github.com/demotomohiro/glew4kb

gvim:
世界最強の唯一のエディタ!

Opera:
オペラ最強伝説

Microsoft Visual C++ 2012 Express Edition:
無料のプログラム開発環境.

API:
--------
OpenGL 3.3
win32api

メールアドレス:
--------
gpuppur@gmail.com

TwitterID
--------
@demotomohiro
