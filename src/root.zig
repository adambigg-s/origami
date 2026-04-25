const std = @import("std");

pub fn Collector(comptime T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            collect: *const fn (*anyopaque, T) anyerror!void,
        };

        const Self = @This();

        pub fn collect(self: Self, val: T) !void {
            return self.vtable.collect(self.ptr, val);
        }

        pub fn collector(ptr: anytype) Self {
            const D = @TypeOf(ptr);

            comptime {
                const info = @typeInfo(D);
                const name = @typeName(D);
                if (info != .pointer) {
                    @compileError("Collector.collect() needs a pointer to an iterable object\n");
                }
                if (info.pointer.size != .one) {
                    @compileError("Must be a single pointer\n");
                }
                if (!@hasDecl(info.pointer.child, "next")) {
                    @compileError(name ++ " doesn't implement .collect()\n");
                }
            }

            const impl = struct {
                pub fn call_collect(pointer: *anyopaque, val: T) !void {
                    const self: D = @ptrCast(@alignCast(pointer));
                    return self.collect(val);
                }
            };

            return .{
                .ptr = ptr,
                .vtable = &.{
                    .collect = impl.call_collect,
                },
            };
        }
    };
}

pub fn Iterator(comptime T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            next: *const fn (*anyopaque) ?T,
        };

        const Self = @This();

        pub fn next(self: Self) ?T {
            return self.vtable.next(self.ptr);
        }

        pub fn iterator(ptr: anytype) Self {
            const D = @TypeOf(ptr);

            comptime {
                const info = @typeInfo(D);
                const name = @typeName(D);
                if (info != .pointer) {
                    @compileError("Iterator.iterator() needs a pointer to an iterable object\n");
                }
                if (info.pointer.size != .one) {
                    @compileError("Must be a single pointer\n");
                }
                if (!@hasDecl(info.pointer.child, "next")) {
                    @compileError(name ++ " doesn't implement .next()\n");
                }
                if (@typeInfo(info.pointer.child) != .@"struct") {
                    @compileError("Pointer must point towards a struct\n");
                }
            }

            const impl = struct {
                pub fn call_next(pointer: *anyopaque) ?T {
                    const self: D = @ptrCast(@alignCast(pointer));
                    return self.next();
                }
            };

            return .{
                .ptr = ptr,
                .vtable = &.{
                    .next = impl.call_next,
                },
            };
        }

        pub fn forEach(self: Self, func: *const fn (T) void) void {
            while (self.next()) |item| {
                func(item);
            }
        }
    };
}

pub fn IteratorMut(comptime T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            next: *const fn (*anyopaque) ?*T,
        };

        const Self = @This();

        pub fn next(self: Self) ?*T {
            return self.vtable.next(self.ptr);
        }

        pub fn iteratorMut(ptr: anytype) Self {
            const D = @TypeOf(ptr);

            comptime {
                const info = @typeInfo(D);
                const name = @typeName(D);
                if (info != .pointer) {
                    @compileError("Iterator.iterator() needs a pointer to an iterable object\n");
                }
                if (info.pointer.size != .one) {
                    @compileError("Must be a single pointer\n");
                }
                if (!@hasDecl(info.pointer.child, "next")) {
                    @compileError(name ++ " doesn't implement .next()\n");
                }
                if (@typeInfo(info.pointer.child) != .@"struct") {
                    @compileError("Pointer must point towards a struct\n");
                }
            }

            const impl = struct {
                pub fn call_next(pointer: *anyopaque) ?*T {
                    const self: D = @ptrCast(@alignCast(pointer));
                    return self.next();
                }
            };

            return .{
                .ptr = ptr,
                .vtable = &.{
                    .next = impl.call_next,
                },
            };
        }

        pub fn forEach(self: Self, func: *const fn (*T) void) void {
            while (self.next()) |item| {
                func(item);
            }
        }

        pub fn map(self: Self, comptime D: type, func: *const fn (T) D) MapIterator(T, D) {
            return MapIterator(T, D){ .backing = self, .func = func };
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

// pub fn FoldIterator(comptime T: type, comptime D: type) type {
//     return struct {};
// }

pub fn RangeIterator(comptime T: type) type {
    return struct {
        curr: T,
        end: T,

        const Self = @This();

        pub fn new(start: T, end: T) Self {
            return .{ .curr = start, .end = end };
        }

        pub fn next(self: Self) ?T {
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

test "basic iterator" {}

test "foreach iterator" {}

test "map iterator" {}

test "fold iterator" {}

test "collect iterator" {}
