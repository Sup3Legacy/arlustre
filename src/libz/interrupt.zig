const Libz = @import("libz.zig");

/// Enable interrupts globaly
pub inline fn sei() void {
    asm volatile ("sei" ::: "memory");
}

/// Disable interrupts globaly
pub inline fn cli() void {
    asm volatile ("cli" ::: "memory");
}

/// Attach an ISR at runtime
/// Not operational for now
pub fn _attach_interrupt(id: usize, addr: usize) void {
    __ISR[id] = addr;
}

// Interrupt vector. Put at the right place by the linker
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
        \\ jmp _tim0_ovf
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

/// Vain attempt at creating an universal ISR
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

/// Hacky variable to check whether the .data segment has already been loaded into RAM. 
/// If not, the ISR no. 0 must jump directly to _start instead of reading garbage in __ISR
/// This is because `__ISR` is located in the .Data segment. So any interrupt happening before
/// this segment gets loaded into RAM would try to jump to whatever offset was at this place
/// in memory before .data-loading
/// Basically, if this variable isn't equal to `0x69`, we MUST NOT use anything from .data
pub export var __ISR_LOADED: u16 = 0x69;

/// runtime ISR-vector.
pub export var __ISR = [_]usize{0x068} ** 28;

pub fn init_ISR() void {
    var index: u8 = 0;
    while (index < 28) : (index += 1) {
        __ISR[index] = @ptrToInt(_unknown_interrupt);
    }
}

/// Fallback ISR
export fn _unknown_interrupt() callconv(.Naked) noreturn {
    while (true) {}
}

/// TIMER1 interruption
/// It should in the future use the runtime-attached ISR
/// but for now it contains some testing-related things
/// Essentially, each ISR must have the 
/// `push; save SREG; call func; restore SREG; pop; asm("reti");` scheme
export fn _timer_int() callconv(.Naked) void {
    push();
    const SREG = Libz.MmIO.MMIO(0x5F, u8, u8);
    var oldSREG: u8 = SREG.read();

    Libz.Serial.write_ch('x');
    //_ = @import("../main.zig").step();

    SREG.write(oldSREG);
    pop();

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
export fn _tim0_ovf() callconv(.Naked) void {
    push();
    const SREG = Libz.MmIO.MMIO(0x5F, u8, u8);
    var oldSREG: u8 = SREG.read();
    //push();
    Libz.Timer.timer0_overflow_int();
    //pop();
    SREG.write(oldSREG);
    pop();
    //Libz.Serial.write_ch('x');
    asm volatile ("reti");
}
// 18 0x0022 SPI, STC SPI Serial Transfer Complete
// 19 0x0024 USART, RX USART Rx Complete
// 20 0x0026 USART, UDRE USART, Data Register Empty
// 21 0x0028 USART, TX USART, Tx Complete
// 22 0x002A ADC ADC Conversion Complete
// 23 0x002C EE READY EEPROM Ready
// 24 0x002E ANALOG COMP Analog Comparator
// 25 0x0030 TWI 2-wire Serial Interface
// 0x0032 SPM READY Store Program Memory Ready

pub fn pop() void {
    asm volatile (
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
        \\ pop r17
        \\ pop r16
        \\ pop r15
        \\ pop r14
        \\ pop r13
        \\ pop r12
        \\ pop r11
        \\ pop r10
        \\ pop r9
        \\ pop r8
        \\ pop r7
        \\ pop r6
        \\ pop r5
        \\ pop r4
        \\ pop r3
        \\ pop r2
        \\ pop r1
        \\ pop r0
    );
}

pub fn push() void {
    asm volatile (
        \\ push r0
        \\ push r1
        \\ push r2
        \\ push r3
        \\ push r4
        \\ push r5
        \\ push r6
        \\ push r7
        \\ push r8
        \\ push r9
        \\ push r10
        \\ push r11
        \\ push r12
        \\ push r13
        \\ push r14
        \\ push r15
        \\ push r16
        \\ push r17
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
    );
}
