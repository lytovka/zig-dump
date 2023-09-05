const std = @import("std");
const testing = std.testing;

const imported_file = @import("dummy.zig");

test {
    _ = U;
    _ = S;
    _ = imported_file;
}

const S = struct {
    test "me daddy" {
        return error.SkipZigTest;
        // try testing.expect(true);
    }
};

const U = union { // U is referenced by the file's top-level test declaration
    s: US, // and US is referenced here; therefore, "U.Us demo test" will run

    const US = struct {
        test "U.US demo test" {
            // This test is a top-level test declaration for the struct.
            // The struct is nested (declared) inside of a union.
            try testing.expect(true);
        }
    };

    test "U demo test" {
        try testing.expect(true);
    }
};
