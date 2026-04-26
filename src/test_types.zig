const std = @import("std");

const lib = @import("root.zig");

pub const ImplCollector = struct {
    list: std.ArrayList(i32),
    alloc: std.mem.Allocator,

    const Self = @This();

    pub fn collect(self: *Self, val: i32) !void {
        try self.list.append(self.alloc, val);
    }

    pub fn intoCollector(self: *Self) lib.Collector(i32) {
        return lib.Collector(i32).collector(self);
    }
};

pub const ImplIterator = struct {
    list: std.ArrayList(i32),
    alloc: std.mem.Allocator,
    idx: usize = 0,

    const Self = @This();

    pub fn next(self: *Self) ?i32 {
        if (self.idx < self.list.items.len) {
            defer self.idx += 1;
            return self.list.items[self.idx];
        }
        return null;
    }

    pub fn intoIterator(self: *Self) lib.Iterator(i32) {
        return lib.Iterator(i32).iterator(self);
    }
};

pub fn doubleIt(comptime T: type, val: T) T {
    return val * 2;
}

pub fn add(comptime T: type, val: T, accum: T) T {
    return accum + val;
}

pub fn doubleIti32(val: i32) i32 {
    return doubleIt(i32, val);
}

pub fn addi32(lhs: i32, rhs: i32) i32 {
    return add(i32, lhs, rhs);
}
