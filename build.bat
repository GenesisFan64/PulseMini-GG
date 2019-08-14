@echo off
cls
echo ** MASTER SYSTEM **
"tools\AS\win32\asw" main.asm -q -xx -c -A -olist out/rom_sms.lst -A -L -D MERCURY=0
C:\Python30\python tools/p2bin.py main.p out/rom.sms
C:\Python30\python tools/mschksm.py out/rom.sms 0x8000
echo ** GAME GEAR **
"tools\AS\win32\asw" main.asm -q -xx -c -A -olist out/rom_gg.lst -A -L -D MERCURY=1
C:\Python30\python tools/p2bin.py main.p out/rom.gg
C:\Python30\python tools/mschksm.py out/rom.gg 0x8000
del main.p
del main.h
pause
