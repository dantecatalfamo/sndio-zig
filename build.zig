const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("sndio", "src/sndio.zig");
    lib.setBuildMode(mode);
    addSndio(lib);
    lib.install();

    const main_tests = b.addTest("src/sndio.zig");
    main_tests.setBuildMode(mode);
    addSndio(main_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

pub fn addSndio(exe: *std.build.LibExeObjStep) void {
    var allocator = exe.builder.allocator;
    const src_dir = std.fs.path.dirname(@src().file) orelse ".";
    const package_path = std.fs.path.join(allocator, &.{ src_dir, "src", "sndio.zig" }) catch unreachable;
    exe.linkSystemLibrary("sndio");
    exe.addPackagePath("sndio", package_path);
}
