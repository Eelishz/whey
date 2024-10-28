const std = @import("std");
const builtin = @import("builtin");
const whey = @import("whey.zig");
const windows = @import("windows.zig");
const linux = @import("linux.zig");

pub fn create_winmain(comptime update: whey.update_fn) (fn (std.os.windows.HINSTANCE, ?std.os.windows.HINSTANCE, std.os.windows.PWSTR, std.os.windows.INT) std.os.windows.INT) {
    if (builtin.os.tag == .windows) {
        return struct {
            fn wWinMain(
                h_instace: std.os.windows.HINSTANCE,
                h_prev_instance: ?std.os.windows.HINSTANCE,
                p_cmd_line: std.os.windows.PWSTR,
                n_cmd_show: std.os.windows.INT,
            ) std.os.windows.INT {
                _ = h_prev_instance;
                _ = p_cmd_line;
                windows.initialize(update, h_instace, n_cmd_show) catch @panic("window init failed");
                return 0;
            }
        }.wWinMain;
    } else {
        return null;
    }
}

pub fn create_main(comptime update: whey.update_fn) (fn () void) {
    switch (builtin.os.tag) {
        .windows => return struct {
            fn main() void {
                std.start.call_wWinMain();
            }
        }.main,
        .linux => return struct {
            fn main() void {
                linux.initialize(update) catch @panic("window init failed");
            }
        }.main,
        else => @panic("unimplemented"),
    }
}
