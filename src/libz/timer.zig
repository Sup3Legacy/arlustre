const Libz = @import("libz.zig");
const MMIO = Libz.MmIO.MMIO;
const Constants = Libz.CONSTANTS;

const TIMER1_RESOLUTION: u64 = 65536;

pub fn init_timer1(period: u64) void {
    // `period` is in µs.
    const ICR1 = MMIO(0x86, u16, u16);
    const TCNT1 = MMIO(0x84, u16, u16);
    const TCCR1B = MMIO(0x81, u8, u8);
    const TCCR1A = MMIO(0x80, u8, u8); 
    const TIMSK1 = MMIO(0x6F, u8, u8);

    TCCR1B.write(1 << 4);
    TCCR1A.write(0);
    TIMSK1.write(TIMSK1.read() | (1 << 2));

    var cycles: u64 = ((Constants.UNO_clock_s/100_000 * period) / 20);

    var clockSelectBits: u8 = 0;
    var pwmPeriod: u64 = 0;

    if (cycles < TIMER1_RESOLUTION) {
        clockSelectBits = 1 << 0;
        pwmPeriod = cycles;
    } else
    if (cycles < TIMER1_RESOLUTION * 8) {
        clockSelectBits = 1 << 1;
        pwmPeriod = cycles / 8;
    } else
    if (cycles < TIMER1_RESOLUTION * 64) {
        clockSelectBits = 1 << 1 | 1 << 0;
        pwmPeriod = cycles / 64;
    } else
    if (cycles < TIMER1_RESOLUTION * 256) {
        clockSelectBits = 1 << 2;
        pwmPeriod = cycles / 256;
    } else
    if (cycles < TIMER1_RESOLUTION * 1024) {
        clockSelectBits = 1 << 2 | 1 << 0;
        pwmPeriod = cycles / 1024;
    } else {
        clockSelectBits = 1 << 2 | 1 << 0;
        pwmPeriod = TIMER1_RESOLUTION - 1;
    }

    TCNT1.write(0);
    ICR1.write(@intCast(u16, pwmPeriod));
    TCCR1B.write((1 << 4) | clockSelectBits);
}

pub fn stop() void {
    const TCCR1B = MMIO(0x81, u8, u8);
    const TIMSK1 = MMIO(0x6F, u8, u8);

    TIMSK1.write(TIMSK1.read() & ~@as(u8, 1 << 2));
    TCCR1B.write(1 << 4);
}