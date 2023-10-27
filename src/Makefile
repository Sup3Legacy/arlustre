all:
	../heptagon/compiler/heptc.byte ../heptagon/lib/pervasives.epi 
	../heptagon/compiler/heptc.byte -target zig interface.epi -stdlib ../heptagon/lib
	../heptagon/compiler/heptc.byte -target zig -s main ./top.lus
	cp top_zig/top.zig top.zig
