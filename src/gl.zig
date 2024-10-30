const std = @import("std");
const builtin = @import("builtin");

const glcorearb = @cImport({
    @cDefine("GL_GLEXT_PROTOTYPES", "1");
    @cDefine("__CYGWIN__", "1");
    @cInclude("glcorearb.h");
});

extern "opengl32" fn wglGetProcAddress(name: [*:0]const u8) callconv(.C) ?*anyopaque;

pub const glapi = glcorearb;

pub const GlProc = struct {
    glCreateShader: *fn (glapi.GLenum) callconv(.C) u32,
    glShaderSource: *fn (u32, isize, **c_char, *i32) callconv(.C) void,
    glCompileShader: *fn (u32) callconv(.C) void,
    // glDrawArrays: *fn (u32, i32, isize) callconv(.C) void,
    glGenBuffers: *fn (glapi.GLsizei, *glapi.GLuint) callconv(.C) void,
    glBindBuffer: *fn (u32, u32) callconv(.C) void,
    glBufferData: *fn (glapi.GLenum, glapi.GLsizeiptr, *const anyopaque, glapi.GLenum) callconv(.C) void,
    glEnableVertexAttribArray: *fn (u32) callconv(.C) void,
    glDisableVertexAttribArray: *fn (u32) callconv(.C) void,
    glVertexAttribPointer: *fn (glapi.GLuint, glapi.GLint, glapi.GLenum, glapi.GLboolean, glapi.GLsizei, ?*const anyopaque) void,

    pub fn load_all() GlProc {
        var glproc: GlProc = undefined;

        inline for (std.meta.fields(GlProc)) |f| {
            @field(glproc, f.name) = get_proc_fn_ptr(f.name, f.type);
        }

        return glproc;
    }
};

fn get_proc_fn_ptr(proc: [*:0]const u8, T: type) T {
    const gl_get_proc_address = switch (builtin.os.tag) {
        .windows => wglGetProcAddress,
        else => @compileError("unimplemented"),
    };

    const fnptr = gl_get_proc_address(proc) orelse {
        std.log.err("could not load {s}", .{proc});
        @panic("failed to get glproc");
    };

    return @as(T, @ptrCast(fnptr));
}
