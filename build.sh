clear
echo "** MASTER SYSTEM **"
tools/AS/linux/asl main.asm -q -xx -c -A -olist out/rom_sms.lst -A -L -D MERCURY=0
python tools/p2bin.py main.p out/rom.sms
python tools/mschksm.py out/rom.sms 0x8000
echo "** GAME GEAR **"
tools/AS/linux/asl main.asm -q -xx -c -A -olist out/rom_gg.lst -A -L -D MERCURY=1
python tools/p2bin.py main.p out/rom.gg
python tools/mschksm.py out/rom.gg 0x8000
rm main.p
rm main.h
