/// Second-stage bootstraping functions.
const std = @import("std");
const Libz = @import("./libz/libz.zig");
const mmio = Libz.MmIO;
const interrupt = Libz.Interrupts;
const utilities = Libz.Utilities;
const Serial = Libz.Serial;
const gpio = Libz.GpIO;
const timer = Libz.Timer;
const Max7219 = Libz.Max7219;

const main = @import("main.zig");

var str = "Hello, world!\n\r";

pub fn initSOC() void {
    // Init serial interface
    Serial.init(19200);
    // Init ADC's prescaler. Must do in order to initialize the ADC
    gpio.ADCSRA.write(gpio.ADCSRA.read() | 0x07);
    // Init the LED array controller
    Max7219.init();
}

pub fn bootstrap() noreturn {
    // Init the SoC
    initSOC();
    utilities.delay(100_000);
    // Hello, world!
    Serial.write(str);

    // Reset the Lustre state machine
    _ = @import("main.zig").main();

    // Enable ticking ot keep track of time
    timer.enableTimer0ClockInt();

    // Print the address of the reset itnerrupt for debug
    utilities.delay(100_000);
    Serial.write_usize(@intCast(u8, interrupt.__ISR[0] >> 8));
    utilities.delay(100_000);
    Serial.write_usize(@intCast(u8, interrupt.__ISR[0]));

    // Somehow screen needs a CRLF-type line ending
    utilities.delay(100_000);
    Serial.write_ch('\r');
    utilities.delay(100_000);
    Serial.write_ch('\n');

    // Enable global interrupts
    interrupt.sei();
    
    // Attach the step function to the timer1 interrupt
    interrupt.attachInterrupt(13, @ptrToInt(@import("main.zig").step));
    // Initializes the timer1 interrupt (B overflow)
    timer.initTimer1(10_000);

    while (true) {
        Libz.Utilities.no_op();
        
        // Housekeeping stuff of needed
    }
}