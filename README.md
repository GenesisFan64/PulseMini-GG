# PulseMini-GG
A Sound Driver for Game Gear / Master System

NOTE: this source code is actually a sound tester, the driver code is located at /system/sound.asm

# Features
- All PSG Channels supported, I don't have plans for YM2413 but it can be implemented
- PSG instruments (not just a single beep), NOISE channel auto-mute detection for Tone3 mode
- Stereo sound on Game Gear
- Channel effects currently supported: Volume Slide (Dxx), Portametro (Exx) (Fxx) and Panning (Xxx)

The assembler used here is a custom version of AS Micro Assembler (both executables for Linux and Windows), the original was made by Alfred Arnold, coding is done on Linux so I haven't checked if it compiles on Windows...

# Scripts
This source uses Python3 scripts as file convertors for the following things:
- AS .p to BIN
- ImpulseTracker files to a custom format used by this driver
- .tga files to Game Gear graphics and palette (optional)*

(Graphics format is the same on Master System, but not the palette, there's a routine that converts GG's colors for MS on the fly)

Documentation is not done yet, but if you are still interested on using it on a big project, contact me (at)_gf64 on Twitter
