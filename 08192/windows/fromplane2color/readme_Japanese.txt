FromPlane2Color
PC 64k (or 5k) intro for Tokyo Demo Fest 2011
by Tomohiro

このデモは2Dグラフィックスがメインです。
OpenGL, DirectX, OpenCL, PhysX, CUDA等のGDI以外のGPU関連APIは使っていません。
全ピクセルの値はCPUのみで計算しています。
このデモは音を出しません。
ソースコードも一緒に入っているので, よければデモを作るときの参考にして下さい。

デモ作成時にiqさんのサイトを参照しました。
http://iquilezles.org/
様々なテクニックや各種4k introのベースになるソースコード, 役立つツール等が公開されています。

必要条件
--------
OS: WindowsXP, WindowsVista or Windows7
CPU: support SSE3
(このプログラムは1スレッドしか使わないのでメニーコアCPUは意味ありません。
もっと時間があればメニーコア対応したかった。)

Credit
--------
Code: Tomohiro

使用したツール.
--------
Crinkler:
プログラムを圧縮してくれる凄いリンカーです。
gvim:
これが無いとコードを書くことができません。
Microsoft Visual C++ 2008 Express Edition:
無料の開発環境.

API:
--------
win32api
SSE3
GDI

contact:
--------
gpuppur@gmail.com
http://twitter.com/demotomohiro
