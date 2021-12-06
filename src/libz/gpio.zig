const __MMIO = @import("mmio.zig").__MMIO;

const PINB = __MMIO(0x23, u8);
const DDRB = __MMIO(0x24, u8);
const PORTB = __MMIO(0x25, u8);

const PINC = __MMIO(0x26, u8);
const DDRC = __MMIO(0x27, u8);
const PORTC = __MMIO(0x28, u8);

const PIND = __MMIO(0x29, u8);
const DDRD = __MMIO(0x2A, u8);
const PORTD = __MMIO(0x2B, u8);

const PORT_MODE = enum {
    INPUT,
    OUTPUT,
    INPUT_PULL,
};

const VALUE = enum {
    LOW,
    HIGH,
};

const GPIO_ERROR = error{
    NON_EXISTING_DIGITAL_PIN,
    NON_EXISTING_ANALOGIC_PIN,
    PWM_NOT_SUPPORTED,
};

// int to bit
fn itb(id: u8) u8 {
    const unite: u8 = 1;
    return unite << @intCast(u3, id % 8);
}

pub fn DIGITAL_MODE(pin_id: u8, mode: PORT_MODE) GPIO_ERROR!void {
    switch (pin_id) {
        0...7 => {
            if (mode == .INPUT) {
                DDRD.write(DDRD.read() | itb(pin_id));
            } else {
                DDRD.write(DDRD.read() & ~itb(pin_id));
            }
        },
        8...13 => {
            if (mode == .INPUT) {
                DDRB.write(DDRB.read() | itb(pin_id));
            } else {
                DDRB.write(DDRB.read() & ~itb(pin_id));
            }
        },
        14...19 => {
            if (mode == .INPUT) {
                DDRC.write(DDRC.read() | itb(pin_id));
            } else {
                DDRC.write(DDRC.read() & ~itb(pin_id));
            }
        },
        else => {
            return GPIO_ERROR.NON_EXISTING_DIGITAL_PIN;
        },
    }
}

pub fn DIGITAL_WRITE(pin_id: u8, value: VALUE) GPIO_ERROR!void {
    switch (pin_id) {
        0...7 => {
            if (value == .HIGH) {
                PORTD.write(PORTD.read() | itb(pin_id));
            } else {
                PORTD.write(PORTD.read() & ~itb(pin_id));
            }
        },
        8...13 => {
            if (value == .HIGH) {
                DDRB.write(DDRB.read() | itb(pin_id));
            } else {
                DDRB.write(DDRB.read() & ~itb(pin_id));
            }
        },
        14...19 => {
            if (value == .HIGH) {
                PORTC.write(PORTC.read() | itb(pin_id));
            } else {
                PORTC.write(PORTC.read() & ~itb(pin_id));
            }
        },
        else => {
            return GPIO_ERROR.NON_EXISTING_DIGITAL_PIN;
        },
    }
}
