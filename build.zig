const std = @import("std");

const Board = enum {
    pico_2,
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const board = b.option(Board, "board", "target board") orelse .pico_2;
    const board_src = switch (board) {
        .pico_2 => "src/boards/board_pico2.zig",
    };

    const registers_mod = b.createModule(.{
        .root_source_file = b.path("src/registers/registers_rp2305.zig"),
        .target = target,
        .optimize = optimize,
    });

    const board_mod = b.createModule(.{
        .root_source_file = b.path(board_src),
        .target = target,
        .optimize = optimize,
    });
    board_mod.addImport("registers", registers_mod);

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/entry.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
    });

    root_mod.addImport("registers", registers_mod);
    root_mod.addImport("board", board_mod);

    const exe = b.addExecutable(.{
        .name = "blinky",
        .root_module = root_mod,
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
