.PHONY: all clean

all: hello.exe

%.obj: %.s
	nasm -fwin64 $<

%.exe: %.obj
	gcc -o $@ $^

clean:
	rm -f *.obj *.exe
