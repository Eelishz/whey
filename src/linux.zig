const std = @import("std");
const whey = @import("whey.zig");
// const xlib = @import("Xlib.zig");
const xlib = @cImport({
    @cInclude("X11/Xlib.h");
});

pub fn initialize(update: *const fn (delta_time: f32, event: whey.Event) callconv(.C) void) !void {
    const display = xlib.XOpenDisplay(null);
    if (display == null) {
        return error.xliberror;
    }

    const screen = xlib.DefaultScreen(display);

    const window = xlib.XCreateSimpleWindow(display, xlib.RootWindow(display, screen), 10, 10, 800, 600, 1, xlib.BlackPixel(display, screen), xlib.WhitePixel(display, screen));

    _ = xlib.XSelectInput(display, window, xlib.ExposureMask | xlib.KeyPressMask);

    _ = xlib.XMapWindow(display, window);

    var event: xlib.XEvent = undefined;

    while (true) {
        _ = xlib.XNextEvent(display, &event);

        if (event.type == xlib.Expose) {
            _ = xlib.XFillRectangle(display, window, xlib.DefaultGC(display, screen), 20, 20, 10, 10);
        }

        if (event.type == xlib.KeyPress) {
            break;
        }
        update(0.0, whey.Event.None);
    }

    _ = xlib.XCloseDisplay(display);

    return;
}
