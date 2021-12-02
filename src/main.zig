const std = @import("std");
const Libz = @import("./libz/libz.zig");
const mmio = Libz.MmIO;
const interrupt = Libz.Interrupts;
const utilities = Libz.Utilities;
const Serial = Libz.Serial;
const gpio = Libz.GpIO;
const timer = Libz.Timer;

var str = "Hello, world!\n\r";
var str2 = "Hi!\n\r";

var lol = [_]u8{0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

var on: bool = false;

pub fn toggle() callconv(.C) void {
    if (on) {
        //gpio.DIGITAL_WRITE(13, .LOW) catch {};
    } else {
        //gpio.DIGITAL_WRITE(13, .HIGH) catch {};
    }
    //Serial.write_ch('x');
    on = !on;
}

pub fn main() void {
    gpio.DIGITAL_MODE(13, .OUTPUT) catch {};
    interrupt._attach_interrupt(12, @ptrToInt(toggle));
    interrupt.sei();
    timer.init_timer1(1_000_000);
    Serial.init(115200);
    Serial.write("Hello, world!");
    //@panic("Ousp...");
    var index: u8 = 0;
    delay();
    Serial.write_usize(@intCast(u8, interrupt.__ISR[12] >> 8));
    delay();
    Serial.write_usize(@intCast(u8, interrupt.__ISR[12]));
    delay();
    Serial.write_ch('\r');
    delay();
    Serial.write_ch('\n');
    while (true) {
        if (on) {
            Serial.write_ch('o');
        } else {
            Serial.write_ch('x');
        }
        delay();
        if (index == 20) {
            timer.stop();
        }
        if (index == 25) {
            timer.init_timer1(2_000_000);
        }
        index += 1;
        //gpio.DIGITAL_WRITE(13, .HIGH) catch {};
        //delay();
        
        //delay();
        //gpio.DIGITAL_WRITE(13, .LOW) catch {};
        //Serial.write(str);
        //Serial.write_ch('a');
    }
    while(true) {}
}

pub fn reset() void {
    Serial.init(115200);
    var index: u8 = 0;
    while (index < 3) : (index += 1) {
        delay();
        //gpio.DIGITAL_WRITE(13, .HIGH) catch {};
        //delay();
        //gpio.DIGITAL_WRITE(13, .LOW) catch {};
        Serial.write(str2);
        //Serial.write_ch('a');
    }
    while(true) {}
}

pub fn delay() void {
    var i: u32 = 0;
    while (i < 1_000_000) : (i += 1) {
        utilities.no_op();
    }
}

pub fn panic(msg: []const u8, stack_trace: ?*std.builtin.StackTrace) noreturn {
    interrupt.cli();
    _ = stack_trace;
    Serial.init(115200);
    delay();
    Serial.write(msg);
    while (true) {}
}
