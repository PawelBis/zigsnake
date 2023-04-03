const std = @import("std");
const Vec2 = @import("Vec2.zig").Vec2;

const MAX_SNAKE_LENGTH: usize = 15;
pub const Snake = struct {
    position: Vec2,
    tail: [MAX_SNAKE_LENGTH + 1]Vec2,
    length: u8,
    direction: Vec2 = Vec2{ .x = 0, .y = 0 },

    pub fn spawn(pos_x: i32, pos_y: i32) Snake {
        return Snake{
            .position = Vec2{
                .x = pos_x,
                .y = pos_y,
            },
            .tail = std.mem.zeroes([MAX_SNAKE_LENGTH + 1]Vec2),
            .length = 1,
        };
    }

    pub fn updateDirection(self: *Snake, new_direction: Vec2) void {
        const direction_update = Vec2.add(new_direction, self.direction);
        if (!direction_update.is_zero()) {
            self.direction = new_direction;
        }
    }

    pub fn updatePosition(self: *Snake) void {
        self.position = Vec2.add(self.position, self.direction);
        var i = self.length;
        while (i >= 1) : (i -= 1) {
            self.tail[i] = self.tail[i - 1];
        }
        self.tail[0] = self.position;
    }

    pub fn checkCollision(self: Snake) bool {
        var i: usize = 1;
        while (i < self.length) : (i += 1) {
            const tail_segment_position = self.tail[i];
            if (Vec2.is_equal(self.position, tail_segment_position)) {
                return true;
            }
        }
        return false;
    }

    pub fn tryConsumeFood(self: *Snake, food_position: Vec2) bool {
        if (Vec2.is_equal(self.position, food_position)) {
            self.length += 1;
            return true;
        }
        return false;
    }
};
