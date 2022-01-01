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
pub const time_pulse_out = struct { b: bool, h: isize, l: isize };
pub const int_of_float_out = struct { i: isize };
pub const float_of_int_out = struct { f: f32 };

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
    Libz.Timer.initTimer1(@as(u64, period));
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

pub fn print_long_step(l: isize, h: isize, do_print: bool, endl: bool, out: *print_long_out) void {
    if (do_print) {
        Libz.Serial.write_u16(@intCast(usize, h));
        Libz.Serial.write_u16(@intCast(usize, l));
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

//return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

pub fn map_int_step(x: isize, in_min: isize, in_max: isize, out_min: isize, out_max: isize, out: *map_int_out) void {
    out.i = @floatToInt(isize, (@intToFloat(f32, x) - @intToFloat(f32, in_min)) * (@intToFloat(f32, out_max) - @intToFloat(f32, out_min)) / (@intToFloat(f32, in_max) - @intToFloat(f32, in_min)) + @intToFloat(f32, out_min));
}

pub fn toggle_pixel_step(x: isize, y: isize, state: bool, do_step: bool, out: *toggle_pixel_out) void {
    if (do_step) {
        Libz.Max7219.toggle_pixel(@intCast(u8, x), @intCast(u8, y), state);
        Libz.Max7219.draw();
        out.b = true;
    }
}

pub fn time_pulse_step(outp: isize, inp: isize, do_step: bool, out: *time_pulse_out) void {
    var in_pin = @intCast(u8, inp);
    Libz.GpIO.DIGITAL_MODE(@intCast(u8, outp), .OUTPUT) catch {};
    Libz.GpIO.DIGITAL_MODE(@intCast(u8, inp), .INPUT) catch {};

    if (do_step) {
        // Temp

        //Interrupts.togglePinChangeIntPort(.C, true);
        //Interrupts.togglePinChangeIntPort(.D, true);
        //Interrupts.PCIFR.write(Interrupts.PCIFR.read() | 1);
        Interrupts.setReference(in_pin);
        Interrupts.did_interrupt_occur[in_pin] = false;
        asm volatile ("nop" ::: "memory");
        // Only interrupt once please
        // * In the future, we may wish to interrupt multiple times ?
        Interrupts.do_interrupt[in_pin] = true;
        Interrupts.time_to_interupt[in_pin] = 1;
        Interrupts.togglePinInterrupt(in_pin, true);

        // Send the signal
        GPIO.PORTD.write(GPIO.PORTD.read() & ~@as(u8, 1 << 7));
        //Libz.GpIO.DIGITAL_WRITE(@intCast(u8, outp), .LOW) catch {};
        Libz.Utilities.delay(4);
        GPIO.PORTD.write(GPIO.PORTD.read() | 1 << 7);
        //Libz.GpIO.DIGITAL_WRITE(@intCast(u8, outp), .HIGH) catch {};
        // Set the time reference for the

        out.b = false;
        out.l = 0;
        out.h = 0;
        Libz.Utilities.delay(4);
        GPIO.PORTD.write(GPIO.PORTD.read() & ~@as(u8, 1 << 7));

        //Libz.GpIO.DIGITAL_WRITE(@intCast(u8, outp), .LOW) catch {};

    } else {
        var did_occur = Interrupts.did_interrupt_occur[in_pin];
        out.b = did_occur;
        if (did_occur) {
            var diff = Interrupts.getLastTime(in_pin) -% Interrupts.getTimeReference(in_pin);
            var low = @intCast(usize, diff & 0x0000ffff);
            var high = @intCast(usize, (diff & 0xffff0000) >> 16);
            out.l = @bitCast(isize, low);
            out.h = @bitCast(isize, high);
            Interrupts.resetPinInterrupt(in_pin);
        } else {
            // Maybe do reset out.l and out.h?
        }
    }
}

pub fn int_of_float_step(f: f32, out: *int_of_float_out) void {
    out.i = @floatToInt(isize, f);
}

pub fn float_of_int_step(i: isize, out: *float_of_int_out) void {
    out.f = @intToFloat(f32, i);
}