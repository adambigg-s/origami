pub fn Iterator(comptime T: type) type {
    return struct {
        ptr: *anyopaque,
        vtable: VTable,

        pub const VTable = struct {
            next: *const fn (*anyopaque) ?*T,
        };

        const Self = @This();

        pub fn next(self: *Self) ?*T {
            return self.vtable.next(self.ptr);
        }

        pub fn iterator(ptr: anytype) Self {
            const D = @TypeOf(ptr);

            const gen = struct {
                pub fn next(pointer: *anyopaque) ?*T {
                    const self: D = @ptrCast(@alignCast(pointer));
                    if (self.next()) |item| {
                        return @ptrCast(@alignCast(item));
                    }
                    return null;
                }
            };

            return .{
                .ptr = ptr,
                .vtable = .{
                    .next = gen.next,
                },
            };
        }
    };
}

pub fn ForEach(comptime _: type) type {
    return struct {};
}

pub fn Map(comptime _: type) type {
    return struct {};
}

pub fn Fold(comptime _: type) type {
    return struct {};
}

test "basic iterator" {}

test "foreach iterator" {}

test "map iterator" {}

test "fold iterator" {}
