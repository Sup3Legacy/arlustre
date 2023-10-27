const Libz = @import("./libz/libz.zig");
const Interrupts = Libz.Interrupts;
const GPIO = Libz.GpIO;

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
pub const print_long_out = struct { b: bool };
pub const read_analog_out = struct { i: isize };
pub const random_out = struct { i: isize };
pub const map_int_out = struct { i: isize };
pub const toggle_pixel_out = struct { b: bool };
pub const time_out = struct { b: bool, l: isize, h: isize };
pub const time_pulse_out = struct { b: bool, l: isize, h: isize };
pub const int_of_float_out = struct { i: isize };
pub const float_of_int_out = struct { f: f32 };

pub fn change_pin_state_step(pin: isize, state: bool, out: *change_pin_state_out) void {
    Libz.GpIO.DIGITAL_WRITE(@intCast(pin), if (state) .HIGH else .LOW) catch {};
    _ = out;
}

pub fn read_pin_state_step(pin: isize, out: *read_pin_state_out) void {
    out.b = Libz.GpIO.DIGITAL_READ(@intCast(pin)) catch {
        return;
    } == .HIGH;
}

pub fn declare_io_step(pin: isize, mode: bool, do_declare: bool, out: *declare_io_out) void {
    if (do_declare) {
        Libz.GpIO.DIGITAL_MODE(@intCast(pin), if (mode) .OUTPUT else .INPUT) catch {};
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
    Libz.Timer.initTimer1(@as(u64, period));
    _ = out;
}

pub fn print_int_step(i: isize, do_print: bool, endl: bool, out: *print_int_out) void {
    if (do_print) {
        Libz.Serial.write_u16(@intCast(i));
        if (endl) {
            Libz.Serial.write("\n\r");
        }
    }
    out.b = do_print;
}

pub fn print_long_step(l: isize, h: isize, do_print: bool, endl: bool, out: *print_long_out) void {
    if (do_print) {
        Libz.Serial.write_u16(@intCast(h));
        Libz.Serial.write_u16(@intCast(l));
        if (endl) {
            Libz.Serial.write("\n\r");
        }
    }
    out.b = do_print;
}

pub fn read_analog_step(pin: isize, out: *read_analog_out) void {
    out.i = @intCast(Libz.GpIO.ANALOG_READ(@intCast(pin)));
}

pub fn random_step(at_least: isize, less_than: isize, out: *random_out) void {
    out.i = Libz.Rand.get_random(at_least, less_than);
}

//return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

pub fn map_int_step(x: isize, in_min: isize, in_max: isize, out_min: isize, out_max: isize, out: *map_int_out) void {
    var x_float: f32 = @floatFromInt(x);
    var in_min_float: f32 = @floatFromInt(in_min);
    var in_max_float: f32 = @floatFromInt(in_max);
    var out_min_float: f32 = @floatFromInt(out_min);
    var out_max_float: f32 = @floatFromInt(out_max);
    out.i = @intFromFloat((x_float - in_min_float) * (out_max_float - out_min_float) / (in_max_float - in_min_float) + out_min_float);
}

pub fn toggle_pixel_step(x: isize, y: isize, state: bool, do_step: bool, out: *toggle_pixel_out) void {
    if (do_step) {
        Libz.Max7219.toggle_pixel(@intCast(x), @intCast(y), state);
        Libz.Max7219.draw();
        out.b = true;
    }
}

pub fn time_step(inp: isize, state: isize, do_step: bool, out: *time_out) void {
    var in_pin: u8 = @intCast(inp);
    Libz.GpIO.DIGITAL_MODE(@intCast(inp), .INPUT) catch {};

    if (do_step) {
        Interrupts.setReference(in_pin);
        Interrupts.resetPinInterrupt(in_pin);
        Interrupts.do_interrupt[in_pin] = true;
        Interrupts.interrupt_state[in_pin] = Interrupts.stateOfInt(state);
        Interrupts.togglePinInterrupt(in_pin, true);

        out.b = false;
        out.l = 0;
        out.h = 0;
    } else {
        var did_occur = Interrupts.did_interrupt_occur[in_pin];
        out.b = did_occur;
        if (did_occur) {
            var diff = Interrupts.getLastTime(in_pin) -% Interrupts.getTimeReference(in_pin);
            var low: u16 = @intCast(diff & 0x0000ffff);
            var high: u16 = @intCast((diff & 0xffff0000) >> 16);
            out.l = @bitCast(low);
            out.h = @bitCast(high);
            Interrupts.resetPinInterrupt(in_pin);
        } else {
            // Both high and low value conserve their value
        }
    }
}

pub fn time_pulse_step(outp: isize, inp: isize, signal_width: isize, state: isize, do_step: bool, out: *time_pulse_out) void {
    var in_pin: u8 = @intCast(inp);
    Libz.GpIO.DIGITAL_MODE(@intCast(outp), .OUTPUT) catch {};
    Libz.GpIO.DIGITAL_MODE(@intCast(inp), .INPUT) catch {};

    if (do_step) {
        Interrupts.setReference(in_pin);
        Interrupts.resetPinInterrupt(in_pin);
        Interrupts.do_interrupt[in_pin] = true;
        Interrupts.interrupt_state[in_pin] = Interrupts.stateOfInt(state);
        Interrupts.togglePinInterrupt(in_pin, true);

        // Send the signal
        GPIO.DIGITAL_WRITE(@intCast(outp), .HIGH) catch {};
        Libz.Utilities.delay(@intCast(signal_width));
        GPIO.DIGITAL_WRITE(@intCast(outp), .LOW) catch {};

        out.b = false;
        out.l = 0;
        out.h = 0;
    } else {
        var did_occur = Interrupts.did_interrupt_occur[in_pin];
        out.b = did_occur;
        if (did_occur) {
            var diff = Interrupts.getLastTime(in_pin) -% Interrupts.getTimeReference(in_pin);
            var low: usize = @intCast(diff & 0x0000ffff);
            var high: usize = @intCast((diff & 0xffff0000) >> 16);
            out.l = @bitCast(low);
            out.h = @bitCast(high);
            Interrupts.resetPinInterrupt(in_pin);
        } else {
            // Both high and low value conserve their value
        }
    }
}

pub fn int_of_float_step(f: f32, out: *int_of_float_out) void {
    out.i = @intFromFloat(f);
}

pub fn float_of_int_step(i: isize, out: *float_of_int_out) void {
    out.f = @floatFromInt(i);
}
