const Libz = @import("libz.zig");
const __MMIO = @import("mmio.zig").__MMIO;

pub const PINB = __MMIO(0x23, u8);
pub const DDRB = __MMIO(0x24, u8);
pub const PORTB = __MMIO(0x25, u8);

pub const PINC = __MMIO(0x26, u8);
pub const DDRC = __MMIO(0x27, u8);
pub const PORTC = __MMIO(0x28, u8);

pub const PIND = __MMIO(0x29, u8);
pub const DDRD = __MMIO(0x2A, u8);
pub const PORTD = __MMIO(0x2B, u8);

pub const ADCL = __MMIO(0x78, u8);
pub const ADCH = __MMIO(0x79, u8);
pub const ADMUX = __MMIO(0x7c, u8);
pub const ADC = __MMIO(0x78, u16);
pub const ADCSRA = __MMIO(0x7a, u8);
pub const ADCSRB = __MMIO(0x7b, u8);

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
    CANT_READ_OUTPUT,
    CANT_WRITE_INPUT,
};

// int to bit
pub fn itb(id: u8) u8 {
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

pub fn READ_DIGITAL_MODE(pin_id: u8) GPIO_ERROR!PORT_MODE {
    switch (pin_id) {
        0...7 => {
            if (DDRD.read() & itb(pin_id) != 0) {
                return .INPUT;
            } else {
                return .OUTPUT;
            }
        },
        8...13 => {
            if (DDRB.read() & itb(pin_id) != 0) {
                return .INPUT;
            } else {
                return .OUTPUT;
            }
        },
        14...19 => {
            if (DDRC.read() & itb(pin_id) != 0) {
                return .INPUT;
            } else {
                return .OUTPUT;
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

pub fn DIGITAL_READ(pin_id: u8) GPIO_ERROR!VALUE {
    var is_input = READ_DIGITAL_MODE(pin_id) catch .INPUT;
    if (is_input != .INPUT) {
        return GPIO_ERROR.CANT_READ_OUTPUT;
    }
    switch (pin_id) {
        0...7 => {
            if (PIND.read() & itb(pin_id) != 0) {
                return .HIGH;
            } else {
                return .LOW;
            }
        },
        8...13 => {
            if (PINB.read() & itb(pin_id) != 0) {
                return .HIGH;
            } else {
                return .LOW;
            }
        },
        // Analog pins, here used as digital ones
        14...19 => {
            if (PINC.read() & itb(pin_id) != 0) {
                return .HIGH;
            } else {
                return .LOW;
            }
        },
        else => {
            return GPIO_ERROR.NON_EXISTING_DIGITAL_PIN;
        },
    }
}

pub fn ANALOG_READ(pin_id: u8) usize {
    // Enable ADC
    ADCSRA.write(ADCSRA.read() | (1 << 7));
    // Select pin. First part is the pin number (n.b. 0x1111 would be the temperature sensor)
    // and second the reference
    ADMUX.write(ADMUX.read() | ((pin_id - 14) & 0x07) | (1 << 6));
    // Start conversion
    ADCSRA.write(ADCSRA.read() | (1 << 6));
    // Wait until conversion end
    while (ADCSRA.read() & (1 << 6) != 0) {
        Libz.Utilities.no_op();
    }
    // Start by reading the low part
    var l = ADCL.read();
    asm volatile ("nop":::"memory");
    var h = ADCH.read();
    return @as(u16, l) | (@as(u16, h) << 8);
}
