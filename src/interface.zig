const Libz = @import("./libz/libz.zig");

pub const change_pin_state_out = struct {
    b: isize,
};
pub const declare_io_out = struct { b: isize };
pub const modulo_out = struct { c: isize };

pub fn change_pin_state_step(pin: isize, state: bool, out: *change_pin_state_out) void {
    Libz.GpIO.DIGITAL_WRITE(@intCast(u8, pin), if (state) .HIGH else .LOW) catch {};
    _ = out;
}

pub fn declare_io_step(pin: isize, mode: isize, out: *declare_io_out) void {
    Libz.GpIO.DIGITAL_MODE(@intCast(u8, pin), if (mode == 1) .OUTPUT else .INPUT) catch {};
    _ = out;
}

pub fn modulo_step(a: isize, b: isize, out: *modulo_out) void {
    // Assume both are positive
    if (b == 0) {
        return;
    }
    var acc: isize = 0;
    while (true) {
        if (acc + b > a) {
            out.*.c = a - acc;
            return;
        }
        acc += b;
    }
}
