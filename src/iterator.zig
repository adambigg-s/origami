const ext = @import("iter_ext.zig");

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
            return ext.MapIterator(T, D){ .backing = self, .func = func };
        }

        pub fn fold(self: Self, comptime D: type, accum: D, func: *const fn (T) D) ext.FoldIterator(T, D) {
            return ext.FoldIterator(T, D){ .backing = self, .func = func, .accum = accum };
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
