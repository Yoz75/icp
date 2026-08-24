module cereslib.versions;

/// The program's version
public shared Version programVersion;

/// Semantic version
public struct Version
{
    size_t major, minor, patch;

    /// Parse version from string in format major.minor.patch
    /// Params:
    ///   stringVersion = 
    /// Returns: 
    public static Version fromString(immutable string stringVersion) pure
    {
        import std.array;
        import std.conv : to;

        Version result;

        string[] splitted = split(stringVersion, '.');

        result.major = splitted[0].to!size_t;
        result.minor = splitted[1].to!size_t;
        result.patch = splitted[2].to!size_t;

        return result;
    }

    /// Get version's representation as string
    /// Returns: string representation of version
    public string toString() inout pure
    {
        import std.conv : to;

        return major.to!string ~ '.' ~ minor.to!string ~ '.' ~ patch.to!string;
    }

    /// Get version's representation as wstring
    /// Returns: wstring representation of version
    public wstring toWstring() inout pure
    {
        import std.conv : to;

        return major.to!wstring ~ '.' ~ minor.to!wstring ~ '.' ~ patch.to!wstring;
    }

    /// Get version's representation as dstring
    /// Returns: dstring representation of version
    public dstring toDstring() inout pure
    {
        import std.conv : to;

        return major.to!dstring ~ '.' ~ minor.to!dstring ~ '.' ~ patch.to!dstring;
    }

        /// Get version's representation as string
    /// Returns: string representation of version
    public string toString() shared inout pure
    {
        import std.conv : to;

        size_t majorLocal = this.major;
        size_t minorLocal = this.minor;
        size_t patchLocal = this.patch;

        return majorLocal.to!string ~ '.' ~ minorLocal.to!string ~ '.' ~ patchLocal.to!string;
    }

    /// Get version's representation as string
    /// Returns: string representation of version
    public wstring toWstring() shared inout pure
    {
        import std.conv : to;

        size_t majorLocal = this.major;
        size_t minorLocal = this.minor;
        size_t patchLocal = this.patch;

        return majorLocal.to!wstring ~ '.' ~ minorLocal.to!wstring ~ '.' ~ patchLocal.to!wstring;
    }

    /// Get version's representation as string
    /// Returns: string representation of version
    public dstring toDstring() shared inout pure
    {
        import std.conv : to;

        size_t majorLocal = this.major;
        size_t minorLocal = this.minor;
        size_t patchLocal = this.patch;

        return majorLocal.to!dstring ~ '.' ~ minorLocal.to!dstring ~ '.' ~ patchLocal.to!dstring;
    }
}