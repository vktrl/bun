const PackageManager = @import("./install.zig").PackageManager;
const Semver = @import("./semver.zig");
const ExternalString = Semver.ExternalString;
const String = Semver.String;
const std = @import("std");
const GitSHA = String;
const string = @import("../string_types.zig").string;

pub const Repository = extern struct {
    owner: String = String{},
    repo: String = String{},
    committish: GitSHA = GitSHA{},

    pub fn count(this: Repository, buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) void {
        builder.count(this.owner.slice(buf));
        builder.count(this.repo.slice(buf));
        builder.count(this.committish.slice(buf));
    }

    pub fn clone(this: Repository, buf: []const u8, comptime StringBuilder: type, builder: StringBuilder) Repository {
        return Repository{
            .owner = builder.append(String, this.owner.slice(buf)),
            .repo = builder.append(String, this.repo.slice(buf)),
            .committish = builder.append(GitSHA, this.committish.slice(buf)),
        };
    }

    pub fn eql(lhs: Repository, rhs: Repository, lhs_buf: []const u8, rhs_buf: []const u8) bool {
        return lhs.owner.eql(rhs.owner, lhs_buf, rhs_buf) and
            lhs.repo.eql(rhs.repo, lhs_buf, rhs_buf) and
            lhs.committish.eql(rhs.committish, lhs_buf, rhs_buf);
    }

    pub fn formatAs(this: Repository, label: string, buf: []const u8, comptime layout: []const u8, opts: std.fmt.FormatOptions, writer: anytype) !void {
        const formatter = Formatter{ .label = label, .repository = this, .buf = buf };
        return try formatter.format(layout, opts, writer);
    }

    pub const Formatter = struct {
        label: []const u8 = "",
        buf: []const u8,
        repository: Repository,
        pub fn format(formatter: Formatter, comptime layout: []const u8, opts: std.fmt.FormatOptions, writer: anytype) !void {
            std.debug.assert(formatter.label.len > 0);

            try writer.writeAll(formatter.label);
            try writer.writeAll(":");

            try writer.writeAll(formatter.repository.owner.slice(formatter.buf));
            try writer.writeAll(formatter.repository.repo.slice(formatter.buf));

            if (!formatter.repository.committish.isEmpty()) {
                try writer.writeAll("#");
                try writer.writeAll(formatter.repository.committish.slice(formatter.buf));
            }
        }
    };
};
