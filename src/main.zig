const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const sndio = @import("./sndio.zig");
const siodsc = sndio.sioctl_desc;

pub fn main() !void {
    var sio = try sndio.sioctl_open(null, .{ .read = true, .write = true }, false);
    defer sio.close();
    debug.print("sio: {p}\n", .{ sio });

    const ret = sio.ondesc(callback, null);
    debug.print("=== Returned ===\n", .{});
    debug.print("ondesc ret: {}\n", .{ ret });
    _ = try std.io.getStdIn().reader().readByte();
}

fn callback(arg: ?[*c]anyopaque, desc: ?*siodsc, val: c_int) callconv(.C) void {
    debug.print("\n=== Called ===\n", .{});
    debug.print("arg: {any}\n", .{ arg });
    if (desc) |dsc| {
        debug.print("addr: {x}\n", .{ dsc.addr });
        debug.print("type: {any}\n", .{ dsc.type });
        debug.print("func: {s}\n", .{ dsc.funcStr() });
        debug.print("group: {s}\n", .{ dsc.groupStr() });
        debug.print("node0:\n", .{});
        debug.print("  name: {s}\n", .{ dsc.node0.nameStr() });
        debug.print("  unit: {d}\n", .{ dsc.node0.unit });
        debug.print("node1:\n", .{});
        debug.print("  name: {s}\n", .{ dsc.node1.nameStr() });
        debug.print("  unit: {d}\n", .{ dsc.node1.unit });
        debug.print("maxval: {d}\n", .{ dsc.maxval });
        debug.print("val: {d}\n", .{ val });
    } else {
        debug.print("desc: null\n", .{});
    }
}
