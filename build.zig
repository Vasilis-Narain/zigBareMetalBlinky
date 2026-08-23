const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const exe = b.addExecutable(.{
        .name = "blinky",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .strip = false,
        }),
    });

    exe.setLinkerScript(b.path("link.ld"));
    exe.entry = .{ .symbol_name = "resetHandler" };
    b.installArtifact(exe);

    const uf2 = b.addSystemCommand(&.{ "picotool", "uf2", "convert" });
    uf2.addFileArg(exe.getEmittedBin());
    uf2.addArgs(&.{ "-t", "elf" });
    const uf2_out = uf2.addOutputFileArg("blinky.uf2");
    uf2.addArgs(&.{ "--family", "rp2350-arm-s" });
    b.getInstallStep().dependOn(&b.addInstallBinFile(uf2_out, "blinky.uf2").step);
}
