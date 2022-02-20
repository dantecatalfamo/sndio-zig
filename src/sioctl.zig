const std = @import("std");
const mem = std.mem;
const debug = std.debug;
const pollfd = std.os.system.pollfd;

// sndioctl

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
    /// control address
    addr: c_uint,
    @"type": sioctl_type,
    /// function name, ex. "level"
    func: [12]u8,
    /// group this control belongs to
    group: [12]u8,
    /// affected node
    node0: sioctl_node,
    /// affected list/vec/sel node
    node1: sioctl_node,
    /// max value
    maxval: c_uint,

    const Self = @This();

    pub fn funcStr(self: Self) []const u8 {
        return mem.sliceTo(&self.func, 0);
    }

    pub fn groupStr(self: Self) []const u8 {
        return mem.sliceTo(&self.group, 0);
    }
};

/// controlled component of the device
pub const sioctl_node = extern struct {
    /// ex. "spkr"
    name: [12]u8,
    /// optional number or -1
    unit: c_int,

    const Self = @This();

    pub fn nameStr(self: Self) []const u8 {
        return mem.sliceTo(&self.name, 0);
    }
};

pub const sioctl_type = enum(c_int) {
    /// deleted
    none = 0,
    /// integer in the 0..maxval range
    num = 2,
    /// on/off switch (0 or 1)
    sw = 3,
    /// number, element of vector
    vec = 4,
    /// switch, element of a list
    list = 5,
    /// element of a selector
    sel = 6
};

