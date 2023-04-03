const std = @import("std");
const builtin = @import("builtin");

pub const Input = enum(u8) {
    Left = 'a',
    Right = 'd',
    Up = 'w',
    Down = 's',
    Exit = 'e',
};

pub fn setupInput() !void {
    if (builtin.os.tag != .windows) {
        const c = @cImport({
            @cInclude("termios.h");
        });
        var oldt: std.os.termios = try std.os.tcgetattr(std.os.STDIN_FILENO);
        var newt = oldt;

        newt.lflag &= ~@as(u32, c.ICANON | c.ECHO);
        newt.cc[c.VMIN] = 0;
        newt.cc[c.VTIME] = 0;
        try std.os.tcsetattr(std.os.STDIN_FILENO, std.os.TCSA.NOW, newt);
    }
}

pub fn pollInput(time_ns: u64) !?Input {
    var buffer = [1]u8{' '};
    var timer = try std.time.Timer.start();

    while (timer.read() < time_ns) {
        if (builtin.os.tag == .windows) {
            const c = @cImport({
                @cInclude("conio.h");
            });

            if (c._kbhit() != 0) {
                buffer[0] = @intCast(u8, c._getch());
            }
        } else {
            _ = try std.io.getStdIn().reader().read(&buffer);
        }
    }

    return switch (buffer[0]) {
        'a' => Input.Left,
        'd' => Input.Right,
        'w' => Input.Up,
        's' => Input.Down,
        'e' => Input.Exit,
        else => null,
    };
}
