const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const pollfd = std.os.system.pollfd;

pub const sioctl_hdl = opaque {
    pub const devany = "default";
    const Self = @This();

    pub fn open(name: ?[*:0]const u8, mode: sioctl_mode, non_blocking_io: bool) !*sioctl_hdl {
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

pub extern fn sioctl_open(name: [*:0]const u8, mode: c_uint, nbio_flag: c_int) ?*sioctl_hdl;
pub extern fn sioctl_close(hdl: *sioctl_hdl) void;
pub extern fn sioctl_ondesc(hdl: *sioctl_hdl, callback: fn (arg: ?[*c]anyopaque, desc: ?*sioctl_desc, val: c_int) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern fn sioctl_onval(hdl: *sioctl_hdl, callback: fn (arg: ?[*c]anyopaque, addr: c_uint, val: c_uint) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern fn sioctl_setval(hdl: *sioctl_hdl, addr: c_uint, val: c_uint) c_int;
pub extern fn sioctl_nfds(hdl: *sioctl_hdl) c_int;
pub extern fn sioctl_pollfd(hdl: *sioctl_hdl, pfd: [*]pollfd, events: c_int) c_int;
pub extern fn sioctl_revents(hdl: *sioctl_hdl, pfd: [*]pollfd) c_int;
pub extern fn sioctl_eof(hdl: *sioctl_hdl) c_int;
