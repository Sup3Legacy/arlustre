all:
	heptc interface.epi && heptc -target zig test.lus && gcc -c -I /home/constantin/.opam/4.12.0/.opam-switch/sources/heptagon.1.05.00/lib/c -I . interface.c test_c/*.c

upload:
	avrdude -carduino -patmega328p -D -P /dev/ttyACM0 -Uflash:w:./zig-out/bin/arlustre:e 

screen:
	screen /dev/ttyACM0 115200

heptc:
	heptc -s main -target zig top.lus

clean:
	rm src/*.epci -f
	rm src/*.log -f
	rm src/*.mls -f
	rm src/*.o -f
	rm src/*.obc -f
	rm zig-cache -r -f
	rm src/zig-cache -r -f
	rm zig-out -r -f
