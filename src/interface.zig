const Libz = @import("./libz/libz.zig");

pub const change_pin_state_out = struct {
    b: isize,
};
pub const read_pin_state_out = struct {
    b: bool,
};
pub const declare_io_out = struct { b: isize };
pub const modulo_out = struct { c: isize };
pub const div_out = struct { c: isize };
pub const change_timer0_out = struct { b: isize };
pub const print_int_out = struct { b: bool };
pub const read_analog_out = struct { i: isize };

pub fn change_pin_state_step(pin: isize, state: bool, out: *change_pin_state_out) void {
    Libz.GpIO.DIGITAL_WRITE(@intCast(u8, pin), if (state) .HIGH else .LOW) catch {};
    _ = out;
}

pub fn read_pin_state_step(pin: isize, out: *read_pin_state_out) void {
    out.b = Libz.GpIO.DIGITAL_READ(@intCast(u8, pin)) catch {
        return;
    } == .HIGH;
}

pub fn declare_io_step(pin: isize, mode: isize, do_declare: bool, out: *declare_io_out) void {
    if (do_declare) {
        Libz.GpIO.DIGITAL_MODE(@intCast(u8, pin), if (mode == 1) .OUTPUT else .INPUT) catch {};
    }
    _ = out;
}

pub fn modulo_step(a: isize, b: isize, out: *modulo_out) void {
    //Assume both are positive
    //if (b == 0) {
    //    return;
    //}
    //var acc: isize = 0;
    //while (true) {
    //    if (acc + b > a) {
    //        out.*.c = a - acc;
    //        return;
    //    }
    //    acc += b;
    //}
    out.*.c = @mod(a, b);
}

pub fn div_step(a: isize, b: isize, out: *div_out) void {
    out.*.c = @divFloor(a, b);
}

pub fn change_timer0_freq(period: isize, out: *change_timer0_out) void {
    Libz.Timer.init_timer1(@as(u64, period));
    _ = out;
}

pub fn print_int_step(i: isize, do_print: bool, endl: bool, out: *print_int_out) void {
    if (do_print) {
        Libz.Serial.write_u16(@intCast(usize, i));
        if (endl) {
            Libz.Serial.write("\n\r");
        }
    }
    out.b = do_print;
}

pub fn read_analog_step(pin: isize, out: *read_analog_out) void {
    out.i = @intCast(isize, Libz.GpIO.ANALOG_READ(@intCast(u8, pin)));
}
