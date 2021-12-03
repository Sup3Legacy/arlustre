const Libz = @import("./libz/libz.zig");
const Serial = Libz.Serial;

pub export fn _start() callconv(.Naked) noreturn {
    @call(.{.modifier = .never_inline}, copy_data_to_ram, .{});
    @call(.{.modifier = .never_inline}, clear_bss, .{});
    //@call(.{.modifier = .never_inline }, update_isr, .{});
    Libz.Interrupts.__ISR_LOADED = 0x69;
    Libz.Interrupts.sei();

    @call(.{.modifier = .never_inline }, @import("start.zig").bootstrap, .{});
    
    while(true) {}
}

fn update_isr() void {
    asm volatile (
        \\ ldi r30, lo8(_start)
        \\ ldi r31, hi8(_start)
        \\ sts __ISR, r30
        \\ sts __ISR + 1, r31
    ::: "r30", "r31");
    
    //var ptr = @ptrCast(*volatile usize, &(@import("interrupt.zig").__ISR[0]));
    //var add = @ptrToInt(&(_start2));
    //ptr.* = add;
    //@import("interrupt.zig").init_ISR();   
}

fn copy_data_to_ram() void {
    asm volatile (
        \\ push r25
        \\
        \\ ldi r30, lo8(__data_load_start)
        \\ ldi r31, hi8(__data_load_start)
        \\
        \\ ldi r28, lo8(__data_start)
        \\ ldi r29, hi8(__data_start)
        \\
        \\ ldi r26, lo8(__data_end)
        \\ ldi r27, hi8(__data_end)
        \\
        \\.ram_cpy_0:
        \\ cp r28, r26
        \\ cpc r29, r27
        \\ brne .ram_cpy_1
        \\ rjmp .ram_cpy_2
        \\.ram_cpy_1:
        \\ lpm r20, Z+
        \\ st Y+, r20
        \\ rjmp .ram_cpy_0
        \\
        \\.ram_cpy_2:
        \\ pop r25
    ::: "r30", "r31", "r28", "r29", "r26", "r27");
}

fn clear_bss() void {
    asm volatile (
        \\ push r25
        \\
        \\ ldi r25, 0x0
        \\
        \\ ldi r28, lo8(__bss_start)
        \\ ldi r29, hi8(__bss_start)
        \\
        \\ ldi r26, lo8(__bss_end)
        \\ ldi r27, hi8(__bss_end)
        \\
        \\.bss_clear_0:
        \\ cp r28, r26
        \\ cpc r29, r27
        \\ brne .bss_clear_1
        \\ rjmp .bss_clear_2
        \\.bss_clear_1:
        \\ st Y+, r25
        \\ rjmp .bss_clear_0
        \\
        \\.bss_clear_2:
        \\ pop r25
    ::: "r28", "r29", "r26", "r27");
    
}