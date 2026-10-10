module kernel.todo;
import std.conv : to;

public mixin template TODO(dstring message, string file = __FILE__, size_t line = __LINE__)
{
    pragma(msg, "TODO: " ~ message ~ " . From: " ~ file ~ '(' ~ line.to!dstring ~')');
}