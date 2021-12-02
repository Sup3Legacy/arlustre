const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const exe = b.addExecutable("arlustre", "src/boot.zig");
    exe.setTarget(std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
        .os_tag = .freestanding,
        .abi = .none,
    });
    exe.setBuildMode(.ReleaseSmall);
    exe.strip = true;
    exe.bundle_compiler_rt = false;
    exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });
    exe.install();
}
