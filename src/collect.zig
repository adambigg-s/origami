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
