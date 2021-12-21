all: clean

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