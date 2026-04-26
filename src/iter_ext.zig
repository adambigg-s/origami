const iterator = @import("iterator.zig");
const Iterator = iterator.Iterator;
const IteratorMut = iterator.IteratorMut;

pub fn RangeIterator(comptime T: type) type {
    return struct {
        curr: T = 0,
        end: T = 0,

        const Self = @This();

        pub fn new(start: T, end: T) Self {
            return .{
                .curr = start,
                .end = end,
            };
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

pub fn SliceIterator(comptime T: type) type {
    return struct {
        slice: []const T,
        curr: usize = 0,

        const Self = @This();

        pub fn new(over: []const T) Self {
            return .{ .slice = over };
        }

        pub fn next(self: *Self) ?T {
            if (self.curr < self.slice.len) {
                defer self.curr += 1;
                return self.slice[self.curr];
            }
            return null;
        }

        pub fn iter(self: *Self) Iterator(T) {
            return Iterator(T).iterator(self);
        }
    };
}

pub fn SliceIteratorMut(comptime T: type) type {
    return struct {
        slice: []T,
        curr: usize = 0,

        const Self = @This();

        pub fn new(over: []T) Self {
            return .{ .slice = over };
        }

        pub fn next(self: *Self) ?*T {
            if (self.curr < self.slice.len) {
                defer self.curr += 1;
                return &self.slice[self.curr];
            }
            return null;
        }

        pub fn iter(self: *Self) Iterator(T) {
            return IteratorMut(T).iteratorMut(self);
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

pub fn EnumerateIterator(comptime T: type) type {
    return struct {
        backing: Iterator(T),
        curr: usize = 0,

        const Pair = struct {
            value: T,
            index: usize,
        };

        const Self = @This();

        pub fn next(self: *Self) ?Pair {
            const item = self.backing.next() orelse return null;
            defer self.curr += 1;
            return Pair{
                .value = item,
                .index = self.curr,
            };
        }

        pub fn iter(self: *Self) Iterator(Pair) {
            return Iterator(Pair).iterator(self);
        }
    };
}

pub fn EnumerateIteratorMut(comptime T: type) type {
    return struct {
        backing: IteratorMut(T),
        curr: usize = 0,

        const Pair = struct {
            value: *T,
            index: usize,
        };

        const Self = @This();

        pub fn next(self: *Self) ?Pair {
            const item = self.backing.next() orelse return null;
            defer self.curr += 1;
            return Pair{
                .value = item,
                .index = self.curr,
            };
        }

        pub fn iterMut(self: *Self) IteratorMut(Pair) {
            return IteratorMut(Pair).iteratorMut(self);
        }
    };
}
