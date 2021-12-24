const Libz = @import("./libz/libz.zig");
const Interrupts = Libz.Interrupts;

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
pub const random_out = struct { i: isize };
pub const time_pulse_out = struct { b: bool, h: isize, l: isize };

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

pub fn random_step(at_least: isize, less_than: isize, out: *random_out) void {
    out.i = Libz.Rand.get_random(at_least, less_than);
}

pub fn time_pulse_step(outp: isize, inp: isize, do_step: bool, out: *time_pulse_out) void {
    var in_pin = @intCast(u8, inp);
    if (do_step) {
        // Send the signal
        Libz.GpIO.DIGITAL_WRITE(@intCast(u8, outp), .HIGH) catch {};
        // Set the tiem reference for the 
        Interrupts.set_reference(in_pin);
        // Only interrupt once please 
        // * In the future, we may wish to interrupt multiple times ?
        Interrupts.do_interrupt[in_pin] = false;
        out.b = false;
        out.l = 0;
        out.h = 0;
    } else {
        
        out.b = Interrupts.did_interrupt_occur[];
        var diff = Interrupts.get_last_time(in_pin) - Interrupts.get_time_reference(in_pin);
        var low = @intCast(usize, diff & 0x0000ffff);
        var high = @intCast(usize, (diff & 0xffff0000) >> 16);
        out.l = @bitCast(isize, low);
        out.h = @bitCast(isize, high);
    }
}