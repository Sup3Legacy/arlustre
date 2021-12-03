const Libz = @import("libz.zig");

pub inline fn sei() void {
    asm volatile ("sei" ::: "memory");
}

pub inline fn cli() void {
    asm volatile ("cli" ::: "memory");
}

pub fn _attach_interrupt(id: usize, addr: usize) void {
    __ISR[id] = addr;
}

comptime {
    asm (
        \\.section .vectors
        \\ jmp _handle_ir
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _timer_int
        \\ jmp _timer_int
        \\ jmp _timer_int
        \\ jmp _timer_int 
        \\ jmp _timer_int
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt
        \\ jmp _unknown_interrupt        
    );
}

pub export fn _handle_ir() void {
    asm volatile (
        \\ push r18
        \\ push r19
        \\ push r20
        \\ push r21
        \\ push r22
        \\ push r23
        \\ push r24
        \\ push r25
        \\ push r26
        \\ push r27
        \\ push r28
        \\ push r29
        \\ push r30
        \\ push r31
        \\ lds r30, __ISR_LOADED
        \\ cpi r30, 0x69 ; Check whether the .data segment has been loaded into the RAM
        \\ brne .lol
        //\\ rjmp _start2
        \\ lds r30, (__ISR)
        \\ lds r31, (__ISR + 1)
        //\\ lds r31, __ISR+1
        \\ icall
        \\ rjmp .lol1
        \\.lol:
        \\ call _start
        \\.lol1:
        \\ pop r31
        \\ pop r30
        \\ pop r29
        \\ pop r28
        \\ pop r27
        \\ pop r26
        \\ pop r25
        \\ pop r24
        \\ pop r23
        \\ pop r22
        \\ pop r21
        \\ pop r20
        \\ pop r19
        \\ pop r18
        \\ reti
    ::: "r30", "r31");
}

// Hacky variable to check whether the .data segment has already been loaded into RAM. 
// If not, the ISR no. 0 must jump directly to _start instead of reading garbage in __ISR
pub export var __ISR_LOADED: u16 = 0x69;

pub export var __ISR = [_]usize{0x068} ** 28;

pub fn init_ISR() void {
    var index: u8 = 0;
    while (index < 28) : (index += 1) {
        __ISR[index] = @ptrToInt(_unknown_interrupt);
    }
}

export fn _unknown_interrupt() callconv(.Naked) noreturn {
    while (true) {}
}

export fn _timer_int() callconv(.Naked) void {
    Libz.Serial.write_ch('x');
    _ = @import("../main.zig").step();
    asm volatile ("reti");
} 

/// Ext int 0
export fn _int0() callconv(.Naked) noreturn {
    while (true) {}
}

/// Ext int 1
export fn _int1() callconv(.Naked) noreturn {
    while (true) {}
}

/// Pin change int 0
export fn _pcint0() callconv(.Naked) noreturn {
    while (true) {}
}

/// Pin change int 1
export fn _pcint1() callconv(.Naked) noreturn {
    while (true) {}
}

/// Pin change int 2
export fn _pcint2() callconv(.Naked) noreturn {
    while (true) {}
}

/// Watchdog timeout
export fn _wdt() callconv(.Naked) noreturn {
    while (true) {}
}

// 7 0x000C WDT Watchdog Time-out Interrupt
// 8 0x000E TIMER2 COMPA Timer/Counter2 Compare Match A
// 9 0x0010 TIMER2 COMPB Timer/Counter2 Compare Match B
// 10 0x0012 TIMER2 OVF Timer/Counter2 Overflow
// 11 0x0014 TIMER1 CAPT Timer/Counter1 Capture Event
// 12 0x0016 TIMER1 COMPA Timer/Counter1 Compare Match A
// 13 0x0018 TIMER1 COMPB Timer/Coutner1 Compare Match B
// 14 0x001A TIMER1 OVF Timer/Counter1 Overflow
// 15 0x001C TIMER0 COMPA Timer/Counter0 Compare Match A
// 16 0x001E TIMER0 COMPB Timer/Counter0 Compare Match B
// 17 0x0020 TIMER0 OVF Timer/Counter0 Overflow
// 18 0x0022 SPI, STC SPI Serial Transfer Complete
// 19 0x0024 USART, RX USART Rx Complete
// 20 0x0026 USART, UDRE USART, Data Register Empty
// 21 0x0028 USART, TX USART, Tx Complete
// 22 0x002A ADC ADC Conversion Complete
// 23 0x002C EE READY EEPROM Ready
// 24 0x002E ANALOG COMP Analog Comparator
// 25 0x0030 TWI 2-wire Serial Interface
// 0x0032 SPM READY Store Program Memory Ready
