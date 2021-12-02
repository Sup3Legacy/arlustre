pub fn __MMIO(comptime addr: usize, comptime intType: type) type {
    return struct {
        pub fn read() intType {
            const ptr = @intToPtr(*volatile intType, addr);
            return ptr.*;
        }
        pub fn write(data: intType) void {
            const ptr = @intToPtr(*volatile intType, addr);
            ptr.* = data;
        }
    };
}

pub fn MMIO(comptime addr: usize, comptime intType: type, comptime reprType: type) type {
    return struct {
        pub fn read() reprType {
            return @bitCast(reprType, __MMIO(addr, intType).read());
        }
        pub fn write(data: reprType) void {
            __MMIO(addr, intType).write(@bitCast(intType, data));
        }
    };
}
