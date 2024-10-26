const std = @import("std");
const windows = std.os.windows;

const ClassStyle = extern struct {
    const byte_align_client: windows.UINT = 0x1000;
    const byte_align_window: windows.UINT = 0x2000;
    const class_device_context: windows.UINT = 0x0040;
    const double_clicks: windows.UINT = 0x0008;
    const drop_shadow: windows.UINT = 0x00020000;
    const global_class: windows.UINT = 0x4000;
    const redraw_horizontal: windows.UINT = 0x0002;
    const no_close: windows.UINT = 0x0200;
    const own_device_context: windows.UINT = 0x0020;
    const parent_device_context: windows.UINT = 0x0080;
    const save_bits: windows.UINT = 0x0800;
    const redraw_vertical: windows.UINT = 0x0001;
};

const Event = extern struct {
    const close: windows.UINT = 0x0010;
    const destroy: windows.UINT = 0x0002;
    const create: windows.UINT = 0x0001;
};

const ExtendedWindowStyle = extern struct {
    const transparent: windows.DWORD = 0x0000_0020;
};

const WindowClassExA = extern struct {
    size: windows.UINT = @sizeOf(WindowClassExA),
    style: windows.UINT = 0,
    window_procedure: WindowProcedure,
    class_extra_bytes: windows.INT = 0,
    window_extra_bytes: windows.INT = 0,
    instance: windows.HINSTANCE,
    icon: ?windows.HICON = null,
    cursor: ?windows.HCURSOR = null,
    background_brush: ?windows.HBRUSH = null,
    menu_name: ?windows.LPCSTR = null,
    class_name: windows.LPCSTR,
    small_icon: ?windows.HICON = null,
};

const MSG = extern struct {
    handle: windows.HWND,
    message: windows.UINT,
    w_param: windows.WPARAM,
    l_param: windows.LPARAM,
    time: windows.DWORD,
    point: windows.POINT,
    private: windows.DWORD,
};

const WindowProcedure = *const fn (
    window_handle: windows.HWND,
    message: windows.UINT,
    w_param: windows.WPARAM,
    l_param: windows.LPARAM,
) callconv(.C) windows.LRESULT;

extern "user32" fn RegisterClassExA(class: WindowClassExA) windows.ATOM;

extern "user32" fn CreateWindowExA(
    style_ex: windows.DWORD,
    class_name: ?windows.LPCSTR,
    window_name: ?windows.LPCSTR,
    style: windows.DWORD,
    x: windows.INT,
    y: windows.INT,
    width: windows.INT,
    height: windows.INT,
    parent_window: ?windows.HWND,
    menu: ?windows.HMENU,
    instance: ?windows.HINSTANCE,
    l_param: ?windows.LPVOID,
) windows.HWND;

extern "user32" fn ShowWindow(handle: windows.HWND, cmd_show: windows.INT) windows.BOOL;

extern "user32" fn GetMessageA(message: *MSG, handle: ?windows.HWND, filter_min: windows.UINT, filter_max: windows.UINT) windows.BOOL;

extern "user32" fn TranslateMessage(message: *const MSG) windows.BOOL;

extern "user32" fn DispatchMessage(message: *const MSG) callconv(.C) windows.BOOL;

extern "user32" fn DefWindowProcA(
    handle: windows.HWND,
    message: windows.UINT,
    w_param: windows.WPARAM,
    l_param: windows.LPARAM,
) windows.LRESULT;

extern "user32" fn PostQuitMessageA(message: windows.INT) callconv(.C) void;

fn window_procedure(handle: windows.HWND, message: windows.UINT, w_param: windows.WPARAM, l_param: windows.LPARAM) callconv(.C) windows.LRESULT {
    switch (message) {
        Event.destroy => PostQuitMessageA(0),
        else => return DefWindowProcA(handle, message, w_param, l_param),
    }
    return 0;
}

pub fn initialize(update: *const fn () callconv(.C) void, instance: windows.HINSTANCE, cmd_show: windows.INT) !void {
    const class_name = "main_window";
    const window_class: WindowClassExA = .{
        .style = 0,
        .window_procedure = window_procedure,
        .instance = instance,
        .class_name = class_name,
    };
    _ = RegisterClassExA(window_class);
    const handle = CreateWindowExA(0, class_name, "Hello Window!", 0, 0, 0, 0, 0, null, null, null, null);
    _ = ShowWindow(handle, cmd_show);

    var message: MSG = undefined;
    while (GetMessageA(&message, null, 0, 0) > 0) {
        _ = TranslateMessage(&message);
        _ = DispatchMessage(&message);
        update();
    }

    return;
}
