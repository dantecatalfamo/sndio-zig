const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const pollfd = std.c.openbsd.pollfd;

pub const sioctl = opaque {
    pub const devany = "default";
    const Self = @This();

    pub fn open(name: ?[*:0]const u8, mode: sioctl_mode, non_blocking_io: bool) !*sioctl {
        const name_str = blk: {
            if (name) |nm| {
                break :blk nm;
            }
            break :blk devany;
        };
        const mode_int = mode.val();
        const nbio_flag = @boolToInt(non_blocking_io);
        const maybe_hdl = sioctl_open(name_str, mode_int, nbio_flag);
        if (maybe_hdl) |hdl| {
            return hdl;
        }
        return error.OpenError;
    }

    pub fn close(self: *Self) void {
        sioctl_close(self);
    }

    pub fn ondesc(self: *Self, callback: fn (arg: ?[*c]anyopaque, desc: ?*sioctl_desc, val: c_int) callconv(.C) void, arg: ?[*c]anyopaque) c_int {
        return sioctl_ondesc(self, callback, arg);
    }

    pub fn onval(self: *Self, callback: fn (arg: ?[*c]anyopaque, addr: c_uint, val: c_uint) callconv(.C) void, arg: ?[*c]anyopaque) c_int {
        return sioctl_onval(self, callback, arg);
    }

    pub fn setval(self: *Self, addr: c_int, val: c_int) c_int {
        return sioctl_setval(self, addr, val);
    }

    pub fn nfds(self: *Self) c_int {
        return sioctl_nfds(self);
    }

    pub fn pollfd(self: *Self, pfd: [*]pollfd, events: c_int) c_int {
        return sioctl_pollfd(self, pfd, events);
    }

    pub fn revents(self: *Self, pfd: [*]pollfd) c_int {
        return sioctl_revents(self, pfd);
    }

    pub fn eof(self: *Self) c_int {
        return sioctl_eof(self);
    }
};

pub const sioctl_mode = struct {
    read: bool = false,
    write: bool = false,

    const read_val: c_uint = 0x100;
    const write_val: c_uint = 0x200;

    const Self = @This();

    pub fn val(self: Self) c_uint {
        const r = if (self.read) read_val else 0;
        const w = if (self.write) write_val else 0;
        return r | w;
    }
};

test "sioctl_mode" {
    const z = (sioctl_mode{}).val();
    try std.testing.expectEqual(z, 0);
    const r = (sioctl_mode{ .read = true }).val();
    try std.testing.expectEqual(r, sioctl_mode.read_val);
    const w = (sioctl_mode{ .write = true }).val();
    try std.testing.expectEqual(w, sioctl_mode.write_val);
}

pub const sioctl_desc = extern struct {
    addr: c_uint,
    @"type": sioctl_type,
    func: [12]u8,
    group: [12]u8,
    node0: sioctl_node,
    node1: sioctl_node,
    maxval: c_uint,

    const Self = @This();

    pub fn funcStr(self: Self) []const u8 {
        return mem.sliceTo(&self.func, 0);
    }

    pub fn groupStr(self: Self) []const u8 {
        return mem.sliceTo(&self.group, 0);
    }
};

pub const sioctl_node = extern struct {
    name: [12]u8,
    unit: c_int,

    const Self = @This();

    pub fn nameStr(self: Self) []const u8 {
        return mem.sliceTo(&self.name, 0);
    }
};

pub const sioctl_type = enum(c_int) {
    none = 0,
    num = 2,
    sw = 3,
    vec = 4,
    list = 5,
    sel = 6
};

pub extern fn sioctl_open(name: [*:0]const u8, mode: c_uint, nbio_flag: c_int) ?*sioctl;
pub extern fn sioctl_close(hdl: *sioctl) void;
pub extern fn sioctl_ondesc(hdl: *sioctl, callback: fn (arg: ?[*c]anyopaque, desc: ?*sioctl_desc, val: c_int) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern fn sioctl_onval(hdl: *sioctl, callback: fn (arg: ?[*c]anyopaque, addr: c_uint, val: c_uint) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern fn sioctl_setval(hdl: *sioctl, addr: c_uint, val: c_uint) c_int;
pub extern fn sioctl_nfds(hdl: *sioctl) c_int;
pub extern fn sioctl_pollfd(hdl: *sioctl, pfd: [*]pollfd, events: c_int) c_int;
pub extern fn sioctl_revents(hdl: *sioctl, pfd: [*]pollfd) c_int;
pub extern fn sioctl_eof(hdl: *sioctl) c_int;
