all:
	heptc interface.epi && heptc -target c test.lus && gcc -c -I /home/constantin/.opam/4.12.0/.opam-switch/sources/heptagon.1.05.00/lib/c -I . interface.c test_c/*.c

upload:
	vrdude -carduino -patmega328p -D -P /dev/ttyACM0 -Uflash:w:binary

clean:
	rm *.epci
	rm *.log
	rm *.mls
	rm *.o