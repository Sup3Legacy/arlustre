pub fn MMIO(comptime addr: usize, comptime IntType: type, comptime ReprType: type) type {
    return struct {
        pub fn ptr() *volatile IntType {
            return @ptrFromInt(addr);
        }
        pub fn read() ReprType {
            const intVal = ptr().*;
            return @bitCast(intVal);
        }
        pub fn write(val: ReprType) void {
            const intVal: IntType = @bitCast(val);
            ptr().* = intVal;
        }
    };
}
