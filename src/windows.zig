const std = @import("std");
const windows = std.os.windows;
const whey = @import("whey.zig");
const gl = @import("gl.zig");
const glapi = gl.glapi;

const PFD = extern struct {
    const DRAW_TO_WINDOW: windows.DWORD = 0x4;
    const SUPPORT_OPENGL: windows.DWORD = 0x20;
    const DOUBLEBUFFER: windows.DWORD = 0x1;
    const TYPE_RGBA: windows.BYTE = 0x0;
};

const PIXELFORMATDESCRIPTOR = extern struct {
    nSize: windows.WORD = @sizeOf(PIXELFORMATDESCRIPTOR),
    nVersion: windows.WORD = 0,
    dwFlags: windows.DWORD = 0,
    iPixelType: windows.BYTE = 0,
    cColorBits: windows.BYTE = 0,
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
    cDepthBits: windows.BYTE = 0,
    cStencilBits: windows.BYTE = 0,
    cAuxBuffers: windows.BYTE = 0,
    iLayerType: windows.BYTE = 0,
    bReserved: windows.BYTE = 0,
    dwLayerMask: windows.DWORD = 0,
    dwVisibleMask: windows.DWORD = 0,
    dwDamageMask: windows.DWORD = 0,
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
    _,
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

extern "user32" fn GetDC(hWnd: windows.HWND) callconv(.C) ?windows.HDC;

extern "gdi32" fn ChoosePixelFormat(hdc: windows.HDC, pfd: *PIXELFORMATDESCRIPTOR) callconv(.C) windows.INT;

extern "gdi32" fn SetPixelFormat(hdc: windows.HDC, format: windows.INT, pfd: *PIXELFORMATDESCRIPTOR) callconv(.C) windows.BOOL;

extern "gdi32" fn SwapBuffers(hdc: windows.HDC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglCreateContext(hdc: windows.HDC) callconv(.C) ?windows.HGLRC;

extern "opengl32" fn wglMakeCurrent(hdc: windows.HDC, hglrc: windows.HGLRC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglDeleteContext(hglrc: windows.HGLRC) callconv(.C) windows.BOOL;

extern "opengl32" fn wglGetProcAddress(proc: [*:0]const u8) callconv(.C) ?*anyopaque;

extern "opengl32" fn wglGetCurrentContext() callconv(.C) ?windows.HGLRC;

extern "user32" fn GetLastError() callconv(.C) windows.DWORD;

extern "opengl32" fn glGetIntegerv(pname: u32, data: *i32) callconv(.C) void;

fn hello_trangle() void {
    const vertices = [9]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        0.0,  0.5,  0.0,
    };

    var vbo: glapi.GLuint = undefined;
    glproc.glGenBuffers(1, &vbo);
    glproc.glBindBuffer(glapi.GL_ARRAY_BUFFER, vbo);
    glproc.glBufferData(glapi.GL_ARRAY_BUFFER, @sizeOf(f32) * vertices.len, &vertices, glapi.GL_STATIC_DRAW);
    glproc.glEnableVertexAttribArray(0);
    glproc.glVertexAttribPointer(0, 3, glapi.GL_FLOAT, glapi.GL_FALSE, 0, null);
    // glproc.glDisableVertexAttribArray(0);

    // const vertex_shader = glproc.glCreateShader(glapi.GL_VERTEX_SHADER);
    //
    // glproc.glShaderSource(vertex_shader, 1, &vertex_shader_source, null);
    // glproc.glCompileShader(vertex_shader);
}

fn render() void {
    glapi.glClear(glapi.GL_COLOR_BUFFER_BIT);
    glapi.glDrawArrays(glapi.GL_TRIANGLES, 0, 3);
    _ = SwapBuffers(hdc);
}

var hdc: windows.HDC = undefined;
var glproc: gl.GlProc = undefined;
fn window_procedure(hWnd: windows.HWND, message: Event, w_param: windows.WPARAM, l_param: windows.LPARAM) callconv(.C) windows.LRESULT {
    switch (message) {
        .create => {
            hdc = GetDC(hWnd) orelse @panic("Failed to obtain device context");
            var pfd: PIXELFORMATDESCRIPTOR = .{
                .nVersion = 1,
                .dwFlags = PFD.DRAW_TO_WINDOW | PFD.SUPPORT_OPENGL | PFD.DOUBLEBUFFER,
                .iPixelType = PFD.TYPE_RGBA,
                .cColorBits = 32,
                .cDepthBits = 24,
                .cStencilBits = 8,
            };
            const pf = ChoosePixelFormat(hdc, &pfd);
            _ = SetPixelFormat(hdc, pf, &pfd);
            const hglrc = wglCreateContext(hdc) orelse @panic("failed to create opengl context");
            const res = wglMakeCurrent(hdc, hglrc);
            std.debug.assert(res == windows.TRUE);
            var version: i32 = undefined;
            glGetIntegerv(0x821b, &version);
            std.debug.print("opengl major version: {}\n", .{version});
            glproc = gl.GlProc.load_all();
            hello_trangle();
        },
        .destroy => PostQuitMessage(0),
        else => return DefWindowProcA(hWnd, message, w_param, l_param),
    }
    return 0;
}

pub fn initialize(update: whey.update_fn, instance: windows.HINSTANCE, cmd_show: windows.INT) !void {
    const class_name = "main_window";
    const window_class: WindowClassExA = .{
        .style = ClassStyle.own_device_context,
        .window_procedure = window_procedure,
        .instance = instance,
        .class_name = class_name,
    };
    _ = RegisterClassExA(window_class);
    const handle = CreateWindowExA(0, class_name, "Hello Window!", 0, 0, 0, 1280, 720, null, null, null, null);
    _ = ShowWindow(handle, cmd_show);

    var message: MSG = undefined;
    while (GetMessageA(&message, null, 0, 0) > 0) {
        _ = TranslateMessage(&message);
        _ = DispatchMessageA(&message);
        render();
        update(0.0, whey.Event.None);
    }

    return;
}
