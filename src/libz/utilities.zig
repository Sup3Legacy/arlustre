pub inline fn no_op() void {
    asm volatile ("nop" ::: "memory");
}
