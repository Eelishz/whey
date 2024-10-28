const std = @import("std");
const windows = std.os.windows;
const whey = @import("whey.zig");

const PIXELFORMATDESCRIPTOR = extern struct {
    nSize: windows.WORD = 0,
    nVersion: windows.WORD = 1,
    dwFlags: windows.DWORD = PFD.DRAW_TO_WINDOW | PFD.SUPPORT_OPENGL | PFD.DOUBLEBUFFER,
    iPixelType: windows.BYTE = PFD.TYPE_RGBA,
    cColorBits: windows.BYTE = 32,
    cRedBits: windows.BYTE = 0,
    cRedShift: windows.BYTE = 0,
    cGreenBits: windows.BYTE = 0,
    cGreenShift: windows.BYTE = 0,
    cBlueBits: windows.BYTE = 0,
    cBlueShift: windows.BYTE = 0,
    cAlphaBits: windows.BYTE = 0,
    cAlphaShift: windows.BYTE = 0,
    cAccumBits: windows.BYTE = 0,
    cAccumRedBits: windows.BYTE = 0,
    cAccumGreenBits: windows.BYTE = 0,
    cAccumBlueBits: windows.BYTE = 0,
    cAccumAlphaBits: windows.BYTE = 0,
    cDepthBits: windows.BYTE = 24,
    cStencilBits: windows.BYTE = 8,
    cAuxBuffers: windows.BYTE = 0,
    iLayerType: windows.BYTE = 0,
    bReserved: windows.BYTE = 0,
    dwLayerMask: windows.DWORD = 0,
    dwVisibleMask: windows.DWORD = 0,
    dwDamageMask: windows.DWORD = 0,
};

const PFD = extern struct {
    const DRAW_TO_WINDOW: windows.DWORD = 0x4;
    const SUPPORT_OPENGL: windows.DWORD = 0x20;
    const DOUBLEBUFFER: windows.DWORD = 0x1;
    const TYPE_RGBA: windows.BYTE = 0x0;
};

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

const Event = enum(windows.UINT) {
    close = 0x0010,
    destroy = 0x0002,
    create = 0x0001,
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
    message: Event,
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

extern "user32" fn DispatchMessageA(message: *const MSG) callconv(.C) windows.LRESULT;

extern "user32" fn DefWindowProcA(
    handle: windows.HWND,
    message: Event,
    w_param: windows.WPARAM,
    l_param: windows.LPARAM,
) windows.LRESULT;

extern "user32" fn PostQuitMessage(message: windows.INT) callconv(.C) void;

extern "user32" fn GetDC(hwnd: windows.HWND) callconv(.C) ?windows.HDC;

extern "gdi32" fn ChoosePixelFormat(hdc: windows.HDC, pfd: PIXELFORMATDESCRIPTOR) callconv(.C) windows.INT;

extern "gdi32" fn SetPixelFormat(hdc: windows.HDC, format: windows.INT, pfd: PIXELFORMATDESCRIPTOR) callconv(.C) windows.BOOL;

extern "gdi32" fn SwapBuffers(hdc: windows.HDC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglCreateContext(hdc: windows.HDC) callconv(.C) windows.HGLRC;

extern "opengl32" fn wglMakeCurrent(hdc: windows.HDC, hglrc: windows.HGLRC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglDeleteContext(hglrc: windows.HGLRC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglGetProcAddress(proc: [*:0]const u8) callconv(.C) ?*anyopaque;

fn window_procedure(hwnd: windows.HWND, message: Event, w_param: windows.WPARAM, l_param: windows.LPARAM) callconv(.C) windows.LRESULT {
    switch (message) {
        .create => {
            const hdc = GetDC(hwnd) orelse @panic("Failed to create device context");
            const pfd = PIXELFORMATDESCRIPTOR{};
            const pf = ChoosePixelFormat(hdc, pfd);
            std.debug.assert(SetPixelFormat(hdc, pf, pfd) != windows.FALSE);
            const ctx = wglCreateContext(hdc);
            std.debug.assert(wglMakeCurrent(hdc, ctx) != windows.FALSE);

            const getIntegerv = @as(*const fn (u32, *i32) callconv(.C) void, @ptrCast(@alignCast(wglGetProcAddress("glGetIntegerv"))));
            var version: i32 = 0;
            getIntegerv(0x821B, &version);
            std.debug.print("Major version: {d}\n", .{version});
        },
        .destroy => PostQuitMessage(0),
        else => return DefWindowProcA(hwnd, message, w_param, l_param),
    }
    return 0;
}

pub fn initialize(update: whey.update_fn, instance: windows.HINSTANCE, cmd_show: windows.INT) !void {
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
        _ = DispatchMessageA(&message);
        update(0.0, whey.Event.None);
    }

    return;
}
