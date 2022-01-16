all: heptc prog

heptc:
	echo "Compiling heptc"; cd heptagon; make &> /dev/null; echo "Finished compiling heptc"
	
prog:
	cd src; zig build

clean:
	rm src/*.epci -f
	rm src/*.log -f
	rm src/*.mls -f
	rm src/*.o -f
	rm src/*.obc -f
	rm src/zig-cache -r -f
	rm src/zig-out -r -f
	rm src/top_zig -r -f
	rm src/top.zig -f 
	rm docs/artifacts/* -f
	cd heptagon; make clean

report:
	cd docs; make &> /dev/null;