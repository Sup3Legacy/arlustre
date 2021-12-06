# arlustre

(WIP)

Arduino interface for the Heptagon synchronous dataflow-oriented language written in Zig. It should provide a kinda-low-level interface to any heptagon program, through the custom Heptagon Zig backend. The whole low-level Arduino core-library is implemented using Zig.

Non-exhaustive list of functionning features:

- Very simple Zig backend, not extensively tested (all operations on arrays are not supported for now)
- Zig Arduino Libcore with custom bootstraping stack, interrupts, Serial, GPIO
- Interface to Heptagon for both GPIO allocation and write operations