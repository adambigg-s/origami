const std = @import("std");
const lib = @import("origami");

pub fn main(_: std.process.Init) !void {
    var alloc = std.heap.DebugAllocator(.{}).init;
    defer std.debug.assert(alloc.deinit() == .ok);

    var list = IterableStruct{
        .data = try std.ArrayList(i32).initCapacity(alloc.allocator(), 150),
    };
    defer list.data.deinit(alloc.allocator());
    try list.data.append(alloc.allocator(), 1);
    try list.data.append(alloc.allocator(), 2);
    try list.data.append(alloc.allocator(), 6);
    try list.data.append(alloc.allocator(), 7);
    try list.data.append(alloc.allocator(), 6);
    try list.data.append(alloc.allocator(), 7);

    list.iter().forEach(print_i32);
    list.curr = 0;
}

fn print_i32(x: i32) void {
    std.debug.print("Value: {}\n", .{x});
}

fn double_i32(x: i32) i32 {
    return x * 2;
}

pub const IterableStruct = struct {
    data: std.ArrayList(i32),
    curr: usize = 0,

    const Self = @This();

    pub fn next(self: *Self) ?i32 {
        if (self.curr >= self.data.items.len) {
            return null;
        }
        defer self.curr += 1;
        return self.data.items[self.curr];
    }

    pub fn iter(self: *Self) lib.Iterator(i32) {
        return lib.Iterator(i32).iterator(self);
    }

    pub fn iterMut(self: *Self) lib.IteratorMut(i32) {
        return lib.IteratorMut(i32).iteratorMut(self);
    }
};
