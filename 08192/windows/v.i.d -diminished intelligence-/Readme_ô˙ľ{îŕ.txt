V.I.D ～奪われた思考力～

作者: Tomohiro
ブラック・メガデモコンサルタント: hole, q
ジャンル: PC 8k intro
Tokyo Demo Fest 2016で公開

実行は自己責任でお願いします。
プログラムが起動しない場合, 一時的にアンチウィルスソフトを無効にすると動く場合があります。

使い方
--------
Escキーで終了。

必要なもの
--------
OpenGL 4.2をサポートした3Dアクセラレータ.
(nVidiaだったらGeforce400代以降のGPU)
OpenGLの仕様書を読んでだいたい規格通りにOpenGLを使ったつもりなので
OpenGL4に対応した3Dアクセラレータなら動くはず・・・

OS: Windows7 or 8 (テストしてないけどXP, Vistaでも動くかも)
CPU: x87 FPUに対応したCPU
(1スレッドしか使わないので, マルチコアCPUで動かしても意味無いです)

動かないときは
--------
たいていの4k introはプログラムサイズをできるだけ小さくするためにエラーチェック
していません。
ファイル名にdebugがついている実行ファイルは4k introと同じ映像と音楽を作りますが,
エラーチェックを行い, 問題があればコンソールにメッセージが表示されます。

使った道具
--------
Crinkler:
4k introを作るときの定番ツール.
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

Microsoft Visual Studio Community 2013:
無料のプログラム開発環境.

API:
--------
OpenGL 4.2
win32api

メールアドレス:
--------
gpuppur@gmail.com

GitHub
--------
https://github.com/demotomohiro

TwitterID
--------
@demotomohiro
