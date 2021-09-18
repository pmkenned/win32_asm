@echo off

nasm -fwin32 hello_win32.asm
golink.exe /entry:go /console kernel32.dll user32.dll hello_win32.obj

nasm -f win64 MessageBox64.asm -o MessageBox64.obj
golink /entry:Start kernel32.dll user32.dll MessageBox64.obj

rem THESE PROGRAMS DON'T WORK (wait, yes they do?):

nasm -f win64 BasicWindow64.asm -o BasicWindow64.obj
golink /entry:Start kernel32.dll user32.dll BasicWindow64.obj

nasm -f win32 BasicWindow32.asm -o BasicWindow32.obj
golink /entry:Start kernel32.dll user32.dll BasicWindow32.obj
