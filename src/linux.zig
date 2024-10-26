const std = @import("std");
const xlib = @import("Xlib.zig");

pub fn initialize(update: *const fn () callconv(.C) void) !void {
    const display = xlib.XOpenDisplay(null);
    if (display == null) {
        return error.xliberror;
    }

    const screen = xlib.DefaultScreen(display);

    const window = xlib.XCreateSimpleWindow(display, xlib.RootWindow(display, screen), 10, 10, 800, 600, 1, xlib.BlackPixel(display, screen), xlib.WhitePixel(display, screen));

    xlib.XSelectInput(display, xlib.ExposureMask | xlib.KeyPressMask);

    xlib.XMapWindow(display, window);

    var event: xlib.XEvent = undefined;

    while (true) {
        xlib.XNextEvent(display, &event);

        if (event.type == xlib.Expose) {
            xlib.XFillRectangle(display, window, xlib.DefaultGC(display, screen), 20, 20, 10, 10);
        }

        if (event.type == xlib.KeyPress) {
            break;
        }
        update();
    }

    xlib.XCloseDisplay(display);

    return;
}
