4k GPGPU calc

作者: Tomohiro
Tokyo Demo Fest 2013で公開

実行は自己責任でお願いします。
プログラムが起動しない場合, 一時的にアンチウィルスソフトを無効にすると動く場合があります。
(自分のPCではアバストを無効にしないと実行できない)

このプログラムは入力した数式を計算して表示します。

この作品では2chで見つけたAAを一部改良して使用しています。

特徴
--------
・一文字づつ入力する健気なあなたを激しいダンスで励まします。
・エラーがでても楽しいAAでやる気アップ！
・log(-1.1)や1.1/0.と入力して結果がNaNやInfinityになってもAAがなんとか場を濁す。
・計算結果にあわせて違うAAが表示される。
・音もでます。

使い方
--------
画面の一番上に数式を入力してEnter keyを押すと結果がでます。
入力はGLSLのfloat式になっている必要があります。
Example.txtに書いてある例を参考にして下さい。
Escキーで終了。

必要なもの
--------
OpenGL3以上をサポートした3Dアクセラレータ.
Nvidiaの3Dアクセラレータしか持ってないけど,
OpenGLの仕様書を読んでだいたい規格通りにOpenGLを使ったつもりなので
OpenGL3に対応した3Dアクセラレータなら動くはず・・・

OS: Windows7 or 8
CPU: x87 FPUに対応したCPU
(1スレッドしか使わないので, マルチコアCPUで動かしても意味無いです)

Credit
--------
Code, Sound, etc: Tomohiro
AA: 名も無きにちゃんねら

使った道具
--------
Crinkler:
コードを圧縮してくれる凄いリンカ.
http://www.crinkler.net/

gvim:
世界で一番のエディタ!

Opera:
オペラ最強伝説

Microsoft Visual C++ 2012 Express Edition:
無料のプログラム開発環境.

API:
--------
OpenGL 3.2
win32api

メールアドレス:
--------
gpuppur@gmail.com

TwitterID
--------
@demotomohiro
