const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libwhey = b.addStaticLibrary(.{
        .name = "whey",
        .root_source_file = b.path("src/whey.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_source_file = b.path("src/demo.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(libwhey);

    switch (target.result.os.tag) {
        .linux => {
            libwhey.linkLibC();
            libwhey.addIncludePath(.{ .src_path = .{ .sub_path = "/usr/include/", .owner = b } });
            exe.linkSystemLibrary("X11");
            exe.linkLibC();
        },
        .windows => exe.linkSystemLibrary("user32"),
        else => {},
    }

    b.installArtifact(libwhey);
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);

    const run_step = b.step("run-demo", "Run the demo");
    run_step.dependOn(&run_exe.step);
}
