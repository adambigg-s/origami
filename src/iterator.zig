pub const ext = @import("iter_ext.zig");
pub const RangeIterator = ext.RangeIterator;
pub const SliceIterator = ext.SliceIterator;
pub const SliceIteratorMut = ext.SliceIteratorMut;

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

        pub fn map(self: Self, comptime D: type, func: *const fn (T) D) ext.MapIterator(T, D) {
            return ext.MapIterator(T, D){
                .backing = self,
                .func = func,
            };
        }

        pub fn fold(self: Self, comptime D: type, accum: D, func: *const fn (T, D) D) ext.FoldIterator(T, D) {
            return ext.FoldIterator(T, D){
                .backing = self,
                .func = func,
                .accum = accum,
            };
        }

        pub fn enumerate(self: Self) ext.EnumerateIterator(T) {
            return ext.EnumerateIterator(T){
                .backing = self,
            };
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
    };
}

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
                if (!@hasDecl(info.pointer.child, "collect")) {
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
