# sndio-zig
[sndio](https://sndio.org/) bindings for zig

Provides both native bindings and a zig wrapper
```zig
hdl = sio_open(...)

sio_write(hdl, arr, 5)
hdl.write(arr, 5)
```

## Importing
```zig
const addSndio = @import("sndio-zig/build.zig").addSndio;

pub fn build(b: *std.build.Builder) void {
    [...]
    const exe = b.addExecutable("example", "src/main.zig");
    addSndio(exe);
    [...]
}
```
