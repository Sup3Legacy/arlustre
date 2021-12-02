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
    @import("../main.zig").toggle();
    asm volatile ("reti");
} 
