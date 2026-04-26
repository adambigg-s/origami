const std = @import("std");
const expect = std.testing.expect;

pub const iterator = @import("iterator.zig");
pub const Iterator = iterator.Iterator;
pub const IteratorMut = iterator.IteratorMut;
pub const Collector = iterator.Collector;
pub const RangeIterator = iterator.RangeIterator;
pub const SliceIterator = iterator.SliceIterator;
pub const SliceIteratorMut = iterator.SliceIteratorMut;
const ttypes = @import("test_types.zig");

test "range iterator" {
    var range = RangeIterator(i32).new(0, 3);
    try expect(range.next() == 0);
    try expect(range.next() == 1);
    try expect(range.next() == 2);
    try expect(range.next() == null);
}

test "slice iterator" {
    const slice = [_]i32{ 1, 2, 3 };
    var slice_iter = SliceIterator(i32).new(&slice);
    try expect(slice_iter.next() == 1);
    try expect(slice_iter.next() == 2);
    try expect(slice_iter.next() == 3);
    try expect(slice_iter.next() == null);
}

test "general iterator" {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const alloc = gpa.allocator();

    var data = ttypes.ImplIterator{
        .list = try std.ArrayList(i32).initCapacity(alloc, 3),
        .alloc = alloc,
    };
    defer data.list.deinit(alloc);
    try data.list.append(alloc, 0);
    try data.list.append(alloc, 1);
    try data.list.append(alloc, 2);

    var iter = data.intoIterator();
    try expect(iter.next() == 0);
    try expect(iter.next() == 1);
    try expect(iter.next() == 2);
}

test "map iterator" {
    var range = RangeIterator(i32).new(0, 3);
    var mapped = range.iter().map(i32, ttypes.doubleIti32);
    try expect(mapped.next() == 0);
    try expect(mapped.next() == 2);
    try expect(mapped.next() == 4);
    try expect(mapped.next() == null);
}

test "fold iterator" {
    var range = RangeIterator(i32).new(0, 3);
    var folder = range.iter().fold(i32, 0, ttypes.addi32);
    try expect(folder.consume() == 3);
}

test "enumerate iterator" {
    const slice = [_]i32{ 1, 2, 3 };
    var slice_iter = SliceIterator(i32).new(&slice);
    var slice_enumerate = slice_iter.iter().enumerate();

    const first = slice_enumerate.next().?;
    try expect(first.value == 1 and first.index == 0);
    const second = slice_enumerate.next().?;
    try expect(second.value == 2 and second.index == 1);
    const third = slice_enumerate.next().?;
    try expect(third.value == 3 and third.index == 2);
}

test "collect iterator" {
    var gpa = std.heap.DebugAllocator(.{}).init;
    defer std.debug.assert(gpa.deinit() == .ok);
    const alloc = gpa.allocator();

    var data = ttypes.ImplCollector{
        .list = try std.ArrayList(i32).initCapacity(alloc, 3),
        .alloc = alloc,
    };
    defer data.list.deinit(alloc);
    const slice = [_]i32{ 1, 2, 3 };
    var slice_iter = SliceIterator(i32).new(&slice);

    var collector = data.intoCollector();
    while (slice_iter.next()) |item| {
        try collector.collect(item);
    }
    try std.testing.expectEqualSlices(i32, data.list.items, &[_]i32{ 1, 2, 3 });
}
