const std = @import("std");
const testing = std.testing;
const math = std.math;

const Point = struct {
    x: f32,
    y: f32,

    pub fn add(self: Point, other: Point) Point {
        return Point{ .x = self.x + other.x, .y = self.y + other.y };
    }

    pub fn distance(self: Point, other: Point) f32 {
        return math.sqrt(math.pow(f32, (other.x - self.x), 2) + math.pow(f32, (other.y - self.y), 2));
    }
};

test "adding two points should work" {
    const p1 = Point{
        .x = 12.0,
        .y = 2.2,
    };
    const p2 = Point{
        .x = 15.0,
        .y = 6.2,
    };
    const res = p1.add(p2);

    try testing.expectEqual(res.x, p1.x + p2.x);
}

test "finding distance between two points should work" {
    const p1 = Point{
        .x = 12.0,
        .y = 2.2,
    };
    const p2 = Point{
        .x = 15.0,
        .y = 6.2,
    };

    const res = p1.distance(p2);
    const actual = math.sqrt(math.pow(f32, (p2.x - p1.x), 2) + math.pow(f32, (p2.y - p1.y), 2));

    try testing.expectEqual(res, actual);
}
