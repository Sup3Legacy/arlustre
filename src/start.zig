/// Second-stage bootstraping functions.
const std = @import("std");
const Libz = @import("./libz/libz.zig");
const mmio = Libz.MmIO;
const interrupt = Libz.Interrupts;
const utilities = Libz.Utilities;
const Serial = Libz.Serial;
const gpio = Libz.GpIO;
const timer = Libz.Timer;

const main = @import("main.zig");

var str = "Hello, world!\n\r";
var str2 = "Hi!\n\r";

var lol = [_]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };

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

pub fn bootstrap() void {
    delay(100_000);
    Serial.init(19200);
    delay(100_000);
    Serial.write(str);

    //interrupt._attach_interrupt(12, @ptrToInt(toggle));
    _ = @import("main.zig").main();
    timer.enable_timer0_clock_int();
    //@panic("Ousp...");
    //var index: u8 = 0;

    delay(100_000);
    Serial.write_usize(@intCast(u8, interrupt.__ISR[12] >> 8));
    delay(100_000);
    Serial.write_usize(@intCast(u8, interrupt.__ISR[12]));
    delay(100_000);
    Serial.write_ch('\r');
    delay(100_000);
    Serial.write_ch('\n');

    interrupt.sei();

    // Attach the step function to the timer1 interrupt
    interrupt._attach_interrupt(13, @ptrToInt(@import("main.zig").step));
    timer.init_timer1(75_000);

    //while (true) {
    //    Serial.write_u32(timer.micros());
    //    Serial.write_ch('\n');
    //    Serial.write_ch('\r');
    //    delay(100_000);
    //}
    //while (true) {
    //    if (on) {
    //        Serial.write_ch('o');
    //    } else {
    //        Serial.write_ch('x');
    //    }
    //    delay();
    //    if (index == 20) {
    //        timer.stop();
    //    }
    //    if (index == 25) {
    //        timer.init_timer1(2_000_000);
    //    }
    //    index += 1;
    //    //gpio.DIGITAL_WRITE(13, .HIGH) catch {};
    //    //delay();
    //
    //    //delay();
    //    //gpio.DIGITAL_WRITE(13, .LOW) catch {};
    //    //Serial.write(str);
    //    //Serial.write_ch('a');
    //}
    while (true) {
        //delay(100_000);
        //Serial.write("Bug, bug, bug\n\r");
        Libz.Utilities.no_op();
    }
}

// Some delay
pub fn delay(m: u32) void {
    //var old: u32 = Libz.Timer.micros();
    //while (Libz.Timer.micros() - old < m) {
    //    utilities.no_op();
    //}
    //Libz.Interrupts.cli();
    //_ = m;
    var i: u32 = 0;
    while (i < m) {
        i += 1;
        asm volatile ("nop");
    }
    //Libz.Interrupts.sei();

    //var n: u16 = m;
    //if (n <= 1) {
    //    return;
    //}
    //
    //n = (n << 1) + n; // x3 us, = 5 cycles
    //
    //n -= 5; //2 cycles
    //asm volatile (
    //    \\1: sbiw %0, 1
    //    \\ brne 1b
    //    : [n] "=w" (n) : [n] "0" (n)// 2 cycles
    //);
}
