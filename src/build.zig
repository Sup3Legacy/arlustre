const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const optimize = .ReleaseSmall;
    const target = std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
        .os_tag = .freestanding,
        .abi = .none,
    };

    const exe = b.addExecutable(.{ .name = "arlustre", .root_source_file = .{ .path = "boot.zig" }, .optimize = optimize, .target = target });

    exe.bundle_compiler_rt = false;
    exe.strip = true;
    exe.single_threaded = true;
    exe.max_memory = 2_000;
    exe.stack_protector = false;
    exe.disable_stack_probing = true;

    exe.setLinkerScriptPath(std.build.FileSource{ .path = "linker.ld" });
    b.installArtifact(exe);

    //const tty = b.option(
    //    []const u8,
    //    "tty",
    //    "Specify the port to which the Arduino is connected (defaults to /dev/ttyACM0)",
    //) orelse "/dev/ttyACM0";

    //const bin_path = b.getInstallPath(exe.install_step.?.dest_dir, exe.out_filename);

    //const flash_command = blk: {
    //    var tmp = std.ArrayList(u8).init(b.allocator);
    //    try tmp.appendSlice("-Uflash:w:");
    //    try tmp.appendSlice(bin_path);
    //    try tmp.appendSlice(":e");
    //    break :blk tmp.toOwnedSlice();
    //};

    //const upload = b.step("upload", "Upload the code to an Arduino device using avrdude");
    //const avrdude = b.addSystemCommand(&.{
    //    "avrdude",
    //    "-carduino",
    //    "-patmega328p",
    //    "-D",
    //    "-P",
    //    tty,
    //    flash_command,
    //});
    //upload.dependOn(&avrdude.step);
    //avrdude.step.dependOn(&exe.install_step.?.step);

    //const objdump = b.step("objdump", "Show dissassembly of the code using avr-objdump");
    //const avr_objdump = b.addSystemCommand(&.{
    //    "avr-objdump",
    //    "-dh",
    //    bin_path,
    //});
    //objdump.dependOn(&avr_objdump.step);
    //avr_objdump.step.dependOn(&exe.install_step.?.step);

    //const monitor = b.step("monitor", "Opens a monitor to the serial output");
    //const screen = b.addSystemCommand(&.{
    //    "screen",
    //    tty,
    //    "115200",
    //});
    //monitor.dependOn(&screen.step);

    b.default_step.dependOn(&exe.step);
}
