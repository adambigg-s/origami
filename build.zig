const std = @import("std");

pub fn build(bld: *std.Build) void {
    const target = bld.standardTargetOptions(.{});

    const mod = bld.addModule("origami", .{
        .root_source_file = bld.path("src/root.zig"),
        .target = target,
    });

    const mod_tests = bld.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = bld.addRunArtifact(mod_tests);
    const test_step = bld.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
