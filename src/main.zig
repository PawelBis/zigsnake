const std = @import("std");
const Vec2 = @import("Vec2.zig").Vec2;
const Snake = @import("Snake.zig").Snake;
const Xoshiro256 = std.rand.Xoshiro256;
const Thread = std.Thread;
const Writer = std.io.Writer;
const controls = @import("controls.zig");
const Input = controls.Input;
const sys = std.zig.system.NativeTargetInfo;

pub fn gotoxy(x: usize, y: usize, draw: ?u8) !void {
    sys.detect()
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{c}[{d};{d}f{c}", .{ 0x1B, y, x, draw orelse 'X' });
}

const MAP_WIDTH: usize = 40;
const MAP_HEIGHT: usize = 20;

// Yes, I know
const CLRSCR = "\x1B[2J\x1B[H";
pub fn clearScreen() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(CLRSCR, .{});
}

pub fn drawMap() !void {
    for (1..MAP_HEIGHT + 1) |y| {
        for (1..MAP_WIDTH + 1) |x| {
            if (x == 1 or x == MAP_WIDTH or y == 1 or y == MAP_HEIGHT) {
                try gotoxy(x, y, 'X');
            }
        }
    }
}

pub fn render(snake: Snake) !void {
    for (0..snake.length) |i| {
        const position = snake.tail[i];
        try gotoxy(position.getX(), position.getY(), 'O');
    }
    const clear_position = snake.tail[snake.length];
    try gotoxy(clear_position.getX(), clear_position.getY(), ' ');
    try gotoxy(MAP_WIDTH, MAP_HEIGHT, null);
}

pub fn spawnFood(rand: *Xoshiro256) !Vec2 {
    const rand_x: i32 = @mod(rand.random().int(i32), @intCast(i32, MAP_WIDTH - 2)) + 2;
    const rand_y: i32 = @mod(rand.random().int(i32), @intCast(i32, MAP_HEIGHT - 2)) + 2;
    const spawn_position = Vec2{ .x = rand_x, .y = rand_y };
    try gotoxy(spawn_position.getX(), spawn_position.getY(), '#');

    return spawn_position;
}

pub fn main() !void {
    var termios = try controls.setupInput();
    _ = termios;
    try clearScreen();

    try drawMap();
    var input: ?Input = null;

    var snake = Snake.spawn(MAP_WIDTH / 2, MAP_HEIGHT / 2);
    var rand_impl = std.rand.DefaultPrng.init(0);
    var food_position: ?Vec2 = null;
    snake.tail[0] = snake.position;

    while (input != Input.Exit) {
        const timer_substep: u64 = 1_000_000_000;
        input = try controls.pollInput(timer_substep);
        if (input) |some_input| {
            const move_direction = switch (some_input) {
                Input.Left => Vec2{ .x = -1, .y = 0 },
                Input.Right => Vec2{ .x = 1, .y = 0 },
                Input.Down => Vec2{ .x = 0, .y = 1 },
                Input.Up => Vec2{ .x = 0, .y = -1 },
                else => Vec2{},
            };
            snake.updateDirection(move_direction);
        }

        if (food_position == null) {
            food_position = try spawnFood(&rand_impl);
        }

        snake.updatePosition();
        try render(snake);
        if (snake.checkCollision()) {
            return;
        }
        if (food_position) |food| {
            if (snake.tryConsumeFood(food)) {
                food_position = null;
            }
        }
    }
}
