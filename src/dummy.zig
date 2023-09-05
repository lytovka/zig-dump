const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const log = std.log;

pub fn subtract_func(x: u32, y: u32) u32 {
    return x - y;
}

pub fn add_func(x: u32, y: u32) u32 {
    return x + y;
}

pub fn add(comptime T: type, a: T, b: T) T {
    return a + b;
}

pub fn subt(comptime T: type, a: T, b: T) T {
    return a - b;
}

pub fn concat_strings(allocator: std.mem.Allocator, x: []const u8, y: []const u8) ![]const u8 {
    var result = try allocator.alloc(u8, x.len + y.len);
    std.mem.copy(u8, result, x);
    std.mem.copy(u8, result[x.len..], y);
    // return x ++ y;
    return result;
}

pub fn main() !void {
    var opt_v: ?u32 = null;
    assert(opt_v == null);

    opt_v = 15;

    var arr = [_]u8{ 1, 3, 4 };

    log.info("\noptional 1\ntype: {}\nvalue: {?}\n", .{ @TypeOf(opt_v), opt_v });
    log.info("\noptional 2\ntype: {}\nvalue: {s}\n", .{ @TypeOf(arr), arr });
}

test "expect add_func to correctly calculate sum" {
    try testing.expectEqual(add(u32, 42, 55), 42 + 55);
    try testing.expectEqual(add(f32, 4.2, 5.5), 4.2 + 5.5);
}

test "expect subtract_func to correctly calculate subtraction" {
    var x: u16 = 500;
    var y: u16 = 200;

    try testing.expectEqual(subtract_func(x, y), x - y);
}

test "expect concat_strings to correctly concatenate strings" {
    const x = "Ivan ";
    const y = "L.";
    var memory: [500]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&memory);
    const allocator = fba.allocator();
    const res = try concat_strings(allocator, x, y);
    try testing.expect(std.mem.eql(u8, "Ivan L.", res));
    // defer allocator.free(res);
}
