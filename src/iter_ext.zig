const iterator = @import("iterator.zig");

const Iterator = iterator.Iterator;

pub fn RangeIterator(comptime T: type) type {
    return struct {
        curr: T,
        end: T,

        const Self = @This();

        pub fn new(start: T, end: T) Self {
            return .{ .curr = start, .end = end };
        }

        pub fn next(self: *Self) ?T {
            if (self.curr < self.end) {
                defer self.curr += 1;
                return self.curr;
            }
            return null;
        }

        pub fn iter(self: *Self) Iterator(T) {
            return Iterator(T).iterator(self);
        }
    };
}

pub fn MapIterator(comptime T: type, comptime D: type) type {
    return struct {
        backing: Iterator(T),
        func: *const fn (T) D,

        const Self = @This();

        pub fn next(self: *Self) ?D {
            const item = self.backing.next() orelse return null;
            return self.func(item);
        }

        pub fn iter(self: *Self) Iterator(D) {
            return Iterator(D).iterator(self);
        }
    };
}

pub fn FoldIterator(comptime T: type, comptime D: type) type {
    return struct {
        backing: Iterator(T),
        func: *const fn (T, D) D,
        accum: D,

        const Self = @This();

        pub fn next(self: *Self) ?D {
            const item = self.backing.next() orelse return null;
            self.accum = self.func(item, self.accum);
            return self.accum;
        }

        pub fn consume(self: *Self) D {
            while (self.next()) |_| {
                continue;
            }
            return self.accum;
        }
    };
}

pub fn EnumerateIterator(comptime T: type, comptime D: type) type {
    return struct {
        backing: Iterator(T),
        index: D,

        const Self = @This();

        pub fn next(self: *Self) .{ T, D } {
            const item = self.backing.next() orelse return null;
            defer self.index += 1;
            return .{ item, self.index };
        }

        pub fn iter(self: *Self) Iterator(.{ T, D }) {
            return Iterator(.{ T, D }).iterator(self);
        }
    };
}
