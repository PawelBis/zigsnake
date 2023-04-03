pub const Vec2 = struct {
    x: i32 = 0,
    y: i32 = 0,

    pub fn is_zero(self: Vec2) bool {
        return self.x == 0 and self.y == 0;
    }

    pub fn add(lhs: Vec2, rhs: Vec2) Vec2 {
        return Vec2{ .x = lhs.x +% rhs.x, .y = lhs.y +% rhs.y };
    }

    pub fn is_equal(lhs: Vec2, rhs: Vec2) bool {
        const substraction = Vec2{ .x = lhs.x -% rhs.x, .y = lhs.y -% rhs.y };
        return substraction.is_zero();
    }

    pub fn getX(self: Vec2) usize {
        return @intCast(usize, self.x);
    }

    pub fn getY(self: Vec2) usize {
        return @intCast(usize, self.y);
    }
};
