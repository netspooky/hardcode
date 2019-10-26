strip -s -R .comment -R .gnu.version demo
sstrip demo
upx-nrv --ultra-brute --overlay=strip --all-methods --all-filters --no-mode --no-owner --no-time --lzma demo
sstrip demo

