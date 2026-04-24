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

    var iter = list.iter();
    while (iter.next()) |val| {
        std.debug.print("Iterator value: {}\n", .{val.*});
    }
}

pub const IterableStruct = struct {
    data: std.ArrayList(i32),
    curr: usize = 0,

    const Self = @This();

    pub fn next(self: *Self) ?*i32 {
        if (self.curr >= self.data.items.len) {
            return null;
        }
        defer self.curr += 1;
        return &self.data.items[self.curr];
    }

    pub fn iter(self: *Self) lib.Iterator(i32) {
        return lib.Iterator(i32).iterator(self);
    }
};
