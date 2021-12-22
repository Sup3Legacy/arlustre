const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const exe = b.addExecutable("arlustre", "boot.zig");
    exe.setTarget(std.zig.CrossTarget{
        .cpu_arch = .avr,
        .cpu_model = .{ .explicit = &std.Target.avr.cpu.atmega328p },
        .os_tag = .freestanding,
        .abi = .none,
    });

    const heptc_command = b.addSystemCommand(&.{
        "heptc",
        "-s",
        "main",
        "-target",
        "zig",
        "interface.epi",
        "top.lus",
    });
    //heptc_command.step.dependOn(&exe.install_step.?.step);

    const heptc = b.step("heptc", "Compiles the Lustre program.");
    const top_move = b.addSystemCommand(&.{ "cp", "./top_zig/top.zig", "./top.zig" });
    heptc.dependOn(&top_move.step);
    top_move.step.dependOn(&heptc_command.step);

    //exe.linkSystemLibrary("lib-gcc");
    exe.setBuildMode(.ReleaseSmall);
    exe.strip = true;
    exe.bundle_compiler_rt = false;
    exe.setLinkerScriptPath(std.build.FileSource{ .path = "linker.ld" });
    exe.step.dependOn(&top_move.step);
    exe.install();

    const bin_path = b.getInstallPath(exe.install_step.?.dest_dir, exe.out_filename);

    const flash_command = blk: {
        var tmp = std.ArrayList(u8).init(b.allocator);
        try tmp.appendSlice("-Uflash:w:");
        try tmp.appendSlice(bin_path);
        try tmp.appendSlice(":e");
        break :blk tmp.toOwnedSlice();
    };

    const upload = b.step("upload", "Upload the code to an Arduino device using avrdude");
    const avrdude = b.addSystemCommand(&.{
        "avrdude",
        "-carduino",
        "-patmega328p",
        "-D",
        "-P",
        "/dev/ttyACM0",
        flash_command,
    });
    upload.dependOn(&avrdude.step);
    avrdude.step.dependOn(&exe.install_step.?.step);

    const objdump = b.step("objdump", "Show dissassembly of the code using avr-objdump");
    const avr_objdump = b.addSystemCommand(&.{
        "avr-objdump",
        "-dh",
        bin_path,
    });
    objdump.dependOn(&avr_objdump.step);
    avr_objdump.step.dependOn(&exe.install_step.?.step);

    const screen = b.step("screen", "Opens the COM-screen");
    const screen_command = b.addSystemCommand(&.{
        "screen",
        "/dev/ttyACM0",
        "19200",
    });
    screen.dependOn(&screen_command.step);
    screen_command.step.dependOn(&avrdude.step);

    const all = b.step("all", "Builds everything, uploads the program and opens the screen.");
    all.dependOn(&screen_command.step);

    b.default_step.dependOn(&exe.step);
}
