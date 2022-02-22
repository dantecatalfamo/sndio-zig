# sndio-zig
[sndio](https://sndio.org/) bindings for zig

Provides both native bindings and a zig wrapper
```zig
hdl = sio_open(...)

sio_write(hdl, arr, 5)
hdl.write(arr, 5)
```
