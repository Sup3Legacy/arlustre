# Arlustre

(WIP)

Arduino interface for the Heptagon synchronous dataflow-oriented language written in Zig. It should provide a kinda-low-level interface to any heptagon program, through the custom Heptagon Zig backend. The whole low-level Arduino core-library is implemented using Zig.

Non-exhaustive list of functionning features:

- Very simple Zig backend, not extensively tested (all operations on arrays are not supported for now)
- Zig Arduino Libcore with custom bootstraping stack, interrupts, Serial, GPIO
- Interface to Heptagon for both GPIO allocation and write operations

# Achievements

Things I have achieved for now :

- Arduino libcore covering a not-to-bad proportion of the features available on the Arduino Uno platform (GPIO, Serial, some basic timer interrupts as of now)
- Automated build using `zig build`
- Small Lustre interface containing GPIO-{declaration, read, write}.
- Lustre test program showing the interaction with LEDs, timers and a button.
  
# How to use

## Prerequisites 

- `ocaml` and some other `opam` libraries to compile my custom fork of `heptagon` (available as a submodule).
- `zig` version >= `0.9` as of now (I use the `edge` channel from `snap` so `0.10.0-dev.2+ea913846c` as of writing)
- `screen`
- `avrdude`
  
## How to compile

- `make` and `make install` in the `heptagon` root directory. This should install `heptc` somewhere that is accessible through the `PATH` (check this if `heptc` cannot be found).
- in the `src` subdirectory : 
  - `zig heptc` : runs `heptc` on `interface.epi` and `top.lus` and moves the generated `top.zig` in `./src`
  - No step to only compile the Zig program for now, WIP
  - `zig build` = `zig build upload` : do everything mentionned before (`heptc`, compiles the Zig program) and uploads the program to the Arduino using a generic port (TODO add port as an optional argument)
  - `zig screen` : does everything above + opens a `screen` session with the arduino on the same port (TODO same_thing)
  
