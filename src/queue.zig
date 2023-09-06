const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const testing = std.testing;

pub const QueueError = error{
    /// Attempt to take from an empty queue.
    EmptyQueue,

    /// Attempt to add to a full queue.
    FullQueue,
};

pub fn StaticQueue(comptime T: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();
        items: [capacity]?T,
        eIndex: usize, // enqueue index
        dIndex: usize, // dequeue index

        pub fn init() Self {
            return Self{ .items = [_]?T{null} ** capacity, .eIndex = 0, .dIndex = 0 };
        }

        pub fn deinit(self: *Self) Self {
            return self.init();
        }

        pub fn enqueue(self: *Self, elem: T) QueueError!void {
            if (self.items[nextIndex(self.eIndex)] != null) return QueueError.FullQueue;
            self.items[self.nextEnqueueIndex()] = elem;
        }

        pub fn dequeue(self: *Self) QueueError!T {
            if (self.items[self.nextDequeueIndex()] == null) return QueueError.EmptyQueue;
            const result = self.items[self.dIndex].?;
            self.items[self.dIndex] = null;

            return result;
        }

        // Perhaps there's a more efficient way to do this
        pub fn count(self: *Self) usize {
            var res: usize = 0;
            for (self.items) |item| {
                if (item != null) {
                    res += 1;
                }
            }
            return res;
        }

        fn nextEnqueueIndex(self: *Self) usize {
            self.eIndex = nextIndex(self.eIndex);
            return self.eIndex;
        }

        fn nextDequeueIndex(self: *Self) usize {
            self.dIndex = nextIndex(self.dIndex);
            return self.dIndex;
        }

        fn nextIndex(i: usize) usize {
            var result = i + 1;
            if (result >= capacity) result = 0;
            return result;
        }
    };
}

pub fn DynamicQueue(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        size: usize,
        list: std.ArrayList(T),

        pub fn init(alloc: Allocator) Self {
            return Self{
                .allocator = alloc,
                .size = 0,
                .list = std.ArrayList(T).init(alloc),
            };
        }

        pub fn deinit(self: *Self) void {
            if (@sizeOf(T) > 0) {
                self.list.deinit();
                // self.allocator.free(self.list);
                self.size = 0;
            }
        }

        pub fn enqueue(self: *Self, elem: T) !void {
            try self.list.insert(0, elem);
            self.size += 1;
        }

        pub fn dequeue(self: *Self) QueueError!T {
            try self.assertCanDequeue();
            const val = self.list.pop();
            self.size -= 1;
            return val;
        }

        pub fn peek(self: *Self) ?T {
            return if (self.size > 0) self.list.items[self.list.items.len - 1] else null;
        }

        fn assertCanDequeue(self: *Self) QueueError!void {
            if (self.size <= 0) return QueueError.EmptyQueue;
        }
    };
}

const DynamicQTest = DynamicQueue(i32);

test "DynamicQueue.init" {
    var q = DynamicQTest.init(testing.allocator);
    defer q.deinit();
    expect(q.size == 0);
    expect(q.list.items.len == q.size);
}

test "DynamicQueue.enqueue" {
    var q = DynamicQTest.init(testing.allocator);
    try q.enqueue(30);
    try q.enqueue(3);
    try q.enqueue(20);

    defer q.deinit();

    expect(q.size == 3);
    expect(q.list.items.len == q.size);
}

test "DynamicQueue.dequeue - taking from empty queue should produce error" {
    var q = DynamicQTest.init(testing.allocator);
    defer q.deinit();
    expectError(QueueError.EmptyQueue, q.dequeue());
}

test "DynamicQueue.dequeue" {
    var q = DynamicQTest.init(testing.allocator);
    defer q.deinit();

    try q.enqueue(30);
    try q.enqueue(2);
    try q.enqueue(30);

    expect(q.dequeue() catch unreachable == 30);
}

test "DynamicQueue.peek" {
    var q = DynamicQTest.init(testing.allocator);
    defer q.deinit();

    expect(q.peek() == null);

    try q.enqueue(30);
    try q.enqueue(300);
    try q.enqueue(3000);

    expectEqual(@as(i32, 30), q.peek().?);
    expect(q.size == 3);
}

const Q_SIZE = 1000;
const StaticQTest = StaticQueue(i32, Q_SIZE);

test "StaticQueue.init" {
    var q = StaticQTest.init();
    try q.enqueue(2);
    try q.enqueue(3);
    try q.enqueue(4);

    expect(q.eIndex == 3);
    expect(q.dIndex == 0);

    expect(q.dequeue() catch unreachable == 2);
}

test "StaticQueue.enqueue & dequeue - basic" {
    var q = StaticQTest.init();
    var arr = [_]i32{0} ** Q_SIZE;

    for (arr) |_, index| {
        // expect(@TypeOf(index) == usize);
        arr[index] = @intCast(i32, index);
    }

    for (arr) |item| try q.enqueue(item);

    var count = q.count();

    expectEqual(@as(usize, Q_SIZE), count);

    for (arr) |expected| expect(try q.dequeue() == expected);

    expect(q.count() == 0);
}

test "StaticQueue.enqueue - should throw exception when adding element to a full queue" {
    var q = StaticQTest.init();
    var arr = [_]i32{0} ** Q_SIZE;

    for (arr) |_, index| {
        // expect(@TypeOf(index) == usize);
        arr[index] = @intCast(i32, index);
    }

    for (arr) |item| try q.enqueue(item);

    expectError(QueueError.FullQueue, q.enqueue(Q_SIZE + 1));
}

fn expectEqual(expected: anytype, actual: @TypeOf(expected)) void {
    testing.expectEqual(expected, actual) catch unreachable;
}

fn expect(predicate: bool) void {
    testing.expect(predicate) catch unreachable;
}

fn expectError(expected: anyerror, actual: anytype) void {
    testing.expectError(expected, actual) catch unreachable;
}