pub extern "sndio" fn sioctl_open(name: [*:0]const u8, mode: c_uint, nbio_flag: c_int) ?*sioctl_hdl;
pub extern "sndio" fn sioctl_close(hdl: *sioctl_hdl) void;
pub extern "sndio" fn sioctl_ondesc(hdl: *sioctl_hdl, callback: fn (arg: ?[*c]anyopaque, desc: ?*sioctl_desc, val: c_int) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern "sndio" fn sioctl_onval(hdl: *sioctl_hdl, callback: fn (arg: ?[*c]anyopaque, addr: c_uint, val: c_uint) callconv(.C) void, arg: ?[*c]anyopaque) c_int;
pub extern "sndio" fn sioctl_setval(hdl: *sioctl_hdl, addr: c_uint, val: c_uint) c_int;
pub extern "sndio" fn sioctl_nfds(hdl: *sioctl_hdl) c_int;
pub extern "sndio" fn sioctl_pollfd(hdl: *sioctl_hdl, pfd: [*]pollfd, events: c_int) c_int;
pub extern "sndio" fn sioctl_revents(hdl: *sioctl_hdl, pfd: [*]pollfd) c_int;
pub extern "sndio" fn sioctl_eof(hdl: *sioctl_hdl) c_int;

// sndio

pub const sio_hdl = opaque {
    pub const devany = "default";
    const Self = @This();

    pub fn open(name: ?[*:0]const u8, mode: sio_mode, non_blocking_io: bool) !*Self {
        const name_str = blk: {
            if (name) |nm| {
                break :blk nm;
            }
            break :blk devany;
        };
        const mode_int = mode.val();
        const nbio_flag = @boolToInt(non_blocking_io);
        const maybe_hdl = sio_open(name_str, mode_int, nbio_flag);
        if (maybe_hdl) |hdl| {
            return hdl;
        }
        return error.OpenError;
    }

    pub fn close(self: *Self) void {
        sio_close(self);
    }

    pub fn setpar(self: *Self, par: *sio_par) c_int {
        return sio_setpar(self, par);
    }

    pub fn getpar(self: *Self, par: *sio_par) c_int {
        return sio_getpar(self, par);
    }

    pub fn getcap(self: *Self, cap: *sio_cap) c_int {
        return sio_getcap(self, cap);
    }

    pub fn onmove(self: *Self, callback: fn (arg: ?[*c]anyopaque, delta: c_int) callconv(.C) void, arg: ?[*c]anyopaque) void {
        return sio_onmove(self, callback, arg);
    }

    pub fn write(self: *Self, addr: [*]anyopaque, nbytes: usize) usize {
        return sio_write(self, addr, nbytes);
    }

    pub fn read(self: *Self, addr: [*]anyopaque, nbytes: usize) usize {
        return sio_read(self, addr, nbytes);
    }

    pub fn start(self: *Self) c_int {
        return sio_start(self);
    }

    pub fn stop(self: *Self) c_int {
        return sio_stop(self);
    }

    pub fn nfds(self: *Self) c_int {
        return sio_nfds(self);
    }

    pub fn pollfd(self: *Self, pfd: [*]pollfd, events: c_int) c_int {
        return sio_pollfd(self, pfd, events);
    }

    pub fn revents(self: *Self, pfd: [*]pollfd) c_int {
        return sio_revents(self, pfd);
    }

    pub fn eof(self: *Self) c_int {
        return sio_eof(self);
    }

    pub fn setvol(self: *Self, vol: c_uint) c_int {
        return sio_setvol(self, vol);
    }

    pub fn onvol(self: *Self, callback: fn (arg: [*c]anyopaque, vol: c_uint) callconv(.C) void , arg: [*c]anyopaque) c_int {
        return sio_onvol(self, callback, arg);
    }
};

pub const sio_mode = struct {
    play: bool = false,
    record: bool = false,

    const play_val: c_uint = 1;
    const record_val: c_uint = 2;

    const Self = @This();

    pub fn val(self: Self) c_uint {
        const p = if (self.play) play_val else 0;
        const r = if (self.record) record_val else 0;
        return p | r;
    }
};

/// parameters of a full-duplex stream
pub const sio_par = extern struct {
    /// bits per sample
    bits: c_uint,
    /// bytes per sample
    bps: c_uint,
    /// 1 = signed, 0 = unsigned
    sig: c_uint,
    /// 1 = LE, 0 = BE byte order
    le: c_uint,
    /// 1 = MSB, 0 = LSB aligned
    msb: c_uint,
    /// number channels for recording direction
    rchan: c_uint,
    /// number channels for playback direction
    pchan: c_uint,
    /// frames per second
    rate: c_uint,
    /// end-to-end buffer size
    bufsz: c_uint,
    /// what to do on overruns/underruns
    xrun: xrun_error,
    /// optimal bufsz divisor
    round: c_uint,
    /// minimum buffer size
    appbufsz: c_uint,
    /// for future use
    __pad: [3]c_int,
    /// for internal/debug purposes only
    __magic: c_uint,
};

const xrun_error = enum (c_uint) {
    /// pause during xrun
    ignore = 0,
    /// resync after xrun
    sync = 1,
    /// terminate on xrun
    @"error" = 2,
};

/// capabilities of a stream
pub const sio_cap: extern struct {
    enc: [8]sio_enc,
    /// allowed values for rchan
    rchan: [8]c_uint,
    /// allowed values for pchan
    pchan: [8]c_uint,
    /// allowed rates
    rate: [16]c_uint,
    /// for future use
    __pad: [7]c_int,
    /// number of elements in confs[]
    nconf: c_uint,
    confs: [4]sio_conf,
};

/// allowed sample encodings
pub const sio_enc: extern struct {
    bits: c_uint,
    bps: c_uint,
    sig: c_uint,
    le: c_uint,
    msb: c_uint,
};

pub const sio_conf = extern struct {
    /// mask of enc[] indexes
    enc: c_uint,
    /// mask of chan[] indexes (rec)
    rchan: c_uint,
    /// mask of chan[] indexes (play)
    pchan: c_uint,
    /// mask of rate[] indexes
    rate: c_uint,
};

pub fn sioBps(bits: c_uint) c_uint {
    if (bits <= 8) {
        return 1;
    } else if (bits <= 16) {
        return 2;
    } else {
        return 4;
    }
}

pub extern "sndio" fn sio_initpar(par: *sio_par) void;
pub extern "sndio" fn sio_open(name: [*:0]const u8, mode: c_uint, nbio_flag: c_int) ?*sio_hdl;
pub extern "sndio" fn sio_close(hdl: *sio_hdl) void;
pub extern "sndio" fn sio_setpar(hdl: *sio_hdl, par: *sio_par) c_int;
pub extern "sndio" fn sio_getpar(hdl: *sio_hdl, par: *sio_par) c_int;
pub extern "sndio" fn sio_getcap(hdl: *sio_hdl, cap: *sio_cap) c_int;
pub extern "sndio" fn sio_onmove(hdl: *sio_hdl, callback: fn (arg: ?[*c]anyopaque, delta: c_int) callconv(.C) void, arg: ?[*c]anyopaque) void;
pub extern "sndio" fn sio_write(hdl: *sio_hdl, addr: [*]anyopaque, nbytes: usize) usize;
pub extern "sndio" fn sio_read(hdl: *sio_hdl, addr: [*]anyopaque, nbytes: usize) usize;
pub extern "sndio" fn sio_start(hdl: *sio_hdl) c_int;
pub extern "sndio" fn sio_stop(hdl: *sio_hdl) c_int;
pub extern "sndio" fn sio_nfds(hdl: *sio_hdl) c_int;
pub extern "sndio" fn sio_pollfd(hdl: *sio_hdl, pfd: [*]pollfd, events: c_int) c_int;
pub extern "sndio" fn sio_revents(hdl: *sio_hdl, pfd: [*]pollfd) c_int;
pub extern "sndio" fn sio_eof(hdl: *sio_hdl) c_int;
pub extern "sndio" fn sio_setvol(hdl: *sio_hdl, vol: c_uint) c_int;
pub extern "sndio" fn sio_onvol(hdl: *sio_hdl, fn (arg: [*c]anyopaque, vol: c_uint) callconv(.C) void , arg: [*c]anyopaque) c_int;

// midi

pub const mio_hdl = opaque {
    pub const devany = "default";
    const Self = @This();

    pub fn open(name: ?[*:0]const u8, mode: mio_mode, non_blocking_io: bool) !*Self {
        const name_str = blk: {
            if (name) |nm| {
                break :blk nm;
            }
            break :blk devany;
        };
        const mode_int = mode.val();
        const nbio_flag = @boolToInt(non_blocking_io);
        const maybe_hdl = mio_open(name_str, mode_int, nbio_flag);
        if (maybe_hdl) |hdl| {
            return hdl;
        }
        return error.OpenError;
    }

    pub fn close(self: *Self) void {
        return mio_close(self);
    }

    pub fn write(self: *Self, addr: [*]anyopaque, nbytes: usize) usize {
        return mio_write(self, addr, nbytes);
    }

    pub fn read(self: *Self, addr: [*]anyopaque, nbytes: usize) usize {
        return mio_read(self, addr, nbytes);
    }

    pub fn nfds(self: *Self) c_int {
        return mio_nfds(self);
    }

    pub fn pollfd(self: *Self, pfd: [*]pollfd, events: c_int) c_int {
        return mio_pollfd(self, pfd, events);
    }

    pub fn revents(self: *Self, pdf: [*]pollfd) c_int {
        return mio_revents(self, pfd);
    }

    pub fn eof(self: *Self) c_int {
        return mio_eof(self);
    }
};

pub const mio_mode = struct {
    out: bool = false,
    in: bool = false,

    const out_val: c_uint = 4;
    const in_val: c_uint = 8;

    const Self = @This();

    pub fn val(self: Self) c_uint {
        const o = if (self.out) out_val else 0;
        const i = if (self.in) in_val else 0;
        return o | i;
    }
};


pub extern fn mio_open(name: [*:0]const u8, mode: c_uint, nbio_flag: c_int) ?*mio_hdl;
pub extern fn mio_close(hdl: *mio_hdl) void;
pub extern fn mio_write(hdl: *mio_hdl, addr: [*]anyopaque, nbytes: usize) usize;
pub extern fn mio_read(hdl: *mio_hdl, addr: [*]anyopaque, nbytes: usize) usize;
pub extern fn mio_nfds(hdl: *mio_hdl) c_int;
pub extern fn mio_pollfd(hdl: *mio_hdl, pfd: [*]pollfd, events: c_int) c_int;
pub extern fn mio_revents(hdl: *mio_hdl, pdf: [*]pollfd) c_int;
pub extern fn mio_eof(hdl: *mio_hdl) c_int;
