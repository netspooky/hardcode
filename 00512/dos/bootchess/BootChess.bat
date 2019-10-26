cls
@echo off
echo """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "                   ___ _                                                    "
echo "                  /     /         _____ _ _      _____ _ _        ___ _     "
echo "     .::.        /     /         /     /  /     /     /  /       /     /    "
echo "     ::::       /     / ____  .-/   _ ___/-. .-/   _ ___/-.     /     /__   " 
echo "      ::       /            \ |    |  .    | |    |  .    |    /        /'  "
echo "      ::            __ _     \     l  |    | |    l  |    |   /     ___/    "
echo "     .::.    /     /   /     /     |  l    |_|    l  |    |__/     / ____   "
echo "    .::::.        / __/            `--'           `--'            /      |  " 
echo "   ::::::::                /                               /             |  "
echo "                    ___ __    Cl!   ___ ___ /      ___ _ _             __|  "
echo "        ___ _ _    /   __/_ __  _ _/      _/_   _ /_  /  /        ___ /__   " 
echo "     /_/   /  / / /   / /            _____/ /  / /    __/      _ /   /  /   "
echo "  .-/     ___/   /     /______         /      ___\    \___    / /    __/    "
echo "  |      /      /     /       |     __/ ___  |    \       |  ___\    \___   " 
echo "  |     /  ____               |    /       | |   _/       | |    \       |  "
echo "  |    /--/    |     ___/     |            | |            | |   _/       |  " 
echo "  |            |    /  /  ::  | ____/  ::  | |  ::  \_____| |            |  "
echo "  |_____/  ::  | __/  /_______|    /_______| |_______\      |  ::  \_____|  "
echo "       /_______|     /___ _       /___ _         _ ___\     |_______\       " 
echo "      /___ _                                                    _ ___\      "
echo "                                                                            " 
echo """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo BootChess SIMPLE MAKE FLOPPY BOOT
echo 
echo Make sure an unprotected 1.44 3.5 floppy is present and press any key
pause
fasm BootChess.asm
del /F /Q floppy.bin
ren BootChess.bin floppy.bin
partcopy floppy.bin 0 200 -f0
echo Make sure BIOS boot order 1st Boot Device is set to Floppy and reboot
pause
exit